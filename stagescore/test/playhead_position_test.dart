import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/measure_map/measure_map_store.dart';
import 'package:stagescore/sync_map/playhead_position.dart';
import 'package:stagescore/sync_map/sync_map_from_measure_map.dart';

void main() {
  group('playheadAtTime', () {
    test('downbeat lands on first beatSplit anchor', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 2,
        x: 0.1,
        y: 0.2,
        width: 0.8,
        height: 0.1,
        measureCount: 1,
      );
      // evenBeatSplits(4) = [0.125, 0.375, 0.625, 0.875]
      final sync = syncMapFromMeasureMap(store);
      final pos = playheadAtTime(syncMap: sync, store: store, timeMs: 0)!;
      expect(pos.pageNumber, 2);
      expect(pos.measure, 1);
      expect(pos.beatIndex, 0);
      // x = 0.1 + 0.8 * 0.125
      expect(pos.x, closeTo(0.1 + 0.8 * 0.125, 1e-9));
      expect(pos.y, closeTo(0.25, 1e-9));
      expect(pos.top, closeTo(0.2, 1e-9));
      expect(pos.height, closeTo(0.1, 1e-9));
    });

    test('interpolates between two beatSplits mid-beat', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 1,
        height: 0.1,
        measureCount: 1,
      );
      final sync = syncMapFromMeasureMap(store);
      // Halfway through first beat (0–500 ms) at tempo 120.
      final pos = playheadAtTime(syncMap: sync, store: store, timeMs: 250)!;
      final a0 = 0.125;
      final a1 = 0.375;
      expect(pos.x, closeTo((a0 + a1) / 2, 1e-9));
      expect(pos.beatIndex, 0);
    });

    test('startsAtBeat playhead begins at that beatSplit', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 1,
        height: 0.1,
        measureCount: 1,
      );
      store.setStartsAtBeat(store.boxes.first.id, 3);
      final sync = syncMapFromMeasureMap(store);
      final pos = playheadAtTime(syncMap: sync, store: store, timeMs: 0)!;
      expect(pos.x, closeTo(0.875, 1e-9)); // evenBeatSplits(4)[3]
      expect(pos.beatIndex, 0);
    });

    test('empty map → null', () {
      expect(
        playheadAtTime(
          syncMap: syncMapFromMeasureMap(MeasureMapStore()),
          store: MeasureMapStore(),
          timeMs: 0,
        ),
        isNull,
      );
    });

    test('last beat eases into next measure first beat — no barline jump', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0.2,
        width: 1,
        height: 0.1,
        measureCount: 2,
      );
      final sync = syncMapFromMeasureMap(store);
      // Two 4/4 @ 120: m1 = 0–2000, last beat 1500–2000; m2 starts at 2000.
      // evenBeatSplits(4): last of m1 = 0.875 → page x = 0 + 0.5*0.875 = 0.4375
      // first of m2 = 0.125 → page x = 0.5 + 0.5*0.125 = 0.5625
      final atLastBeatStart =
          playheadAtTime(syncMap: sync, store: store, timeMs: 1500)!;
      expect(atLastBeatStart.x, closeTo(0.4375, 1e-9));

      final midHandoff =
          playheadAtTime(syncMap: sync, store: store, timeMs: 1750)!;
      expect(midHandoff.x, closeTo((0.4375 + 0.5625) / 2, 1e-9));
      expect(midHandoff.measure, 1);

      final atNextDownbeat =
          playheadAtTime(syncMap: sync, store: store, timeMs: 2000)!;
      expect(atNextDownbeat.x, closeTo(0.5625, 1e-9));
      expect(atNextDownbeat.measure, 2);

      // Continuous: end of m1 last beat lands on m2 first beat.
      final endOfM1 =
          playheadAtTime(syncMap: sync, store: store, timeMs: 2000 - 1e-6)!;
      expect(endOfM1.x, closeTo(atNextDownbeat.x, 1e-6));
    });
  });
}
