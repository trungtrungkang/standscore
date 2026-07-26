import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/layout/pdf_layout_mode.dart';
import 'package:standscore/pageturn/page_turn_amount.dart';
import 'package:standscore/pageturn/page_turn_prefs.dart';
import 'package:standscore/pageturn/page_turn_prefs_store.dart';

void main() {
  group('resolvePageTurnStep', () {
    test('single and half-page layout always one page', () {
      for (final mode in [
        PdfLayoutMode.single,
        PdfLayoutMode.halfPageTopBottom,
        PdfLayoutMode.halfPageLeftRight,
      ]) {
        for (final amount in TurnAmount.values) {
          final step = resolvePageTurnStep(mode: mode, amount: amount);
          expect(step.kind, PageTurnStepKind.performancePages);
          expect(step.pageDelta, 1);
        }
      }
    });

    test('twoPage full=2 half=1', () {
      expect(
        resolvePageTurnStep(
          mode: PdfLayoutMode.twoPage,
          amount: TurnAmount.full,
        ).pageDelta,
        2,
      );
      expect(
        resolvePageTurnStep(
          mode: PdfLayoutMode.twoPage,
          amount: TurnAmount.half,
        ).pageDelta,
        1,
      );
    });

    test('fitWidth/fitHeight half uses viewport fraction', () {
      for (final mode in [PdfLayoutMode.fitWidth, PdfLayoutMode.fitHeight]) {
        final half = resolvePageTurnStep(mode: mode, amount: TurnAmount.half);
        expect(half.kind, PageTurnStepKind.viewportFraction);
        expect(half.viewportFraction, 0.5);

        final full = resolvePageTurnStep(mode: mode, amount: TurnAmount.full);
        expect(full.kind, PageTurnStepKind.performancePages);
        expect(full.pageDelta, 1);
      }
    });
  });

  test('PageTurnPrefs round-trips turnAmount', () async {
    final dir = await Directory.systemTemp.createTemp('turn_amount_');
    addTearDown(() => dir.delete(recursive: true));
    final store = PageTurnPrefsStore(root: dir);
    await store.save(
      const PageTurnPrefs(turnAmount: TurnAmount.half),
    );
    final loaded = await store.load();
    expect(loaded.turnAmount, TurnAmount.half);
  });
}
