import 'package:stagescore/label/label.dart';
import 'package:stagescore/label/label_filter.dart';
import 'package:stagescore/library/library_search.dart';
import 'package:stagescore/library/library_sort.dart';
import 'package:stagescore/library/score.dart';

/// Scores the Library list should show (Spec 0055).
///
/// Default: roots only. Search or a Label filter widens the list to every
/// matching Score — including children — so a piece titled `Op. 10 No. 3` is
/// reachable without opening its book first. An empty root is never invented
/// to host matching children (G3 #5).
List<Score> visibleLibraryScores({
  required List<Score> scores,
  required String query,
  required Map<String, List<String>> bookmarkTitlesByScoreId,
  Map<String, String> bookNameByDocumentId = const {},
  Map<String, Set<String>> assignments = const {},
  Set<String> selectedLabelIds = const {},
  LabelFilterMode mode = LabelFilterMode.any,
}) {
  var filtered = scores;
  final labelsActive =
      selectedLabelIds.isNotEmpty || mode == LabelFilterMode.untagged;
  if (labelsActive) {
    filtered = filterScoresByLabels(
      scores: filtered,
      assignments: assignments,
      selectedLabelIds: selectedLabelIds,
      mode: mode,
    );
  }
  filtered = filterScoresBySearch(
    scores: filtered,
    query: query,
    bookmarkTitlesByScoreId: bookmarkTitlesByScoreId,
    bookNameByDocumentId: bookNameByDocumentId,
  );

  final searching = query.trim().isNotEmpty;
  if (!searching && !labelsActive) {
    return rootsOnly(filtered);
  }
  return filtered;
}

/// Sort key for a Library row, with root "Last viewed" = max(root, children).
LibrarySortKey librarySortKeyOf(Score score, List<Score> allScores) {
  if (!score.isRoot) return sortKeyOf(score);
  DateTime? opened = score.lastOpenedAt;
  for (final child in childrenOfRoot(allScores, score.id)) {
    final at = child.lastOpenedAt;
    if (at == null) continue;
    if (opened == null || at.isAfter(opened)) opened = at;
  }
  return (
    name: score.title,
    created: score.createdAt,
    opened: opened,
    id: score.id,
  );
}

/// Sort [scores] for the Library list (Spec 0023 / 0055).
List<Score> sortLibraryScores(
  List<Score> scores,
  LibrarySortMode mode,
  List<Score> allScores,
) {
  final out = List<Score>.from(scores);
  out.sort(
    (a, b) => compareSortKeys(
      librarySortKeyOf(a, allScores),
      librarySortKeyOf(b, allScores),
      mode,
    ),
  );
  return out;
}

/// Subtitle crumb when a child appears outside its book (search / filter).
String? childInRootSubtitle(Score score, List<Score> allScores) {
  final parentId = score.parentId;
  if (parentId == null) return null;
  for (final s in allScores) {
    if (s.id == parentId) return 'in ${s.title}';
  }
  return 'in book';
}
