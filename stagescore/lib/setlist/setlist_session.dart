import 'dart:io';

import 'package:pdfrx/pdfrx.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/library/score.dart';
import 'package:stagescore/library/score_library.dart';
import 'package:stagescore/library/score_origin.dart';
import 'package:stagescore/pageorder/page_order_store.dart';
import 'package:stagescore/setlist/setlist.dart';

/// One resolved Score slot in an open Setlist session.
class SetlistPiece {
  const SetlistPiece({
    required this.score,
    required this.filePath,
    this.originLine,
  });

  final Score score;
  final String filePath;

  /// "Pages 12–19 of Chopin Etudes.pdf", resolved here because this is where
  /// the library is still in reach (Spec 0052).
  final String? originLine;
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
    required AppLocalizations l10n,
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
      final document = library.documentFor(score);
      pieces.add(
        SetlistPiece(
          score: score,
          filePath: file.path,
          originLine: scoreOriginLine(
            l10n: l10n,
            extent: score.pageExtent,
            documentName: document?.displayName,
            documentPageCount: document?.pageCount,
          ),
        ),
      );
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
      // Boundary PageTurn counts the pages of the *piece*, not of the file it
      // shares with the rest of the book (Spec 0052).
      final extent = piece.score.extentIn(sourceCount);
      final order = await PageOrderStore(
        root: root,
        scoreId: piece.score.id,
      ).loadOrIdentity(
        extent?.length ?? 0,
        sourceFirstPage: extent?.firstPage ?? 1,
      );
      counts.add(order.length);
    }
    return counts;
  }
}
