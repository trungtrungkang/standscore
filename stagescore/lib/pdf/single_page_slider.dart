import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:stagescore/annotation/annotation_store.dart';
import 'package:stagescore/annotation/draw_style.dart';
import 'package:stagescore/annotation/draw_tool.dart';
import 'package:stagescore/annotation/stamp.dart';
import 'package:stagescore/layout/page_color_filter.dart';
import 'package:stagescore/pageorder/page_order.dart';
import 'package:stagescore/pdf/performance_page_slot.dart';
import 'package:stagescore/pdf/shared_zoom.dart';
import 'package:stagescore/pdf/zoom_toggle.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';

/// ScorePDF-style single-page slider over [PageOrder] (Specs 0004 / 0011).
class SinglePageSlider extends StatefulWidget {
  const SinglePageSlider({
    super.key,
    required this.filePath,
    required this.pageOrder,
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
    this.allowUserScroll = false,
    this.reverseDirection = false,
    this.onDocumentReady,
    this.initialPage = 1,
  });

  final String filePath;
  final PageOrder pageOrder;
  final AnnotationStore store;
  final bool drawEnabled;
  final VoidCallback onAnnotateChanged;
  final SinglePageSliderController controller;
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
  final bool allowUserScroll;
  final bool reverseDirection;
  final ValueChanged<int>? onDocumentReady;

  /// Performance page to open on, read only when this view is built or when it
  /// opens a different file — a layout change or a draw toggle rebuilds the
  /// viewer, and the musician should still be looking at their own page.
  final int initialPage;

  @override
  State<SinglePageSlider> createState() => _SinglePageSliderState();
}

class SinglePageSliderController extends ChangeNotifier {
  _SinglePageSliderState? _state;

  void _attach(_SinglePageSliderState? state) {
    _state = state;
  }

  void _detach(_SinglePageSliderState state) {
    if (_state == state) _state = null;
  }

  int get pageNumber => (_state?._pageIndex ?? 0) + 1;

  int get pageCount => _state?._pageCount ?? 0;

  bool get isReady =>
      _state?._document != null && (_state?._pageCount ?? 0) > 0;

  int get sourcePageCount => _state?._document?.pages.length ?? 0;

  Future<void> goToPage(int pageNumber, {required Duration duration}) {
    return _state?._goToPage(pageNumber, duration: duration) ??
        Future<void>.value();
  }

  void _notify() => notifyListeners();
}

class _SinglePageSliderState extends State<SinglePageSlider> {
  PdfDocument? _document;
  late final PageController _pageController;
  int _pageIndex = 0;
  int _pageCount = 0;
  String? _error;
  final Map<int, TransformationController> _transforms = {};

  /// Pinch/pan transform shared across pages once one page is zoomed
  /// (post-0043 follow-up): a musician who pinched in *and panned* on page 3
  /// — say, to hide a scan's wide left margin — does not want fit-to-page
  /// back, uncentred, the moment they turn to page 4. `null` means "no shared
  /// zoom" (fit).
  Matrix4? _sharedZoomTransform;

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
    _pageCount = widget.pageOrder.length;
    _pageIndex = _initialIndex();
    _pageController = PageController(initialPage: _pageIndex);
    _open();
  }

  int _initialIndex() =>
      (widget.initialPage - 1).clamp(0, _pageCount > 0 ? _pageCount - 1 : 0);

  @override
  void didUpdateWidget(covariant SinglePageSlider oldWidget) {
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_pageController.hasClients || _pageCount <= 0) return;
        _pageController.jumpToPage(_pageIndex);
      });
    }
    if (oldWidget.pageScale != widget.pageScale ||
        oldWidget.zoomLocked != widget.zoomLocked) {
      _sharedZoomTransform = null;
      for (final t in _transforms.values) {
        t.value = Matrix4.identity();
      }
    }
  }

  @override
  void dispose() {
    widget.controller._detach(this);
    _zoomSettleTimer?.cancel();
    _pageController.dispose();
    for (final t in _transforms.values) {
      t.dispose();
    }
    _document?.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final previous = _document;
    setState(() {
      _error = null;
      _document = null;
      _pageCount = widget.pageOrder.length;
      _pageIndex = _initialIndex();
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
        _pageIndex = _initialIndex();
      });
      widget.onDocumentReady?.call(doc.pages.length);
      widget.controller._notify();
      // The PageView is built after the document arrives, so a controller
      // carried over from the previous file is still sitting on its old page.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_pageController.hasClients || _pageCount <= 0) return;
        if (_pageController.page?.round() != _pageIndex) {
          _pageController.jumpToPage(_pageIndex);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _goToPage(int pageNumber, {required Duration duration}) async {
    if (_pageCount <= 0) return;
    final index = (pageNumber - 1).clamp(0, _pageCount - 1);
    if (!_pageController.hasClients) {
      // Attach may lag one frame after remount.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _goToPage(pageNumber, duration: duration);
      });
      return;
    }
    if (duration == Duration.zero) {
      _pageController.jumpToPage(index);
    } else {
      await _pageController.animateToPage(
        index,
        duration: duration,
        curve: Curves.easeOutCubic,
      );
    }
    // Keep controller page in sync even if onPageChanged is skipped.
    if (_pageIndex != index && mounted) {
      setState(() => _pageIndex = index);
      widget.controller._notify();
    }
  }

  bool _isZoomed(int index) {
    final t = _transforms[index];
    if (t == null) return false;
    return isInteractivelyZoomed(t.value);
  }

  bool get _currentZoomed => _isZoomed(_pageIndex);

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
  /// (post-0043 follow-up — double-tap zoom was cut, pinch is now the only
  /// zoom gesture). Shares the resulting transform with every other page's
  /// controller, visited or not, so turning the page keeps the musician's
  /// zoom *and pan* instead of snapping back to an uncentred fit.
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

  TransformationController _transformFor(int index) {
    return _transforms.putIfAbsent(index, () {
      final t = TransformationController(
        sharedZoomMatrix(_sharedZoomTransform),
      );
      t.addListener(() => _onTransformChanged(index, t));
      return t;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_error != null) {
      return Center(child: Text(l10n.singlePageSliderOpenFailed(_error!)));
    }
    final doc = _document;
    if (doc == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final scrollable =
        widget.allowUserScroll && !widget.drawEnabled && !_currentZoomed;

    return PageView.builder(
      controller: _pageController,
      itemCount: _pageCount,
      reverse: widget.reverseDirection,
      physics: scrollable
          ? const PageScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      onPageChanged: (index) {
        setState(() => _pageIndex = index);
        widget.controller._notify();
      },
      itemBuilder: (context, index) {
        final entry = widget.pageOrder.entries[index];
        final transform = _transformFor(index);
        final zoomed = _isZoomed(index);
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
              widget.resolvePageScale?.call(entry.sourcePage) ??
              widget.pageScale,
          pageBorderEnabled: widget.pageBorderEnabled,
          pageBorderWidth: widget.pageBorderWidth,
          pageBorderColor: widget.pageBorderColor,
          transformationController: transform,
          panEnabled:
              !widget.drawEnabled &&
              (zoomed ||
                  (widget.resolvePageScale?.call(entry.sourcePage) ??
                          widget.pageScale) >
                      1.01),
          scaleEnabled: !widget.drawEnabled && !widget.zoomLocked,
        );
      },
    );
  }
}
