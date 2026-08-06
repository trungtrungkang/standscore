import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:stagescore/metronome/beat_clock.dart';
import 'package:stagescore/metronome/click_wav.dart';
import 'package:stagescore/metronome/metronome_prefs.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// How often the beat is read back from the clock. One frame at 60 fps, so a
/// dot never lands a frame late. Listeners are notified only when the beat
/// actually changes, which keeps the notification rate at beats-per-second
/// rather than 60 Hz (Spec 0030 reopen, decision 4).
const _beatPollInterval = Duration(milliseconds: 16);

/// Foreground metronome (Spec 0030).
///
/// Timing / audio model:
/// - **Audible clicks** come from a sample-timed looping WAV played by
///   [flutter_soloud] (keeps sounding under lock / background with
///   `UIBackgroundModes: audio` — Dart [Timer] alone is suspended).
/// - **Visual beat dots read the same clock as the clicks**: the play head of
///   that loop, mapped to a beat by [beatInBarFromLoopPosition]. Dots cannot
///   lead or lag the sound by construction, and cannot drift away from it,
///   because there is no second clock to drift against. See `beat_clock.dart`
///   for what went wrong when there were two.
/// - **Mute (visual only)** has no play head to read, so it is the one case
///   that needs a clock of its own: a monotonic [Stopwatch] feeding the same
///   mapping. [_silentOffset] carries the play head's last position into it, so
///   muting mid-bar does not restart the count.
/// - **Wakelock** while running so the score does not dim/lock mid-practice.
/// - Exactly one click voice is baked into each beat slot (accent *or* tick).
class MetronomeEngine extends ChangeNotifier {
  MetronomeEngine({MetronomePrefs? prefs})
    : _prefs = prefs ?? const MetronomePrefs();

  MetronomePrefs _prefs;
  Timer? _beatPoll;
  int _beatInBar = 0;
  int _loopLoadId = 0;
  bool _running = false;
  bool _ready = false;
  bool _sessionConfigured = false;

  /// Stands in for the play head while muted, and only then.
  Stopwatch? _silentClock;

  /// Where in the bar [_silentClock] started, so mute keeps the count going.
  Duration _silentOffset = Duration.zero;

  AudioSource? _loopSource;
  SoundHandle? _loopHandle;

  /// Preloaded one-shot clicks for SyncMap Play (Spec 0059) — avoids
  /// synthesize + loadMem on every beat, which made the playhead lead the ear.
  AudioSource? _accentClickSource;
  AudioSource? _tickClickSource;

  MetronomePrefs get prefs => _prefs;
  bool get isRunning => _running;
  int get beatInBar => _beatInBar;
  bool get isAccent =>
      _prefs.accentEnabled && MetronomePrefs.isAccentBeat(_beatInBar);

  Future<void> _ensureAudioSession() async {
    if (_sessionConfigured) return;
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        // playback: ignore silent switch; keep audio eligible for background.
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          usage: AndroidAudioUsage.assistanceSonification,
        ),
        androidAudioFocusGainType:
            AndroidAudioFocusGainType.gainTransientMayDuck,
      ),
    );
    _sessionConfigured = true;
  }

  Future<void> _ensureReady() async {
    if (_ready) return;
    await _ensureAudioSession();
    final soloud = SoLoud.instance;
    if (!soloud.isInitialized) {
      await soloud.init(
        bufferSize: 512,
        channels: Channels.mono,
        automaticCleanup: true,
      );
    }
    _ready = true;
  }

  Future<void> _stopLoopAudio() async {
    final handle = _loopHandle;
    final source = _loopSource;
    _loopHandle = null;
    _loopSource = null;
    final soloud = SoLoud.instance;
    if (!soloud.isInitialized) return;
    if (handle != null) {
      try {
        await soloud.stop(handle);
      } catch (_) {}
    }
    if (source != null) {
      try {
        await soloud.disposeSource(source);
      } catch (_) {}
    }
  }

  Future<void> _startLoopAudio() async {
    await _stopLoopAudio();
    if (!_running || _prefs.muted || _prefs.volume <= 0.001) return;

    final wav = synthesizeMetronomeLoopWav(
      tempoBpm: _prefs.tempoBpm,
      beatsPerBar: _prefs.beatsPerBar,
      accentEnabled: _prefs.accentEnabled,
    );
    final id = ++_loopLoadId;
    final source = await SoLoud.instance.loadMem(
      'stagescore_metro_loop_$id.wav',
      wav,
      mode: LoadMode.memory,
    );
    if (!_running || id != _loopLoadId) {
      await SoLoud.instance.disposeSource(source);
      return;
    }
    _loopSource = source;
    _loopHandle = SoLoud.instance.play(
      source,
      volume: _prefs.volume.clamp(0.0, 1.0),
      looping: true,
    );
  }

  Future<void> updatePrefs(MetronomePrefs prefs) async {
    final wasRunning = _running;
    final timingChanged =
        prefs.tempoBpm != _prefs.tempoBpm ||
        prefs.beatsPerBar != _prefs.beatsPerBar ||
        prefs.accentEnabled != _prefs.accentEnabled ||
        prefs.beatUnit != _prefs.beatUnit;
    final muteChanged = prefs.muted != _prefs.muted;
    final volumeChanged = prefs.volume != _prefs.volume;
    _prefs = prefs;

    if (!wasRunning) {
      notifyListeners();
      return;
    }

    if (timingChanged) {
      await stop();
      await start();
      return;
    }

    if (volumeChanged && _loopHandle != null) {
      SoLoud.instance.setVolume(_loopHandle!, _prefs.volume.clamp(0.0, 1.0));
    }
    if (muteChanged) {
      if (_prefs.muted || _prefs.volume <= 0.001) {
        // Carry the beat over before the play head goes away.
        _carryPositionToSilentClock();
        await _stopLoopAudio();
      } else {
        // The new play head starts the bar again, audibly; the dots follow it
        // there rather than keeping a count of their own.
        await _startLoopAudio();
      }
    }
    notifyListeners();
  }

  Future<void> start() async {
    await _ensureReady();
    try {
      await (await AudioSession.instance).setActive(true);
    } catch (_) {}
    try {
      await WakelockPlus.enable();
    } catch (_) {}

    _beatPoll?.cancel();
    _beatInBar = 0;
    _running = true;
    // _startLoopAudio checks _running, so the flag has to be up before the
    // clock exists. Nothing reads the beat until isRunning is announced.
    notifyListeners();

    // Audio first, then the clock: the play head *is* the clock, so there is
    // nothing for the dots to follow until the loop is playing. This ordering
    // is the fix — anchoring before this line is what put the dots ahead of
    // the clicks by however long synthesis, loadMem and play() took.
    await _startLoopAudio();
    if (!_running) return; // stopped while the buffer was being built

    _silentOffset = Duration.zero;
    _silentClock = Stopwatch()..start();
    _beatInBar = _readBeat();
    notifyListeners();
    _beatPoll = Timer.periodic(_beatPollInterval, (_) => _pollBeat());
  }

  void _pollBeat() {
    if (!_running) return;
    final beat = _readBeat();
    if (beat == _beatInBar) return; // notify on the beat, not on the poll
    _beatInBar = beat;
    notifyListeners();
  }

  int _readBeat() {
    final interval = metronomeAudioBeatInterval(tempoBpm: _prefs.tempoBpm);
    return beatInBarFromLoopPosition(
      position: _clockPosition(),
      beatInterval: interval,
      beatsPerBar: _prefs.beatsPerBar,
    );
  }

  /// The play head when the clicks are audible; the silent stand-in when not.
  Duration _clockPosition() {
    final handle = _loopHandle;
    if (handle != null) {
      try {
        return SoLoud.instance.getPosition(handle);
      } catch (_) {
        // Engine torn down under us — fall through to the silent clock.
      }
    }
    return (_silentClock?.elapsed ?? Duration.zero) + _silentOffset;
  }

  /// Hands the play head's position to the silent clock, so losing the audio
  /// (mute) continues the bar instead of restarting it.
  void _carryPositionToSilentClock() {
    final position = _clockPosition();
    _silentOffset = position;
    _silentClock = Stopwatch()..start();
  }

  Future<void> stop() async {
    _beatPoll?.cancel();
    _beatPoll = null;
    _running = false;
    _beatInBar = 0;
    _silentClock = null;
    _silentOffset = Duration.zero;
    await _stopLoopAudio();
    try {
      await WakelockPlus.disable();
    } catch (_) {}
    notifyListeners();
  }

  Future<void> toggle() async {
    if (_running) {
      await stop();
    } else {
      await start();
    }
  }

  /// Load one-shot click buffers once (safe to call before SyncMap Play).
  Future<void> ensureClicksReady() async {
    if (_prefs.muted || _prefs.volume <= 0.001) return;
    await _ensureClickSources();
  }

  Future<void> _ensureClickSources() async {
    await _ensureReady();
    if (_accentClickSource != null && _tickClickSource != null) return;
    try {
      await (await AudioSession.instance).setActive(true);
    } catch (_) {}
    // Same pitch pair as [synthesizeMetronomeLoopWav].
    _accentClickSource ??= await SoLoud.instance.loadMem(
      'stagescore_metro_click_accent.wav',
      synthesizeClickWav(frequencyHz: 880, durationMs: 30, amplitude: 0.9),
      mode: LoadMode.memory,
    );
    _tickClickSource ??= await SoLoud.instance.loadMem(
      'stagescore_metro_click_tick.wav',
      synthesizeClickWav(frequencyHz: 1200, durationMs: 30, amplitude: 0.55),
      mode: LoadMode.memory,
    );
  }

  Future<void> _disposeClickSources() async {
    final accent = _accentClickSource;
    final tick = _tickClickSource;
    _accentClickSource = null;
    _tickClickSource = null;
    final soloud = SoLoud.instance;
    if (!soloud.isInitialized) return;
    for (final source in [accent, tick]) {
      if (source == null) continue;
      try {
        await soloud.disposeSource(source);
      } catch (_) {}
    }
  }

  /// One-shot click for SyncMap-driven Play (Spec 0059).
  ///
  /// Reuses cached SoLoud sources + this engine's volume/mute prefs.
  /// Does not start the looping metronome.
  Future<void> playClick({required bool accent}) async {
    if (_prefs.muted || _prefs.volume <= 0.001) return;
    await _ensureClickSources();
    final source = accent ? _accentClickSource : _tickClickSource;
    if (source == null) return;
    try {
      SoLoud.instance.play(
        source,
        volume: _prefs.volume.clamp(0.0, 1.0),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _beatPoll?.cancel();
    unawaited(_stopLoopAudio());
    unawaited(_disposeClickSources());
    unawaited(WakelockPlus.disable());
    _ready = false;
    super.dispose();
  }
}
