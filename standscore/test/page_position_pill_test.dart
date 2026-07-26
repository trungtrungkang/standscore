import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/ui/page_position_pill.dart';

/// The transient position readout from Spec 0036.
void main() {
  const duration = Duration(milliseconds: 300);

  Future<void> pumpPill(
    WidgetTester tester, {
    required int pageNumber,
    required bool enabled,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PagePositionPill(
            pageNumber: pageNumber,
            pageCount: 56,
            enabled: enabled,
            duration: duration,
          ),
        ),
      ),
    );
  }

  double opacity(WidgetTester tester) =>
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;

  testWidgets('stays out of the way until a page turn', (tester) async {
    await pumpPill(tester, pageNumber: 4, enabled: true);
    expect(opacity(tester), 0);

    await pumpPill(tester, pageNumber: 5, enabled: true);
    await tester.pump();
    expect(opacity(tester), 1);
    expect(find.text('5 / 56'), findsOneWidget);
  });

  testWidgets('fades itself out without being asked', (tester) async {
    await pumpPill(tester, pageNumber: 4, enabled: true);
    await pumpPill(tester, pageNumber: 5, enabled: true);
    await tester.pump();
    expect(opacity(tester), 1);

    await tester.pump(duration);
    expect(opacity(tester), 0);
    await tester.pumpAndSettle();
  });

  testWidgets('says nothing while the chrome is up', (tester) async {
    // The PageNavBar is already answering the question.
    await pumpPill(tester, pageNumber: 4, enabled: false);
    await pumpPill(tester, pageNumber: 5, enabled: false);
    await tester.pump();

    expect(opacity(tester), 0);
  });

  testWidgets('a reveal mid-countdown takes it away', (tester) async {
    await pumpPill(tester, pageNumber: 4, enabled: true);
    await pumpPill(tester, pageNumber: 5, enabled: true);
    await tester.pump();
    expect(opacity(tester), 1);

    await pumpPill(tester, pageNumber: 5, enabled: false);
    await tester.pump();
    expect(opacity(tester), 0);
    await tester.pumpAndSettle();
  });

  testWidgets('never takes a tap meant for the PageTurn zone', (tester) async {
    // It floats over the bottom-right corner, which is where the musician
    // taps to turn the page once the PageNavBar is hidden (0034).
    var tapsBehind = 0;
    Widget app(int page) => MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => tapsBehind++,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: PagePositionPill(
                pageNumber: page,
                pageCount: 56,
                enabled: true,
                duration: duration,
              ),
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(app(4));
    await tester.pumpWidget(app(5));
    await tester.pump();
    expect(find.text('5 / 56'), findsOneWidget);

    await tester.tap(find.text('5 / 56'), warnIfMissed: false);
    await tester.pump();

    expect(tapsBehind, 1);
    await tester.pumpAndSettle();
  });
}
