import 'package:flutter/material.dart';
import 'package:standscore/annotation/annotation_store.dart';
import 'package:standscore/annotation/draw_tool.dart';

/// Draws completed + in-progress strokes in the current page overlay size.
class AnnotationPainter extends CustomPainter {
  AnnotationPainter({
    required this.strokes,
    required this.inProgress,
    required this.pageSize,
    this.inProgressTool = DrawTool.pen,
    this.inProgressColor,
    this.inProgressWidth,
  });

  final List<AnnotationStroke> strokes;
  final List<Offset>? inProgress;
  final Size pageSize;
  final DrawTool inProgressTool;
  final Color? inProgressColor;
  final double? inProgressWidth;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _paintNormalized(
        canvas,
        size,
        stroke.points,
        stroke.color,
        stroke.width,
        stroke.tool,
      );
    }
    if (inProgress != null && inProgress!.isNotEmpty) {
      final color = inProgressColor ?? DrawToolPresets.colorFor(inProgressTool);
      final width = inProgressWidth ?? DrawToolPresets.widthFor(inProgressTool);
      if (inProgress!.length == 1) {
        _paintDot(canvas, size, inProgress!.first, color, width);
      } else {
        _paintNormalized(
          canvas,
          size,
          inProgress!,
          color,
          width,
          inProgressTool,
        );
      }
    }
  }

  void _paintDot(
    Canvas canvas,
    Size size,
    Offset normalized,
    Color color,
    double widthFraction,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(
      Offset(normalized.dx * size.width, normalized.dy * size.height),
      (widthFraction * size.width) / 2,
      paint,
    );
  }

  void _paintNormalized(
    Canvas canvas,
    Size size,
    List<Offset> normalized,
    Color color,
    double widthFraction,
    DrawTool tool,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = widthFraction * size.width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true
      ..blendMode =
          tool == DrawTool.marker ? BlendMode.multiply : BlendMode.srcOver;

    final path = Path();
    path.moveTo(
      normalized.first.dx * size.width,
      normalized.first.dy * size.height,
    );
    for (var i = 1; i < normalized.length; i++) {
      path.lineTo(
        normalized[i].dx * size.width,
        normalized[i].dy * size.height,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AnnotationPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.inProgress != inProgress ||
        oldDelegate.pageSize != pageSize ||
        oldDelegate.inProgressTool != inProgressTool ||
        oldDelegate.inProgressColor != inProgressColor ||
        oldDelegate.inProgressWidth != inProgressWidth;
  }
}
