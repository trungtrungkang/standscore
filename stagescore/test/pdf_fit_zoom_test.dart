import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/layout/pdf_fit_zoom.dart';
import 'package:stagescore/layout/pdf_layout_mode.dart';

/// A4 in PDF units, and the phone this was reported on.
const _page = Size(595, 842);
const _portrait = Size(393, 852);
const _landscape = Size(852, 393);
const _margin = 8.0;

Size _verticalDocument(int pages) =>
    Size(_page.width + _margin * 2, pages * (_page.height + _margin) + _margin);

Size _twoPageDocument(int spreads) => Size(
  _page.width * 2 + _margin * 3,
  spreads * (_page.height + _margin) + _margin,
);

final _spreadHeight = _page.height + _margin * 2;

void main() {
  group('scrolling layouts', () {
    test('width binds, in either orientation', () {
      final document = _verticalDocument(12);
      for (final view in [_portrait, _landscape]) {
        expect(
          pdfFitZoom(
            mode: PdfLayoutMode.fitWidth,
            viewSize: view,
            documentSize: document,
          ),
          view.width / document.width,
        );
      }
    });

    test('a landscape Score at fit does not read as zoomed in', () {
      // Regression: this was measured against pdfrx's minScale — the scale
      // that fits a whole page — so landscape looked 3× zoomed and swipe
      // PageTurn (0033) switched itself off.
      final document = _verticalDocument(12);
      final fit = pdfFitZoom(
        mode: PdfLayoutMode.fitWidth,
        viewSize: _landscape,
        documentSize: document,
      );

      expect(fit <= fit * kFitZoomTolerance, isTrue);
      expect(fit, greaterThan(_landscape.height / _page.height));
    });

    test('fit height reads sideways, so height binds', () {
      final document = Size(9000, _page.height + _margin * 2);
      expect(
        pdfFitZoom(
          mode: PdfLayoutMode.fitHeight,
          viewSize: _landscape,
          documentSize: document,
        ),
        _landscape.height / document.height,
      );
    });
  });

  group('two pages', () {
    test('a landscape spread fits on the screen, not just across it', () {
      final document = _twoPageDocument(6);
      final fit = pdfFitZoom(
        mode: PdfLayoutMode.twoPage,
        viewSize: _landscape,
        documentSize: document,
        spreadHeight: _spreadHeight,
      );

      expect(
        _spreadHeight * fit,
        lessThanOrEqualTo(_landscape.height + 0.01),
        reason: 'the bottom of the music was off the screen',
      );
      expect(document.width * fit, lessThanOrEqualTo(_landscape.width + 0.01));
      expect(fit, lessThan(_landscape.width / document.width));
    });

    test('a portrait spread still fits across', () {
      final document = _twoPageDocument(6);
      expect(
        pdfFitZoom(
          mode: PdfLayoutMode.twoPage,
          viewSize: _portrait,
          documentSize: document,
          spreadHeight: _spreadHeight,
        ),
        _portrait.width / document.width,
      );
    });

    test('the pair binds, not the page being looked at', () {
      final layouts = [
        const Rect.fromLTWH(0, 0, 595, 700),
        const Rect.fromLTWH(0, 0, 595, 842),
        const Rect.fromLTWH(0, 0, 595, 500),
      ];

      expect(twoPageSpreadHeight(layouts, 1), 842);
      expect(twoPageSpreadHeight(layouts, 2), 842);
      expect(twoPageSpreadHeight(layouts, 3), 500, reason: 'no partner');
    });

    test('an out-of-range page falls back to a real pair', () {
      final layouts = [const Rect.fromLTWH(0, 0, 595, 842)];
      expect(twoPageSpreadHeight(layouts, 99), 842);
      expect(twoPageSpreadHeight(const [], 1), 0);
    });
  });

  test('an unmeasured viewer asks for no scaling', () {
    expect(
      pdfFitZoom(
        mode: PdfLayoutMode.fitWidth,
        viewSize: Size.zero,
        documentSize: _verticalDocument(3),
      ),
      1,
    );
  });
}
