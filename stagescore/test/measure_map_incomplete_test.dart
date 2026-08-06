import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/measure_map/measure_map_store.dart';

void main() {
  test('gaps between pages load and jump only hits present measures', () {
    final store = MeasureMapStore();
    store.addSystem(
      pageNumber: 1,
      x: 0,
      y: 0,
      width: 1,
      height: 0.1,
      measureCount: 2,
    );
    store.addSystem(
      pageNumber: 3,
      x: 0,
      y: 0,
      width: 1,
      height: 0.1,
      measureCount: 2,
    );
    // No page 2 — incomplete map is valid.
    expect(store.boxesForPage(2), isEmpty);
    expect(store.boxes.map((b) => b.measureNumber), [1, 2, 3, 4]);
    expect(store.byMeasureNumber(3)?.pageNumber, 3);
    expect(store.byMeasureNumber(99), isNull);
  });

  test('json round-trip keeps gaps', () {
    final store = MeasureMapStore();
    store.addSystem(
      pageNumber: 1,
      x: 0,
      y: 0,
      width: 1,
      height: 0.1,
      measureCount: 1,
    );
    store.addSystem(
      pageNumber: 5,
      x: 0,
      y: 0,
      width: 1,
      height: 0.1,
      measureCount: 1,
    );
    final loaded = MeasureMapStore()..loadJson(store.toJson('s'));
    expect(loaded.boxesForPage(2), isEmpty);
    expect(loaded.boxesForPage(5).single.measureNumber, 2);
  });
}
