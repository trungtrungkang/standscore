import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/layout/display_prefs.dart';
import 'package:stagescore/layout/page_scale.dart';
import 'package:stagescore/layout/pdf_layout_mode.dart';
import 'package:stagescore/layout/pdf_layout_prefs.dart';
import 'package:stagescore/metronome/metronome_engine.dart';
import 'package:stagescore/pageturn/page_turn_prefs.dart';
import 'package:stagescore/ui/display_sheet.dart';
import 'package:stagescore/ui/layout_settings_sheet.dart';
import 'package:stagescore/ui/metronome_sheet.dart';
import 'package:stagescore/ui/page_scale_sheet.dart';
import 'package:stagescore/ui/page_turn_settings_sheet.dart';

/// Settings sheets end where their content ends. Pinned to a fraction of the
/// screen they read as a pushed screen rather than a sheet (Spec 0035).
Future<double> _openAndMeasure(
  WidgetTester tester,
  Future<void> Function(BuildContext context) open,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => open(context),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  final height = tester.getSize(find.byType(BottomSheet)).height;
  // Leave the tree without a route open, so the next measurement starts clean.
  await tester.tap(find.text('Done'));
  await tester.pumpAndSettle();
  return height;
}

Future<double> _layoutSheetHeight(WidgetTester tester, PdfLayoutMode mode) {
  return _openAndMeasure(
    tester,
    (context) => showLayoutSettingsSheet(
      context: context,
      prefs: PdfLayoutPrefs(mode: mode),
      pageTurnPrefs: const PageTurnPrefs(),
      onChanged: (_) {},
    ),
  );
}

void main() {
  testWidgets('Layout sheet is sized by its rows, not by the screen', (
    tester,
  ) async {
    // The old sheet was a fixed 90% of the screen whatever it held, so the
    // test that catches a relapse is that a taller screen does not make a
    // taller sheet — not a magic fraction, which the 0041 rows outgrew while
    // staying content-sized.
    final onShort = await _layoutSheetHeight(tester, PdfLayoutMode.single);

    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final onTall = await _layoutSheetHeight(tester, PdfLayoutMode.single);

    expect(onTall, onShort);
    expect(onTall, lessThan(1600 * 0.9), reason: 'nowhere near the cap');
  });

  testWidgets('Page turn sheet stays within the screen', (tester) async {
    final height = await _openAndMeasure(
      tester,
      (context) => showPageTurnSettingsSheet(
        context: context,
        prefs: const PageTurnPrefs(),
        onChanged: (_) {},
      ),
    );
    final screen = tester.getSize(find.byType(MaterialApp)).height;
    expect(height, lessThanOrEqualTo(screen));
  });

  group('on a phone in landscape', () {
    // Reported from a device: the Metronome sheet overflowed by 144 pt in
    // landscape and its Start button could not be reached. A sheet that is
    // sized by its content has to *scroll* on a screen shorter than its
    // content, which is a different property from not being pinned to a
    // fraction of the screen — the tests above only checked the second one.
    Future<void> openSheet(
      WidgetTester tester,
      Future<void> Function(BuildContext context) open,
    ) async {
      tester.view.physicalSize = const Size(852, 393);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => open(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'a sheet taller than the screen must scroll, not overflow',
      );
      final sheet = tester.getSize(find.byType(BottomSheet));
      expect(sheet.height, lessThanOrEqualTo(393));
    }

    testWidgets('the Metronome sheet scrolls to its Start button', (
      tester,
    ) async {
      // Not disposed on purpose: MetronomeEngine.dispose releases a wakelock
      // through a platform channel that does not exist in a widget test, and
      // an engine that never started holds no timer to leak.
      final engine = MetronomeEngine();
      await openSheet(
        tester,
        (context) => showMetronomeSheet(
          context: context,
          engine: engine,
          onPrefsChanged: (_) {},
        ),
      );

      await tester.scrollUntilVisible(find.text('Start'), 60);
      expect(find.text('Start'), findsOneWidget);
    });

    // One sheet per test: a second sheet opened over the first sits on a
    // barrier that swallows the tap that would open it.
    testWidgets('the Layout sheet fits too', (tester) async {
      await openSheet(
        tester,
        (context) => showLayoutSettingsSheet(
          context: context,
          prefs: const PdfLayoutPrefs(),
          pageTurnPrefs: const PageTurnPrefs(),
          onChanged: (_) {},
        ),
      );
    });

    testWidgets('the Page turn sheet fits too', (tester) async {
      await openSheet(
        tester,
        (context) => showPageTurnSettingsSheet(
          context: context,
          prefs: const PageTurnPrefs(),
          onChanged: (_) {},
        ),
      );
    });

    testWidgets('the Display sheet fits too', (tester) async {
      await openSheet(
        tester,
        (context) => showDisplaySheet(
          context: context,
          prefs: const DisplayPrefs(),
          onChanged: (_) {},
          performanceModeHint: 'Swipe from the top edge',
        ),
      );
    });

    testWidgets('the Page scale sheet fits too', (tester) async {
      await openSheet(
        tester,
        (context) => showPageScaleSheet(
          context: context,
          prefs: const PageScalePrefs(),
          scoreId: 'score-1',
          sourcePage: 1,
          onChanged: (_) {},
        ),
      );
    });
  });
}
