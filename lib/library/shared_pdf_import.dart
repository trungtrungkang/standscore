import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:standscore/library/score.dart';
import 'package:standscore/library/score_library.dart';

/// Imports PDFs received from OS share / open-in (Spec 0029 / P2.12).
class SharedPdfImport {
  const SharedPdfImport();

  /// True when [path] looks like a PDF (extension, ignoring query fragments).
  bool isPdfPath(String path) {
    final name = p.basename(path.split('?').first).toLowerCase();
    return name.endsWith('.pdf');
  }

  /// Import each PDF path into [library]; skip non-PDFs and missing files.
  Future<List<Score>> importPaths({
    required ScoreLibrary library,
    required Iterable<String> paths,
  }) async {
    final imported = <Score>[];
    for (final raw in paths) {
      final path = raw.replaceFirst(RegExp(r'^file://'), '');
      if (!isPdfPath(path)) continue;
      final file = File(path);
      if (!await file.exists()) continue;
      imported.add(
        await library.importPdf(
          sourcePath: file.path,
          originalFileName: p.basename(file.path),
        ),
      );
    }
    return imported;
  }
}
