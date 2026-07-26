import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:standscore/annotation/annotation_painter.dart';
import 'package:standscore/annotation/annotation_store.dart';
import 'package:standscore/annotation/draw_style.dart';
import 'package:standscore/annotation/draw_tool.dart';
import 'package:standscore/annotation/ink_sampler.dart';
import 'package:standscore/annotation/stamp.dart';
import 'package:standscore/annotation/stamp_painter.dart';

/// Per-page overlay: ink + stamps in normalized page coords.
class PageAnnotationOverlay extends StatefulWidget {
  const PageAnnotationOverlay({
    super.key,
    required this.pageRect,
    required this.page,
    required this.store,
    required this.drawEnabled,
    required this.onChanged,
    this.tool = DrawTool.pen,
    this.style = const DrawStylePrefs(),
    this.onStyleChanged,
    this.onEyedropperDone,
    this.pendingStamp,
    this.pendingStampText,
    this.onPendingStampConsumed,
    this.selectedStampId,
    this.onSelectedStampChanged,
    this.annotationsVisible = true,
  });

  final Rect pageRect;
  final PdfPage page;
  final AnnotationStore store;
  final bool drawEnabled;
  final VoidCallback onChanged;
  final DrawTool tool;
  final DrawStylePrefs style;
  final ValueChanged<Color>? onStyleChanged;
  final VoidCallback? onEyedropperDone;
  final StampKind? pendingStamp;
  final String? pendingStampText;
  final VoidCallback? onPendingStampConsumed;
  final String? selectedStampId;
  final ValueChanged<String?>? onSelectedStampChanged;

  /// When false, ink/stamps are not painted (Spec 0020 hide).
  final bool annotationsVisible;

  @override
  State<PageAnnotationOverlay> createState() => _PageAnnotationOverlayState();
}

class _PageAnnotationOverlayState extends State<PageAnnotationOverlay> {
  List<Offset>? _inProgress;
  String? _draggingStampId;
  Offset? _dragOrigin;
  Offset? _dragCurrent;
  var _didDragStamp = false;

  Offset _normalize(Offset local) {
    final w = widget.pageRect.width;
    final h = widget.pageRect.height;
    if (w <= 0 || h <= 0) return Offset.zero;
    return Offset(
      (local.dx / w).clamp(0.0, 1.0),
      (local.dy / h).clamp(0.0, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.annotationsVisible) {
      return const SizedBox.expand();
    }

    final page = widget.page.pageNumber;
    final strokes = widget.store.strokesForPage(page);
    final stamps = widget.store.stampsForPage(page);
    final inkTool =
        widget.tool == DrawTool.marker ? DrawTool.marker : DrawTool.pen;

    final preview = <String, Offset>{
      if (_draggingStampId != null && _dragCurrent != null)
        _draggingStampId!: _dragCurrent!,
    };

    final stack = Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          size: widget.pageRect.size,
          painter: AnnotationPainter(
            strokes: strokes,
            inProgress: _inProgress,
            pageSize: widget.pageRect.size,
            inProgressTool: inkTool,
            inProgressColor: widget.style.colorFor(inkTool),
            inProgressWidth: widget.style.widthFor(inkTool),
          ),
        ),
        CustomPaint(
          size: widget.pageRect.size,
          painter: StampPainter(
            stamps: stamps,
            pageSize: widget.pageRect.size,
            selectedId: widget.selectedStampId,
            previewCenters: preview,
          ),
        ),
      ],
    );

    if (!widget.drawEnabled) {
      return IgnorePointer(child: stack);
    }

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) => _onDown(_normalize(event.localPosition)),
      onPointerMove: (event) => _onMove(_normalize(event.localPosition)),
      onPointerUp: (_) => _onUp(),
      onPointerCancel: (_) => _onUp(),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (_) {},
        onPanUpdate: (_) {},
        onPanEnd: (_) {},
        child: stack,
      ),
    );
  }

  void _onDown(Offset pos) {
    final page = widget.page.pageNumber;

    // Place pending stamp.
    final pending = widget.pendingStamp;
    if (pending != null) {
      final size = (widget.style.penWidth * 12).clamp(0.04, 0.14);
      final stamp = widget.store.createStamp(
        pageNumber: page,
        kind: pending,
        center: pos,
        color: widget.style.penColor,
        size: size,
        text: pending == StampKind.text ? widget.pendingStampText : null,
      );
      widget.store.addStamp(stamp);
      widget.onPendingStampConsumed?.call();
      widget.onSelectedStampChanged?.call(stamp.id);
      widget.onChanged();
      return;
    }

    // Hit-test existing stamp (select / start drag).
    final hit = widget.store.hitTestStamp(page, pos);
    if (hit != null) {
      _draggingStampId = hit.id;
      _dragOrigin = hit.center;
      _dragCurrent = hit.center;
      _didDragStamp = false;
      widget.onSelectedStampChanged?.call(hit.id);
      setState(() {});
      return;
    }

    widget.onSelectedStampChanged?.call(null);

    if (widget.tool == DrawTool.eyedropper) {
      _sample(pos);
      return;
    }

    setState(() => _inProgress = [pos, pos]);
  }

  void _onMove(Offset pos) {
    if (_draggingStampId != null && _dragOrigin != null) {
      _didDragStamp = true;
      setState(() => _dragCurrent = pos);
      return;
    }
    if (widget.tool == DrawTool.eyedropper) return;
    if (widget.pendingStamp != null) return;
    final points = _inProgress;
    if (points == null) return;
    setState(() => _inProgress = [...points, pos]);
  }

  void _onUp() {
    if (_draggingStampId != null) {
      final id = _draggingStampId!;
      final current = _dragCurrent;
      _draggingStampId = null;
      _dragOrigin = null;
      _dragCurrent = null;
      if (_didDragStamp && current != null) {
        widget.store.moveStamp(id, current);
        widget.onChanged();
      }
      _didDragStamp = false;
      setState(() {});
      return;
    }

    if (widget.tool == DrawTool.eyedropper) return;
    if (widget.pendingStamp != null) return;
    _commitInk();
  }

  void _sample(Offset point) {
    final color = sampleInkColor(
      store: widget.store,
      pageNumber: widget.page.pageNumber,
      point: point,
    );
    if (color != null) {
      widget.onStyleChanged?.call(color);
    }
    widget.onEyedropperDone?.call();
  }

  void _commitInk() {
    final points = _inProgress;
    _inProgress = null;
    if (points == null || points.length < 2) {
      setState(() {});
      return;
    }

    if (widget.tool == DrawTool.eraser) {
      final removed = widget.store.eraseAlong(
        pageNumber: widget.page.pageNumber,
        path: points,
      );
      if (removed > 0) widget.onChanged();
      setState(() {});
      return;
    }

    if (!DrawToolPresets.isInkTool(widget.tool)) {
      setState(() {});
      return;
    }

    final strokePoints = pointsForStroke(
      raw: points,
      straightLine: widget.style.straightLine,
    );

    widget.store.addStroke(
      widget.store.createStroke(
        pageNumber: widget.page.pageNumber,
        points: strokePoints,
        tool: widget.tool,
        color: widget.style.colorFor(widget.tool),
        width: widget.style.widthFor(widget.tool),
      ),
    );
    widget.onChanged();
    setState(() {});
  }
}
