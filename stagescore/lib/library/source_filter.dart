import 'package:stagescore/library/score.dart';

/// Pure Library filter by source file (Spec 0053).
///
/// Narrowing, not grouping — 0054 added the grouped list next to this rather
/// than on top of it, and the two share nothing but this count. A book can own
/// a header row, but it is still never a Score (ADR 0019, decision 11).
List<Score> filterScoresBySource({
  required List<Score> scores,
  required String? pdfDocumentId,
}) {
  if (pdfDocumentId == null) return List<Score>.from(scores);
  return [
    for (final score in scores)
      if (score.pdfDocumentId == pdfDocumentId) score,
  ];
}

/// How many Scores each PdfDocument holds.
///
/// The one predicate behind both entrances to the source filter — the row menu
/// and the filter sheet — so they cannot disagree about what counts as a
/// source. Derived from the Scores already in memory rather than
/// `ScoreLibrary.scoresSharingDocument`, which re-reads the manifest and so
/// cannot be called while building a row (Spec 0053, G3 #11).
Map<String, int> countScoresByDocument(List<Score> scores) {
  final counts = <String, int>{};
  for (final score in scores) {
    counts[score.pdfDocumentId] = (counts[score.pdfDocumentId] ?? 0) + 1;
  }
  return counts;
}

/// Whether [pdfDocumentId] holds enough pieces to be worth filtering by.
///
/// A file with one Score is not a source: offering "show all pieces of it"
/// would promise a list and return the row the musician is already looking at.
bool isFilterableSource(Map<String, int> counts, String pdfDocumentId) =>
    (counts[pdfDocumentId] ?? 0) >= 2;
