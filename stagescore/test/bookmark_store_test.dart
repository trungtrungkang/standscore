import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/bookmark/bookmark_store.dart';

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('bookmarks_');
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('round-trips per Score id', () async {
    final a = BookmarkStore(root: root, scoreId: 'score-a');
    final b = BookmarkStore(root: root, scoreId: 'score-b');

    await a.add(title: 'Solo', pageNumber: 3);
    await a.add(title: 'Intro', pageNumber: 1);
    await b.add(title: 'Other', pageNumber: 2);

    final listedA = await a.list();
    expect(listedA.map((e) => e.title), ['Intro', 'Solo']);
    expect(listedA.map((e) => e.pageNumber), [1, 3]);

    final listedB = await b.list();
    expect(listedB, hasLength(1));
    expect(listedB.first.title, 'Other');

    expect(
      File(p.join(root.path, 'bookmarks', 'score-a.json')).existsSync(),
      isTrue,
    );
  });

  test('rename and delete', () async {
    final store = BookmarkStore(root: root, scoreId: 's1');
    final created = await store.add(title: 'A', pageNumber: 2);
    await store.rename(created.id, 'Bridge');
    var listed = await store.list();
    expect(listed.single.title, 'Bridge');

    await store.delete(created.id);
    listed = await store.list();
    expect(listed, isEmpty);
  });

  test('empty title defaults to Page N', () async {
    final store = BookmarkStore(root: root, scoreId: 's1');
    final created = await store.add(title: '  ', pageNumber: 7);
    expect(created.title, 'Page 7');
  });
}
