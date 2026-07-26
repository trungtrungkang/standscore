import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/layout/pdf_layout_mode.dart';
import 'package:standscore/layout/pdf_layout_prefs.dart';
import 'package:standscore/pageturn/page_turn_prefs.dart';
import 'package:standscore/ui/layout_settings_sheet.dart';
import 'package:standscore/ui/page_turn_settings_sheet.dart';

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
      onChanged: (_) {},
    ),
  );
}

void main() {
  testWidgets('Layout sheet is sized by its chips, not by the screen', (
    tester,
  ) async {
    final height = await _layoutSheetHeight(tester, PdfLayoutMode.single);
    final screen = tester.getSize(find.byType(MaterialApp)).height;
    // The old sheet was a fixed 90% of the screen whatever it held.
    expect(height, lessThan(screen * 0.75));
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
