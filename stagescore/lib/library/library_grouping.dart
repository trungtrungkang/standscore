import 'package:stagescore/library/library_sort.dart';
import 'package:stagescore/library/pdf_document.dart';
import 'package:stagescore/library/score.dart';
import 'package:stagescore/library/source_filter.dart';

/// One row of the Library list: a book header, or a piece (Spec 0054).
///
/// A flat list of rows rather than a tree, and the difference is the whole
/// design. A tree has nodes that close, which means state to store, restore and
/// reconcile with search — and no good answer for "the query matched a piece
/// inside a collapsed book". Every row here is always visible; the header only
/// says that the pieces under it belong together.
sealed class LibraryRow {
  const LibraryRow();
}

/// The book. Never a Score: it does not open, has no thumbnail, and cannot
/// enter a Setlist (ADR 0019, decision 11).
class BookHeaderRow extends LibraryRow {
  const BookHeaderRow({required this.document, required this.pieces});

  final PdfDocument document;

  /// How many pieces are shown beneath it — which is not necessarily how many
  /// the book holds, because search and filters narrow it (Spec 0054, G3 #7).
  final int pieces;
}

class ScoreRow extends LibraryRow {
  const ScoreRow({required this.score, required this.inBook});

  final Score score;

  /// Whether a header above it already names the book.
  ///
  /// The provenance line shortens to "Pages 12–19" when true: repeating the
  /// book's name on all nine of its rows is noise, and the one function that
  /// phrases provenance already drops the name when given none.
  final bool inBook;
}

/// Group the visible Scores under their books, and order everything.
///
/// [scores] is the filtered and searched list, **unsorted** — sorting happens
/// here because the thing being ordered is a row, and a book's header row has
/// its own key. [counts] is counted over the whole library, not over [scores],
/// so narrowing to one piece of a book still shows its header.
///
/// Pieces inside a book are always in page order, whatever the sort mode: the
/// pieces of one book have exactly one natural order and that is the order they
/// are printed in. Sorting them A–Z would throw that away for an order nobody
/// asked for (Spec 0054, G3 #5).
List<LibraryRow> buildLibraryRows({
  required List<Score> scores,
  required Map<String, PdfDocument> documentsById,
  required Map<String, int> counts,
  required LibrarySortMode mode,
}) {
  final books = <String, List<Score>>{};
  final loose = <Score>[];
  for (final score in scores) {
    final id = score.pdfDocumentId;
    if (isFilterableSource(counts, id) && documentsById.containsKey(id)) {
      (books[id] ??= []).add(score);
    } else {
      loose.add(score);
    }
  }

  final nodes = <({LibrarySortKey key, List<LibraryRow> rows})>[
    for (final score in loose)
      (
        key: sortKeyOf(score),
        rows: [ScoreRow(score: score, inBook: false)],
      ),
  ];
  for (final entry in books.entries) {
    final document = documentsById[entry.key]!;
    final pieces = [...entry.value]..sort(_byPage);
    nodes.add((
      key: _bookKey(document, pieces),
      rows: [
        BookHeaderRow(document: document, pieces: pieces.length),
        for (final piece in pieces) ScoreRow(score: piece, inBook: true),
      ],
    ));
  }

  nodes.sort((a, b) => compareSortKeys(a.key, b.key, mode));
  return [for (final node in nodes) ...node.rows];
}

int _byPage(Score a, Score b) {
  final byPage = a.firstAbsolutePage.compareTo(b.firstAbsolutePage);
  if (byPage != 0) return byPage;
  final byTitle = a.title.toLowerCase().compareTo(b.title.toLowerCase());
  return byTitle != 0 ? byTitle : a.id.compareTo(b.id);
}

/// `Created` reads the book's own arrival, not its pieces'.
///
/// Splitting stamps every new piece with `now`, so taking the newest child
/// would send a book bought last year to the top of the list every time the
/// musician carves one more piece out of it (Spec 0054, G3 #4).
LibrarySortKey _bookKey(PdfDocument document, List<Score> pieces) {
  DateTime? opened;
  for (final piece in pieces) {
    final at = piece.lastOpenedAt;
    if (at == null) continue;
    if (opened == null || at.isAfter(opened)) opened = at;
  }
  return (
    name: document.displayName,
    created: document.importedAt,
    opened: opened,
    id: document.id,
  );
}
