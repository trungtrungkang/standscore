import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/label/label.dart';
import 'package:stagescore/library/library_sort.dart';
import 'package:stagescore/library/library_visibility.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/score.dart';

import 'support/test_l10n.dart';

/// Default list is roots; search/filter widen (Spec 0055).
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await testL10n();
  });

  final root = Score(
    id: 'root',
    title: 'Chopin Etudes',
    pdfDocumentId: 'doc',
    createdAt: DateTime.utc(2026, 1, 1),
  );
  final no1 = Score(
    id: 'c1',
    title: 'Op. 10 No. 1',
    pdfDocumentId: 'doc',
    parentId: 'root',
    pageExtent: const PageExtent(firstPage: 1, lastPage: 8),
    createdAt: DateTime.utc(2026, 1, 2),
    lastOpenedAt: DateTime.utc(2026, 8, 1),
  );
  final no3 = Score(
    id: 'c3',
    title: 'Op. 10 No. 3',
    pdfDocumentId: 'doc',
    parentId: 'root',
    pageExtent: const PageExtent(firstPage: 17, lastPage: 24),
    createdAt: DateTime.utc(2026, 1, 3),
  );
  final solo = Score(
    id: 'solo',
    title: 'Solo',
    pdfDocumentId: 'solo',
    createdAt: DateTime.utc(2026, 2, 1),
  );
  final all = [root, no1, no3, solo];

  test('default list is roots only', () {
    final visible = visibleLibraryScores(
      scores: all,
      query: '',
      bookmarkTitlesByScoreId: const {},
    );
    expect(visible.map((s) => s.id).toList(), ['root', 'solo']);
  });

  test('search for a piece title surfaces the child with in <root>', () {
    final visible = visibleLibraryScores(
      scores: all,
      query: 'No. 3',
      bookmarkTitlesByScoreId: const {},
    );
    expect(visible.map((s) => s.id).toList(), ['c3']);
    expect(childInRootSubtitle(l10n, no3, all), 'in Chopin Etudes');
  });

  test('search matching root and child shows both', () {
    final renamedRoot = root.copyWith(title: 'No. 3 Collection');
    final scores = [renamedRoot, no1, no3, solo];
    final visible = visibleLibraryScores(
      scores: scores,
      query: 'No. 3',
      bookmarkTitlesByScoreId: const {},
    );
    expect(visible.map((s) => s.id).toSet(), {'root', 'c3'});
  });

  test('label filter shows matching children without an empty root', () {
    final visible = visibleLibraryScores(
      scores: all,
      query: '',
      bookmarkTitlesByScoreId: const {},
      assignments: {
        'c3': {'gig'},
      },
      selectedLabelIds: {'gig'},
      mode: LabelFilterMode.any,
    );
    expect(visible.map((s) => s.id).toList(), ['c3']);
    expect(visible.any((s) => s.id == 'root'), isFalse);
  });

  test('Last viewed of a root is max(root, children)', () {
    final key = librarySortKeyOf(root, all);
    expect(key.opened, DateTime.utc(2026, 8, 1));
    final sorted = sortLibraryScores([root, solo], LibrarySortMode.lastViewed, all);
    expect(sorted.first.id, 'root');
  });
}
