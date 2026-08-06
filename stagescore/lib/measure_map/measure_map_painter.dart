import 'package:flutter/material.dart';
import 'package:stagescore/form_map/form_overlay_badge.dart';
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
    this.selectOnly = false,
    this.formBadgesForMeasure,
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

  /// FormMap select mode — distinct palette from MeasureMap geometry edit.
  final bool selectOnly;

  final List<FormOverlayBadge> Function(int measureNumber)? formBadgesForMeasure;

  // MeasureMap geometry edit (green).
  static const _fill = Color(0x554CAF50);
  static const _border = Color(0xFF2E7D32);
  static const _selected = Color(0xFF1565C0);
  static const _highlight = Color(0xFFFF6F00);
  static const _beat = Color(0xCC2196F3);
  static const _draftFill = Color(0x442196F3);
  static const _draftStroke = Color(0xFF1565C0);
  static const _systemChrome = Color(0x662196F3);
  static const _systemSelected = Color(0xFF1565C0);

  // FormMap select (indigo) — reads apart from MeasureMap green.
  static const _formFill = Color(0x332E3A8C);
  static const _formBorder = Color(0xFF3949AB);
  static const _formSelected = Color(0xFFC62828);
  static const _formNumberBg = Color(0xEE1A237E);
  static const _formNumberFg = Color(0xFFFFFFFF);

  static const _badgeRepeat = Color(0xFF00897B);
  static const _badgeEnding = Color(0xFFEF6C00);
  static const _badgeMarker = Color(0xFF6A1B9A);
  static const _badgeJump = Color(0xFFD84315);

  @override
  void paint(Canvas canvas, Size size) {
    final w = pageSize.width;
    final h = pageSize.height;
    if (w <= 0 || h <= 0) return;

    if (editEnabled) {
      _paintSystemFrames(canvas, w, h);
    }

    // FormMap select-only uses indigo; MeasureMap geometry edit stays green.
    final formMode = selectOnly;
    final fillColor = formMode ? _formFill : _fill;
    final borderColor = formMode ? _formBorder : _border;
    final selectedColor = formMode ? _formSelected : _selected;

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor;
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
            : (isSelected ? selectedColor : borderColor)
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

      if (formMode) {
        _paintFormLabels(canvas, rect, box.measureNumber, isSelected);
      } else {
        final label = TextPainter(
          text: TextSpan(
            text: '${box.measureNumber}',
            style: TextStyle(
              color: borderColor,
              fontSize: (rect.height * 0.35).clamp(10.0, 16.0),
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: rect.width);
        label.paint(canvas, Offset(rect.left + 4, rect.top + 2));
      }
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

  void _paintFormLabels(
    Canvas canvas,
    Rect rect,
    int measureNumber,
    bool isSelected,
  ) {
    // Compact chips — must not dominate the MeasureBox (FormMap edit).
    final fontSize = (rect.height * 0.18).clamp(7.0, 10.0);
    final number = TextPainter(
      text: TextSpan(
        text: '$measureNumber',
        style: TextStyle(
          color: _formNumberFg,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const padX = 2.5;
    const padY = 1.0;
    final chipRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        rect.left + 2,
        rect.top + 2,
        number.width + padX * 2,
        number.height + padY * 2,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      chipRect,
      Paint()..color = isSelected ? _formSelected : _formNumberBg,
    );
    number.paint(
      canvas,
      Offset(chipRect.left + padX, chipRect.top + padY),
    );

    final badges = formBadgesForMeasure?.call(measureNumber) ?? const [];
    if (badges.isEmpty) return;

    var x = chipRect.right + 2;
    final y = rect.top + 2;
    final maxRight = rect.right - 2;
    final badgeSize = (fontSize * 0.95).clamp(6.5, 9.0);
    for (final badge in badges) {
      final bg = switch (badge.kind) {
        FormOverlayBadgeKind.repeat => _badgeRepeat,
        FormOverlayBadgeKind.ending => _badgeEnding,
        FormOverlayBadgeKind.marker => _badgeMarker,
        FormOverlayBadgeKind.jump => _badgeJump,
      };
      final tp = TextPainter(
        text: TextSpan(
          text: badge.label,
          style: TextStyle(
            color: Colors.white,
            fontSize: badgeSize,
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: (maxRight - x).clamp(0.0, rect.width));
      if (tp.width <= 0 || x + tp.width + padX * 2 > maxRight) break;
      final bRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          y,
          tp.width + padX * 2,
          tp.height + padY * 2,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(bRect, Paint()..color = bg);
      tp.paint(canvas, Offset(bRect.left + padX, bRect.top + padY));
      x = bRect.right + 2;
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
        oldDelegate.editEnabled != editEnabled ||
        oldDelegate.selectOnly != selectOnly ||
        oldDelegate.formBadgesForMeasure != formBadgesForMeasure;
  }
}
