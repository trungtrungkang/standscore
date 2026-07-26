import 'package:flutter/material.dart';
import 'package:stagescore/layout/page_color_filter.dart';

/// The surface a Score page sits on — gutters, margins and safe-area bands.
///
/// It matches the paper in light themes so the viewport reads as one sheet
/// instead of a page boxed into the app (Spec 0034); dark themes keep a dark
/// surround. Pass [filter] for surfaces painted outside the filtered subtree,
/// so they tint with the page (Spec 0025).
Color pdfSurfaceColor(
  BuildContext context, {
  PageColorFilterMode filter = PageColorFilterMode.off,
}) {
  return applyPageColorFilter(
    Theme.of(context).colorScheme.surfaceContainerLowest,
    filter,
  );
}
