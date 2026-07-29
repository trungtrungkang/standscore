import 'package:stagescore/metronome/metronome_prefs.dart';

/// Maps a position inside the looping click buffer to the beat of the bar
/// (Spec 0030, reopened twice on 2026-07-29).
///
/// The metronome used to run two clocks that nothing tied together: the dots
/// were driven by a Dart timer anchored at the moment Start was pressed, while
/// the clicks were driven by the audio device's sample clock, which only began
/// once the buffer had been synthesised, copied across the FFI boundary and
/// handed to the mixer. Everything spent in between became a permanent phase
/// error, because from then on both clocks ran free at the same rate and so
/// nothing ever pulled them back together.
///
/// Now there is one clock — the audio play head — and this is the single
/// mapping from it to a beat. Two properties are worth keeping:
///
/// - It takes a *position*, not a beat count, so it is stateless. Sampling it
///   late (a dropped frame, a busy isolate) yields the beat that is sounding
///   now rather than the beat after the one it last reported.
/// - It reduces modulo the bar, so it is correct whether the audio backend
///   reports a play head that wraps at the end of the loop or one that keeps
///   accumulating across repeats. Neither is promised by the plugin.
///
/// [beatInterval] must be the beat length of the buffer that is actually
/// playing — see `metronomeAudioBeatInterval` — and not the nominal tempo
/// interval, so that a play head which accumulates cannot drift against it.
int beatInBarFromLoopPosition({
  required Duration position,
  required Duration beatInterval,
  required int beatsPerBar,
}) {
  final beats = MetronomePrefs.clampBeatsPerBar(beatsPerBar);
  final intervalUs = beatInterval.inMicroseconds;
  if (intervalUs <= 0) return 0;
  final loopUs = intervalUs * beats;
  var us = position.inMicroseconds % loopUs;
  if (us < 0) us += loopUs; // a position before the loop start still lands
  return (us ~/ intervalUs).clamp(0, beats - 1);
}
