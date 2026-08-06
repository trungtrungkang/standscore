import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/score_library.dart';
import 'package:stagescore/ui/split_score_screen.dart';

/// The split screen (Spec 0052).
///
/// Thumbnails are left null, which is the same path a file the renderer cannot
/// read takes: every card falls back to the PDF glyph, so nothing here needs a
/// PDF engine. What is under test is the marking, not the pictures.
void main() {
  List<SplitMark>? saved;

  /// The card for one page, matched on the Semantics label rather than the page
  /// number drawn on it: a piece badge is a bare number too, so `find.text('3')`
  /// would be ambiguous.
  Finder pageCard(int page) => find.byWidgetPredicate((widget) {
    if (widget is! Semantics) return false;
    final label = widget.properties.label;
    return label == 'Page $page' || (label?.startsWith('Page $page, ') ?? false);
  });

  Future<void> pumpSplit(
    WidgetTester tester, {
    List<({int startPage, String title})> proposals = const [],
    int pageCount = 6,
    PageExtent? pages,
    String? fixedFirstTitle,
    String bookTitle = 'Chopin Etudes',
  }) async {
    saved = null;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                saved = await Navigator.of(context).push<List<SplitMark>>(
                  MaterialPageRoute(
                    builder: (_) => SplitScoreScreen(
                      bookTitle: bookTitle,
                      pdf: File('/nowhere/book.pdf'),
                      documentId: 'doc-1',
                      pages:
                          pages ??
                          PageExtent(firstPage: 1, lastPage: pageCount),
                      fixedFirstTitle: fixedFirstTitle,
                      proposals: proposals,
                    ),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> tapPage(WidgetTester tester, int page) async {
    await tester.tap(pageCard(page));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();
  }

  Finder saveButton() => find.widgetWithText(TextButton, 'Save');

  testWidgets('an unmarked grid is no pieces at all, and cannot be saved', (
    tester,
  ) async {
    await pumpSplit(tester);

    expect(find.text('No pieces yet'), findsOneWidget);
    expect(
      tester.widget<TextButton>(saveButton()).onPressed,
      isNull,
      reason: 'one piece would be the book as it already is',
    );
  });

  testWidgets('the outline is offered with its count, and marks nothing until '
      'it is asked for', (tester) async {
    await pumpSplit(
      tester,
      proposals: const [
        (startPage: 1, title: 'Op. 10 No. 1'),
        (startPage: 3, title: 'Op. 10 No. 2'),
        (startPage: 5, title: 'Op. 10 No. 3'),
      ],
    );

    expect(find.text('No pieces yet'), findsOneWidget);
    expect(
      find.text('Op. 10 No. 2'),
      findsNothing,
      reason:
          'a two-entry outline on a long book looked exactly like a good one '
          'when the marks were seeded',
    );

    await tester.tap(find.text('Use table of contents (3 entries)'));
    await tester.pumpAndSettle();

    expect(find.text('3 pieces'), findsOneWidget);
    expect(find.text('Op. 10 No. 1'), findsOneWidget);
    expect(find.text('Op. 10 No. 3'), findsOneWidget);
  });

  testWidgets('a coarse outline names its own count before anything is marked', (
    tester,
  ) async {
    await pumpSplit(
      tester,
      pageCount: 148,
      proposals: const [
        (startPage: 1, title: 'Front matter'),
        (startPage: 4, title: 'Music'),
      ],
    );

    expect(
      find.text('Use table of contents (2 entries)'),
      findsOneWidget,
      reason: 'the count is the evidence: 2 on a 148-page book warns by itself',
    );
    expect(find.text('No pieces yet'), findsOneWidget);
  });

  testWidgets('a file with no contents list offers nothing to apply', (
    tester,
  ) async {
    await pumpSplit(tester);

    expect(find.textContaining('Use table of contents'), findsNothing);
  });

  testWidgets('tapping a page adds a piece, tapping it again takes it away', (
    tester,
  ) async {
    await pumpSplit(tester);

    await tapPage(tester, 1);
    await tapPage(tester, 4);
    expect(find.text('2 pieces'), findsOneWidget);

    await tapPage(tester, 4);
    expect(find.text('1 piece'), findsOneWidget);
  });

  group('the front matter of a book is not a piece', () {
    testWidgets('the pages before the first mark are named as belonging to '
        'nothing', (tester) async {
      await pumpSplit(tester);

      await tapPage(tester, 3);

      expect(
        find.text("Pages 1–2 are front matter and won't belong to any piece."),
        findsOneWidget,
      );
    });

    testWidgets('a single excluded page is said in the singular', (
      tester,
    ) async {
      await pumpSplit(tester);

      await tapPage(tester, 2);

      expect(
        find.text("Page 1 is front matter and won't belong to any piece."),
        findsOneWidget,
      );
    });

    testWidgets('marking page 1 means nothing is left out', (tester) async {
      await pumpSplit(tester);

      await tapPage(tester, 1);

      expect(
        find.textContaining("won't belong to any piece"),
        findsNothing,
      );
    });

    testWidgets('the first piece starts where the first mark is', (
      tester,
    ) async {
      await pumpSplit(tester);
      await tapPage(tester, 3);
      await tapPage(tester, 5);

      await save(tester);

      expect(
        saved!.map((m) => m.startPage),
        [3, 5],
        reason: 'a cover and a contents page are not a Score anyone wants',
      );
    });
  });

  testWidgets('the whole proposal goes away in one action, and can be asked '
      'for again', (tester) async {
    await pumpSplit(
      tester,
      proposals: const [
        (startPage: 1, title: 'One'),
        (startPage: 3, title: 'Two'),
        (startPage: 5, title: 'Three'),
      ],
    );
    await tester.tap(find.text('Use table of contents (3 entries)'));
    await tester.pumpAndSettle();
    expect(find.text('3 pieces'), findsOneWidget);

    await tester.tap(find.text('Clear marks'));
    await tester.pumpAndSettle();

    expect(find.text('No pieces yet'), findsOneWidget);
    expect(
      find.text('Two'),
      findsNothing,
      reason:
          'a screen that imposed the outline would be worse than one with no '
          'proposal at all',
    );
    expect(
      find.text('Use table of contents (3 entries)'),
      findsOneWidget,
      reason: 'clearing says the proposal was wrong, not that it is unwanted',
    );
  });

  testWidgets('unnamed pieces carry the name of the book they are in', (
    tester,
  ) async {
    await pumpSplit(tester);
    await tapPage(tester, 1);
    await tapPage(tester, 3);
    await tapPage(tester, 5);

    await save(tester);

    expect(saved, isNotNull);
    expect(saved!.map((m) => m.startPage), [1, 3, 5]);
    expect(
      saved!.map((m) => m.title),
      ['Chopin Etudes — 1', 'Chopin Etudes — 2', 'Chopin Etudes — 3'],
      reason:
          'twelve rows called Untitled is worse than twelve carrying the right '
          'prefix',
    );
  });

  testWidgets('inserting an earlier mark renumbers the default names', (
    tester,
  ) async {
    await pumpSplit(tester);
    await tapPage(tester, 1);
    await tapPage(tester, 5);
    await tapPage(tester, 3);

    await save(tester);

    expect(saved!.map((m) => m.startPage), [1, 3, 5]);
    expect(saved![2].title, 'Chopin Etudes — 3');
  });

  testWidgets('a marked page can be renamed before saving', (tester) async {
    await pumpSplit(tester);
    await tapPage(tester, 1);
    await tapPage(tester, 3);

    await tester.longPress(pageCard(3));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Nocturne');
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Save'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nocturne'), findsOneWidget);

    await save(tester);
    expect(saved![1].title, 'Nocturne');
  });

  testWidgets('a proposal pointing past the end of the file is ignored', (
    tester,
  ) async {
    await pumpSplit(
      tester,
      pageCount: 4,
      proposals: const [
        (startPage: 1, title: 'One'),
        (startPage: 9, title: 'Past the end'),
      ],
    );

    expect(
      find.text('Use table of contents (1 entry)'),
      findsOneWidget,
      reason: 'the offer counts what this file can hold, not what it was given',
    );

    await tester.tap(find.text('Use table of contents (1 entry)'));
    await tester.pumpAndSettle();

    expect(find.text('1 piece'), findsOneWidget);
    expect(find.text('Past the end'), findsNothing);
  });
}
