import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/library/score.dart';
import 'package:stagescore/library/score_library.dart';
import 'package:stagescore/ui/library_screen.dart';
import 'package:stagescore/ui/pieces_screen.dart';

/// "Edit pieces": redefining an already-split root's boundaries in place,
/// keeping a piece's id (and its annotations/bookmarks/jump links/Labels/
/// Setlist membership) wherever its exact page range survives (Spec 0055
/// follow-up).
void main() {
  late Directory temp;
  late ScoreLibrary library;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('library_edit_pieces_');
    library = ScoreLibrary(root: temp, countPages: (path) async => 12);
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

  // 80 rather than the usual 40: this screen's save path chases more
  // sequential dart:io calls than a plain split (a data-loss check per
  // removed piece, then a page-scale handover per removed piece), and each
  // needs its own real-event-loop hop to resolve inside a fake-async test.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 80; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 5)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Future<void> pumpLibrary(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LibraryScreen(library: library)));
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

  Future<void> openEditPieces(WidgetTester tester, String rowTitle) async {
    await openRowMenu(tester, rowTitle);
    await tester.tap(find.text('Edit pieces…'));
    await settle(tester);
  }

  Future<void> writeAnnotation(String scoreId) async {
    final file = File(p.join(temp.path, 'annotations', '$scoreId.json'));
    await file.parent.create(recursive: true);
    await file.writeAsString(
      jsonEncode({
        'scoreId': scoreId,
        'strokes': [
          {
            'id': 's1',
            'pageNumber': 5,
            'tool': 'pen',
            'color': 0xFF000000,
            'width': 0.01,
            'points': [
              {'x': 0.1, 'y': 0.1},
            ],
          },
        ],
        'stamps': [],
      }),
    );
  }

  testWidgets('Edit pieces only appears once a root has children', (
    tester,
  ) async {
    await io(tester, () => importBook('Solo.pdf'));
    await pumpLibrary(tester);

    await openRowMenu(tester, 'Solo');
    expect(find.text('Edit pieces…'), findsNothing);
  });

  testWidgets("Edit pieces opens with today's boundaries already checked", (
    tester,
  ) async {
    await io(tester, () async {
      final book = await importBook('Chopin Etudes.pdf');
      await library.splitScore(
        scoreId: book.id,
        marks: const [
          (startPage: 1, title: 'One'),
          (startPage: 5, title: 'Two'),
        ],
      );
    });
    await pumpLibrary(tester);

    await openEditPieces(tester, 'Chopin Etudes');

    expect(find.text('Edit pieces'), findsOneWidget);
    expect(find.text('2 pieces'), findsOneWidget);
    expect(find.text('One'), findsWidgets);
    expect(find.text('Two'), findsWidgets);

    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await settle(tester);

    expect(find.text('Updated 2 pieces'), findsOneWidget);
  });

  testWidgets('Edit pieces is also reachable from the Pieces screen app bar', (
    tester,
  ) async {
    await io(tester, () async {
      final book = await importBook('Chopin Etudes.pdf');
      await library.splitScore(
        scoreId: book.id,
        marks: const [
          (startPage: 1, title: 'One'),
          (startPage: 5, title: 'Two'),
        ],
      );
    });
    await pumpLibrary(tester);

    await tester.tap(find.widgetWithText(ListTile, 'Chopin Etudes'));
    await settle(tester);
    expect(find.byType(PiecesScreen), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.more_vert),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Edit pieces…'), findsOneWidget);
    await tester.tap(find.text('Edit pieces…'));
    await settle(tester);

    // Backs out of Pieces first, same as every other row-level action there.
    expect(find.byType(PiecesScreen), findsNothing);
    expect(find.text('Edit pieces'), findsOneWidget);
    expect(find.text('2 pieces'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await settle(tester);
    expect(find.text('Updated 2 pieces'), findsOneWidget);
  });

  testWidgets("a piece whose page range doesn't change keeps its id", (
    tester,
  ) async {
    late String keptId;
    await io(tester, () async {
      final book = await importBook('Chopin Etudes.pdf');
      final scores = await library.splitScore(
        scoreId: book.id,
        marks: const [
          (startPage: 1, title: 'One'),
          (startPage: 5, title: 'Two'),
        ],
      );
      keptId = scores.firstWhere((s) => s.title == 'Two').id;
    });
    await pumpLibrary(tester);

    await openEditPieces(tester, 'Chopin Etudes');
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await settle(tester);

    final scores = await io(tester, library.listScores);
    expect(scores.firstWhere((s) => s.title == 'Two').id, keptId);
  });

  // Removing the *middle* mark of three keeps the Save button enabled (two
  // marks still remain) while merging the first two pieces into one — the
  // last piece's range is untouched and keeps its id either way.
  Future<Score> importSplitInThree(WidgetTester tester) async {
    return io(tester, () async {
      final book = await importBook('Chopin Etudes.pdf');
      await library.splitScore(
        scoreId: book.id,
        marks: const [
          (startPage: 1, title: 'One'),
          (startPage: 5, title: 'Two'),
          (startPage: 9, title: 'Three'),
        ],
      );
      return book;
    });
  }

  testWidgets('merging pieces with no data away needs no confirmation', (
    tester,
  ) async {
    await importSplitInThree(tester);
    await pumpLibrary(tester);

    await openEditPieces(tester, 'Chopin Etudes');
    expect(find.text('3 pieces'), findsOneWidget);
    // Un-check the mark at page 5: 'One' and 'Two' merge into one piece
    // covering pages 1–8; 'Three' (9–12) is untouched.
    await tester.tap(pageCard(5));
    await tester.pumpAndSettle();
    expect(find.text('2 pieces'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await settle(tester);

    expect(find.text('Edit pieces?'), findsNothing);
    expect(find.text('Updated 2 pieces'), findsOneWidget);

    final scores = await io(tester, library.listScores);
    final pieces = scores.where((s) => s.parentId != null).toList();
    expect(pieces, hasLength(2));
    expect(pieces.map((s) => s.title), contains('Three'));
  });

  testWidgets('merging a piece that holds annotations warns before deleting it', (
    tester,
  ) async {
    late String removedId;
    late String survivingId;
    await io(tester, () async {
      final book = await importBook('Chopin Etudes.pdf');
      final scores = await library.splitScore(
        scoreId: book.id,
        marks: const [
          (startPage: 1, title: 'One'),
          (startPage: 5, title: 'Two'),
          (startPage: 9, title: 'Three'),
        ],
      );
      removedId = scores.firstWhere((s) => s.title == 'Two').id;
      survivingId = scores.firstWhere((s) => s.title == 'Three').id;
      await writeAnnotation(removedId);
    });
    await pumpLibrary(tester);

    await openEditPieces(tester, 'Chopin Etudes');
    await tester.tap(pageCard(5));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await settle(tester);

    expect(find.text('Edit pieces?'), findsOneWidget);
    expect(find.textContaining('Two'), findsWidgets);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await settle(tester);
    var scores = await io(tester, library.listScores);
    expect(scores.any((s) => s.id == removedId), isTrue);

    await openEditPieces(tester, 'Chopin Etudes');
    await tester.tap(pageCard(5));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await settle(tester);

    scores = await io(tester, library.listScores);
    expect(scores.any((s) => s.id == removedId), isFalse);
    expect(
      scores.any((s) => s.id == survivingId),
      isTrue,
      reason: "the untouched last piece keeps its id regardless",
    );
    final annotationFile = File(
      p.join(temp.path, 'annotations', '$removedId.json'),
    );
    expect(await io(tester, annotationFile.exists), isFalse);
  });
}
