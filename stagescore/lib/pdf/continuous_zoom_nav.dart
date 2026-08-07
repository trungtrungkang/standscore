import 'dart:ui';

/// Document-space focus so [pageRect]'s top edge sits at the top of a
/// [viewSize] viewport at [zoom], with the page centred horizontally.
///
/// Used when jumping pages on the identity continuous `PdfViewer` while the
/// musician is pinched in. pdfrx's `goToPage` with `PdfPageAnchor.top` recomputes
/// a fit zoom and only uses the current zoom as a *ceiling* (`zoomMax`), so a
/// pinch-in is discarded on every scrubber / prev / next jump (Spec 0033).
/// Feeding this point to `PdfViewerController.calcMatrixFor` at the current
/// zoom keeps the magnification and still lands on the top of the target page.
Offset pageTopFocus({
  required Rect pageRect,
  required Size viewSize,
  required double zoom,
}) {
  assert(zoom > 0);
  return Offset(
    pageRect.center.dx,
    pageRect.top + viewSize.height / (2 * zoom),
  );
}
