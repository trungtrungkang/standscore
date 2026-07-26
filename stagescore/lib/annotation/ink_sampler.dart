import 'dart:ui';

import 'package:stagescore/annotation/annotation_geometry.dart';
import 'package:stagescore/annotation/annotation_store.dart';
import 'package:stagescore/annotation/draw_tool.dart';

/// Sample color from the topmost ink stroke under [point] (Spec 0018 eyedropper).
Color? sampleInkColor({
  required AnnotationStore store,
  required int pageNumber,
  required Offset point,
  double radius = DrawToolPresets.eraserRadius,
}) {
  final strokes = store.strokesForPage(pageNumber);
  for (var i = strokes.length - 1; i >= 0; i--) {
    if (pointHitsStroke(point, strokes[i], radius: radius)) {
      return strokes[i].color;
    }
  }
  return null;
}
