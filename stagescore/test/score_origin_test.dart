import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/score_origin.dart';

/// The one line that says where a piece came from (Spec 0052).
void main() {
  test('a piece of a book names its pages and its file', () {
    expect(
      scoreOriginLine(
        extent: const PageExtent(firstPage: 12, lastPage: 19),
        documentName: 'Chopin Etudes.pdf',
        documentPageCount: 200,
      ),
      'Pages 12–19 of Chopin Etudes.pdf',
    );
  });

  test('a one-page piece is singular', () {
    expect(
      scoreOriginLine(
        extent: const PageExtent(firstPage: 7, lastPage: 7),
        documentName: 'Book.pdf',
        documentPageCount: 30,
      ),
      'Page 7 of Book.pdf',
    );
  });

  test('a Score that is a whole file says nothing at all', () {
    expect(
      scoreOriginLine(
        extent: null,
        documentName: 'Solo.pdf',
        documentPageCount: 4,
      ),
      isNull,
      reason: 'someone who never split anything must see no difference',
    );
    expect(
      scoreOriginLine(
        extent: const PageExtent(firstPage: 1, lastPage: 4),
        documentName: 'Solo.pdf',
        documentPageCount: 4,
      ),
      isNull,
      reason: 'an extent covering the file is not "a piece of" anything',
    );
  });

  test('an uncounted or unnamed document still reports the pages', () {
    expect(
      scoreOriginLine(
        extent: const PageExtent(firstPage: 12, lastPage: 19),
        documentName: null,
        documentPageCount: null,
      ),
      'Pages 12–19',
    );
    expect(
      scoreOriginLine(
        extent: const PageExtent(firstPage: 1, lastPage: 4),
        documentName: 'Book.pdf',
        documentPageCount: null,
      ),
      'Pages 1–4 of Book.pdf',
    );
  });
}
