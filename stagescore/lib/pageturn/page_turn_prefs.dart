import 'dart:ui';

import 'package:stagescore/pageturn/gesture_map.dart';
import 'package:stagescore/pageturn/page_turn_amount.dart';
import 'package:stagescore/pageturn/page_turn_animation.dart';
import 'package:stagescore/pageturn/page_turn_delay.dart';

/// Where a tap should send PageTurn.
///
/// [matchLayout] is a sentinel, not a zone: it means "whichever halves lie
/// along the axis this layout moves pages" and is resolved by
/// `resolvePageTurnPrefsForLayout` before any tap is read (Spec 0041).
enum PageTurnTapMode {
  matchLayout,
  previous,
  next,
  leftRight,
  topBottom,
  disabled,
}

/// Whether the swipe switches are the musician's or the layout's (Spec 0041).
enum SwipeMode { matchLayout, custom }

enum PageTurnAction { previous, next }

/// App-level PageTurn preferences (Spec 0003 + 0006–0008 + 0014–0015).
class PageTurnPrefs {
  /// [tapMode] and [swipeMode] default to Match layout, which only reaches a
  /// new install — an existing prefs file keeps the switches its owner set
  /// (Spec 0041).
  const PageTurnPrefs({
    this.tapMode = PageTurnTapMode.matchLayout,
    this.swipeMode = SwipeMode.matchLayout,
    this.swipeLeft = true,
    this.swipeRight = true,
    this.swipeUp = false,
    this.swipeDown = false,
    this.hintShown = false,
    this.delayPreset = PageTurnDelayPreset.off,
    this.delayScope = PageTurnDelayScope.all,
    this.animationPreset = PageTurnAnimationPreset.normal,
    this.reverseDirection = false,
    this.turnAmount = TurnAmount.full,
    this.gestureMap = const GestureMap(),
  });

  final PageTurnTapMode tapMode;

  /// When [SwipeMode.matchLayout], the four switches below are ignored in
  /// favour of the layout's own axis.
  final SwipeMode swipeMode;
  final bool swipeLeft;
  final bool swipeRight;
  final bool swipeUp;
  final bool swipeDown;
  final bool hintShown;
  final PageTurnDelayPreset delayPreset;
  final PageTurnDelayScope delayScope;
  final PageTurnAnimationPreset animationPreset;

  /// When true, horizontal slide/gestures flip; document next/prev unchanged (Spec 0008).
  final bool reverseDirection;

  /// Full vs half PageTurn advance (Spec 0014).
  final TurnAmount turnAmount;

  /// Long-press / edge gesture assignments (Spec 0015).
  final GestureMap gestureMap;

  Duration get delay => delayPreset.duration;

  /// Duration for Single-page slide turns (Spec 0007).
  Duration get animationDuration => animationPreset.duration;

  bool get anySwipeEnabled => swipeLeft || swipeRight || swipeUp || swipeDown;

  PageTurnPrefs copyWith({
    PageTurnTapMode? tapMode,
    SwipeMode? swipeMode,
    bool? swipeLeft,
    bool? swipeRight,
    bool? swipeUp,
    bool? swipeDown,
    bool? hintShown,
    PageTurnDelayPreset? delayPreset,
    PageTurnDelayScope? delayScope,
    PageTurnAnimationPreset? animationPreset,
    bool? reverseDirection,
    TurnAmount? turnAmount,
    GestureMap? gestureMap,
  }) {
    return PageTurnPrefs(
      tapMode: tapMode ?? this.tapMode,
      swipeMode: swipeMode ?? this.swipeMode,
      swipeLeft: swipeLeft ?? this.swipeLeft,
      swipeRight: swipeRight ?? this.swipeRight,
      swipeUp: swipeUp ?? this.swipeUp,
      swipeDown: swipeDown ?? this.swipeDown,
      hintShown: hintShown ?? this.hintShown,
      delayPreset: delayPreset ?? this.delayPreset,
      delayScope: delayScope ?? this.delayScope,
      animationPreset: animationPreset ?? this.animationPreset,
      reverseDirection: reverseDirection ?? this.reverseDirection,
      turnAmount: turnAmount ?? this.turnAmount,
      gestureMap: gestureMap ?? this.gestureMap,
    );
  }

  Map<String, dynamic> toJson() => {
    'tapMode': tapMode.name,
    'swipeMode': swipeMode.name,
    'swipeLeft': swipeLeft,
    'swipeRight': swipeRight,
    'swipeUp': swipeUp,
    'swipeDown': swipeDown,
    'hintShown': hintShown,
    'delayMs': delayPreset.duration.inMilliseconds,
    'delayScope': delayScope.name,
    'animation': animationPreset.name,
    'reverseDirection': reverseDirection,
    'turnAmount': turnAmount.name,
    'gestureMap': gestureMap.toJson(),
  };

  factory PageTurnPrefs.fromJson(Map<String, dynamic> json) {
    return PageTurnPrefs(
      tapMode: PageTurnTapMode.values.firstWhere(
        (m) => m.name == json['tapMode'],
        orElse: () => PageTurnTapMode.leftRight,
      ),
      // Absent means the file predates 0041, so its switches are explicit:
      // Match layout is offered to those installs, never imposed on them.
      swipeMode: SwipeMode.values.firstWhere(
        (m) => m.name == json['swipeMode'],
        orElse: () => SwipeMode.custom,
      ),
      swipeLeft: json['swipeLeft'] as bool? ?? true,
      swipeRight: json['swipeRight'] as bool? ?? true,
      swipeUp: json['swipeUp'] as bool? ?? false,
      swipeDown: json['swipeDown'] as bool? ?? false,
      hintShown: json['hintShown'] as bool? ?? false,
      delayPreset: PageTurnDelayPreset.fromMilliseconds(
        json['delayMs'] as int?,
      ),
      delayScope: PageTurnDelayScope.values.firstWhere(
        (s) => s.name == json['delayScope'],
        orElse: () => PageTurnDelayScope.all,
      ),
      animationPreset: PageTurnAnimationPreset.fromName(
        json['animation'] as String?,
      ),
      reverseDirection: json['reverseDirection'] as bool? ?? false,
      turnAmount: TurnAmount.fromName(json['turnAmount'] as String?),
      gestureMap: GestureMap.fromJson(
        json['gestureMap'] as Map<String, dynamic>?,
      ),
    );
  }
}

/// Resolve tap in viewer coordinates (origin top-left of the viewer).
PageTurnAction? resolveTapAction({
  required Offset localPosition,
  required Size viewSize,
  required PageTurnTapMode mode,
  bool reverseHorizontal = false,
}) {
  if (viewSize.width <= 0 || viewSize.height <= 0) return null;
  switch (mode) {
    case PageTurnTapMode.matchLayout:
      // Resolved against the layout before it gets here; a tap arriving with
      // the sentinel still on means a caller skipped that step.
      assert(false, 'resolvePageTurnPrefsForLayout was not applied');
      return null;
    case PageTurnTapMode.disabled:
      return null;
    case PageTurnTapMode.previous:
      return PageTurnAction.previous;
    case PageTurnTapMode.next:
      return PageTurnAction.next;
    case PageTurnTapMode.leftRight:
      final onLeft = localPosition.dx < viewSize.width / 2;
      if (reverseHorizontal) {
        return onLeft ? PageTurnAction.next : PageTurnAction.previous;
      }
      return onLeft ? PageTurnAction.previous : PageTurnAction.next;
    case PageTurnTapMode.topBottom:
      return localPosition.dy < viewSize.height / 2
          ? PageTurnAction.previous
          : PageTurnAction.next;
  }
}

/// Resolve a completed drag (viewer coords) into a PageTurn action.
PageTurnAction? resolveSwipeAction({
  required Offset velocity,
  required PageTurnPrefs prefs,
  double minSpeed = 200,
  bool reverseHorizontal = false,
}) {
  final dx = velocity.dx;
  final dy = velocity.dy;
  if (dx.abs() >= dy.abs()) {
    if (dx.abs() < minSpeed) return null;
    PageTurnAction? action;
    if (dx < 0 && prefs.swipeLeft) action = PageTurnAction.next;
    if (dx > 0 && prefs.swipeRight) action = PageTurnAction.previous;
    if (action == null) return null;
    if (reverseHorizontal) {
      return action == PageTurnAction.next
          ? PageTurnAction.previous
          : PageTurnAction.next;
    }
    return action;
  }
  if (dy.abs() < minSpeed) return null;
  if (dy < 0 && prefs.swipeUp) return PageTurnAction.next;
  if (dy > 0 && prefs.swipeDown) return PageTurnAction.previous;
  return null;
}
