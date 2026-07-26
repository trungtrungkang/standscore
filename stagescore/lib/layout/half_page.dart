import 'dart:math' as math;
import 'dart:ui';

import 'package:stagescore/layout/pdf_layout_mode.dart';

/// Peek fraction of the viewport dedicated to the next page (Spec 0013).
const double halfPageSeparatorMin = 0.1;
const double halfPageSeparatorMax = 0.5;
const double halfPageSeparatorDefault = 0.28;

double clampHalfPageSeparatorRatio(double ratio) =>
    ratio.clamp(halfPageSeparatorMin, halfPageSeparatorMax).toDouble();

bool isHalfPageLayoutMode(PdfLayoutMode mode) =>
    mode == PdfLayoutMode.halfPageTopBottom ||
    mode == PdfLayoutMode.halfPageLeftRight;

/// Width the peek page is laid out at, before it is clipped to the band
/// (Spec 0013, corrected by 0041).
///
/// The peek used to be a whole page fitted into the band, which on a phone
/// drew the next page at 42% of the size of the page beside it — the notes
/// were there and nobody could read them. A peek is for reading the first
/// system of what comes next, so the page is drawn at the size it will be
/// played at and the rest is cut off.
///
/// That size is the current page's own width, except where the band is
/// narrower than that (the side peek always is, and so is a top peek on a
/// screen where the current page is bound by height).
double halfPagePeekPageWidth({
  required PdfLayoutMode mode,
  required Size viewerSize,
  required double separatorRatio,
  required double pageAspect,
  required double handleExtent,
}) {
  if (viewerSize.isEmpty || pageAspect <= 0) return 0;
  final ratio = clampHalfPageSeparatorRatio(separatorRatio);
  if (mode == PdfLayoutMode.halfPageTopBottom) {
    final usable = viewerSize.height - handleExtent;
    if (usable <= 0) return 0;
    final currentPaneHeight = usable * (1 - ratio);
    return math.min(viewerSize.width, currentPaneHeight * pageAspect);
  }
  final usable = viewerSize.width - handleExtent;
  if (usable <= 0) return 0;
  return math.min(usable * ratio, viewerSize.height * pageAspect);
}

/// 1-based next performance page, or null at end of PageOrder.
int? halfPageNextPerformancePage({
  required int currentPage,
  required int pageCount,
}) {
  if (pageCount < 1) return null;
  if (currentPage < 1 || currentPage >= pageCount) return null;
  return currentPage + 1;
}
