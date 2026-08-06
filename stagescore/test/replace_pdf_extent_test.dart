import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/score_library.dart';

/// Replacing the PDF under a book now touches every piece of it, and a shorter
/// file can leave an extent describing pages that no longer exist (Spec 0052).
///
/// The point of these tests is the *reporting*. Silently repairing a piece is
/// how a musician finds out on stage that the second half of their etude is
/// gone, so the result has to name what it changed.
void main() {
  late Directory temp;
  var pageCount = 200;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('replace_extent_test');
    pageCount = 200;
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  ScoreLibrary openLibrary() =>
      ScoreLibrary(root: temp, countPages: (path) async => pageCount);

  Future<String> writePdf(String name) async {
    final file = File(p.join(temp.path, name));
    await file.writeAsBytes(const [0x25, 0x50, 0x44, 0x46]);
    return file.path;
  }

  Future<({ScoreLibrary library, List<String> ids})> splitBook() async {
    final library = openLibrary();
    final book = await library.importPdf(
      sourcePath: await writePdf('Book.pdf'),
      originalFileName: 'Book.pdf',
    );
    final pieces = await library.splitScore(
      scoreId: book.id,
      marks: [
        (startPage: 1, title: 'One'),
        (startPage: 41, title: 'Two'),
        (startPage: 121, title: 'Three'),
      ],
    );
    return (library: library, ids: pieces.map((s) => s.id).toList());
  }

  test('every piece of the book counts as affected, not just the one', () async {
    final book = await splitBook();

    final result = await book.library.replacePdf(
      scoreId: book.ids.first,
      sourcePath: await writePdf('Same length.pdf'),
      overlays: ReplacePdfOverlayChoice.keep,
    );

    expect(result.sharedScoreCount, 4, reason: 'root + three children');
    expect(result.truncated, isEmpty);
    expect(result.reset, isEmpty);
  });

  test('a shorter file truncates the piece that straddles the new end', () async {
    final book = await splitBook();

    pageCount = 150;
    final result = await book.library.replacePdf(
      scoreId: book.ids.first,
      sourcePath: await writePdf('Shorter.pdf'),
      overlays: ReplacePdfOverlayChoice.keep,
    );

    expect(result.truncated.map((s) => s.title), ['Three']);
    expect(result.reset, isEmpty);
    final three = (await book.library.listScores()).firstWhere(
      (s) => s.title == 'Three',
    );
    expect(three.pageExtent, const PageExtent(firstPage: 121, lastPage: 150));
  });

  test('a piece left entirely past the end is reported, never left dangling', () async {
    final book = await splitBook();

    pageCount = 30;
    final result = await book.library.replacePdf(
      scoreId: book.ids.first,
      sourcePath: await writePdf('Much shorter.pdf'),
      overlays: ReplacePdfOverlayChoice.keep,
    );

    // Pieces two and three start past page 30, so nothing of them survives.
    expect(result.reset.map((s) => s.title), ['Two', 'Three']);
    expect(result.truncated.map((s) => s.title), ['One']);
    for (final score in await book.library.listScores()) {
      final extent = score.pageExtent;
      if (extent == null) continue;
      expect(
        extent.lastPage,
        lessThanOrEqualTo(30),
        reason: 'no Score may be left opening onto pages the file lost',
      );
    }
  });
}
