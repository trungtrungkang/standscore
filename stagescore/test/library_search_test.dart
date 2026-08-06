import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/bookmark/bookmark_store.dart';
import 'package:stagescore/library/library_search.dart';
import 'package:stagescore/library/score.dart';

Score _score(String id, String title) => Score(
  id: id,
  title: title,
  pdfDocumentId: id,
  createdAt: DateTime.utc(2026),
);

void main() {
  test('textMatchesQuery is case-insensitive substring', () {
    expect(textMatchesQuery('Moonlight Sonata', 'moon'), isTrue);
    expect(textMatchesQuery('Moonlight Sonata', 'SONATA'), isTrue);
    expect(textMatchesQuery('Moonlight Sonata', 'jazz'), isFalse);
    expect(textMatchesQuery('Anything', '  '), isTrue);
  });

  test('filterScoresBySearch matches title or bookmark titles', () {
    final scores = [
      _score('a', 'Moonlight'),
      _score('b', 'Jazz Standards'),
      _score('c', 'Etudes'),
    ];
    final bookmarks = {
      'a': ['Cadenza'],
      'b': ['Chorus 2'],
      'c': <String>[],
    };

    expect(
      filterScoresBySearch(
        scores: scores,
        query: 'moon',
        bookmarkTitlesByScoreId: bookmarks,
      ).map((s) => s.id),
      ['a'],
    );
    expect(
      filterScoresBySearch(
        scores: scores,
        query: 'cadenza',
        bookmarkTitlesByScoreId: bookmarks,
      ).map((s) => s.id),
      ['a'],
    );
    expect(
      filterScoresBySearch(
        scores: scores,
        query: '',
        bookmarkTitlesByScoreId: bookmarks,
      ),
      hasLength(3),
    );
  });

  test('loadBookmarkTitleIndex reads BookmarkStore files', () async {
    final root = await Directory.systemTemp.createTemp('search_bm_');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    final store = BookmarkStore(root: root, scoreId: 'score-1');
    await store.add(title: 'Solo break', pageNumber: 3);
    await store.add(title: 'D.S.', pageNumber: 8);

    final index = await loadBookmarkTitleIndex(
      root: root,
      scoreIds: ['score-1', 'score-2'],
    );
    expect(index['score-1'], ['Solo break', 'D.S.']);
    expect(index.containsKey('score-2'), isFalse);
    expect(
      File(p.join(root.path, 'bookmarks', 'score-1.json')).existsSync(),
      isTrue,
    );
  });
}
