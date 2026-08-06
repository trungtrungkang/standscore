import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/measure_map/measure_map_store.dart';

void main() {
  test('boxes outside PageExtent stay on disk but are not visible', () {
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
    store.addSystem(
      pageNumber: 10,
      x: 0,
      y: 0,
      width: 1,
      height: 0.1,
      measureCount: 1,
    );

    // Piece is pages 4–8 of the book.
    final extent = PageExtent(firstPage: 4, lastPage: 8);
    final visible = store.boxesVisibleIn(extent);
    expect(visible.map((b) => b.pageNumber), [5]);
    // Still on disk.
    expect(store.boxes.length, 3);
    expect(store.boxesForPageInExtent(1, extent), isEmpty);
    expect(store.boxesForPageInExtent(5, extent).length, 1);
    expect(store.boxesForPageInExtent(10, extent), isEmpty);

    // Widen extent again — page 1 and 10 reappear without rewriting.
    final wide = PageExtent(firstPage: 1, lastPage: 12);
    expect(store.boxesVisibleIn(wide).length, 3);
  });
}
