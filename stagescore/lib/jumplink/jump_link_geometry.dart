import 'dart:ui';

import 'package:stagescore/jumplink/jump_link.dart';
import 'package:stagescore/layout/half_page.dart';
import 'package:stagescore/layout/pdf_layout_mode.dart';
import 'package:stagescore/pageturn/page_jump.dart';

/// Separator handle thickness used by [HalfPageView].
const double halfPageHandleExtent = 28;

/// Clamp JumpLink destination to a valid performance page (Spec 0016).
int clampJumpDestination(int destinationPage, int pageCount) =>
    clampPageNumber(destinationPage, pageCount);

/// Largest aspect-fit page rect centered in [viewerSize] (BoxFit.contain).
Rect fittedPageRect(Size viewerSize, double pageAspectRatio) {
  if (viewerSize.isEmpty || pageAspectRatio <= 0) {
    return Offset.zero & viewerSize;
  }
  final viewerAspect = viewerSize.width / viewerSize.height;
  if (viewerAspect > pageAspectRatio) {
    final height = viewerSize.height;
    final width = height * pageAspectRatio;
    return Rect.fromLTWH((viewerSize.width - width) / 2, 0, width, height);
  }
  final width = viewerSize.width;
  final height = width / pageAspectRatio;
  return Rect.fromLTWH(0, (viewerSize.height - height) / 2, width, height);
}

/// Pixel rect of a JumpLink within [pageRect].
Rect jumpLinkPixelRect(JumpLink link, Rect pageRect) {
  return Rect.fromLTWH(
    pageRect.left + link.normRect.left * pageRect.width,
    pageRect.top + link.normRect.top * pageRect.height,
    link.normRect.width * pageRect.width,
    link.normRect.height * pageRect.height,
  );
}

/// Move a normalized JumpLink rect by a pixel delta; keep fully on-page.
Rect moveJumpLinkNormRect(Rect norm, Offset pixelDelta, Size pageSize) {
  if (pageSize.width <= 0 || pageSize.height <= 0) return norm;
  final width = norm.width.clamp(0.0, 1.0);
  final height = norm.height.clamp(0.0, 1.0);
  final left = (norm.left + pixelDelta.dx / pageSize.width).clamp(
    0.0,
    1.0 - width,
  );
  final top = (norm.top + pixelDelta.dy / pageSize.height).clamp(
    0.0,
    1.0 - height,
  );
  return Rect.fromLTWH(left, top, width, height);
}

/// Hit-test JumpLinks on [originPage] within [pageRect].
/// Returns the topmost match (last in list wins).
JumpLink? hitTestJumpLinksInPageRect({
  required List<JumpLink> links,
  required int originPage,
  required Offset localInViewer,
  required Rect pageRect,
}) {
  JumpLink? hit;
  for (final link in links) {
    if (link.originPage != originPage) continue;
    final rect = jumpLinkPixelRect(link, pageRect);
    if (rect.contains(localInViewer)) {
      hit = link;
    }
  }
  return hit;
}

/// Hit-test using a fitted page rect for [pageAspectRatio].
JumpLink? hitTestJumpLinks({
  required List<JumpLink> links,
  required int originPage,
  required Offset localInViewer,
  required Size viewerSize,
  required double pageAspectRatio,
}) {
  return hitTestJumpLinksInPageRect(
    links: links,
    originPage: originPage,
    localInViewer: localInViewer,
    pageRect: fittedPageRect(viewerSize, pageAspectRatio),
  );
}

/// Current-page pane inside a Half Page layout (matches HalfPageView chrome).
Rect halfPageCurrentPaneRect({
  required Size viewerSize,
  required PdfLayoutMode layoutMode,
  required double separatorRatio,
  required bool reverseHorizontal,
}) {
  final ratio = clampHalfPageSeparatorRatio(separatorRatio);
  if (layoutMode == PdfLayoutMode.halfPageTopBottom) {
    final usable = viewerSize.height - halfPageHandleExtent;
    final peek = usable * ratio;
    return Rect.fromLTWH(
      0,
      peek + halfPageHandleExtent,
      viewerSize.width,
      usable - peek,
    );
  }
  final usable = viewerSize.width - halfPageHandleExtent;
  final peek = usable * ratio;
  final peekFirst = !reverseHorizontal;
  if (peekFirst) {
    return Rect.fromLTWH(
      peek + halfPageHandleExtent,
      0,
      usable - peek,
      viewerSize.height,
    );
  }
  return Rect.fromLTWH(0, 0, usable - peek, viewerSize.height);
}
