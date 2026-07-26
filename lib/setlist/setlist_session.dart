import 'dart:io';

import 'package:pdfrx/pdfrx.dart';
import 'package:standscore/library/score.dart';
import 'package:standscore/library/score_library.dart';
import 'package:standscore/pageorder/page_order_store.dart';
import 'package:standscore/setlist/setlist.dart';

/// One resolved Score slot in an open Setlist session.
class SetlistPiece {
  const SetlistPiece({
    required this.score,
    required this.filePath,
  });

  final Score score;
  final String filePath;
}

/// PdfMode session spanning multiple Scores (Spec 0012).
class SetlistSession {
  const SetlistSession({
    required this.setlist,
    required this.pieces,
    this.initialIndex = 0,
  });

  final Setlist setlist;
  final List<SetlistPiece> pieces;
  final int initialIndex;

  /// Resolve Setlist membership against the library. Skips missing Scores.
  static Future<({SetlistSession? session, int skipped})> resolve({
    required Setlist setlist,
    required ScoreLibrary library,
  }) async {
    final scores = await library.listScores();
    final byId = {for (final s in scores) s.id: s};
    final pieces = <SetlistPiece>[];
    var skipped = 0;
    for (final id in setlist.scoreIds) {
      final score = byId[id];
      if (score == null) {
        skipped++;
        continue;
      }
      final file = library.absoluteFile(score);
      if (!await file.exists()) {
        skipped++;
        continue;
      }
      pieces.add(SetlistPiece(score: score, filePath: file.path));
    }
    if (pieces.isEmpty) {
      return (session: null, skipped: skipped);
    }
    return (
      session: SetlistSession(setlist: setlist, pieces: pieces),
      skipped: skipped,
    );
  }

  /// PageOrder lengths for each piece (for boundary PageTurn).
  static Future<List<int>> loadPageCounts({
    required Directory root,
    required List<SetlistPiece> pieces,
  }) async {
    final counts = <int>[];
    for (final piece in pieces) {
      var sourceCount = 0;
      try {
        final doc = await PdfDocument.openFile(piece.filePath);
        sourceCount = doc.pages.length;
        await doc.dispose();
      } catch (_) {}
      final order = await PageOrderStore(
        root: root,
        scoreId: piece.score.id,
      ).loadOrIdentity(sourceCount);
      counts.add(order.length);
    }
    return counts;
  }
}
