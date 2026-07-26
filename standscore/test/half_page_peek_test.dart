import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/layout/half_page.dart';
import 'package:standscore/layout/pdf_layout_mode.dart';

/// What the peek is *for*: reading the first system of the next page at the
/// size it is about to be played, not looking at a whole page in miniature.
const _phone = Size(393, 852);
const _phoneLandscape = Size(852, 393);
const _tabletLandscape = Size(1194, 834);
const _aspect = 1 / 1.414;
const _handle = 28.0;

double _peek(PdfLayoutMode mode, Size view, {double ratio = 0.28}) =>
    halfPagePeekPageWidth(
      mode: mode,
      viewerSize: view,
      separatorRatio: ratio,
      pageAspect: _aspect,
      handleExtent: _handle,
    );

/// Width the current page is drawn at, which is what the peek has to match.
double _currentWidth(PdfLayoutMode mode, Size view, {double ratio = 0.28}) {
  final pane = mode == PdfLayoutMode.halfPageTopBottom
      ? Size(view.width, (view.height - _handle) * (1 - ratio))
      : Size((view.width - _handle) * (1 - ratio), view.height);
  return math.min(pane.width, pane.height * _aspect);
}

void main() {
  group('top/bottom peek', () {
    test('draws the next page at the size of the page below it', () {
      // The bug: fitting a whole page into the band drew it at 42% of the
      // current page. A peek is a slice, not a thumbnail.
      final peek = _peek(PdfLayoutMode.halfPageTopBottom, _phone);
      expect(
        peek,
        closeTo(_currentWidth(PdfLayoutMode.halfPageTopBottom, _phone), 0.01),
      );
      expect(peek, closeTo(393, 0.01), reason: 'the phone is width-bound');
    });

    test('never grows past the current page on a wide screen', () {
      // Landscape leaves the current page bound by height, so a band-wide
      // peek would blow the next page up bigger than the music being played.
      final peek = _peek(PdfLayoutMode.halfPageTopBottom, _phoneLandscape);
      final current = _currentWidth(
        PdfLayoutMode.halfPageTopBottom,
        _phoneLandscape,
      );
      expect(peek, closeTo(current, 0.01));
      expect(peek, lessThan(_phoneLandscape.width));
    });

    test('follows the current page wherever the separator puts it', () {
      // Dragging the separator down eventually squeezes the current page
      // itself; the two pages stay the same size as each other throughout, so
      // the peek always reads as a continuation rather than a picture of one.
      for (final ratio in [0.1, 0.28, 0.5]) {
        expect(
          _peek(PdfLayoutMode.halfPageTopBottom, _phone, ratio: ratio),
          closeTo(
            _currentWidth(
              PdfLayoutMode.halfPageTopBottom,
              _phone,
              ratio: ratio,
            ),
            0.01,
          ),
          reason: 'separator at $ratio',
        );
      }
    });
  });

  group('side peek', () {
    test('is as wide as the strip it lives in', () {
      final peek = _peek(PdfLayoutMode.halfPageLeftRight, _tabletLandscape);
      expect(peek, closeTo((1194 - _handle) * 0.28, 0.01));
      expect(
        peek,
        lessThan(
          _currentWidth(PdfLayoutMode.halfPageLeftRight, _tabletLandscape),
        ),
        reason: 'a narrow strip cannot show the next page at reading size',
      );
    });

    test('stops at a whole page rather than overflowing sideways', () {
      // A wide strip on a short screen: the page runs out of height first.
      final peek = _peek(
        PdfLayoutMode.halfPageLeftRight,
        _phoneLandscape,
        ratio: 0.5,
      );
      expect(peek, closeTo(_phoneLandscape.height * _aspect, 0.01));
    });
  });

  test('an unmeasured viewer asks for nothing', () {
    expect(_peek(PdfLayoutMode.halfPageTopBottom, Size.zero), 0);
    expect(
      halfPagePeekPageWidth(
        mode: PdfLayoutMode.halfPageTopBottom,
        viewerSize: _phone,
        separatorRatio: 0.28,
        pageAspect: 0,
        handleExtent: _handle,
      ),
      0,
    );
  });
}
