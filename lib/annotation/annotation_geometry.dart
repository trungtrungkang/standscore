import 'dart:ui';

import 'package:standscore/annotation/annotation_store.dart';
import 'package:standscore/annotation/draw_tool.dart';

/// True if [point] is within [radius] of any segment of [stroke].
bool pointHitsStroke(
  Offset point,
  AnnotationStroke stroke, {
  double radius = DrawToolPresets.eraserRadius,
}) {
  final points = stroke.points;
  if (points.isEmpty) return false;
  final hitR = radius + stroke.width * 0.5;
  if (points.length == 1) {
    return (points.first - point).distance <= hitR;
  }
  for (var i = 0; i < points.length - 1; i++) {
    if (distanceToSegment(point, points[i], points[i + 1]) <= hitR) {
      return true;
    }
  }
  return false;
}

/// True if any sample on [path] hits [stroke].
bool pathHitsStroke(
  List<Offset> path,
  AnnotationStroke stroke, {
  double radius = DrawToolPresets.eraserRadius,
}) {
  for (final p in path) {
    if (pointHitsStroke(p, stroke, radius: radius)) return true;
  }
  return false;
}

double distanceToSegment(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 <= 1e-12) return (p - a).distance;
  var t = ((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / len2;
  t = t.clamp(0.0, 1.0);
  final proj = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
  return (p - proj).distance;
}
