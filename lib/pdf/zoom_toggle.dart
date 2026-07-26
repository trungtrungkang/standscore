import 'package:flutter/material.dart';

/// Double-tap zoom factor for Spec 0033 / P0.7.
const double kDoubleTapZoomScale = 2.0;

/// True when the interactive transform is meaningfully zoomed in.
bool isInteractivelyZoomed(Matrix4 matrix) => matrix.getMaxScaleOnAxis() > 1.05;

/// Toggle between identity (fit) and [kDoubleTapZoomScale].
Matrix4 toggledZoomMatrix(Matrix4 current) {
  if (isInteractivelyZoomed(current)) {
    return Matrix4.identity();
  }
  return Matrix4.identity()..scaleByDouble(
    kDoubleTapZoomScale,
    kDoubleTapZoomScale,
    kDoubleTapZoomScale,
    1,
  );
}

/// Applies [toggledZoomMatrix] to a [TransformationController].
void toggleTransformationZoom(TransformationController controller) {
  controller.value = toggledZoomMatrix(controller.value);
}
