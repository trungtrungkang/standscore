import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/layout/pdf_layout_mode.dart';
import 'package:stagescore/layout/pdf_layout_prefs.dart';
import 'package:stagescore/pageturn/page_turn_prefs.dart';
import 'package:stagescore/ui/layout_settings_sheet.dart';
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

  testWidgets('Layout sheet grows for the half-page slider', (tester) async {
    final compact = await _layoutSheetHeight(tester, PdfLayoutMode.single);
    final withSlider = await _layoutSheetHeight(
      tester,
      PdfLayoutMode.halfPageTopBottom,
    );
    expect(withSlider, greaterThan(compact));
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
}
