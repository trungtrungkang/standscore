import 'package:flutter/material.dart';
import 'package:stagescore/ui/page_nav_bar.dart';

/// Height of the shortcut row's tap targets, above [kQuickBarGestureGap] and
/// any home-indicator inset.
const double kQuickBarHeight = kMinInteractiveDimension;

/// Dead space kept below the shortcut row, on top of any home-indicator
/// inset — same idea as [kPageNavBarGestureGap].
///
/// Spec 0034 learned this for a horizontal drag; here it is a tap, but the
/// reason still applies: controls sitting flush on the safe-area boundary read
/// as part of the OS's own gesture pill rather than the app's, on phones whose
/// `MediaQuery.padding` is thinner than the strip a thumb actually avoids.
const double kQuickBarGestureGap = 12;

/// Smallest a shortcut slot may be: the minimum tap target.
const double kQuickBarMinSlotWidth = kMinInteractiveDimension;

/// Largest a shortcut slot may grow to.
///
/// Without a ceiling the row spreads its shortcuts over whatever width it is
/// given, which on a 13" tablet in landscape put them 283 pt apart — a group
/// of related controls scattered across the whole screen, so reaching the last
/// one is a journey. Capped, the group keeps the same shape on every screen
/// and only its position changes.
const double kQuickBarMaxSlotWidth = 96;

/// Padding either side of a shortcut's label inside its slot.
const double kQuickBarLabelPadding = 4;

/// Gap between a shortcut's icon and its label.
const double kQuickBarLabelGap = 2;

/// Ceiling on the share of the screen's height the bottom chrome may spend
/// when the PageNavBar and the shortcut row are stacked.
///
/// Measured before this existed: stacked, they took 54% of the height of a
/// phone in landscape once the AppBar was counted, leaving the Score 180 pt of
/// 393. A quarter is the line where the Score keeps three quarters of what it
/// is drawn on.
const double kMaxStackedChromeFraction = 0.25;

/// Width the PageNavBar's own controls need beside the scrubber: two chevrons
/// and the page-number button.
///
/// An estimate only because the merge decision has to be made before the row
/// is laid out, and a deliberately generous one — 283 pt measured with a
/// four-digit page count in a test font that draws every character a full em
/// wide, which no real typeface does. A widget test holds it to that
/// measurement, so a new control on the bar cannot leave it stale.
const double kPageNavBarControlsWidth = 288;

/// Narrowest scrubber still worth dragging.
///
/// A 56-page Score over 160 pt gives each page under 3 pt of travel, which is
/// already at the edge of aimable; below it the scrubber stops being a way to
/// reach a page and the jump-to-page dialog is the only honest route.
const double kMinScrubberWidth = 160;

/// How the bottom chrome's shortcut row fits the screen it is drawn on
/// (Spec 0043 revision 3).
///
/// The same move [LayoutFit] makes for the Score itself: which shape is right
/// is arithmetic about this viewport, not a taste a Spec can settle once for
/// every device. A phone on its side and a 13" tablet disagree about both
/// questions here — a second row of chrome is affordable on one and ruinous on
/// the other, and a row that spreads to fill its width is fine on one and
/// scattered on the other — so both are answered by measuring rather than by
/// picking a breakpoint.
///
/// Nothing here is stored: the answers change when the device is rotated, and
/// a remembered answer would be a lie one rotation later.
@immutable
class QuickBarFit {
  const QuickBarFit({
    required this.screenSize,
    required this.slotCount,
    this.bottomInset = 0,
  });

  /// The whole screen, not the viewer: the question is what share of the
  /// device the chrome is allowed to spend.
  final Size screenSize;

  /// How many shortcuts the row carries — [ScoreMenuQuickBar.slotCount], so
  /// adding a shortcut later moves these answers on its own.
  final int slotCount;

  /// Home-indicator inset the bottom-most chrome has to reserve, or 0 when the
  /// musician turned "Avoid notches and bars" off (Spec 0032).
  final double bottomInset;

  /// What the PageNavBar and the shortcut row cost stacked one above the
  /// other, insets and gesture gap included.
  double get stackedHeight =>
      kPageNavBarHeight + kQuickBarHeight + kQuickBarGestureGap + bottomInset;

  /// That cost as a share of the screen.
  double get stackedHeightFraction =>
      screenSize.height <= 0 ? 1 : stackedHeight / screenSize.height;

  /// What the scrubber would be left with if the shortcuts moved into its row.
  double get mergedScrubberWidth =>
      screenSize.width -
      kPageNavBarControlsWidth -
      slotCount * kQuickBarMinSlotWidth;

  /// Whether the shortcuts should ride inside the PageNavBar's own row.
  ///
  /// Two conditions, and both are about the same trade: a short screen cannot
  /// afford a second row of chrome, but a narrow one cannot afford to give the
  /// scrubber's width away either. A phone in landscape satisfies both — it
  /// leaves the scrubber 508 pt — while a phone in portrait fails the second,
  /// so it keeps two rows even though they cost it a third of its height.
  bool get mergeIntoPageNav =>
      stackedHeightFraction > kMaxStackedChromeFraction &&
      mergedScrubberWidth >= kMinScrubberWidth;

  /// Width of one shortcut slot on a row of its own.
  double get slotWidth {
    if (slotCount <= 0) return 0;
    final even = screenSize.width / slotCount;
    return even.clamp(kQuickBarMinSlotWidth, kQuickBarMaxSlotWidth).toDouble();
  }

  /// Width of the whole group of shortcuts, which is centred rather than
  /// stretched — see [kQuickBarMaxSlotWidth].
  double get contentWidth => slotWidth * slotCount;
}

/// Whether every one of [labels] fits under its icon on a [slotWidth] slot.
///
/// This is how Spec 0043 stops arguing about labels. Revision 1 removed a
/// labelled tab-strip because a translated word can outgrow a fixed row, and
/// revision 2 answered with icons only, which leaves a musician nothing to
/// read and a tooltip they can only find by long-pressing. Neither is a rule:
/// measure the words that are actually about to be drawn, at the text scale
/// the musician actually chose, and a label that does not fit simply is not
/// drawn. A longer translation, or accessibility text at 200%, then falls back
/// to icons on its own instead of overflowing.
bool quickBarLabelsFit({
  required Iterable<String> labels,
  required TextStyle style,
  required TextScaler textScaler,
  required double slotWidth,
  double iconSize = 24,
}) {
  final room = slotWidth - kQuickBarLabelPadding * 2;
  if (room <= 0) return false;
  for (final label in labels) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    if (painter.width > room) return false;
    // A label may not push the icon out of its own tap target either.
    if (iconSize + kQuickBarLabelGap + painter.height > kQuickBarHeight) {
      return false;
    }
  }
  return true;
}
