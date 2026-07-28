import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:stagescore/annotation/annotation_store.dart';
import 'package:stagescore/annotation/draw_style.dart';
import 'package:stagescore/annotation/draw_tool.dart';
import 'package:stagescore/annotation/stamp.dart';
import 'package:stagescore/layout/half_page.dart';
import 'package:stagescore/layout/page_color_filter.dart';
import 'package:stagescore/layout/pdf_layout_mode.dart';
import 'package:stagescore/pageorder/page_order.dart';
import 'package:stagescore/pdf/pdf_surface.dart';
import 'package:stagescore/pdf/performance_page_slot.dart';
import 'package:stagescore/pdf/shared_zoom.dart';
import 'package:stagescore/pdf/zoom_toggle.dart';

const double _handleExtent = 28;

/// A4, matching the blank page [PerformancePageSlot] draws.
const double _blankPageAspect = 1 / 1.414;

/// Current page + peek of next page with a draggable separator (Spec 0013).
class HalfPageView extends StatefulWidget {
  const HalfPageView({
    super.key,
    required this.filePath,
    required this.pageOrder,
    required this.layoutMode,
    required this.separatorRatio,
    required this.onSeparatorRatioChanged,
    required this.store,
    required this.drawEnabled,
    required this.onAnnotateChanged,
    required this.controller,
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
    this.pageScale = 1.0,
    this.zoomLocked = false,
    this.resolvePageScale,
    this.pageBorderEnabled = false,
    this.pageBorderWidth = 2.0,
    this.pageBorderColor = const Color(0xFF424242),
    this.reverseHorizontal = false,
    this.nextSetlistTitle,
    this.initialPage = 1,
    this.viewerOverlay,
  });

  final String filePath;
  final PageOrder pageOrder;
  final PdfLayoutMode layoutMode;
  final double separatorRatio;
  final ValueChanged<double> onSeparatorRatioChanged;
  final AnnotationStore store;
  final bool drawEnabled;
  final VoidCallback onAnnotateChanged;
  final HalfPageController controller;
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
  final double pageScale;
  final bool zoomLocked;
  final double Function(int? sourcePage)? resolvePageScale;
  final bool pageBorderEnabled;
  final double pageBorderWidth;
  final Color pageBorderColor;
  final bool reverseHorizontal;

  /// Shown in peek when there is no next page but a Setlist has a next Score.
  final String? nextSetlistTitle;
  final int initialPage;

  /// Full-viewer PageTurn overlay; separator handle stays above it.
  final Widget? viewerOverlay;

  @override
  State<HalfPageView> createState() => _HalfPageViewState();
}

class HalfPageController extends ChangeNotifier {
  _HalfPageViewState? _state;

  void _attach(_HalfPageViewState? state) {
    _state = state;
  }

  /// Only clear if [state] is still the attached owner (new widget may have
  /// already attached before the old one's dispose runs).
  void _detach(_HalfPageViewState state) {
    if (_state == state) _state = null;
  }

  int get pageNumber => (_state?._pageIndex ?? 0) + 1;

  int get pageCount => _state?._pageCount ?? 0;

  bool get isReady =>
      _state?._document != null && (_state?._pageCount ?? 0) > 0;

  Future<void> goToPage(int pageNumber, {required Duration duration}) {
    return _state?._goToPage(pageNumber) ?? Future<void>.value();
  }

  void _notify() => notifyListeners();
}

class _HalfPageViewState extends State<HalfPageView> {
  PdfDocument? _document;
  int _pageIndex = 0;
  int _pageCount = 0;
  final Map<int, TransformationController> _transforms = {};
  String? _error;

  /// Shared pinch/pan transform across pages, mirroring
  /// `_SinglePageSliderState` (post-0043 follow-up — see `shared_zoom.dart`
  /// for why pan, not just scale, is shared).
  Matrix4? _sharedZoomTransform;

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
    _pageCount = widget.pageOrder.length;
    _pageIndex = (widget.initialPage - 1).clamp(
      0,
      _pageCount > 0 ? _pageCount - 1 : 0,
    );
    _open();
  }

  @override
  void didUpdateWidget(covariant HalfPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._detach(this);
      widget.controller._attach(this);
    }
    if (oldWidget.filePath != widget.filePath) {
      _open();
      return;
    }
    if (oldWidget.pageOrder != widget.pageOrder) {
      setState(() {
        _pageCount = widget.pageOrder.length;
        if (_pageIndex >= _pageCount) {
          _pageIndex = _pageCount > 0 ? _pageCount - 1 : 0;
        }
      });
      widget.controller._notify();
    }
  }

  @override
  void dispose() {
    widget.controller._detach(this);
    _zoomSettleTimer?.cancel();
    for (final t in _transforms.values) {
      t.dispose();
    }
    _document?.dispose();
    super.dispose();
  }

  TransformationController _transformFor(int index) {
    return _transforms.putIfAbsent(index, () {
      final t = TransformationController(
        sharedZoomMatrix(_sharedZoomTransform),
      );
      t.addListener(() => _onTransformChanged(index, t));
      return t;
    });
  }

  /// Debounces sharing until the current page's transform stops moving — see
  /// `kZoomSettleDelay` for why `onInteractionEnd` alone reads a mid-fling
  /// value rather than where the musician actually left it.
  Timer? _zoomSettleTimer;

  void _onTransformChanged(int index, TransformationController t) {
    if (index != _pageIndex) return;
    if (mounted) setState(() {});
    _zoomSettleTimer?.cancel();
    _zoomSettleTimer = Timer(
      kZoomSettleDelay,
      () => _onZoomSettled(index),
    );
  }

  /// Fires once [index]'s transform has sat still for `kZoomSettleDelay`
  /// (post-0043 follow-up). Shares the resulting transform with every other
  /// page's controller so PageTurn keeps the zoom *and* the pan.
  void _onZoomSettled(int index) {
    if (!mounted) return;
    final t = _transforms[index];
    if (t == null) return;
    final next = nextSharedZoomTransform(t.value);
    if (!sharedZoomTransformChanged(_sharedZoomTransform, next)) return;
    _sharedZoomTransform = next;
    for (final entry in _transforms.entries) {
      if (entry.key == index) continue;
      entry.value.value = sharedZoomMatrix(next);
    }
  }

  bool _isZoomed(int index) {
    final t = _transforms[index];
    if (t == null) return false;
    return isInteractivelyZoomed(t.value);
  }

  Future<void> _open() async {
    final previous = _document;
    setState(() {
      _error = null;
      _document = null;
      _pageCount = widget.pageOrder.length;
      _pageIndex = (widget.initialPage - 1).clamp(
        0,
        _pageCount > 0 ? _pageCount - 1 : 0,
      );
      _sharedZoomTransform = null;
    });
    previous?.dispose();
    try {
      final doc = await PdfDocument.openFile(widget.filePath);
      if (!mounted) {
        doc.dispose();
        return;
      }
      setState(() {
        _document = doc;
        _pageCount = widget.pageOrder.length;
      });
      widget.controller._notify();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _goToPage(int pageNumber) async {
    if (_pageCount <= 0) return;
    final index = (pageNumber - 1).clamp(0, _pageCount - 1);
    if (_pageIndex != index && mounted) {
      setState(() => _pageIndex = index);
      widget.controller._notify();
    }
  }

  void _onDragUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    final topBottom = widget.layoutMode == PdfLayoutMode.halfPageTopBottom;
    final delta = topBottom ? details.delta.dy : details.delta.dx;
    final extent = topBottom
        ? constraints.maxHeight - _handleExtent
        : constraints.maxWidth - _handleExtent;
    if (extent <= 0) return;

    // Dragging the handle toward the current page increases peek size.
    var signed = delta;
    if (!topBottom && widget.reverseHorizontal) {
      signed = -delta;
    }
    final next = clampHalfPageSeparatorRatio(
      widget.separatorRatio + signed / extent,
    );
    if ((next - widget.separatorRatio).abs() > 0.0005) {
      widget.onSeparatorRatioChanged(next);
    }
  }

  double _peekPageWidth(
    BoxConstraints constraints,
    double currentAspect,
    double ratio,
  ) => halfPagePeekPageWidth(
    mode: widget.layoutMode,
    viewerSize: Size(constraints.maxWidth, constraints.maxHeight),
    separatorRatio: ratio,
    pageAspect: currentAspect,
    handleExtent: _handleExtent,
  );

  /// The peek band, showing the *top* of the next page at reading size.
  ///
  /// The band is short and wide, so fitting a whole page inside it drew the
  /// next page at 42% of the current page's size on a phone — every note
  /// legible only in principle. What a musician reads ahead for is the first
  /// system or two, at the size they are about to play it, so the page is laid
  /// out at [width] and whatever does not fit the band is simply cut off
  /// (Spec 0013, fixed in 0041).
  Widget _topOfPage({
    required double width,
    required double aspect,
    required Widget child,
  }) {
    if (width <= 0 || aspect <= 0) return child;
    final height = width / aspect;
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, band) => OverflowBox(
          // Anchored to the top only when there is more page than band; a side
          // peek that fits whole sits centred, like the page it is beside.
          alignment: height > band.maxHeight
              ? Alignment.topCenter
              : Alignment.center,
          minWidth: width,
          maxWidth: width,
          minHeight: height,
          maxHeight: height,
          child: child,
        ),
      ),
    );
  }

  /// Width over height of the page drawn for [index], blanks included.
  double _pageAspect(PdfDocument doc, int index) {
    if (index < 0 || index >= widget.pageOrder.entries.length) {
      return _blankPageAspect;
    }
    final entry = widget.pageOrder.entries[index];
    final source = entry.sourcePage;
    if (entry.isBlank || source == null) return _blankPageAspect;
    if (source < 1 || source > doc.pages.length) return _blankPageAspect;
    final page = doc.pages[source - 1];
    return page.width / page.height;
  }

  Widget _buildPeek(PdfDocument doc, Color bg, {required double pageWidth}) {
    final nextPage = halfPageNextPerformancePage(
      currentPage: _pageIndex + 1,
      pageCount: _pageCount,
    );
    if (nextPage != null) {
      final entry = widget.pageOrder.entries[nextPage - 1];
      return ColoredBox(
        color: bg,
        child: _topOfPage(
          width: pageWidth,
          aspect: _pageAspect(doc, nextPage - 1),
          child: PerformancePageSlot(
            document: doc,
            entry: entry,
            store: widget.store,
            drawEnabled: false,
            onAnnotateChanged: () {},
            colorFilterMode: widget.colorFilterMode,
            pageScale:
                widget.resolvePageScale?.call(entry.sourcePage) ??
                widget.pageScale,
            pageBorderEnabled: widget.pageBorderEnabled,
            pageBorderWidth: widget.pageBorderWidth,
            pageBorderColor: widget.pageBorderColor,
            panEnabled: false,
            scaleEnabled: false,
          ),
        ),
      );
    }
    final title = widget.nextSetlistTitle;
    if (title != null && title.isNotEmpty) {
      return ColoredBox(
        color: bg,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Next: $title',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      );
    }
    return ColoredBox(color: bg);
  }

  Widget _buildCurrent(PdfDocument doc) {
    final entry = widget.pageOrder.entries[_pageIndex];
    return PerformancePageSlot(
      document: doc,
      entry: entry,
      store: widget.store,
      drawEnabled: widget.drawEnabled,
      onAnnotateChanged: widget.onAnnotateChanged,
      drawTool: widget.drawTool,
      drawStyle: widget.drawStyle,
      onDrawStyleChanged: widget.onDrawStyleChanged,
      onEyedropperDone: widget.onEyedropperDone,
      pendingStamp: widget.pendingStamp,
      pendingStampText: widget.pendingStampText,
      onPendingStampConsumed: widget.onPendingStampConsumed,
      selectedStampId: widget.selectedStampId,
      onSelectedStampChanged: widget.onSelectedStampChanged,
      annotationsVisible: widget.annotationsVisible,
      colorFilterMode: widget.colorFilterMode,
      pageScale:
          widget.resolvePageScale?.call(entry.sourcePage) ?? widget.pageScale,
      pageBorderEnabled: widget.pageBorderEnabled,
      pageBorderWidth: widget.pageBorderWidth,
      pageBorderColor: widget.pageBorderColor,
      transformationController: _transformFor(_pageIndex),
      // Pan only when zoomed so single-finger PageTurn swipe still works at fit.
      panEnabled: !widget.drawEnabled && _isZoomed(_pageIndex),
      scaleEnabled: !widget.drawEnabled && !widget.zoomLocked,
    );
  }

  Widget _separatorHandle({required bool verticalBar}) {
    final theme = Theme.of(context);
    final useBorder = widget.pageBorderEnabled;
    final lineColor = useBorder
        ? widget.pageBorderColor
        : theme.colorScheme.outline;
    final lineWidth = useBorder ? widget.pageBorderWidth : 1.0;
    return MouseRegion(
      cursor: verticalBar
          ? SystemMouseCursors.resizeLeftRight
          : SystemMouseCursors.resizeUpDown,
      child: Container(
        width: verticalBar ? _handleExtent : null,
        height: verticalBar ? null : _handleExtent,
        alignment: Alignment.center,
        color: theme.colorScheme.surfaceContainerHighest,
        child: Container(
          width: verticalBar ? lineWidth.clamp(1.0, 6.0) : double.infinity,
          height: verticalBar ? double.infinity : lineWidth.clamp(1.0, 6.0),
          margin: EdgeInsets.symmetric(
            horizontal: verticalBar ? 0 : 8,
            vertical: verticalBar ? 8 : 0,
          ),
          color: lineColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(child: Text('Failed to open PDF:\n$_error'));
    }
    final doc = _document;
    if (doc == null || _pageCount < 1) {
      return const Center(child: CircularProgressIndicator());
    }

    final bg = pdfSurfaceColor(context, filter: widget.colorFilterMode);
    final topBottom = widget.layoutMode == PdfLayoutMode.halfPageTopBottom;
    final ratio = clampHalfPageSeparatorRatio(widget.separatorRatio);

    return LayoutBuilder(
      builder: (context, constraints) {
        final current = _buildCurrent(doc);
        final overlay = widget.viewerOverlay;
        final currentAspect = _pageAspect(doc, _pageIndex);

        if (topBottom) {
          final usable = constraints.maxHeight - _handleExtent;
          final peekSize = usable * ratio;
          final peek = _buildPeek(
            doc,
            bg,
            pageWidth: _peekPageWidth(constraints, currentAspect, ratio),
          );
          final handle = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (d) => _onDragUpdate(d, constraints),
            child: _separatorHandle(verticalBar: false),
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  SizedBox(height: peekSize, child: peek),
                  const SizedBox(height: _handleExtent),
                  Expanded(child: current),
                ],
              ),
              if (overlay != null) Positioned.fill(child: overlay),
              Positioned(
                top: peekSize,
                left: 0,
                right: 0,
                height: _handleExtent,
                child: handle,
              ),
            ],
          );
        }

        final usable = constraints.maxWidth - _handleExtent;
        final peekSize = usable * ratio;
        final peek = _buildPeek(
          doc,
          bg,
          pageWidth: _peekPageWidth(constraints, currentAspect, ratio),
        );
        final peekFirst = !widget.reverseHorizontal;
        final handle = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: (d) => _onDragUpdate(d, constraints),
          child: _separatorHandle(verticalBar: true),
        );

        final pages = peekFirst
            ? Row(
                children: [
                  SizedBox(width: peekSize, child: peek),
                  const SizedBox(width: _handleExtent),
                  Expanded(child: current),
                ],
              )
            : Row(
                children: [
                  Expanded(child: current),
                  const SizedBox(width: _handleExtent),
                  SizedBox(width: peekSize, child: peek),
                ],
              );

        final handleLeft = peekFirst ? peekSize : usable - peekSize;

        return Stack(
          fit: StackFit.expand,
          children: [
            pages,
            if (overlay != null) Positioned.fill(child: overlay),
            Positioned(
              left: handleLeft,
              top: 0,
              bottom: 0,
              width: _handleExtent,
              child: handle,
            ),
          ],
        );
      },
    );
  }
}
