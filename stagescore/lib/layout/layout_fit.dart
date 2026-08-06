import 'dart:math' as math;
import 'dart:ui';

import 'package:stagescore/layout/pdf_layout_mode.dart';

/// A page's width over its height. A4 is 1/√2, and scanned parts are close
/// enough that one constant beats asking the document before it is decoded.
const double kDefaultPageAspect = 1 / 1.4142135623730951;

/// Narrowest a page may be drawn inside a spread and still be music.
///
/// Fenced by two real devices rather than picked: a 393-pt phone in portrait
/// gives each page of a spread 196 pt, which no one can read at arm's length,
/// and the same phone on its side gives 278 pt, which 0036 went to some
/// trouble to make work.
const double kMinSpreadPageWidth = 240;

/// What the current viewport can afford a Score (Spec 0041).
///
/// Every layout question in PdfMode is the same question — how does the shape
/// of the screen compare to the shape of a page — so it is asked in one place.
/// Nothing here is stored: the answer changes when the device is rotated, and
/// a remembered answer would be a lie one rotation later.
class LayoutFit {
  const LayoutFit({
    required this.viewSize,
    this.pageAspect = kDefaultPageAspect,
  });

  final Size viewSize;

  /// Width over height of the page being read.
  final double pageAspect;

  bool get _measured =>
      viewSize.width > 0 && viewSize.height > 0 && pageAspect > 0;

  /// Width over height of the viewport.
  double get viewAspect => _measured ? viewSize.width / viewSize.height : 0;

  /// Whether the viewport has vertical slack a width-fitted page leaves
  /// behind — the case Half Page (top/bottom) spends by scrolling into it
  /// (Spec 0056). True for any portrait phone; false once the page is bound
  /// by height instead, which is every landscape screen.
  bool get hasVerticalSlack => _measured && viewAspect < pageAspect;

  /// Width each page of a facing pair would be drawn at, in logical pixels.
  double get spreadPageWidth {
    if (!_measured) return 0;
    return math.min(viewSize.width / 2, viewSize.height * pageAspect);
  }

  /// Whether a two-page spread is worth showing on this viewport.
  ///
  /// Deliberately not "is this landscape": a tablet held upright draws a
  /// perfectly readable spread, and an orientation flag would take it away.
  bool get spreadFits => spreadPageWidth >= kMinSpreadPageWidth;

  /// Whether the second page costs nothing.
  ///
  /// The mirror image of [hasVerticalSlack]. A page bound by the viewport's
  /// height leaves horizontal slack, and once that slack is a page wide the
  /// spread draws each page at exactly the size One page would have drawn it — twice
  /// the music for nothing. Below that the spread still *fits* (a tablet held
  /// upright), but it is a trade, and Auto does not make trades on the
  /// musician's behalf.
  bool get spreadIsFree => _measured && viewAspect >= 2 * pageAspect;

  /// The layout this screen would choose for itself.
  ///
  /// Spend whichever slack the screen has and nothing else: a second page
  /// across when the screen is wider than the page, continuous scroll (with
  /// its half-step peek of what comes next) when it is narrower. Since Spec
  /// 0056, Half Page draws the music at exactly One page's size — it is
  /// never a trade, so it is recommended whenever there is any vertical
  /// slack to spend.
  PdfLayoutMode recommendedMode() {
    if (!_measured) return PdfLayoutMode.single;
    if (spreadIsFree) return PdfLayoutMode.twoPage;
    if (hasVerticalSlack) return PdfLayoutMode.halfPageTopBottom;
    return PdfLayoutMode.single;
  }

  @override
  bool operator ==(Object other) =>
      other is LayoutFit &&
      other.viewSize == viewSize &&
      other.pageAspect == pageAspect;

  @override
  int get hashCode => Object.hash(viewSize, pageAspect);
}

/// The layout actually drawn, given what the musician picked and what the
/// screen can afford (Spec 0041).
///
/// The picked mode is never rewritten by this: rotating a phone back restores
/// the spread without the musician choosing again.
PdfLayoutMode resolveLayoutMode({
  required PdfLayoutMode stored,
  required LayoutFit fit,
}) {
  switch (stored) {
    case PdfLayoutMode.auto:
      return fit.recommendedMode();
    case PdfLayoutMode.twoPage:
      // 0004 always said "facing pages when width allows" and never said what
      // happens when it does not. This is that.
      return fit.spreadFits ? PdfLayoutMode.twoPage : PdfLayoutMode.single;
    case PdfLayoutMode.fitHeight:
      // Cut from the picker at 0041; old prefs and 0027 restores still hold it.
      return PdfLayoutMode.fitWidth;
    case PdfLayoutMode.single:
    case PdfLayoutMode.fitWidth:
    case PdfLayoutMode.halfPageTopBottom:
    case PdfLayoutMode.halfPageLeftRight:
      return stored;
  }
}

/// True when [stored] asks for a spread this viewport cannot give.
bool spreadFellBack({required PdfLayoutMode stored, required LayoutFit fit}) =>
    stored == PdfLayoutMode.twoPage && !fit.spreadFits;
