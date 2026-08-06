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
import 'package:stagescore/brand/brand.dart';
import 'package:stagescore/label/label.dart';
import 'package:stagescore/label/label_store.dart';
import 'package:stagescore/library/library_backup.dart';
import 'package:stagescore/library/library_root.dart';
import 'package:stagescore/library/library_search.dart';
import 'package:stagescore/library/library_sort.dart';
import 'package:stagescore/library/library_sort_prefs_store.dart';
import 'package:stagescore/library/library_visibility.dart';
import 'package:stagescore/library/outline_split.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/relative_day.dart';
import 'package:stagescore/library/score.dart';
import 'package:stagescore/library/score_library.dart';
import 'package:stagescore/library/score_origin.dart';
import 'package:stagescore/library/score_thumbnails.dart';
import 'package:stagescore/library/shared_pdf_import.dart';
import 'package:stagescore/library/split_handover.dart';
import 'package:stagescore/pdf/pdf_first_page.dart';
import 'package:stagescore/pdf/pdf_outline.dart';
import 'package:stagescore/setlist/setlist.dart';
import 'package:stagescore/setlist/setlist_session.dart';
import 'package:stagescore/setlist/setlist_store.dart';
import 'package:stagescore/theme/app_appearance.dart';
import 'package:stagescore/theme/app_tokens.dart';
import 'package:stagescore/ui/about_sheet.dart';
import 'package:stagescore/ui/appearance_sheet.dart';
import 'package:stagescore/ui/label_sheets.dart';
import 'package:stagescore/ui/library_filter_sheet.dart';
import 'package:stagescore/ui/page_extent_screen.dart';
import 'package:stagescore/ui/pdf_mode_screen.dart';
import 'package:stagescore/ui/pieces_screen.dart';
import 'package:stagescore/ui/score_thumbnail_tile.dart';
import 'package:stagescore/ui/setlist_editor_screen.dart';
import 'package:stagescore/ui/split_score_screen.dart';
import 'package:stagescore/ui/title_prompt.dart';

enum _LibraryTab { scores, setlists }

/// Which kind of Label filter chip is showing (Spec 0021).
enum _FilterChipKind { label, untagged }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    this.library,
    this.thumbnails,
    this.appearance = AppAppearance.defaults,
    this.onAppearanceChanged,
    this.onLibraryRestored,
    this.readBuild,
    this.launchUrl,
    this.loadOutline,
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

  /// Both injected for tests; production lets the About sheet reach the
  /// bundle and the system browser itself (Spec 0042).
  final Future<AppBuild> Function()? readBuild;
  final Future<bool> Function(Uri url)? launchUrl;

  /// Injected for tests; production reads the outline with pdfrx. Null means no
  /// split proposals — a grid with nothing marked, which is also what a PDF
  /// without a table of contents gets (Spec 0052).
  final PdfOutlineLoader? loadOutline;

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
  PdfOutlineLoader? _outlineLoader;

  /// Freshly imported files that look like collections, in import order — one
  /// suggestion bar at a time, dismissable, never a step in the import flow
  /// (Spec 0052, G3 #6).
  List<({Score score, List<OutlineSplitProposal> proposals})>
  _splitSuggestions = const [];
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
      _outlineLoader =
          widget.loadOutline ??
          (widget.library == null ? loadPdfOutline : null);
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
    final root = await openLibraryRoot();
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
    await _suggestSplits(imported);
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

  /// What to call each book when search matches a piece by its book's name.
  Map<String, String> get _bookNames {
    final byId = <String, String>{};
    for (final score in _scores) {
      if (!score.isRoot) continue;
      byId[score.pdfDocumentId] = score.title;
    }
    return byId;
  }

  /// Scores on the Library list after search/filter, then sorted (Spec 0055).
  List<Score> get _visibleScores {
    final labels = _labelStore;
    final filtered = visibleLibraryScores(
      scores: _scores,
      query: _searchQuery,
      bookmarkTitlesByScoreId: _bookmarkTitles,
      bookNameByDocumentId: _bookNames,
      assignments: labels?.assignments ?? const {},
      selectedLabelIds: _filterLabelIds,
      mode: _filterMode,
    );
    return sortLibraryScores(filtered, _sortMode, _scores);
  }

  Future<void> _setSortMode(LibrarySortMode mode) async {
    setState(() => _sortMode = mode);
    await _sortPrefsStore?.save(mode);
  }

  Future<void> _backupLibrary() async {
    final root = _libraryRoot;
    if (root == null) return;
    final messenger = ScaffoldMessenger.of(context);

    // Confirm before paying the cost of zipping the whole library — tapping
    // the menu item to explore should not start a multi-minute job (Spec 0050).
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create backup?'),
        content: const Text(
          'This zips every Score, annotation, Label, Setlist, and preference '
          'into one file you can share or save. A large library can take a '
          'while.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create backup'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

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
      final zip = File(p.join(exports.path, 'StageScore-backup-$stamp.zip'));
      final cancelled = await _runBackupJob(
        title: 'Creating backup…',
        run: (onProgress, cancelToken) => const LibraryBackup().createBackup(
          libraryRoot: root,
          zipFile: zip,
          onProgress: onProgress,
          cancelToken: cancelToken,
        ),
      );
      if (cancelled || !mounted) return;
      try {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(zip.path, mimeType: 'application/zip')],
            subject: 'StageScore backup',
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
    } on LibraryBackupCancelledException {
      // Dialog already closed; nothing to report.
    } catch (e) {
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

    try {
      final cancelled = await _runBackupJob(
        title: 'Restoring backup…',
        run: (onProgress, cancelToken) => const LibraryBackup().restoreBackup(
          zipFile: File(path),
          libraryRoot: root,
          onProgress: onProgress,
          cancelToken: cancelToken,
        ),
      );
      if (cancelled || !mounted) return;
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
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Library restored from backup')),
      );
    } on LibraryBackupCancelledException {
      // Dialog already closed; library left intact.
    } on LibraryBackupException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Restore failed: $e')));
    }
  }

  /// Determinate progress + Cancel for backup/restore (Spec 0050).
  ///
  /// Returns `true` when the musician cancelled. Throws on failure after the
  /// dialog is dismissed.
  Future<bool> _runBackupJob({
    required String title,
    required Future<void> Function(
      void Function(BackupProgress progress) onProgress,
      LibraryBackupCancelToken cancelToken,
    )
    run,
  }) async {
    final cancelToken = LibraryBackupCancelToken();
    final progress = ValueNotifier<BackupProgress>(
      const BackupProgress(fraction: 0),
    );

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: ValueListenableBuilder<BackupProgress>(
          valueListenable: progress,
          builder: (context, value, _) {
            final percent = (value.fraction * 100).clamp(0, 100).round();
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(value: value.fraction),
                  const SizedBox(height: AppSpacing.md),
                  Text('$percent%'),
                  if (value.label != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      value.label!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
              actions: [
                if (value.canCancel)
                  TextButton(
                    onPressed: cancelToken.cancel,
                    child: const Text('Cancel'),
                  ),
              ],
            );
          },
        ),
      ),
    );

    try {
      await run((p) {
        progress.value = p;
      }, cancelToken);
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      return false;
    } on LibraryBackupCancelledException {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      return true;
    } catch (_) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      rethrow;
    } finally {
      progress.dispose();
    }
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

  /// What the filter is doing, in a sentence (Spec 0040).
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

  /// The active Label filter, spelled out under the search field.
  Widget _buildFilterChips(BuildContext context) {
    final theme = Theme.of(context);
    final untagged = _filterMode == LabelFilterMode.untagged;
    final store = _labelStore;
    final chips = <({_FilterChipKind kind, String? id, String name})>[
      if (untagged)
        (kind: _FilterChipKind.untagged, id: null, name: 'Untagged')
      else
        for (final label in store?.labels ?? const <Label>[])
          if (_filterLabelIds.contains(label.id))
            (kind: _FilterChipKind.label, id: label.id, name: label.name),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (_filterMode == LabelFilterMode.all && chips.length > 1)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
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
                    onDeleted: () => _removeFilterChip(chip.kind, chip.id),
                  ),
              ],
            ),
          ),
          TextButton(onPressed: _clearFilter, child: const Text('Clear')),
        ],
      ),
    );
  }

  void _removeFilterChip(_FilterChipKind kind, String? id) {
    switch (kind) {
      case _FilterChipKind.untagged:
        _clearFilter();
      case _FilterChipKind.label:
        setState(() => _filterLabelIds = {..._filterLabelIds}..remove(id));
    }
  }

  bool get _searchActive => _searchQuery.trim().isNotEmpty;

  Future<void> _openFilter() async {
    final store = _labelStore;
    if (store == null) return;
    await showLibraryFilterSheet(
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

    // The file may be shared by every piece of a book, and the person pressing
    // the button is thinking about the one they just opened — so the count goes
    // in the sentence, not in a footnote (Spec 0052).
    final sharing = await library.scoresSharingDocument(score.id);
    final others = sharing - 1;

    if (!mounted) return;
    final choice = await showDialog<ReplacePdfOverlayChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace PDF'),
        content: Text(
          others > 0
              ? 'This PDF holds $sharing scores. Replacing it changes '
                    '“${score.title}” and $others '
                    '${others == 1 ? 'other score' : 'other scores'} that share '
                    'the same file. Choose whether to keep annotations, '
                    'bookmarks, jump links, and page order — or reset them.'
              : 'Replace the file for “${score.title}”? '
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
      final result = await library.replacePdf(
        scoreId: score.id,
        sourcePath: path,
        overlays: choice,
      );
      await _reload();
      if (!mounted) return;
      final overlayNote = choice == ReplacePdfOverlayChoice.reset
          ? 'overlays reset'
          : 'overlays kept';
      // A shorter file can leave a piece describing pages that no longer
      // exist. Saying so is the point: silently repairing it is how a musician
      // finds out on stage.
      final shortened = result.truncated.length + result.reset.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            shortened == 0
                ? 'PDF replaced; $overlayNote.'
                : 'PDF replaced; $overlayNote. The new file is shorter, so '
                      '$shortened ${shortened == 1 ? 'score' : 'scores'} '
                      'no longer cover the same pages.',
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

    final imported = await library.importPdfs(files);
    await _reload();
    await _suggestSplits(imported);
  }

  /// Offer to split whatever came in looking like a collection.
  ///
  /// After the import, never inside it: import takes many files at once, so a
  /// question per file would turn one import of a dozen pieces into a dozen
  /// dialogs. Someone importing a single piece sees no extra step at all.
  Future<void> _suggestSplits(List<Score> imported) async {
    final library = _library;
    if (library == null || _outlineLoader == null) return;
    final found = <({Score score, List<OutlineSplitProposal> proposals})>[];
    for (final score in imported) {
      final pdf = library.absoluteFileOrNull(score);
      if (pdf == null) continue;
      final proposals = await _outlineProposals(pdf.path);
      final looks = looksLikeCollection(
        pageCount: library.pageCountOf(score),
        proposals: proposals,
      );
      if (looks) found.add((score: score, proposals: proposals));
    }
    if (found.isEmpty || !mounted) return;
    setState(() => _splitSuggestions = found);
  }

  Future<List<OutlineSplitProposal>> _outlineProposals(String path) async {
    final loader = _outlineLoader;
    if (loader == null) return const [];
    final outline = await loader(path);
    if (outline == null) return const [];
    return proposeSplitFromOutline(outline);
  }

  void _dismissSuggestion(String scoreId) {
    if (!_splitSuggestions.any((s) => s.score.id == scoreId)) return;
    setState(() {
      _splitSuggestions = [
        for (final suggestion in _splitSuggestions)
          if (suggestion.score.id != scoreId) suggestion,
      ];
    });
  }

  /// Whether this Score holds enough pages to be carved into pieces.
  ///
  /// A root splits only while it has no children yet — once it does, further
  /// carving happens on the children (Spec 0055). A child with two or more
  /// pages can always be resplit into siblings under the same root.
  bool _canSplit(Score score) {
    final document = _library?.documentFor(score);
    final pageCount = document?.pageCount;
    if (pageCount == null || pageCount < 2) return false;
    final extent = score.extentIn(pageCount);
    if (extent == null || extent.length < 2) return false;
    if (score.isRoot) {
      return childrenOfRoot(_scores, score.id).isEmpty;
    }
    return true;
  }

  /// Whether this Score is a child, so its pages can be moved.
  bool _isPiece(Score score) => score.parentId != null;

  Future<void> _splitScore(
    Score score, {
    List<OutlineSplitProposal>? proposals,
  }) async {
    final library = _library;
    final root = _libraryRoot;
    if (library == null || root == null) return;
    final document = library.documentFor(score);
    final pageCount = document?.pageCount;
    final pdf = library.absoluteFileOrNull(score);
    final pages = pageCount == null ? null : score.extentIn(pageCount);
    if (document == null || pageCount == null || pdf == null || pages == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Still reading this PDF — try again in a moment.'),
        ),
      );
      return;
    }
    final wholeFile = pages.coversWholeDocument(pageCount);

    final suggested = proposals ?? await _outlineProposals(pdf.path);
    if (!mounted) return;
    var bookTitle = score.title;
    if (!score.isRoot) {
      bookTitle = document.displayName;
      for (final s in _scores) {
        if (s.id == score.parentId) {
          bookTitle = s.title;
          break;
        }
      }
    }
    final marks = await Navigator.of(context).push<List<SplitMark>>(
      MaterialPageRoute(
        builder: (_) => SplitScoreScreen(
          bookTitle: bookTitle,
          pdf: pdf,
          documentId: document.id,
          pages: pages,
          fixedFirstTitle: wholeFile ? null : score.title,
          thumbnails: _thumbnails,
          proposals: suggested,
        ),
      ),
    );
    _dismissSuggestion(score.id);
    // Fewer than two pieces is not a split: one mark either leaves the book as
    // it already is or only trims its front matter, and changing which pages one
    // Score covers is what the Pages screen is for. Save is disabled there too;
    // this is the second line.
    if (marks == null || marks.length < 2 || !mounted) return;

    if (!await _confirmSplitPageOrder(score, marks, pages)) return;

    final scores = await library.splitScore(scoreId: score.id, marks: marks);
    final rootId = score.parentId ?? score.id;
    final pieces = childrenOfRoot(scores, rootId);
    await handOverPageScales(
      root: root,
      originalScoreId: score.id,
      pieces: pieces,
    );
    // Resplitting a child keeps that child's id on the first sibling, so its
    // page order must narrow. A first split of a root leaves the root's order
    // alone — it still covers the whole file (Spec 0055).
    final kept = scores.firstWhere((s) => s.id == score.id);
    final keptExtent = kept.pageExtent;
    if (keptExtent != null) {
      await restrictPageOrderTo(
        root: root,
        scoreId: kept.id,
        extent: keptExtent,
      );
    }
    await _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Split into ${marks.length} pieces')),
    );
  }

  /// Resplitting a child narrows the page order on the Score that keeps its id.
  /// Says the count first — being told afterwards is being told too late
  /// (Spec 0052, G3 #5). A first split of a root does not narrow anything.
  Future<bool> _confirmSplitPageOrder(
    Score score,
    List<SplitMark> marks,
    PageExtent pages,
  ) async {
    if (score.isRoot) return true;
    final root = _libraryRoot;
    if (root == null) return false;
    final starts = [for (final mark in marks) mark.startPage]..sort();
    final first = PageExtent(
      firstPage: starts.first.clamp(pages.firstPage, pages.lastPage),
      lastPage: (starts[1] - 1).clamp(pages.firstPage, pages.lastPage),
    );
    final dropping = await pageOrderSlotsOutside(
      root: root,
      scoreId: score.id,
      extent: first,
    );
    if (!mounted) return false;
    if (dropping == 0) return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Split into pieces?'),
        content: Text(
          '$dropping ${dropping == 1 ? 'slot' : 'slots'} in the page order of '
          '“${score.title}” point outside pages '
          '${first.firstPage}–${first.lastPage} and will be removed. '
          'Annotations on those pages are kept with the pieces that hold them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Split'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _editPageExtent(Score score) async {
    final library = _library;
    final root = _libraryRoot;
    if (library == null || root == null) return;
    final document = library.documentFor(score);
    final pageCount = document?.pageCount;
    final pdf = library.absoluteFileOrNull(score);
    final current = score.pageExtent;
    if (document == null ||
        pageCount == null ||
        pdf == null ||
        current == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Still reading this PDF — try again in a moment.'),
        ),
      );
      return;
    }

    final next = await Navigator.of(context).push<PageExtent>(
      MaterialPageRoute(
        builder: (_) => PageExtentScreen(
          scoreTitle: score.title,
          pdf: pdf,
          documentId: document.id,
          pageCount: pageCount,
          initial: current,
          thumbnails: _thumbnails,
        ),
      ),
    );
    if (next == null || next == current || !mounted) return;

    // Annotations outside the new pages are only hidden, but a performance
    // sequence has to stay consistent — so slots are dropped, and the count is
    // said before the change, not reported after it (Spec 0052, G3 #5).
    final dropping = await pageOrderSlotsOutside(
      root: root,
      scoreId: score.id,
      extent: next,
    );
    if (!mounted) return;
    if (dropping > 0) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Change pages?'),
          content: Text(
            '$dropping ${dropping == 1 ? 'slot' : 'slots'} in the page order '
            'of “${score.title}” point outside pages '
            '${next.firstPage}–${next.lastPage} and will be removed. '
            'Annotations on those pages are kept, and come back if you widen '
            'the pages again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Change pages'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    await library.updatePageExtent(scoreId: score.id, extent: next);
    await restrictPageOrderTo(root: root, scoreId: score.id, extent: next);
    await _reload();
  }

  Future<void> _importSample() async {
    final library = _library;
    if (library == null) return;

    final bytes = await rootBundle.load('assets/sample_score.pdf');
    final temp = File(
      p.join(
        (await getTemporaryDirectory()).path,
        'stagescore_sample_score.pdf',
      ),
    );
    await temp.writeAsBytes(bytes.buffer.asUint8List());
    await library.importPdf(
      sourcePath: temp.path,
      originalFileName: 'Sample Score.pdf',
    );
    await _reload();
  }

  /// Tap on a Library row: roots with children drill in; everything else opens.
  Future<void> _onScoreRowTap(Score score) async {
    if (score.isRoot && childrenOfRoot(_scores, score.id).isNotEmpty) {
      await _openPieces(score);
      return;
    }
    await _openScore(score);
  }

  Future<void> _openPieces(Score root) async {
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (piecesContext) => PiecesScreen(
          root: root,
          pieces: childrenOfRoot(_scores, root.id),
          library: _library!,
          thumbnails: _thumbnails,
          labelNames: _labelNames,
          canSplit: _canSplit,
          onOpenPiece: (piece) async {
            Navigator.of(piecesContext).pop();
            await _openScore(piece);
          },
          onOpenFullScore: () async {
            Navigator.of(piecesContext).pop();
            await _openScore(root);
          },
          onRename: (piece) async {
            Navigator.of(piecesContext).pop();
            await _renameScore(piece);
          },
          onLabels: (piece) async {
            Navigator.of(piecesContext).pop();
            await _editScoreLabels(piece);
          },
          onSplit: (piece) async {
            Navigator.of(piecesContext).pop();
            await _splitScore(piece);
          },
          onPages: (piece) async {
            Navigator.of(piecesContext).pop();
            await _editPageExtent(piece);
          },
          onReplace: (piece) async {
            Navigator.of(piecesContext).pop();
            await _replacePdf(piece);
          },
          onDelete: (piece) async {
            Navigator.of(piecesContext).pop();
            await _deleteScore(piece);
          },
        ),
      ),
    );
    await _reload();
  }

  Future<void> _openScore(Score score) async {
    final library = _library;
    if (library == null) return;
    final updated = await library.markOpened(score);
    final path = library.absoluteFile(updated).path;
    final document = library.documentFor(updated);
    final childIds = childrenOfRoot(_scores, score.id).map((s) => s.id).toList();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PdfModeScreen(
          score: updated,
          filePath: path,
          originLine: scoreOriginLine(
            extent: updated.pageExtent,
            documentName: document?.displayName,
            documentPageCount: document?.pageCount,
          ),
          pieceScoreIds: score.isRoot && score.pageExtent == null
              ? childIds
              : const [],
        ),
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
    final children = childrenOfRoot(_scores, score.id);
    final content = children.isEmpty
        ? 'Delete “${score.title}” from the Library? '
            'The PDF, annotations, bookmarks, jump links, and page order '
            'will be removed. This cannot be undone.'
        : 'Delete “${score.title}” and its ${children.length} '
            '${children.length == 1 ? 'piece' : 'pieces'}? '
            'The PDF and every overlay on the book and its pieces will be '
            'removed. This cannot be undone.';
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete score?'),
        content: Text(content),
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
    final doomed = [score.id, ...children.map((c) => c.id)];
    await library.deleteScore(score.id);
    for (final id in doomed) {
      await _labelStore?.setScoreLabels(id, {});
      await setlists.removeScoreFromAll(id);
      await _thumbnails?.evict(id);
    }
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: 'StageScore',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Image.asset(
              'assets/brand/stagescore-logo.png',
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  children: [
                    const Icon(Icons.sort),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _sortMode.label,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: 'Filter',
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
                case 'about':
                  showAboutSheet(
                    context: context,
                    readBuild: widget.readBuild,
                    launch: widget.launchUrl,
                  );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'appearance', child: Text('Appearance…')),
              PopupMenuItem(value: 'backup', child: Text('Backup…')),
              PopupMenuItem(value: 'restore', child: Text('Restore…')),
              PopupMenuItem(
                value: 'about',
                child: Text('About ${Brand.productName}…'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
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
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search titles, books & bookmarks',
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
          if (!_loading &&
              _tab == _LibraryTab.scores &&
              _splitSuggestions.isNotEmpty)
            _buildSplitSuggestion(context, _splitSuggestions.first),
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

  /// One bar at the top of the list offering to split a book that just came in.
  ///
  /// Says what it noticed rather than what it wants, and is dismissable, so a
  /// musician who imported a 40-page single piece is not being corrected.
  Widget _buildSplitSuggestion(
    BuildContext context,
    ({Score score, List<OutlineSplitProposal> proposals}) suggestion,
  ) {
    final theme = Theme.of(context);
    final score = suggestion.score;
    final name = _library?.documentFor(score)?.displayName ?? score.title;
    final pages = _library?.pageCountOf(score);
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // Length only, never a count of contents entries: a book with two
            // bookmarks and twenty-eight pieces made that number a claim the
            // file could not back (Spec 0052, G3 #11). The count belongs on the
            // split screen, where it labels the action that acts on it.
            pages != null
                ? '“$name” is $pages pages — split it into pieces?'
                : '“$name” looks like a collection — split it into pieces?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _dismissSuggestion(score.id),
                child: const Text('Not now'),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton(
                onPressed: () =>
                    _splitScore(score, proposals: suggestion.proposals),
                child: const Text('Split…'),
              ),
            ],
          ),
        ],
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
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.library_music_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No scores yet',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Import PDF sheet music from your device to build your library.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: _importPdfs,
                icon: const Icon(Icons.add),
                label: const Text('Add PDF'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: _importSample,
                child: const Text('Add sample score'),
              ),
              // The only screen every new install passes through, so it is the
              // only place the publisher line can land before someone goes
              // looking for it in ⋯ → About (Spec 0042). A caption, not a
              // banner: it must not compete with Add PDF.
              const SizedBox(height: AppSpacing.xl),
              Text(
                Brand.publisherLine,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final scores = _visibleScores;
    if (scores.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
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
              const SizedBox(height: AppSpacing.md),
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
      padding: const EdgeInsets.only(bottom: kFabScrollClearance),
      itemCount: scores.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final score = scores[index];
        final labelNames = _labelNames[score.id] ?? const <String>[];
        final pdf = library?.absoluteFileOrNull(score);
        final document = library?.documentFor(score);
        final childCount = score.isRoot
            ? childrenOfRoot(_scores, score.id).length
            : 0;
        final inRoot = childInRootSubtitle(score, _scores);
        final origin = score.isRoot
            ? null
            : scoreOriginLine(
                extent: score.pageExtent,
                documentName: inRoot == null ? document?.displayName : null,
                documentPageCount: document?.pageCount,
              );
        final hasChildren = childCount > 0;
        return ListTile(
          leading: pdf == null
              ? const Icon(Icons.picture_as_pdf_outlined)
              : ScoreThumbnailTile(
                  thumbnails: _thumbnails,
                  scoreId: score.id,
                  pdf: pdf,
                  pageNumber: score.firstAbsolutePage,
                ),
          title: Text(score.title),
          isThreeLine:
              labelNames.isNotEmpty || origin != null || inRoot != null || hasChildren,
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasChildren
                    ? '${_recencyLine(score)} · $childCount '
                        '${childCount == 1 ? 'piece' : 'pieces'}'
                    : _recencyLine(score),
              ),
              if (inRoot != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(inRoot),
                ),
              if (origin != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(origin),
                ),
              if (labelNames.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: _LabelChips(names: labelNames),
                ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'open_full':
                  _openScore(score);
                case 'rename':
                  _renameScore(score);
                case 'labels':
                  _editScoreLabels(score);
                case 'split':
                  _splitScore(score);
                case 'pages':
                  _editPageExtent(score);
                case 'replace':
                  _replacePdf(score);
                case 'delete':
                  _deleteScore(score);
              }
            },
            itemBuilder: (context) => [
              if (hasChildren)
                const PopupMenuItem(
                  value: 'open_full',
                  child: Text('Open full score'),
                ),
              const PopupMenuItem(value: 'rename', child: Text('Rename…')),
              const PopupMenuItem(value: 'labels', child: Text('Labels…')),
              if (_canSplit(score))
                const PopupMenuItem(
                  value: 'split',
                  child: Text('Split into pieces…'),
                ),
              if (_isPiece(score))
                const PopupMenuItem(value: 'pages', child: Text('Pages…')),
              const PopupMenuItem(
                value: 'replace',
                child: Text('Replace PDF…'),
              ),
              const PopupMenuItem(value: 'delete', child: Text('Delete…')),
            ],
          ),
          onTap: () => _onScoreRowTap(score),
        );
      },
    );
  }

  /// "Opened today · 4 pages" — when it was last played, and how long it is.
  String _recencyLine(Score score) {
    final when = score.lastOpenedAt == null
        ? 'Added ${relativeDay(score.createdAt)}'
        : 'Opened ${relativeDay(score.lastOpenedAt!)}';
    final pages = _library?.pageCountOf(score);
    if (pages == null) return when;
    return '$when · $pages ${pages == 1 ? 'page' : 'pages'}';
  }

  Widget _buildSetlistsBody(BuildContext context) {
    if (_setlists.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.queue_music,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No setlists yet',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Group scores for continuous performance without reopening each piece.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
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
      padding: const EdgeInsets.only(bottom: kFabScrollClearance),
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
      // The 2 is measured, not a step: it is what makes this label sit at the
      // same height as the compact InputChip in the filter row above it.
      // Allowlisted in `test/design_token_guard_test.dart`.
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.sm),
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
