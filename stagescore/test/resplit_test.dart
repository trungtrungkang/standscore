import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/score.dart';
import 'package:stagescore/library/score_library.dart';

/// Splitting a piece into smaller pieces under one root (Spec 0054 / 0055).
void main() {
  late Directory temp;
  late ScoreLibrary library;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('resplit_');
    library = ScoreLibrary(root: temp, countPages: (path) async => 20);
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  Future<Score> importBook([String fileName = 'Chopin Etudes.pdf']) async {
    final source = File(p.join(temp.path, fileName));
    await source.writeAsString('%PDF-1.4');
    return library.importPdf(
      sourcePath: source.path,
      originalFileName: fileName,
    );
  }

  /// A 20-page book cut in two under one root.
  Future<({Score root, Score first, Score second})> bookInTwo() async {
    final book = await importBook();
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

  ({int first, int last})? extentOf(List<Score> scores, String id) {
    final extent = scores.firstWhere((s) => s.id == id).pageExtent;
    return extent == null
        ? null
        : (first: extent.firstPage, last: extent.lastPage);
  }

  test('a piece splits inside its own pages, leaving its sibling alone', () async {
    final book = await bookInTwo();

    final after = await library.splitScore(
      scoreId: book.second.id,
      marks: const [
        (startPage: 11, title: 'Two'),
        (startPage: 15, title: 'Three'),
      ],
    );

    expect(after, hasLength(4), reason: 'root + three children');
    expect(extentOf(after, book.first.id), (first: 1, last: 10));
    expect(extentOf(after, book.second.id), (first: 11, last: 14));
    final third = after.firstWhere(
      (s) =>
          s.parentId == book.root.id &&
          s.id != book.first.id &&
          s.id != book.second.id,
    );
    expect(extentOf(after, third.id), (first: 15, last: 20));
  });

  test('marks outside the piece are pulled onto its edges', () async {
    final book = await bookInTwo();

    final after = await library.splitScore(
      scoreId: book.second.id,
      marks: const [
        (startPage: 3, title: 'Two'),
        (startPage: 25, title: 'Three'),
      ],
    );

    expect(extentOf(after, book.first.id), (first: 1, last: 10));
    expect(extentOf(after, book.second.id), (first: 11, last: 19));
    final third = after.firstWhere(
      (s) =>
          s.parentId == book.root.id &&
          s.id != book.first.id &&
          s.id != book.second.id,
    );
    expect(extentOf(after, third.id), (first: 20, last: 20));
  });

  test('splitting the same piece twice keeps the pages accounted for', () async {
    var book = await bookInTwo();
    var scores = await library.splitScore(
      scoreId: book.second.id,
      marks: const [
        (startPage: 11, title: 'Two'),
        (startPage: 16, title: 'Three'),
      ],
    );
    final three = scores.firstWhere((s) => s.title == 'Three');
    scores = await library.splitScore(
      scoreId: three.id,
      marks: const [
        (startPage: 16, title: 'Three'),
        (startPage: 18, title: 'Four'),
      ],
    );

    final covered = <int>{};
    for (final score in childrenOfRoot(scores, book.root.id)) {
      final extent = score.extentIn(20)!;
      for (var page = extent.firstPage; page <= extent.lastPage; page++) {
        expect(
          covered.add(page),
          isTrue,
          reason: 'page $page ended up in two pieces at once',
        );
      }
    }
    expect(covered.length, 20, reason: 'a page fell out of every piece');
  });

  test('a piece keeps its id and its title through a sub-split', () async {
    final book = await bookInTwo();

    final after = await library.splitScore(
      scoreId: book.second.id,
      marks: const [
        (startPage: 11, title: ''),
        (startPage: 15, title: 'Three'),
      ],
    );

    final kept = after.firstWhere((s) => s.id == book.second.id);
    expect(kept.title, 'Second half');
    expect(kept.createdAt, book.second.createdAt);
  });

  test('a one-page piece has nothing to split', () async {
    final root = await importBook();
    final pieces = await library.splitScore(
      scoreId: root.id,
      marks: const [
        (startPage: 1, title: 'Long'),
        (startPage: 20, title: 'Last page'),
      ],
    );
    final last = childrenOfRoot(pieces, root.id).last;
    expect(extentOf(pieces, last.id), (first: 20, last: 20));

    final after = await library.splitScore(
      scoreId: last.id,
      marks: const [
        (startPage: 20, title: 'A'),
        (startPage: 20, title: 'B'),
      ],
    );
    expect(childrenOfRoot(after, root.id), hasLength(2));
    expect(extentOf(after, last.id), (first: 20, last: 20));
  });

  test('an extent left over from a longer file cannot reach past the end', () async {
    final book = await importBook();
    await library.updatePageExtent(
      scoreId: book.id,
      extent: const PageExtent(firstPage: 15, lastPage: 99),
    );

    // A root with a narrowed extent is still a root: split keeps it whole-file
    // and the marks become children clamped to the file.
    final after = await library.splitScore(
      scoreId: book.id,
      marks: const [
        (startPage: 15, title: 'One'),
        (startPage: 18, title: 'Two'),
      ],
    );

    expect(after.firstWhere((s) => s.id == book.id).pageExtent, isNull);
    final children = childrenOfRoot(after, book.id);
    expect(extentOf(after, children[0].id), (first: 15, last: 17));
    expect(extentOf(after, children[1].id), (first: 18, last: 20));
  });

  test('a Score that covers no page of its file refuses to split', () async {
    final book = await importBook();
    await library.updatePageExtent(
      scoreId: book.id,
      extent: const PageExtent(firstPage: 40, lastPage: 60),
    );

    await expectLater(
      library.splitScore(
        scoreId: book.id,
        marks: const [(startPage: 40, title: 'One')],
      ),
      throwsStateError,
    );
  });
}
