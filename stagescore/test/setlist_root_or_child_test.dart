import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/score.dart';
import 'package:stagescore/setlist/setlist.dart';
import 'package:stagescore/ui/setlist_editor_screen.dart';

/// Setlist picker can add a root or drill into a child (Spec 0055).
void main() {
  final root = Score(
    id: 'root',
    title: 'Chopin Etudes',
    pdfDocumentId: 'doc',
    createdAt: DateTime.utc(2026, 1, 1),
  );
  final child = Score(
    id: 'c1',
    title: 'Op. 10 No. 1',
    pdfDocumentId: 'doc',
    parentId: 'root',
    pageExtent: const PageExtent(firstPage: 1, lastPage: 8),
    createdAt: DateTime.utc(2026, 1, 2),
  );
  final solo = Score(
    id: 'solo',
    title: 'Solo',
    pdfDocumentId: 'solo',
    createdAt: DateTime.utc(2026, 2, 1),
  );

  testWidgets('picker lists roots and can drill into pieces', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SetlistEditorScreen(
          initial: Setlist(
            id: 's',
            title: 'Gig',
            scoreIds: const [],
            createdAt: DateTime.utc(2026, 1, 1),
          ),
          libraryScores: [root, child, solo],
        ),
      ),
    );

    await tester.tap(find.text('Add scores'));
    await tester.pumpAndSettle();

    expect(find.text('Chopin Etudes'), findsOneWidget);
    expect(find.text('Solo'), findsOneWidget);
    expect(find.text('Op. 10 No. 1'), findsNothing);

    await tester.tap(find.text('Chopin Etudes'));
    await tester.pumpAndSettle();
    expect(find.text('Op. 10 No. 1'), findsOneWidget);

    await tester.tap(find.widgetWithText(CheckboxListTile, 'Op. 10 No. 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Op. 10 No. 1'), findsOneWidget);
  });
}
