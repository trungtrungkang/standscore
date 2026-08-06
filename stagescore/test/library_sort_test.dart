import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/library/library_sort.dart';
import 'package:stagescore/library/library_sort_prefs_store.dart';
import 'package:stagescore/library/score.dart';

Score _score(String id, String title, {DateTime? created, DateTime? opened}) {
  return Score(
    id: id,
    title: title,
    pdfDocumentId: id,
    createdAt: created ?? DateTime.utc(2026, 1, 1),
    lastOpenedAt: opened,
  );
}

void main() {
  test('title sorts A–Z case-insensitive', () {
    final sorted = sortScores([
      _score('1', 'zebra'),
      _score('2', 'Apple'),
      _score('3', 'mango'),
    ], LibrarySortMode.title);
    expect(sorted.map((s) => s.title), ['Apple', 'mango', 'zebra']);
  });

  test('created sorts newest first', () {
    final sorted = sortScores([
      _score('1', 'old', created: DateTime.utc(2026, 1, 1)),
      _score('2', 'new', created: DateTime.utc(2026, 3, 1)),
      _score('3', 'mid', created: DateTime.utc(2026, 2, 1)),
    ], LibrarySortMode.created);
    expect(sorted.map((s) => s.id), ['2', '3', '1']);
  });

  test('lastViewed puts never-opened last; recent first', () {
    final sorted = sortScores([
      _score('a', 'Never'),
      _score('b', 'Older open', opened: DateTime.utc(2026, 1, 1)),
      _score('c', 'Newer open', opened: DateTime.utc(2026, 2, 1)),
    ], LibrarySortMode.lastViewed);
    expect(sorted.map((s) => s.id), ['c', 'b', 'a']);
  });

  test('LibrarySortPrefsStore round-trips', () async {
    final root = await Directory.systemTemp.createTemp('sort_prefs_');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    final store = LibrarySortPrefsStore(root: root);
    expect(await store.load(), LibrarySortMode.lastViewed);
    await store.save(LibrarySortMode.title);
    expect(
      await LibrarySortPrefsStore(root: root).load(),
      LibrarySortMode.title,
    );
  });
}
