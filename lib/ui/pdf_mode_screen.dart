import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:share_plus/share_plus.dart';
import 'package:standscore/annotation/annotation_export.dart';
import 'package:standscore/annotation/annotation_store.dart';
import 'package:standscore/annotation/draw_style.dart';
import 'package:standscore/annotation/draw_style_prefs_store.dart';
import 'package:standscore/annotation/draw_tool.dart';
import 'package:standscore/annotation/stamp.dart';
import 'package:standscore/bookmark/bookmark_store.dart';
import 'package:standscore/jumplink/jump_link.dart';
import 'package:standscore/jumplink/jump_link_geometry.dart';
import 'package:standscore/jumplink/jump_link_store.dart';
import 'package:standscore/layout/half_page.dart';
import 'package:standscore/layout/display_prefs.dart';
import 'package:standscore/layout/display_prefs_store.dart';
import 'package:standscore/layout/page_color_filter.dart';
import 'package:standscore/layout/page_color_filter_prefs_store.dart';
import 'package:standscore/layout/page_scale.dart';
import 'package:standscore/layout/page_scale_prefs_store.dart';
import 'package:standscore/layout/pdf_layout_mode.dart';
import 'package:standscore/layout/pdf_layout_prefs.dart';
import 'package:standscore/library/score.dart';
import 'package:standscore/pageorder/page_order.dart';
import 'package:standscore/pageorder/page_order_store.dart';
import 'package:standscore/pageturn/gesture_map.dart';
import 'package:standscore/pageturn/page_jump.dart';
import 'package:standscore/pageturn/page_turn_amount.dart';
import 'package:standscore/pageturn/page_turn_delay.dart';
import 'package:standscore/pageturn/page_turn_prefs.dart';
import 'package:standscore/pageturn/page_turn_prefs_store.dart';
import 'package:standscore/pageturn/pedal_key_map.dart';
import 'package:standscore/pdf/continuous_page_order_view.dart';
import 'package:standscore/pdf/half_page_view.dart';
import 'package:standscore/pdf/page_annotation_overlay.dart';
import 'package:standscore/pdf/single_page_slider.dart';
import 'package:standscore/setlist/setlist_nav.dart';
import 'package:standscore/setlist/setlist_session.dart';
import 'package:standscore/ui/bookmarks_sheet.dart';
import 'package:standscore/ui/display_sheet.dart';
import 'package:standscore/ui/draw_toolbar.dart';
import 'package:standscore/ui/jump_link_edit_sheet.dart';
import 'package:standscore/ui/jump_link_overlay.dart';
import 'package:standscore/ui/layout_settings_sheet.dart';
import 'package:standscore/ui/page_nav_bar.dart';
import 'package:standscore/ui/page_order_editor_screen.dart';
import 'package:standscore/ui/page_scale_sheet.dart';
import 'package:standscore/ui/page_turn_interaction_layer.dart';
import 'package:standscore/ui/page_turn_settings_sheet.dart';

class PdfModeScreen extends StatefulWidget {
  const PdfModeScreen({
    super.key,
    required this.score,
    required this.filePath,
    this.setlistSession,
  });

  final Score score;
  final String filePath;

  /// When non-null, PageTurn can cross Score boundaries (Spec 0012).
  final SetlistSession? setlistSession;

  @override
  State<PdfModeScreen> createState() => _PdfModeScreenState();
}

class _PdfModeScreenState extends State<PdfModeScreen> {
  late Score _score;
  late String _filePath;
  late AnnotationStore _store;
  AnnotationPersistence? _annotationPersistence;
  final PdfViewerController _controller = PdfViewerController();
  final SinglePageSliderController _sliderController =
      SinglePageSliderController();
  final HalfPageController _halfPageController = HalfPageController();
  final ContinuousPageOrderController _orderScrollController =
      ContinuousPageOrderController();
  final FocusNode _focusNode = FocusNode();
  final PageTurnDelayGate _delayGate = PageTurnDelayGate();
  PageTurnPrefsStore? _pageTurnStore;
  PdfLayoutPrefsStore? _layoutStore;
  DrawStylePrefsStore? _drawStyleStore;
  PageColorFilterPrefsStore? _colorFilterStore;
  PageScalePrefsStore? _pageScaleStore;
  DisplayPrefsStore? _displayStore;
  BookmarkStore? _bookmarkStore;
  JumpLinkStore? _jumpLinkStore;
  PageOrderStore? _pageOrderStore;
  Directory? _root;
  PageTurnPrefs _pageTurnPrefs = const PageTurnPrefs();
  PdfLayoutPrefs _layoutPrefs = const PdfLayoutPrefs();
  DrawStylePrefs _drawStyle = const DrawStylePrefs();
  PageColorFilterMode _colorFilterMode = PageColorFilterMode.off;
  PageScalePrefs _pageScalePrefs = const PageScalePrefs();
  DisplayPrefs _displayPrefs = const DisplayPrefs();
  PageOrder _pageOrder = PageOrder.identity(0);
  List<JumpLink> _jumpLinks = const [];
  double _pageAspectRatio = 1 / 1.414;
  bool _drawEnabled = false;
  DrawTool _drawTool = DrawTool.pen;
  DrawTool _lastInkTool = DrawTool.pen;
  StampKind? _pendingStamp;
  String? _pendingStampText;
  String? _selectedStampId;
  bool _annotationsVisible = true;
  bool _exporting = false;
  bool _prefsReady = false;
  int _scoreIndex = 0;
  List<int> _piecePageCounts = const [];
  final GlobalKey<PopupMenuButtonState<String>> _overflowMenuKey =
      GlobalKey<PopupMenuButtonState<String>>();

  /// Authoritative performance page for PageTurn (avoids stale controller reads).
  int _navPage = 1;

  bool get _inSetlist => widget.setlistSession != null;

  @override
  void initState() {
    super.initState();
    _score = widget.score;
    _filePath = widget.filePath;
    _store = AnnotationStore();
    final session = widget.setlistSession;
    if (session != null) {
      _scoreIndex = session.initialIndex.clamp(0, session.pieces.length - 1);
      final piece = session.pieces[_scoreIndex];
      _score = piece.score;
      _filePath = piece.filePath;
    }
    _controller.addListener(_onControllerChanged);
    _sliderController.addListener(_onControllerChanged);
    _halfPageController.addListener(_onControllerChanged);
    _orderScrollController.addListener(_onControllerChanged);
    HardwareKeyboard.instance.addHandler(_onHardwareKey);
    _loadPrefs();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onHardwareKey);
    _controller.removeListener(_onControllerChanged);
    _sliderController.removeListener(_onControllerChanged);
    _halfPageController.removeListener(_onControllerChanged);
    _orderScrollController.removeListener(_onControllerChanged);
    _sliderController.dispose();
    _halfPageController.dispose();
    _orderScrollController.dispose();
    _focusNode.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _applySystemUi() {
    final overlays = <SystemUiOverlay>[
      if (_displayPrefs.showStatusBar) SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ];
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: overlays,
    );
  }

  void _onControllerChanged() {
    // Defer: sync setState during key/focus highlight dispatch disposes InkWells
    // mid-notify → "deactivated widget's ancestor" assertion.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final fromViewer = _readViewerPage();
      if (fromViewer != null) _navPage = fromViewer;
      setState(() {});
    });
  }

  /// Page reported by the active viewer, or null if not ready.
  int? _readViewerPage() {
    if (_pageCount < 1) return null;
    if (_isSingle) {
      return _sliderController.isReady ? _sliderController.pageNumber : null;
    }
    if (_isHalfPage) {
      return _halfPageController.isReady ? _halfPageController.pageNumber : null;
    }
    if (_useCustomContinuous) {
      return _orderScrollController.isReady
          ? _orderScrollController.pageNumber
          : null;
    }
    if (!_controller.isReady) return null;
    return _controller.pageNumber;
  }

  bool _isTypingInTextField() {
    final focus = FocusManager.instance.primaryFocus;
    final ctx = focus?.context;
    if (ctx == null || !ctx.mounted) return false;
    return ctx.findAncestorStateOfType<EditableTextState>() != null;
  }

  bool _onHardwareKey(KeyEvent event) {
    // KeyRepeatEvent is not a KeyDownEvent — still treat as pedal input.
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;
    if (!_prefsReady || _drawEnabled) return false;
    if (_isTypingInTextField()) return false;
    final action = resolvePedalKeyAction(event.logicalKey);
    if (action == null) return false;
    // Microtask (not post-frame): apply immediately with optimistic _navPage.
    scheduleMicrotask(() {
      if (mounted) _applyAction(action, kind: PageTurnInputKind.pedal);
    });
    return true;
  }

  bool get _isSingle => _layoutPrefs.mode == PdfLayoutMode.single;

  bool get _isHalfPage => isHalfPageLayoutMode(_layoutPrefs.mode);

  bool get _useCustomContinuous =>
      !_isSingle &&
      !_isHalfPage &&
      !_pageOrder.isIdentity &&
      _pageOrder.length > 0;

  /// Next Setlist piece title when peeking past the last page of this Score.
  String? get _nextSetlistTitle {
    final session = widget.setlistSession;
    if (session == null) return null;
    if (_pageNumber < _pageCount) return null;
    final next = _scoreIndex + 1;
    if (next >= session.pieces.length) return null;
    return session.pieces[next].score.title;
  }

  Future<void> _loadPrefs() async {
    final docs = await getApplicationDocumentsDirectory();
    final root = Directory(p.join(docs.path, 'standscore'));
    final pageTurnStore = PageTurnPrefsStore(root: root);
    final layoutStore = PdfLayoutPrefsStore(root: root);
    final drawStyleStore = DrawStylePrefsStore(root: root);
    final colorFilterStore = PageColorFilterPrefsStore(root: root);
    final pageScaleStore = PageScalePrefsStore(root: root);
    final displayStore = DisplayPrefsStore(root: root);
    final pageTurn = await pageTurnStore.load();
    final layout = await layoutStore.load();
    final drawStyle = await drawStyleStore.load();
    final colorFilter = await colorFilterStore.load();
    final pageScale = await pageScaleStore.load();
    final display = await displayStore.load();

    List<int> pieceCounts = const [];
    final session = widget.setlistSession;
    if (session != null) {
      pieceCounts = await SetlistSession.loadPageCounts(
        root: root,
        pieces: session.pieces,
      );
    }

    if (!mounted) return;
    _root = root;
    _pageTurnStore = pageTurnStore;
    _layoutStore = layoutStore;
    _drawStyleStore = drawStyleStore;
    _colorFilterStore = colorFilterStore;
    _pageScaleStore = pageScaleStore;
    _displayStore = displayStore;
    _pageTurnPrefs = pageTurn;
    _layoutPrefs = layout;
    _drawStyle = drawStyle;
    _colorFilterMode = colorFilter;
    _pageScalePrefs = pageScale;
    _displayPrefs = display;
    _piecePageCounts = List<int>.from(pieceCounts);
    _applySystemUi();

    await _loadCurrentScorePrefs(initialPage: 1, showHint: !pageTurn.hintShown);
  }

  Future<void> _saveDisplayPrefs(DisplayPrefs prefs) async {
    setState(() => _displayPrefs = prefs);
    _applySystemUi();
    await _displayStore?.save(prefs);
  }

  Future<void> _loadCurrentScorePrefs({
    required int initialPage,
    bool showHint = false,
  }) async {
    final root = _root;
    if (root == null) return;

    final bookmarkStore = BookmarkStore(root: root, scoreId: _score.id);
    final jumpLinkStore = JumpLinkStore(root: root, scoreId: _score.id);
    final annotationPersistence =
        AnnotationPersistence(root: root, scoreId: _score.id);
    final pageOrderStore = PageOrderStore(root: root, scoreId: _score.id);
    final annotationStore = AnnotationStore();
    await annotationPersistence.loadInto(annotationStore);

    var sourceCount = 0;
    var aspect = _pageAspectRatio;
    try {
      final doc = await PdfDocument.openFile(_filePath);
      sourceCount = doc.pages.length;
      if (doc.pages.isNotEmpty) {
        final page = doc.pages.first;
        if (page.height > 0) {
          aspect = page.width / page.height;
        }
      }
      await doc.dispose();
    } catch (_) {}

    final pageOrder = await pageOrderStore.loadOrIdentity(sourceCount);
    final jumpLinks = await jumpLinkStore.list();
    final nav = clampPageNumber(initialPage, pageOrder.length);

    if (!mounted) return;
    setState(() {
      _bookmarkStore = bookmarkStore;
      _jumpLinkStore = jumpLinkStore;
      _annotationPersistence = annotationPersistence;
      _store = annotationStore;
      _pageOrderStore = pageOrderStore;
      _pageOrder = pageOrder;
      _jumpLinks = jumpLinks;
      _pageAspectRatio = aspect;
      _navPage = nav;
      _prefsReady = true;
      if (_piecePageCounts.isNotEmpty &&
          _scoreIndex >= 0 &&
          _scoreIndex < _piecePageCounts.length) {
        _piecePageCounts[_scoreIndex] = pageOrder.length;
      }
    });
    if (showHint) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showHint());
    }
    if (nav > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _jumpToPage(nav);
      });
    }
  }

  Future<void> _switchToPiece(int index, {required int page}) async {
    final session = widget.setlistSession;
    if (session == null) return;
    if (index < 0 || index >= session.pieces.length) return;
    final piece = session.pieces[index];
    setState(() {
      _prefsReady = false;
      _drawEnabled = false;
      _drawTool = DrawTool.pen;
      _pendingStamp = null;
      _pendingStampText = null;
      _selectedStampId = null;
      _annotationsVisible = true;
      _scoreIndex = index;
      _score = piece.score;
      _filePath = piece.filePath;
      _store = AnnotationStore();
      _annotationPersistence = null;
      _navPage = page;
    });
    await _loadCurrentScorePrefs(initialPage: page);
  }

  Future<void> _onAnnotationsChanged() async {
    setState(() {});
    await _annotationPersistence?.save(_store);
  }

  Future<void> _saveDrawStyle(DrawStylePrefs style) async {
    setState(() => _drawStyle = style);
    await _drawStyleStore?.save(style);
  }

  void _onDrawToolChanged(DrawTool tool) {
    setState(() {
      if (DrawToolPresets.isInkTool(tool)) {
        _lastInkTool = tool;
      }
      _drawTool = tool;
      _pendingStamp = null;
      _pendingStampText = null;
    });
  }

  void _onEyedropperColor(Color color) {
    final target =
        DrawToolPresets.isInkTool(_lastInkTool) ? _lastInkTool : DrawTool.pen;
    _saveDrawStyle(_drawStyle.withColorFor(target, color));
  }

  void _onEyedropperDone() {
    setState(() => _drawTool = _lastInkTool);
  }

  void _onStampArmed(StampKind kind, String? text) {
    setState(() {
      _pendingStamp = kind;
      _pendingStampText = text;
      _selectedStampId = null;
    });
  }

  void _onPendingStampConsumed() {
    setState(() {
      _pendingStamp = null;
      _pendingStampText = null;
    });
  }

  void _onSelectedStampChanged(String? id) {
    setState(() => _selectedStampId = id);
  }

  Future<void> _deleteSelectedStamp() async {
    final id = _selectedStampId;
    if (id == null) return;
    if (!_store.deleteStamp(id)) return;
    setState(() => _selectedStampId = null);
    await _onAnnotationsChanged();
  }

  void _setDrawEnabled(bool enabled) {
    setState(() {
      _drawEnabled = enabled;
      if (enabled) {
        // Drawing requires seeing marks (Spec 0020 G3).
        _annotationsVisible = true;
      } else {
        _pendingStamp = null;
        _pendingStampText = null;
        _selectedStampId = null;
      }
    });
  }

  Future<void> _exportAnnotatedPdf() async {
    if (_exporting || !_prefsReady) return;
    setState(() => _exporting = true);
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Exporting PDF…')));
    try {
      final doc = await PdfDocument.openFile(_filePath);
      try {
        final bytes = await const AnnotationExporter().exportBytes(
          document: doc,
          store: _store,
        );
        final rawTitle = _score.title.replaceAll(RegExp(r'[^\w\-]+'), '_');
        final safeTitle = rawTitle.isEmpty
            ? 'score'
            : rawTitle.substring(0, rawTitle.length > 40 ? 40 : rawTitle.length);
        final exportsDir = Directory(
          p.join((await getApplicationDocumentsDirectory()).path, 'exports'),
        );
        await exportsDir.create(recursive: true);
        final out = File(p.join(exportsDir.path, '${safeTitle}_annotated.pdf'));
        await out.writeAsBytes(bytes, flush: true);

        // Share sheet needs a full app restart after adding share_plus
        // (hot reload is not enough). Fall back to saved file if unavailable.
        try {
          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(out.path, mimeType: 'application/pdf')],
              subject: '${_score.title} (annotated)',
            ),
          );
          if (!mounted) return;
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Export ready — share sheet opened')),
            );
        } on MissingPluginException {
          if (!mounted) return;
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  'Exported to ${out.path}. Fully restart the app '
                  '(stop + flutter run) to enable the share sheet.',
                ),
                duration: const Duration(seconds: 6),
              ),
            );
        }
      } finally {
        doc.dispose();
      }
    } catch (e) {
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Export failed: $e')));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _savePageTurnPrefs(PageTurnPrefs prefs) async {
    setState(() => _pageTurnPrefs = prefs);
    await _pageTurnStore?.save(prefs);
  }

  Future<void> _saveLayoutPrefs(PdfLayoutPrefs prefs) async {
    setState(() => _layoutPrefs = prefs);
    await _layoutStore?.save(prefs);
    if (_controller.isReady) {
      _controller.invalidate();
    }
  }

  Future<void> _savePageOrder(PageOrder order) async {
    setState(() {
      _pageOrder = order;
      _navPage = _navPage.clamp(1, order.length < 1 ? 1 : order.length);
      if (_piecePageCounts.isNotEmpty &&
          _scoreIndex >= 0 &&
          _scoreIndex < _piecePageCounts.length) {
        _piecePageCounts[_scoreIndex] = order.length;
      }
    });
    await _pageOrderStore?.save(order);
  }

  Future<void> _openPageOrderEditor() async {
    _focusNode.unfocus();
    final result = await Navigator.of(context).push<PageOrder>(
      MaterialPageRoute(
        builder: (_) => PageOrderEditorScreen(initial: _pageOrder),
      ),
    );
    if (result != null) {
      await _savePageOrder(result);
    }
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  Future<void> _showSetlistJumpSheet() async {
    final session = widget.setlistSession;
    if (session == null) return;
    final chosen = await showModalBottomSheet<int>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    session.setlist.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.5,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: session.pieces.length,
                  itemBuilder: (context, index) {
                    final piece = session.pieces[index];
                    final selected = index == _scoreIndex;
                    return ListTile(
                      leading: Text('${index + 1}.'),
                      title: Text(piece.score.title),
                      trailing: selected
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () => Navigator.pop(context, index),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    if (chosen == null || !mounted) return;
    if (chosen == _scoreIndex) {
      await _jumpToPage(1);
      return;
    }
    await _switchToPiece(chosen, page: 1);
  }

  void _onOverflowSelected(String value) {
    switch (value) {
      case 'bookmarks':
        if (_bookmarkStore == null) return;
        showBookmarksSheet(
          context: context,
          store: _bookmarkStore!,
          currentPage: _pageNumber,
          onJumpToPage: _jumpToPage,
        );
      case 'add_jump_link':
        _addJumpLink();
      case 'layout':
        showLayoutSettingsSheet(
          context: context,
          prefs: _layoutPrefs,
          onChanged: _saveLayoutPrefs,
        );
      case 'page_turn':
        showPageTurnSettingsSheet(
          context: context,
          prefs: _pageTurnPrefs,
          onChanged: _savePageTurnPrefs,
        );
      case 'page_order':
        _openPageOrderEditor();
      case 'toggle_annotations':
        setState(() => _annotationsVisible = !_annotationsVisible);
      case 'export_annotated':
        _exportAnnotatedPdf();
      case 'color_filter':
        _pickColorFilter();
      case 'page_scale':
        _pickPageScale();
      case 'display':
        _pickDisplay();
    }
  }

  Future<void> _pickDisplay() async {
    await showDisplaySheet(
      context: context,
      prefs: _displayPrefs,
      onChanged: _saveDisplayPrefs,
    );
  }

  int? get _currentSourcePage {
    final index = _pageNumber - 1;
    if (index < 0 || index >= _pageOrder.entries.length) return null;
    return _pageOrder.entries[index].sourcePage;
  }

  double _resolvePageScale(int? sourcePage) {
    return _pageScalePrefs.resolve(
      scoreId: _score.id,
      sourcePage: sourcePage,
    );
  }

  Future<void> _pickPageScale() async {
    await showPageScaleSheet(
      context: context,
      prefs: _pageScalePrefs,
      scoreId: _score.id,
      sourcePage: _currentSourcePage,
      onChanged: (prefs) async {
        setState(() => _pageScalePrefs = prefs);
        await _pageScaleStore?.save(prefs);
      },
    );
  }

  Future<void> _pickColorFilter() async {
    final selected = await showModalBottomSheet<PageColorFilterMode>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  'Color filter',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final mode in PageColorFilterMode.values)
                ListTile(
                  title: Text(mode.label),
                  trailing: _colorFilterMode == mode
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.pop(context, mode),
                ),
            ],
          ),
        );
      },
    );
    if (selected == null) return;
    setState(() => _colorFilterMode = selected);
    await _colorFilterStore?.save(selected);
  }

  Future<void> _reloadJumpLinks() async {
    final store = _jumpLinkStore;
    if (store == null) return;
    final links = await store.list();
    if (!mounted) return;
    setState(() => _jumpLinks = links);
  }

  Future<void> _addJumpLink() async {
    if (_jumpLinkStore == null || _pageCount < 1) return;
    final result = await showJumpLinkEditor(
      context: context,
      pageCount: _pageCount,
      originPage: _pageNumber,
    );
    if (result == null || result.action != JumpLinkEditAction.save) return;
    final draft = result.link!;
    await _jumpLinkStore!.add(
      originPage: draft.originPage,
      destinationPage: draft.destinationPage,
      normRect: draft.normRect,
      colorValue: draft.colorValue,
    );
    await _reloadJumpLinks();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Drag the button to a clear spot. Long-press to edit.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _editJumpLink(JumpLink link) async {
    if (_jumpLinkStore == null || _pageCount < 1) return;
    final result = await showJumpLinkEditor(
      context: context,
      pageCount: _pageCount,
      originPage: link.originPage,
      existing: link,
    );
    if (result == null) return;
    if (result.action == JumpLinkEditAction.delete) {
      await _jumpLinkStore!.delete(link.id);
    } else {
      await _jumpLinkStore!.update(result.link!);
    }
    await _reloadJumpLinks();
  }

  Future<void> _activateJumpLink(JumpLink link) async {
    final dest = clampJumpDestination(link.destinationPage, _pageCount);
    await _jumpToPage(dest);
  }

  Rect _jumpLinkPageRect(Size viewSize) {
    if (_isHalfPage) {
      final pane = halfPageCurrentPaneRect(
        viewerSize: viewSize,
        layoutMode: _layoutPrefs.mode,
        separatorRatio: _layoutPrefs.halfPageSeparatorRatio,
        reverseHorizontal: _pageTurnPrefs.reverseDirection,
      );
      return fittedPageRect(pane.size, _pageAspectRatio).shift(pane.topLeft);
    }
    return fittedPageRect(viewSize, _pageAspectRatio);
  }

  void _replaceJumpLink(JumpLink link) {
    setState(() {
      _jumpLinks = [
        for (final item in _jumpLinks)
          if (item.id == link.id) link else item,
      ];
    });
  }

  Future<void> _onJumpLinkMoved(JumpLink link) async {
    _replaceJumpLink(link);
    await _jumpLinkStore?.update(link);
  }

  Widget _withJumpLinkLayer(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewSize = Size(constraints.maxWidth, constraints.maxHeight);
        final links = _jumpLinks
            .where((l) => l.originPage == _pageNumber)
            .toList(growable: false);
        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            if (_prefsReady && !_drawEnabled && links.isNotEmpty)
              JumpLinkInteractiveLayer(
                pageRect: _jumpLinkPageRect(viewSize),
                links: links,
                onTap: _activateJumpLink,
                onLongPress: _editJumpLink,
                onMoveEnd: _onJumpLinkMoved,
              ),
          ],
        );
      },
    );
  }

  Future<void> _showHint() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tap the right half for next page, left for previous.'),
        duration: Duration(seconds: 4),
      ),
    );
    await _savePageTurnPrefs(_pageTurnPrefs.copyWith(hintShown: true));
  }

  bool get _atFitZoom {
    if (_isSingle || _isHalfPage || _useCustomContinuous) return true;
    if (!_controller.isReady) return true;
    return _controller.currentZoom <= _controller.minScale * 1.08;
  }

  bool get _panEnabled {
    if (_drawEnabled) return false;
    if (_atFitZoom && _pageTurnPrefs.anySwipeEnabled) return false;
    return true;
  }

  int get _pageCount => _pageOrder.length;

  int get _pageNumber {
    if (_pageCount < 1) return 1;
    return _navPage.clamp(1, _pageCount);
  }

  Future<void> _jumpToPage(int page) async {
    final count = _pageCount;
    if (count < 1) return;
    final target = clampPageNumber(page, count);
    if (target == _pageNumber) return;
    _navPage = target;
    if (_isSingle) {
      if (!_sliderController.isReady) return;
      await _sliderController.goToPage(target, duration: Duration.zero);
      return;
    }
    if (_isHalfPage) {
      if (!_halfPageController.isReady) return;
      await _halfPageController.goToPage(target, duration: Duration.zero);
      return;
    }
    if (_useCustomContinuous) {
      if (!_orderScrollController.isReady) return;
      await _orderScrollController.goToPage(target);
      return;
    }
    if (!_controller.isReady) return;
    await _controller.goToPage(pageNumber: target);
  }

  Future<void> _goToPageInCurrentScore(
    int target, {
    required Duration duration,
  }) async {
    _navPage = target;
    if (_isSingle) {
      await _sliderController.goToPage(target, duration: duration);
      return;
    }
    if (_isHalfPage) {
      await _halfPageController.goToPage(target, duration: duration);
      return;
    }
    if (_useCustomContinuous) {
      await _orderScrollController.goToPage(target);
      return;
    }
    if (_controller.isReady) {
      await _controller.goToPage(pageNumber: target);
    }
  }

  Future<void> _applyAction(
    PageTurnAction action, {
    required PageTurnInputKind kind,
  }) async {
    final now = DateTime.now();
    final delay = _pageTurnPrefs.delay;
    final scope = _pageTurnPrefs.delayScope;
    if (!_delayGate.allow(
      now: now,
      kind: kind,
      delay: delay,
      scope: scope,
    )) {
      return;
    }

    final step = resolvePageTurnStep(
      mode: _layoutPrefs.mode,
      amount: _pageTurnPrefs.turnAmount,
    );

    // Continuous half-step: scroll ~½ viewport (Spec 0014).
    if (step.kind == PageTurnStepKind.viewportFraction) {
      final moved = await _scrollByViewportFraction(
        action,
        fraction: step.viewportFraction,
      );
      if (moved) {
        _delayGate.lockAfterSuccess(
          now: now,
          kind: kind,
          delay: delay,
          scope: scope,
        );
        return;
      }
      // At scroll edge — fall through to page / Setlist boundary turn.
    }

    final pageDelta = step.kind == PageTurnStepKind.performancePages
        ? step.pageDelta
        : 1;
    final current = _pageNumber;
    final delta = action == PageTurnAction.next ? pageDelta : -pageDelta;

    if (_inSetlist && _piecePageCounts.isNotEmpty) {
      if (_scoreIndex >= 0 && _scoreIndex < _piecePageCounts.length) {
        _piecePageCounts[_scoreIndex] = _pageCount;
      }
      final nav = resolveSetlistPageTurn(
        scoreIndex: _scoreIndex,
        currentPage: current,
        delta: delta,
        pageCounts: _piecePageCounts,
      );
      if (nav == null) return;

      _delayGate.lockAfterSuccess(
        now: now,
        kind: kind,
        delay: delay,
        scope: scope,
      );

      if (nav.scoreIndex != _scoreIndex) {
        await _switchToPiece(nav.scoreIndex, page: nav.pageNumber);
        return;
      }

      await _goToPageInCurrentScore(
        nav.pageNumber,
        duration: _pageTurnPrefs.animationDuration,
      );
      return;
    }

    final target = current + delta;
    if (target < 1 || target > _pageCount) return;

    _delayGate.lockAfterSuccess(
      now: now,
      kind: kind,
      delay: delay,
      scope: scope,
    );

    await _goToPageInCurrentScore(
      target,
      duration: _pageTurnPrefs.animationDuration,
    );
  }

  /// Scroll continuous viewer by a viewport fraction. Returns false at edge.
  Future<bool> _scrollByViewportFraction(
    PageTurnAction action, {
    required double fraction,
  }) async {
    final forward = action == PageTurnAction.next;
    final duration = _pageTurnPrefs.animationDuration;

    if (_useCustomContinuous) {
      if (!_orderScrollController.isReady) return false;
      return _orderScrollController.scrollByViewportFraction(
        fraction,
        forward: forward,
        duration: duration,
      );
    }

    // Identity continuous: pdfrx PdfViewer (fit width / fit height).
    if (_isSingle || _isHalfPage) return false;
    if (!_controller.isReady) return false;

    final view = _controller.viewSize;
    final zoom = _controller.currentZoom;
    if (zoom <= 0 || view.isEmpty) return false;
    final horizontal = _layoutPrefs.mode == PdfLayoutMode.fitHeight;
    final extent = horizontal ? view.width : view.height;
    final docDelta = (extent * fraction) / zoom;
    final sign = forward ? 1.0 : -1.0;
    final center = _controller.centerPosition;
    final before = center;
    final next = horizontal
        ? Offset(center.dx + sign * docDelta, center.dy)
        : Offset(center.dx, center.dy + sign * docDelta);
    await _controller.goTo(
      _controller.calcMatrixFor(next),
      duration: duration,
    );
    final after = _controller.centerPosition;
    return (after - before).distance > 0.5;
  }

  void _onInteractionAction(PageTurnAction action, PageTurnInputKind kind) {
    if (_drawEnabled || !_prefsReady) return;
    if (kind == PageTurnInputKind.swipe && !_atFitZoom) return;
    _applyAction(action, kind: kind);
  }

  void _onGestureMapAction(GestureMapAction action) {
    if (!_prefsReady) return;
    switch (action) {
      case GestureMapAction.showChrome:
        _overflowMenuKey.currentState?.showButtonMenu();
      case GestureMapAction.enterDraw:
        if (!_drawEnabled) _setDrawEnabled(true);
      case GestureMapAction.disabled:
        break;
    }
  }

  Widget _interactionLayer() {
    // While drawing, keep PageTurn chrome off the page so ink gestures are not
    // shared with the viewer's scroll arena (which caused the score to scroll).
    // Edge GestureMap strips still work for Show menu / Draw.
    if (_drawEnabled) {
      return _drawModeEdgeGestureChrome();
    }
    return PageTurnInteractionLayer(
      prefs: _pageTurnPrefs,
      reverseHorizontal: _pageTurnPrefs.reverseDirection,
      onAction: _onInteractionAction,
      onGestureAction: _onGestureMapAction,
      pageTurnEnabled: true,
    );
  }

  /// Thin top/bottom bands only — center stays free for annotation strokes.
  Widget _drawModeEdgeGestureChrome() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final band = gestureMapEdgeBandHeight(constraints.maxHeight);
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: band,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onGestureMapAction(
                  _pageTurnPrefs.gestureMap.topEdge,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: band,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onGestureMapAction(
                  _pageTurnPrefs.gestureMap.bottomEdge,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool? _onKey(
    PdfViewerKeyHandlerParams params,
    LogicalKeyboardKey key,
    bool isRealKeyPress,
  ) {
    // Pedal keys handled by HardwareKeyboard; defer to that path.
    if (resolvePedalKeyAction(key) != null) return true;
    return null;
  }

  Widget _buildTitle() {
    if (!_inSetlist) {
      return Text(_score.title);
    }
    return InkWell(
      onTap: _prefsReady ? _showSetlistJumpSheet : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                _score.title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _wrapViewerInsets(Widget child) {
    if (!_displayPrefs.avoidNotches) return child;
    return SafeArea(top: false, child: child);
  }

  void _paintPageBorder(Canvas canvas, Rect pageRect, PdfPage page) {
    if (!_displayPrefs.borderEnabled) return;
    final paint = Paint()
      ..color = _displayPrefs.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _displayPrefs.borderWidth;
    canvas.drawRect(pageRect.deflate(_displayPrefs.borderWidth / 2), paint);
  }

  @override
  Widget build(BuildContext context) {
    final layoutMode = _layoutPrefs.mode;
    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(),
        actions: [
          // Primary: Draw (+ Undo while drawing). Everything else → ⋯
          ExcludeFocus(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_drawEnabled) ...[
                  IconButton(
                    tooltip: 'Undo',
                    onPressed: !_store.canUndo
                        ? null
                        : () async {
                            if (_store.undo()) {
                              final id = _selectedStampId;
                              if (id != null &&
                                  !_store.stamps.any((s) => s.id == id)) {
                                _selectedStampId = null;
                              }
                              await _onAnnotationsChanged();
                            }
                          },
                    icon: const Icon(Icons.undo),
                  ),
                  IconButton(
                    tooltip: 'Redo',
                    onPressed: !_store.canRedo
                        ? null
                        : () async {
                            if (_store.redo()) await _onAnnotationsChanged();
                          },
                    icon: const Icon(Icons.redo),
                  ),
                  if (_selectedStampId != null)
                    IconButton(
                      tooltip: 'Delete stamp',
                      onPressed: _deleteSelectedStamp,
                      icon: const Icon(Icons.delete_outline),
                    ),
                ],
                IconButton(
                  tooltip: _drawEnabled ? 'Exit draw' : 'Draw',
                  onPressed: () => _setDrawEnabled(!_drawEnabled),
                  icon: Icon(_drawEnabled ? Icons.edit_off : Icons.edit),
                ),
                PopupMenuButton<String>(
                  key: _overflowMenuKey,
                  tooltip: 'More',
                  enabled: _prefsReady,
                  onSelected: _onOverflowSelected,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'bookmarks',
                      child: Text('Bookmarks'),
                    ),
                    const PopupMenuItem(
                      value: 'add_jump_link',
                      child: Text('Add jump link'),
                    ),
                    PopupMenuItem(
                      value: 'toggle_annotations',
                      child: Text(
                        _annotationsVisible
                            ? 'Hide annotations'
                            : 'Show annotations',
                      ),
                    ),
                    PopupMenuItem(
                      value: 'export_annotated',
                      enabled: !_exporting,
                      child: Text(
                        _exporting
                            ? 'Exporting…'
                            : 'Export PDF with annotations',
                      ),
                    ),
                    PopupMenuItem(
                      value: 'color_filter',
                      child: Text(
                        _colorFilterMode == PageColorFilterMode.off
                            ? 'Color filter…'
                            : 'Color filter (${_colorFilterMode.label})…',
                      ),
                    ),
                    PopupMenuItem(
                      value: 'page_scale',
                      child: Text(
                        _pageScalePrefs.locked
                            ? 'Page scale (locked)…'
                            : 'Page scale…',
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'display',
                      child: Text('Display…'),
                    ),
                    const PopupMenuItem(
                      value: 'layout',
                      child: Text('Layout'),
                    ),
                    const PopupMenuItem(
                      value: 'page_turn',
                      child: Text('Page turn settings'),
                    ),
                    const PopupMenuItem(
                      value: 'page_order',
                      child: Text('Page order…'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_drawEnabled)
            DrawToolbar(
              tool: _drawTool,
              style: _drawStyle,
              onToolChanged: _onDrawToolChanged,
              onStyleChanged: _saveDrawStyle,
              pendingStamp: _pendingStamp,
              onStampArmed: _onStampArmed,
            ),
          Expanded(
            child: !_prefsReady
                ? const Center(child: CircularProgressIndicator())
                : _wrapViewerInsets(
                    _isSingle
                        ? _buildSinglePageBody()
                        : _isHalfPage
                            ? _buildHalfPageBody()
                            : _useCustomContinuous
                                ? _buildCustomContinuousBody(layoutMode)
                                : _buildContinuousBody(layoutMode),
                  ),
          ),
          if (_prefsReady && _pageCount > 0)
            PageNavBar(
              pageNumber: _pageNumber,
              pageCount: _pageCount,
              onJumpToPage: _jumpToPage,
              avoidNotches: _displayPrefs.avoidNotches,
            ),
        ],
      ),
    );
  }

  Widget _buildSinglePageBody() {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      child: _withJumpLinkLayer(
        Stack(
          fit: StackFit.expand,
          children: [
            SinglePageSlider(
              key: ValueKey(
                'single-${_score.id}-$_filePath-${_pageOrder.hashCode}',
              ),
              filePath: _filePath,
              pageOrder: _pageOrder,
              store: _store,
              drawEnabled: _drawEnabled,
              drawTool: _drawTool,
              drawStyle: _drawStyle,
              onDrawStyleChanged: _onEyedropperColor,
              onEyedropperDone: _onEyedropperDone,
              pendingStamp: _pendingStamp,
              pendingStampText: _pendingStampText,
              onPendingStampConsumed: _onPendingStampConsumed,
              selectedStampId: _selectedStampId,
              onSelectedStampChanged: _onSelectedStampChanged,
              annotationsVisible: _annotationsVisible,
              colorFilterMode: _colorFilterMode,
              pageScale: _resolvePageScale(_currentSourcePage),
              zoomLocked: _pageScalePrefs.locked,
              resolvePageScale: _resolvePageScale,
              pageBorderEnabled: _displayPrefs.borderEnabled,
              pageBorderWidth: _displayPrefs.borderWidth,
              pageBorderColor: _displayPrefs.borderColor,
              onAnnotateChanged: _onAnnotationsChanged,
              controller: _sliderController,
              allowUserScroll: false,
              reverseDirection: _pageTurnPrefs.reverseDirection,
            ),
            _interactionLayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHalfPageBody() {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      child: _withJumpLinkLayer(
        HalfPageView(
          key: ValueKey(
            'half-${_layoutPrefs.mode.name}-${_score.id}-'
            '$_filePath-${_pageOrder.hashCode}',
          ),
          filePath: _filePath,
          pageOrder: _pageOrder,
          layoutMode: _layoutPrefs.mode,
          separatorRatio: _layoutPrefs.halfPageSeparatorRatio,
          onSeparatorRatioChanged: (ratio) {
            _saveLayoutPrefs(
              _layoutPrefs.copyWith(halfPageSeparatorRatio: ratio),
            );
          },
          store: _store,
          drawEnabled: _drawEnabled,
          drawTool: _drawTool,
          drawStyle: _drawStyle,
          onDrawStyleChanged: _onEyedropperColor,
          onEyedropperDone: _onEyedropperDone,
          pendingStamp: _pendingStamp,
          pendingStampText: _pendingStampText,
          onPendingStampConsumed: _onPendingStampConsumed,
          selectedStampId: _selectedStampId,
          onSelectedStampChanged: _onSelectedStampChanged,
          annotationsVisible: _annotationsVisible,
          colorFilterMode: _colorFilterMode,
          pageScale: _resolvePageScale(_currentSourcePage),
          zoomLocked: _pageScalePrefs.locked,
          resolvePageScale: _resolvePageScale,
          pageBorderEnabled: _displayPrefs.borderEnabled,
          pageBorderWidth: _displayPrefs.borderWidth,
          pageBorderColor: _displayPrefs.borderColor,
          onAnnotateChanged: _onAnnotationsChanged,
          controller: _halfPageController,
          reverseHorizontal: _pageTurnPrefs.reverseDirection,
          nextSetlistTitle: _nextSetlistTitle,
          initialPage: _pageNumber,
          // Full viewer so left/top tap zones still mean previous (peek sits there).
          viewerOverlay: _interactionLayer(),
        ),
      ),
    );
  }

  Widget _buildCustomContinuousBody(PdfLayoutMode layoutMode) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      child: _withJumpLinkLayer(
        Stack(
          fit: StackFit.expand,
          children: [
            ContinuousPageOrderView(
              key: ValueKey(
                'cont-${_score.id}-${layoutMode.name}-${_pageOrder.hashCode}',
              ),
              filePath: _filePath,
              pageOrder: _pageOrder,
              layoutMode: layoutMode,
              store: _store,
              drawEnabled: _drawEnabled,
              drawTool: _drawTool,
              drawStyle: _drawStyle,
              onDrawStyleChanged: _onEyedropperColor,
              onEyedropperDone: _onEyedropperDone,
              pendingStamp: _pendingStamp,
              pendingStampText: _pendingStampText,
              onPendingStampConsumed: _onPendingStampConsumed,
              selectedStampId: _selectedStampId,
              onSelectedStampChanged: _onSelectedStampChanged,
              annotationsVisible: _annotationsVisible,
              colorFilterMode: _colorFilterMode,
              pageScale: _resolvePageScale(_currentSourcePage),
              zoomLocked: _pageScalePrefs.locked,
              resolvePageScale: _resolvePageScale,
              pageBorderEnabled: _displayPrefs.borderEnabled,
              pageBorderWidth: _displayPrefs.borderWidth,
              pageBorderColor: _displayPrefs.borderColor,
              onAnnotateChanged: _onAnnotationsChanged,
              controller: _orderScrollController,
            ),
            _interactionLayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildContinuousBody(PdfLayoutMode layoutMode) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      child: _withJumpLinkLayer(
        PageColorFiltered(
          mode: _colorFilterMode,
          child: PdfViewer.file(
            _filePath,
            key: ValueKey(
              '${_score.id}-$layoutMode-'
              '${_displayPrefs.borderEnabled}-'
              '${_displayPrefs.borderWidth}-'
              '${_displayPrefs.borderColorValue}',
            ),
            controller: _controller,
            params: PdfViewerParams(
              panEnabled: _panEnabled,
              scaleEnabled: !_drawEnabled && !_pageScalePrefs.locked,
              scrollPhysics: _drawEnabled
                  ? const NeverScrollableScrollPhysics()
                  : null,
              layoutPages: layoutPagesFor(layoutMode),
              pageAnchor: PdfPageAnchor.top,
              onKey: _onKey,
              keyHandlerParams: const PdfViewerKeyHandlerParams(
                autofocus: true,
              ),
              pagePaintCallbacks: [_paintPageBorder],
              viewerOverlayBuilder: (context, size, handleLinkTap) {
                return [_interactionLayer()];
              },
              pageOverlaysBuilder: (context, pageRect, page) {
                return [
                  PageAnnotationOverlay(
                    pageRect: pageRect,
                    page: page,
                    store: _store,
                    drawEnabled: _drawEnabled,
                    tool: _drawTool,
                    style: _drawStyle,
                    onStyleChanged: _onEyedropperColor,
                    onEyedropperDone: _onEyedropperDone,
                    pendingStamp: _pendingStamp,
                    pendingStampText: _pendingStampText,
                    onPendingStampConsumed: _onPendingStampConsumed,
                    selectedStampId: _selectedStampId,
                    onSelectedStampChanged: _onSelectedStampChanged,
                    annotationsVisible: _annotationsVisible,
                    onChanged: _onAnnotationsChanged,
                  ),
                ];
              },
            ),
          ),
        ),
      ),
    );
  }
}
