import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/layout/pdf_layout_mode.dart';
import 'package:stagescore/pageturn/page_turn_prefs.dart';

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
String navigationHintFor(
  AppLocalizations l10n,
  PdfLayoutMode mode,
  PageTurnPrefs prefs,
) {
  final resolved = resolvePageTurnPrefsForLayout(prefs, mode);
  final parts = <String>[
    ?_tapHint(l10n, resolved.tapMode),
    ?_swipeHint(l10n, resolved),
  ];
  if (parts.isEmpty) return l10n.layoutNavigationPedalOrPageBar;
  return parts.join(' · ');
}

String? _tapHint(AppLocalizations l10n, PageTurnTapMode mode) => switch (mode) {
  PageTurnTapMode.leftRight => l10n.layoutNavigationTapLeftRight,
  PageTurnTapMode.topBottom => l10n.layoutNavigationTapTopBottom,
  PageTurnTapMode.next => l10n.layoutNavigationTapAnywhere,
  PageTurnTapMode.previous => l10n.layoutNavigationTapAnywhereBack,
  PageTurnTapMode.disabled || PageTurnTapMode.matchLayout => null,
};

String? _swipeHint(AppLocalizations l10n, PageTurnPrefs prefs) {
  final horizontal = prefs.swipeLeft || prefs.swipeRight;
  final vertical = prefs.swipeUp || prefs.swipeDown;
  if (horizontal && vertical) return l10n.layoutNavigationSwipe;
  if (horizontal) return l10n.layoutNavigationSwipeSideways;
  if (vertical) return l10n.layoutNavigationSwipeUpDown;
  return null;
}
