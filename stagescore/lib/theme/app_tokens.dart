/// Design tokens — Spec 0044.
///
/// A token is *taste*: a step someone picked so that two sheets written months
/// apart look like the same app. A **measured** number is not a token — see
/// `kQuickBarGestureGap` (0043) or `kFabScrollClearance` below — and must never
/// be replaced by a step, even when the two happen to be equal today, because
/// retuning a scale would then silently move a measurement.
///
/// `test/design_token_guard_test.dart` keeps `lib/ui/` spending these steps
/// instead of raw numbers.
library;

/// Whitespace steps. Five, because `lib/ui/` already spends 8, 12, 16, 4 and 24
/// on almost everything, and a sixth step is how a scale starts dissolving.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  /// Ascending, no duplicates — locked by `test/app_tokens_test.dart`.
  static const List<double> steps = <double>[xs, sm, md, lg, xl];
}

/// Corner steps: `xs` clips an image inside a small tile, `sm` shapes a control
/// or a swatch, `md` shapes a card, a pill or a floating toolbar. Material's own
/// 28 on a bottom sheet is left alone — it is already right.
abstract final class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;

  /// Ascending, no duplicates — locked by `test/app_tokens_test.dart`.
  static const List<double> steps = <double>[xs, sm, md];
}

/// Room a scrollable leaves so its last row is not stuck under a floating
/// action button: 56 for the FAB plus `AppSpacing.lg` above and below.
///
/// Measured, not a step: it moves only when the FAB moves.
const double kFabScrollClearance = 56 + AppSpacing.lg * 2;
