import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/layout/pdf_layout_mode.dart';
import 'package:stagescore/layout/pdf_layout_prefs.dart';
import 'package:stagescore/pageturn/page_turn_prefs.dart';
import 'package:stagescore/ui/layout_settings_sheet.dart';

Future<PdfLayoutPrefs?> _openSheet(
  WidgetTester tester, {
  required Size screen,
  PdfLayoutPrefs prefs = const PdfLayoutPrefs(),
  VoidCallback? onOpenPageTurnSettings,
}) async {
  tester.view.physicalSize = screen;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  PdfLayoutPrefs? changed;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showLayoutSettingsSheet(
              context: context,
              prefs: prefs,
              pageTurnPrefs: const PageTurnPrefs(),
              onChanged: (next) => changed = next,
              onOpenPageTurnSettings: onOpenPageTurnSettings,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return changed;
}

/// The subtitle under a row, which is where 0041 puts the answer to "how do I
/// turn a page in this one".
String _subtitleOf(WidgetTester tester, String label) {
  final tile = find.ancestor(
    of: find.text(label),
    matching: find.byType(ListTile),
  );
  final subtitle = find.descendant(of: tile, matching: find.byType(Text));
  return tester.widgetList<Text>(subtitle).last.data!;
}

void main() {
  testWidgets('every row says how it turns a page', (tester) async {
    await _openSheet(tester, screen: const Size(393, 852));

    expect(
      _subtitleOf(tester, 'One page'),
      'tap left / right · swipe sideways',
    );
    expect(
      _subtitleOf(tester, 'Scroll'),
      'tap top / bottom · swipe up / down',
      reason: 'Scroll runs down the screen, so it is turned down the screen',
    );
  });

  testWidgets('Auto admits what it picked, and is marked as fitting', (
    tester,
  ) async {
    await _openSheet(tester, screen: const Size(393, 852));

    expect(
      _subtitleOf(tester, 'Auto').startsWith('Now: One page + peek'),
      isTrue,
    );
    expect(find.text('fits this screen'), findsOneWidget);
  });

  testWidgets('a spread that cannot fit says so on its own row', (
    tester,
  ) async {
    await _openSheet(tester, screen: const Size(393, 852));
    expect(
      _subtitleOf(tester, 'Two pages'),
      'One page on this screen — rotate for a spread',
    );
  });

  testWidgets('a screen that can show a spread just describes it', (
    tester,
  ) async {
    await _openSheet(tester, screen: const Size(1194, 834));
    expect(
      _subtitleOf(tester, 'Two pages'),
      'tap left / right · swipe sideways',
    );
  });

  testWidgets('the peek slider says where the peek stops being free', (
    tester,
  ) async {
    await _openSheet(
      tester,
      screen: const Size(393, 852),
      prefs: const PdfLayoutPrefs(mode: PdfLayoutMode.halfPageTopBottom),
    );

    expect(find.textContaining('Free up to 35%'), findsOneWidget);
    expect(find.textContaining('the music is full size'), findsOneWidget);
  });

  testWidgets('choosing a row reports it without closing the sheet', (
    tester,
  ) async {
    await _openSheet(tester, screen: const Size(393, 852));
    await tester.tap(find.text('Two pages'));
    await tester.pumpAndSettle();
    expect(find.text('Layout'), findsOneWidget);
  });

  testWidgets('Page turn settings are one tap from the layout that uses them', (
    tester,
  ) async {
    var opened = false;
    await _openSheet(
      tester,
      screen: const Size(393, 852),
      onOpenPageTurnSettings: () => opened = true,
    );

    await tester.tap(find.text('Page turn settings'));
    await tester.pumpAndSettle();
    expect(opened, isTrue);
    expect(find.text('Layout'), findsNothing, reason: 'the sheet handed over');
  });
}
