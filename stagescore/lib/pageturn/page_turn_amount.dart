import 'package:stagescore/layout/half_page.dart';
import 'package:stagescore/layout/pdf_layout_mode.dart';

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

/// Resolve PageTurn step from layout + turn amount (Specs 0014 / 0041).
PageTurnStep resolvePageTurnStep({
  required PdfLayoutMode mode,
  required TurnAmount amount,
}) {
  assert(mode != PdfLayoutMode.auto, 'resolve the layout before stepping it');
  if (mode == PdfLayoutMode.single || isHalfPageLayoutMode(mode)) {
    return PageTurnStep.pages(1);
  }
  if (mode == PdfLayoutMode.twoPage) {
    return PageTurnStep.pages(amount == TurnAmount.half ? 1 : 2);
  }
  // Scrolling layouts move by what is on the screen, not by page index. A
  // page-anchored jump leaves whatever did not fit unread — invisible on a
  // phone, where a page has vertical slack to spare, and a lost system at the
  // bottom of every page on a tablet (Spec 0041).
  return PageTurnStep.viewport(amount == TurnAmount.half ? 0.5 : 1.0);
}

/// Whether Turn amount changes anything in [mode].
///
/// One page and the peek layouts always advance one page, so offering the
/// setting there teaches the musician that settings do nothing (Spec 0041).
bool turnAmountApplies(PdfLayoutMode mode) =>
    mode != PdfLayoutMode.single && !isHalfPageLayoutMode(mode);
