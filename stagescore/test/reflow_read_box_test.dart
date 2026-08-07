import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/measure_map/measure_map_store.dart';
import 'package:stagescore/reflow/read_box.dart';

/// Three systems on page `1`, each `0.1` tall with a `0.1` gap between them.
MeasureMapStore _threeSystems() {
  final store = MeasureMapStore();
  store.addSystem(
    pageNumber: 1,
    x: 0.1,
    y: 0.1,
    width: 0.8,
    height: 0.1,
    measureCount: 2,
  );
  store.addSystem(
    pageNumber: 1,
    x: 0.1,
    y: 0.3,
    width: 0.8,
    height: 0.1,
    measureCount: 2,
  );
  store.addSystem(
    pageNumber: 1,
    x: 0.1,
    y: 0.5,
    width: 0.8,
    height: 0.1,
    measureCount: 2,
  );
  return store;
}

void main() {
  test('contextFraction 0 leaves the ReadBox equal to the SystemBox', () {
    final boxes = readBoxesForPage(_threeSystems(), 1, contextFraction: 0);

    expect(boxes, hasLength(3));
    for (final box in boxes) {
      expect(box.y, closeTo(box.systemY, 1e-9));
      expect(box.height, closeTo(box.systemHeight, 1e-9));
    }
  });

  test('contextFraction 1 makes neighbours touch without overlapping', () {
    final boxes = readBoxesForPage(_threeSystems(), 1, contextFraction: 1);

    for (var i = 1; i < boxes.length; i++) {
      expect(boxes[i - 1].bottom, closeTo(boxes[i].y, 1e-9));
    }
    // Half of the 0.1 gap on each side of the middle system.
    expect(boxes[1].y, closeTo(0.25, 1e-9));
    expect(boxes[1].bottom, closeTo(0.45, 1e-9));
  });

  test('the SystemBox is still reported, so the playhead can stay on it', () {
    final boxes = readBoxesForPage(_threeSystems(), 1, contextFraction: 1);

    expect(boxes[1].systemY, closeTo(0.3, 1e-9));
    expect(boxes[1].systemHeight, closeTo(0.1, 1e-9));
    expect(boxes[1].height, greaterThan(boxes[1].systemHeight));
  });

  test('reading order follows y, not the order systems were drawn', () {
    final store = MeasureMapStore();
    // Drawn bottom first, then the one above it — a musician who missed a line
    // and came back for it.
    store.addSystem(
      pageNumber: 1,
      x: 0.1,
      y: 0.5,
      width: 0.8,
      height: 0.1,
      measureCount: 1,
    );
    store.addSystem(
      pageNumber: 1,
      x: 0.1,
      y: 0.2,
      width: 0.8,
      height: 0.1,
      measureCount: 1,
    );

    final boxes = readBoxesForPage(store, 1);

    expect(boxes.map((b) => b.systemY), [closeTo(0.2, 1e-9), closeTo(0.5, 1e-9)]);
    expect(boxes.map((b) => b.systemIndex), [1, 0]);
  });

  test('a narrow system inherits the widest left edge on its page', () {
    final store = MeasureMapStore();
    // Drawn from the clef.
    store.addSystem(
      pageNumber: 1,
      x: 0.05,
      y: 0.1,
      width: 0.9,
      height: 0.1,
      measureCount: 2,
    );
    // Drawn from the first barline, losing the clef and key signature.
    store.addSystem(
      pageNumber: 1,
      x: 0.2,
      y: 0.3,
      width: 0.6,
      height: 0.1,
      measureCount: 2,
    );

    final boxes = readBoxesForPage(store, 1);

    for (final box in boxes) {
      expect(box.x, closeTo(0.05, 1e-9));
      expect(box.right, closeTo(0.95, 1e-9));
    }
  });

  test('a ReadBox never leaves the page', () {
    final store = MeasureMapStore();
    store.addSystem(
      pageNumber: 1,
      x: 0.1,
      y: 0.0,
      width: 0.8,
      height: 0.1,
      measureCount: 1,
    );
    store.addSystem(
      pageNumber: 1,
      x: 0.1,
      y: 0.9,
      width: 0.8,
      height: 0.1,
      measureCount: 1,
    );

    final boxes = readBoxesForPage(store, 1);

    expect(boxes.first.y, 0.0);
    expect(boxes.last.bottom, closeTo(1.0, 1e-9));
  });

  test('overlapping hand-drawn systems never borrow each other s staff', () {
    final store = MeasureMapStore();
    store.addSystem(
      pageNumber: 1,
      x: 0.1,
      y: 0.10,
      width: 0.8,
      height: 0.10,
      measureCount: 1,
    );
    // Starts above where the previous one ends.
    store.addSystem(
      pageNumber: 1,
      x: 0.1,
      y: 0.18,
      width: 0.8,
      height: 0.10,
      measureCount: 1,
    );

    final boxes = readBoxesForPage(store, 1, contextFraction: 1);

    expect(boxes.first.bottom, closeTo(boxes.first.systemY + 0.10, 1e-9));
    expect(boxes.last.y, closeTo(0.18, 1e-9));
  });

  test('a lone system on a page falls back to half its own height', () {
    final store = MeasureMapStore();
    store.addSystem(
      pageNumber: 2,
      x: 0.1,
      y: 0.4,
      width: 0.8,
      height: 0.2,
      measureCount: 1,
    );

    final boxes = readBoxesForPage(store, 2, contextFraction: 1);

    expect(boxes, hasLength(1));
    expect(boxes.single.y, closeTo(0.35, 1e-9));
    expect(boxes.single.bottom, closeTo(0.65, 1e-9));
  });

  test('a page with no SystemBox answers with an empty list', () {
    expect(readBoxesForPage(_threeSystems(), 7), isEmpty);
    expect(readBoxesForPage(MeasureMapStore(), 1), isEmpty);
  });

  test('magnification is the reciprocal of the crop width', () {
    final boxes = readBoxesForPage(_threeSystems(), 1);

    expect(boxes.first.width, closeTo(0.8, 1e-9));
    expect(boxes.first.magnification, closeTo(1.25, 1e-9));
  });

  test('readBoxesForScore walks pages in order, then down each page', () {
    final store = _threeSystems();
    store.addSystem(
      pageNumber: 2,
      x: 0.1,
      y: 0.2,
      width: 0.8,
      height: 0.1,
      measureCount: 1,
    );

    final boxes = readBoxesForScore(store);

    expect(boxes.map((b) => b.pageNumber), [1, 1, 1, 2]);
    expect(boxes.last.systemY, closeTo(0.2, 1e-9));
  });

  test('contextFraction is clamped, so no caller can force an overlap', () {
    final wide = readBoxesForPage(_threeSystems(), 1, contextFraction: 5);
    final full = readBoxesForPage(_threeSystems(), 1, contextFraction: 1);

    for (var i = 0; i < wide.length; i++) {
      expect(wide[i].y, closeTo(full[i].y, 1e-9));
      expect(wide[i].bottom, closeTo(full[i].bottom, 1e-9));
    }
  });
}
