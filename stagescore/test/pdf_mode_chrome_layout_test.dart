import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/ui/page_nav_bar.dart';
import 'package:stagescore/ui/pdf_mode_screen.dart';

/// The PdfMode Scaffold shape from Spec 0034. The real screen cannot be pumped
/// (pdfrx needs the native viewer), so the chrome composition is characterised
/// here: the viewer must keep the same size whether chrome is shown or hidden.
Widget _shell({
  required bool performanceChrome,
  required bool chromeShown,
  VoidCallback? onScoreTap,
  bool drawToolbar = false,
}) {
  final appBar = AppBar(
    toolbarHeight: kPdfAppBarHeight,
    title: const Text('Score'),
  );
  final pageNav = PageNavBar(
    pageNumber: 1,
    pageCount: 56,
    onJumpToPage: (_) {},
  );
  Widget fade(Widget child) => IgnorePointer(
    ignoring: !chromeShown,
    child: AnimatedOpacity(
      opacity: chromeShown ? 1 : 0,
      duration: const Duration(milliseconds: 180),
      child: child,
    ),
  );
  return MaterialApp(
    builder: (context, child) => MediaQuery(
      // Notch + home indicator, as on the iPhone this Spec was demoed on.
      data: MediaQuery.of(
        context,
      ).copyWith(padding: const EdgeInsets.only(top: 47, bottom: 34)),
      child: child!,
    ),
    home: Builder(
      builder: (context) {
        final body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (drawToolbar) const SizedBox(height: 56),
            Expanded(
              // Mirrors PdfModeScreen._wrapViewerInsets.
              child: SafeArea(
                top: performanceChrome,
                bottom: !performanceChrome,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onScoreTap,
                  child: const _ViewerStub(),
                ),
              ),
            ),
          ],
        );
        // One Scaffold, one Stack, the Score always first in it — see the
        // comment on PdfModeScreen.build.
        return Scaffold(
          appBar: performanceChrome ? null : appBar,
          bottomNavigationBar: performanceChrome ? null : pageNav,
          body: Stack(
            fit: StackFit.expand,
            children: [
              body,
              if (performanceChrome) ...[
                Positioned(top: 0, left: 0, right: 0, child: fade(appBar)),
                Positioned(bottom: 0, left: 0, right: 0, child: fade(pageNav)),
              ],
            ],
          ),
        );
      },
    ),
  );
}

/// Stands in for a viewer: the thing that matters about it is that its State,
/// and so the page it is showing, is the same object after a rebuild.
class _ViewerStub extends StatefulWidget {
  const _ViewerStub();

  @override
  State<_ViewerStub> createState() => _ViewerStubState();
}

class _ViewerStubState extends State<_ViewerStub> {
  int page = 1;

  @override
  Widget build(BuildContext context) => const Placeholder();
}

void main() {
  testWidgets('entering draw mode keeps the viewer, and the page it is on', (
    tester,
  ) async {
    // Regression: Draw mode suspends PerformanceMode (`active` is off while
    // drawing), and the screen used to answer that with a different Scaffold
    // shape. The viewer was then a different element in each shape, so it was
    // rebuilt from nothing and the musician landed back on page 1.
    await tester.pumpWidget(
      _shell(performanceChrome: true, chromeShown: false),
    );
    tester.state<_ViewerStubState>(find.byType(_ViewerStub)).page = 12;

    await tester.pumpWidget(
      _shell(performanceChrome: false, chromeShown: true, drawToolbar: true),
    );
    await tester.pumpAndSettle();
    expect(tester.state<_ViewerStubState>(find.byType(_ViewerStub)).page, 12);

    await tester.pumpWidget(
      _shell(performanceChrome: true, chromeShown: false),
    );
    await tester.pumpAndSettle();
    expect(
      tester.state<_ViewerStubState>(find.byType(_ViewerStub)).page,
      12,
      reason: 'leaving draw mode must not cost the page either',
    );
  });

  testWidgets('PageNavBar stays compact in the Scaffold bottom slot', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: PageNavBar(
            pageNumber: 1,
            pageCount: 56,
            onJumpToPage: (_) {},
          ),
          body: const Placeholder(),
        ),
      ),
    );

    final nav = tester.getSize(find.byType(PageNavBar));
    expect(
      nav.height,
      kPageNavBarHeight + kPageNavBarGestureGap,
      reason: 'must not cover the Score',
    );
    expect(tester.getSize(find.byType(Placeholder)).height, greaterThan(400));
  });

  testWidgets('the scrubber keeps clear of the phone bottom edge', (
    tester,
  ) async {
    // Regression: flush against the home indicator, a drag along the scrubber
    // was taken by the OS as a switch-apps swipe.
    await tester.pumpWidget(_shell(performanceChrome: true, chromeShown: true));
    await tester.pumpAndSettle();

    final screen = tester.getSize(find.byType(MaterialApp));
    final slider = tester.getRect(find.byType(Slider));
    expect(screen.height - slider.bottom, 34 + kPageNavBarGestureGap);
  });

  testWidgets('the AppBar is taller than the PageNavBar', (tester) async {
    await tester.pumpWidget(_shell(performanceChrome: true, chromeShown: true));
    await tester.pumpAndSettle();

    final header = tester.getSize(find.byType(AppBar)).height;
    final footer = tester.getSize(find.byType(PageNavBar)).height;
    // Both carry their own device inset; compare the content bands.
    expect(header - 47, kPdfAppBarHeight);
    expect(footer - 34, kPageNavBarHeight + kPageNavBarGestureGap);
    expect(kPdfAppBarHeight, greaterThan(kPageNavBarHeight));
  });

  testWidgets('PerformanceMode viewer keeps its size when chrome hides', (
    tester,
  ) async {
    await tester.pumpWidget(_shell(performanceChrome: true, chromeShown: true));
    await tester.pumpAndSettle();
    final shown = tester.getRect(find.byType(_ViewerStub));

    await tester.pumpWidget(
      _shell(performanceChrome: true, chromeShown: false),
    );
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(_ViewerStub)), shown);

    final screen = tester.getSize(find.byType(MaterialApp));
    expect(shown.top, 47, reason: 'clears the notch, not the AppBar');
    expect(
      shown.bottom,
      screen.height,
      reason: 'runs to the bottom edge so PageTurn taps land there',
    );
  });

  testWidgets('hidden chrome does not eat taps in the bottom corner', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _shell(
        performanceChrome: true,
        chromeShown: false,
        onScoreTap: () => taps++,
      ),
    );
    await tester.pumpAndSettle();

    final screen = tester.getSize(find.byType(MaterialApp));
    await tester.tapAt(Offset(screen.width - 8, screen.height - 8));
    expect(taps, 1, reason: 'PageTurn must reach the bottom-right corner');
  });

  testWidgets('revealed chrome does take the taps on its own bar', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _shell(
        performanceChrome: true,
        chromeShown: true,
        onScoreTap: () => taps++,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tapAt(tester.getCenter(find.byType(PageNavBar)));
    expect(taps, 0);
  });

  testWidgets('without PerformanceMode the chrome takes layout space', (
    tester,
  ) async {
    await tester.pumpWidget(
      _shell(performanceChrome: false, chromeShown: true),
    );
    await tester.pumpAndSettle();

    final screen = tester.getSize(find.byType(MaterialApp));
    final body = tester.getRect(find.byType(_ViewerStub));
    final nav = tester.getRect(find.byType(PageNavBar));
    expect(body.top, greaterThan(0), reason: 'below the AppBar');
    expect(body.bottom, nav.top, reason: 'above the PageNavBar');
    expect(nav.bottom, screen.height);
  });
}
