import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/pageorder/page_order.dart';
import 'package:stagescore/pageorder/page_order_store.dart';

/// PageOrder over one piece of a shared PDF (Spec 0052).
///
/// PageExtent is a **range** and PageOrder is a **sequence**, and the sequence
/// now runs inside the range. Mixing the two is the most expensive design
/// mistake available here, so these tests are written in absolute document
/// pages throughout — there is no such thing on disk as "page 3 of the piece".
void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('page_order_extent_');
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  group('forExtent', () {
    test('walks the piece\'s own pages in file order', () {
      final order = PageOrder.forExtent(firstPage: 12, pageCount: 8);

      expect(order.length, 8);
      expect(order.sourceFirstPage, 12);
      expect(order.sourceLastPage, 19);
      expect(order.entries.first.sourcePage, 12);
      expect(order.entries.last.sourcePage, 19);
      expect(order.isIdentity, isTrue);
    });

    test('identity is the whole-file case of the same thing', () {
      // Slot ids are fresh uuids, so the two are compared by shape.
      final identity = PageOrder.identity(4);
      final whole = PageOrder.forExtent(firstPage: 1, pageCount: 4);

      expect(identity.sourceFirstPage, whole.sourceFirstPage);
      expect(identity.sourcePageCount, whole.sourcePageCount);
      expect(
        identity.entries.map((e) => e.sourcePage),
        whole.entries.map((e) => e.sourcePage),
      );
      expect(PageOrder.identity(0).length, 0);
    });

    test('a rearranged piece is not identity, and Reset restores its pages', () {
      final moved = PageOrder.forExtent(firstPage: 12, pageCount: 3).move(0, 2);
      expect(moved.isIdentity, isFalse);

      final reset = moved.resetToOriginal();
      expect(reset.isIdentity, isTrue);
      expect(reset.entries.map((e) => e.sourcePage), [12, 13, 14]);
    });
  });

  group('narrowing a piece', () {
    test('counts the slots that would be dropped before anything changes', () {
      final order = PageOrder.forExtent(firstPage: 1, pageCount: 10);

      expect(order.slotsOutside(firstPage: 1, lastPage: 4), 6);
      expect(order.slotsOutside(firstPage: 1, lastPage: 10), 0);
      expect(order.slotsOutside(firstPage: 5, lastPage: 10), 4);
    });

    test('blanks are never counted — they belong to the sequence', () {
      final order = PageOrder.forExtent(
        firstPage: 1,
        pageCount: 4,
      ).insertBlank(2);

      expect(order.slotsOutside(firstPage: 1, lastPage: 4), 0);
    });

    test('restrictedTo drops out-of-range slots and rebases the piece', () {
      final book = PageOrder.forExtent(firstPage: 1, pageCount: 10);

      final piece = book.restrictedTo(firstPage: 3, lastPage: 5);

      expect(piece.entries.map((e) => e.sourcePage), [3, 4, 5]);
      expect(piece.sourceFirstPage, 3);
      expect(piece.sourcePageCount, 3);
      expect(piece.isIdentity, isTrue);
    });

    test('restrictedTo keeps duplicates and blanks that are still in range', () {
      final built = PageOrder.forExtent(firstPage: 1, pageCount: 6)
          .duplicate(2)
          .insertBlank(1);

      final piece = built.restrictedTo(firstPage: 3, lastPage: 4);

      expect(
        piece.entries.where((e) => e.isBlank),
        hasLength(1),
        reason: 'a blank page is not a page of the PDF, so it survives',
      );
      expect(
        piece.entries.where((e) => e.sourcePage == 3),
        hasLength(2),
        reason: 'the duplicate of page 3 is still inside the piece',
      );
      expect(piece.entries.every((e) => e.isBlank || e.sourcePage! >= 3), isTrue);
    });

    test('a piece left with nothing but blanks falls back to its own pages', () {
      final blanks = PageOrder.forExtent(firstPage: 1, pageCount: 2)
          .insertBlank(0)
          .removeAt(1)
          .removeAt(1);

      final piece = blanks.restrictedTo(firstPage: 7, lastPage: 9);

      expect(piece.isIdentity, isTrue);
      expect(piece.entries.map((e) => e.sourcePage), [7, 8, 9]);
    });

    test('widening again brings the pages back, since nothing was renumbered', () {
      final narrowed = PageOrder.forExtent(
        firstPage: 1,
        pageCount: 10,
      ).restrictedTo(firstPage: 1, lastPage: 3);

      final widened = narrowed.restrictedTo(firstPage: 1, lastPage: 10);

      expect(
        widened.entries.map((e) => e.sourcePage),
        [1, 2, 3],
        reason: 'the slots that were dropped are gone, but the rest kept their '
            'absolute pages, so no page silently became a different page',
      );
      expect(widened.sourcePageCount, 10);
    });
  });

  group('on disk', () {
    test('a whole-file order writes exactly the JSON it always did', () {
      final json = PageOrder.identity(3).toJson();

      expect(
        json.containsKey('sourceFirstPage'),
        isFalse,
        reason: 'a library that never split anything keeps its files byte for '
            'byte — that is the most important G4 check of this slice',
      );
    });

    test('a piece round-trips its first page', () {
      final piece = PageOrder.forExtent(firstPage: 12, pageCount: 8);

      final restored = PageOrder.fromJson(
        jsonDecode(jsonEncode(piece.toJson())) as Map<String, dynamic>,
      );

      expect(restored, piece);
      expect(restored.sourceFirstPage, 12);
    });

    test('an order written before 0052 reads back as a whole file', () {
      final restored = PageOrder.fromJson({
        'sourcePageCount': 2,
        'entries': [
          {'id': 'a', 'type': 'pdf', 'sourcePage': 1},
          {'id': 'b', 'type': 'pdf', 'sourcePage': 2},
        ],
      });

      expect(restored.sourceFirstPage, 1);
      expect(restored.isIdentity, isTrue);
    });

    test('loadStored says nothing rather than identity when there is no file', () async {
      final store = PageOrderStore(root: temp, scoreId: 's1');

      expect(await store.loadStored(), isNull);
      expect((await store.loadOrIdentity(3)).length, 3);
    });

    test('a piece with no stored order gets the pages of its extent', () async {
      final store = PageOrderStore(root: temp, scoreId: 's1');

      final order = await store.loadOrIdentity(8, sourceFirstPage: 12);

      expect(order.entries.map((e) => e.sourcePage), [12, 13, 14, 15, 16, 17, 18, 19]);
    });

    test('a stored order is restricted when the extent moved under it', () async {
      final store = PageOrderStore(root: temp, scoreId: 's1');
      await store.save(PageOrder.forExtent(firstPage: 1, pageCount: 10));

      final order = await store.loadOrIdentity(3, sourceFirstPage: 1);

      expect(order.entries.map((e) => e.sourcePage), [1, 2, 3]);
    });

    test('an unreadable PDF keeps the sequence instead of emptying it', () async {
      final store = PageOrderStore(root: temp, scoreId: 's1');
      final built = PageOrder.forExtent(firstPage: 1, pageCount: 4).move(0, 3);
      await store.save(built);

      // Page count 0 means "could not open the file", which is a reason to show
      // nothing — never a reason to conclude the piece has no pages.
      final order = await store.loadOrIdentity(0);

      expect(order, built);
    });
  });
}
