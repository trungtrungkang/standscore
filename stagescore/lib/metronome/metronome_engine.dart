import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:stagescore/metronome/click_wav.dart';
import 'package:stagescore/metronome/metronome_prefs.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Foreground metronome (Spec 0030).
///
/// Timing / audio model:
/// - **Audible clicks** come from a sample-timed looping WAV played by
///   [flutter_soloud] (keeps sounding under lock / background with
///   `UIBackgroundModes: audio` — Dart [Timer] alone is suspended).
/// - **Visual beat dots** use an absolute wall-clock [Timer] in the foreground.
/// - **Wakelock** while running so the score does not dim/lock mid-practice.
/// - Exactly one click voice is baked into each beat slot (accent *or* tick).
class MetronomeEngine extends ChangeNotifier {
  MetronomeEngine({MetronomePrefs? prefs})
    : _prefs = prefs ?? const MetronomePrefs();

  MetronomePrefs _prefs;
  Timer? _timer;
  int _absoluteBeat = 0;
  int _beatInBar = 0;
  int _loopLoadId = 0;
  bool _running = false;
  bool _ready = false;
  bool _sessionConfigured = false;
  DateTime? _anchorTime;

  AudioSource? _loopSource;
  SoundHandle? _loopHandle;

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
      'standscore_metro_loop_$id.wav',
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
        await _stopLoopAudio();
      } else {
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

    _timer?.cancel();
    _absoluteBeat = 0;
    _beatInBar = 0;
    _running = true;
    _anchorTime = DateTime.now();
    notifyListeners();
    _emitVisualBeat();
    _armTimer();
    await _startLoopAudio();
  }

  void _armTimer() {
    _timer?.cancel();
    if (!_running || _anchorTime == null) return;
    final interval = MetronomePrefs.beatInterval(_prefs.tempoBpm);
    final nextIndex = _absoluteBeat + 1;
    final target = _anchorTime!.add(interval * nextIndex);
    var delay = target.difference(DateTime.now());
    if (delay.isNegative) delay = Duration.zero;
    _timer = Timer(delay, () {
      if (!_running) return;
      _absoluteBeat = nextIndex;
      _emitVisualBeat();
      _armTimer();
    });
  }

  void _emitVisualBeat() {
    _beatInBar = MetronomePrefs.beatInBar(
      absoluteBeat: _absoluteBeat,
      beatsPerBar: _prefs.beatsPerBar,
    );
    notifyListeners();
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _running = false;
    _beatInBar = 0;
    _anchorTime = null;
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

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_stopLoopAudio());
    unawaited(WakelockPlus.disable());
    _ready = false;
    super.dispose();
  }
}
