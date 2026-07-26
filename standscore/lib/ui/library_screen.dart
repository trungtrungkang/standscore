import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_handler/share_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:standscore/label/label.dart';
import 'package:standscore/label/label_filter.dart';
import 'package:standscore/label/label_store.dart';
import 'package:standscore/library/library_backup.dart';
import 'package:standscore/library/library_search.dart';
import 'package:standscore/library/library_sort.dart';
import 'package:standscore/library/library_sort_prefs_store.dart';
import 'package:standscore/library/relative_day.dart';
import 'package:standscore/library/score.dart';
import 'package:standscore/library/score_library.dart';
import 'package:standscore/library/score_thumbnails.dart';
import 'package:standscore/library/shared_pdf_import.dart';
import 'package:standscore/pdf/pdf_first_page.dart';
import 'package:standscore/setlist/setlist.dart';
import 'package:standscore/setlist/setlist_session.dart';
import 'package:standscore/setlist/setlist_store.dart';
import 'package:standscore/theme/app_appearance.dart';
import 'package:standscore/ui/appearance_sheet.dart';
import 'package:standscore/ui/label_sheets.dart';
import 'package:standscore/ui/pdf_mode_screen.dart';
import 'package:standscore/ui/score_thumbnail_tile.dart';
import 'package:standscore/ui/setlist_editor_screen.dart';
import 'package:standscore/ui/title_prompt.dart';

enum _LibraryTab { scores, setlists }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    this.library,
    this.thumbnails,
    this.appearance = AppAppearance.defaults,
    this.onAppearanceChanged,
    this.onLibraryRestored,
  });

  /// Injected for tests; production creates a documents-based library.
  final ScoreLibrary? library;

  /// Injected for tests; production caches thumbnails beside the app's other
  /// derived data. Null means rows keep the generic PDF glyph (Spec 0040).
  final ScoreThumbnails? thumbnails;

  final AppAppearance appearance;
  final ValueChanged<AppAppearance>? onAppearanceChanged;

  /// Called after a successful ZIP restore so app chrome prefs can reload.
  final VoidCallback? onLibraryRestored;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  ScoreLibrary? _library;
  SetlistStore? _setlistStore;
  LabelStore? _labelStore;
  List<Score> _scores = const [];
  List<Setlist> _setlists = const [];
  bool _loading = true;
  String? _error;
  _LibraryTab _tab = _LibraryTab.scores;
  Set<String> _filterLabelIds = {};
  LabelFilterMode _filterMode = LabelFilterMode.any;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, List<String>> _bookmarkTitles = const {};

  /// Label names per Score, rebuilt on reload rather than in `itemBuilder` —
  /// that ran once per Label per row on every frame (Spec 0040).
  Map<String, List<String>> _labelNames = const {};
  ScoreThumbnails? _thumbnails;
  Directory? _libraryRoot;
  LibrarySortPrefsStore? _sortPrefsStore;
  LibrarySortMode _sortMode = LibrarySortMode.lastViewed;
  StreamSubscription<SharedMedia>? _shareSub;
  bool _shareListening = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _bootstrap();
  }

  @override
  void dispose() {
    _shareSub?.cancel();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final next = _searchController.text;
    if (next == _searchQuery) return;
    setState(() => _searchQuery = next);
  }

  Future<void> _bootstrap() async {
    try {
      final library = widget.library ?? await _openDocumentsLibrary();
      await library.ensureReady();
      final libraryRoot = library.manifestFile.parent;
      final store = SetlistStore(root: libraryRoot);
      final labelStore = LabelStore(root: libraryRoot);
      await labelStore.load();
      final sortPrefs = LibrarySortPrefsStore(root: libraryRoot);
      final sortMode = await sortPrefs.load();
      final scores = await library.listScores();
      final setlists = await store.list();
      final bookmarkTitles = await loadBookmarkTitleIndex(
        root: libraryRoot,
        scoreIds: scores.map((s) => s.id),
      );
      _thumbnails =
          widget.thumbnails ??
          (widget.library == null ? await _openThumbnailCache() : null);
      if (!mounted) return;
      setState(() {
        _library = library;
        _libraryRoot = libraryRoot;
        _setlistStore = store;
        _labelStore = labelStore;
        _sortPrefsStore = sortPrefs;
        _sortMode = sortMode;
        _scores = scores;
        _setlists = setlists;
        _bookmarkTitles = bookmarkTitles;
        _labelNames = _labelNamesFor(scores, labelStore);
        _loading = false;
      });
      unawaited(_backfillPageCounts());
      await _startShareListening();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<ScoreLibrary> _openDocumentsLibrary() async {
    final root = Directory(
      p.join((await getApplicationDocumentsDirectory()).path, 'standscore'),
    );
    return ScoreLibrary(root: root, countPages: countPdfPages);
  }

  /// Thumbnails are derived data, so they live in the OS cache directory, not
  /// the library root: nothing to strip out of a backup ZIP (0027), and the
  /// system may reclaim them (Spec 0040).
  Future<ScoreThumbnails?> _openThumbnailCache() async {
    try {
      final cache = await getApplicationCacheDirectory();
      return ScoreThumbnails(
        cacheDir: Directory(p.join(cache.path, 'score-thumbs')),
        render: renderPdfFirstPagePng,
      );
    } catch (_) {
      // No cache directory on this host: rows fall back to the PDF glyph.
      return null;
    }
  }

  Map<String, List<String>> _labelNamesFor(
    List<Score> scores,
    LabelStore? store,
  ) {
    if (store == null) return const {};
    final names = {for (final label in store.labels) label.id: label.name};
    return {
      for (final score in scores)
        score.id: [
          for (final label in store.labels)
            if (store.labelsForScore(score.id).contains(label.id))
              names[label.id]!,
        ],
    };
  }

  /// Counts pages for Scores that predate Spec 0040, after the list is up.
  Future<void> _backfillPageCounts() async {
    final scores = await _library?.backfillPageCounts();
    if (scores == null || !mounted) return;
    setState(() => _scores = scores);
  }

  Future<void> _startShareListening() async {
    if (_shareListening || kIsWeb) return;
    if (!(Platform.isIOS || Platform.isAndroid)) return;
    _shareListening = true;
    final handler = ShareHandler.instance;
    try {
      final initial = await handler.getInitialSharedMedia();
      await _importSharedMedia(initial);
      await handler.resetInitialSharedMedia();
    } catch (_) {
      // Plugin unavailable in tests / unsupported host.
    }
    _shareSub = handler.sharedMediaStream.listen((media) {
      _importSharedMedia(media);
    });
  }

  Future<void> _importSharedMedia(SharedMedia? media) async {
    final library = _library;
    if (library == null || media == null) return;
    final paths = <String>[
      for (final attachment in media.attachments ?? const <SharedAttachment?>[])
        ?attachment?.path,
    ];
    if (paths.isEmpty) return;

    final imported = await const SharedPdfImport().importPaths(
      library: library,
      paths: paths,
    );
    if (!mounted) return;
    if (imported.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No PDF files to import')));
      return;
    }
    setState(() => _tab = _LibraryTab.scores);
    await _reload();
    if (!mounted) return;
    final n = imported.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(n == 1 ? 'Imported 1 score' : 'Imported $n scores'),
      ),
    );
  }

  Future<void> _reload() async {
    final library = _library;
    final store = _setlistStore;
    final labels = _labelStore;
    final root = _libraryRoot;
    if (library == null || store == null) return;
    final scores = await library.listScores();
    final setlists = await store.list();
    await labels?.load();
    final bookmarkTitles = root == null
        ? _bookmarkTitles
        : await loadBookmarkTitleIndex(
            root: root,
            scoreIds: scores.map((s) => s.id),
          );
    if (!mounted) return;
    setState(() {
      _scores = scores;
      _setlists = setlists;
      _bookmarkTitles = bookmarkTitles;
      _labelNames = _labelNamesFor(scores, labels);
    });
  }

  List<Score> get _visibleScores {
    var scores = _scores;
    final labels = _labelStore;
    if (labels != null) {
      scores = filterScoresByLabels(
        scores: scores,
        assignments: labels.assignments,
        selectedLabelIds: _filterLabelIds,
        mode: _filterMode,
      );
    }
    scores = filterScoresBySearch(
      scores: scores,
      query: _searchQuery,
      bookmarkTitlesByScoreId: _bookmarkTitles,
    );
    return sortScores(scores, _sortMode);
  }

  Future<void> _setSortMode(LibrarySortMode mode) async {
    setState(() => _sortMode = mode);
    await _sortPrefsStore?.save(mode);
  }

  Future<void> _backupLibrary() async {
    final root = _libraryRoot;
    if (root == null) return;
    final messenger = ScaffoldMessenger.of(context);
    _showBusyDialog('Creating backup…');
    try {
      final exports = Directory(
        p.join((await getApplicationDocumentsDirectory()).path, 'exports'),
      );
      await exports.create(recursive: true);
      final stamp = DateTime.now()
          .toUtc()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final zip = File(p.join(exports.path, 'StandScore-backup-$stamp.zip'));
      await const LibraryBackup().createBackup(libraryRoot: root, zipFile: zip);
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      try {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(zip.path, mimeType: 'application/zip')],
            subject: 'StandScore backup',
          ),
        );
      } on MissingPluginException {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text('Backup saved: ${zip.path}')),
        );
        return;
      }
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Backup ready — share sheet opened')),
      );
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Backup failed: $e')));
    }
  }

  Future<void> _restoreLibrary() async {
    final root = _libraryRoot;
    if (root == null) return;
    final messenger = ScaffoldMessenger.of(context);

    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
      withData: false,
    );
    final path = picked?.files.single.path;
    if (path == null) return;
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore backup?'),
        content: const Text(
          'This replaces all Scores, annotations, Labels, Setlists, '
          'and app preferences with the backup. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Replace all'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    _showBusyDialog('Restoring backup…');
    try {
      await const LibraryBackup().restoreBackup(
        zipFile: File(path),
        libraryRoot: root,
      );
      final sortPrefs = LibrarySortPrefsStore(root: root);
      final sortMode = await sortPrefs.load();
      if (!mounted) return;
      setState(() {
        _sortPrefsStore = sortPrefs;
        _sortMode = sortMode;
        _filterLabelIds = {};
        _filterMode = LabelFilterMode.any;
        _searchController.clear();
        _searchQuery = '';
      });
      await _reload();
      widget.onLibraryRestored?.call();
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Library restored from backup')),
      );
    } on LibraryBackupException catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Restore failed: $e')));
    }
  }

  void _showBusyDialog(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }

  bool get _filterActive =>
      _filterMode == LabelFilterMode.untagged || _filterLabelIds.isNotEmpty;

  /// Label names behind the current filter, in catalog order.
  List<String> get _activeFilterNames {
    final store = _labelStore;
    if (store == null) return const [];
    return [
      for (final label in store.labels)
        if (_filterLabelIds.contains(label.id)) label.name,
    ];
  }

  /// What the filter is doing, in a sentence — the empty state used to say
  /// "this filter" and leave the musician guessing (Spec 0040).
  String _filterDescription() {
    if (_filterMode == LabelFilterMode.untagged) return 'Untagged';
    final names = _activeFilterNames;
    if (names.isEmpty) return 'this filter';
    final joiner = _filterMode == LabelFilterMode.all ? ' and ' : ' or ';
    return names.join(joiner);
  }

  void _clearFilter() {
    setState(() {
      _filterLabelIds = {};
      _filterMode = LabelFilterMode.any;
    });
  }

  /// The active filter, spelled out under the search field and removable from
  /// there; the filled funnel icon alone never said what was hidden.
  Widget _buildFilterChips(BuildContext context) {
    final theme = Theme.of(context);
    final untagged = _filterMode == LabelFilterMode.untagged;
    final store = _labelStore;
    final chips = <({String? id, String name})>[
      if (untagged)
        (id: null, name: 'Untagged')
      else
        for (final label in store?.labels ?? const <Label>[])
          if (_filterLabelIds.contains(label.id))
            (id: label.id, name: label.name),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
      child: Row(
        children: [
          if (_filterMode == LabelFilterMode.all && chips.length > 1)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text('All of', style: theme.textTheme.labelMedium),
            ),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final chip in chips)
                  InputChip(
                    label: Text(chip.name),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    deleteIcon: const Icon(Icons.close, size: 18),
                    deleteButtonTooltipMessage: 'Remove ${chip.name} filter',
                    onDeleted: () => _removeFilterChip(chip.id),
                  ),
              ],
            ),
          ),
          TextButton(onPressed: _clearFilter, child: const Text('Clear')),
        ],
      ),
    );
  }

  void _removeFilterChip(String? labelId) {
    if (labelId == null) {
      _clearFilter();
      return;
    }
    setState(() => _filterLabelIds = {..._filterLabelIds}..remove(labelId));
  }

  bool get _searchActive => _searchQuery.trim().isNotEmpty;

  Future<void> _openFilter() async {
    final store = _labelStore;
    if (store == null) return;
    await showLabelFilterSheet(
      context: context,
      store: store,
      selectedLabelIds: _filterLabelIds,
      mode: _filterMode,
      onChanged: (selected, mode) {
        setState(() {
          _filterLabelIds = selected;
          _filterMode = mode;
        });
      },
    );
  }

  Future<void> _editScoreLabels(Score score) async {
    final store = _labelStore;
    if (store == null) return;
    await showScoreLabelsSheet(
      context: context,
      store: store,
      scoreId: score.id,
      scoreTitle: score.title,
      onChanged: () =>
          setState(() => _labelNames = _labelNamesFor(_scores, _labelStore)),
    );
    await _reload();
  }

  Future<void> _renameScore(Score score) async {
    final library = _library;
    if (library == null) return;
    final title = await promptForTitle(
      context: context,
      title: 'Rename Score',
      initial: score.title,
    );
    // Cancelled, or cleared: the file name it came in with is not an
    // improvement on the title it already has (Spec 0040).
    if (title == null || title.trim().isEmpty) return;
    await library.renameScore(scoreId: score.id, title: title);
    await _reload();
  }

  Future<void> _replacePdf(Score score) async {
    final library = _library;
    if (library == null) return;

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;

    if (!mounted) return;
    final choice = await showDialog<ReplacePdfOverlayChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace PDF'),
        content: Text(
          'Replace the file for “${score.title}”? '
          'Choose whether to keep annotations, bookmarks, jump links, '
          'and page order — or reset them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, ReplacePdfOverlayChoice.keep),
            child: const Text('Keep overlays'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, ReplacePdfOverlayChoice.reset),
            child: const Text('Reset overlays'),
          ),
        ],
      ),
    );
    if (choice == null) return;

    try {
      await library.replacePdf(
        scoreId: score.id,
        sourcePath: path,
        overlays: choice,
      );
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            choice == ReplacePdfOverlayChoice.reset
                ? 'PDF replaced; overlays reset.'
                : 'PDF replaced; overlays kept.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Replace failed: $e')));
    }
  }

  Future<void> _importPdfs() async {
    final library = _library;
    if (library == null) return;

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: true,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;

    final files = <({String path, String name})>[];
    for (final file in result.files) {
      final path = file.path;
      if (path == null) continue;
      files.add((path: path, name: file.name));
    }
    if (files.isEmpty) return;

    await library.importPdfs(files);
    await _reload();
  }

  Future<void> _importSample() async {
    final library = _library;
    if (library == null) return;

    final bytes = await rootBundle.load('assets/sample_score.pdf');
    final temp = File(
      p.join(
        (await getTemporaryDirectory()).path,
        'standscore_sample_score.pdf',
      ),
    );
    await temp.writeAsBytes(bytes.buffer.asUint8List());
    await library.importPdf(
      sourcePath: temp.path,
      originalFileName: 'Sample Score.pdf',
    );
    await _reload();
  }

  Future<void> _openScore(Score score) async {
    final library = _library;
    if (library == null) return;
    final updated = await library.markOpened(score);
    final path = library.absoluteFile(updated).path;
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PdfModeScreen(score: updated, filePath: path),
      ),
    );
    await _reload();
  }

  Future<void> _openSetlist(Setlist setlist) async {
    final library = _library;
    final store = _setlistStore;
    if (library == null || store == null) return;
    if (setlist.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This setlist is empty. Add scores first.'),
        ),
      );
      return;
    }

    final resolved = await SetlistSession.resolve(
      setlist: setlist,
      library: library,
    );
    if (!mounted) return;
    if (resolved.session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No scores available in this setlist.')),
      );
      return;
    }
    if (resolved.skipped > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Skipped ${resolved.skipped} missing score'
            '${resolved.skipped == 1 ? '' : 's'}.',
          ),
        ),
      );
    }

    await store.markOpened(setlist);
    final session = resolved.session!;
    final first = session.pieces.first;
    await library.markOpened(first.score);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PdfModeScreen(
          score: first.score,
          filePath: first.filePath,
          setlistSession: session,
        ),
      ),
    );
    await _reload();
  }

  Future<void> _createSetlist() async {
    final store = _setlistStore;
    if (store == null) return;
    final draft = Setlist(
      id: store.newId(),
      title: 'New setlist',
      scoreIds: const [],
      createdAt: DateTime.now().toUtc(),
    );
    final result = await Navigator.of(context).push<Setlist>(
      MaterialPageRoute(
        builder: (_) =>
            SetlistEditorScreen(initial: draft, libraryScores: _scores),
      ),
    );
    if (result == null) return;
    await store.upsert(result);
    await _reload();
  }

  Future<void> _editSetlist(Setlist setlist) async {
    final store = _setlistStore;
    if (store == null) return;
    final result = await Navigator.of(context).push<Setlist>(
      MaterialPageRoute(
        builder: (_) =>
            SetlistEditorScreen(initial: setlist, libraryScores: _scores),
      ),
    );
    if (result == null) return;
    await store.upsert(result);
    await _reload();
  }

  Future<void> _deleteSetlist(Setlist setlist) async {
    final store = _setlistStore;
    if (store == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete setlist?'),
        content: Text('Delete “${setlist.title}”? Scores are kept.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await store.delete(setlist.id);
    await _reload();
  }

  Future<void> _deleteScore(Score score) async {
    final library = _library;
    final setlists = _setlistStore;
    if (library == null || setlists == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete score?'),
        content: Text(
          'Delete “${score.title}” from the Library? '
          'The PDF, annotations, bookmarks, jump links, and page order '
          'will be removed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await library.deleteScore(score.id);
    await _labelStore?.setScoreLabels(score.id, {});
    await setlists.removeScoreFromAll(score.id);
    await _thumbnails?.evict(score.id);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: 'StandScore',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              'assets/brand/standscore-logo.png',
              height: 32,
              width: 32,
              fit: BoxFit.cover,
            ),
          ),
        ),
        actions: [
          if (_tab == _LibraryTab.scores) ...[
            PopupMenuButton<LibrarySortMode>(
              tooltip: 'Sort',
              enabled: !_loading,
              initialValue: _sortMode,
              onSelected: _setSortMode,
              itemBuilder: (context) => [
                for (final mode in LibrarySortMode.values)
                  CheckedPopupMenuItem<LibrarySortMode>(
                    value: mode,
                    checked: _sortMode == mode,
                    child: Text(mode.label),
                  ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    const Icon(Icons.sort),
                    const SizedBox(width: 4),
                    Text(
                      _sortMode.label,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: 'Filter by Label',
              onPressed: _loading ? null : _openFilter,
              icon: Icon(
                _filterActive ? Icons.filter_alt : Icons.filter_alt_outlined,
              ),
            ),
            IconButton(
              tooltip: 'Manage Labels',
              onPressed: _loading
                  ? null
                  : () async {
                      final store = _labelStore;
                      if (store == null) return;
                      await showManageLabelsSheet(
                        context: context,
                        store: store,
                        onChanged: () => setState(() {}),
                      );
                      await _reload();
                    },
              icon: const Icon(Icons.label_outline),
            ),
          ],
          // No "New setlist" action here: the FAB below already is it.
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (value) {
              switch (value) {
                case 'appearance':
                  final onChanged = widget.onAppearanceChanged;
                  if (onChanged == null) return;
                  showAppearanceSheet(
                    context: context,
                    appearance: widget.appearance,
                    onChanged: onChanged,
                  );
                case 'backup':
                  _backupLibrary();
                case 'restore':
                  _restoreLibrary();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'appearance', child: Text('Appearance…')),
              PopupMenuItem(value: 'backup', child: Text('Backup…')),
              PopupMenuItem(value: 'restore', child: Text('Restore…')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SegmentedButton<_LibraryTab>(
              segments: const [
                ButtonSegment(
                  value: _LibraryTab.scores,
                  label: Text('Scores'),
                  icon: Icon(Icons.picture_as_pdf_outlined),
                ),
                ButtonSegment(
                  value: _LibraryTab.setlists,
                  label: Text('Setlists'),
                  icon: Icon(Icons.queue_music),
                ),
              ],
              selected: {_tab},
              onSelectionChanged: _loading
                  ? null
                  : (next) => setState(() => _tab = next.first),
            ),
          ),
          if (!_loading && _tab == _LibraryTab.scores && _scores.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search titles & bookmarks',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchActive
                      ? IconButton(
                          tooltip: 'Clear',
                          onPressed: () {
                            _searchController.clear();
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          if (!_loading && _tab == _LibraryTab.scores && _filterActive)
            _buildFilterChips(context),
          Expanded(child: _buildBody(context)),
        ],
      ),
      floatingActionButton: _loading
          ? null
          : _tab == _LibraryTab.scores
          ? FloatingActionButton.extended(
              onPressed: _importPdfs,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Add PDF'),
            )
          : FloatingActionButton.extended(
              onPressed: _createSetlist,
              icon: const Icon(Icons.playlist_add),
              label: const Text('New setlist'),
            ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Failed to open library:\n$_error'));
    }
    return _tab == _LibraryTab.scores
        ? _buildScoresBody(context)
        : _buildSetlistsBody(context);
  }

  Widget _buildScoresBody(BuildContext context) {
    if (_scores.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.library_music_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'No scores yet',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Import PDF sheet music from your device to build your library.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _importPdfs,
                icon: const Icon(Icons.add),
                label: const Text('Add PDF'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _importSample,
                child: const Text('Add sample score'),
              ),
            ],
          ),
        ),
      );
    }

    final visible = _visibleScores;
    if (visible.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _searchActive
                    ? 'No scores match “${_searchQuery.trim()}”'
                    : 'No scores match ${_filterDescription()}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (_searchActive)
                TextButton(
                  onPressed: () => _searchController.clear(),
                  child: const Text('Clear search'),
                ),
              if (_filterActive)
                TextButton(
                  onPressed: _clearFilter,
                  child: const Text('Clear filter'),
                ),
            ],
          ),
        ),
      );
    }

    final library = _library;
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: visible.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final score = visible[index];
        final labelNames = _labelNames[score.id] ?? const <String>[];
        return ListTile(
          leading: library == null
              ? const Icon(Icons.picture_as_pdf_outlined)
              : ScoreThumbnailTile(
                  thumbnails: _thumbnails,
                  scoreId: score.id,
                  pdf: library.absoluteFile(score),
                ),
          title: Text(score.title),
          isThreeLine: labelNames.isNotEmpty,
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_recencyLine(score)),
              if (labelNames.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _LabelChips(names: labelNames),
                ),
            ],
          ),
          onTap: () => _openScore(score),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'rename':
                  _renameScore(score);
                case 'labels':
                  _editScoreLabels(score);
                case 'replace':
                  _replacePdf(score);
                case 'delete':
                  _deleteScore(score);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'rename', child: Text('Rename…')),
              PopupMenuItem(value: 'labels', child: Text('Labels…')),
              PopupMenuItem(value: 'replace', child: Text('Replace PDF…')),
              PopupMenuItem(value: 'delete', child: Text('Delete…')),
            ],
          ),
        );
      },
    );
  }

  /// "Opened today · 4 pages" — when it was last played, and how long it is.
  String _recencyLine(Score score) {
    final when = score.lastOpenedAt == null
        ? 'Added ${relativeDay(score.createdAt)}'
        : 'Opened ${relativeDay(score.lastOpenedAt!)}';
    final pages = score.pageCount;
    if (pages == null) return when;
    return '$when · $pages ${pages == 1 ? 'page' : 'pages'}';
  }

  Widget _buildSetlistsBody(BuildContext context) {
    if (_setlists.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.queue_music,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'No setlists yet',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Group scores for continuous performance without reopening each piece.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _createSetlist,
                icon: const Icon(Icons.playlist_add),
                label: const Text('New setlist'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: _setlists.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final setlist = _setlists[index];
        final count = setlist.scoreIds.length;
        return ListTile(
          leading: const Icon(Icons.queue_music),
          title: Text(setlist.title),
          subtitle: Text(
            count == 0
                ? 'Empty'
                : '$count score${count == 1 ? '' : 's'}'
                      '${setlist.lastOpenedAt == null ? '' : ' · Opened ${relativeDay(setlist.lastOpenedAt!)}'}',
          ),
          onTap: () => _openSetlist(setlist),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editSetlist(setlist);
                case 'delete':
                  _deleteSetlist(setlist);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        );
      },
    );
  }
}

/// Labels on a Score row, capped so a heavily tagged Score cannot grow the row
/// without limit (Spec 0040).
class _LabelChips extends StatelessWidget {
  const _LabelChips({required this.names});

  static const _max = 2;

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    final shown = names.take(_max).toList();
    final hidden = names.length - shown.length;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final name in shown) _Chip(name),
        if (hidden > 0) _Chip('+$hidden'),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
