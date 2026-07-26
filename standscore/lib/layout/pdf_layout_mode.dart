import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:standscore/layout/half_page.dart';

/// PdfMode reading layout (Specs 0004 / 0013 / 0041).
enum PdfLayoutMode {
  /// Whatever the screen can afford — resolved from `LayoutFit`, never drawn
  /// directly. Stored as a choice; see `resolveLayoutMode` (Spec 0041).
  auto,

  /// One page at a time with horizontal slider turn (not continuous scroll).
  /// Rendered by [SinglePageSlider], not pdfrx [layoutPagesFor].
  single,

  /// Facing pages side-by-side.
  twoPage,

  /// Pages stacked vertically (continuous scroll).
  fitWidth,

  /// Pages in a horizontal strip (continuous scroll).
  ///
  /// Cut from the picker at 0041 — its result was whatever the screen's aspect
  /// happened to produce, including a page wider than a portrait phone. Kept
  /// in the enum because 0027 restores and older prefs files contain it, and
  /// resolved to [fitWidth] before anything draws it.
  fitHeight,

  /// Current page + peek of next (peek on top). Dedicated [HalfPageView].
  halfPageTopBottom,

  /// Current page + peek of next (peek on left; right when reverse). Dedicated.
  halfPageLeftRight,
}

/// The direction pages move in a layout — and therefore the direction the
/// musician's thumb should move to turn one (Spec 0041).
enum LayoutAxis { horizontal, vertical }

LayoutAxis layoutAxisFor(PdfLayoutMode mode) => switch (mode) {
  PdfLayoutMode.single ||
  PdfLayoutMode.twoPage ||
  PdfLayoutMode.fitHeight ||
  PdfLayoutMode.halfPageLeftRight => LayoutAxis.horizontal,
  PdfLayoutMode.fitWidth ||
  PdfLayoutMode.halfPageTopBottom => LayoutAxis.vertical,
  // Never drawn: resolve first, then ask.
  PdfLayoutMode.auto => LayoutAxis.horizontal,
};

/// Layouts offered in the Layout sheet, in reading order (Spec 0041).
const List<PdfLayoutMode> pickableLayoutModes = [
  PdfLayoutMode.auto,
  PdfLayoutMode.single,
  PdfLayoutMode.twoPage,
  PdfLayoutMode.halfPageTopBottom,
  PdfLayoutMode.halfPageLeftRight,
  PdfLayoutMode.fitWidth,
];

extension PdfLayoutModeX on PdfLayoutMode {
  /// Named for what the musician gets, not for how it is computed — "fit" is
  /// a zoom rule these modes stopped implementing when 0036 took the fit over.
  String get label => switch (this) {
    PdfLayoutMode.auto => 'Auto',
    PdfLayoutMode.single => 'One page',
    PdfLayoutMode.twoPage => 'Two pages',
    PdfLayoutMode.fitWidth => 'Scroll',
    PdfLayoutMode.fitHeight => 'Scroll (sideways)',
    PdfLayoutMode.halfPageTopBottom => 'One page + peek',
    PdfLayoutMode.halfPageLeftRight => 'One page + side peek',
  };
}

/// pdfrx continuous layouts. Discrete modes use dedicated widgets.
PdfPageLayoutFunction layoutPagesFor(PdfLayoutMode mode) {
  assert(
    !isHalfPageLayoutMode(mode) &&
        mode != PdfLayoutMode.single &&
        mode != PdfLayoutMode.auto,
    'Single/half-page modes use dedicated viewers, and Auto must be resolved',
  );
  return switch (mode) {
    PdfLayoutMode.auto || PdfLayoutMode.single =>
      (pages, params) => _layoutVertical(pages, params, gap: params.margin),
    PdfLayoutMode.fitWidth => (pages, params) => _layoutVertical(
      pages,
      params,
      gap: params.margin,
    ),
    PdfLayoutMode.fitHeight => _layoutHorizontal,
    PdfLayoutMode.twoPage => _layoutTwoPage,
    PdfLayoutMode.halfPageTopBottom || PdfLayoutMode.halfPageLeftRight =>
      (pages, params) => _layoutVertical(pages, params, gap: params.margin),
  };
}

PdfPageLayout _layoutVertical(
  List<PdfPage> pages,
  PdfViewerParams params, {
  required double gap,
}) {
  final width = pages.fold(0.0, (w, p) => max(w, p.width)) + params.margin * 2;
  final pageLayout = <Rect>[];
  var y = params.margin;
  for (final page in pages) {
    pageLayout.add(
      Rect.fromLTWH((width - page.width) / 2, y, page.width, page.height),
    );
    y += page.height + gap;
  }
  return PdfPageLayout(pageLayouts: pageLayout, documentSize: Size(width, y));
}

PdfPageLayout _layoutHorizontal(List<PdfPage> pages, PdfViewerParams params) {
  final height =
      pages.fold(0.0, (h, p) => max(h, p.height)) + params.margin * 2;
  final pageLayout = <Rect>[];
  var x = params.margin;
  for (final page in pages) {
    pageLayout.add(
      Rect.fromLTWH(x, (height - page.height) / 2, page.width, page.height),
    );
    x += page.width + params.margin;
  }
  return PdfPageLayout(pageLayouts: pageLayout, documentSize: Size(x, height));
}

PdfPageLayout _layoutTwoPage(List<PdfPage> pages, PdfViewerParams params) {
  final pageLayout = <Rect>[];
  var y = params.margin;
  var docWidth = params.margin * 2;

  for (var i = 0; i < pages.length; i += 2) {
    final left = pages[i];
    final right = i + 1 < pages.length ? pages[i + 1] : null;
    final rowHeight = max(left.height, right?.height ?? 0);
    final rowWidth =
        left.width +
        (right?.width ?? 0) +
        params.margin * (right == null ? 2 : 3);

    docWidth = max(docWidth, rowWidth);

    final leftX = params.margin;
    pageLayout.add(
      Rect.fromLTWH(
        leftX,
        y + (rowHeight - left.height) / 2,
        left.width,
        left.height,
      ),
    );

    if (right != null) {
      pageLayout.add(
        Rect.fromLTWH(
          leftX + left.width + params.margin,
          y + (rowHeight - right.height) / 2,
          right.width,
          right.height,
        ),
      );
    }

    y += rowHeight + params.margin;
  }

  return PdfPageLayout(
    pageLayouts: pageLayout,
    documentSize: Size(docWidth, y),
  );
}

/// PageTurn step: facing mode advances a spread.
int pageTurnStepFor(PdfLayoutMode mode) =>
    mode == PdfLayoutMode.twoPage ? 2 : 1;
