import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stagescore/annotation/all_pages_notes.dart';
import 'package:stagescore/annotation/annotation_export.dart';
import 'package:stagescore/annotation/annotation_store.dart';
import 'package:stagescore/annotation/draw_style.dart';
import 'package:stagescore/annotation/draw_style_prefs_store.dart';
import 'package:stagescore/annotation/draw_tool.dart';
import 'package:stagescore/annotation/stamp.dart';
import 'package:stagescore/bookmark/bookmark_store.dart';
import 'package:stagescore/jumplink/jump_link.dart';
import 'package:stagescore/jumplink/jump_link_geometry.dart';
import 'package:stagescore/jumplink/jump_link_store.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/layout/display_prefs.dart';
import 'package:stagescore/layout/display_prefs_store.dart';
import 'package:stagescore/layout/layout_fit.dart';
import 'package:stagescore/layout/page_color_filter.dart';
import 'package:stagescore/layout/page_color_filter_prefs_store.dart';
import 'package:stagescore/layout/page_scale.dart';
import 'package:stagescore/layout/page_scale_prefs_store.dart';
import 'package:stagescore/layout/pdf_fit_zoom.dart';
import 'package:stagescore/layout/pdf_layout_mode.dart';
import 'package:stagescore/layout/pdf_layout_prefs.dart';
import 'package:stagescore/layout/stage_preset.dart';
import 'package:stagescore/library/library_root.dart';
import 'package:stagescore/library/score.dart';
import 'package:stagescore/metronome/metronome_engine.dart';
import 'package:stagescore/metronome/metronome_prefs.dart';
import 'package:stagescore/metronome/metronome_prefs_store.dart';
import 'package:stagescore/pageorder/page_order.dart';
import 'package:stagescore/pageorder/page_order_store.dart';
import 'package:stagescore/pageturn/gesture_map.dart';
import 'package:stagescore/pageturn/layout_navigation.dart';
import 'package:stagescore/pageturn/page_jump.dart';
import 'package:stagescore/pageturn/page_turn_amount.dart';
import 'package:stagescore/pageturn/page_turn_delay.dart';
import 'package:stagescore/pageturn/page_turn_prefs.dart';
import 'package:stagescore/pageturn/page_turn_prefs_store.dart';
import 'package:stagescore/pageturn/pedal_key_map.dart';
import 'package:stagescore/pdf/continuous_page_order_view.dart';
import 'package:stagescore/pdf/page_annotation_overlay.dart';
import 'package:stagescore/pdf/pdf_surface.dart';
import 'package:stagescore/pdf/single_page_slider.dart';
import 'package:stagescore/setlist/setlist_nav.dart';
import 'package:stagescore/setlist/setlist_session.dart';
import 'package:stagescore/theme/app_tokens.dart';
import 'package:stagescore/ui/beat_strip.dart';
import 'package:stagescore/ui/bookmarks_sheet.dart';
import 'package:stagescore/ui/display_sheet.dart';
import 'package:stagescore/ui/draw_toolbar.dart';
import 'package:stagescore/ui/jump_link_edit_sheet.dart';
import 'package:stagescore/ui/jump_link_overlay.dart';
import 'package:stagescore/ui/jump_links_sheet.dart';
import 'package:stagescore/ui/layout_settings_sheet.dart';
import 'package:stagescore/ui/metronome_sheet.dart';
import 'package:stagescore/ui/page_nav_bar.dart';
import 'package:stagescore/ui/page_order_editor_screen.dart';
import 'package:stagescore/ui/page_position_pill.dart';
import 'package:stagescore/ui/page_scale_sheet.dart';
import 'package:stagescore/ui/page_turn_interaction_layer.dart';
import 'package:stagescore/ui/page_turn_settings_sheet.dart';
import 'package:stagescore/ui/performance_chrome.dart';
import 'package:stagescore/ui/quick_bar_fit.dart';
import 'package:stagescore/ui/score_menu.dart';
import 'package:stagescore/ui/score_menu_quick_bar.dart';
import 'package:stagescore/ui/score_menu_sheet.dart';
import 'package:stagescore/ui/undo_snack_bar.dart';

/// Height of the PdfMode AppBar, above the status-bar inset.
const double kPdfAppBarHeight = 64;

/// How long to let pdfrx settle its own matrix after the viewport changes
/// before re-fitting on top of it.
const Duration kRefitDelay = Duration(milliseconds: 200);

class PdfModeScreen extends StatefulWidget {
  const PdfModeScreen({
    super.key,
    required this.score,
    required this.filePath,
    this.setlistSession,
    this.originLine,
    this.pieceScoreIds = const [],
  });

  final Score score;
  final String filePath;

  /// When non-null, PageTurn can cross Score boundaries (Spec 0012).
  final SetlistSession? setlistSession;

  /// "Pages 12–19 of Chopin Etudes.pdf" for one piece of a book, null for a
  /// Score that is a whole file (Spec 0052).
  ///
  /// Passed in rather than looked up: this screen never holds a `ScoreLibrary`,
  /// and the file name a musician recognises is the one the PDF came in with,
  /// not the uuid it is stored under.
  final String? originLine;

  /// Child Score ids when this screen opened a whole-file root (Spec 0055).
  ///
  /// Empty for ordinary Scores and for children. Non-empty enables the
  /// session-only *Show piece notes* toggle on all-pages.
  final List<String> pieceScoreIds;

  @override
  State<PdfModeScreen> createState() => _PdfModeScreenState();
}

class _PdfModeScreenState extends State<PdfModeScreen> {
  late Score _score;
  late String _filePath;
  String? _originLine;
  late AnnotationStore _store;
  AnnotationPersistence? _annotationPersistence;
  final PdfViewerController _controller = PdfViewerController();
  final SinglePageSliderController _sliderController =
      SinglePageSliderController();
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
  MetronomePrefsStore? _metronomeStore;
  final MetronomeEngine _metronome = MetronomeEngine();

  /// Mirror of [MetronomeEngine.isRunning], so a beat can be told apart from a
  /// start or a stop — see [_onMetronomeChanged].
  bool _metronomeRunning = false;
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
  bool _showPieceNotes = false;
  AnnotationStore? _pieceNotesUnion;
  bool _exporting = false;
  bool _prefsReady = false;
  int _scoreIndex = 0;
  List<int> _piecePageCounts = const [];

  bool get _canShowPieceNotes => widget.pieceScoreIds.isNotEmpty;

  /// What the overlay paints: root only, or root + children when toggled.
  AnnotationStore get _overlayStore =>
      _showPieceNotes ? (_pieceNotesUnion ?? _store) : _store;

  /// Authoritative performance page for PageTurn (avoids stale controller reads).
  int _navPage = 1;

  bool get _inSetlist => widget.setlistSession != null;

  /// PerformanceMode chrome (Spec 0034). Pinned while a menu, sheet or dialog
  /// opened from the chrome is on screen.
  late final PerformanceChrome _chrome = PerformanceChrome(
    isPinned: () => mounted && ModalRoute.of(context)?.isCurrent == false,
  );

  @override
  void initState() {
    super.initState();
    _score = widget.score;
    _filePath = widget.filePath;
    _originLine = widget.originLine;
    _store = AnnotationStore();
    final session = widget.setlistSession;
    if (session != null) {
      _scoreIndex = session.initialIndex.clamp(0, session.pieces.length - 1);
      final piece = session.pieces[_scoreIndex];
      _score = piece.score;
      _filePath = piece.filePath;
      _originLine = piece.originLine;
    }
    _controller.addListener(_onControllerChanged);
    _sliderController.addListener(_onControllerChanged);
    _orderScrollController.addListener(_onControllerChanged);
    HardwareKeyboard.instance.addHandler(_onHardwareKey);
    _metronome.addListener(_onMetronomeChanged);
    _chrome.addListener(_onChromeChanged);
    _loadPrefs();
  }

  /// Only a start or a stop reaches the screen.
  ///
  /// This used to be a bare `setState`, which rebuilt the whole screen — PDF
  /// viewer included — on every beat: over three times a second at 200 BPM,
  /// while the musician is playing. What actually changes per beat is the
  /// metronome glyph's tint and the beat strip, and each of those listens to
  /// the engine itself (Spec 0030 reopen, decision 4).
  void _onMetronomeChanged() {
    final running = _metronome.isRunning;
    if (!mounted || running == _metronomeRunning) return;
    setState(() => _metronomeRunning = running);
  }

  @override
  void dispose() {
    _chrome.removeListener(_onChromeChanged);
    _chrome.dispose();
    HardwareKeyboard.instance.removeHandler(_onHardwareKey);
    _metronome.removeListener(_onMetronomeChanged);
    _metronome.dispose();
    _controller.removeListener(_onControllerChanged);
    _sliderController.removeListener(_onControllerChanged);
    _orderScrollController.removeListener(_onControllerChanged);
    _sliderController.dispose();
    _orderScrollController.dispose();
    _focusNode.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onChromeChanged() {
    if (mounted) setState(() {});
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

  /// What this screen can afford, refreshed from MediaQuery on every build so
  /// a rotation is the only thing that has to change it (Spec 0041).
  LayoutFit _fit = const LayoutFit(viewSize: Size.zero);

  /// The last layout the musician was told about, so a re-resolve announces
  /// itself once and a deliberate pick never does.
  PdfLayoutMode? _announcedLayout;
  int _layoutNoticeSeq = 0;
  String? _layoutNotice;

  /// The layout actually drawn: what was picked, through what fits.
  PdfLayoutMode get _layoutMode =>
      resolveLayoutMode(stored: _layoutPrefs.mode, fit: _fit);

  bool get _isSingle => _layoutMode == PdfLayoutMode.single;

  bool get _useCustomContinuous =>
      !_isSingle && !_pageOrder.isIdentity && _pageOrder.length > 0;

  Future<void> _loadPrefs() async {
    final root = await openLibraryRoot();
    final pageTurnStore = PageTurnPrefsStore(root: root);
    final layoutStore = PdfLayoutPrefsStore(root: root);
    final drawStyleStore = DrawStylePrefsStore(root: root);
    final colorFilterStore = PageColorFilterPrefsStore(root: root);
    final pageScaleStore = PageScalePrefsStore(root: root);
    final displayStore = DisplayPrefsStore(root: root);
    final metronomeStore = MetronomePrefsStore(root: root);
    final pageTurn = await pageTurnStore.load();
    final layout = await layoutStore.load();
    final drawStyle = await drawStyleStore.load();
    final colorFilter = await colorFilterStore.load();
    final pageScale = await pageScaleStore.load();
    final display = await displayStore.load();
    final metronomePrefs = await metronomeStore.load();

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
    _metronomeStore = metronomeStore;
    _pageTurnPrefs = pageTurn;
    _layoutPrefs = layout;
    _announcedLayout = null;
    _drawStyle = drawStyle;
    _colorFilterMode = colorFilter;
    _pageScalePrefs = pageScale;
    _displayPrefs = display;
    // Scores open with the chrome hidden, except the very first one: it keeps
    // the chrome up long enough to learn the reveal gesture (Spec 0034).
    final introduceChrome =
        display.performanceMode && !display.performanceHintShown;
    _chrome.setPerformanceMode(
      display.performanceMode,
      keepChromeUp: introduceChrome,
    );
    _piecePageCounts = List<int>.from(pieceCounts);
    await _metronome.updatePrefs(metronomePrefs);
    _applySystemUi();
    if (introduceChrome) {
      _displayPrefs = display.copyWith(performanceHintShown: true);
      unawaited(displayStore.save(_displayPrefs));
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showPerformanceHint(),
      );
    }

    await _loadCurrentScorePrefs(initialPage: 1, showHint: !pageTurn.hintShown);
  }

  Future<void> _saveMetronomePrefs(MetronomePrefs prefs) async {
    await _metronome.updatePrefs(prefs);
    await _metronomeStore?.save(prefs);
    if (mounted) setState(() {});
  }

  Future<void> _openMetronome() async {
    await showMetronomeSheet(
      context: context,
      engine: _metronome,
      onPrefsChanged: _saveMetronomePrefs,
    );
  }

  Future<void> _saveDisplayPrefs(DisplayPrefs prefs) async {
    setState(() => _displayPrefs = prefs);
    _applySystemUi();
    _chrome.setPerformanceMode(prefs.performanceMode);
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
    final annotationPersistence = AnnotationPersistence(
      root: root,
      scoreId: _score.id,
    );
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

    // The Score's own pages, which are the whole file only while it is the only
    // Score on it (Spec 0052). Read off the file just opened rather than the
    // manifest, because the file is what the viewer is about to render.
    final extent = _score.extentIn(sourceCount);
    final pageOrder = await pageOrderStore.loadOrIdentity(
      extent?.length ?? 0,
      sourceFirstPage: extent?.firstPage ?? 1,
    );
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
      // The layout that arrives with the prefs is the one this Score opens
      // with, not a re-resolve to explain (Spec 0041).
      _announcedLayout = null;
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
      _originLine = piece.originLine;
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
    final target = DrawToolPresets.isInkTool(_lastInkTool)
        ? _lastInkTool
        : DrawTool.pen;
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

  Future<void> _undo() async {
    if (!_store.undo()) return;
    final id = _selectedStampId;
    if (id != null && !_store.stamps.any((s) => s.id == id)) {
      _selectedStampId = null;
    }
    await _onAnnotationsChanged();
  }

  Future<void> _redo() async {
    if (!_store.redo()) return;
    await _onAnnotationsChanged();
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
      // Piece-notes view is read-only: turning Draw on drops the toggle
      // rather than writing into a child store from all-pages (Spec 0055).
      if (enabled && _showPieceNotes) {
        _showPieceNotes = false;
        _pieceNotesUnion = null;
      }
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
    // Chrome is laid out and pinned for the whole Draw session (0034).
    _chrome.setDrawing(enabled);
  }

  Future<void> _setShowPieceNotes(bool show) async {
    if (!_canShowPieceNotes) return;
    if (!show) {
      setState(() {
        _showPieceNotes = false;
        _pieceNotesUnion = null;
      });
      return;
    }
    final root = _root;
    if (root == null) return;
    final union = await buildAllPagesNotesUnion(
      root: root,
      rootStore: _store,
      pieceScoreIds: widget.pieceScoreIds,
    );
    if (!mounted) return;
    setState(() {
      _showPieceNotes = true;
      _pieceNotesUnion = union;
      if (_drawEnabled) {
        _drawEnabled = false;
        _pendingStamp = null;
        _pendingStampText = null;
        _selectedStampId = null;
      }
    });
    _chrome.setDrawing(false);
  }

  Future<void> _exportAnnotatedPdf() async {
    if (_exporting || !_prefsReady) return;
    setState(() => _exporting = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(l10n.pdfModeScreenExporting)),
      );
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
            : rawTitle.substring(
                0,
                rawTitle.length > 40 ? 40 : rawTitle.length,
              );
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
              SnackBar(content: Text(l10n.pdfModeScreenExportReady)),
            );
        } on MissingPluginException {
          if (!mounted) return;
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  l10n.pdfModeScreenExportRestartHint(out.path),
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
        ..showSnackBar(
          SnackBar(content: Text(l10n.pdfModeScreenExportFailed('$e'))),
        );
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
    // The musician just chose this; the pill is for when the screen chooses.
    _announcedLayout = _layoutMode;
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
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
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
                      leading: Text(
                        AppLocalizations.of(context).pdfModeScreenPieceIndex(index + 1),
                      ),
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

  /// The four ScoreMenu groups 0035 built, rebuilt fresh on every open so the
  /// sheet always shows current state (Layout, Color filter, Page scale…).
  List<ScoreMenuGroup> _scoreMenuGroups() => buildScoreMenu(
    l10n: AppLocalizations.of(context),
    layoutMode: _layoutPrefs.mode,
    resolvedLayout: _layoutMode,
    colorFilter: _colorFilterMode,
    zoomLocked: _pageScalePrefs.locked,
    annotationsVisible: _annotationsVisible,
    exporting: _exporting,
    metronomeRunning: _metronome.isRunning,
    stagePreset: StagePreset.directionFor(
      display: _displayPrefs,
      scale: _pageScalePrefs,
    ),
  );

  /// Opens the full ScoreMenu — all four groups, exactly as 0035 built it.
  ///
  /// Spec 0043 replaced this `⋯` with an always-visible tab-strip, then the
  /// Orchestrator reversed that call the same day it was built: a fixed
  /// tab-strip's labels are sized for English, and a longer translation on a
  /// row that must fit four tabs on the narrowest supported phone is a
  /// layout that breaks the day the app is localised, not a hypothetical.
  /// `⋯` is back to holding everything, unconditionally.
  Future<void> _openScoreMenu() async {
    final action = await showScoreMenu(
      context: context,
      groups: _scoreMenuGroups(),
      subtitle: _originLine,
    );
    if (!mounted) return;
    // Reading the menu counts as interaction, whether or not it led anywhere.
    _chrome.keepAlive();
    if (action != null) _onScoreMenuSelected(action);
  }

  /// Same dispatch as picking the action out of a sheet, for a tap that
  /// skipped the sheet entirely (Spec 0043's ScoreMenuQuickBar).
  void _onQuickBarSelected(ScoreMenuAction action) {
    _chrome.keepAlive();
    _onScoreMenuSelected(action);
  }

  void _onScoreMenuSelected(ScoreMenuAction action) {
    switch (action) {
      case ScoreMenuAction.bookmarks:
        if (_bookmarkStore == null) return;
        showBookmarksSheet(
          context: context,
          store: _bookmarkStore!,
          currentPage: _pageNumber,
          onJumpToPage: _jumpToPage,
        );
      case ScoreMenuAction.jumpLinks:
        _showJumpLinks();
      case ScoreMenuAction.layout:
        showLayoutSettingsSheet(
          context: context,
          prefs: _layoutPrefs,
          pageTurnPrefs: _pageTurnPrefs,
          onChanged: _saveLayoutPrefs,
          onOpenPageTurnSettings: _openPageTurnSettings,
        );
      case ScoreMenuAction.pageTurnSettings:
        _openPageTurnSettings();
      case ScoreMenuAction.pageOrder:
        _openPageOrderEditor();
      case ScoreMenuAction.toggleAnnotations:
        setState(() => _annotationsVisible = !_annotationsVisible);
      case ScoreMenuAction.exportAnnotated:
        _exportAnnotatedPdf();
      case ScoreMenuAction.colorFilter:
        _pickColorFilter();
      case ScoreMenuAction.pageScale:
        _pickPageScale();
      case ScoreMenuAction.display:
        _pickDisplay();
      case ScoreMenuAction.metronome:
        _openMetronome();
      case ScoreMenuAction.stagePreset:
        _applyStagePreset();
    }
  }

  void _openPageTurnSettings() {
    showPageTurnSettingsSheet(
      context: context,
      prefs: _pageTurnPrefs,
      onChanged: _savePageTurnPrefs,
      layoutMode: _layoutMode,
    );
  }

  /// Set the app up to play, or back to practise (Spec 0036).
  ///
  /// An action, not a mode: it writes the same prefs the Display and Page
  /// scale sheets write, and Undo holds the previous values only for as long
  /// as the snackbar is up.
  Future<void> _applyStagePreset() async {
    final direction = StagePreset.directionFor(
      display: _displayPrefs,
      scale: _pageScalePrefs,
    );
    final beforeDisplay = _displayPrefs;
    final beforeScale = _pageScalePrefs;
    final afterDisplay = StagePreset.applyToDisplay(beforeDisplay, direction);
    final afterScale = StagePreset.applyToScale(beforeScale, direction);
    final changes = StagePreset.changes(
      l10n: AppLocalizations.of(context),
      beforeDisplay: beforeDisplay,
      beforeScale: beforeScale,
      afterDisplay: afterDisplay,
      afterScale: afterScale,
    );

    await _applyStageSettings(afterDisplay, afterScale);
    if (!mounted || changes.isEmpty) return;
    ScaffoldMessenger.of(context)
      // Two presets in a row must not queue two four-second messages over the
      // Score.
      ..hideCurrentSnackBar()
      ..showSnackBar(
        undoSnackBar(
          l10n: AppLocalizations.of(context),
          message: changes.join(' · '),
          onUndo: () => _applyStageSettings(beforeDisplay, beforeScale),
        ),
      );
  }

  Future<void> _applyStageSettings(
    DisplayPrefs display,
    PageScalePrefs scale,
  ) async {
    await _saveDisplayPrefs(display);
    if (!mounted) return;
    setState(() => _pageScalePrefs = scale);
    await _pageScaleStore?.save(scale);
  }

  Future<void> _pickDisplay() async {
    await showDisplaySheet(
      context: context,
      prefs: _displayPrefs,
      onChanged: _saveDisplayPrefs,
      performanceModeHint: gestureMapRevealHint(
        AppLocalizations.of(context),
        _pageTurnPrefs.gestureMap,
      ),
    );
  }

  int? get _currentSourcePage {
    final index = _pageNumber - 1;
    if (index < 0 || index >= _pageOrder.entries.length) return null;
    return _pageOrder.entries[index].sourcePage;
  }

  double _resolvePageScale(int? sourcePage) {
    return _pageScalePrefs.resolve(scoreId: _score.id, sourcePage: sourcePage);
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
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  l10n.pdfModeScreenColorFilterTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final mode in PageColorFilterMode.values)
                ListTile(
                  title: Text(mode.label(l10n)),
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

  Future<void> _showJumpLinks() async {
    final store = _jumpLinkStore;
    if (store == null) return;
    await showJumpLinksSheet(
      context: context,
      store: store,
      currentPage: _pageNumber,
      pageCount: _pageCount,
      onJumpToPage: _jumpToPage,
      onChanged: () {
        _reloadJumpLinks();
      },
    );
    await _reloadJumpLinks();
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

  Rect _jumpLinkPageRect(Size viewSize) =>
      fittedPageRect(viewSize, _pageAspectRatio);

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
      SnackBar(
        content: Text(AppLocalizations.of(context).pdfModeScreenTapHint),
        duration: const Duration(seconds: 4),
      ),
    );
    await _savePageTurnPrefs(_pageTurnPrefs.copyWith(hintShown: true));
  }

  void _showPerformanceHint() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          gestureMapRevealHint(
            AppLocalizations.of(context),
            _pageTurnPrefs.gestureMap,
          ),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  bool get _atFitZoom {
    if (_isSingle || _useCustomContinuous) return true;
    final fit = _fitZoom(_controller);
    if (fit == null) return true;
    return _controller.currentZoom <= fit * kFitZoomTolerance;
  }

  /// The zoom this layout opens at in the current viewport, or null before the
  /// viewer knows its own size.
  double? _fitZoom(PdfViewerController controller, {Size? viewSize}) {
    if (!controller.isReady) return null;
    final layout = controller.layout;
    final margin = controller.params.margin;
    return pdfFitZoom(
      mode: _layoutMode,
      viewSize: viewSize ?? controller.viewSize,
      documentSize: layout.documentSize,
      spreadHeight: _layoutMode != PdfLayoutMode.twoPage
          ? 0
          : twoPageSpreadHeight(layout.pageLayouts, _navPage) + margin * 2,
    );
  }

  /// One instance for the screen's life: pdfrx rebuilds its sizing delegate
  /// whenever the provider compares unequal, and a fresh one per build would
  /// reset the zoom mid-read.
  late final _sizeDelegate = PdfViewerSizeDelegateProviderLegacy(
    calculateInitialZoom: _initialZoom,
  );

  /// The viewer opens on a whole reading unit, not on whatever fits across.
  double? _initialZoom(
    PdfDocument document,
    PdfViewerController controller,
    double fitZoom,
    double coverZoom,
  ) => _fitZoom(controller) ?? coverZoom;

  /// Rotation changes what fits, so a Score that was showing a whole spread
  /// must still show one afterwards. A musician who had pinched in keeps their
  /// zoom — only an untouched fit is re-fitted.
  void _onViewSizeChanged(
    Size viewSize,
    Size? oldViewSize,
    PdfViewerController controller,
  ) {
    if (oldViewSize == null) return;
    final before = _fitZoom(controller, viewSize: oldViewSize);
    if (before == null) return;
    if (controller.currentZoom > before * kFitZoomTolerance) return;
    final after = _fitZoom(controller, viewSize: viewSize);
    if (after == null) return;
    // pdfrx calls this during build, and the delegate is still settling its
    // own matrix; take the last word once that has run.
    Future.delayed(kRefitDelay, () {
      if (!mounted || !controller.isReady) return;
      controller.setZoom(
        controller.centerPosition,
        after,
        duration: Duration.zero,
      );
    });
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
    // Any PageTurn (tap, swipe or pedal) means the musician is back on the
    // Score — drop the chrome without waiting for the timer (0034).
    _chrome.hide();
    final now = DateTime.now();
    final delay = _pageTurnPrefs.delay;
    final scope = _pageTurnPrefs.delayScope;
    if (!_delayGate.allow(now: now, kind: kind, delay: delay, scope: scope)) {
      return;
    }

    final step = resolvePageTurnStep(
      mode: _layoutMode,
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

    // Identity continuous: pdfrx PdfViewer (Scroll or Half Page).
    if (_isSingle) return false;
    if (!_controller.isReady) return false;

    final view = _controller.viewSize;
    final zoom = _controller.currentZoom;
    if (zoom <= 0 || view.isEmpty) return false;
    final horizontal = layoutAxisFor(_layoutMode) == LayoutAxis.horizontal;
    final extent = horizontal ? view.width : view.height;
    final docDelta = (extent * fraction) / zoom;
    final sign = forward ? 1.0 : -1.0;
    final center = _controller.centerPosition;
    final before = center;
    final next = horizontal
        ? Offset(center.dx + sign * docDelta, center.dy)
        : Offset(center.dx, center.dy + sign * docDelta);
    await _controller.goTo(_controller.calcMatrixFor(next), duration: duration);
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
        // Hidden chrome → reveal only. Already visible → the ScoreMenu (0015).
        if (!_chrome.shown) {
          _chrome.reveal();
        } else {
          _openScoreMenu();
        }
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
      // Tap zones and swipe run along the axis this layout moves pages (0041).
      prefs: resolvePageTurnPrefsForLayout(_pageTurnPrefs, _layoutMode),
      reverseHorizontal: _pageTurnPrefs.reverseDirection,
      onAction: _onInteractionAction,
      onGestureAction: _onGestureMapAction,
      onScoreTap: _chrome.hide,
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
                onTap: () =>
                    _onGestureMapAction(_pageTurnPrefs.gestureMap.topEdge),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: band,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    _onGestureMapAction(_pageTurnPrefs.gestureMap.bottomEdge),
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
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(_score.title, overflow: TextOverflow.ellipsis),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  /// Icon over a caption, the same grammar `ScoreMenuQuickBar` uses for
  /// shortcuts that must explain themselves without a hover tooltip
  /// mid-performance (Spec 0043) — a bare "layers" glyph reads as nothing on
  /// its own, and this is the one AppBar action that toggles a mode rather
  /// than opening something, so it needs to say what it does at a glance.
  Widget _buildPieceNotesToggle() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final tint = !_prefsReady
        ? theme.disabledColor
        : (_showPieceNotes ? theme.colorScheme.primary : null);
    return IconButton(
      tooltip: _showPieceNotes
          ? l10n.pdfModeScreenHidePieceNotes
          : l10n.pdfModeScreenShowPieceNotes,
      onPressed: _prefsReady
          ? () => _setShowPieceNotes(!_showPieceNotes)
          : null,
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _showPieceNotes ? Icons.layers : Icons.layers_outlined,
            color: tint,
          ),
          const SizedBox(height: kQuickBarLabelGap),
          Text(
            l10n.pdfModeScreenPieceNotes,
            style: theme.textTheme.labelSmall?.copyWith(color: tint),
          ),
        ],
      ),
    );
  }

  Widget _wrapViewerInsets(Widget child) {
    // Inset bands must read as the same surface as the viewer gutter — with
    // the chrome hidden, a different colour looks like the Score is boxed in
    // top and bottom (Spec 0034).
    return ColoredBox(
      color: pdfSurfaceColor(context, filter: _colorFilterMode),
      child: !_displayPrefs.avoidNotches
          ? child
          : SafeArea(
              // In PerformanceMode the AppBar floats over the viewer, so the
              // viewer owns the top inset instead of inheriting it from
              // laid-out chrome (0034).
              top: _chrome.active,
              // …and keeps the bottom edge: the home indicator is an overlay
              // bar, not a cutout, and that strip is prime PageTurn tap area
              // once the PageNavBar is hidden.
              bottom: !_chrome.active,
              child: child,
            ),
    );
  }

  /// Fades chrome in/out over a viewer that keeps its size (Spec 0034).
  Widget _fadingChrome(Widget child, {required bool shown}) {
    return IgnorePointer(
      ignoring: !shown,
      child: AnimatedOpacity(
        opacity: shown ? 1 : 0,
        duration: kChromeFadeDuration,
        child: child,
      ),
    );
  }

  void _paintPageBorder(Canvas canvas, Rect pageRect, PdfPage page) {
    if (!_displayPrefs.borderEnabled) return;
    final paint = Paint()
      ..color = _displayPrefs.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _displayPrefs.borderWidth;
    canvas.drawRect(pageRect.deflate(_displayPrefs.borderWidth / 2), paint);
  }

  /// Say so when the screen, not the musician, changed the layout (Spec 0041).
  ///
  /// A layout that rearranges itself under your hands mid-piece with no
  /// explanation is worse than a layout that was wrong to begin with.
  void _noticeIfLayoutReresolved(PdfLayoutMode resolved) {
    final previous = _announcedLayout;
    if (previous == resolved) return;
    _announcedLayout = resolved;
    // First build has nothing to compare against, and nothing to explain.
    if (previous == null || !_prefsReady) return;
    _layoutNotice = resolved.label(AppLocalizations.of(context));
    _layoutNoticeSeq++;
  }

  @override
  Widget build(BuildContext context) {
    _fit = LayoutFit(viewSize: MediaQuery.sizeOf(context));
    final layoutMode = _layoutMode;
    _noticeIfLayoutReresolved(layoutMode);
    final performanceChrome = _chrome.active;
    final chromeShown = _chrome.shown;
    final appBar = AppBar(
      // Taller than the default: this bar carries the title and every action,
      // so it gets the room the one-slider PageNavBar gives back (0034).
      toolbarHeight: kPdfAppBarHeight,
      title: _buildTitle(),
      actions: [
        // Session-only: every open of all-pages starts with this off (Spec 0055).
        if (_canShowPieceNotes) _buildPieceNotesToggle(),
        // Draw, Metronome and Bookmarks moved down to the ScoreMenuQuickBar in
        // the bottom chrome (Spec 0043): they are the actions wanted mid-piece,
        // and they read fine there without an AppBar row fighting the title for
        // space. `⋯` is the one action still worth keeping up here — it is
        // reached the same way whether the chrome is fading in or settled.
        IconButton(
          tooltip: AppLocalizations.of(context).actionMore,
          onPressed: _prefsReady ? _openScoreMenu : null,
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );

    // How the shortcut row fits *this* screen, rather than one shape for every
    // device (Spec 0043 revision 3): stacked under the scrubber where there is
    // height for it, inside the scrubber's own row where there is not.
    final quickBarFit = QuickBarFit(
      screenSize: MediaQuery.sizeOf(context),
      slotCount: ScoreMenuQuickBar.slotCount,
      bottomInset: _displayPrefs.avoidNotches
          ? MediaQuery.paddingOf(context).bottom
          : 0,
    );
    final hasPageNav = _prefsReady && _pageCount > 0;
    final mergeQuickBar = hasPageNav && quickBarFit.mergeIntoPageNav;

    // Only this subtree follows the beat, so the tint can pulse without the
    // viewer above it rebuilding with it.
    final quickBar = ListenableBuilder(
      listenable: _metronome,
      builder: (context, _) => ScoreMenuQuickBar(
        metronomeRunning: _metronome.isRunning,
        metronomeAccent: _metronome.isAccent,
        onOpenMetronome: _openMetronome,
        drawEnabled: _drawEnabled,
        onToggleDraw: () => _setDrawEnabled(!_drawEnabled),
        onOpenBookmarks: () => _onQuickBarSelected(ScoreMenuAction.bookmarks),
        fit: quickBarFit,
        merged: mergeQuickBar,
        // Greys out rather than disappearing while the Score's prefs load, the
        // same way `⋯` above does.
        enabled: _prefsReady,
        avoidNotches: _displayPrefs.avoidNotches,
      ),
    );

    final pageNav = hasPageNav
        ? PageNavBar(
            pageNumber: _pageNumber,
            pageCount: _pageCount,
            onJumpToPage: (page) {
              // Using the scrubber counts as interaction: restart auto-hide.
              _chrome.keepAlive();
              _jumpToPage(page);
            },
            onPrevPage: () {
              if (_pageNumber > 1) {
                _jumpToPage(_pageNumber - 1);
                _chrome.keepAlive();
              }
            },
            onNextPage: () {
              if (_pageNumber < _pageCount) {
                _jumpToPage(_pageNumber + 1);
                _chrome.keepAlive();
              }
            },
            // Whichever bar is bottom-most owns the home-indicator inset and
            // the gesture gap; stacked, that is the quick-bar below (0032).
            trailing: mergeQuickBar ? [quickBar] : const [],
            bottomGestureGap: mergeQuickBar,
            avoidNotches: mergeQuickBar && _displayPrefs.avoidNotches,
          )
        : null;

    // One visual block of bottom chrome, whether it sits in the Scaffold's own
    // slot or floats as an overlay. The quick-bar is in it even when there is
    // no scrubber yet: Draw is not in `⋯` (0035 decision 6), so tying the bar's
    // life to the page count is what would take Draw away entirely — and every
    // Setlist piece change, which clears `_prefsReady`, moved the chrome.
    final bottomChrome = Column(
      mainAxisSize: MainAxisSize.min,
      children: [?pageNav, if (!mergeQuickBar) quickBar],
    );

    final body = Column(
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
            onUndo: _store.canUndo ? _undo : null,
            onRedo: _store.canRedo ? _redo : null,
            onDeleteStamp: _selectedStampId == null
                ? null
                : _deleteSelectedStamp,
          ),
        Expanded(
          child: !_prefsReady
              ? const Center(child: CircularProgressIndicator())
              : _wrapViewerInsets(
                  _isSingle
                      ? _buildSinglePageBody()
                      : _useCustomContinuous
                      ? _buildCustomContinuousBody(layoutMode)
                      : _buildContinuousBody(layoutMode),
                ),
        ),
      ],
    );

    // Over the Score in both chrome states: the screen may re-resolve the
    // layout while the toolbar is up just as easily as while it is hidden.
    final withNotice = Stack(
      fit: StackFit.expand,
      children: [
        body,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: TransientPill(
              text: _layoutNotice ?? '',
              trigger: _layoutNoticeSeq,
              enabled: _layoutNotice != null,
            ),
          ),
        ),
      ],
    );

    // One Scaffold for both chrome states, and the Score always the first
    // child of the same Stack. Returning two different Scaffold shapes made
    // the viewer a different element in each, so entering Draw mode — which
    // suspends PerformanceMode — rebuilt it from nothing and lost the page.
    //
    // In PerformanceMode the chrome floats over that Stack instead of taking
    // Scaffold's slots, so revealing it never resizes (and re-fits) the
    // viewer, and the body keeps the device's own insets instead of being
    // padded out by the height of an AppBar the musician cannot even see.
    return Scaffold(
      appBar: performanceChrome ? null : appBar,
      bottomNavigationBar: performanceChrome ? null : bottomChrome,
      body: Stack(
        fit: StackFit.expand,
        children: [
          withNotice,
          // Always in the Stack, shown by its own rule: a child that comes and
          // goes is a child the viewer beside it can be rebuilt by.
          BeatStrip(engine: _metronome, chromeShown: chromeShown),
          if (performanceChrome) ...[
            if (_pageCount > 0)
              Positioned(
                right: 0,
                bottom: 0,
                child: PagePositionPill(
                  pageNumber: _pageNumber,
                  pageCount: _pageCount,
                  enabled: !chromeShown,
                ),
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _fadingChrome(appBar, shown: chromeShown),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _fadingChrome(bottomChrome, shown: chromeShown),
            ),
          ],
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
              store: _overlayStore,
              drawEnabled: _drawEnabled && !_showPieceNotes,
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
              initialPage: _pageNumber,
            ),
            _interactionLayer(),
          ],
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
              store: _overlayStore,
              drawEnabled: _drawEnabled && !_showPieceNotes,
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
              initialPage: _pageNumber,
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
            // Changing layout or borders builds a new PdfViewer; this is what
            // keeps it from opening at the front of the Score (Spec 0004).
            initialPageNumber: _pageNumber,
            params: PdfViewerParams(
              // Unfiltered: the whole viewer is inside PageColorFiltered here.
              backgroundColor: pdfSurfaceColor(context),
              sizeDelegateProvider: _sizeDelegate,
              onViewSizeChanged: _onViewSizeChanged,
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
                    store: _overlayStore,
                    drawEnabled: _drawEnabled && !_showPieceNotes,
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
