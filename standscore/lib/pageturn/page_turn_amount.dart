import 'package:standscore/layout/half_page.dart';
import 'package:standscore/layout/pdf_layout_mode.dart';

/// How far one PageTurn advances (Spec 0014 / P1.12).
enum TurnAmount {
  /// One full page (or spread step in two-page Full).
  full,

  /// Half step: ~½ viewport in continuous scroll; one page in two-page.
  half;

  static TurnAmount fromName(String? name) {
    return TurnAmount.values.firstWhere(
      (v) => v.name == name,
      orElse: () => TurnAmount.full,
    );
  }
}

/// Kind of motion produced by a PageTurn.
enum PageTurnStepKind {
  /// Change performance page index by [pageDelta].
  performancePages,

  /// Scroll continuous viewer by [viewportFraction] of the viewport.
  viewportFraction,
}

class PageTurnStep {
  const PageTurnStep._({
    required this.kind,
    this.pageDelta = 1,
    this.viewportFraction = 0.5,
  });

  factory PageTurnStep.pages(int pageDelta) => PageTurnStep._(
    kind: PageTurnStepKind.performancePages,
    pageDelta: pageDelta < 1 ? 1 : pageDelta,
  );

  factory PageTurnStep.viewport(double fraction) => PageTurnStep._(
    kind: PageTurnStepKind.viewportFraction,
    viewportFraction: fraction,
  );

  final PageTurnStepKind kind;
  final int pageDelta;
  final double viewportFraction;
}

/// Resolve PageTurn step from layout + turn amount (Spec 0014).
PageTurnStep resolvePageTurnStep({
  required PdfLayoutMode mode,
  required TurnAmount amount,
}) {
  if (mode == PdfLayoutMode.single || isHalfPageLayoutMode(mode)) {
    return PageTurnStep.pages(1);
  }
  if (mode == PdfLayoutMode.twoPage) {
    return PageTurnStep.pages(amount == TurnAmount.half ? 1 : 2);
  }
  // fitWidth / fitHeight continuous
  if (amount == TurnAmount.half) {
    return PageTurnStep.viewport(0.5);
  }
  return PageTurnStep.pages(1);
}
