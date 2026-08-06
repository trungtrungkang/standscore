import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/layout/pdf_layout_mode.dart';
import 'package:stagescore/pageturn/page_turn_amount.dart';
import 'package:stagescore/pageturn/page_turn_prefs.dart';
import 'package:stagescore/pageturn/page_turn_prefs_store.dart';

void main() {
  group('resolvePageTurnStep', () {
    test('single layout always advances one page', () {
      for (final amount in TurnAmount.values) {
        final step = resolvePageTurnStep(
          mode: PdfLayoutMode.single,
          amount: amount,
        );
        expect(step.kind, PageTurnStepKind.performancePages);
        expect(step.pageDelta, 1);
      }
    });

    test('half-page layout always advances half a viewport (Spec 0056)', () {
      for (final mode in [
        PdfLayoutMode.halfPageTopBottom,
        PdfLayoutMode.halfPageLeftRight,
      ]) {
        for (final amount in TurnAmount.values) {
          final step = resolvePageTurnStep(mode: mode, amount: amount);
          expect(step.kind, PageTurnStepKind.viewportFraction, reason: mode.name);
          expect(step.viewportFraction, 0.5, reason: mode.name);
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

    test('a scrolling layout moves by the screen, not by page index', () {
      // Full used to be goToPage(±1) with a top anchor, which reads the top of
      // the next page and never the bottom of the one it left — a lost system
      // per page on any screen where a page does not fit (Spec 0041).
      for (final mode in [PdfLayoutMode.fitWidth, PdfLayoutMode.fitHeight]) {
        final half = resolvePageTurnStep(mode: mode, amount: TurnAmount.half);
        expect(half.kind, PageTurnStepKind.viewportFraction);
        expect(half.viewportFraction, 0.5);

        final full = resolvePageTurnStep(mode: mode, amount: TurnAmount.full);
        expect(full.kind, PageTurnStepKind.viewportFraction);
        expect(full.viewportFraction, 1.0);
      }
    });

    test('Turn amount is only offered where it changes something', () {
      expect(turnAmountApplies(PdfLayoutMode.fitWidth), isTrue);
      expect(turnAmountApplies(PdfLayoutMode.twoPage), isTrue);
      for (final mode in [
        PdfLayoutMode.single,
        PdfLayoutMode.halfPageTopBottom,
        PdfLayoutMode.halfPageLeftRight,
      ]) {
        expect(turnAmountApplies(mode), isFalse, reason: mode.name);
      }
    });
  });

  test('PageTurnPrefs round-trips turnAmount', () async {
    final dir = await Directory.systemTemp.createTemp('turn_amount_');
    addTearDown(() => dir.delete(recursive: true));
    final store = PageTurnPrefsStore(root: dir);
    await store.save(const PageTurnPrefs(turnAmount: TurnAmount.half));
    final loaded = await store.load();
    expect(loaded.turnAmount, TurnAmount.half);
  });
}
