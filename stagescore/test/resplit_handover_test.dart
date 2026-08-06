import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/layout/page_scale.dart';
import 'package:stagescore/layout/page_scale_prefs_store.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/score.dart';
import 'package:stagescore/library/score_library.dart';
import 'package:stagescore/library/split_handover.dart';
import 'package:stagescore/pageorder/page_order.dart';
import 'package:stagescore/pageorder/page_order_store.dart';

/// What a piece hands over when it is split again (Spec 0054 / 0055).
void main() {
  late Directory temp;
  late ScoreLibrary library;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('resplit_handover_');
    library = ScoreLibrary(root: temp, countPages: (path) async => 20);
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  Future<({Score root, Score first, Score second})> bookInTwo() async {
    final source = File(p.join(temp.path, 'Chopin Etudes.pdf'));
    await source.writeAsString('%PDF-1.4');
    final book = await library.importPdf(
      sourcePath: source.path,
      originalFileName: 'Chopin Etudes.pdf',
    );
    final after = await library.splitScore(
      scoreId: book.id,
      marks: const [
        (startPage: 1, title: 'First half'),
        (startPage: 11, title: 'Second half'),
      ],
    );
    final pieces = childrenOfRoot(after, book.id);
    return (
      root: after.firstWhere((s) => s.id == book.id),
      first: pieces[0],
      second: pieces[1],
    );
  }

  test('a page scale override follows its page into the new piece', () async {
    final book = await bookInTwo();
    final parent = book.second;
    final store = PageScalePrefsStore(root: temp);
    await store.save(
      PageScalePrefs(
        pageScales: {
          PageScalePrefs.pageKey(parent.id, 12): 1.1,
          PageScalePrefs.pageKey(parent.id, 18): 1.3,
          PageScalePrefs.pageKey(book.first.id, 2): 1.2,
        },
      ),
    );

    final after = await library.splitScore(
      scoreId: parent.id,
      marks: const [
        (startPage: 11, title: 'Second half'),
        (startPage: 15, title: 'Third'),
      ],
    );
    final pieces = childrenOfRoot(after, book.root.id);
    await handOverPageScales(
      root: temp,
      originalScoreId: parent.id,
      pieces: pieces,
    );

    final third = after.firstWhere(
      (s) => s.parentId == book.root.id && s.id != parent.id && s.id != book.first.id,
    );
    final prefs = await store.load();
    expect(prefs.pageScales[PageScalePrefs.pageKey(parent.id, 12)], 1.1);
    expect(prefs.pageScales[PageScalePrefs.pageKey(third.id, 18)], 1.3);
    expect(
      prefs.pageScales.containsKey(PageScalePrefs.pageKey(parent.id, 18)),
      isFalse,
    );
    expect(prefs.pageScales[PageScalePrefs.pageKey(book.first.id, 2)], 1.2);
  });

  test('the parent\'s page order is narrowed to what it keeps', () async {
    final book = await bookInTwo();
    final parent = book.second;
    final orders = PageOrderStore(root: temp, scoreId: parent.id);
    await orders.save(PageOrder.forExtent(firstPage: 11, pageCount: 10));

    final dropping = await pageOrderSlotsOutside(
      root: temp,
      scoreId: parent.id,
      extent: const PageExtent(firstPage: 11, lastPage: 14),
    );
    expect(dropping, 6);

    await library.splitScore(
      scoreId: parent.id,
      marks: const [
        (startPage: 11, title: 'Second half'),
        (startPage: 15, title: 'Third'),
      ],
    );
    await restrictPageOrderTo(
      root: temp,
      scoreId: parent.id,
      extent: const PageExtent(firstPage: 11, lastPage: 14),
    );

    final stored = await orders.loadStored();
    expect(stored!.entries.map((e) => e.sourcePage), [11, 12, 13, 14]);
  });

  test('a piece with no page order and no overrides needs no handover', () async {
    final book = await bookInTwo();
    final parent = book.second;

    expect(
      await pageOrderSlotsOutside(
        root: temp,
        scoreId: parent.id,
        extent: const PageExtent(firstPage: 11, lastPage: 14),
      ),
      0,
    );

    final after = await library.splitScore(
      scoreId: parent.id,
      marks: const [
        (startPage: 11, title: 'Second half'),
        (startPage: 15, title: 'Third'),
      ],
    );
    await handOverPageScales(
      root: temp,
      originalScoreId: parent.id,
      pieces: after,
    );
    await restrictPageOrderTo(
      root: temp,
      scoreId: parent.id,
      extent: const PageExtent(firstPage: 11, lastPage: 14),
    );

    expect(
      await PageOrderStore(root: temp, scoreId: parent.id).loadStored(),
      isNull,
    );
    expect((await PageScalePrefsStore(root: temp).load()).pageScales, isEmpty);
  });
}
