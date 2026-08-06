import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';

/// PdfMode reading layout (Specs 0004 / 0013 / 0041 / 0056).
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

  /// Pages stacked vertically (continuous scroll), same engine as
  /// [fitWidth]. PageTurn always advances half a viewport (Spec 0056) — that
  /// half-step is what shows the top of the next page while the current one
  /// is still on screen, without the jump-cut a fixed peek overlay caused.
  halfPageTopBottom,

  /// Pages in a horizontal strip (continuous scroll), same engine as
  /// [fitHeight]. PageTurn always advances half a viewport (Spec 0056).
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
  String label(AppLocalizations l10n) => switch (this) {
    PdfLayoutMode.auto => l10n.pdfLayoutModeAuto,
    PdfLayoutMode.single => l10n.pdfLayoutModeSingle,
    PdfLayoutMode.twoPage => l10n.pdfLayoutModeTwoPages,
    PdfLayoutMode.fitWidth => l10n.pdfLayoutModeScroll,
    PdfLayoutMode.fitHeight => l10n.pdfLayoutModeScrollSideways,
    PdfLayoutMode.halfPageTopBottom => l10n.pdfLayoutModeHalfPageTopBottom,
    PdfLayoutMode.halfPageLeftRight => l10n.pdfLayoutModeHalfPageLeftRight,
  };
}

/// pdfrx continuous layouts. Single page uses a dedicated widget (Spec 0056
/// moved Half Page off its own overlay and onto this same engine).
PdfPageLayoutFunction layoutPagesFor(PdfLayoutMode mode) {
  assert(
    mode != PdfLayoutMode.single && mode != PdfLayoutMode.auto,
    'Single page uses a dedicated viewer, and Auto must be resolved',
  );
  return switch (mode) {
    PdfLayoutMode.auto || PdfLayoutMode.single =>
      (pages, params) => _layoutVertical(pages, params, gap: params.margin),
    PdfLayoutMode.fitWidth || PdfLayoutMode.halfPageTopBottom =>
      (pages, params) => _layoutVertical(pages, params, gap: params.margin),
    PdfLayoutMode.fitHeight ||
    PdfLayoutMode.halfPageLeftRight => _layoutHorizontal,
    PdfLayoutMode.twoPage => _layoutTwoPage,
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
