import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stagescore/metronome/metronome_engine.dart';
import 'package:stagescore/sync_map/sync_map_entry.dart';
import 'package:stagescore/sync_map/sync_map_from_measure_map.dart';

/// Playback phase for SyncMap-driven Play (Spec 0059).
enum SyncMapPlaybackPhase {
  /// Stopped at the start; playhead hidden.
  stopped,

  /// Clicking count-in measures; playhead not yet on the score.
  countIn,

  /// Timeline running; playhead moves.
  playing,

  /// Frozen position; playhead stays visible.
  paused,
}

/// One audible click during SyncMap play / count-in.
typedef SyncMapClickPlayer = Future<void> Function({required bool accent});

/// Narrow Listenable clock for SyncMap Play / Pause / Stop + count-in.
///
/// Position is Stopwatch-backed. Audible clicks reuse [MetronomeEngine.playClick]
/// unless a [clickPlayer] is injected (tests).
class SyncMapPlayback extends ChangeNotifier {
  SyncMapPlayback({
    required MetronomeEngine metronome,
    SyncMapClickPlayer? clickPlayer,
  })  : _metronome = metronome,
        _clickPlayer = clickPlayer ??
            (({required bool accent}) => metronome.playClick(accent: accent));

  final MetronomeEngine _metronome;
  final SyncMapClickPlayer _clickPlayer;

  SyncMap _map = const SyncMap([]);
  SyncMapPlaybackPhase _phase = SyncMapPlaybackPhase.stopped;
  double _positionMs = 0;
  int _countInMeasures = 0;

  List<double> _countInBeatMs = const [];
  double _countInEndMs = 0;
  double _countInMsPerBeat = 500;
  int _countInBeatsPerBar = 4;
  int _countInTotalBeats = 0;
  int _nextCountInBeat = 0;
  int _nextScoreBeat = 0;
  List<({double ms, bool accent})> _scoreBeats = const [];

  Stopwatch? _clock;
  double _clockOriginMs = 0;
  Timer? _poll;

  static const _pollInterval = Duration(milliseconds: 16);

  /// Fire audible clicks this far ahead of the playhead clock so synthesis /
  /// device buffer latency does not make the playhead look early (Spec 0059).
  static const clickLeadMs = 45.0;

  SyncMap get map => _map;
  SyncMapPlaybackPhase get phase => _phase;
  double get positionMs => _positionMs;
  bool get isPlaying => _phase == SyncMapPlaybackPhase.playing;
  bool get isPaused => _phase == SyncMapPlaybackPhase.paused;
  bool get isCountIn => _phase == SyncMapPlaybackPhase.countIn;
  bool get isActive =>
      _phase == SyncMapPlaybackPhase.playing ||
      _phase == SyncMapPlaybackPhase.countIn;
  bool get playheadVisible =>
      _phase == SyncMapPlaybackPhase.playing ||
      _phase == SyncMapPlaybackPhase.paused;

  /// Timeline length in milliseconds (0 when empty).
  double get totalDurationMs => _map.totalDurationMs;

  /// Full count-in length in ms (0 when not counting in).
  double get countInTotalMs =>
      _phase == SyncMapPlaybackPhase.countIn ? _countInEndMs : 0;

  /// Milliseconds left before the score downbeat (0 when not counting in).
  double get countInRemainingMs {
    if (_phase != SyncMapPlaybackPhase.countIn) return 0;
    final elapsed = _clock?.elapsedMilliseconds.toDouble() ?? 0;
    return (_countInEndMs - elapsed).clamp(0.0, _countInEndMs);
  }

  /// Remaining count-in as `measures.beat` with **1-based** beat-in-bar
  /// (`2.4` … `2.1`, `1.4` … `1.1` for 4/4). Null when not in count-in.
  ({int measures, int beats, int beatsPerBar})? get countInRemaining {
    if (_phase != SyncMapPlaybackPhase.countIn) return null;
    final msPerBeat = _countInMsPerBeat <= 0 ? 500.0 : _countInMsPerBeat;
    final bpb = _countInBeatsPerBar <= 0 ? 4 : _countInBeatsPerBar;
    final remainingBeats = countInRemainingMs <= 0
        ? 0
        : (countInRemainingMs / msPerBeat).ceil().clamp(0, _countInTotalBeats);
    if (remainingBeats <= 0) {
      return (measures: 0, beats: 0, beatsPerBar: bpb);
    }
    return (
      measures: ((remainingBeats - 1) ~/ bpb) + 1,
      beats: ((remainingBeats - 1) % bpb) + 1,
      beatsPerBar: bpb,
    );
  }

  /// Seek the timeline. Syncs playhead + upcoming metronome clicks.
  ///
  /// - While **playing**: continue from [positionMs] (no click at the land).
  /// - While **count-in** / **stopped**: cancel count-in and land in **paused**
  ///   so the playhead shows at the scrubbed spot.
  /// - While **paused**: move the frozen position.
  void seekTo(double positionMs) {
    if (_map.isEmpty) return;
    final target = positionMs.clamp(0.0, totalDurationMs);

    if (_phase == SyncMapPlaybackPhase.countIn) {
      _stopPoll();
      _clock = null;
      _countInBeatMs = const [];
      _countInEndMs = 0;
      _countInTotalBeats = 0;
      _nextCountInBeat = 0;
      _phase = SyncMapPlaybackPhase.paused;
    } else if (_phase == SyncMapPlaybackPhase.stopped) {
      _phase = SyncMapPlaybackPhase.paused;
    }

    _positionMs = target;
    // Beats at or before the scrub point are skipped; the next click is the
    // first beat strictly after [target] (or on it if we landed early).
    _advanceScoreCursorPast(_positionMs);

    if (_phase == SyncMapPlaybackPhase.playing) {
      _clockOriginMs = _positionMs;
      _clock = Stopwatch()..start();
      if (_poll == null) _startPoll();
    }

    notifyListeners();
  }

  /// Replace the computed SyncMap. While playing/paused, continue from the
  /// nearest surviving measure+beat; if gone, Stop and return `false` (G3 7).
  bool replaceMap(SyncMap next) {
    final wasEngaged = isActive || isPaused;
    final previousMs = _positionMs;
    _map = next;
    _scoreBeats = _buildScoreBeats(next);
    if (!wasEngaged) return true;
    if (next.isEmpty) {
      stop();
      return false;
    }
    final nearest = nearestMeasureBeat(next, previousMs);
    SyncMapEntry? entry;
    if (nearest != null) {
      for (final e in next.entries) {
        if (e.measure == nearest.measure) {
          entry = e;
          break;
        }
      }
    }
    if (entry == null) {
      stop();
      return false;
    }
    final beats = entry.beatTimestamps;
    final idx = nearest!.beatIndex.clamp(
      0,
      beats.isEmpty ? 0 : beats.length - 1,
    );
    _positionMs = beats.isEmpty ? entry.timeMs : beats[idx];
    _advanceScoreCursorPast(_positionMs);
    if (_phase == SyncMapPlaybackPhase.playing) {
      _clockOriginMs = _positionMs;
      _clock = Stopwatch()..start();
    }
    notifyListeners();
    return true;
  }

  void setCountInMeasures(int n) {
    _countInMeasures = n.clamp(0, 2);
  }

  /// Play from Stop (count-in then start) or resume from Pause (no count-in).
  Future<void> play() async {
    if (_map.isEmpty) return;
    if (_metronome.isRunning) await _metronome.stop();
    // Warm SoLoud click buffers before the first beat (avoids playhead lead).
    // Ignore failures in unit tests without a platform binding.
    try {
      await _metronome.ensureClicksReady();
    } catch (_) {}

    if (_phase == SyncMapPlaybackPhase.paused) {
      _phase = SyncMapPlaybackPhase.playing;
      _clockOriginMs = _positionMs;
      _clock = Stopwatch()..start();
      // Skip beats already passed; poll applies [clickLeadMs] for the next ones.
      _advanceScoreCursorPast(_positionMs);
      _startPoll();
      notifyListeners();
      return;
    }

    _positionMs = _map.first!.timeMs;
    _advanceScoreCursorPast(_positionMs - 1); // allow downbeat at t=0

    if (_countInMeasures > 0) {
      _beginCountIn();
    } else {
      _beginPlaying(fireDownbeat: true);
    }
  }

  void pause() {
    if (!isActive) return;
    if (_phase == SyncMapPlaybackPhase.countIn) {
      // Abort count-in → paused at score start with playhead visible? Spec:
      // playhead during count-in is hidden; Pause mid count-in → treat as
      // paused at start (playhead can show at start).
      _positionMs = _map.first!.timeMs;
    } else {
      _positionMs = _clockOriginMs + (_clock?.elapsedMilliseconds ?? 0);
    }
    _stopPoll();
    _clock = null;
    _phase = SyncMapPlaybackPhase.paused;
    notifyListeners();
  }

  void stop() {
    _stopPoll();
    _clock = null;
    _phase = SyncMapPlaybackPhase.stopped;
    _positionMs = _map.isEmpty ? 0 : _map.first!.timeMs;
    _countInBeatMs = const [];
    _countInEndMs = 0;
    _countInTotalBeats = 0;
    _nextCountInBeat = 0;
    _nextScoreBeat = 0;
    notifyListeners();
  }

  void _beginCountIn() {
    final target = _map.first!;
    final parts = parseTimeSignatureParts(target.timeSignature);
    final msPerBeat =
        60000.0 / target.tempo * quartersPerBeat(parts.denominator);
    final totalBeats = parts.numerator * _countInMeasures;
    _countInBeatsPerBar = parts.numerator;
    _countInMsPerBeat = msPerBeat;
    _countInTotalBeats = totalBeats;
    _countInBeatMs = [
      for (var i = 0; i < totalBeats; i++) i * msPerBeat,
    ];
    // Last click, then one full beat until the score downbeat.
    _countInEndMs = totalBeats <= 0 ? 0 : totalBeats * msPerBeat;
    _nextCountInBeat = 0;
    _phase = SyncMapPlaybackPhase.countIn;
    _clockOriginMs = 0;
    _clock = Stopwatch()..start();
    _startPoll();
    unawaited(_fireCountInBeat(0));
    _nextCountInBeat = 1;
    notifyListeners();
  }

  void _beginPlaying({required bool fireDownbeat}) {
    _phase = SyncMapPlaybackPhase.playing;
    _positionMs = _map.first!.timeMs;
    _clockOriginMs = _positionMs;
    _clock = Stopwatch()..start();
    _advanceScoreCursorPast(fireDownbeat ? _positionMs - 1 : _positionMs);
    _startPoll();
    if (fireDownbeat && _scoreBeats.isNotEmpty) {
      unawaited(_clickPlayer(accent: _scoreBeats.first.accent));
      _nextScoreBeat = 1;
    }
    notifyListeners();
  }

  List<({double ms, bool accent})> _buildScoreBeats(SyncMap map) {
    final out = <({double ms, bool accent})>[];
    for (final e in map.entries) {
      for (var i = 0; i < e.beatTimestamps.length; i++) {
        out.add((
          ms: e.beatTimestamps[i],
          accent: e.startsAtBeat == 0 && i == 0,
        ));
      }
    }
    return out;
  }

  void _advanceScoreCursorPast(double ms) {
    _nextScoreBeat = 0;
    while (_nextScoreBeat < _scoreBeats.length &&
        _scoreBeats[_nextScoreBeat].ms <= ms + 1e-6) {
      _nextScoreBeat++;
    }
  }

  void _startPoll() {
    _poll?.cancel();
    _poll = Timer.periodic(_pollInterval, (_) => _onPoll());
  }

  void _stopPoll() {
    _poll?.cancel();
    _poll = null;
  }

  void _onPoll() {
    if (_phase == SyncMapPlaybackPhase.countIn) {
      final elapsed = _clock?.elapsedMilliseconds.toDouble() ?? 0;
      final clickHorizon = elapsed + clickLeadMs;
      while (_nextCountInBeat < _countInBeatMs.length &&
          clickHorizon + 1e-6 >= _countInBeatMs[_nextCountInBeat]) {
        unawaited(_fireCountInBeat(_nextCountInBeat));
        _nextCountInBeat++;
      }
      if (elapsed + 1e-6 >= _countInEndMs) {
        _beginPlaying(fireDownbeat: true);
        return;
      }
      // Drive the countdown UI every tick.
      notifyListeners();
      return;
    }

    if (_phase != SyncMapPlaybackPhase.playing) return;

    final elapsed = _clockOriginMs + (_clock?.elapsedMilliseconds ?? 0);
    // Playhead follows the clock; clicks fire slightly early to cover latency.
    _positionMs = elapsed;
    final clickHorizon = elapsed + clickLeadMs;

    while (_nextScoreBeat < _scoreBeats.length &&
        clickHorizon + 1e-6 >= _scoreBeats[_nextScoreBeat].ms) {
      unawaited(_clickPlayer(accent: _scoreBeats[_nextScoreBeat].accent));
      _nextScoreBeat++;
    }

    if (_positionMs >= _map.totalDurationMs - 1e-6) {
      stop();
      return;
    }
    notifyListeners();
  }

  Future<void> _fireCountInBeat(int index) async {
    final parts = parseTimeSignatureParts(_map.first!.timeSignature);
    final accent = index % parts.numerator == 0;
    await _clickPlayer(accent: accent);
  }

  @override
  void dispose() {
    _stopPoll();
    _clock = null;
    super.dispose();
  }
}
