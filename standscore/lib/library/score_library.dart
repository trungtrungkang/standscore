import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:standscore/library/score.dart';
import 'package:standscore/library/score_overlays.dart';
import 'package:uuid/uuid.dart';

/// Whether to clear per-Score overlays when replacing a PDF (Spec 0024).
enum ReplacePdfOverlayChoice { keep, reset }

/// Pages in the PDF at [path], or null if it cannot be read (Spec 0040).
///
/// Injected so the library layer stays free of pdfrx: production passes the
/// pdfrx counter, tests pass whatever they need and get null by default.
typedef PdfPageCounter = Future<int?> Function(String path);

Future<int?> _unknownPageCount(String path) async => null;

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

  Directory get root => _root;

  Directory get scoresDir => Directory(p.join(_root.path, 'scores'));
  File get manifestFile => File(p.join(_root.path, 'library.json'));

  Future<void> ensureReady() async {
    if (!await _root.exists()) {
      await _root.create(recursive: true);
    }
    if (!await scoresDir.exists()) {
      await scoresDir.create(recursive: true);
    }
    if (!await manifestFile.exists()) {
      await _writeScores(const []);
    }
  }

  /// Unordered manifest list; Library UI applies [sortScores] (Spec 0023).
  Future<List<Score>> listScores() async {
    await ensureReady();
    return _readScores();
  }

  Future<Score> importPdf({
    required String sourcePath,
    required String originalFileName,
  }) async {
    await ensureReady();
    final id = _uuid.v4();
    final title = _titleFromFileName(originalFileName);
    final relativePath = p.join('scores', '$id.pdf');
    final dest = File(p.join(_root.path, relativePath));
    await File(sourcePath).copy(dest.path);

    final score = Score(
      id: id,
      title: title,
      relativePath: relativePath,
      createdAt: DateTime.now().toUtc(),
      pageCount: await _countPages(dest.path),
    );
    final scores = await _readScores();
    scores.add(score);
    await _writeScores(scores);
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

  File absoluteFile(Score score) =>
      File(p.join(_root.path, score.relativePath));

  /// Replace the PDF bytes for [scoreId] in place (same Score id / path).
  ///
  /// Title, Labels, and Setlist membership are unchanged. When [overlays] is
  /// [ReplacePdfOverlayChoice.reset], annotation/bookmark/jumplink/page-order
  /// files for that Score are deleted.
  Future<Score> replacePdf({
    required String scoreId,
    required String sourcePath,
    required ReplacePdfOverlayChoice overlays,
  }) async {
    await ensureReady();
    final scores = await _readScores();
    final index = scores.indexWhere((s) => s.id == scoreId);
    if (index < 0) {
      throw StateError('Score not found: $scoreId');
    }
    final score = scores[index];
    final dest = absoluteFile(score);
    await File(sourcePath).copy(dest.path);

    // The new file is a different document; its old page count would lie.
    final updated = Score(
      id: score.id,
      title: score.title,
      relativePath: score.relativePath,
      createdAt: score.createdAt,
      lastOpenedAt: score.lastOpenedAt,
      pageCount: await _countPages(dest.path),
    );
    scores[index] = updated;
    await _writeScores(scores);

    if (overlays == ReplacePdfOverlayChoice.reset) {
      await clearScoreOverlays(root: _root, scoreId: scoreId);
    }
    return updated;
  }

  /// Retitle a Score (Spec 0040).
  ///
  /// Metadata only: the PDF keeps its file name and path, so annotations,
  /// Bookmarks and Setlist membership — all keyed by Score id — are untouched.
  /// A blank [title] is refused rather than resurrecting the file name.
  Future<Score> renameScore({
    required String scoreId,
    required String title,
  }) async {
    final trimmed = title.trim();
    await ensureReady();
    final scores = await _readScores();
    final index = scores.indexWhere((s) => s.id == scoreId);
    if (index < 0) {
      throw StateError('Score not found: $scoreId');
    }
    if (trimmed.isEmpty) return scores[index];
    final updated = scores[index].copyWith(title: trimmed);
    scores[index] = updated;
    await _writeScores(scores);
    return updated;
  }

  /// Fill in page counts missing from the manifest (Spec 0040).
  ///
  /// Scores imported before 0040 have no count, and counting means opening
  /// every PDF — so this runs after the list is already on screen, and returns
  /// the fresh manifest only when something actually changed.
  Future<List<Score>?> backfillPageCounts() async {
    final scores = await listScores();
    var changed = false;
    for (var i = 0; i < scores.length; i++) {
      if (scores[i].pageCount != null) continue;
      final count = await _countPages(absoluteFile(scores[i]).path);
      if (count == null) continue;
      scores[i] = scores[i].copyWith(pageCount: count);
      changed = true;
    }
    if (!changed) return null;
    // Re-read: an import or delete may have landed while we were counting.
    final current = await _readScores();
    final counted = {
      for (final score in scores)
        if (score.pageCount != null) score.id: score.pageCount!,
    };
    for (var i = 0; i < current.length; i++) {
      if (current[i].pageCount != null) continue;
      final count = counted[current[i].id];
      if (count == null) continue;
      current[i] = current[i].copyWith(pageCount: count);
    }
    await _writeScores(current);
    return current;
  }

  Future<Score> markOpened(Score score) async {
    final scores = await _readScores();
    final index = scores.indexWhere((s) => s.id == score.id);
    if (index < 0) return score;
    final updated = scores[index].copyWith(
      lastOpenedAt: DateTime.now().toUtc(),
    );
    scores[index] = updated;
    await _writeScores(scores);
    return updated;
  }

  /// Hard-delete a Score: PDF file, overlays, and manifest entry (Spec 0028).
  ///
  /// Does not update Labels or Setlists — caller clears those in the same action.
  Future<void> deleteScore(String scoreId) async {
    await ensureReady();
    final scores = await _readScores();
    final index = scores.indexWhere((s) => s.id == scoreId);
    if (index < 0) {
      throw StateError('Score not found: $scoreId');
    }
    final score = scores[index];
    final pdf = absoluteFile(score);
    if (await pdf.exists()) {
      await pdf.delete();
    }
    await clearScoreOverlays(root: _root, scoreId: scoreId);
    scores.removeAt(index);
    await _writeScores(scores);
  }

  static String _titleFromFileName(String fileName) {
    final base = p.basename(fileName);
    if (base.toLowerCase().endsWith('.pdf')) {
      return base.substring(0, base.length - 4);
    }
    return base;
  }

  Future<List<Score>> _readScores() async {
    final raw = await manifestFile.readAsString();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final list = json['scores'] as List<dynamic>? ?? const [];
    return list.map((e) => Score.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _writeScores(List<Score> scores) async {
    final payload = {'scores': scores.map((s) => s.toJson()).toList()};
    await manifestFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
  }
}
