import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/layout/page_scale.dart';
import 'package:stagescore/library/page_extent.dart';

/// Per-page scale is the one page-anchored store that lives in a shared,
/// app-level file keyed by `"$scoreId:$sourcePage"` — so splitting a book
/// orphans every override past the first piece unless they are handed over
/// (Spec 0052).
void main() {
  /// Who owns [page] once the book has been split into [pieces].
  String? Function(int) ownerFrom(List<(String, PageExtent)> pieces) {
    return (page) {
      for (final piece in pieces) {
        if (piece.$2.contains(page)) return piece.$1;
      }
      return null;
    };
  }

  test('overrides follow the piece that now owns the page', () {
    const prefs = PageScalePrefs(
      pageScales: {'book:1': 1.1, 'book:10': 1.2, 'book:20': 1.3},
    );

    final reassigned = prefs.reassignPageScales(
      scoreId: 'book',
      ownerOf: ownerFrom([
        ('book', const PageExtent(firstPage: 1, lastPage: 9)),
        ('piece-2', const PageExtent(firstPage: 10, lastPage: 19)),
        ('piece-3', const PageExtent(firstPage: 20, lastPage: 30)),
      ]),
    );

    expect(reassigned.pageScales, {
      'book:1': 1.1,
      'piece-2:10': 1.2,
      'piece-3:20': 1.3,
    });
  });

  test('the page number stays absolute, it is not rebased on the extent', () {
    const prefs = PageScalePrefs(pageScales: {'book:20': 1.3});

    final reassigned = prefs.reassignPageScales(
      scoreId: 'book',
      ownerOf: ownerFrom([
        ('piece-3', const PageExtent(firstPage: 20, lastPage: 30)),
      ]),
    );

    // Rebasing to "page 1 of the piece" would be the forbidden third page
    // numbering space, and would silently shift on the next extent edit.
    expect(reassigned.pageScales.keys, ['piece-3:20']);
  });

  test('overrides for other Scores are untouched', () {
    const prefs = PageScalePrefs(
      pageScales: {'book:10': 1.2, 'other:10': 0.8},
    );

    final reassigned = prefs.reassignPageScales(
      scoreId: 'book',
      ownerOf: ownerFrom([
        ('piece-2', const PageExtent(firstPage: 10, lastPage: 19)),
      ]),
    );

    expect(reassigned.pageScales['other:10'], 0.8);
  });

  test('an override on a page no piece covers is dropped', () {
    const prefs = PageScalePrefs(pageScales: {'book:5': 1.4, 'book:12': 1.2});

    final reassigned = prefs.reassignPageScales(
      scoreId: 'book',
      ownerOf: ownerFrom([
        ('piece-2', const PageExtent(firstPage: 10, lastPage: 19)),
      ]),
    );

    expect(reassigned.pageScales, {'piece-2:12': 1.2});
  });

  test('per-Score and fixed scales are left alone', () {
    const prefs = PageScalePrefs(
      fixedScale: 1.25,
      scoreScales: {'book': 0.9},
      pageScales: {'book:10': 1.2},
    );

    final reassigned = prefs.reassignPageScales(
      scoreId: 'book',
      ownerOf: ownerFrom([
        ('piece-2', const PageExtent(firstPage: 10, lastPage: 19)),
      ]),
    );

    expect(reassigned.fixedScale, 1.25);
    expect(reassigned.scoreScales, {'book': 0.9});
  });

  test('resolve finds the override after the handover', () {
    const prefs = PageScalePrefs(pageScales: {'book:12': 1.2});

    final reassigned = prefs.reassignPageScales(
      scoreId: 'book',
      ownerOf: ownerFrom([
        ('piece-2', const PageExtent(firstPage: 10, lastPage: 19)),
      ]),
    );

    expect(reassigned.resolve(scoreId: 'piece-2', sourcePage: 12), 1.2);
    expect(
      reassigned.resolve(scoreId: 'book', sourcePage: 12),
      PageScalePrefs.defaultScale,
    );
  });
}
