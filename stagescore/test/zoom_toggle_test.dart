import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/pdf/zoom_toggle.dart';

void main() {
  test('toggledZoomMatrix zooms in from identity', () {
    final next = toggledZoomMatrix(Matrix4.identity());
    expect(isInteractivelyZoomed(next), isTrue);
    expect(next.getMaxScaleOnAxis(), closeTo(kDoubleTapZoomScale, 0.01));
  });

  test('toggledZoomMatrix resets when already zoomed', () {
    final zoomed = Matrix4.identity()
      ..scaleByDouble(
        kDoubleTapZoomScale,
        kDoubleTapZoomScale,
        kDoubleTapZoomScale,
        1,
      );
    final next = toggledZoomMatrix(zoomed);
    expect(isInteractivelyZoomed(next), isFalse);
  });

  test('toggleTransformationZoom mutates controller', () {
    final c = TransformationController();
    toggleTransformationZoom(c);
    expect(isInteractivelyZoomed(c.value), isTrue);
    toggleTransformationZoom(c);
    expect(isInteractivelyZoomed(c.value), isFalse);
  });
}
