import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/library/library_grouping.dart';
import 'package:stagescore/library/library_sort.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/pdf_document.dart';
import 'package:stagescore/library/score.dart';
import 'package:stagescore/library/source_filter.dart';

/// Grouping the Library's pieces under their books (Spec 0054).
///
/// A pure function on lists, so the ordering rules are pinned here rather than
/// inferred from a rendered list.
void main() {
  PdfDocument book(
    String id, {
    String? title,
    String? fileName,
    DateTime? importedAt,
  }) => PdfDocument(
    id: id,
    relativePath: 'documents/$id.pdf',
    importedAt: importedAt ?? DateTime.utc(2026, 1, 1),
    pageCount: 40,
    originalFileName: fileName ?? '$id.pdf',
    title: title,
  );

  Score piece(
    String id, {
    required String documentId,
    required String title,
    int? firstPage,
    int? lastPage,
    DateTime? createdAt,
    DateTime? lastOpenedAt,
  }) => Score(
    id: id,
    title: title,
    pdfDocumentId: documentId,
    pageExtent: firstPage == null
        ? null
        : PageExtent(firstPage: firstPage, lastPage: lastPage ?? firstPage),
    createdAt: createdAt ?? DateTime.utc(2026, 1, 1),
    lastOpenedAt: lastOpenedAt,
  );

  List<LibraryRow> rows(
    List<Score> scores,
    List<PdfDocument> books, {
    LibrarySortMode mode = LibrarySortMode.title,
  }) => buildLibraryRows(
    scores: scores,
    documentsById: {for (final b in books) b.id: b},
    counts: countScoresByDocument(scores),
    mode: mode,
  );

  /// What is on screen, in order: a book name or a piece title.
  List<String> labels(List<LibraryRow> list) => [
    for (final row in list)
      switch (row) {
        BookHeaderRow(:final document) => 'BOOK ${document.displayName}',
        ScoreRow(:final score) => score.title,
      },
  ];

  test('a file with one Score gets no header', () {
    final solo = piece('s1', documentId: 'd1', title: 'Solo');
    expect(labels(rows([solo], [book('d1')])), ['Solo']);
  });

  test('two or more pieces of one file sit under a header, in page order', () {
    final scores = [
      piece('s3', documentId: 'd1', title: 'Third', firstPage: 17, lastPage: 24),
      piece('s1', documentId: 'd1', title: 'First', firstPage: 1, lastPage: 8),
      piece('s2', documentId: 'd1', title: 'Second', firstPage: 9, lastPage: 16),
    ];
    expect(labels(rows(scores, [book('d1', title: 'Etudes')])), [
      'BOOK Etudes',
      'First',
      'Second',
      'Third',
    ]);
  });

  test('page order inside a book holds in every sort mode', () {
    final scores = [
      piece(
        's1',
        documentId: 'd1',
        title: 'Zebra',
        firstPage: 1,
        lastPage: 8,
        lastOpenedAt: DateTime.utc(2026, 1, 1),
      ),
      piece(
        's2',
        documentId: 'd1',
        title: 'Apple',
        firstPage: 9,
        lastPage: 16,
        lastOpenedAt: DateTime.utc(2026, 8, 1),
      ),
    ];
    for (final mode in LibrarySortMode.values) {
      expect(
        labels(rows(scores, [book('d1', title: 'Etudes')], mode: mode)),
        ['BOOK Etudes', 'Zebra', 'Apple'],
        reason:
            'the pieces of one book have one natural order and it is the order '
            'they are printed in (Spec 0054, G3 #5)',
      );
    }
  });

  test('headers and loose pieces are sorted against each other by title', () {
    final scores = [
      piece('s0', documentId: 'd0', title: 'Misty'),
      piece('s1', documentId: 'd1', title: 'One', firstPage: 1, lastPage: 8),
      piece('s2', documentId: 'd1', title: 'Two', firstPage: 9, lastPage: 16),
      piece('s3', documentId: 'd2', title: 'Air', firstPage: 1, lastPage: 8),
      piece('s4', documentId: 'd2', title: 'Bee', firstPage: 9, lastPage: 16),
    ];
    final list = rows(scores, [
      book('d0', fileName: 'Misty.pdf'),
      book('d1', title: 'Etudes'),
      book('d2', title: 'Album'),
    ]);
    expect(labels(list), [
      'BOOK Album',
      'Air',
      'Bee',
      'BOOK Etudes',
      'One',
      'Two',
      'Misty',
    ]);
  });

  test('Created reads the book\'s arrival, not its newest piece', () {
    // splitScore stamps every new piece with `now`, so taking the newest child
    // would send a book bought last year to the top every time one more piece
    // is carved out of it (Spec 0054, G3 #4).
    final scores = [
      piece(
        's1',
        documentId: 'd1',
        title: 'One',
        firstPage: 1,
        lastPage: 8,
        createdAt: DateTime.utc(2025, 1, 1),
      ),
      piece(
        's2',
        documentId: 'd1',
        title: 'Two',
        firstPage: 9,
        lastPage: 16,
        createdAt: DateTime.utc(2026, 8, 5),
      ),
      piece(
        's3',
        documentId: 'd2',
        title: 'Fresh',
        createdAt: DateTime.utc(2026, 6, 1),
      ),
    ];
    final list = rows(
      scores,
      [
        book('d1', title: 'Old book', importedAt: DateTime.utc(2025, 1, 1)),
        book('d2', fileName: 'Fresh.pdf'),
      ],
      mode: LibrarySortMode.created,
    );
    expect(labels(list), ['Fresh', 'BOOK Old book', 'One', 'Two']);
  });

  test('Last viewed puts a book where its most recent piece puts it', () {
    final scores = [
      piece(
        's1',
        documentId: 'd1',
        title: 'One',
        firstPage: 1,
        lastPage: 8,
        lastOpenedAt: DateTime.utc(2026, 8, 5),
      ),
      piece('s2', documentId: 'd1', title: 'Two', firstPage: 9, lastPage: 16),
      piece(
        's3',
        documentId: 'd2',
        title: 'Older',
        lastOpenedAt: DateTime.utc(2026, 7, 1),
      ),
      piece('s4', documentId: 'd3', title: 'Never opened'),
    ];
    final list = rows(
      scores,
      [
        book('d1', title: 'Etudes'),
        book('d2', fileName: 'Older.pdf'),
        book('d3', fileName: 'Never opened.pdf'),
      ],
      mode: LibrarySortMode.lastViewed,
    );
    expect(labels(list), [
      'BOOK Etudes',
      'One',
      'Two',
      'Older',
      'Never opened',
    ]);
  });

  test('a book narrowed to one visible piece keeps its header', () {
    // The count is over the whole library, so search and filters cannot hide
    // which book a surviving row came out of (Spec 0054, G3 #7).
    final all = [
      piece('s1', documentId: 'd1', title: 'One', firstPage: 1, lastPage: 8),
      piece('s2', documentId: 'd1', title: 'Two', firstPage: 9, lastPage: 16),
    ];
    final list = buildLibraryRows(
      scores: [all.last],
      documentsById: {'d1': book('d1', title: 'Etudes')},
      counts: countScoresByDocument(all),
      mode: LibrarySortMode.title,
    );
    expect(labels(list), ['BOOK Etudes', 'Two']);
    expect((list.first as BookHeaderRow).pieces, 1);
  });

  test('a piece inside a book knows the header already named it', () {
    final scores = [
      piece('s1', documentId: 'd1', title: 'One', firstPage: 1, lastPage: 8),
      piece('s2', documentId: 'd1', title: 'Two', firstPage: 9, lastPage: 16),
      piece('s3', documentId: 'd2', title: 'Solo'),
    ];
    final list = rows(scores, [book('d1'), book('d2')]);
    final inBook = [
      for (final row in list)
        if (row is ScoreRow) '${row.score.title}:${row.inBook}',
    ];
    expect(inBook, ['One:true', 'Two:true', 'Solo:false']);
  });

  test('a Score whose document is missing is still listed', () {
    // A manifest that lost a document must not take a row down with it.
    final scores = [
      piece('s1', documentId: 'gone', title: 'One', firstPage: 1, lastPage: 8),
      piece('s2', documentId: 'gone', title: 'Two', firstPage: 9, lastPage: 16),
    ];
    expect(labels(rows(scores, const [])), ['One', 'Two']);
  });
}
