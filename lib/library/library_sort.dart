import 'package:standscore/library/score.dart';

/// Library Scores sort key (Spec 0023 / P2.7).
enum LibrarySortMode { title, created, lastViewed }

extension LibrarySortModeX on LibrarySortMode {
  String get label => switch (this) {
    LibrarySortMode.title => 'Title',
    LibrarySortMode.created => 'Created',
    LibrarySortMode.lastViewed => 'Last viewed',
  };
}

/// Sort Scores after filter/search (Spec 0023).
///
/// - [LibrarySortMode.title]: A–Z, case-insensitive
/// - [LibrarySortMode.created]: newest first
/// - [LibrarySortMode.lastViewed]: recent first; never-opened last
List<Score> sortScores(List<Score> scores, LibrarySortMode mode) {
  final out = List<Score>.from(scores);
  out.sort((a, b) => _compare(a, b, mode));
  return out;
}

int _compare(Score a, Score b, LibrarySortMode mode) {
  switch (mode) {
    case LibrarySortMode.title:
      final byTitle = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      if (byTitle != 0) return byTitle;
      return a.id.compareTo(b.id);
    case LibrarySortMode.created:
      final byCreated = b.createdAt.compareTo(a.createdAt);
      if (byCreated != 0) return byCreated;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    case LibrarySortMode.lastViewed:
      final aOpened = a.lastOpenedAt;
      final bOpened = b.lastOpenedAt;
      if (aOpened == null && bOpened == null) {
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
      if (aOpened == null) return 1;
      if (bOpened == null) return -1;
      final byOpened = bOpened.compareTo(aOpened);
      if (byOpened != 0) return byOpened;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }
}
