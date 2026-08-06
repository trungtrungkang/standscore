import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/library/score.dart';
import 'package:stagescore/library/score_library.dart';
import 'package:stagescore/ui/library_screen.dart';
import 'package:stagescore/ui/pieces_screen.dart';

/// Root row + Pieces drill-in (Spec 0055).
void main() {
  late Directory temp;
  late ScoreLibrary library;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('library_book_');
    library = ScoreLibrary(root: temp, countPages: (path) async => 12);
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  Future<T> io<T>(WidgetTester tester, Future<T> Function() body) async {
    return (await tester.runAsync(body)) as T;
  }

  Future<Score> importPdf(String fileName) async {
    final source = File(p.join(temp.path, fileName));
    await source.writeAsString('%PDF-1.4');
    return library.importPdf(
      sourcePath: source.path,
      originalFileName: fileName,
    );
  }

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

  testWidgets('a split book is one root row, not every piece', (tester) async {
    await io(tester, () async {
      final book = await importPdf('Chopin Etudes.pdf');
      await library.splitScore(
        scoreId: book.id,
        marks: const [
          (startPage: 1, title: 'Op. 10 No. 1'),
          (startPage: 5, title: 'Op. 10 No. 2'),
          (startPage: 9, title: 'Op. 10 No. 3'),
        ],
      );
      await importPdf('Misty.pdf');
    });
    await pumpLibrary(tester);

    expect(find.widgetWithText(ListTile, 'Chopin Etudes'), findsOneWidget);
    expect(find.textContaining('3 pieces'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Op. 10 No. 1'), findsNothing);
    expect(find.widgetWithText(ListTile, 'Misty'), findsOneWidget);
  });

  testWidgets('tapping the root opens Pieces; Open full score is on the menu', (
    tester,
  ) async {
    await io(tester, () async {
      final book = await importPdf('Chopin Etudes.pdf');
      await library.splitScore(
        scoreId: book.id,
        marks: const [
          (startPage: 1, title: 'Op. 10 No. 1'),
          (startPage: 5, title: 'Op. 10 No. 2'),
        ],
      );
    });
    await pumpLibrary(tester);

    await tester.tap(find.widgetWithText(ListTile, 'Chopin Etudes'));
    await settle(tester);
    expect(find.byType(PiecesScreen), findsOneWidget);
    expect(find.text('Op. 10 No. 1'), findsOneWidget);
    expect(find.text('Open full score'), findsOneWidget);

    await tester.pageBack();
    await settle(tester);
    await openRowMenu(tester, 'Chopin Etudes');
    expect(find.text('Open full score'), findsOneWidget);
  });

  testWidgets('renaming the root renames the Library row', (tester) async {
    await io(tester, () async {
      final book = await importPdf('Chopin Etudes.pdf');
      await library.splitScore(
        scoreId: book.id,
        marks: const [
          (startPage: 1, title: 'Op. 10 No. 1'),
          (startPage: 5, title: 'Op. 10 No. 2'),
        ],
      );
    });
    await pumpLibrary(tester);

    await openRowMenu(tester, 'Chopin Etudes');
    await tester.tap(find.text('Rename…'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'Paderewski',
    );
    await tester.tap(find.text('Save'));
    await settle(tester);

    expect(find.widgetWithText(ListTile, 'Paderewski'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Chopin Etudes'), findsNothing);
  });

  testWidgets('a piece can be split again from the Pieces screen', (
    tester,
  ) async {
    await io(tester, () async {
      final book = await importPdf('Chopin Etudes.pdf');
      await library.splitScore(
        scoreId: book.id,
        marks: const [
          (startPage: 1, title: 'First half'),
          (startPage: 7, title: 'Second half'),
        ],
      );
    });
    await pumpLibrary(tester);

    await tester.tap(find.widgetWithText(ListTile, 'Chopin Etudes'));
    await settle(tester);
    await openRowMenu(tester, 'Second half');
    expect(find.text('Split into pieces…'), findsOneWidget);
  });

  testWidgets('deleting every child leaves the root row', (tester) async {
    late String rootId;
    late List<Score> children;
    await io(tester, () async {
      final book = await importPdf('Chopin Etudes.pdf');
      rootId = book.id;
      final after = await library.splitScore(
        scoreId: book.id,
        marks: const [
          (startPage: 1, title: 'One'),
          (startPage: 7, title: 'Two'),
        ],
      );
      children = after.where((s) => s.parentId == rootId).toList();
      for (final child in children) {
        await library.deleteScore(child.id);
      }
    });
    await pumpLibrary(tester);

    expect(find.widgetWithText(ListTile, 'Chopin Etudes'), findsOneWidget);
    expect(find.textContaining('pieces'), findsNothing);
  });
}
