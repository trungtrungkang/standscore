import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:stagescore/annotation/annotation_store.dart';
import 'package:stagescore/annotation/draw_style.dart';
import 'package:stagescore/annotation/draw_tool.dart';
import 'package:stagescore/annotation/stamp.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/layout/page_color_filter.dart';
import 'package:stagescore/pageorder/page_order.dart';
import 'package:stagescore/pdf/page_annotation_overlay.dart';
import 'package:stagescore/pdf/pdf_surface.dart';

/// Renders one PageOrder slot: PDF page or blank (Spec 0011).
class PerformancePageSlot extends StatelessWidget {
  const PerformancePageSlot({
    super.key,
    required this.document,
    required this.entry,
    required this.store,
    required this.drawEnabled,
    required this.onAnnotateChanged,
    this.drawTool = DrawTool.pen,
    this.drawStyle = const DrawStylePrefs(),
    this.onDrawStyleChanged,
    this.onEyedropperDone,
    this.pendingStamp,
    this.pendingStampText,
    this.onPendingStampConsumed,
    this.selectedStampId,
    this.onSelectedStampChanged,
    this.annotationsVisible = true,
    this.colorFilterMode = PageColorFilterMode.off,
    this.transformationController,
    this.panEnabled = true,
    this.scaleEnabled = true,
    this.pageScale = 1.0,
    this.pageBorderEnabled = false,
    this.pageBorderWidth = 2.0,
    this.pageBorderColor = const Color(0xFF424242),
  });

  final PdfDocument document;
  final PageOrderEntry entry;
  final AnnotationStore store;
  final bool drawEnabled;
  final VoidCallback onAnnotateChanged;
  final DrawTool drawTool;
  final DrawStylePrefs drawStyle;
  final ValueChanged<Color>? onDrawStyleChanged;
  final VoidCallback? onEyedropperDone;
  final StampKind? pendingStamp;
  final String? pendingStampText;
  final VoidCallback? onPendingStampConsumed;
  final String? selectedStampId;
  final ValueChanged<String?>? onSelectedStampChanged;
  final bool annotationsVisible;
  final PageColorFilterMode colorFilterMode;
  final TransformationController? transformationController;
  final bool panEnabled;
  final bool scaleEnabled;

  /// Persisted base page scale (Spec 0031); pinch stacks on top when enabled.
  final double pageScale;

  /// Page frame (Spec 0032).
  final bool pageBorderEnabled;
  final double pageBorderWidth;
  final Color pageBorderColor;

  /// Drawn above page pixels — PdfPageView [decoration] sits under the image
  /// and is fully covered, so borders there are invisible.
  Widget? _pageBorderOverlay() {
    if (!pageBorderEnabled) return null;
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: pageBorderColor, width: pageBorderWidth),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // The gutter sits outside the filtered subtree, so tint it here.
    final bg = pdfSurfaceColor(context, filter: colorFilterMode);
    if (entry.isBlank) {
      return ColoredBox(
        color: bg,
        child: Center(
          child: AspectRatio(
            aspectRatio: 1 / 1.414,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: applyPageColorFilter(Colors.white, colorFilterMode),
                ),
                Center(
                  child: Text(
                    l10n.performancePageSlotBlank,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                ?_pageBorderOverlay(),
              ],
            ),
          ),
        ),
      );
    }

    final source = entry.sourcePage!;
    if (source < 1 || source > document.pages.length) {
      return ColoredBox(
        color: bg,
        child: Center(
          child: Text(l10n.performancePageSlotMissingPage(source)),
        ),
      );
    }
    final page = document.pages[source - 1];

    return ColoredBox(
      color: bg,
      child: InteractiveViewer(
        transformationController: transformationController,
        minScale: 1,
        maxScale: 8,
        panEnabled: panEnabled,
        scaleEnabled: scaleEnabled,
        child: Transform.scale(
          scale: pageScale,
          alignment: Alignment.center,
          child: Center(
            child: AspectRatio(
              aspectRatio: page.width / page.height,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final pageRect =
                      Offset.zero &
                      Size(constraints.maxWidth, constraints.maxHeight);
                  return PageColorFiltered(
                    mode: colorFilterMode,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        PdfPageView(
                          document: document,
                          pageNumber: source,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(color: Colors.white),
                        ),
                        PageAnnotationOverlay(
                          pageRect: pageRect,
                          page: page,
                          store: store,
                          drawEnabled: drawEnabled,
                          onChanged: onAnnotateChanged,
                          tool: drawTool,
                          style: drawStyle,
                          onStyleChanged: onDrawStyleChanged,
                          onEyedropperDone: onEyedropperDone,
                          pendingStamp: pendingStamp,
                          pendingStampText: pendingStampText,
                          onPendingStampConsumed: onPendingStampConsumed,
                          selectedStampId: selectedStampId,
                          onSelectedStampChanged: onSelectedStampChanged,
                          annotationsVisible: annotationsVisible,
                        ),
                        ?_pageBorderOverlay(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
