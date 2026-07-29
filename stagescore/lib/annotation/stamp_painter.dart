import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stagescore/annotation/stamp.dart';

/// Paints placed stamps in page pixel space.
class StampPainter extends CustomPainter {
  StampPainter({
    required this.stamps,
    required this.pageSize,
    this.selectedId,
    this.selectionColor,
    this.previewCenters = const {},
  });

  final List<AnnotationStamp> stamps;
  final Size pageSize;
  final String? selectedId;

  /// Outline drawn around the selected Stamp. Chrome, not ink — a Stamp's own
  /// colour is `stamp.color` — so it follows the accent the musician picked
  /// (Spec 0026 / 0044). Null wherever selection cannot happen, such as export.
  final Color? selectionColor;
  final Map<String, Offset> previewCenters;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stamp in stamps) {
      final centerNorm = previewCenters[stamp.id] ?? stamp.center;
      final center = Offset(
        centerNorm.dx * size.width,
        centerNorm.dy * size.height,
      );
      final extent = stamp.size * size.width;
      _paintStamp(canvas, stamp, center, extent);
      final selectionColor = this.selectionColor;
      if (stamp.id == selectedId && selectionColor != null) {
        final preview = stamp.copyWith(center: centerNorm);
        final hit = preview.hitRect;
        final rect = Rect.fromLTRB(
          hit.left * size.width,
          hit.top * size.height,
          hit.right * size.width,
          hit.bottom * size.height,
        );
        canvas.drawRect(
          rect.inflate(3),
          Paint()
            ..color = selectionColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  void _paintStamp(
    Canvas canvas,
    AnnotationStamp stamp,
    Offset center,
    double extent,
  ) {
    final paint = Paint()
      ..color = stamp.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2, extent * 0.08)
      ..isAntiAlias = true;

    switch (stamp.kind) {
      case StampKind.box:
        canvas.drawRect(
          Rect.fromCenter(center: center, width: extent, height: extent * 0.75),
          paint,
        );
      case StampKind.circle:
        canvas.drawCircle(center, extent * 0.45, paint);
      case StampKind.arrow:
        final path = Path()
          ..moveTo(center.dx - extent * 0.55, center.dy)
          ..lineTo(center.dx + extent * 0.35, center.dy)
          ..moveTo(center.dx + extent * 0.1, center.dy - extent * 0.28)
          ..lineTo(center.dx + extent * 0.45, center.dy)
          ..lineTo(center.dx + extent * 0.1, center.dy + extent * 0.28);
        canvas.drawPath(path, paint);
      case StampKind.dynamicP:
      case StampKind.dynamicF:
      case StampKind.sharp:
      case StampKind.flat:
      case StampKind.natural:
      case StampKind.text:
        final label = stamp.kind == StampKind.text
            ? (stamp.text ?? '')
            : stamp.kind.glyph;
        if (label.isEmpty) return;
        final tp = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: stamp.color,
              fontSize: extent * (stamp.kind == StampKind.text ? 0.9 : 1.1),
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
        );
    }
  }

  @override
  bool shouldRepaint(covariant StampPainter oldDelegate) {
    return oldDelegate.stamps != stamps ||
        oldDelegate.pageSize != pageSize ||
        oldDelegate.selectedId != selectedId ||
        oldDelegate.previewCenters != previewCenters;
  }
}
