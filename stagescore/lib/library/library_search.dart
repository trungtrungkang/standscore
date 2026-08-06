import 'dart:io';

import 'package:stagescore/bookmark/bookmark_store.dart';
import 'package:stagescore/library/score.dart';

/// Case-insensitive substring match (Spec 0022).
bool textMatchesQuery(String haystack, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  return haystack.toLowerCase().contains(q);
}

/// Filter Scores by title, Bookmark title, or the name of the book they came
/// out of.
///
/// Empty [query] returns [scores] unchanged. Preserve input order.
///
/// [bookNameByDocumentId] is optional so callers that have no manifest keep
/// working. It earns its place because a piece is often named `Op. 10 No. 3`
/// while the thing the musician remembers is `Chopin Etudes` — and the header
/// row is what explains why a match with neither word in its title appeared
/// (Spec 0054).
List<Score> filterScoresBySearch({
  required List<Score> scores,
  required String query,
  required Map<String, List<String>> bookmarkTitlesByScoreId,
  Map<String, String> bookNameByDocumentId = const {},
}) {
  final q = query.trim();
  if (q.isEmpty) return List<Score>.from(scores);

  return [
    for (final score in scores)
      if (textMatchesQuery(score.title, q) ||
          (bookmarkTitlesByScoreId[score.id] ?? const []).any(
            (title) => textMatchesQuery(title, q),
          ) ||
          textMatchesQuery(bookNameByDocumentId[score.pdfDocumentId] ?? '', q))
        score,
  ];
}

/// Load Bookmark titles for many Scores (async index for Library search).
Future<Map<String, List<String>>> loadBookmarkTitleIndex({
  required Directory root,
  required Iterable<String> scoreIds,
}) async {
  final map = <String, List<String>>{};
  for (final id in scoreIds) {
    final bookmarks = await BookmarkStore(root: root, scoreId: id).list();
    if (bookmarks.isEmpty) continue;
    map[id] = [for (final b in bookmarks) b.title];
  }
  return map;
}
