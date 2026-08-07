import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/measure_map/measure_map_selection.dart';

void main() {
  group('SystemBoxHit', () {
    const rect = (x: 0.2, y: 0.3, width: 0.6, height: 0.1);

    test('frame ring hits near edges, not deep interior', () {
      expect(
        SystemBoxHit.hitFrameRing(
          rect: rect,
          pos: const Offset(0.2, 0.35),
          pageWidthPx: 1000,
          pageHeightPx: 1000,
        ),
        isTrue,
      );
      expect(
        SystemBoxHit.hitFrameRing(
          rect: rect,
          pos: const Offset(0.5, 0.35),
          pageWidthPx: 1000,
          pageHeightPx: 1000,
        ),
        isFalse,
      );
    });

    test('hitEdge identifies the nearest side', () {
      expect(
        SystemBoxHit.hitEdge(
          rect: rect,
          pos: const Offset(0.2, 0.35),
          pageWidthPx: 1000,
          pageHeightPx: 1000,
        ),
        SystemEdge.left,
      );
      expect(
        SystemBoxHit.hitEdge(
          rect: rect,
          pos: const Offset(0.5, 0.3),
          pageWidthPx: 1000,
          pageHeightPx: 1000,
        ),
        SystemEdge.top,
      );
    });
  });

  group('MeasureMapSelection', () {
    test('measure and system are mutually exclusive helpers', () {
      const m = MeasureMapSelectionMeasure('a');
      const s = MeasureMapSelectionSystem(pageNumber: 1, systemIndex: 0);
      expect(m.isMeasure, isTrue);
      expect(m.measureId, 'a');
      expect(m.systemKey, isNull);
      expect(s.isSystem, isTrue);
      expect(s.systemKey?.pageNumber, 1);
      expect(s.matches(pageNumber: 1, systemIndex: 0), isTrue);
      expect(MeasureMapSelection.none.isNone, isTrue);
    });
  });
}
