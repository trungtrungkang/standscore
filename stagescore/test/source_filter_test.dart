import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/score.dart';
import 'package:stagescore/library/source_filter.dart';

Score _piece(String id, String documentId, {PageExtent? extent}) => Score(
  id: id,
  title: id,
  pdfDocumentId: documentId,
  pageExtent: extent,
  createdAt: DateTime.utc(2026),
);

void main() {
  final scores = [
    _piece('a', 'book', extent: const PageExtent(firstPage: 1, lastPage: 8)),
    _piece('b', 'book', extent: const PageExtent(firstPage: 9, lastPage: 16)),
    _piece('c', 'single'),
  ];

  test('filterScoresBySource keeps only pieces of that document', () {
    expect(
      filterScoresBySource(
        scores: scores,
        pdfDocumentId: 'book',
      ).map((s) => s.id),
      ['a', 'b'],
    );
  });

  test('a null document id is no filter at all', () {
    expect(
      filterScoresBySource(scores: scores, pdfDocumentId: null),
      hasLength(3),
    );
  });

  test('an unknown document id filters everything out', () {
    expect(
      filterScoresBySource(scores: scores, pdfDocumentId: 'gone'),
      isEmpty,
    );
  });

  test('a Score with no extent still belongs to its document', () {
    expect(
      filterScoresBySource(
        scores: scores,
        pdfDocumentId: 'single',
      ).map((s) => s.id),
      ['c'],
    );
  });

  test('only documents holding two or more Scores are sources', () {
    final counts = countScoresByDocument(scores);
    expect(counts, {'book': 2, 'single': 1});
    expect(isFilterableSource(counts, 'book'), isTrue);
    expect(isFilterableSource(counts, 'single'), isFalse);
    expect(isFilterableSource(counts, 'gone'), isFalse);
  });
}
