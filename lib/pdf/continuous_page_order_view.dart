import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:standscore/annotation/annotation_store.dart';
import 'package:standscore/annotation/draw_style.dart';
import 'package:standscore/annotation/draw_tool.dart';
import 'package:standscore/annotation/stamp.dart';
import 'package:standscore/layout/page_color_filter.dart';
import 'package:standscore/layout/pdf_layout_mode.dart';
import 'package:standscore/pageorder/page_order.dart';
import 'package:standscore/pdf/performance_page_slot.dart';
import 'package:standscore/pdf/zoom_toggle.dart';

/// Scrollable PageOrder view for non-identity continuous layouts (Spec 0011).
class ContinuousPageOrderView extends StatefulWidget {
  const ContinuousPageOrderView({
    super.key,
    required this.filePath,
    required this.pageOrder,
    required this.layoutMode,
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
  });

  final String filePath;
  final PageOrder pageOrder;
  final PdfLayoutMode layoutMode;
  final AnnotationStore store;
  final bool drawEnabled;
  final VoidCallback onAnnotateChanged;
  final ContinuousPageOrderController controller;
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

  @override
  State<ContinuousPageOrderView> createState() =>
      _ContinuousPageOrderViewState();
}

class ContinuousPageOrderController extends ChangeNotifier {
  _ContinuousPageOrderViewState? _state;

  void _attach(_ContinuousPageOrderViewState? state) => _state = state;

  void _detach(_ContinuousPageOrderViewState state) {
    if (_state == state) _state = null;
  }

  int get pageNumber => (_state?._visibleIndex ?? 0) + 1;
  int get pageCount => _state?._orderLength ?? 0;
  bool get isReady => _state?._document != null && pageCount > 0;

  Future<void> goToPage(int pageNumber) =>
      _state?._goToPage(pageNumber) ?? Future<void>.value();

  /// Scroll by a fraction of the viewport (Spec 0014 half turn amount).
  Future<bool> scrollByViewportFraction(
    double fraction, {
    required bool forward,
    required Duration duration,
  }) =>
      _state?._scrollByViewportFraction(
        fraction,
        forward: forward,
        duration: duration,
      ) ??
      Future<bool>.value(false);

  void toggleZoom() => _state?._toggleZoom();

  void _notify() => notifyListeners();
}

class _ContinuousPageOrderViewState extends State<ContinuousPageOrderView> {
  PdfDocument? _document;
  final _scrollController = ScrollController();
  int _visibleIndex = 0;
  int _orderLength = 0;
  String? _error;
  final _keys = <int, GlobalKey>{};
  final Map<int, TransformationController> _transforms = {};

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
    _orderLength = widget.pageOrder.length;
    _open();
  }

  @override
  void didUpdateWidget(covariant ContinuousPageOrderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._detach(this);
      widget.controller._attach(this);
    }
    if (oldWidget.filePath != widget.filePath) {
      _open();
    } else if (oldWidget.pageOrder != widget.pageOrder) {
      setState(() => _orderLength = widget.pageOrder.length);
      widget.controller._notify();
    }
  }

  @override
  void dispose() {
    widget.controller._detach(this);
    _scrollController.dispose();
    for (final t in _transforms.values) {
      t.dispose();
    }
    _document?.dispose();
    super.dispose();
  }

  TransformationController _transformFor(int index) {
    return _transforms.putIfAbsent(index, TransformationController.new);
  }

  void _toggleZoom() {
    if (widget.zoomLocked || widget.drawEnabled) return;
    toggleTransformationZoom(_transformFor(_visibleIndex));
    setState(() {});
    widget.controller._notify();
  }

  Future<void> _open() async {
    final previous = _document;
    setState(() {
      _error = null;
      _document = null;
      _orderLength = widget.pageOrder.length;
    });
    previous?.dispose();
    try {
      final doc = await PdfDocument.openFile(widget.filePath);
      if (!mounted) {
        doc.dispose();
        return;
      }
      setState(() => _document = doc);
      widget.controller._notify();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _goToPage(int pageNumber) async {
    final index = (pageNumber - 1).clamp(0, _orderLength - 1);
    final key = _keys[index];
    final ctx = key?.currentContext;
    if (ctx != null) {
      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 200),
        alignment: 0.1,
      );
    }
    setState(() => _visibleIndex = index);
    widget.controller._notify();
  }

  /// Returns true if the scroll offset actually changed.
  Future<bool> _scrollByViewportFraction(
    double fraction, {
    required bool forward,
    required Duration duration,
  }) async {
    if (!_scrollController.hasClients) return false;
    final position = _scrollController.position;
    final before = position.pixels;
    final delta = position.viewportDimension * fraction * (forward ? 1 : -1);
    final target = (before + delta).clamp(0.0, position.maxScrollExtent);
    if ((target - before).abs() < 0.5) return false;
    if (duration == Duration.zero) {
      _scrollController.jumpTo(target);
    } else {
      await _scrollController.animateTo(
        target,
        duration: duration,
        curve: Curves.easeOutCubic,
      );
    }
    widget.controller._notify();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(child: Text('Failed to open PDF:\n$_error'));
    }
    final doc = _document;
    if (doc == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final horizontal = widget.layoutMode == PdfLayoutMode.fitHeight;
    final twoPage = widget.layoutMode == PdfLayoutMode.twoPage;

    final scrollPhysics = widget.drawEnabled
        ? const NeverScrollableScrollPhysics()
        : null;

    if (twoPage) {
      return ListView.builder(
        controller: _scrollController,
        physics: scrollPhysics,
        itemCount: (_orderLength + 1) ~/ 2,
        itemBuilder: (context, row) {
          final left = row * 2;
          final right = left + 1;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _slot(doc, left)),
                if (right < _orderLength) ...[
                  const SizedBox(width: 8),
                  Expanded(child: _slot(doc, right)),
                ],
              ],
            ),
          );
        },
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: scrollPhysics,
      scrollDirection: horizontal ? Axis.horizontal : Axis.vertical,
      itemCount: _orderLength,
      itemBuilder: (context, index) {
        return SizedBox(
          width: horizontal ? MediaQuery.sizeOf(context).width * 0.85 : null,
          height: horizontal ? null : MediaQuery.sizeOf(context).height * 0.85,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: _slot(doc, index),
          ),
        );
      },
    );
  }

  Widget _slot(PdfDocument doc, int index) {
    final key = _keys.putIfAbsent(index, GlobalKey.new);
    return NotificationListener<ScrollNotification>(
      onNotification: (_) => false,
      child: GestureDetector(
        onTap: () {
          setState(() => _visibleIndex = index);
          widget.controller._notify();
        },
        child: KeyedSubtree(
          key: key,
          child: PerformancePageSlot(
            document: doc,
            entry: widget.pageOrder.entries[index],
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
            pageScale: widget.resolvePageScale?.call(
                  widget.pageOrder.entries[index].sourcePage,
                ) ??
                widget.pageScale,
            pageBorderEnabled: widget.pageBorderEnabled,
            pageBorderWidth: widget.pageBorderWidth,
            pageBorderColor: widget.pageBorderColor,
            transformationController: _transformFor(index),
            panEnabled: !widget.drawEnabled,
            scaleEnabled: !widget.drawEnabled && !widget.zoomLocked,
          ),
        ),
      ),
    );
  }
}
