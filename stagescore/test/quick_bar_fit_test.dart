import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/ui/page_nav_bar.dart';
import 'package:stagescore/ui/quick_bar_fit.dart';
import 'package:stagescore/ui/score_menu_quick_bar.dart';

QuickBarFit _fit(Size size, {double bottomInset = 0, int slots = 3}) =>
    QuickBarFit(screenSize: size, slotCount: slots, bottomInset: bottomInset);

void main() {
  group('QuickBarFit — stacked or merged', () {
    test('a phone in portrait stacks the two rows', () {
      // 162 pt of 852 is a fifth of the screen: affordable, and the row has no
      // width to give the scrubber anyway.
      final fit = _fit(const Size(393, 852), bottomInset: 34);
      expect(fit.mergeIntoPageNav, isFalse);
      expect(fit.stackedHeightFraction, lessThan(kMaxStackedChromeFraction));
    });

    test('a phone in landscape merges into the scrubber row', () {
      // The measurement this whole class exists for: stacked, the chrome took
      // over half the height of this screen and left the Score 180 pt.
      final fit = _fit(const Size(852, 393), bottomInset: 21);
      expect(fit.stackedHeightFraction, greaterThan(kMaxStackedChromeFraction));
      expect(fit.mergeIntoPageNav, isTrue);
      expect(fit.mergedScrubberWidth, greaterThan(kMinScrubberWidth));
    });

    test('a tablet stacks in both orientations', () {
      expect(
        _fit(const Size(744, 1133), bottomInset: 20).mergeIntoPageNav,
        isFalse,
      );
      expect(
        _fit(const Size(1366, 1024), bottomInset: 20).mergeIntoPageNav,
        isFalse,
      );
    });

    test('a screen that is short *and* narrow keeps the scrubber whole', () {
      // Split-screen: stacking is unaffordable by height, but merging would
      // leave the scrubber 49 pt, so the height cost is the lesser harm.
      final fit = _fit(const Size(393, 360));
      expect(fit.stackedHeightFraction, greaterThan(kMaxStackedChromeFraction));
      expect(fit.mergedScrubberWidth, lessThan(kMinScrubberWidth));
      expect(fit.mergeIntoPageNav, isFalse);
    });

    test('a fourth shortcut is answered for without touching this class', () {
      // A wide-enough screen still merges four; the point is that the number
      // comes from the bar, so the arithmetic follows it.
      expect(_fit(const Size(852, 393), slots: 4).mergeIntoPageNav, isTrue);
      expect(
        _fit(const Size(600, 393), slots: 4).mergedScrubberWidth,
        lessThan(_fit(const Size(600, 393), slots: 3).mergedScrubberWidth),
      );
    });
  });

  group('QuickBarFit — slot width', () {
    test('slots keep their shape instead of spreading over a tablet', () {
      final phone = _fit(const Size(393, 852));
      final tablet = _fit(const Size(1366, 1024));
      expect(phone.slotWidth, kQuickBarMaxSlotWidth);
      expect(tablet.slotWidth, kQuickBarMaxSlotWidth);
      // Measured before the cap existed: the shortcuts sat 283 pt apart here.
      expect(tablet.contentWidth, lessThan(tablet.screenSize.width / 3));
    });

    test('a narrow screen falls back to the minimum tap target', () {
      final fit = _fit(const Size(320, 568), slots: 8);
      expect(fit.slotWidth, kQuickBarMinSlotWidth);
    });
  });

  group('quickBarLabelsFit', () {
    // The test font draws every character a full em wide, so a word of N
    // characters at F points measures N × F. That makes these cases about the
    // rule rather than about one typeface's metrics — a real font is narrower,
    // which is why the words fit on a device at the app's own label size.
    const style = TextStyle(fontSize: 8);
    const labels = ['Bookmarks', 'Draw', 'Exit draw', 'Metronome'];

    test('the words fit a full-width slot', () {
      // 9 characters × 8 pt = 72, inside 96 less the padding either side.
      expect(
        quickBarLabelsFit(
          labels: labels,
          style: style,
          textScaler: TextScaler.noScaling,
          slotWidth: kQuickBarMaxSlotWidth,
        ),
        isTrue,
      );
    });

    test('and drop out of a slot squeezed to the tap target', () {
      expect(
        quickBarLabelsFit(
          labels: labels,
          style: style,
          textScaler: TextScaler.noScaling,
          slotWidth: kQuickBarMinSlotWidth,
        ),
        isFalse,
      );
    });

    test('the longest word decides for the whole row', () {
      // Stands in for a translation: the bar reserves room for the longest
      // word it could draw, so nothing overflows and nothing moves later.
      expect(
        quickBarLabelsFit(
          labels: const [...labels, 'Trang đánh dấu'],
          style: style,
          textScaler: TextScaler.noScaling,
          slotWidth: kQuickBarMaxSlotWidth,
        ),
        isFalse,
      );
    });

    test('accessibility text at 300% falls back to icons, never clips', () {
      // Height, not width, is what fails here: a label three times its size
      // would push the icon out of its own tap target.
      expect(
        quickBarLabelsFit(
          labels: const ['Draw'],
          style: style,
          textScaler: const TextScaler.linear(3),
          slotWidth: kQuickBarMaxSlotWidth,
        ),
        isFalse,
      );
    });
  });

  testWidgets('kPageNavBarControlsWidth is not smaller than the real bar', (
    tester,
  ) async {
    // The merge decision is made before the row is laid out, so the constant
    // stands in for the chevrons and the page button. This keeps it honest: if
    // the PageNavBar grows a control, the estimate has to grow with it.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: PageNavBar(
            // A page count wider than any real Score's, so the widest the
            // page-number button can get is inside the estimate too.
            pageNumber: 9999,
            pageCount: 9999,
            onJumpToPage: (_) {},
          ),
        ),
      ),
    );

    final bar = tester.getSize(find.byType(PageNavBar));
    final slider = tester.getSize(find.byType(Slider));
    expect(
      bar.width - slider.width,
      lessThanOrEqualTo(kPageNavBarControlsWidth),
    );
  });

  test('the bar owns the slot count the fit is asked about', () {
    // One number, in the widget that knows what is on the row.
    expect(ScoreMenuQuickBar.slotCount, 3);
  });
}
