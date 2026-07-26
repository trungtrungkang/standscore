import 'package:standscore/layout/pdf_layout_mode.dart';

/// Peek fraction of the viewport dedicated to the next page (Spec 0013).
const double halfPageSeparatorMin = 0.1;
const double halfPageSeparatorMax = 0.5;
const double halfPageSeparatorDefault = 0.28;

double clampHalfPageSeparatorRatio(double ratio) =>
    ratio.clamp(halfPageSeparatorMin, halfPageSeparatorMax).toDouble();

bool isHalfPageLayoutMode(PdfLayoutMode mode) =>
    mode == PdfLayoutMode.halfPageTopBottom ||
    mode == PdfLayoutMode.halfPageLeftRight;

/// 1-based next performance page, or null at end of PageOrder.
int? halfPageNextPerformancePage({
  required int currentPage,
  required int pageCount,
}) {
  if (pageCount < 1) return null;
  if (currentPage < 1 || currentPage >= pageCount) return null;
  return currentPage + 1;
}
