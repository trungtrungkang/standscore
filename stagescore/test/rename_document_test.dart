import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/library/score.dart';
import 'package:stagescore/library/score_library.dart';

/// Naming a book, and keeping that name (Spec 0054).
void main() {
  late Directory temp;
  late ScoreLibrary library;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('rename_document_');
    library = ScoreLibrary(root: temp, countPages: (path) async => 8);
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  Future<File> sourceFile(String fileName) async {
    final file = File(p.join(temp.path, fileName));
    await file.writeAsString('%PDF-1.4');
    return file;
  }

  Future<Score> importPdf(String fileName) async {
    final source = await sourceFile(fileName);
    return library.importPdf(
      sourcePath: source.path,
      originalFileName: fileName,
    );
  }

  Future<String> displayNameFor(Score score) async {
    await library.listScores();
    return library.documentFor(score)!.displayName;
  }

  test('the name is what the Library reads back', () async {
    final book = await importPdf('scan_0421.pdf');
    expect(await displayNameFor(book), 'scan_0421');

    await library.renameDocument(
      documentId: library.documentFor(book)!.id,
      title: 'Chopin Etudes',
    );

    expect(await displayNameFor(book), 'Chopin Etudes');
  });

  test('a fresh ScoreLibrary on the same folder reads the name', () async {
    final book = await importPdf('scan_0421.pdf');
    await library.renameDocument(
      documentId: library.documentFor(book)!.id,
      title: 'Chopin Etudes',
    );

    library = ScoreLibrary(root: temp, countPages: (path) async => 8);
    final scores = await library.listScores();
    expect(library.documentFor(scores.single)!.displayName, 'Chopin Etudes');
  });

  test('an empty name goes back to the file name', () async {
    final book = await importPdf('scan_0421.pdf');
    final id = library.documentFor(book)!.id;
    await library.renameDocument(documentId: id, title: 'Chopin Etudes');

    await library.renameDocument(documentId: id, title: '  ');

    // Not a book called "" and not a book called "Untitled": the file name is
    // still a fact, and it is the best name left.
    expect(await displayNameFor(book), 'scan_0421');
    expect(library.documentFor(book)!.title, isNull);
  });

  test('renaming the book renames no Score', () async {
    final book = await importPdf('Chopin.pdf');
    final pieces = await library.splitScore(
      scoreId: book.id,
      marks: const [
        (startPage: 1, title: 'Op. 10 No. 1'),
        (startPage: 5, title: 'Op. 10 No. 2'),
      ],
    );
    await library.renameDocument(
      documentId: library.documentFor(book)!.id,
      title: 'Etudes, Op. 10',
    );

    final after = await library.listScores();
    expect(
      [for (final score in after) score.title],
      containsAll([pieces.first.title, pieces.last.title]),
    );
  });

  test('Replace PDF keeps the name', () async {
    final book = await importPdf('scan_0421.pdf');
    final documentId = library.documentFor(book)!.id;
    await library.renameDocument(documentId: documentId, title: 'Chopin Etudes');

    // The bytes are a different file; the book is the same book, and the name
    // the musician typed is about the book. This path used to rebuild the
    // PdfDocument field by field and drop the name without a word.
    final replacement = await sourceFile('rescan.pdf');
    await library.replacePdf(
      scoreId: book.id,
      sourcePath: replacement.path,
      overlays: ReplacePdfOverlayChoice.keep,
    );

    expect(await displayNameFor(book), 'Chopin Etudes');
    expect(library.documentFor(book)!.originalFileName, 'scan_0421.pdf');
  });

  test('renaming a document nobody has is an error, not a silent no-op', () async {
    await importPdf('Chopin.pdf');
    await expectLater(
      library.renameDocument(documentId: 'no-such-doc', title: 'X'),
      throwsStateError,
    );
  });
}
