import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/library/pdf_document.dart';

/// The book's own name (Spec 0054).
void main() {
  PdfDocument document({String? title, String? fileName}) => PdfDocument(
    id: 'doc-1',
    relativePath: 'documents/doc-1.pdf',
    importedAt: DateTime.utc(2026, 8, 5),
    pageCount: 148,
    originalFileName: fileName,
    title: title,
  );

  test('a named book goes by its name', () {
    expect(
      document(title: 'Chopin Etudes', fileName: 'chopin-ed-pad.pdf')
          .displayName,
      'Chopin Etudes',
    );
  });

  test('an unnamed book goes by its file name, without the extension', () {
    // Spec 0053 had argued the opposite on purpose; that held only while the
    // file name was the one name the app knew (Spec 0054, G3 #2).
    expect(document(fileName: 'Chopin Etudes.pdf').displayName, 'Chopin Etudes');
  });

  test('only a real extension is dropped', () {
    expect(document(fileName: 'Vol. 2').displayName, 'Vol. 2');
    expect(document(fileName: '.scores').displayName, '.scores');
    expect(document(fileName: 'Book.vol.2.pdf').displayName, 'Book.vol.2');
  });

  test('a whitespace title is not a name', () {
    expect(
      document(title: '   ', fileName: 'Etudes.pdf').displayName,
      'Etudes',
    );
  });

  test('a book with nothing to call itself is not offered as a source', () {
    final nameless = document();
    expect(nameless.displayName, 'Untitled book');
    expect(nameless.hasOwnName, isFalse);
    expect(document(fileName: 'Etudes.pdf').hasOwnName, isTrue);
    // Renaming is enough on its own: a file imported without a name still ends
    // up recognisable.
    expect(document(title: 'Etudes').hasOwnName, isTrue);
  });

  test('copyWith carries the title through a page recount', () {
    final renamed = document(title: 'Etudes', fileName: 'e.pdf');
    // The trap this closes: replacePdf used to rebuild the object field by
    // field, so a rename vanished the moment the file was replaced.
    expect(renamed.copyWith(pageCount: 12).title, 'Etudes');
    expect(renamed.copyWith(clearPageCount: true).pageCount, isNull);
    expect(renamed.copyWith(clearPageCount: true).title, 'Etudes');
  });

  test('clearTitle goes back to the file name', () {
    final cleared = document(title: 'Etudes', fileName: 'Book.pdf').copyWith(
      clearTitle: true,
    );
    expect(cleared.title, isNull);
    expect(cleared.displayName, 'Book');
  });

  test('the title round-trips, and an older manifest reads as unnamed', () {
    final named = document(title: 'Etudes', fileName: 'Book.pdf');
    expect(PdfDocument.fromJson(named.toJson()).title, 'Etudes');

    final legacy = {
      'id': 'doc-1',
      'relativePath': 'scores/doc-1.pdf',
      'importedAt': DateTime.utc(2026, 7, 1).toIso8601String(),
      'pageCount': 4,
      'originalFileName': 'Book.pdf',
    };
    // No migration: the field is simply absent, which is what "never renamed"
    // looks like.
    expect(PdfDocument.fromJson(legacy).title, isNull);
    expect(PdfDocument.fromJson(legacy).displayName, 'Book');
  });
}
