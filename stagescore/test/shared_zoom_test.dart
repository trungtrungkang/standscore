import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/pdf/shared_zoom.dart';

/// A zoomed-in transform with a horizontal pan on top — the shape a musician
/// leaves behind after pinching in and then dragging to hide a scan's wide
/// left margin.
Matrix4 _zoomedAndPanned({double scale = 2.0, double panX = -80}) =>
    Matrix4.identity()
      ..scaleByDouble(scale, scale, scale, 1)
      ..setTranslationRaw(panX, 0, 0);

void main() {
  test(
    'kZoomSettleDelay is well past a frame gap, so it only fires once '
    'InteractiveViewer\'s inertia animation has actually stopped',
    () {
      // 120fps -> ~8.3ms between frames; the delay must clear that by a wide
      // margin or a still-animating fling would look "settled" mid-flight.
      expect(kZoomSettleDelay.inMilliseconds, greaterThan(50));
    },
  );

  group('nextSharedZoomTransform', () {
    test('is null at fit (identity)', () {
      expect(nextSharedZoomTransform(Matrix4.identity()), isNull);
    });

    test('captures scale once pinched in', () {
      final zoomed = Matrix4.identity()..scaleByDouble(2.5, 2.5, 2.5, 1);
      final next = nextSharedZoomTransform(zoomed)!;
      expect(next.getMaxScaleOnAxis(), closeTo(2.5, 0.001));
    });

    test('captures pan alongside scale, not scale alone', () {
      final value = _zoomedAndPanned();
      final next = nextSharedZoomTransform(value)!;
      expect(next.getMaxScaleOnAxis(), closeTo(2.0, 0.001));
      expect(next.getTranslation().x, closeTo(-80, 0.001));
    });

    test('is null again once pinched back out to fit, even mid-pan', () {
      // A pan with no meaningful zoom still reads as "at fit" — panning only
      // matters once there is more page than viewport to move around.
      final backToFit = Matrix4.identity()..setTranslationRaw(-80, 0, 0);
      expect(nextSharedZoomTransform(backToFit), isNull);
    });

    test('returns a copy, not the same instance', () {
      final value = _zoomedAndPanned();
      final next = nextSharedZoomTransform(value)!;
      next.setTranslationRaw(999, 999, 0);
      expect(value.getTranslation().x, closeTo(-80, 0.001));
    });
  });

  group('sharedZoomTransformChanged', () {
    test('null to null is not a change', () {
      expect(sharedZoomTransformChanged(null, null), isFalse);
    });

    test('null to a transform is a change (first zoom-in)', () {
      expect(sharedZoomTransformChanged(null, _zoomedAndPanned()), isTrue);
    });

    test('a transform to null is a change (zoomed back out)', () {
      expect(sharedZoomTransformChanged(_zoomedAndPanned(), null), isTrue);
    });

    test('ignores sub-percent float drift from InteractiveViewer', () {
      final a = _zoomedAndPanned();
      final b = _zoomedAndPanned(panX: -80.001);
      expect(sharedZoomTransformChanged(a, b), isFalse);
    });

    test('a meaningfully different scale is a change', () {
      expect(
        sharedZoomTransformChanged(
          _zoomedAndPanned(scale: 2.0),
          _zoomedAndPanned(scale: 3.0),
        ),
        isTrue,
      );
    });

    test('same scale but a meaningfully different pan is still a change', () {
      // The whole point of this follow-up: two transforms can agree on zoom
      // and disagree on where they are panned to, and that must count.
      expect(
        sharedZoomTransformChanged(
          _zoomedAndPanned(panX: -80),
          _zoomedAndPanned(panX: -10),
        ),
        isTrue,
      );
    });
  });

  group('sharedZoomMatrix', () {
    test('null transform is identity (fit)', () {
      expect(sharedZoomMatrix(null), Matrix4.identity());
    });

    test('a transform is carried through scale and pan alike', () {
      final matrix = sharedZoomMatrix(_zoomedAndPanned());
      expect(matrix.getMaxScaleOnAxis(), closeTo(2.0, 0.001));
      expect(matrix.getTranslation().x, closeTo(-80, 0.001));
    });

    test('returns a fresh copy each time — two pages must never share one '
        'mutable Matrix4', () {
      final shared = _zoomedAndPanned();
      final a = sharedZoomMatrix(shared);
      final b = sharedZoomMatrix(shared);
      a.setTranslationRaw(0, 0, 0);
      expect(b.getTranslation().x, closeTo(-80, 0.001));
    });
  });

  test(
    'a pinch-and-pan-then-turn round trip: zoom + pan on page 1, next page '
    'opens the same way, zooming back out on page 2 resets page 3',
    () {
      // Simulates what SinglePageSlider / ContinuousPageOrderView (which also
      // draws the Half Page layouts, Spec 0056) do around a pinch gesture
      // ending, without needing a real PdfDocument (pdfrx needs the native
      // viewer, unavailable under flutter test).
      Matrix4? shared;

      // Page 1: musician pinches to 2x and pans left to hide a wide margin.
      final settled = _zoomedAndPanned(scale: 2.0, panX: -80);
      final next = nextSharedZoomTransform(settled);
      expect(sharedZoomTransformChanged(shared, next), isTrue);
      shared = next;

      // Page 2, never visited before: opens already at the shared view.
      final page2Initial = sharedZoomMatrix(shared);
      expect(page2Initial.getMaxScaleOnAxis(), closeTo(2.0, 0.001));
      expect(page2Initial.getTranslation().x, closeTo(-80, 0.001));

      // Musician pinches back out to fit on page 2.
      final backToFit = nextSharedZoomTransform(Matrix4.identity());
      expect(sharedZoomTransformChanged(shared, backToFit), isTrue);
      shared = backToFit;

      // Page 3 now opens at fit, not still zoomed-and-panned.
      expect(sharedZoomMatrix(shared), Matrix4.identity());
    },
  );
}
