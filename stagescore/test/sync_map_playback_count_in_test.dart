import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/measure_map/measure_map_store.dart';
import 'package:stagescore/metronome/metronome_engine.dart';
import 'package:stagescore/sync_map/sync_map_from_measure_map.dart';
import 'package:stagescore/sync_map/sync_map_playback.dart';

void main() {
  group('SyncMapPlayback count-in', () {
    SyncMapPlayback makePlayback(MeasureMapStore store) {
      // No-op clicks — avoid SoLoud / wakelock channels in unit tests.
      final playback = SyncMapPlayback(
        metronome: MetronomeEngine(),
        clickPlayer: ({required bool accent}) async {},
      );
      playback.replaceMap(syncMapFromMeasureMap(store));
      return playback;
    }

    test('after Stop, play enters countIn when count-in > 0', () async {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 1,
        height: 0.1,
        measureCount: 1,
      );
      final playback = makePlayback(store);
      addTearDown(playback.dispose);
      playback.setCountInMeasures(1);

      await playback.play();
      expect(playback.phase, SyncMapPlaybackPhase.countIn);
      expect(playback.playheadVisible, isFalse);
      // 1 measure of 4/4 @ 120 → 2000 ms / 4 beats count-in.
      expect(playback.countInTotalMs, 2000);
      expect(playback.countInRemainingMs, closeTo(2000, 50));
      // 4/4 count-in: start shows 1.4 (measure.beat, 1-based).
      expect(playback.countInRemaining?.measures, 1);
      expect(playback.countInRemaining?.beats, 4);

      playback.stop();
      expect(playback.phase, SyncMapPlaybackPhase.stopped);
      expect(playback.playheadVisible, isFalse);
      expect(playback.countInRemainingMs, 0);
      expect(playback.countInRemaining, isNull);
    });

    test('count-in 2 starts at 2.4 for 4/4', () async {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 1,
        height: 0.1,
        measureCount: 1,
      );
      final playback = makePlayback(store);
      addTearDown(playback.dispose);
      playback.setCountInMeasures(2);

      await playback.play();
      expect(playback.phase, SyncMapPlaybackPhase.countIn);
      expect(playback.countInRemaining?.measures, 2);
      expect(playback.countInRemaining?.beats, 4);
    });

    test('count-in 0 starts playing immediately', () async {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 1,
        height: 0.1,
        measureCount: 1,
      );
      final playback = makePlayback(store);
      addTearDown(playback.dispose);
      playback.setCountInMeasures(0);

      await playback.play();
      expect(playback.phase, SyncMapPlaybackPhase.playing);
      expect(playback.playheadVisible, isTrue);

      playback.pause();
      expect(playback.phase, SyncMapPlaybackPhase.paused);
      final pausedAt = playback.positionMs;

      await playback.play();
      // Resume from Pause — no count-in (G3 11b).
      expect(playback.phase, SyncMapPlaybackPhase.playing);
      expect(playback.positionMs, closeTo(pausedAt, 50));
    });

    test('Stop resets to timeline start and hides playhead', () async {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 1,
        height: 0.1,
        measureCount: 1,
      );
      final playback = makePlayback(store);
      addTearDown(playback.dispose);
      playback.setCountInMeasures(0);
      await playback.play();
      playback.pause();
      playback.stop();
      expect(playback.phase, SyncMapPlaybackPhase.stopped);
      expect(playback.positionMs, 0);
      expect(playback.playheadVisible, isFalse);
    });

    test('seekTo moves position and shows playhead from Stop', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 1,
        height: 0.1,
        measureCount: 2,
      );
      final playback = makePlayback(store);
      addTearDown(playback.dispose);

      expect(playback.totalDurationMs, 4000);
      playback.seekTo(1500);
      expect(playback.phase, SyncMapPlaybackPhase.paused);
      expect(playback.positionMs, 1500);
      expect(playback.playheadVisible, isTrue);

      playback.seekTo(99999);
      expect(playback.positionMs, 4000);
    });

    test('seek while playing keeps playing from the new origin', () async {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 1,
        height: 0.1,
        measureCount: 2,
      );
      final playback = makePlayback(store);
      addTearDown(playback.dispose);
      playback.setCountInMeasures(0);
      await playback.play();
      expect(playback.phase, SyncMapPlaybackPhase.playing);

      playback.seekTo(2500);
      expect(playback.phase, SyncMapPlaybackPhase.playing);
      expect(playback.positionMs, closeTo(2500, 30));
    });
  });
}
