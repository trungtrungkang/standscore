import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/label/label_store.dart';
import 'package:stagescore/library/score.dart';
import 'package:stagescore/library/score_library.dart';
import 'package:stagescore/library/score_thumbnails.dart';
import 'package:stagescore/ui/about_sheet.dart';
import 'package:stagescore/ui/library_screen.dart';
import 'package:stagescore/ui/score_thumbnail_tile.dart';

/// Library rows, rename and filter state (Spec 0040).
///
/// The screen is driven through an injected [ScoreLibrary] and
/// [ScoreThumbnails], so nothing here needs path_provider or a PDF engine.
///
/// Everything that touches the disk — the fixtures below and the screen's own
/// manifest reads — goes through [WidgetTester.runAsync]: `dart:io` futures do
/// not complete inside a widget test's fake-async zone, and awaiting one there
/// hangs the test rather than failing it.
void main() {
  late Directory temp;
  late ScoreLibrary library;
  late int renders;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('standscore_screen_');
    library = ScoreLibrary(root: temp, countPages: (path) async => 4);
    renders = 0;
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  Future<T> io<T>(WidgetTester tester, Future<T> Function() body) async {
    return (await tester.runAsync(body)) as T;
  }

  Future<Score> importScore(String fileName) async {
    final source = File(p.join(temp.path, fileName));
    await source.writeAsString('%PDF-1.4');
    return library.importPdf(
      sourcePath: source.path,
      originalFileName: fileName,
    );
  }

  Future<List<String>> addLabels(String scoreId, List<String> names) async {
    final labels = LabelStore(root: temp);
    await labels.load();
    final ids = <String>[];
    for (final name in names) {
      ids.add((await labels.create(name)).id);
    }
    await labels.setScoreLabels(scoreId, ids.toSet());
    return ids;
  }

  ScoreThumbnails fakeThumbnails() {
    return ScoreThumbnails(
      cacheDir: Directory(p.join(temp.path, 'cache')),
      render: (path, {int width = 240, int pageNumber = 1}) async {
        renders++;
        return _onePixelPng;
      },
    );
  }

  /// Settle frames *and* the screen's real disk work.
  ///
  /// One `runAsync` window lets pending `dart:io` complete and the following
  /// `pump` drains the continuation, so each round advances the screen's load
  /// by a single `await` — hence the loop rather than one long wait.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 40; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 5)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Future<void> pumpLibrary(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LibraryScreen(library: library, thumbnails: fakeThumbnails()),
      ),
    );
    await settle(tester);
  }

  /// The row's own ⋯, not the AppBar's — the Scaffold body comes first in the
  /// tree, so index-based finders pick the wrong one.
  Future<void> openRowMenu(WidgetTester tester, String rowTitle) async {
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(ListTile, rowTitle),
        matching: find.byIcon(Icons.more_vert),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> rename(
    WidgetTester tester,
    String rowTitle,
    String title,
  ) async {
    await openRowMenu(tester, rowTitle);
    await tester.tap(find.text('Rename…'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, title);
    await tester.tap(find.text('Save'));
    await settle(tester);
  }

  testWidgets('a Score can be renamed from its row', (tester) async {
    await io(tester, () => importScore('doc_2024-11-03_18-22.pdf'));
    await pumpLibrary(tester);
    expect(find.text('doc_2024-11-03_18-22'), findsOneWidget);

    await rename(tester, 'doc_2024-11-03_18-22', 'Autumn Leaves');

    expect(find.text('Autumn Leaves'), findsOneWidget);
    expect(find.text('doc_2024-11-03_18-22'), findsNothing);
    final saved = await io(tester, library.listScores);
    expect(saved.single.title, 'Autumn Leaves');
  });

  testWidgets('a rename left blank keeps the old title', (tester) async {
    await io(tester, () => importScore('Chart.pdf'));
    await pumpLibrary(tester);

    await rename(tester, 'Chart', '   ');

    expect(find.text('Chart'), findsOneWidget);
    final saved = await io(tester, library.listScores);
    expect(saved.single.title, 'Chart');
  });

  testWidgets('a row shows recency and page count, not an ISO date', (
    tester,
  ) async {
    await io(tester, () => importScore('Chart.pdf'));
    await pumpLibrary(tester);

    expect(find.text('Added today · 4 pages'), findsOneWidget);
  });

  testWidgets('each row renders its own thumbnail once', (tester) async {
    await io(tester, () => importScore('One.pdf'));
    await io(tester, () => importScore('Two.pdf'));
    await pumpLibrary(tester);
    await settle(tester);

    // Not find.byType(Image): the AppBar logo is one too.
    expect(find.byType(ScoreThumbnailTile), findsNWidgets(2));
    expect(
      find.descendant(
        of: find.byType(ScoreThumbnailTile),
        matching: find.byType(Image),
      ),
      findsNWidgets(2),
    );
    expect(renders, 2);
  });

  testWidgets('labels appear as chips, capped with +N', (tester) async {
    final score = await io(tester, () => importScore('Chart.pdf'));
    await io(tester, () => addLabels(score.id, ['Jazz', 'Gig', 'Wedding']));

    await pumpLibrary(tester);

    expect(find.text('Jazz'), findsOneWidget);
    expect(find.text('Gig'), findsOneWidget);
    expect(find.text('Wedding'), findsNothing);
    expect(find.text('+1'), findsOneWidget);
  });

  testWidgets('an active filter is named on screen and removable', (
    tester,
  ) async {
    final jazz = await io(tester, () => importScore('Jazz tune.pdf'));
    await io(tester, () => importScore('Other.pdf'));
    await io(tester, () => addLabels(jazz.id, ['Jazz']));

    await pumpLibrary(tester);
    await tester.tap(find.byTooltip('Filter by Label'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jazz').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await settle(tester);

    // Named above the list, not just a filled funnel icon.
    expect(find.byType(InputChip), findsOneWidget);
    expect(find.text('Other'), findsNothing);

    await tester.tap(
      find.descendant(
        of: find.byType(InputChip),
        matching: find.byIcon(Icons.close),
      ),
    );
    await settle(tester);

    expect(find.byType(InputChip), findsNothing);
    expect(find.text('Other'), findsOneWidget);
  });

  testWidgets('the empty Library says who makes the app', (tester) async {
    await pumpLibrary(tester);

    // The first screen of a fresh install, and the only moment this line has
    // to land — nobody opens ⋯ → About on day one (Spec 0042).
    expect(find.text('No scores yet'), findsOneWidget);
    expect(find.text('A Backing & Score app'), findsOneWidget);
  });

  testWidgets('the Setlists empty state does not repeat the publisher', (
    tester,
  ) async {
    await pumpLibrary(tester);
    await tester.tap(find.text('Setlists'));
    await tester.pumpAndSettle();

    expect(find.text('No setlists yet'), findsOneWidget);
    expect(find.text('A Backing & Score app'), findsNothing);
  });

  testWidgets('⋯ opens About with the build the bundle reports', (
    tester,
  ) async {
    final opened = <Uri>[];
    await tester.pumpWidget(
      MaterialApp(
        home: LibraryScreen(
          library: library,
          thumbnails: fakeThumbnails(),
          readBuild: () async =>
              const AppBuild(version: '9.9.9', buildNumber: '42'),
          launchUrl: (url) async {
            opened.add(url);
            return true;
          },
        ),
      ),
    );
    await settle(tester);

    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('About StageScore…'));
    await tester.pumpAndSettle();

    expect(find.text('Part of Backing & Score'), findsOneWidget);
    expect(find.text('Version 9.9.9 (42)'), findsOneWidget);

    await tester.tap(find.text('backingscore.com'));
    await tester.pumpAndSettle();
    expect(opened.single.toString(), 'https://backingscore.com');
  });

  testWidgets('the Setlists tab has one way to make a setlist', (tester) async {
    await pumpLibrary(tester);
    await tester.tap(find.text('Setlists'));
    await tester.pumpAndSettle();

    // The FAB is the one way in; the AppBar no longer duplicates it.
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.playlist_add),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(FloatingActionButton),
        matching: find.byIcon(Icons.playlist_add),
      ),
      findsOneWidget,
    );
  });
}

/// Smallest PNG that decodes, so rows can show a real [Image].
final _onePixelPng = Uint8List.fromList([
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, //
  0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4,
  0x89, 0x00, 0x00, 0x00, 0x0a, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9c, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0d, 0x0a, 0x2d, 0xb4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4e, 0x44, 0xae,
  0x42, 0x60, 0x82,
]);
