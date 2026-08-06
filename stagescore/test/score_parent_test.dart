import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/score.dart';

/// Score.parentId and root/child helpers (Spec 0055).
void main() {
  Score root({String id = 'root'}) => Score(
    id: id,
    title: 'Chopin Etudes',
    pdfDocumentId: 'doc',
    createdAt: DateTime.utc(2026, 1, 1),
  );

  Score child({
    String id = 'c1',
    String parentId = 'root',
    int first = 1,
    int last = 8,
  }) => Score(
    id: id,
    title: 'Op. 10 No. 1',
    pdfDocumentId: 'doc',
    parentId: parentId,
    pageExtent: PageExtent(firstPage: first, lastPage: last),
    createdAt: DateTime.utc(2026, 1, 2),
  );

  test('parentId round-trips through JSON and is absent when null', () {
    final r = root();
    expect(r.toJson().containsKey('parentId'), isFalse);
    expect(Score.fromJson(r.toJson()).parentId, isNull);

    final c = child();
    expect(c.toJson()['parentId'], 'root');
    expect(Score.fromJson(c.toJson()).parentId, 'root');
  });

  test('an old JSON without parentId is a root', () {
    final score = Score.fromJson({
      'id': 'a',
      'title': 'Solo',
      'pdfDocumentId': 'a',
      'pageExtent': null,
      'createdAt': '2026-01-02T03:04:05.000Z',
    });
    expect(score.parentId, isNull);
    expect(score.isRoot, isTrue);
  });

  test('isRoot is exactly parentId == null', () {
    expect(root().isRoot, isTrue);
    expect(child().isRoot, isFalse);
  });

  test('childrenOfRoot keeps page order and ignores other parents', () {
    final scores = [
      child(id: 'c2', first: 9, last: 16),
      root(),
      child(id: 'other', parentId: 'elsewhere', first: 1, last: 2),
      child(id: 'c1', first: 1, last: 8),
    ];
    expect(
      childrenOfRoot(scores, 'root').map((s) => s.id).toList(),
      ['c1', 'c2'],
    );
  });

  test('rootsOnly drops every child', () {
    final scores = [root(), child(), root(id: 'solo')];
    expect(rootsOnly(scores).map((s) => s.id).toList(), ['root', 'solo']);
  });

  test('copyWith can set or clear parentId', () {
    final c = child().copyWith(clearParentId: true);
    expect(c.parentId, isNull);
    expect(root().copyWith(parentId: 'other').parentId, 'other');
  });
}
