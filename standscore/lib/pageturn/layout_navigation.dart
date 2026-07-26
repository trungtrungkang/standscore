import 'package:standscore/layout/pdf_layout_mode.dart';
import 'package:standscore/pageturn/page_turn_prefs.dart';

/// PageTurn prefs as they apply to [mode], with `Match layout` resolved
/// (Spec 0041).
///
/// Six layouts move their pages along two different axes while the tap zones
/// and swipe switches were one global set, so half of them were turned across
/// the grain — Scroll ran down the screen and was turned sideways. This is the
/// one place that mismatch is settled.
///
/// The result is for reading, never for saving: the switches it fills in are
/// the layout's answer, not the musician's, and writing them back would turn a
/// default into a choice they never made.
PageTurnPrefs resolvePageTurnPrefsForLayout(
  PageTurnPrefs prefs,
  PdfLayoutMode mode,
) {
  final horizontal = layoutAxisFor(mode) == LayoutAxis.horizontal;
  final tapMode = prefs.tapMode == PageTurnTapMode.matchLayout
      ? (horizontal ? PageTurnTapMode.leftRight : PageTurnTapMode.topBottom)
      : prefs.tapMode;
  if (prefs.swipeMode == SwipeMode.custom) {
    return prefs.copyWith(tapMode: tapMode);
  }
  return prefs.copyWith(
    tapMode: tapMode,
    swipeLeft: horizontal,
    swipeRight: horizontal,
    swipeUp: !horizontal,
    swipeDown: !horizontal,
  );
}

/// One line naming the gestures that turn a page in [mode], read off the
/// prefs that will actually be in force there (Spec 0041).
String navigationHintFor(PdfLayoutMode mode, PageTurnPrefs prefs) {
  final resolved = resolvePageTurnPrefsForLayout(prefs, mode);
  final parts = <String>[?_tapHint(resolved.tapMode), ?_swipeHint(resolved)];
  if (parts.isEmpty) return 'Pedal or the page bar';
  return parts.join(' · ');
}

String? _tapHint(PageTurnTapMode mode) => switch (mode) {
  PageTurnTapMode.leftRight => 'tap left / right',
  PageTurnTapMode.topBottom => 'tap top / bottom',
  PageTurnTapMode.next => 'tap anywhere',
  PageTurnTapMode.previous => 'tap anywhere to go back',
  PageTurnTapMode.disabled || PageTurnTapMode.matchLayout => null,
};

String? _swipeHint(PageTurnPrefs prefs) {
  final horizontal = prefs.swipeLeft || prefs.swipeRight;
  final vertical = prefs.swipeUp || prefs.swipeDown;
  if (horizontal && vertical) return 'swipe';
  if (horizontal) return 'swipe sideways';
  if (vertical) return 'swipe up / down';
  return null;
}
