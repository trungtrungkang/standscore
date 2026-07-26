import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/layout/pdf_layout_mode.dart';
import 'package:stagescore/pageturn/layout_navigation.dart';
import 'package:stagescore/pageturn/page_turn_prefs.dart';
import 'package:stagescore/pageturn/page_turn_prefs_store.dart';

const _horizontal = [
  PdfLayoutMode.single,
  PdfLayoutMode.twoPage,
  PdfLayoutMode.halfPageLeftRight,
];

const _vertical = [PdfLayoutMode.fitWidth, PdfLayoutMode.halfPageTopBottom];

void main() {
  group('Match layout', () {
    test('taps land on the halves the pages move between', () {
      for (final mode in _horizontal) {
        final resolved = resolvePageTurnPrefsForLayout(
          const PageTurnPrefs(),
          mode,
        );
        expect(resolved.tapMode, PageTurnTapMode.leftRight, reason: mode.name);
      }
      for (final mode in _vertical) {
        final resolved = resolvePageTurnPrefsForLayout(
          const PageTurnPrefs(),
          mode,
        );
        expect(resolved.tapMode, PageTurnTapMode.topBottom, reason: mode.name);
      }
    });

    test('swipe runs along the same axis', () {
      final sideways = resolvePageTurnPrefsForLayout(
        const PageTurnPrefs(),
        PdfLayoutMode.single,
      );
      expect(sideways.swipeLeft, isTrue);
      expect(sideways.swipeRight, isTrue);
      expect(sideways.swipeUp, isFalse);
      expect(sideways.swipeDown, isFalse);

      // Scroll used to run down the screen and be turned sideways.
      final down = resolvePageTurnPrefsForLayout(
        const PageTurnPrefs(),
        PdfLayoutMode.fitWidth,
      );
      expect(down.swipeUp, isTrue);
      expect(down.swipeDown, isTrue);
      expect(down.swipeLeft, isFalse);
      expect(down.swipeRight, isFalse);
    });

    test('an explicit choice is never overruled', () {
      const chosen = PageTurnPrefs(
        tapMode: PageTurnTapMode.next,
        swipeMode: SwipeMode.custom,
        swipeLeft: false,
        swipeRight: false,
        swipeUp: true,
        swipeDown: false,
      );
      final resolved = resolvePageTurnPrefsForLayout(
        chosen,
        PdfLayoutMode.single,
      );
      expect(resolved.tapMode, PageTurnTapMode.next);
      expect(resolved.swipeUp, isTrue);
      expect(resolved.swipeLeft, isFalse);
    });
  });

  group('navigationHintFor', () {
    test('names the gestures that will actually turn a page', () {
      expect(
        navigationHintFor(PdfLayoutMode.single, const PageTurnPrefs()),
        'tap left / right · swipe sideways',
      );
      expect(
        navigationHintFor(PdfLayoutMode.fitWidth, const PageTurnPrefs()),
        'tap top / bottom · swipe up / down',
      );
    });

    test('falls back to what is left when a musician turns gestures off', () {
      const noGestures = PageTurnPrefs(
        tapMode: PageTurnTapMode.disabled,
        swipeMode: SwipeMode.custom,
        swipeLeft: false,
        swipeRight: false,
      );
      expect(
        navigationHintFor(PdfLayoutMode.single, noGestures),
        'Pedal or the page bar',
      );
    });
  });

  group('prefs', () {
    test('a new install matches the layout', () {
      const prefs = PageTurnPrefs();
      expect(prefs.tapMode, PageTurnTapMode.matchLayout);
      expect(prefs.swipeMode, SwipeMode.matchLayout);
    });

    test('a file written before 0041 keeps its own switches', () {
      final prefs = PageTurnPrefs.fromJson(const {
        'tapMode': 'leftRight',
        'swipeLeft': true,
        'swipeRight': true,
      });
      expect(prefs.swipeMode, SwipeMode.custom);
      expect(prefs.tapMode, PageTurnTapMode.leftRight);
    });

    test('round-trips the new sentinels', () async {
      final dir = await Directory.systemTemp.createTemp('layout_nav_');
      addTearDown(() => dir.delete(recursive: true));
      final store = PageTurnPrefsStore(root: dir);
      await store.save(const PageTurnPrefs());
      final loaded = await store.load();
      expect(loaded.tapMode, PageTurnTapMode.matchLayout);
      expect(loaded.swipeMode, SwipeMode.matchLayout);
    });
  });
}
