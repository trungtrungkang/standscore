import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/measure_map/measure_box.dart';
import 'package:stagescore/measure_map/measure_map_store.dart';
import 'package:stagescore/sync_map/sync_map_from_measure_map.dart';

void main() {
  MeasureMapStore mapWith({required int count}) {
    final store = MeasureMapStore();
    store.addSystem(
      pageNumber: 1,
      x: 0,
      y: 0,
      width: 1,
      height: 0.1,
      measureCount: count,
    );
    return store;
  }

  void replaceBox(MeasureMapStore store, MeasureBox box) {
    final json = store.toJson('t');
    final list = (json['measures'] as List).cast<Map<String, dynamic>>();
    for (var i = 0; i < list.length; i++) {
      if (list[i]['id'] == box.id) list[i] = box.toJson();
    }
    store.loadJson({'scoreId': 't', 'measures': list});
  }

  group('syncMapFromMeasureMap', () {
    test('empty map → empty SyncMap', () {
      expect(syncMapFromMeasureMap(MeasureMapStore()).isEmpty, isTrue);
    });

    test('4/4 at 120 → 2000 ms per measure, even beatTimestamps', () {
      final store = mapWith(count: 2);
      final sync = syncMapFromMeasureMap(store);
      expect(sync.entries.length, 2);

      final e0 = sync.entries[0];
      expect(e0.measure, 1);
      expect(e0.tempo, 120);
      expect(e0.timeSignature, '4/4');
      expect(e0.durationInQuarters, 4);
      expect(e0.timeMs, 0);
      expect(e0.beatTimestamps, [0, 500, 1000, 1500]);
      expect(e0.beatTimestamps[0], e0.timeMs);

      final e1 = sync.entries[1];
      expect(e1.timeMs, 2000);
      expect(e1.beatTimestamps, [2000, 2500, 3000, 3500]);
      expect(sync.totalDurationMs, 4000);
    });

    test('tempo change mid-score', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 1,
        height: 0.1,
        measureCount: 2,
      );
      store.applyMeta(
        anchorId: store.boxes[1].id,
        scope: MeasureMetaScope.thisMeasure,
        tempo: 60,
      );
      final sync = syncMapFromMeasureMap(store);
      expect(sync.entries[0].tempo, 120);
      expect(sync.entries[0].durationMs, 2000);
      expect(sync.entries[1].tempo, 60);
      expect(sync.entries[1].timeMs, 2000);
      expect(sync.entries[1].durationMs, 4000);
    });

    test('3/4 shortens duration; 6/8 is three quarters', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 1,
        height: 0.1,
        measureCount: 2,
      );
      store.applyMeta(
        anchorId: store.boxes.first.id,
        scope: MeasureMetaScope.thisMeasure,
        timeSignature: '3/4',
        tempo: 120,
      );
      store.applyMeta(
        anchorId: store.boxes[1].id,
        scope: MeasureMetaScope.thisMeasure,
        timeSignature: '6/8',
        tempo: 120,
      );
      final sync = syncMapFromMeasureMap(store);
      expect(sync.entries[0].durationInQuarters, 3);
      expect(sync.entries[0].beatTimestamps.length, 3);
      expect(sync.entries[0].durationMs, 1500);
      // 6/8: 6 × (4/8) = 3 quarters.
      expect(sync.entries[1].durationInQuarters, 3);
      expect(sync.entries[1].beatTimestamps.length, 6);
      expect(sync.entries[1].timeMs, 1500);
    });

    test('beatSplits do not change timeline', () {
      final even = mapWith(count: 1);
      final skewed = MeasureMapStore();
      skewed.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 1,
        height: 0.1,
        measureCount: 1,
      );
      final id = skewed.boxes.first.id;
      replaceBox(
        skewed,
        skewed.boxes.first.copyWith(beatSplits: [0.1, 0.2, 0.3, 0.9]),
      );
      expect(skewed.byId(id)!.beatSplits, [0.1, 0.2, 0.3, 0.9]);

      final a = syncMapFromMeasureMap(even);
      final b = syncMapFromMeasureMap(skewed);
      expect(a.entries.first.beatTimestamps, b.entries.first.beatTimestamps);
      expect(
        a.entries.first.durationInQuarters,
        b.entries.first.durationInQuarters,
      );
    });

    test('gap in measure numbers — no invented silence', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 0.5,
        height: 0.1,
        measureCount: 1,
      );
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0.2,
        width: 0.5,
        height: 0.1,
        measureCount: 1,
      );
      // Delete middle would renumber — instead leave two measures 1,2 contiguous.
      // Spec: missing numbers between present ones are skipped. Simulate by
      // forcing measureNumber gap after renumber via replace.
      replaceBox(store, store.boxes[1].copyWith(measureNumber: 5));
      final sync = syncMapFromMeasureMap(store);
      expect(sync.entries.map((e) => e.measure), [1, 5]);
      expect(sync.entries[1].timeMs, 2000); // immediately after m1
    });

    test('Option A pickup — short 1/4 then 4/4', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 0.2,
        height: 0.1,
        measureCount: 1,
      );
      store.addSystem(
        pageNumber: 1,
        x: 0.2,
        y: 0,
        width: 0.8,
        height: 0.1,
        measureCount: 1,
      );
      store.applyMeta(
        anchorId: store.boxes.first.id,
        scope: MeasureMetaScope.thisMeasure,
        timeSignature: '1/4',
        tempo: 120,
      );
      store.applyMeta(
        anchorId: store.boxes[1].id,
        scope: MeasureMetaScope.thisMeasure,
        timeSignature: '4/4',
        tempo: 120,
      );
      final sync = syncMapFromMeasureMap(store);
      expect(sync.entries[0].durationMs, 500);
      expect(sync.entries[0].beatTimestamps, [0.0]);
      expect(sync.entries[1].timeMs, 500);
      expect(sync.entries[1].beatTimestamps.first, 500);
    });

    test('Option B startsAtBeat skips prior beats', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 1,
        height: 0.1,
        measureCount: 2,
      );
      store.setStartsAtBeat(store.boxes.first.id, 3); // last beat of 4/4
      final sync = syncMapFromMeasureMap(store);
      expect(sync.entries[0].startsAtBeat, 3);
      expect(sync.entries[0].durationInQuarters, 1);
      expect(sync.entries[0].beatTimestamps, [0.0]);
      expect(sync.entries[0].durationMs, 500);
      // Next measure downbeat at 500 — invariant § D2.
      expect(sync.entries[1].timeMs, 500);
      expect(sync.entries[1].startsAtBeat, 0);
    });
  });
}
