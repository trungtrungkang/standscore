import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/form_map/form_map.dart';
import 'package:stagescore/form_map/form_map_unroll.dart';
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

  List<int> physicals(SyncMapBuildResult result) {
    expect(result, isA<SyncMapBuildSuccess>());
    return [
      for (final e in (result as SyncMapBuildSuccess).map.entries)
        e.physicalMeasure,
    ];
  }

  List<int> latents(SyncMapBuildResult result) {
    expect(result, isA<SyncMapBuildSuccess>());
    return [
      for (final e in (result as SyncMapBuildSuccess).map.entries) e.measure,
    ];
  }

  group('empty FormMap = 0059', () {
    test('matches syncMapFromMeasureMap byte-for-byte', () {
      final store = mapWith(count: 4);
      final linear = syncMapFromMeasureMap(store);
      final built = syncMapFromMeasureMapAndForm(store, FormMap());
      expect(built, isA<SyncMapBuildSuccess>());
      expect((built as SyncMapBuildSuccess).map, linear);
      for (final e in built.map.entries) {
        expect(e.physicalMeasure, e.measure);
      }
    });

    test('empty MeasureMap → empty SyncMap', () {
      final built =
          syncMapFromMeasureMapAndForm(MeasureMapStore(), FormMap());
      expect(built, isA<SyncMapBuildSuccess>());
      expect((built as SyncMapBuildSuccess).map.isEmpty, isTrue);
    });
  });

  group('repeat', () {
    test('times=2 plays the region twice', () {
      final store = mapWith(count: 5);
      // |: 2–4 :| then 5
      final form = FormMap(
        repeats: [
          const FormRepeatRegion(
            id: 'r1',
            startMeasure: 2,
            endMeasure: 4,
            times: 2,
          ),
        ],
      );
      final result = syncMapFromMeasureMapAndForm(store, form);
      expect(physicals(result), [1, 2, 3, 4, 2, 3, 4, 5]);
      expect(latents(result).length, 8);
      // Second visit of physical 2 is a new latent.
      final map = (result as SyncMapBuildSuccess).map;
      final visitsOf2 = map.entries.where((e) => e.physicalMeasure == 2);
      expect(visitsOf2.length, 2);
      expect(visitsOf2.first.measure, isNot(visitsOf2.last.measure));
    });
  });

  group('volta', () {
    test('pass 1 plays ending 1; pass 2 plays ending 2', () {
      final store = mapWith(count: 6);
      // |: 1–3 [1. 4 :|] [2. 5] 6 — repeat backward sits on ending 1
      final form = FormMap(
        repeats: [
          const FormRepeatRegion(
            id: 'r1',
            startMeasure: 1,
            endMeasure: 4,
            times: 2,
          ),
        ],
        endings: [
          const FormEnding(
            id: 'e1',
            startMeasure: 4,
            endMeasure: 4,
            endingNumber: 1,
          ),
          const FormEnding(
            id: 'e2',
            startMeasure: 5,
            endMeasure: 5,
            endingNumber: 2,
          ),
        ],
      );
      final result = syncMapFromMeasureMapAndForm(store, form);
      expect(physicals(result), [1, 2, 3, 4, 1, 2, 3, 5, 6]);
    });
  });

  group('D.C. al coda / Fine', () {
    test('D.C. then To Coda skips the middle; Fine stops', () {
      // Physical: 1 2 3(ToCoda) 4(D.C.) 5(Coda) 6(Fine) 7
      // Play: 1 2 3 4 → jump to 1 → 1 2 3 → To Coda → 5 6(Fine) stop
      final store = mapWith(count: 7);
      final form = FormMap(
        markers: const [
          FormMarker(id: 'c', measure: 5, kind: FormMarkerKind.coda),
          FormMarker(id: 'f', measure: 6, kind: FormMarkerKind.fine),
        ],
        jumps: const [
          FormJump(id: 'tc', measure: 3, kind: FormJumpKind.toCoda),
          FormJump(id: 'dc', measure: 4, kind: FormJumpKind.daCapo),
        ],
      );
      final result = syncMapFromMeasureMapAndForm(store, form);
      expect(physicals(result), [1, 2, 3, 4, 1, 2, 3, 5, 6]);
      // Measure 7 never played; first pass through 3 does not jump (not jumped yet).
    });

    test('D.S. jumps to Segno', () {
      final store = mapWith(count: 5);
      final form = FormMap(
        markers: const [
          FormMarker(id: 's', measure: 2, kind: FormMarkerKind.segno),
        ],
        jumps: const [
          FormJump(id: 'ds', measure: 4, kind: FormJumpKind.dalSegno),
        ],
      );
      final result = syncMapFromMeasureMapAndForm(store, form);
      expect(physicals(result), [1, 2, 3, 4, 2, 3, 4, 5]);
    });
  });

  group('invalid form', () {
    test('missing physical measure → failure', () {
      final store = mapWith(count: 2);
      final form = FormMap(
        markers: const [
          FormMarker(id: 's', measure: 9, kind: FormMarkerKind.segno),
        ],
      );
      final result = syncMapFromMeasureMapAndForm(store, form);
      expect(result, isA<SyncMapBuildFailure>());
      expect(
        (result as SyncMapBuildFailure).reason,
        'formInvalidMissingMeasure',
      );
    });

    test('loop cap → failure', () {
      final store = mapWith(count: 2);
      // After D.C., To Coda → Coda on the same measure re-enters forever.
      final form = FormMap(
        markers: const [
          FormMarker(id: 'c', measure: 2, kind: FormMarkerKind.coda),
        ],
        jumps: const [
          FormJump(id: 'dc', measure: 1, kind: FormJumpKind.daCapo),
          FormJump(id: 'tc', measure: 2, kind: FormJumpKind.toCoda),
        ],
      );
      final result = syncMapFromMeasureMapAndForm(store, form);
      expect(result, isA<SyncMapBuildFailure>());
      expect((result as SyncMapBuildFailure).reason, 'formInvalidLoop');
    });
  });

  group('playhead physical on second visit', () {
    test('same physical geometry for both visits; different timeline', () {
      final store = mapWith(count: 3);
      final form = FormMap(
        repeats: [
          const FormRepeatRegion(
            id: 'r1',
            startMeasure: 1,
            endMeasure: 2,
            times: 2,
          ),
        ],
      );
      final result = syncMapFromMeasureMapAndForm(store, form);
      final map = (result as SyncMapBuildSuccess).map;
      final first = map.entries.where((e) => e.physicalMeasure == 1).toList();
      expect(first.length, 2);
      expect(first[0].timeMs, isNot(first[1].timeMs));
      expect(first[0].physicalMeasure, first[1].physicalMeasure);
    });
  });
}
