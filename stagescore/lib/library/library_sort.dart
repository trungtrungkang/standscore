import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/library/score.dart';

/// Library Scores sort key (Spec 0023 / P2.7).
enum LibrarySortMode { title, created, lastViewed }

extension LibrarySortModeX on LibrarySortMode {
  String label(AppLocalizations l10n) => switch (this) {
    LibrarySortMode.title => l10n.librarySortTitle,
    LibrarySortMode.created => l10n.librarySortCreated,
    LibrarySortMode.lastViewed => l10n.librarySortLastViewed,
  };
}

/// What sorting needs to know about one row of the Library.
///
/// Exists so a book's header row and a piece answer to the **same** ordering
/// rules: since 0054 the two are sorted against each other, and two comparators
/// would be two chances for "newest first" to mean different things on the same
/// screen (Spec 0054, G3 #4).
typedef LibrarySortKey = ({
  String name,
  DateTime created,
  DateTime? opened,
  String id,
});

LibrarySortKey sortKeyOf(Score score) => (
  name: score.title,
  created: score.createdAt,
  opened: score.lastOpenedAt,
  id: score.id,
);

/// Sort Scores after filter/search (Spec 0023).
///
/// - [LibrarySortMode.title]: A–Z, case-insensitive
/// - [LibrarySortMode.created]: newest first
/// - [LibrarySortMode.lastViewed]: recent first; never-opened last
List<Score> sortScores(List<Score> scores, LibrarySortMode mode) {
  final out = List<Score>.from(scores);
  out.sort((a, b) => compareSortKeys(sortKeyOf(a), sortKeyOf(b), mode));
  return out;
}

int compareSortKeys(LibrarySortKey a, LibrarySortKey b, LibrarySortMode mode) {
  switch (mode) {
    case LibrarySortMode.title:
      final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      if (byName != 0) return byName;
      return a.id.compareTo(b.id);
    case LibrarySortMode.created:
      final byCreated = b.created.compareTo(a.created);
      if (byCreated != 0) return byCreated;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    case LibrarySortMode.lastViewed:
      final aOpened = a.opened;
      final bOpened = b.opened;
      if (aOpened == null && bOpened == null) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      if (aOpened == null) return 1;
      if (bOpened == null) return -1;
      final byOpened = bOpened.compareTo(aOpened);
      if (byOpened != 0) return byOpened;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}
