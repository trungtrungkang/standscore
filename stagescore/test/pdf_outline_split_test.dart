import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/library/outline_split.dart';

void main() {
  group('proposeSplitFromOutline', () {
    test('a flat outline becomes one proposal per entry, in page order', () {
      final proposals = proposeSplitFromOutline(const [
        OutlineEntry(title: 'Op. 10 No. 3', pageNumber: 17),
        OutlineEntry(title: 'Op. 10 No. 1', pageNumber: 1),
        OutlineEntry(title: 'Op. 10 No. 2', pageNumber: 9),
      ]);

      expect(proposals, [
        (startPage: 1, title: 'Op. 10 No. 1'),
        (startPage: 9, title: 'Op. 10 No. 2'),
        (startPage: 17, title: 'Op. 10 No. 3'),
      ]);
    });

    test('a nested outline keeps the pieces inside its chapters', () {
      final proposals = proposeSplitFromOutline(const [
        OutlineEntry(
          title: 'Book I',
          pageNumber: 1,
          children: [
            OutlineEntry(title: 'Prelude', pageNumber: 3),
            OutlineEntry(title: 'Fugue', pageNumber: 7),
          ],
        ),
        OutlineEntry(
          title: 'Book II',
          pageNumber: 20,
          children: [OutlineEntry(title: 'Prelude', pageNumber: 22)],
        ),
      ]);

      expect(proposals.map((p) => p.startPage), [1, 3, 7, 20, 22]);
      expect(proposals.map((p) => p.title), [
        'Book I',
        'Prelude',
        'Fugue',
        'Book II',
        'Prelude',
      ]);
    });

    test('a node with no destination is skipped, its children are not', () {
      final proposals = proposeSplitFromOutline(const [
        OutlineEntry(
          title: 'Contents',
          children: [
            OutlineEntry(title: 'First', pageNumber: 2),
            OutlineEntry(title: 'Second', pageNumber: 10),
          ],
        ),
      ]);

      expect(proposals, [
        (startPage: 2, title: 'First'),
        (startPage: 10, title: 'Second'),
      ]);
    });

    test('a destination-less leaf loses nothing else', () {
      final proposals = proposeSplitFromOutline(const [
        OutlineEntry(title: 'First', pageNumber: 1),
        OutlineEntry(title: 'Nowhere'),
        OutlineEntry(title: 'Third', pageNumber: 5),
      ]);

      expect(proposals.map((p) => p.startPage), [1, 5]);
    });

    test('an empty outline proposes nothing', () {
      expect(proposeSplitFromOutline(const []), isEmpty);
    });

    test('two entries on one page collapse to the outer title', () {
      final proposals = proposeSplitFromOutline(const [
        OutlineEntry(
          title: 'Chapter',
          pageNumber: 4,
          children: [OutlineEntry(title: 'Same page', pageNumber: 4)],
        ),
      ]);

      expect(proposals, [(startPage: 4, title: 'Chapter')]);
    });

    test('blank titles and impossible pages are ignored', () {
      final proposals = proposeSplitFromOutline(const [
        OutlineEntry(title: '   ', pageNumber: 2),
        OutlineEntry(title: 'Real', pageNumber: 3),
        OutlineEntry(title: 'Zero', pageNumber: 0),
      ]);

      expect(proposals, [(startPage: 3, title: 'Real')]);
    });
  });

  group('looksLikeCollection', () {
    test('an outline with two or more destinations qualifies', () {
      expect(
        looksLikeCollection(
          pageCount: 4,
          proposals: const [
            (startPage: 1, title: 'a'),
            (startPage: 2, title: 'b'),
          ],
        ),
        isTrue,
      );
    });

    test('a long file qualifies even with no outline', () {
      expect(looksLikeCollection(pageCount: 31, proposals: const []), isTrue);
      expect(looksLikeCollection(pageCount: 30, proposals: const []), isFalse);
    });

    test('an ordinary single piece does not', () {
      expect(
        looksLikeCollection(
          pageCount: 4,
          proposals: const [(startPage: 1, title: 'only')],
        ),
        isFalse,
      );
      expect(looksLikeCollection(pageCount: null, proposals: const []), isFalse);
    });
  });
}
