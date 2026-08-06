import 'package:flutter/material.dart';
import 'package:stagescore/measure_map/measure_box.dart';
import 'package:stagescore/measure_map/measure_map_selection.dart';
import 'package:stagescore/measure_map/measure_map_store.dart';

/// Paints MeasureBoxes (and optional BeatBox splits) in normalized page space.
class MeasureMapPainter extends CustomPainter {
  MeasureMapPainter({
    required this.boxes,
    required this.pageSize,
    required this.store,
    required this.pageNumber,
    this.selection = MeasureMapSelection.none,
    this.highlightedId,
    this.editingBeatsId,
    this.inProgressRect,
    this.editEnabled = false,
  });

  final List<MeasureBox> boxes;
  final Size pageSize;
  final MeasureMapStore store;
  final int pageNumber;
  final MeasureMapSelection selection;
  final String? highlightedId;
  final String? editingBeatsId;
  final Rect? inProgressRect;
  final bool editEnabled;

  static const _fill = Color(0x554CAF50);
  static const _border = Color(0xFF2E7D32);
  static const _selected = Color(0xFF1565C0);
  static const _highlight = Color(0xFFFF6F00);
  static const _beat = Color(0xCC2196F3);
  static const _draftFill = Color(0x442196F3);
  static const _draftStroke = Color(0xFF1565C0);
  static const _systemChrome = Color(0x662196F3);
  static const _systemSelected = Color(0xFF1565C0);

  @override
  void paint(Canvas canvas, Size size) {
    final w = pageSize.width;
    final h = pageSize.height;
    if (w <= 0 || h <= 0) return;

    if (editEnabled) {
      _paintSystemFrames(canvas, w, h);
    }

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = _fill;
    final stroke = Paint()..style = PaintingStyle.stroke;
    final selectedMeasureId = selection.measureId;

    for (final box in boxes) {
      final rect = Rect.fromLTWH(
        box.x * w,
        box.y * h,
        box.width * w,
        box.height * h,
      );
      canvas.drawRect(rect, fill);

      final isSelected = box.id == selectedMeasureId;
      final isHighlighted = box.id == highlightedId;
      stroke
        ..color = isHighlighted
            ? _highlight
            : (isSelected ? _selected : _border)
        ..strokeWidth = isSelected || isHighlighted ? 2.5 : 1.5;
      canvas.drawRect(rect, stroke);

      if (box.id == editingBeatsId) {
        final beatPaint = Paint()
          ..color = _beat
          ..strokeWidth = 1.5;
        for (final split in box.beatSplits) {
          final x = rect.left + split * rect.width;
          canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), beatPaint);
        }
      }

      final label = TextPainter(
        text: TextSpan(
          text: '${box.measureNumber}',
          style: TextStyle(
            color: _border,
            fontSize: (rect.height * 0.35).clamp(10.0, 16.0),
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: rect.width);
      label.paint(canvas, Offset(rect.left + 4, rect.top + 2));
    }

    final draft = inProgressRect;
    if (draft != null) {
      final r = Rect.fromLTRB(
        draft.left * w,
        draft.top * h,
        draft.right * w,
        draft.bottom * h,
      );
      canvas.drawRect(
        r,
        Paint()
          ..color = _draftFill
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(
        r,
        Paint()
          ..color = _draftStroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _paintSystemFrames(Canvas canvas, double w, double h) {
    final indices = store.systemIndicesOnPage(pageNumber);
    final selected = selection;
    for (final sysIdx in indices) {
      final rect = store.systemRect(
        pageNumber: pageNumber,
        systemIndex: sysIdx,
      );
      if (rect == null) continue;
      final isSelected = selected is MeasureMapSelectionSystem &&
          selected.matches(pageNumber: pageNumber, systemIndex: sysIdx);
      final r = Rect.fromLTWH(
        rect.x * w,
        rect.y * h,
        rect.width * w,
        rect.height * h,
      );
      canvas.drawRect(
        r,
        Paint()
          ..color = isSelected ? _systemSelected : _systemChrome
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 3 : 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MeasureMapPainter oldDelegate) {
    return oldDelegate.boxes != boxes ||
        oldDelegate.pageSize != pageSize ||
        oldDelegate.store != store ||
        oldDelegate.pageNumber != pageNumber ||
        oldDelegate.selection != selection ||
        oldDelegate.highlightedId != highlightedId ||
        oldDelegate.editingBeatsId != editingBeatsId ||
        oldDelegate.inProgressRect != inProgressRect ||
        oldDelegate.editEnabled != editEnabled;
  }
}
