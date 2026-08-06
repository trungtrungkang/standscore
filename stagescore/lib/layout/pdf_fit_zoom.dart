import 'dart:math' as math;
import 'dart:ui';

import 'package:stagescore/layout/pdf_layout_mode.dart';

/// Slack allowed before a zoom counts as the musician's rather than the fit's.
///
/// Rounding and page margins put the settled zoom a hair off the computed fit;
/// a pinch is never this small.
const double kFitZoomTolerance = 1.08;

/// The zoom at which the layout's reading unit fills the viewport.
///
/// This is the app's own answer to "is the musician zoomed in?", and it has to
/// be, because pdfrx's is orientation-blind: its `minScale` is the scale that
/// fits one whole *page*, which in landscape is far smaller than the fit-width
/// zoom the viewer actually opens at. Measuring against that made a landscape
/// Score look permanently zoomed in, which switched off swipe PageTurn (0033)
/// and handed swipes to the pan gesture instead.
///
/// The reading unit differs per layout, and that is the whole content of this
/// function:
///
/// - **Fit height** reads sideways, so the document's height is the unit.
/// - **Two pages** must show a whole spread, so the taller of the pair binds as
///   well as the spread's width — otherwise a phone in landscape fits the
///   spread across and pushes its bottom off the screen.
/// - Everything else scrolls vertically: width binds, height is endless.
double pdfFitZoom({
  required PdfLayoutMode mode,
  required Size viewSize,
  required Size documentSize,
  double spreadHeight = 0,
}) {
  if (viewSize.isEmpty || documentSize.isEmpty) return 1;
  // Both read sideways: pages sit in a horizontal strip, so its width is the
  // sum of every page rather than the reading unit — height is what one page
  // (or Half Page's half-viewport step, Spec 0056) actually binds to.
  if (mode == PdfLayoutMode.fitHeight ||
      mode == PdfLayoutMode.halfPageLeftRight) {
    return viewSize.height / documentSize.height;
  }
  final byWidth = viewSize.width / documentSize.width;
  if (mode != PdfLayoutMode.twoPage || spreadHeight <= 0) return byWidth;
  return math.min(byWidth, viewSize.height / spreadHeight);
}

/// Height of the facing pair [pageNumber] sits in, in document units.
///
/// Pairs are laid out left-then-right from page 1 (see `layoutPagesFor`), so
/// the pair is found by index, not by asking the layout. A trailing odd page
/// has no partner and is its own height.
double twoPageSpreadHeight(List<Rect> pageLayouts, int pageNumber) {
  if (pageLayouts.isEmpty) return 0;
  final index = (pageNumber - 1).clamp(0, pageLayouts.length - 1);
  final left = index - index % 2;
  final right = left + 1;
  return math.max(
    pageLayouts[left].height,
    right < pageLayouts.length ? pageLayouts[right].height : 0,
  );
}
