import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/ui/page_extent_screen.dart';

/// Moving a piece's pages after the split (Spec 0052, G3 #5).
///
/// Editing has to exist because a proposal read off a table of contents is
/// wrong in places, and without it the only repair would be delete-and-reimport
/// — which is exactly how the annotations get lost.
void main() {
  PageExtent? saved;

  Finder pageCard(int page) => find.byWidgetPredicate((widget) {
    if (widget is! Semantics) return false;
    return widget.properties.label == 'Page $page';
  });

  Future<void> pumpExtent(
    WidgetTester tester, {
    PageExtent initial = const PageExtent(firstPage: 3, lastPage: 5),
    int pageCount = 8,
  }) async {
    saved = null;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                saved = await Navigator.of(context).push<PageExtent>(
                  MaterialPageRoute(
                    builder: (_) => PageExtentScreen(
                      scoreTitle: 'Op. 10 No. 2',
                      pdf: File('/nowhere/book.pdf'),
                      documentId: 'doc-1',
                      pageCount: pageCount,
                      initial: initial,
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

  testWidgets('opens on the pages the piece already covers', (tester) async {
    await pumpExtent(tester);

    expect(find.text('First page: 3'), findsOneWidget);
    expect(find.text('Last page: 5'), findsOneWidget);
    expect(find.text('“Op. 10 No. 2” · 3 pages'), findsOneWidget);
  });

  testWidgets('nothing changed means nothing to save', (tester) async {
    await pumpExtent(tester);

    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Save'))
          .onPressed,
      isNull,
    );
  });

  testWidgets('a tap moves the highlighted end, and the chip moves on', (
    tester,
  ) async {
    await pumpExtent(tester);

    await tapPage(tester, 2);
    expect(find.text('First page: 2'), findsOneWidget);
    // Picking a start is usually followed by picking an end.
    await tapPage(tester, 7);
    expect(find.text('Last page: 7'), findsOneWidget);
    expect(find.text('“Op. 10 No. 2” · 6 pages'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    expect(saved, const PageExtent(firstPage: 2, lastPage: 7));
  });

  testWidgets('the ends cannot cross each other', (tester) async {
    await pumpExtent(tester);

    // Start after the end: the piece collapses onto the end instead of
    // inverting, which would be an extent describing nothing.
    await tapPage(tester, 8);
    expect(find.text('First page: 5'), findsOneWidget);
    expect(find.text('Last page: 5'), findsOneWidget);

    await tester.tap(find.text('First page: 5'));
    await tester.pumpAndSettle();
    await tapPage(tester, 1);
    expect(find.text('First page: 1'), findsOneWidget);
  });

  testWidgets('a one-page piece names its single page', (tester) async {
    await pumpExtent(
      tester,
      initial: const PageExtent(firstPage: 4, lastPage: 4),
    );

    expect(find.text('“Op. 10 No. 2” · 1 page'), findsOneWidget);
    expect(find.text('Only'), findsOneWidget);
  });
}
