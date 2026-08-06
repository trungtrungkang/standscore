import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/layout/page_scale.dart';
import 'package:stagescore/layout/page_scale_prefs_store.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/score.dart';
import 'package:stagescore/library/split_handover.dart';
import 'package:stagescore/pageorder/page_order.dart';
import 'package:stagescore/pageorder/page_order_store.dart';

/// What a split owes the overlays that were keyed to the whole book (0052).
///
/// Both of these fail silently if nobody calls them: per-page scale overrides
/// would be orphaned under the book's Score id, and the first piece would open
/// onto every page of the book.
void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('split_handover_');
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  Score piece(String id, int first, int last) => Score(
    id: id,
    title: id,
    pdfDocumentId: 'doc',
    pageExtent: PageExtent(firstPage: first, lastPage: last),
    createdAt: DateTime.utc(2026),
  );

  group('page scale', () {
    test('each override follows the page into the piece that now owns it', () async {
      final store = PageScalePrefsStore(root: temp);
      await store.save(
        const PageScalePrefs(
          pageScales: {'book:2': 1.2, 'book:15': 0.8, 'other:3': 1.1},
        ),
      );

      await handOverPageScales(
        root: temp,
        originalScoreId: 'book',
        pieces: [piece('book', 1, 8), piece('p2', 9, 20)],
      );

      final loaded = await store.load();
      expect(loaded.pageScales['book:2'], 1.2, reason: 'page 2 is still piece 1');
      expect(loaded.pageScales['p2:15'], 0.8, reason: 'page 15 moved to piece 2');
      expect(loaded.pageScales.containsKey('book:15'), isFalse);
      expect(loaded.pageScales['other:3'], 1.1, reason: 'other Scores untouched');
      expect(
        loaded.pageScales['p2:15'],
        isNotNull,
        reason: 'the page number never changes — only who owns it',
      );
    });

    test('an override on a page no piece covers is dropped, not moved', () async {
      final store = PageScalePrefsStore(root: temp);
      await store.save(const PageScalePrefs(pageScales: {'book:50': 1.4}));

      await handOverPageScales(
        root: temp,
        originalScoreId: 'book',
        pieces: [piece('book', 1, 8)],
      );

      expect((await store.load()).pageScales, isEmpty);
    });

    test('nothing to hand over leaves the prefs file alone', () async {
      final store = PageScalePrefsStore(root: temp);
      await store.save(const PageScalePrefs(fixedScale: 1.3));

      await handOverPageScales(
        root: temp,
        originalScoreId: 'book',
        pieces: [piece('book', 1, 8)],
      );

      expect((await store.load()).fixedScale, 1.3);
    });
  });

  group('page order', () {
    test('the count is available before the change is made', () async {
      await PageOrderStore(root: temp, scoreId: 'book').save(
        PageOrder.forExtent(firstPage: 1, pageCount: 10),
      );

      final dropping = await pageOrderSlotsOutside(
        root: temp,
        scoreId: 'book',
        extent: const PageExtent(firstPage: 1, lastPage: 4),
      );

      expect(dropping, 6);
      final stored = await PageOrderStore(root: temp, scoreId: 'book').loadStored();
      expect(stored!.length, 10, reason: 'asking must not change anything');
    });

    test('the first piece stops walking into the second', () async {
      final store = PageOrderStore(root: temp, scoreId: 'book');
      await store.save(PageOrder.forExtent(firstPage: 1, pageCount: 10));

      final dropped = await restrictPageOrderTo(
        root: temp,
        scoreId: 'book',
        extent: const PageExtent(firstPage: 1, lastPage: 4),
      );

      expect(dropped, 6);
      final stored = await store.loadStored();
      expect(stored!.entries.map((e) => e.sourcePage), [1, 2, 3, 4]);
    });

    test('a piece with no stored order has nothing to restrict', () async {
      final dropped = await restrictPageOrderTo(
        root: temp,
        scoreId: 'never-edited',
        extent: const PageExtent(firstPage: 9, lastPage: 16),
      );

      expect(dropped, 0);
      expect(
        await PageOrderStore(root: temp, scoreId: 'never-edited').loadStored(),
        isNull,
        reason: 'restricting must not create a file the Score never had',
      );
    });

    test('an unchanged extent writes nothing', () async {
      final store = PageOrderStore(root: temp, scoreId: 'p');
      await store.save(PageOrder.forExtent(firstPage: 9, pageCount: 4));

      final dropped = await restrictPageOrderTo(
        root: temp,
        scoreId: 'p',
        extent: const PageExtent(firstPage: 9, lastPage: 12),
      );

      expect(dropped, 0);
    });
  });
}
