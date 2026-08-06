import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:stagescore/library/library_migration.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/pdf_document.dart';
import 'package:stagescore/library/piece_resplit.dart';
import 'package:stagescore/library/score.dart';
import 'package:stagescore/library/score_overlays.dart';
import 'package:uuid/uuid.dart';

/// Whether to clear per-Score overlays when replacing a PDF (Spec 0024).
enum ReplacePdfOverlayChoice { keep, reset }

/// Pages in the PDF at [path], or null if it cannot be read (Spec 0040).
///
/// Injected so the library layer stays free of pdfrx: production passes the
/// pdfrx counter, tests pass whatever they need and get null by default.
typedef PdfPageCounter = Future<int?> Function(String path);

Future<int?> _unknownPageCount(String path) async => null;

/// Where a piece starts, for splitting one PDF into many Scores (Spec 0052).
typedef SplitMark = ({int startPage, String title});

/// What replacing a PDF did to the Scores sharing it (Spec 0052).
class ReplacePdfResult {
  const ReplacePdfResult({
    required this.scores,
    required this.sharedScoreCount,
    required this.truncated,
    required this.reset,
  });

  /// Every Score on the replaced document, after the replacement.
  final List<Score> scores;

  /// How many Scores share the file — what the dialog has to say out loud,
  /// because the person pressing the button is thinking about one piece.
  final int sharedScoreCount;

  /// Scores whose extent ran past the end of the new file and was shortened.
  final List<Score> truncated;

  /// Scores whose extent started past the end of the new file, so nothing
  /// could be salvaged and the extent fell back to the whole document.
  final List<Score> reset;

  bool get hasLosses => truncated.isNotEmpty || reset.isNotEmpty;
}

/// Local on-device Score library (PDF files + JSON manifest).
class ScoreLibrary {
  ScoreLibrary({
    required this._root,
    Uuid? uuid,
    this._countPages = _unknownPageCount,
  }) : _uuid = uuid ?? const Uuid();

  final Directory _root;
  final Uuid _uuid;
  final PdfPageCounter _countPages;

  /// Documents from the last manifest read, so [absoluteFile] can stay
  /// synchronous for callers inside a widget build.
  final Map<String, PdfDocument> _documentsById = {};

  Directory get root => _root;

  Directory get scoresDir => Directory(p.join(_root.path, 'scores'));

  /// Where PDFs imported since Spec 0052 are written.
  ///
  /// Documents migrated from before 0052 stay in `scores/`; the two layouts
  /// coexist permanently, which is safe because the path is stored data rather
  /// than a convention anything recomputes.
  Directory get documentsDir => Directory(p.join(_root.path, 'documents'));

  File get manifestFile => File(p.join(_root.path, 'library.json'));

  Future<void> ensureReady() async {
    if (!await _root.exists()) {
      await _root.create(recursive: true);
    }
    if (!await scoresDir.exists()) {
      await scoresDir.create(recursive: true);
    }
    if (!await documentsDir.exists()) {
      await documentsDir.create(recursive: true);
    }
    if (!await manifestFile.exists()) {
      await _write(const [], const []);
    }
  }

  /// Unordered manifest list; Library UI applies [sortScores] (Spec 0023).
  Future<List<Score>> listScores() async {
    await ensureReady();
    return (await _read()).scores;
  }

  Future<List<PdfDocument>> listDocuments() async {
    await ensureReady();
    return (await _read()).documents;
  }

  /// Run the PdfDocument migration if this library predates it (Spec 0052).
  ///
  /// Idempotent, and called from two places: opening the library, and finishing
  /// a restore. The second matters because a `version: 1` backup passes the
  /// version check and would otherwise drop a pre-0052 manifest into code that
  /// expects documents.
  Future<void> migrateIfNeeded() async {
    await ensureReady();
    await _read();
  }

  PdfDocument? documentFor(Score score) => _documentsById[score.pdfDocumentId];

  /// The cached manifest's documents, for building a whole list of rows at once.
  ///
  /// Unmodifiable and synchronous: grouping the Library happens inside a build,
  /// which may not wait on the disk.
  Map<String, PdfDocument> get documentsById => Map.unmodifiable(_documentsById);

  /// The PDF file holding [score].
  ///
  /// Throws rather than guessing when the document is unknown: every path that
  /// produces a Score has read the manifest first, so a miss is a bug, and a
  /// reconstructed path would be the exact mistake migration avoided.
  File absoluteFile(Score score) {
    final document = _documentsById[score.pdfDocumentId];
    if (document == null) {
      throw StateError(
        'No PdfDocument ${score.pdfDocumentId} for Score ${score.id}',
      );
    }
    return File(p.join(_root.path, document.relativePath));
  }

  /// The PDF file holding [score], or null when its document is unknown.
  ///
  /// For widget builds, where a manifest that lost a document must render a
  /// placeholder rather than take the Library down with it.
  File? absoluteFileOrNull(Score score) {
    final document = _documentsById[score.pdfDocumentId];
    if (document == null) return null;
    return File(p.join(_root.path, document.relativePath));
  }

  File absoluteFileForDocument(PdfDocument document) =>
      File(p.join(_root.path, document.relativePath));

  /// Pages in [score] — its extent's length, or the whole file when it has no
  /// extent. Null while the file has not been counted yet.
  int? pageCountOf(Score score) => score.pageCountIn(documentFor(score));

  Future<Score> importPdf({
    required String sourcePath,
    required String originalFileName,
  }) async {
    await ensureReady();
    final documentId = _uuid.v4();
    final relativePath = p.join('documents', '$documentId.pdf');
    final dest = File(p.join(_root.path, relativePath));
    await File(sourcePath).copy(dest.path);

    final now = DateTime.now().toUtc();
    final document = PdfDocument(
      id: documentId,
      relativePath: relativePath,
      importedAt: now,
      pageCount: await _countPages(dest.path),
      originalFileName: p.basename(originalFileName),
    );
    final score = Score(
      id: _uuid.v4(),
      title: _titleFromFileName(originalFileName),
      pdfDocumentId: documentId,
      createdAt: now,
    );

    final manifest = await _read();
    await _write([...manifest.scores, score], [...manifest.documents, document]);
    return score;
  }

  Future<List<Score>> importPdfs(
    Iterable<({String path, String name})> files,
  ) async {
    final imported = <Score>[];
    for (final file in files) {
      imported.add(
        await importPdf(sourcePath: file.path, originalFileName: file.name),
      );
    }
    return imported;
  }

  /// Split [scoreId] into one child Score per mark (Spec 0052, rewritten 0055).
  ///
  /// Splitting a root keeps that Score as the whole-file root (`pageExtent`
  /// null, title = book name) and creates **new** children for every mark —
  /// the opposite of 0052, which turned the original into the first piece.
  /// Resplitting a child replaces it with N siblings under the **same** root
  /// (one layer only); the first sibling keeps the child's id so its
  /// annotations and Setlist membership survive.
  ///
  /// Marks stay inside the Score's own PageExtent (Spec 0054). No mark can
  /// reach a page belonging to a sibling.
  Future<List<Score>> splitScore({
    required String scoreId,
    required List<SplitMark> marks,
  }) async {
    await ensureReady();
    final manifest = await _read();
    final index = manifest.scores.indexWhere((s) => s.id == scoreId);
    if (index < 0) throw StateError('Score not found: $scoreId');
    final original = manifest.scores[index];
    final document = manifest.documentById(original.pdfDocumentId);
    if (document == null) {
      throw StateError('No PdfDocument for Score $scoreId');
    }
    final pageCount = document.pageCount;
    if (pageCount == null) {
      throw StateError('Cannot split an uncounted PDF: ${document.id}');
    }
    if (marks.isEmpty) return manifest.scores;
    final bounds = original.extentIn(pageCount);
    if (bounds == null) {
      throw StateError('Score $scoreId covers no page of ${document.id}');
    }

    // Clamp first, then cut. A mark outside the bounds lands on the edge, and
    // two marks that end up on the same page are one mark: deriving each end
    // from the *unclamped* next start would hand the same page to two Scores.
    final sorted = [...marks]..sort((a, b) => a.startPage.compareTo(b.startPage));
    final kept = <SplitMark>[];
    for (final mark in sorted) {
      final start = mark.startPage.clamp(bounds.firstPage, bounds.lastPage);
      if (kept.isNotEmpty && start <= kept.last.startPage) continue;
      kept.add((startPage: start, title: mark.title));
    }
    final extents = [
      for (var i = 0; i < kept.length; i++)
        PageExtent(
          firstPage: kept[i].startPage,
          lastPage: i + 1 < kept.length
              ? kept[i + 1].startPage - 1
              : bounds.lastPage,
        ),
    ];

    final scores = [...manifest.scores];
    final now = DateTime.now().toUtc();
    final parentId = original.parentId;

    if (parentId != null) {
      // Resplit a child → N siblings under the same root. First keeps the id.
      scores[index] = original.copyWith(
        title: kept.first.title.trim().isEmpty
            ? original.title
            : kept.first.title.trim(),
        pageExtent: extents.first,
        parentId: parentId,
      );
      for (var i = 1; i < kept.length; i++) {
        scores.add(
          Score(
            id: _uuid.v4(),
            title: kept[i].title.trim().isEmpty
                ? '${original.title} — ${i + 1}'
                : kept[i].title.trim(),
            pdfDocumentId: document.id,
            pageExtent: extents[i],
            parentId: parentId,
            createdAt: now,
          ),
        );
      }
    } else {
      // First split of a root: keep it as the whole-file Score; every mark is
      // a new child. Setlist entries that pointed at this id now open the book.
      final bookTitle = document.displayName;
      scores[index] = original.copyWith(
        title: bookTitle,
        clearPageExtent: true,
        clearParentId: true,
      );
      for (var i = 0; i < kept.length; i++) {
        scores.add(
          Score(
            id: _uuid.v4(),
            title: kept[i].title.trim().isEmpty
                ? '$bookTitle — ${i + 1}'
                : kept[i].title.trim(),
            pdfDocumentId: document.id,
            pageExtent: extents[i],
            parentId: original.id,
            createdAt: now,
          ),
        );
      }
      // Keep the document title in sync with the root the musician sees.
      final docIndex = manifest.documents.indexWhere((d) => d.id == document.id);
      final documents = [...manifest.documents];
      if (docIndex >= 0 && document.title != bookTitle) {
        documents[docIndex] = document.copyWith(title: bookTitle);
      }
      await _write(scores, documents);
      return scores;
    }
    await _write(scores, manifest.documents);
    return scores;
  }

  /// Redefine a root's pieces from scratch ("Edit pieces", Spec 0055 follow-up).
  ///
  /// Unlike [splitScore], which only ever *adds* children, this **replaces**
  /// the current set with one child per mark — see [planPieceResplit] for the
  /// id-preserving match. The root itself (`pageExtent` null, whole file) is
  /// untouched. Clears overlays for every piece [PieceResplitPlan.removedIds]
  /// names; Label and Setlist cleanup for those ids is the caller's job, the
  /// same way it is for [deleteScore] today.
  Future<PieceResplitPlan> editPieces({
    required String rootId,
    required List<SplitMark> marks,
  }) async {
    await ensureReady();
    final manifest = await _read();
    final index = manifest.scores.indexWhere((s) => s.id == rootId);
    if (index < 0) throw StateError('Score not found: $rootId');
    final root = manifest.scores[index];
    if (!root.isRoot) {
      throw StateError('editPieces requires a root Score: $rootId');
    }
    final document = manifest.documentById(root.pdfDocumentId);
    if (document == null) {
      throw StateError('No PdfDocument for Score $rootId');
    }
    final pageCount = document.pageCount;
    if (pageCount == null) {
      throw StateError('Cannot split an uncounted PDF: ${document.id}');
    }

    final oldChildren = [
      for (final s in manifest.scores)
        if (s.parentId == rootId) s,
    ];
    final plan = planPieceResplit(
      oldChildren: oldChildren,
      marks: marks,
      bounds: PageExtent.whole(pageCount),
      rootId: rootId,
      pdfDocumentId: document.id,
      bookTitle: root.title,
      now: DateTime.now().toUtc(),
      nextId: _uuid.v4,
    );
    if (identical(plan.children, oldChildren)) return plan;

    final scores = [
      for (final s in manifest.scores)
        if (s.parentId != rootId) s,
      ...plan.children,
    ];
    await _write(scores, manifest.documents);
    for (final id in plan.removedIds) {
      await clearScoreOverlays(root: _root, scoreId: id);
    }
    return plan;
  }

  /// Change which pages of its document a Score covers (Spec 0052).
  ///
  /// Annotations outside the new extent are kept on disk and simply not shown:
  /// they are anchored to absolute document pages, so narrowing shifts nothing
  /// and widening brings them back intact.
  Future<Score> updatePageExtent({
    required String scoreId,
    required PageExtent? extent,
  }) async {
    await ensureReady();
    final manifest = await _read();
    final index = manifest.scores.indexWhere((s) => s.id == scoreId);
    if (index < 0) throw StateError('Score not found: $scoreId');
    final updated = extent == null
        ? manifest.scores[index].copyWith(clearPageExtent: true)
        : manifest.scores[index].copyWith(pageExtent: extent);
    final scores = [...manifest.scores]..[index] = updated;
    await _write(scores, manifest.documents);
    return updated;
  }

  /// Name the book, or clear the name to go back to the file name (Spec 0054).
  ///
  /// Touches no Score title, not even pieces carrying the default `<book> — 3`:
  /// those names were copied at split time and are the musician's now.
  Future<PdfDocument> renameDocument({
    required String documentId,
    required String? title,
  }) async {
    await ensureReady();
    final manifest = await _read();
    final index = manifest.documents.indexWhere((d) => d.id == documentId);
    if (index < 0) throw StateError('PdfDocument not found: $documentId');
    final trimmed = title?.trim();
    final blank = trimmed == null || trimmed.isEmpty;
    final updated = manifest.documents[index].copyWith(
      title: blank ? null : trimmed,
      clearTitle: blank,
    );
    final documents = [...manifest.documents]..[index] = updated;
    await _write(manifest.scores, documents);
    return updated;
  }

  /// How many Scores are pieces of the same document as [scoreId].
  Future<int> scoresSharingDocument(String scoreId) async {
    final manifest = await _read();
    final score = manifest.scoreById(scoreId);
    if (score == null) return 0;
    return manifest.scores
        .where((s) => s.pdfDocumentId == score.pdfDocumentId)
        .length;
  }

  /// Replace the PDF bytes behind [scoreId] in place (Spec 0024).
  ///
  /// Since 0052 this affects **every** Score sharing the document, and a
  /// shorter file can leave an extent describing pages that no longer exist —
  /// so the result reports both, and the caller is expected to say so.
  Future<ReplacePdfResult> replacePdf({
    required String scoreId,
    required String sourcePath,
    required ReplacePdfOverlayChoice overlays,
  }) async {
    await ensureReady();
    final manifest = await _read();
    final score = manifest.scoreById(scoreId);
    if (score == null) throw StateError('Score not found: $scoreId');
    final document = manifest.documentById(score.pdfDocumentId);
    if (document == null) {
      throw StateError('No PdfDocument for Score $scoreId');
    }

    final dest = absoluteFileForDocument(document);
    await File(sourcePath).copy(dest.path);
    // The new file is a different document; its old page count would lie.
    final newCount = await _countPages(dest.path);
    final documents = [...manifest.documents];
    documents[documents.indexWhere((d) => d.id == document.id)] = document
        .copyWith(pageCount: newCount, clearPageCount: newCount == null);

    final scores = [...manifest.scores];
    final affected = <Score>[];
    final truncated = <Score>[];
    final reset = <Score>[];
    for (var i = 0; i < scores.length; i++) {
      if (scores[i].pdfDocumentId != document.id) continue;
      var updated = scores[i];
      final extent = updated.pageExtent;
      if (extent != null && newCount != null) {
        final clamped = extent.clampedTo(newCount);
        if (clamped == null) {
          // Nothing of this piece survives. Falling back to the whole file is
          // visibly wrong and fixable; leaving an extent pointing past the end
          // would be a Score that opens onto nothing.
          updated = updated.copyWith(clearPageExtent: true);
          reset.add(updated);
        } else if (clamped != extent) {
          updated = updated.copyWith(pageExtent: clamped);
          truncated.add(updated);
        }
      }
      scores[i] = updated;
      affected.add(updated);
    }

    await _write(scores, documents);

    if (overlays == ReplacePdfOverlayChoice.reset) {
      for (final s in affected) {
        await clearScoreOverlays(root: _root, scoreId: s.id);
      }
    }
    return ReplacePdfResult(
      scores: affected,
      sharedScoreCount: affected.length,
      truncated: truncated,
      reset: reset,
    );
  }

  /// Retitle a Score (Spec 0040).
  ///
  /// Metadata only: the PDF keeps its file name and path, so annotations,
  /// Bookmarks and Setlist membership — all keyed by Score id — are untouched.
  /// A blank [title] is refused rather than resurrecting the file name.
  ///
  /// Renaming a root also writes [PdfDocument.title], so the book name and the
  /// Library row stay one thing (Spec 0055).
  Future<Score> renameScore({
    required String scoreId,
    required String title,
  }) async {
    final trimmed = title.trim();
    await ensureReady();
    final manifest = await _read();
    final index = manifest.scores.indexWhere((s) => s.id == scoreId);
    if (index < 0) {
      throw StateError('Score not found: $scoreId');
    }
    if (trimmed.isEmpty) return manifest.scores[index];
    final updated = manifest.scores[index].copyWith(title: trimmed);
    final scores = [...manifest.scores]..[index] = updated;
    var documents = manifest.documents;
    if (updated.isRoot) {
      final docIndex = documents.indexWhere(
        (d) => d.id == updated.pdfDocumentId,
      );
      if (docIndex >= 0) {
        documents = [...documents]
          ..[docIndex] = documents[docIndex].copyWith(title: trimmed);
      }
    }
    await _write(scores, documents);
    return updated;
  }

  /// Fill in page counts missing from the manifest (Spec 0040, 0052).
  ///
  /// Counts live on the document now. Documents imported before 0040 have no
  /// count, and counting means opening every PDF — so this runs after the list
  /// is on screen, and returns the fresh Scores only when something changed.
  Future<List<Score>?> backfillPageCounts() async {
    await ensureReady();
    final manifest = await _read();
    final counted = <String, int>{};
    for (final document in manifest.documents) {
      if (document.pageCount != null) continue;
      final count = await _countPages(absoluteFileForDocument(document).path);
      if (count == null) continue;
      counted[document.id] = count;
    }
    if (counted.isEmpty) return null;

    // Re-read: an import or delete may have landed while we were counting.
    final current = await _read();
    final documents = [...current.documents];
    var changed = false;
    for (var i = 0; i < documents.length; i++) {
      if (documents[i].pageCount != null) continue;
      final count = counted[documents[i].id];
      if (count == null) continue;
      documents[i] = documents[i].copyWith(pageCount: count);
      changed = true;
    }
    if (!changed) return null;
    await _write(current.scores, documents);
    return current.scores;
  }

  Future<Score> markOpened(Score score) async {
    final manifest = await _read();
    final index = manifest.scores.indexWhere((s) => s.id == score.id);
    if (index < 0) return score;
    final updated = manifest.scores[index].copyWith(
      lastOpenedAt: DateTime.now().toUtc(),
    );
    final scores = [...manifest.scores]..[index] = updated;
    await _write(scores, manifest.documents);
    return updated;
  }

  /// Hard-delete a Score: overlays, manifest entry, and — only when it was the
  /// last piece of its document — the PDF file (Spec 0028, 0052).
  ///
  /// Deleting a root cascades to every child (Spec 0055); deleting a child
  /// leaves the root in place even when it has no children left. Reference
  /// counting is a read over the manifest rather than a stored tally, because
  /// a stored tally drifts the first time something fails halfway and a
  /// recount never does.
  Future<void> deleteScore(String scoreId) async {
    await ensureReady();
    final manifest = await _read();
    final score = manifest.scoreById(scoreId);
    if (score == null) {
      throw StateError('Score not found: $scoreId');
    }
    final toDelete = <String>{scoreId};
    if (score.isRoot) {
      for (final s in manifest.scores) {
        if (s.parentId == scoreId) toDelete.add(s.id);
      }
    }
    final scores = [
      for (final s in manifest.scores)
        if (!toDelete.contains(s.id)) s,
    ];
    final stillUsed = scores.any(
      (s) => s.pdfDocumentId == score.pdfDocumentId,
    );

    var documents = manifest.documents;
    if (!stillUsed) {
      final document = manifest.documentById(score.pdfDocumentId);
      if (document != null) {
        final pdf = absoluteFileForDocument(document);
        if (await pdf.exists()) {
          await pdf.delete();
        }
        documents = documents.where((d) => d.id != document.id).toList();
      }
    }

    for (final id in toDelete) {
      await clearScoreOverlays(root: _root, scoreId: id);
    }
    await _write(scores, documents);
  }

  static String _titleFromFileName(String fileName) {
    final base = p.basename(fileName);
    if (base.toLowerCase().endsWith('.pdf')) {
      return base.substring(0, base.length - 4);
    }
    return base;
  }

  Future<_Manifest> _read() async {
    final raw = await manifestFile.readAsString();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final migrated = migrateLibraryManifest(decoded);
    final manifest = _Manifest.fromJson(migrated);
    _reindex(manifest.documents);
    if (!_sameManifest(migrated, decoded)) {
      await _write(manifest.scores, manifest.documents);
    }
    return manifest;
  }

  Future<void> _write(List<Score> scores, List<PdfDocument> documents) async {
    final payload = {
      'scores': scores.map((s) => s.toJson()).toList(),
      pdfDocumentsKey: documents.map((d) => d.toJson()).toList(),
    };
    await manifestFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
    _reindex(documents);
  }

  void _reindex(List<PdfDocument> documents) {
    _documentsById
      ..clear()
      ..addEntries(documents.map((d) => MapEntry(d.id, d)));
  }
}

/// Whether migration rewrote the decoded map.
///
/// Hierarchy migration always allocates a new scores list when it changes
/// anything, so identity alone is not enough after 0055 — compare the encoded
/// shape of the scores and documents keys.
bool _sameManifest(Map<String, dynamic> a, Map<String, dynamic> b) {
  if (identical(a, b)) return true;
  return jsonEncode(a['scores']) == jsonEncode(b['scores']) &&
      jsonEncode(a[pdfDocumentsKey]) == jsonEncode(b[pdfDocumentsKey]);
}

class _Manifest {
  const _Manifest({required this.scores, required this.documents});

  final List<Score> scores;
  final List<PdfDocument> documents;

  Score? scoreById(String id) {
    for (final score in scores) {
      if (score.id == id) return score;
    }
    return null;
  }

  PdfDocument? documentById(String id) {
    for (final document in documents) {
      if (document.id == id) return document;
    }
    return null;
  }

  factory _Manifest.fromJson(Map<String, dynamic> json) => _Manifest(
    scores: (json['scores'] as List<dynamic>? ?? const [])
        .map((e) => Score.fromJson(e as Map<String, dynamic>))
        .toList(),
    documents: (json[pdfDocumentsKey] as List<dynamic>? ?? const [])
        .map((e) => PdfDocument.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
