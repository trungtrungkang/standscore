import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/form_map/form_map.dart';
import 'package:stagescore/form_map/form_map_store.dart';

void main() {
  test('overlappingRepeats detects shared measures', () {
    final store = FormMapStore()
      ..upsertRepeat(
        const FormRepeatRegion(
          id: 'r18',
          startMeasure: 1,
          endMeasure: 8,
        ),
      );
    expect(
      store.overlappingRepeats(start: 1, end: 7).map((r) => r.id),
      ['r18'],
    );
    expect(store.overlappingRepeats(start: 9, end: 12), isEmpty);
  });

  test('replaceOverlappingRepeats drops conflict and keeps disjoint', () {
    final store = FormMapStore()
      ..upsertRepeat(
        const FormRepeatRegion(
          id: 'r18',
          startMeasure: 1,
          endMeasure: 8,
        ),
      )
      ..upsertRepeat(
        const FormRepeatRegion(
          id: 'r1012',
          startMeasure: 10,
          endMeasure: 12,
        ),
      )
      ..replaceOverlappingRepeats(
        const FormRepeatRegion(
          id: 'r17',
          startMeasure: 1,
          endMeasure: 7,
          times: 2,
        ),
      );
    expect(store.form.repeats.map((r) => r.id).toList(), ['r1012', 'r17']);
  });

  test('applyRepeatWithVoltas writes endings and scrubs old volta', () {
    final store = FormMapStore()
      ..applyRepeatWithVoltas(
        region: const FormRepeatRegion(
          id: 'r18',
          startMeasure: 1,
          endMeasure: 8,
        ),
        replaceOverlapping: false,
        pass1: (start: 8, end: 8),
        pass2: (start: 9, end: 9),
      );
    expect(store.form.endings.map((e) => e.endingNumber), [1, 2]);
    expect(store.form.endings[0].startMeasure, 8);
    expect(store.form.endings[1].startMeasure, 9);

    store.applyRepeatWithVoltas(
      region: const FormRepeatRegion(
        id: 'r17',
        startMeasure: 1,
        endMeasure: 7,
      ),
      replaceOverlapping: true,
      pass1: null,
      pass2: null,
    );
    expect(store.form.repeats.single.endMeasure, 7);
    expect(store.form.endings, isEmpty);
  });
}
