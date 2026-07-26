import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:standscore/annotation/annotation_store.dart';
import 'package:standscore/annotation/draw_style.dart';
import 'package:standscore/annotation/draw_tool.dart';
import 'package:standscore/annotation/stamp.dart';
import 'package:standscore/layout/half_page.dart';
import 'package:standscore/layout/page_color_filter.dart';
import 'package:standscore/layout/pdf_layout_mode.dart';
import 'package:standscore/pageorder/page_order.dart';
import 'package:standscore/pdf/performance_page_slot.dart';

const double _handleExtent = 28;

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

  bool get isReady => _state?._document != null && (_state?._pageCount ?? 0) > 0;

  Future<void> goToPage(int pageNumber, {required Duration duration}) {
    return _state?._goToPage(pageNumber) ?? Future<void>.value();
  }

  void _notify() => notifyListeners();
}

class _HalfPageViewState extends State<HalfPageView> {
  PdfDocument? _document;
  int _pageIndex = 0;
  int _pageCount = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
    _pageCount = widget.pageOrder.length;
    _pageIndex =
        (widget.initialPage - 1).clamp(0, _pageCount > 0 ? _pageCount - 1 : 0);
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
    _document?.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final previous = _document;
    setState(() {
      _error = null;
      _document = null;
      _pageCount = widget.pageOrder.length;
      _pageIndex = (widget.initialPage - 1)
          .clamp(0, _pageCount > 0 ? _pageCount - 1 : 0);
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

  Widget _buildPeek(PdfDocument doc, Color bg) {
    final nextPage = halfPageNextPerformancePage(
      currentPage: _pageIndex + 1,
      pageCount: _pageCount,
    );
    if (nextPage != null) {
      final entry = widget.pageOrder.entries[nextPage - 1];
      return ColoredBox(
        color: bg,
        child: PerformancePageSlot(
          document: doc,
          entry: entry,
          store: widget.store,
          drawEnabled: false,
          onAnnotateChanged: () {},
          colorFilterMode: widget.colorFilterMode,
          pageScale: widget.resolvePageScale?.call(entry.sourcePage) ??
              widget.pageScale,
          pageBorderEnabled: widget.pageBorderEnabled,
          pageBorderWidth: widget.pageBorderWidth,
          pageBorderColor: widget.pageBorderColor,
          panEnabled: false,
          scaleEnabled: false,
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
      pageScale: widget.resolvePageScale?.call(entry.sourcePage) ??
          widget.pageScale,
      pageBorderEnabled: widget.pageBorderEnabled,
      pageBorderWidth: widget.pageBorderWidth,
      pageBorderColor: widget.pageBorderColor,
      // Pan fights PageTurn swipe; pinch-zoom still available when unlocked.
      panEnabled: false,
      scaleEnabled: !widget.drawEnabled && !widget.zoomLocked,
    );
  }

  Widget _separatorHandle({required bool verticalBar}) {
    final theme = Theme.of(context);
    final useBorder = widget.pageBorderEnabled;
    final lineColor =
        useBorder ? widget.pageBorderColor : theme.colorScheme.outline;
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

    final bg = Theme.of(context).colorScheme.surfaceContainerHighest;
    final topBottom = widget.layoutMode == PdfLayoutMode.halfPageTopBottom;
    final ratio = clampHalfPageSeparatorRatio(widget.separatorRatio);

    return LayoutBuilder(
      builder: (context, constraints) {
        final peek = _buildPeek(doc, bg);
        final current = _buildCurrent(doc);
        final overlay = widget.viewerOverlay;

        if (topBottom) {
          final usable = constraints.maxHeight - _handleExtent;
          final peekSize = usable * ratio;
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
