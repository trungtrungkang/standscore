import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:stagescore/measure_map/measure_box.dart';
import 'package:stagescore/measure_map/measure_map_overlay_config.dart';
import 'package:stagescore/measure_map/measure_map_painter.dart';
import 'package:stagescore/measure_map/measure_map_selection.dart';
import 'package:stagescore/measure_map/measure_map_store.dart';

/// Wins the arena immediately so PageView / scrollables cannot steal a
/// SystemBox rubber-band (L→R on page ≥ 2 looked like a page turn).
class _EagerHorizontalDragGestureRecognizer
    extends HorizontalDragGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}

class _EagerVerticalDragGestureRecognizer
    extends VerticalDragGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}

/// Per-page MeasureMap overlay — same 0–1 / pageRect path as annotations.
class PageMeasureMapOverlay extends StatefulWidget {
  const PageMeasureMapOverlay({
    super.key,
    required this.pageRect,
    required this.page,
    required this.config,
  });

  final Rect pageRect;
  final PdfPage page;
  final MeasureMapOverlayConfig config;

  @override
  State<PageMeasureMapOverlay> createState() => _PageMeasureMapOverlayState();
}

class _PageMeasureMapOverlayState extends State<PageMeasureMapOverlay> {
  Offset? _dragStart;
  Rect? _inProgress;
  _DragKind? _dragKind;
  String? _dividerLeftId;
  String? _beatMeasureId;
  int? _beatSplitIndex;
  Timer? _longPressTimer;
  String? _longPressMeasureId;
  Offset? _longPressOrigin;

  SystemEdge? _resizeEdge;
  int? _gestureSystemIndex;
  Offset? _movePointerOrigin;
  ({double x, double y, double width, double height})? _gestureOriginRect;

  /// Measure under pointer when a system-move gesture started — used to
  /// promote to measure selection on a short tap (no drag).
  String? _tapMeasureCandidate;

  /// True when a drag mutated the store — parent save waits until pointer-up.
  bool _storeDirty = false;

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  Offset _normalize(Offset local) {
    final w = widget.pageRect.width;
    final h = widget.pageRect.height;
    if (w <= 0 || h <= 0) return Offset.zero;
    return Offset(
      (local.dx / w).clamp(0.0, 1.0),
      (local.dy / h).clamp(0.0, 1.0),
    );
  }

  List<MeasureBox> get _boxes => widget.config.store.boxesForPageInExtent(
    widget.page.pageNumber,
    widget.config.extent,
  );

  MeasureMapSelectionSystem? get _selectedSystem {
    final s = widget.config.selection;
    return s is MeasureMapSelectionSystem ? s : null;
  }

  @override
  Widget build(BuildContext context) {
    final paintBoxes = widget.config.editEnabled ||
            widget.config.highlightedId != null
        ? _boxes
        : const <MeasureBox>[];

    if (!widget.config.editEnabled && widget.config.highlightedId == null) {
      return const SizedBox.expand();
    }

    final stack = CustomPaint(
      size: widget.pageRect.size,
      painter: MeasureMapPainter(
        boxes: paintBoxes,
        pageSize: widget.pageRect.size,
        store: widget.config.store,
        pageNumber: widget.page.pageNumber,
        selection: widget.config.selection,
        highlightedId: widget.config.highlightedId,
        editingBeatsId: widget.config.editingBeatsId,
        inProgressRect: _inProgress,
        editEnabled: widget.config.editEnabled,
      ),
    );

    if (!widget.config.editEnabled) {
      return IgnorePointer(child: stack);
    }

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) => _onDown(_normalize(e.localPosition)),
      onPointerMove: (e) => _onMove(_normalize(e.localPosition)),
      onPointerUp: (_) => _onUp(),
      // Match Draw ink: commit (or discard undersized) instead of dropping the
      // rubber-band when a competing scroll recognizer briefly wins.
      onPointerCancel: (_) => _onUp(),
      child: RawGestureDetector(
        behavior: HitTestBehavior.translucent,
        gestures: <Type, GestureRecognizerFactory>{
          _EagerHorizontalDragGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<
                _EagerHorizontalDragGestureRecognizer
              >(
                () => _EagerHorizontalDragGestureRecognizer(),
                (_EagerHorizontalDragGestureRecognizer instance) {
                  instance.onStart = (_) {};
                  instance.onUpdate = (_) {};
                  instance.onEnd = (_) {};
                },
              ),
          _EagerVerticalDragGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<
                _EagerVerticalDragGestureRecognizer
              >(
                () => _EagerVerticalDragGestureRecognizer(),
                (_EagerVerticalDragGestureRecognizer instance) {
                  instance.onStart = (_) {};
                  instance.onUpdate = (_) {};
                  instance.onEnd = (_) {};
                },
              ),
        },
        child: stack,
      ),
    );
  }

  void _onDown(Offset pos) {
    final boxes = _boxes;
    final w = widget.pageRect.width;
    final h = widget.pageRect.height;
    final page = widget.page.pageNumber;
    final store = widget.config.store;

    // 1. Beat split hit (only while Edit beats on that measure).
    final editBeats = widget.config.editingBeatsId;
    if (editBeats != null) {
      MeasureBox? box;
      for (final b in boxes) {
        if (b.id == editBeats) {
          box = b;
          break;
        }
      }
      if (box != null) {
        final hit = _hitBeatSplit(box, pos, w);
        if (hit != null) {
          _dragKind = _DragKind.beatSplit;
          _beatMeasureId = box.id;
          _beatSplitIndex = hit;
          return;
        }
      }
    }

    // 2. Measure divider hit.
    for (var i = 0; i < boxes.length; i++) {
      final box = boxes[i];
      final nextSameSystem = i + 1 < boxes.length &&
          boxes[i + 1].systemIndex == box.systemIndex &&
          boxes[i + 1].pageNumber == box.pageNumber;
      if (!nextSameSystem) continue;
      final edgeX = box.right;
      final px = (pos.dx - edgeX).abs() * w;
      if (px <= 12 && pos.dy >= box.y && pos.dy <= box.bottom) {
        _dragKind = _DragKind.measureDivider;
        _dividerLeftId = box.id;
        return;
      }
    }

    // 3. System edge / frame ring (topmost system first if overlapping).
    for (final sysIdx in store.systemIndicesOnPage(page).reversed) {
      final rect = store.systemRect(pageNumber: page, systemIndex: sysIdx);
      if (rect == null) continue;
      final edge = SystemBoxHit.hitEdge(
        rect: rect,
        pos: pos,
        pageWidthPx: w,
        pageHeightPx: h,
      );
      if (edge == null) continue;
      final selected = _selectedSystem;
      if (selected != null &&
          selected.matches(pageNumber: page, systemIndex: sysIdx)) {
        _dragKind = _DragKind.systemEdge;
        _resizeEdge = edge;
        _gestureSystemIndex = sysIdx;
        _gestureOriginRect = rect;
        return;
      }
      // Not selected → select system (no resize until next gesture).
      widget.config.onSelectionChanged(
        MeasureMapSelectionSystem(pageNumber: page, systemIndex: sysIdx),
      );
      return;
    }

    // 4. Selected system body → potential move (short tap may select measure).
    final selected = _selectedSystem;
    if (selected != null && selected.pageNumber == page) {
      final rect = store.systemRect(
        pageNumber: page,
        systemIndex: selected.systemIndex,
      );
      if (rect != null &&
          pos.dx >= rect.x &&
          pos.dx <= rect.x + rect.width &&
          pos.dy >= rect.y &&
          pos.dy <= rect.y + rect.height) {
        _dragKind = _DragKind.systemMove;
        _gestureSystemIndex = selected.systemIndex;
        _movePointerOrigin = pos;
        _gestureOriginRect = rect;
        _tapMeasureCandidate = null;
        for (final box in boxes.reversed) {
          if (box.systemIndex == selected.systemIndex &&
              box.containsPoint(pos.dx, pos.dy)) {
            _tapMeasureCandidate = box.id;
            break;
          }
        }
        return;
      }
    }

    // 5. Tap / long-press MeasureBox → select measure.
    for (final box in boxes.reversed) {
      if (box.containsPoint(pos.dx, pos.dy)) {
        widget.config.onSelectionChanged(MeasureMapSelectionMeasure(box.id));
        _longPressMeasureId = box.id;
        _longPressOrigin = pos;
        _longPressTimer?.cancel();
        _longPressTimer = Timer(const Duration(milliseconds: 500), () {
          final id = _longPressMeasureId;
          if (id == null) return;
          widget.config.onMeasureLongPress?.call(id);
          _clearLongPress();
        });
        return;
      }
    }

    // 6. Empty → clear + rubber-band.
    _clearLongPress();
    widget.config.onSelectionChanged(MeasureMapSelection.none);
    _dragKind = _DragKind.drawSystem;
    _dragStart = pos;
    _inProgress = Rect.fromPoints(pos, pos);
    setState(() {});
  }

  void _clearLongPress() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    _longPressMeasureId = null;
    _longPressOrigin = null;
  }

  void _onMove(Offset pos) {
    final origin = _longPressOrigin;
    if (origin != null) {
      final dx = (pos.dx - origin.dx).abs() * widget.pageRect.width;
      final dy = (pos.dy - origin.dy).abs() * widget.pageRect.height;
      if (dx > 8 || dy > 8) _clearLongPress();
    }
    final page = widget.page.pageNumber;
    final store = widget.config.store;
    switch (_dragKind) {
      case _DragKind.drawSystem:
        final start = _dragStart;
        if (start == null) return;
        setState(() => _inProgress = Rect.fromPoints(start, pos));
      case _DragKind.measureDivider:
        final id = _dividerLeftId;
        if (id == null) return;
        if (store.dragMeasureDivider(leftId: id, newRight: pos.dx)) {
          _storeDirty = true;
          setState(() {});
        }
      case _DragKind.beatSplit:
        final mid = _beatMeasureId;
        final idx = _beatSplitIndex;
        if (mid == null || idx == null) return;
        final box = store.byId(mid);
        if (box == null || box.width <= 0) return;
        final ratio = ((pos.dx - box.x) / box.width).clamp(0.0, 1.0);
        if (store.dragBeatSplit(
          measureId: mid,
          splitIndex: idx,
          newRatio: ratio,
        )) {
          _storeDirty = true;
          setState(() {});
        }
      case _DragKind.systemEdge:
        final edge = _resizeEdge;
        final sysIdx = _gestureSystemIndex;
        final originRect = _gestureOriginRect;
        if (edge == null || sysIdx == null || originRect == null) return;
        final next = _rectForEdgeDrag(originRect, edge, pos);
        // Absolute target from gesture-start rect; store.resizeSystem remaps
        // current sibling ratios into that target (ratiosios stay invariant).
        if (store.resizeSystem(
          pageNumber: page,
          systemIndex: sysIdx,
          x: next.x,
          y: next.y,
          width: next.width,
          height: next.height,
        )) {
          _storeDirty = true;
          setState(() {});
        }
      case _DragKind.systemMove:
        final sysIdx = _gestureSystemIndex;
        final start = _movePointerOrigin;
        final originRect = _gestureOriginRect;
        if (sysIdx == null || start == null || originRect == null) return;
        final dx = pos.dx - start.dx;
        final dy = pos.dy - start.dy;
        if (dx.abs() * widget.pageRect.width < 2 &&
            dy.abs() * widget.pageRect.height < 2) {
          return;
        }
        final cur = store.systemRect(pageNumber: page, systemIndex: sysIdx);
        if (cur == null) return;
        final wantX = originRect.x + dx;
        final wantY = originRect.y + dy;
        if (store.moveSystem(
          pageNumber: page,
          systemIndex: sysIdx,
          dx: wantX - cur.x,
          dy: wantY - cur.y,
        )) {
          _tapMeasureCandidate = null; // dragged → not a tap
          _storeDirty = true;
          setState(() {});
        }
      case null:
        break;
    }
  }

  ({double x, double y, double width, double height}) _rectForEdgeDrag(
    ({double x, double y, double width, double height}) origin,
    SystemEdge edge,
    Offset pos,
  ) {
    var left = origin.x;
    var top = origin.y;
    var right = origin.x + origin.width;
    var bottom = origin.y + origin.height;
    switch (edge) {
      case SystemEdge.left:
        left = pos.dx.clamp(0.0, right - MeasureMapStore.minSystemWidth);
      case SystemEdge.right:
        right = pos.dx.clamp(left + MeasureMapStore.minSystemWidth, 1.0);
      case SystemEdge.top:
        top = pos.dy.clamp(0.0, bottom - MeasureMapStore.minSystemHeight);
      case SystemEdge.bottom:
        bottom = pos.dy.clamp(top + MeasureMapStore.minSystemHeight, 1.0);
    }
    return (x: left, y: top, width: right - left, height: bottom - top);
  }

  void _onUp() {
    _clearLongPress();
    if (_dragKind == _DragKind.drawSystem) {
      final rect = _inProgress;
      _dragKind = null;
      _dragStart = null;
      _inProgress = null;
      setState(() {});
      if (rect != null &&
          rect.width > MeasureMapStore.minSystemWidth &&
          rect.height > MeasureMapStore.minSystemHeight) {
        final pageNumber = widget.page.pageNumber;
        final normalized = Rect.fromLTRB(
          rect.left,
          rect.top,
          rect.right,
          rect.bottom,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          widget.config.onSystemDrawn(pageNumber, normalized);
        });
      }
      return;
    }

    // Short tap on a measure while system was selected → select that measure.
    if (_dragKind == _DragKind.systemMove &&
        !_storeDirty &&
        _tapMeasureCandidate != null) {
      widget.config.onSelectionChanged(
        MeasureMapSelectionMeasure(_tapMeasureCandidate!),
      );
    }

    final dirty = _storeDirty;
    _resetGesture();
    if (dirty) widget.config.onChanged();
  }

  void _resetGesture() {
    _dragKind = null;
    _dividerLeftId = null;
    _beatMeasureId = null;
    _beatSplitIndex = null;
    _resizeEdge = null;
    _gestureSystemIndex = null;
    _movePointerOrigin = null;
    _gestureOriginRect = null;
    _tapMeasureCandidate = null;
    _storeDirty = false;
    _dragStart = null;
  }

  int? _hitBeatSplit(MeasureBox box, Offset pos, double pageWidth) {
    if (!box.containsPoint(pos.dx, pos.dy)) return null;
    for (var i = 0; i < box.beatSplits.length; i++) {
      final edgeX = box.x + box.beatSplits[i] * box.width;
      final px = (pos.dx - edgeX).abs() * pageWidth;
      if (px <= 10) return i;
    }
    return null;
  }
}

enum _DragKind {
  drawSystem,
  measureDivider,
  beatSplit,
  systemEdge,
  systemMove,
}
