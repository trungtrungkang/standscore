import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:standscore/library/score.dart';
import 'package:standscore/library/score_overlays.dart';
import 'package:uuid/uuid.dart';

/// Whether to clear per-Score overlays when replacing a PDF (Spec 0024).
enum ReplacePdfOverlayChoice {
  keep,
  reset,
}

/// Local on-device Score library (PDF files + JSON manifest).
class ScoreLibrary {
  ScoreLibrary({
    required this._root,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final Directory _root;
  final Uuid _uuid;

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

  File absoluteFile(Score score) => File(p.join(_root.path, score.relativePath));

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

    if (overlays == ReplacePdfOverlayChoice.reset) {
      await clearScoreOverlays(root: _root, scoreId: scoreId);
    }
    return score;
  }

  Future<Score> markOpened(Score score) async {
    final scores = await _readScores();
    final index = scores.indexWhere((s) => s.id == score.id);
    if (index < 0) return score;
    final updated = scores[index].copyWith(lastOpenedAt: DateTime.now().toUtc());
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
    return list
        .map((e) => Score.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _writeScores(List<Score> scores) async {
    final payload = {
      'scores': scores.map((s) => s.toJson()).toList(),
    };
    await manifestFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
  }
}
