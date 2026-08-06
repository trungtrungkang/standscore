import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/piece_resplit.dart';
import 'package:stagescore/library/score.dart';

/// Pure resplit-planning logic behind "Edit pieces" (Spec 0055 follow-up).
void main() {
  final now = DateTime.utc(2026, 1, 1);
  const bounds = PageExtent(firstPage: 1, lastPage: 20);

  Score piece({
    required String id,
    required int firstPage,
    required int lastPage,
    String title = 'Untitled',
  }) => Score(
    id: id,
    title: title,
    pdfDocumentId: 'doc',
    pageExtent: PageExtent(firstPage: firstPage, lastPage: lastPage),
    parentId: 'root',
    createdAt: now,
  );

  var nextIdCounter = 0;
  String nextId() => 'new-${nextIdCounter++}';

  setUp(() => nextIdCounter = 0);

  test('an unchanged range keeps its id, title included', () {
    final oldChildren = [
      piece(id: 'a', firstPage: 1, lastPage: 4, title: 'One'),
      piece(id: 'b', firstPage: 5, lastPage: 20, title: 'Two'),
    ];
    final plan = planPieceResplit(
      oldChildren: oldChildren,
      marks: const [
        (startPage: 1, title: 'One'),
        (startPage: 5, title: 'Two'),
      ],
      bounds: bounds,
      rootId: 'root',
      pdfDocumentId: 'doc',
      bookTitle: 'Book',
      now: now,
      nextId: nextId,
    );

    expect(plan.removedIds, isEmpty);
    expect(plan.children.map((c) => c.id), ['a', 'b']);
    expect(plan.children[0].pageExtent, const PageExtent(firstPage: 1, lastPage: 4));
    expect(plan.children[1].pageExtent, const PageExtent(firstPage: 5, lastPage: 20));
  });

  test('a renamed mark on an unchanged range keeps the id and takes the new title', () {
    final oldChildren = [
      piece(id: 'a', firstPage: 1, lastPage: 4, title: 'One'),
      piece(id: 'b', firstPage: 5, lastPage: 20, title: 'Two'),
    ];
    final plan = planPieceResplit(
      oldChildren: oldChildren,
      marks: const [
        (startPage: 1, title: 'Renamed'),
        (startPage: 5, title: 'Two'),
      ],
      bounds: bounds,
      rootId: 'root',
      pdfDocumentId: 'doc',
      bookTitle: 'Book',
      now: now,
      nextId: nextId,
    );

    expect(plan.removedIds, isEmpty);
    expect(plan.children[0].id, 'a');
    expect(plan.children[0].title, 'Renamed');
  });

  test('a moved boundary drops the old piece and creates a new one', () {
    final oldChildren = [
      piece(id: 'a', firstPage: 1, lastPage: 4, title: 'One'),
      piece(id: 'b', firstPage: 5, lastPage: 20, title: 'Two'),
    ];
    // Merge everything into a single piece starting at page 1 — the mark at
    // page 5 disappears, so 'a' (1-4) has no surviving range and 'b' (5-20)
    // does not match the new (1-20) range either.
    final plan = planPieceResplit(
      oldChildren: oldChildren,
      marks: const [(startPage: 1, title: 'Whole'), (startPage: 10, title: 'Rest')],
      bounds: bounds,
      rootId: 'root',
      pdfDocumentId: 'doc',
      bookTitle: 'Book',
      now: now,
      nextId: nextId,
    );

    expect(plan.removedIds, containsAll(['a', 'b']));
    expect(plan.children, hasLength(2));
    expect(plan.children.every((c) => c.id.startsWith('new-')), isTrue);
  });

  test('a mark that matches only one old range keeps that one and drops the rest', () {
    final oldChildren = [
      piece(id: 'a', firstPage: 1, lastPage: 4, title: 'One'),
      piece(id: 'b', firstPage: 5, lastPage: 12, title: 'Two'),
      piece(id: 'c', firstPage: 13, lastPage: 20, title: 'Three'),
    ];
    // Piece 'b' and 'c' are merged into one piece from page 5-20; 'a' is
    // untouched.
    final plan = planPieceResplit(
      oldChildren: oldChildren,
      marks: const [
        (startPage: 1, title: 'One'),
        (startPage: 5, title: 'Merged'),
      ],
      bounds: bounds,
      rootId: 'root',
      pdfDocumentId: 'doc',
      bookTitle: 'Book',
      now: now,
      nextId: nextId,
    );

    expect(plan.removedIds, ['b', 'c']);
    expect(plan.children[0].id, 'a');
    expect(plan.children[1].id, 'new-0');
    expect(plan.children[1].pageExtent, const PageExtent(firstPage: 5, lastPage: 20));
  });

  test('fewer than two marks is a no-op, returning the old children unchanged', () {
    final oldChildren = [piece(id: 'a', firstPage: 1, lastPage: 20)];
    final plan = planPieceResplit(
      oldChildren: oldChildren,
      marks: const [(startPage: 1, title: 'One')],
      bounds: bounds,
      rootId: 'root',
      pdfDocumentId: 'doc',
      bookTitle: 'Book',
      now: now,
      nextId: nextId,
    );

    expect(plan.children, same(oldChildren));
    expect(plan.removedIds, isEmpty);
  });

  test('a blank title on a matched mark keeps the old title', () {
    final oldChildren = [
      piece(id: 'a', firstPage: 1, lastPage: 4, title: 'One'),
      piece(id: 'b', firstPage: 5, lastPage: 20, title: 'Two'),
    ];
    final plan = planPieceResplit(
      oldChildren: oldChildren,
      marks: const [(startPage: 1, title: ' '), (startPage: 5, title: 'Two')],
      bounds: bounds,
      rootId: 'root',
      pdfDocumentId: 'doc',
      bookTitle: 'Book',
      now: now,
      nextId: nextId,
    );

    expect(plan.children[0].title, 'One');
  });

  test('a blank title on a brand new mark falls back to book — N', () {
    final plan = planPieceResplit(
      oldChildren: const <Score>[],
      marks: const [(startPage: 1, title: ''), (startPage: 5, title: '')],
      bounds: bounds,
      rootId: 'root',
      pdfDocumentId: 'doc',
      bookTitle: 'Book',
      now: now,
      nextId: nextId,
    );

    expect(plan.children[0].title, 'Book — 1');
    expect(plan.children[1].title, 'Book — 2');
  });
}
