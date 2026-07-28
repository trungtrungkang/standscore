import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/pdf/zoom_toggle.dart';

void main() {
  test('isInteractivelyZoomed is false at identity', () {
    expect(isInteractivelyZoomed(Matrix4.identity()), isFalse);
  });

  test('isInteractivelyZoomed is true once scaled up meaningfully', () {
    final zoomed = Matrix4.identity()..scaleByDouble(2, 2, 2, 1);
    expect(isInteractivelyZoomed(zoomed), isTrue);
  });

  test('isInteractivelyZoomed ignores sub-threshold float jitter', () {
    final barely = Matrix4.identity()..scaleByDouble(1.02, 1.02, 1.02, 1);
    expect(isInteractivelyZoomed(barely), isFalse);
  });
}
