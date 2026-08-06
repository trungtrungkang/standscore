import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/layout/page_scale.dart';
import 'package:stagescore/layout/page_scale_prefs_store.dart';
import 'package:stagescore/library/outline_split.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/score.dart';
import 'package:stagescore/library/score_library.dart';
import 'package:stagescore/pageorder/page_order.dart';
import 'package:stagescore/pageorder/page_order_store.dart';
import 'package:stagescore/ui/library_screen.dart';

/// Splitting a book from the Library, and moving a piece's pages afterwards
/// (Spec 0052).
///
/// Driven through an injected [ScoreLibrary] and outline loader, so nothing here
/// needs a PDF engine. Thumbnails are left null: every page card falls back to
/// the PDF glyph, which is also what an unreadable file gets.
///
/// Every fixture goes through [WidgetTester.runAsync], because `dart:io` futures
/// do not complete inside a widget test's fake-async zone — awaiting one there
/// hangs the test instead of failing it.
///
/// The suggestion bar after an import is not here: reaching it means going
/// through the platform file picker. Its two halves are covered instead by
/// `looksLikeCollection` in `pdf_outline_split_test.dart` and by the G4 demo on
/// the Orchestrator's own library.
void main() {
  late Directory temp;
  late ScoreLibrary library;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('library_split_');
    library = ScoreLibrary(root: temp, countPages: (path) async => 6);
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  Future<T> io<T>(WidgetTester tester, Future<T> Function() body) async {
    return (await tester.runAsync(body)) as T;
  }

  Future<Score> importBook(String fileName) async {
    final source = File(p.join(temp.path, fileName));
    await source.writeAsString('%PDF-1.4');
    return library.importPdf(
      sourcePath: source.path,
      originalFileName: fileName,
    );
  }

  /// Settle frames *and* the screen's real disk work. One `runAsync` window lets
  /// pending `dart:io` complete and the following `pump` drains the
  /// continuation, so each round advances the screen by a single `await`.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 40; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 5)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Future<void> pumpLibrary(
    WidgetTester tester, {
    List<OutlineEntry>? outline,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LibraryScreen(
          library: library,
          loadOutline: outline == null ? null : (path) async => outline,
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> openRowMenu(WidgetTester tester, String rowTitle) async {
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(ListTile, rowTitle),
        matching: find.byIcon(Icons.more_vert),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder pageCard(int page) => find.byWidgetPredicate((widget) {
    if (widget is! Semantics) return false;
    final label = widget.properties.label;
    return label == 'Page $page' || (label?.startsWith('Page $page, ') ?? false);
  });

  /// Open the split screen from a book's row, apply the contents list if
  /// [useOutline], mark [pages], and save.
  Future<void> split(
    WidgetTester tester,
    String rowTitle, {
    List<int> pages = const [],
    bool useOutline = false,
  }) async {
    await openRowMenu(tester, rowTitle);
    await tester.tap(find.text('Split into pieces…'));
    await settle(tester);
    if (useOutline) {
      await tester.tap(find.textContaining('Use table of contents'));
      await tester.pumpAndSettle();
    }
    for (final page in pages) {
      await tester.tap(pageCard(page));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await settle(tester);
    // Splitting narrows the first piece's page order, and since 0054 the count
    // is said before it happens — the same rule the Pages screen follows. Only
    // a Score with slots to lose is asked.
    final confirm = find.widgetWithText(FilledButton, 'Split');
    if (confirm.evaluate().isNotEmpty) {
      await tester.tap(confirm);
      await settle(tester);
    }
  }

  group('the menu offers what applies to this Score', () {
    testWidgets('a whole book can be split', (tester) async {
      await io(tester, () => importBook('Chopin Etudes.pdf'));
      await pumpLibrary(tester);

      await openRowMenu(tester, 'Chopin Etudes');

      expect(find.text('Split into pieces…'), findsOneWidget);
      expect(find.text('Pages…'), findsNothing);
    });

    testWidgets('a piece can be split again, and moved', (tester) async {
      await io(tester, () async {
        final book = await importBook('Chopin Etudes.pdf');
        await library.splitScore(
          scoreId: book.id,
          marks: const [
            (startPage: 1, title: 'One'),
            (startPage: 4, title: 'Two'),
          ],
        );
      });
      await pumpLibrary(tester);

      await tester.tap(find.widgetWithText(ListTile, 'Chopin Etudes'));
      await settle(tester);
      await openRowMenu(tester, 'Two');

      expect(find.text('Pages…'), findsOneWidget);
      expect(find.text('Split into pieces…'), findsOneWidget);
    });

    testWidgets('a one-page piece cannot be split', (tester) async {
      await io(tester, () async {
        final book = await importBook('Chopin Etudes.pdf');
        await library.splitScore(
          scoreId: book.id,
          marks: const [
            (startPage: 1, title: 'One'),
            (startPage: 6, title: 'Last'),
          ],
        );
      });
      await pumpLibrary(tester);

      await tester.tap(find.widgetWithText(ListTile, 'Chopin Etudes'));
      await settle(tester);
      await openRowMenu(tester, 'Last');

      expect(find.text('Pages…'), findsOneWidget);
      expect(find.text('Split into pieces…'), findsNothing);
    });

    testWidgets('a root that already has children cannot be split again', (
      tester,
    ) async {
      await io(tester, () async {
        final book = await importBook('Chopin Etudes.pdf');
        await library.splitScore(
          scoreId: book.id,
          marks: const [
            (startPage: 1, title: 'One'),
            (startPage: 4, title: 'Two'),
          ],
        );
      });
      await pumpLibrary(tester);

      await openRowMenu(tester, 'Chopin Etudes');

      expect(
        find.text('Split into pieces…'),
        findsNothing,
        reason: 'further carving happens on children, not on the root again',
      );
      expect(find.text('Open full score'), findsOneWidget);
    });

    testWidgets('a single-page PDF offers neither', (tester) async {
      library = ScoreLibrary(root: temp, countPages: (path) async => 1);
      await io(tester, () => importBook('Solo.pdf'));
      await pumpLibrary(tester);

      await openRowMenu(tester, 'Solo');

      expect(find.text('Split into pieces…'), findsNothing);
      expect(find.text('Pages…'), findsNothing);
    });
  });

  testWidgets('the outline reaches the grid as an offer, not as marks', (
    tester,
  ) async {
    await io(tester, () => importBook('Chopin Etudes.pdf'));
    await pumpLibrary(
      tester,
      outline: const [
        OutlineEntry(title: 'Op. 10 No. 1', pageNumber: 1),
        OutlineEntry(title: 'Op. 10 No. 2', pageNumber: 3),
        OutlineEntry(title: 'Op. 10 No. 3', pageNumber: 5),
      ],
    );

    await openRowMenu(tester, 'Chopin Etudes');
    await tester.tap(find.text('Split into pieces…'));
    await settle(tester);

    expect(find.text('No pieces yet'), findsOneWidget);
    expect(find.text('Op. 10 No. 2'), findsNothing);

    await tester.tap(find.text('Use table of contents (3 entries)'));
    await tester.pumpAndSettle();

    expect(find.text('3 pieces'), findsOneWidget);
    expect(find.text('Op. 10 No. 2'), findsOneWidget);
  });

  testWidgets('splitting gives the Library one root row', (tester) async {
    await io(tester, () => importBook('Chopin Etudes.pdf'));
    await pumpLibrary(
      tester,
      outline: const [
        OutlineEntry(title: 'Op. 10 No. 1', pageNumber: 1),
        OutlineEntry(title: 'Op. 10 No. 2', pageNumber: 3),
        OutlineEntry(title: 'Op. 10 No. 3', pageNumber: 4),
      ],
    );

    await split(tester, 'Chopin Etudes', useOutline: true);

    expect(find.text('Split into 3 pieces'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Chopin Etudes'), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Chopin Etudes'),
        matching: find.textContaining('3 pieces'),
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(ListTile, 'Op. 10 No. 1'), findsNothing);

    final scores = await io(tester, library.listScores);
    expect(scores, hasLength(4), reason: 'root + three children');
    expect(
      scores.map((s) => s.pdfDocumentId).toSet(),
      hasLength(1),
      reason: 'four Scores, one file',
    );
  });

  testWidgets('the front matter of a book does not become a child', (
    tester,
  ) async {
    await io(tester, () => importBook('Chopin Etudes.pdf'));
    await pumpLibrary(tester);

    await split(tester, 'Chopin Etudes', pages: [3, 5]);

    final scores = await io(tester, library.listScores);
    final children = scores.where((s) => s.parentId != null).toList()
      ..sort((a, b) => a.firstAbsolutePage.compareTo(b.firstAbsolutePage));
    expect(scores.where((s) => s.parentId == null), hasLength(1));
    expect(children, hasLength(2));
    expect(
      children.map((s) => s.pageExtent).toList(),
      const [
        PageExtent(firstPage: 3, lastPage: 4),
        PageExtent(firstPage: 5, lastPage: 6),
      ],
      reason:
          'pages 1–2 stay in the PdfDocument; only the marked pieces are '
          'children',
    );
  });

  testWidgets('splitting a root leaves its whole-file page order alone', (
    tester,
  ) async {
    final book = await io(tester, () async {
      final book = await importBook('Chopin Etudes.pdf');
      // The book was played and reordered before anyone split it.
      await PageOrderStore(root: temp, scoreId: book.id).save(
        PageOrder.forExtent(firstPage: 1, pageCount: 6),
      );
      return book;
    });
    await pumpLibrary(tester);

    await split(tester, 'Chopin Etudes', pages: [1, 4]);

    final stored = await io(
      tester,
      PageOrderStore(root: temp, scoreId: book.id).loadStored,
    );
    expect(
      stored!.entries.map((e) => e.sourcePage),
      [1, 2, 3, 4, 5, 6],
      reason:
          'the root keeps the whole-file page order; children start without '
          'one (Spec 0055)',
    );
  });

  testWidgets('per-page scale follows the page into its new piece', (
    tester,
  ) async {
    final scaleStore = PageScalePrefsStore(root: temp);
    final book = await io(tester, () async {
      final book = await importBook('Chopin Etudes.pdf');
      await scaleStore.save(
        PageScalePrefs(pageScales: {PageScalePrefs.pageKey(book.id, 5): 1.3}),
      );
      return book;
    });
    await pumpLibrary(tester);

    await split(tester, 'Chopin Etudes', pages: [1, 4]);

    final scores = await io(tester, library.listScores);
    final second = scores.firstWhere(
      (s) => s.parentId == book.id && s.pageExtent?.contains(5) == true,
    );
    final prefs = await io(tester, scaleStore.load);

    expect(prefs.pageScales[PageScalePrefs.pageKey(second.id, 5)], 1.3);
    expect(
      prefs.pageScales.containsKey(PageScalePrefs.pageKey(book.id, 5)),
      isFalse,
      reason:
          'page 5 belongs to the second piece now, so the override would '
          'otherwise be orphaned the moment the split happened',
    );
  });

  group('moving a piece\'s pages', () {
    /// A book split in two, where the second piece has a page order of its own.
    Future<Score> secondPieceWithOrder(WidgetTester tester) async {
      return io(tester, () async {
        final book = await importBook('Chopin Etudes.pdf');
        final after = await library.splitScore(
          scoreId: book.id,
          marks: const [
            (startPage: 1, title: 'One'),
            (startPage: 4, title: 'Two'),
          ],
        );
        final second = after.firstWhere((s) => s.title == 'Two');
        await PageOrderStore(root: temp, scoreId: second.id).save(
          PageOrder.forExtent(firstPage: 4, pageCount: 3),
        );
        return second;
      });
    }

    Future<void> narrowLastPageTo(WidgetTester tester, int page) async {
      await tester.tap(find.widgetWithText(ListTile, 'Chopin Etudes'));
      await settle(tester);
      await openRowMenu(tester, 'Two');
      await tester.tap(find.text('Pages…'));
      await settle(tester);
      await tester.tap(find.text('Last page: 6'));
      await tester.pumpAndSettle();
      await tester.tap(pageCard(page));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await settle(tester);
    }

    testWidgets('says how many slots it will drop, and can be called off', (
      tester,
    ) async {
      final second = await secondPieceWithOrder(tester);
      await pumpLibrary(tester);

      await narrowLastPageTo(tester, 4);
      expect(
        find.textContaining('will drop 2 pages from its page order'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await settle(tester);

      final scores = await io(tester, library.listScores);
      expect(
        scores.firstWhere((s) => s.id == second.id).pageExtent,
        const PageExtent(firstPage: 4, lastPage: 6),
        reason: 'called off means nothing changed',
      );
    });

    testWidgets('confirming moves the pages and cuts the sequence down', (
      tester,
    ) async {
      final second = await secondPieceWithOrder(tester);
      await pumpLibrary(tester);

      await narrowLastPageTo(tester, 5);
      await tester.tap(find.widgetWithText(FilledButton, 'Change'));
      await settle(tester);

      final scores = await io(tester, library.listScores);
      expect(
        scores.firstWhere((s) => s.id == second.id).pageExtent,
        const PageExtent(firstPage: 4, lastPage: 5),
      );

      final stored = await io(
        tester,
        PageOrderStore(root: temp, scoreId: second.id).loadStored,
      );
      expect(stored!.entries.map((e) => e.sourcePage), [4, 5]);
    });
  });
}
