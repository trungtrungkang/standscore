import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/layout/half_page.dart';
import 'package:standscore/layout/layout_fit.dart';
import 'package:standscore/layout/pdf_layout_mode.dart';
import 'package:standscore/layout/pdf_layout_prefs.dart';

/// The four screens the 0041 review measured, and the small phone that shows
/// the same setting landing on the other side of the line.
const _phone = Size(393, 852);
const _phoneLandscape = Size(852, 393);
const _smallPhone = Size(375, 667);
const _tablet = Size(834, 1194);
const _tabletLandscape = Size(1194, 834);

LayoutFit _fit(Size size) => LayoutFit(viewSize: size);

PdfLayoutMode _recommended(Size size) =>
    _fit(size).recommendedMode(peekRatio: halfPageSeparatorDefault);

void main() {
  group('free peek', () {
    test('is the vertical slack a width-bound page leaves behind', () {
      // 35% on this phone against a 28% default: the peek layout draws the
      // music at exactly One page's size and adds a quarter of the next page.
      expect(_fit(_phone).freePeek, closeTo(0.348, 0.001));
      expect(_fit(_phone).freePeek, greaterThan(halfPageSeparatorDefault));
    });

    test('the same default costs music on a smaller phone', () {
      expect(_fit(_smallPhone).freePeek, closeTo(0.205, 0.001));
      expect(_fit(_smallPhone).freePeek, lessThan(halfPageSeparatorDefault));
    });

    test('a page that already fills the height leaves nothing to spend', () {
      expect(_fit(_tablet).freePeek, closeTo(0.012, 0.001));
      expect(_fit(_tabletLandscape).freePeek, 0);
    });
  });

  group('spreads', () {
    test('fit wherever a page of the pair stays readable', () {
      expect(_fit(_phone).spreadFits, isFalse, reason: '196 pt per page');
      expect(_fit(_phoneLandscape).spreadFits, isTrue, reason: '278 pt');
      // Not an orientation flag: a tablet held upright is a usable spread.
      expect(_fit(_tablet).spreadFits, isTrue, reason: '417 pt');
      expect(_fit(_tabletLandscape).spreadFits, isTrue);
    });

    test('are free only where the screen is two pages wide', () {
      expect(_fit(_tabletLandscape).spreadIsFree, isTrue);
      expect(_fit(_phoneLandscape).spreadIsFree, isTrue);
      expect(
        _fit(_tablet).spreadIsFree,
        isFalse,
        reason: 'usable, but each page is half the size One page would give',
      );
      expect(_fit(_phone).spreadIsFree, isFalse);
    });
  });

  group('what the screen recommends', () {
    test('a landscape tablet wants the spread', () {
      expect(_recommended(_tabletLandscape), PdfLayoutMode.twoPage);
      expect(_recommended(_phoneLandscape), PdfLayoutMode.twoPage);
    });

    test('a portrait tablet wants one page, spread or no spread', () {
      expect(_recommended(_tablet), PdfLayoutMode.single);
    });

    test('a portrait phone wants the peek it gets for nothing', () {
      expect(_recommended(_phone), PdfLayoutMode.halfPageTopBottom);
      expect(
        _recommended(_smallPhone),
        PdfLayoutMode.single,
        reason: 'here the default peek would shrink the music',
      );
    });

    test('an unmeasured screen recommends nothing clever', () {
      expect(_recommended(Size.zero), PdfLayoutMode.single);
    });
  });

  group('resolveLayoutMode', () {
    PdfLayoutMode resolve(PdfLayoutMode stored, Size size) => resolveLayoutMode(
      stored: stored,
      fit: _fit(size),
      peekRatio: halfPageSeparatorDefault,
    );

    test('Auto draws what the screen asked for', () {
      expect(
        resolve(PdfLayoutMode.auto, _tabletLandscape),
        PdfLayoutMode.twoPage,
      );
      expect(
        resolve(PdfLayoutMode.auto, _phone),
        PdfLayoutMode.halfPageTopBottom,
      );
    });

    test('a spread that cannot fit falls back without being rewritten', () {
      expect(resolve(PdfLayoutMode.twoPage, _phone), PdfLayoutMode.single);
      expect(
        spreadFellBack(stored: PdfLayoutMode.twoPage, fit: _fit(_phone)),
        isTrue,
      );
      // Rotating restores it: the pref was never touched.
      expect(
        resolve(PdfLayoutMode.twoPage, _phoneLandscape),
        PdfLayoutMode.twoPage,
      );
      expect(
        resolve(PdfLayoutMode.twoPage, _tablet),
        PdfLayoutMode.twoPage,
        reason: 'a portrait tablet keeps the spread it can show',
      );
    });

    test('a stored Fit height lands on Scroll', () {
      expect(resolve(PdfLayoutMode.fitHeight, _phone), PdfLayoutMode.fitWidth);
    });

    test('every other layout is drawn as picked', () {
      for (final mode in [
        PdfLayoutMode.single,
        PdfLayoutMode.fitWidth,
        PdfLayoutMode.halfPageTopBottom,
        PdfLayoutMode.halfPageLeftRight,
      ]) {
        expect(resolve(mode, _phone), mode);
        expect(resolve(mode, _tabletLandscape), mode);
      }
    });
  });

  group('layout prefs', () {
    test('a new install starts on Auto', () {
      expect(const PdfLayoutPrefs().mode, PdfLayoutMode.auto);
    });

    test('an install that predates Auto keeps what it chose', () async {
      final dir = await Directory.systemTemp.createTemp('layout_prefs_');
      addTearDown(() => dir.delete(recursive: true));
      final store = PdfLayoutPrefsStore(root: dir);

      await store.save(const PdfLayoutPrefs(mode: PdfLayoutMode.fitHeight));
      final loaded = await store.load();
      expect(loaded.mode, PdfLayoutMode.fitHeight, reason: '0027 restores it');
      expect(
        resolveLayoutMode(
          stored: loaded.mode,
          fit: _fit(_phone),
          peekRatio: loaded.halfPageSeparatorRatio,
        ),
        PdfLayoutMode.fitWidth,
      );
    });

    test('a file with no readable mode is not switched to Auto', () {
      final prefs = PdfLayoutPrefs.fromJson(const {'mode': 'someOldName'});
      expect(prefs.mode, PdfLayoutMode.single);
    });
  });
}
