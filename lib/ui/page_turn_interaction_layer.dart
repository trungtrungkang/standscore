import 'package:flutter/material.dart';
import 'package:standscore/jumplink/jump_link.dart';
import 'package:standscore/pageturn/gesture_map.dart';
import 'package:standscore/pageturn/page_turn_delay.dart';
import 'package:standscore/pageturn/page_turn_prefs.dart';

/// Tap zones, swipe, edge gestures, and long-press (Specs 0003 / 0015 / 0016).
class PageTurnInteractionLayer extends StatefulWidget {
  const PageTurnInteractionLayer({
    super.key,
    required this.prefs,
    required this.reverseHorizontal,
    required this.onAction,
    this.onGestureAction,
    this.pageTurnEnabled = true,
    this.resolveJumpLink,
    this.onJumpLinkTap,
    this.onJumpLinkLongPress,
  });

  final PageTurnPrefs prefs;
  final bool reverseHorizontal;
  final void Function(PageTurnAction action, PageTurnInputKind kind) onAction;

  /// Non–PageTurn gesture map actions (Spec 0015).
  final ValueChanged<GestureMapAction>? onGestureAction;

  /// When false, PageTurn tap/swipe are ignored; Show menu gestures still work.
  final bool pageTurnEnabled;

  /// JumpLink hit-test before PageTurn (Spec 0016). Return null = miss.
  final JumpLink? Function(Offset local, Size viewSize)? resolveJumpLink;
  final ValueChanged<JumpLink>? onJumpLinkTap;
  final ValueChanged<JumpLink>? onJumpLinkLongPress;

  @override
  State<PageTurnInteractionLayer> createState() =>
      _PageTurnInteractionLayerState();
}

class _PageTurnInteractionLayerState extends State<PageTurnInteractionLayer> {
  Offset? _tapDown;
  Offset? _longPressPos;

  void _emitGesture(GestureMapAction action) {
    if (action == GestureMapAction.disabled) return;
    widget.onGestureAction?.call(action);
  }

  JumpLink? _linkAt(Offset pos, Size viewSize) {
    return widget.resolveJumpLink?.call(pos, viewSize);
  }

  void _handleTap(Size viewSize) {
    final pos = _tapDown;
    _tapDown = null;
    if (pos == null) return;

    final link = _linkAt(pos, viewSize);
    if (link != null) {
      widget.onJumpLinkTap?.call(link);
      return;
    }

    final band = resolveVerticalEdgeBand(
      localY: pos.dy,
      viewerHeight: viewSize.height,
    );
    if (band != null) {
      final input = gestureInputForEdge(band)!;
      final mapped = widget.prefs.gestureMap.actionFor(input);
      if (mapped != GestureMapAction.disabled) {
        _emitGesture(mapped);
        return;
      }
      // Off → fall through to PageTurn.
    }

    if (!widget.pageTurnEnabled) return;
    if (widget.prefs.tapMode == PageTurnTapMode.disabled) return;

    final action = resolveTapAction(
      localPosition: pos,
      viewSize: viewSize,
      mode: widget.prefs.tapMode,
      reverseHorizontal: widget.reverseHorizontal,
    );
    if (action != null) {
      widget.onAction(action, PageTurnInputKind.tap);
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.pageTurnEnabled) return;
    final action = resolveSwipeAction(
      velocity: details.velocity.pixelsPerSecond,
      prefs: widget.prefs,
      reverseHorizontal: widget.reverseHorizontal,
    );
    if (action != null) {
      widget.onAction(action, PageTurnInputKind.swipe);
    }
  }

  void _handleLongPress(Size viewSize) {
    final pos = _longPressPos ?? _tapDown;
    _longPressPos = null;
    if (pos != null) {
      final link = _linkAt(pos, viewSize);
      if (link != null) {
        widget.onJumpLinkLongPress?.call(link);
        return;
      }
    }
    final action = widget.prefs.gestureMap.longPress;
    _emitGesture(action);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final swipeOn =
            widget.pageTurnEnabled && widget.prefs.anySwipeEnabled;
        return Stack(
          fit: StackFit.expand,
          children: [
            if (swipeOn)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragEnd: _handleDragEnd,
                  onVerticalDragEnd: _handleDragEnd,
                ),
              ),
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (details) => _tapDown = details.localPosition,
                onTapCancel: () => _tapDown = null,
                onTap: () => _handleTap(size),
                onLongPressStart: (details) =>
                    _longPressPos = details.localPosition,
                onLongPress: () => _handleLongPress(size),
              ),
            ),
          ],
        );
      },
    );
  }
}
