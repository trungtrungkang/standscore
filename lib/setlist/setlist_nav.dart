/// Target location after a PageTurn that may cross Setlist Score boundaries.
class SetlistNavTarget {
  const SetlistNavTarget({
    required this.scoreIndex,
    required this.pageNumber,
  });

  final int scoreIndex;

  /// 1-based performance page within the target Score's PageOrder.
  final int pageNumber;

  @override
  bool operator ==(Object other) =>
      other is SetlistNavTarget &&
      scoreIndex == other.scoreIndex &&
      pageNumber == other.pageNumber;

  @override
  int get hashCode => Object.hash(scoreIndex, pageNumber);
}

/// Resolve next/prev PageTurn across Setlist pieces.
///
/// [delta] is typically ±[pageTurnStepFor] (e.g. ±1 or ±2).
/// When the computed page is outside the current Score, moves to the adjacent
/// Score (page 1 forward, last page backward). Returns null at Setlist ends.
SetlistNavTarget? resolveSetlistPageTurn({
  required int scoreIndex,
  required int currentPage,
  required int delta,
  required List<int> pageCounts,
}) {
  if (pageCounts.isEmpty) return null;
  if (scoreIndex < 0 || scoreIndex >= pageCounts.length) return null;
  if (delta == 0) return null;

  final count = pageCounts[scoreIndex];
  if (count < 1) return null;

  final target = currentPage + delta;
  if (target >= 1 && target <= count) {
    return SetlistNavTarget(scoreIndex: scoreIndex, pageNumber: target);
  }

  if (delta > 0) {
    final next = scoreIndex + 1;
    if (next >= pageCounts.length) return null;
    if (pageCounts[next] < 1) return null;
    return SetlistNavTarget(scoreIndex: next, pageNumber: 1);
  }

  final prev = scoreIndex - 1;
  if (prev < 0) return null;
  final prevCount = pageCounts[prev];
  if (prevCount < 1) return null;
  return SetlistNavTarget(scoreIndex: prev, pageNumber: prevCount);
}
