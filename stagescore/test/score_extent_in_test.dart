import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/score.dart';

/// Which pages a Score covers in the file that was actually opened (Spec 0052).
///
/// This is what PdfMode and boundary PageTurn both ask, and neither can be
/// pumped in a widget test — `PdfModeScreen` needs a native viewer — so the
/// answer lives here rather than inline at two call sites.
void main() {
  Score score({PageExtent? extent}) => Score(
    id: 's1',
    title: 'Piece',
    pdfDocumentId: 'doc',
    pageExtent: extent,
    createdAt: DateTime.utc(2026),
  );

  test('a Score with no extent covers the whole file', () {
    expect(score().extentIn(6), const PageExtent(firstPage: 1, lastPage: 6));
  });

  test('a piece covers its own pages', () {
    final extent = const PageExtent(firstPage: 12, lastPage: 19);

    expect(score(extent: extent).extentIn(200), extent);
  });

  test('an extent that outlived a shorter file is clamped, not honoured', () {
    // Replace PDF can hand a Score a file shorter than the piece it described.
    expect(
      score(extent: const PageExtent(firstPage: 3, lastPage: 90)).extentIn(5),
      const PageExtent(firstPage: 3, lastPage: 5),
    );
  });

  test('an extent starting past the end of the file resolves to nothing', () {
    expect(
      score(extent: const PageExtent(firstPage: 90, lastPage: 99)).extentIn(5),
      isNull,
    );
  });

  test('a file that would not open answers null, not an empty piece', () {
    expect(
      score().extentIn(0),
      isNull,
      reason: 'a failed open is a reason to show nothing, never a reason to '
          'conclude the piece has no pages',
    );
    expect(score(extent: const PageExtent(firstPage: 1, lastPage: 2)).extentIn(0), isNull);
  });
}
