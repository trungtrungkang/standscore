import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/library/library_migration.dart';
import 'package:stagescore/library/score.dart';
import 'package:stagescore/library/score_library.dart';

/// Deleting one piece of a shared PDF must keep the file; deleting the last
/// Score that needs it must clean it up (Spec 0052 / 0055).
void main() {
  late Directory temp;
  late ScoreLibrary library;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('refcount_test');
    library = ScoreLibrary(root: temp, countPages: (path) async => 200);
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  Future<File> writePdf(String name) async {
    final file = File(p.join(temp.path, name));
    await file.writeAsBytes(const [0x25, 0x50, 0x44, 0x46]);
    return file;
  }

  test('deleting one piece of a book keeps the PDF for the others', () async {
    final source = await writePdf('Chopin Etudes.pdf');
    final book = await library.importPdf(
      sourcePath: source.path,
      originalFileName: 'Chopin Etudes.pdf',
    );
    final after = await library.splitScore(
      scoreId: book.id,
      marks: [
        (startPage: 1, title: 'Op. 10 No. 1'),
        (startPage: 9, title: 'Op. 10 No. 2'),
        (startPage: 17, title: 'Op. 10 No. 3'),
      ],
    );
    expect(after, hasLength(4), reason: 'root + three children');
    final pieces = childrenOfRoot(after, book.id);
    final pdf = library.absoluteFile(after.firstWhere((s) => s.id == book.id));

    await library.deleteScore(pieces[1].id);

    expect(await pdf.exists(), isTrue);
    expect((await library.listScores()), hasLength(3));
    expect((await library.listDocuments()), hasLength(1));
    for (final score in await library.listScores()) {
      expect(await library.absoluteFile(score).exists(), isTrue);
    }
  });

  test('deleting every child leaves the root and the PDF', () async {
    final source = await writePdf('Chopin Etudes.pdf');
    final book = await library.importPdf(
      sourcePath: source.path,
      originalFileName: 'Chopin Etudes.pdf',
    );
    final after = await library.splitScore(
      scoreId: book.id,
      marks: [
        (startPage: 1, title: 'One'),
        (startPage: 9, title: 'Two'),
      ],
    );
    final pdf = library.absoluteFile(after.firstWhere((s) => s.id == book.id));
    for (final piece in childrenOfRoot(after, book.id)) {
      await library.deleteScore(piece.id);
    }

    expect(await pdf.exists(), isTrue);
    final left = await library.listScores();
    expect(left, hasLength(1));
    expect(left.single.id, book.id);
    expect(left.single.pageExtent, isNull);
  });

  test('deleting a root cascades to children and cleans up the PDF', () async {
    final source = await writePdf('Chopin Etudes.pdf');
    final book = await library.importPdf(
      sourcePath: source.path,
      originalFileName: 'Chopin Etudes.pdf',
    );
    await library.splitScore(
      scoreId: book.id,
      marks: [
        (startPage: 1, title: 'One'),
        (startPage: 9, title: 'Two'),
      ],
    );
    final pdf = library.absoluteFile(
      (await library.listScores()).firstWhere((s) => s.id == book.id),
    );

    await library.deleteScore(book.id);

    expect(await pdf.exists(), isFalse);
    expect(await library.listScores(), isEmpty);
    expect(await library.listDocuments(), isEmpty);
  });

  test('two separately imported PDFs never share a document', () async {
    final a = await library.importPdf(
      sourcePath: (await writePdf('a.pdf')).path,
      originalFileName: 'a.pdf',
    );
    final b = await library.importPdf(
      sourcePath: (await writePdf('b.pdf')).path,
      originalFileName: 'b.pdf',
    );
    expect(a.pdfDocumentId, isNot(b.pdfDocumentId));

    final fileB = library.absoluteFile(b);
    await library.deleteScore(a.id);
    expect(await fileB.exists(), isTrue);
  });

  test('scoresSharingDocument counts root and children', () async {
    final book = await library.importPdf(
      sourcePath: (await writePdf('Book.pdf')).path,
      originalFileName: 'Book.pdf',
    );
    expect(await library.scoresSharingDocument(book.id), 1);

    await library.splitScore(
      scoreId: book.id,
      marks: [
        (startPage: 1, title: 'One'),
        (startPage: 5, title: 'Two'),
        (startPage: 9, title: 'Three'),
      ],
    );
    expect(await library.scoresSharingDocument(book.id), 4);
  });

  test('a Score pointing at a missing document does not break the list', () async {
    await library.importPdf(
      sourcePath: (await writePdf('a.pdf')).path,
      originalFileName: 'a.pdf',
    );
    final manifest = jsonDecode(await library.manifestFile.readAsString())
        as Map<String, dynamic>;
    manifest[pdfDocumentsKey] = <dynamic>[];
    await library.manifestFile.writeAsString(jsonEncode(manifest));

    final reopened = ScoreLibrary(root: temp);
    final scores = await reopened.listScores();

    expect(scores, hasLength(1), reason: 'reading the manifest still works');
    expect(reopened.documentFor(scores.single), isNull);
    expect(reopened.pageCountOf(scores.single), isNull);
    expect(() => reopened.absoluteFile(scores.single), throwsStateError);
  });

  test('splitting sets contiguous extents on the children', () async {
    final book = await library.importPdf(
      sourcePath: (await writePdf('Book.pdf')).path,
      originalFileName: 'Book.pdf',
    );
    final after = await library.splitScore(
      scoreId: book.id,
      marks: [
        (startPage: 1, title: 'One'),
        (startPage: 9, title: 'Two'),
        (startPage: 17, title: 'Three'),
      ],
    );

    final extents = childrenOfRoot(after, book.id).map((s) => s.pageExtent!).toList();
    expect(extents[0].firstPage, 1);
    expect(extents[0].lastPage, 8);
    expect(extents[1].firstPage, 9);
    expect(extents[1].lastPage, 16);
    expect(extents[2].firstPage, 17);
    expect(extents[2].lastPage, 200, reason: 'last piece runs to the end');
    expect(extents.fold<int>(0, (sum, e) => sum + e.length), 200);
    expect(after.firstWhere((s) => s.id == book.id).pageExtent, isNull);
  });

  test('the original Score survives a split as the whole-file root', () async {
    final book = await library.importPdf(
      sourcePath: (await writePdf('Book.pdf')).path,
      originalFileName: 'Book.pdf',
    );
    final after = await library.splitScore(
      scoreId: book.id,
      marks: [
        (startPage: 1, title: 'One'),
        (startPage: 9, title: 'Two'),
      ],
    );

    final root = after.firstWhere((s) => s.id == book.id);
    expect(root.parentId, isNull);
    expect(root.pageExtent, isNull);
    expect(root.title, 'Book');
    expect(root.createdAt, book.createdAt);
  });
}
