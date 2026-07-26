import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:standscore/setlist/setlist.dart';
import 'package:standscore/setlist/setlist_store.dart';

void main() {
  test('SetlistStore save / list / delete / markOpened round-trip', () async {
    final root = await Directory.systemTemp.createTemp('setlist_store_');
    addTearDown(() => root.delete(recursive: true));
    final store = SetlistStore(root: root);

    expect(await store.list(), isEmpty);

    final created = DateTime.utc(2026, 7, 26);
    final list = Setlist(
      id: 'sl1',
      title: 'Gig',
      scoreIds: const ['a', 'b'],
      createdAt: created,
    );
    await store.upsert(list);

    expect(
      File(p.join(root.path, 'setlists.json')).existsSync(),
      isTrue,
    );

    final listed = await store.list();
    expect(listed, hasLength(1));
    expect(listed.first.title, 'Gig');
    expect(listed.first.scoreIds, ['a', 'b']);

    final opened = await store.markOpened(list);
    expect(opened.lastOpenedAt, isNotNull);

    await store.delete('sl1');
    expect(await store.list(), isEmpty);
  });
}
