import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_handler/share_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stagescore/bookmark/bookmark_store.dart';
import 'package:stagescore/brand/brand.dart';
import 'package:stagescore/jumplink/jump_link_store.dart';
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
import 'package:stagescore/library/piece_resplit.dart';
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
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/theme/app_appearance.dart';
import 'package:stagescore/theme/app_locale_pref.dart';
import 'package:stagescore/theme/app_tokens.dart';
import 'package:stagescore/ui/about_sheet.dart';
import 'package:stagescore/ui/appearance_sheet.dart';
import 'package:stagescore/ui/language_sheet.dart';
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
    this.localePref = AppLocalePref.system,
    this.onLocaleChanged,
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

  final AppLocalePref localePref;
  final ValueChanged<AppLocalePref>? onLocaleChanged;

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
    final l10n = AppLocalizations.of(context);
    if (imported.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.libraryScreenNoPdfFiles)));
      return;
    }
    setState(() => _tab = _LibraryTab.scores);
    await _reload();
    if (!mounted) return;
    final n = imported.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.libraryScreenImportedScores(n))),
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
    final l10n = AppLocalizations.of(context);

    // Confirm before paying the cost of zipping the whole library — tapping
    // the menu item to explore should not start a multi-minute job (Spec 0050).
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.libraryScreenCreateBackupTitle),
        content: Text(l10n.libraryScreenCreateBackupBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.libraryScreenCreateBackupConfirm),
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
        title: l10n.libraryScreenCreatingBackup,
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
            subject: l10n.libraryScreenBackupShareSubject,
          ),
        );
      } on MissingPluginException {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.libraryScreenBackupSaved(zip.path))),
        );
        return;
      }
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.libraryScreenBackupReady)),
      );
    } on LibraryBackupCancelledException {
      // Dialog already closed; nothing to report.
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.libraryScreenBackupFailed(e.toString()))),
      );
    }
  }

  Future<void> _restoreLibrary() async {
    final root = _libraryRoot;
    if (root == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

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
        title: Text(l10n.libraryScreenRestoreBackupTitle),
        content: Text(l10n.libraryScreenRestoreBackupBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.libraryScreenReplaceAll),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final cancelled = await _runBackupJob(
        title: l10n.libraryScreenRestoringBackup,
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
        SnackBar(content: Text(l10n.libraryScreenLibraryRestored)),
      );
    } on LibraryBackupCancelledException {
      // Dialog already closed; library left intact.
    } on LibraryBackupException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.libraryScreenRestoreFailed(e.toString()))),
      );
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
            final l10n = AppLocalizations.of(context);
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(value: value.fraction),
                  const SizedBox(height: AppSpacing.md),
                  Text(l10n.libraryScreenPercentValue(percent)),
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
                    child: Text(l10n.actionCancel),
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
    final l10n = AppLocalizations.of(context);
    if (_filterMode == LabelFilterMode.untagged) {
      return l10n.libraryScreenUntagged;
    }
    final names = _activeFilterNames;
    if (names.isEmpty) return l10n.libraryScreenThisFilter;
    final joiner = _filterMode == LabelFilterMode.all
        ? ' ${l10n.libraryScreenAndConjunction} '
        : ' ${l10n.commonOr} ';
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
    final l10n = AppLocalizations.of(context);
    final untagged = _filterMode == LabelFilterMode.untagged;
    final store = _labelStore;
    final chips = <({_FilterChipKind kind, String? id, String name})>[
      if (untagged)
        (
          kind: _FilterChipKind.untagged,
          id: null,
          name: l10n.libraryScreenUntagged,
        )
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
              child: Text(
                l10n.libraryScreenAllOf,
                style: theme.textTheme.labelMedium,
              ),
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
                    deleteButtonTooltipMessage: l10n
                        .libraryScreenRemoveFilterChip(chip.name),
                    onDeleted: () => _removeFilterChip(chip.kind, chip.id),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: _clearFilter,
            child: Text(l10n.actionClear),
          ),
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
      title: AppLocalizations.of(context).libraryScreenRenameScoreTitle,
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
    final dialogL10n = AppLocalizations.of(context);
    final choice = await showDialog<ReplacePdfOverlayChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dialogL10n.libraryScreenReplacePdfTitle),
        content: Text(
          others > 0
              ? dialogL10n.libraryScreenReplacePdfBodyShared(
                  sharing,
                  score.title,
                  others,
                )
              : dialogL10n.libraryScreenReplacePdfBodySingle(score.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(dialogL10n.actionCancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, ReplacePdfOverlayChoice.keep),
            child: Text(dialogL10n.libraryScreenKeepOverlays),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, ReplacePdfOverlayChoice.reset),
            child: Text(dialogL10n.libraryScreenResetOverlays),
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
      final l10n = AppLocalizations.of(context);
      final overlayNote = choice == ReplacePdfOverlayChoice.reset
          ? l10n.libraryScreenOverlaysReset
          : l10n.libraryScreenOverlaysKept;
      // A shorter file can leave a piece describing pages that no longer
      // exist. Saying so is the point: silently repairing it is how a musician
      // finds out on stage.
      final shortened = result.truncated.length + result.reset.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            shortened == 0
                ? l10n.libraryScreenPdfReplaced(overlayNote)
                : l10n.libraryScreenPdfReplacedShortened(
                    overlayNote,
                    shortened,
                  ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).libraryScreenReplaceFailed(
              e.toString(),
            ),
          ),
        ),
      );
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
        SnackBar(
          content: Text(
            AppLocalizations.of(context).libraryScreenStillReadingPdf,
          ),
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
      SnackBar(
        content: Text(
          AppLocalizations.of(context).libraryScreenSplitIntoPiecesSnackbar(
            marks.length,
          ),
        ),
      ),
    );
  }

  /// Redefine where a root's pieces begin ("Edit pieces", Spec 0055 follow-up).
  ///
  /// Unlike [_splitScore] on a root with no children yet, this reopens the
  /// whole document with today's boundaries already checked, and — via
  /// [ScoreLibrary.editPieces] — keeps a piece's id (and its annotations,
  /// bookmarks, jump links, Labels and Setlist membership) wherever its exact
  /// page range survives. A piece with no surviving range is deleted; the
  /// musician is warned first if that piece is not empty.
  Future<void> _editPieces(Score root) async {
    final library = _library;
    final libraryRoot = _libraryRoot;
    if (library == null || libraryRoot == null) return;
    final document = library.documentFor(root);
    final pageCount = document?.pageCount;
    final pdf = library.absoluteFileOrNull(root);
    if (document == null || pageCount == null || pdf == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).libraryScreenStillReadingPdf,
          ),
        ),
      );
      return;
    }
    final bounds = PageExtent.whole(pageCount);
    final oldChildren = childrenOfRoot(_scores, root.id);
    final suggested = await _outlineProposals(pdf.path);
    if (!mounted) return;

    final marks = await Navigator.of(context).push<List<SplitMark>>(
      MaterialPageRoute(
        builder: (_) => SplitScoreScreen(
          bookTitle: root.title,
          pdf: pdf,
          documentId: document.id,
          pages: bounds,
          thumbnails: _thumbnails,
          proposals: suggested,
          initialMarks: [
            for (final piece in oldChildren)
              (startPage: piece.firstAbsolutePage, title: piece.title),
          ],
          appBarTitle: AppLocalizations.of(context).libraryScreenEditPiecesAppBarTitle,
        ),
      ),
    );
    if (marks == null || marks.length < 2 || !mounted) return;

    final preview = planPieceResplit(
      oldChildren: oldChildren,
      marks: marks,
      bounds: bounds,
      rootId: root.id,
      pdfDocumentId: document.id,
      bookTitle: root.title,
      now: DateTime.now().toUtc(),
      nextId: () => '',
    );
    if (!await _confirmEditPieces(oldChildren, preview.removedIds)) return;

    final plan = await library.editPieces(rootId: root.id, marks: marks);
    for (final id in plan.removedIds) {
      await handOverPageScales(
        root: libraryRoot,
        originalScoreId: id,
        pieces: plan.children,
      );
      await _labelStore?.setScoreLabels(id, {});
      await _setlistStore?.removeScoreFromAll(id);
      await _thumbnails?.evict(id);
    }
    await _reload();
    if (!mounted) return;
    final count = plan.children.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).libraryScreenUpdatedPieces(count),
        ),
      ),
    );
  }

  /// Whether any piece about to disappear holds annotations, bookmarks, jump
  /// links, a Label, or Setlist membership — and if so, asks before that data
  /// is deleted along with it (Spec 0055 follow-up G3 — data-loss policy).
  Future<bool> _confirmEditPieces(
    List<Score> oldChildren,
    List<String> removedIds,
  ) async {
    if (removedIds.isEmpty) return true;
    final atRisk = <Score>[];
    for (final id in removedIds) {
      final piece = oldChildren.firstWhere((c) => c.id == id);
      if (await _pieceHasData(id)) atRisk.add(piece);
    }
    if (atRisk.isEmpty) return true;
    if (!mounted) return false;
    final names = atRisk.map((s) => '“${s.title}”').join(', ');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.libraryScreenEditPiecesDialogTitle),
          content: Text(
            l10n.libraryScreenEditPiecesBody(names, atRisk.length),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.actionContinue),
            ),
          ],
        );
      },
    );
    return ok == true;
  }

  /// Whether [scoreId] holds anything a musician would miss: ink, a bookmark,
  /// a jump link, a MeasureMap, a Label, or Setlist membership.
  Future<bool> _pieceHasData(String scoreId) async {
    final root = _library?.root;
    if (root == null) return false;
    final annotationsFile = File(
      p.join(root.path, 'annotations', '$scoreId.json'),
    );
    if (await annotationsFile.exists()) {
      try {
        final json =
            jsonDecode(await annotationsFile.readAsString())
                as Map<String, dynamic>;
        final strokes = json['strokes'] as List<dynamic>? ?? const [];
        final stamps = json['stamps'] as List<dynamic>? ?? const [];
        if (strokes.isNotEmpty || stamps.isNotEmpty) return true;
      } catch (_) {
        // An unreadable file is not "no data" — better to warn than to lose it.
        return true;
      }
    }
    final measureMapFile = File(
      p.join(root.path, 'measure_maps', '$scoreId.json'),
    );
    if (await measureMapFile.exists()) {
      try {
        final json =
            jsonDecode(await measureMapFile.readAsString())
                as Map<String, dynamic>;
        final measures = json['measures'] as List<dynamic>? ?? const [];
        if (measures.isNotEmpty) return true;
      } catch (_) {
        return true;
      }
    }
    final formMapFile = File(p.join(root.path, 'form_maps', '$scoreId.json'));
    if (await formMapFile.exists()) {
      try {
        final json =
            jsonDecode(await formMapFile.readAsString()) as Map<String, dynamic>;
        final repeats = json['repeats'] as List<dynamic>? ?? const [];
        final endings = json['endings'] as List<dynamic>? ?? const [];
        final markers = json['markers'] as List<dynamic>? ?? const [];
        final jumps = json['jumps'] as List<dynamic>? ?? const [];
        if (repeats.isNotEmpty ||
            endings.isNotEmpty ||
            markers.isNotEmpty ||
            jumps.isNotEmpty) {
          return true;
        }
      } catch (_) {
        return true;
      }
    }
    if ((await BookmarkStore(root: root, scoreId: scoreId).list())
        .isNotEmpty) {
      return true;
    }
    if ((await JumpLinkStore(root: root, scoreId: scoreId).list())
        .isNotEmpty) {
      return true;
    }
    if ((_labelStore?.labelsForScore(scoreId) ?? const {}).isNotEmpty) {
      return true;
    }
    return _setlists.any((s) => s.scoreIds.contains(scoreId));
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
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.libraryScreenSplitIntoPiecesDialogTitle),
          content: Text(
            l10n.libraryScreenSplitPageOrderBody(
              dropping,
              score.title,
              first.firstPage,
              first.lastPage,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.libraryScreenSplitConfirm),
            ),
          ],
        );
      },
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
        SnackBar(
          content: Text(
            AppLocalizations.of(context).libraryScreenStillReadingPdf,
          ),
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
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return AlertDialog(
            title: Text(l10n.libraryScreenChangePagesTitle),
            content: Text(
              l10n.libraryScreenChangePagesBody(
                dropping,
                score.title,
                next.firstPage,
                next.lastPage,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.libraryScreenChangePagesConfirm),
              ),
            ],
          );
        },
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
          onEditPieces: () async {
            Navigator.of(piecesContext).pop();
            await _editPieces(root);
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
            l10n: AppLocalizations.of(context),
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
        SnackBar(
          content: Text(
            AppLocalizations.of(context).libraryScreenSetlistEmptyAddScores,
          ),
        ),
      );
      return;
    }

    final resolved = await SetlistSession.resolve(
      l10n: AppLocalizations.of(context),
      setlist: setlist,
      library: library,
    );
    if (!mounted) return;
    if (resolved.session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).libraryScreenNoScoresAvailable,
          ),
        ),
      );
      return;
    }
    if (resolved.skipped > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).libraryScreenSkippedMissingScores(resolved.skipped),
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
      title: AppLocalizations.of(context).libraryScreenNewSetlist,
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
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.libraryScreenDeleteSetlistTitle),
          content: Text(l10n.libraryScreenDeleteSetlistBody(setlist.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.actionDelete),
            ),
          ],
        );
      },
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        final content = children.isEmpty
            ? l10n.libraryScreenDeleteScoreBody(score.title)
            : l10n.libraryScreenDeleteScoreWithPiecesBody(
                score.title,
                children.length,
              );
        return AlertDialog(
          title: Text(l10n.libraryScreenDeleteScoreTitle),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.actionDelete),
            ),
          ],
        );
      },
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
          label: Brand.productName,
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
              tooltip: AppLocalizations.of(context).libraryScreenSort,
              enabled: !_loading,
              initialValue: _sortMode,
              onSelected: _setSortMode,
              itemBuilder: (context) {
                final l10n = AppLocalizations.of(context);
                return [
                  for (final mode in LibrarySortMode.values)
                    CheckedPopupMenuItem<LibrarySortMode>(
                      value: mode,
                      checked: _sortMode == mode,
                      child: Text(mode.label(l10n)),
                    ),
                ];
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  children: [
                    const Icon(Icons.sort),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _sortMode.label(AppLocalizations.of(context)),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: AppLocalizations.of(context).libraryScreenFilter,
              onPressed: _loading ? null : _openFilter,
              icon: Icon(
                _filterActive ? Icons.filter_alt : Icons.filter_alt_outlined,
              ),
            ),
            IconButton(
              tooltip: AppLocalizations.of(context).libraryScreenManageLabels,
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
            tooltip: AppLocalizations.of(context).libraryScreenMore,
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
                case 'language':
                  final onChanged = widget.onLocaleChanged;
                  if (onChanged == null) return;
                  showLanguageSheet(
                    context: context,
                    pref: widget.localePref,
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
            itemBuilder: (context) {
              final l10n = AppLocalizations.of(context);
              return [
                PopupMenuItem(
                  value: 'appearance',
                  child: Text(l10n.libraryScreenAppearance),
                ),
                PopupMenuItem(
                  value: 'language',
                  child: Text(l10n.libraryScreenLanguage),
                ),
                PopupMenuItem(
                  value: 'backup',
                  child: Text(l10n.libraryScreenBackup),
                ),
                PopupMenuItem(
                  value: 'restore',
                  child: Text(l10n.libraryScreenRestore),
                ),
                PopupMenuItem(
                  value: 'about',
                  child: Text(l10n.libraryScreenAbout(Brand.productName)),
                ),
              ];
            },
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
              segments: [
                ButtonSegment(
                  value: _LibraryTab.scores,
                  label: Text(AppLocalizations.of(context).libraryScreenTabScores),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                ),
                ButtonSegment(
                  value: _LibraryTab.setlists,
                  label: Text(
                    AppLocalizations.of(context).libraryScreenTabSetlists,
                  ),
                  icon: const Icon(Icons.queue_music),
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
                  hintText: AppLocalizations.of(context).libraryScreenSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchActive
                      ? IconButton(
                          tooltip: AppLocalizations.of(context).actionClear,
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
              label: Text(AppLocalizations.of(context).libraryScreenAddPdf),
            )
          : FloatingActionButton.extended(
              onPressed: _createSetlist,
              icon: const Icon(Icons.playlist_add),
              label: Text(
                AppLocalizations.of(context).libraryScreenNewSetlist,
              ),
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
    final l10n = AppLocalizations.of(context);
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
                ? l10n.libraryScreenSplitSuggestionWithPages(name, pages)
                : l10n.libraryScreenSplitSuggestionGeneric(name),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _dismissSuggestion(score.id),
                child: Text(l10n.libraryScreenNotNow),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton(
                onPressed: () =>
                    _splitScore(score, proposals: suggestion.proposals),
                child: Text(l10n.libraryScreenSplitEllipsis),
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
      return Center(
        child: Text(
          AppLocalizations.of(context).libraryScreenFailedToOpen(_error!),
        ),
      );
    }
    return _tab == _LibraryTab.scores
        ? _buildScoresBody(context)
        : _buildSetlistsBody(context);
  }

  Widget _buildScoresBody(BuildContext context) {
    if (_scores.isEmpty) {
      final l10n = AppLocalizations.of(context);
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
                l10n.libraryScreenNoScoresYet,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.libraryScreenImportPdfHint,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: _importPdfs,
                icon: const Icon(Icons.add),
                label: Text(l10n.libraryScreenAddPdf),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: _importSample,
                child: Text(l10n.libraryScreenAddSampleScore),
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
      final l10n = AppLocalizations.of(context);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _searchActive
                    ? l10n.libraryScreenNoScoresMatchSearch(
                        _searchQuery.trim(),
                      )
                    : l10n.libraryScreenNoScoresMatchFilter(
                        _filterDescription(),
                      ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              if (_searchActive)
                TextButton(
                  onPressed: () => _searchController.clear(),
                  child: Text(l10n.libraryScreenClearSearch),
                ),
              if (_filterActive)
                TextButton(
                  onPressed: _clearFilter,
                  child: Text(l10n.libraryScreenClearFilter),
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
        final l10n = AppLocalizations.of(context);
        final inRoot = childInRootSubtitle(l10n, score, _scores);
        final origin = score.isRoot
            ? null
            : scoreOriginLine(
                l10n: l10n,
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
                    ? l10n.libraryScreenRecencyWithPieces(
                        _recencyLine(score),
                        childCount,
                      )
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
                case 'pieces':
                  _openPieces(score);
                case 'edit_pieces':
                  _editPieces(score);
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
            itemBuilder: (context) {
              final l10n = AppLocalizations.of(context);
              return [
                // Menu parity with the row tap gesture (Spec 0055): tapping a
                // root with children drills into PiecesScreen, so "…" needs
                // its own path there too, not just the "Open full score"
                // shortcut.
                if (hasChildren)
                  PopupMenuItem(
                    value: 'pieces',
                    child: Text(l10n.libraryScreenPiecesEllipsis),
                  ),
                // Redraw where the book's pieces begin, seeded from today's
                // boundaries (Spec 0055 follow-up "Edit pieces").
                if (hasChildren)
                  PopupMenuItem(
                    value: 'edit_pieces',
                    child: Text(l10n.libraryScreenEditPiecesMenuItem),
                  ),
                if (hasChildren)
                  PopupMenuItem(
                    value: 'open_full',
                    child: Text(l10n.libraryScreenOpenFullScore),
                  ),
                PopupMenuItem(
                  value: 'rename',
                  child: Text(l10n.libraryScreenRenameEllipsis),
                ),
                PopupMenuItem(
                  value: 'labels',
                  child: Text(l10n.libraryScreenLabelsEllipsis),
                ),
                if (_canSplit(score))
                  PopupMenuItem(
                    value: 'split',
                    child: Text(l10n.libraryScreenSplitIntoPiecesEllipsis),
                  ),
                if (_isPiece(score))
                  PopupMenuItem(
                    value: 'pages',
                    child: Text(l10n.libraryScreenPagesEllipsis),
                  ),
                PopupMenuItem(
                  value: 'replace',
                  child: Text(l10n.libraryScreenReplacePdfEllipsis),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(l10n.libraryScreenDeleteEllipsis),
                ),
              ];
            },
          ),
          onTap: () => _onScoreRowTap(score),
        );
      },
    );
  }

  /// "Opened today · 4 pages" — when it was last played, and how long it is.
  String _recencyLine(Score score) {
    final l10n = AppLocalizations.of(context);
    final when = score.lastOpenedAt == null
        ? l10n.libraryScreenAddedRelative(relativeDay(l10n, score.createdAt))
        : l10n.libraryScreenOpenedRelative(
            relativeDay(l10n, score.lastOpenedAt!),
          );
    final pages = _library?.pageCountOf(score);
    if (pages == null) return when;
    return l10n.libraryScreenRecencyWithPages(when, pages);
  }

  Widget _buildSetlistsBody(BuildContext context) {
    if (_setlists.isEmpty) {
      final l10n = AppLocalizations.of(context);
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
                l10n.libraryScreenNoSetlistsYet,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.libraryScreenSetlistsEmptyHint,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: _createSetlist,
                icon: const Icon(Icons.playlist_add),
                label: Text(l10n.libraryScreenNewSetlist),
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
        final l10n = AppLocalizations.of(context);
        final scoreCount = l10n.libraryScreenSetlistScoreCount(count);
        return ListTile(
          leading: const Icon(Icons.queue_music),
          title: Text(setlist.title),
          subtitle: Text(
            count == 0
                ? l10n.libraryScreenSetlistCountEmpty
                : setlist.lastOpenedAt == null
                ? scoreCount
                : l10n.libraryScreenSetlistScoreCountOpened(
                    scoreCount,
                    l10n.libraryScreenOpenedRelative(
                      relativeDay(l10n, setlist.lastOpenedAt!),
                    ),
                  ),
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
            itemBuilder: (context) {
              final l10n = AppLocalizations.of(context);
              return [
                PopupMenuItem(value: 'edit', child: Text(l10n.actionEdit)),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(l10n.actionDelete),
                ),
              ];
            },
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
