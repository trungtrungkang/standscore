import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/ui/quick_bar_fit.dart';
import 'package:stagescore/ui/score_menu_quick_bar.dart';

Widget _bar({
  bool metronomeRunning = false,
  bool drawEnabled = false,
  bool merged = false,
  bool enabled = true,
  VoidCallback? onOpenMetronome,
  VoidCallback? onToggleDraw,
  VoidCallback? onOpenBookmarks,
  // The test font draws every character a full em wide, so the app's own
  // ~11 pt label size never measures as fitting here. Driving the size is how
  // these tests reach both sides of the decision in quickBarLabelsFit.
  double labelFontSize = 11,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData(
      textTheme: TextTheme(labelSmall: TextStyle(fontSize: labelFontSize)),
    ),
    home: Scaffold(
      body: ScoreMenuQuickBar(
        metronomeRunning: metronomeRunning,
        metronomeAccent: false,
        onOpenMetronome: onOpenMetronome ?? () {},
        drawEnabled: drawEnabled,
        onToggleDraw: onToggleDraw ?? () {},
        onOpenBookmarks: onOpenBookmarks ?? () {},
        merged: merged,
        enabled: enabled,
      ),
    ),
  );
}

List<double> _iconCentres(WidgetTester tester) {
  final buttons = find.descendant(
    of: find.byType(ScoreMenuQuickBar),
    matching: find.byType(IconButton),
  );
  return [
    for (var i = 0; i < tester.widgetList(buttons).length; i++)
      tester.getCenter(buttons.at(i)).dx,
  ];
}

void main() {
  group('ScoreMenuQuickBar', () {
    testWidgets('carries the three actions wanted mid-piece, and no others', (
      tester,
    ) async {
      await tester.pumpWidget(_bar());

      expect(find.byTooltip('Bookmarks'), findsOneWidget);
      expect(find.byTooltip('Draw'), findsOneWidget);
      expect(find.byTooltip('Metronome'), findsOneWidget);
      // Layout and the View group went back to `⋯` alone (revision 3): they
      // are how a Score is set up before playing, and View was a group sitting
      // beside its own child.
      expect(find.byTooltip('Layout'), findsNothing);
      expect(find.byTooltip('View'), findsNothing);
      expect(_iconCentres(tester), hasLength(ScoreMenuQuickBar.slotCount));
    });

    testWidgets('the metronome shortcut is there before it is running', (
      tester,
    ) async {
      // The whole point of a shortcut is starting the thing. Showing it only
      // while running meant the one moment it was reachable was the one moment
      // it was not needed.
      var opened = 0;
      await tester.pumpWidget(_bar(onOpenMetronome: () => opened++));

      await tester.tap(find.byTooltip('Metronome'));
      expect(opened, 1);
    });

    testWidgets('starting the metronome does not move the other shortcuts', (
      tester,
    ) async {
      // Measured regression: the conditional metronome icon shifted Draw by
      // 60 pt the moment it appeared — mid-piece, which is exactly when a
      // musician is aiming without looking.
      await tester.pumpWidget(_bar());
      final idle = _iconCentres(tester);

      await tester.pumpWidget(_bar(metronomeRunning: true));
      expect(_iconCentres(tester), idle);
      expect(find.byTooltip('Metronome (running)'), findsOneWidget);
    });

    testWidgets('each shortcut calls its own callback', (tester) async {
      var draw = 0;
      var bookmarks = 0;
      var metronome = 0;
      await tester.pumpWidget(
        _bar(
          onToggleDraw: () => draw++,
          onOpenBookmarks: () => bookmarks++,
          onOpenMetronome: () => metronome++,
        ),
      );

      await tester.tap(find.byTooltip('Bookmarks'));
      await tester.tap(find.byTooltip('Draw'));
      await tester.tap(find.byTooltip('Metronome'));

      expect(draw, 1);
      expect(bookmarks, 1);
      expect(metronome, 1);
    });

    testWidgets('the Draw shortcut flips once inside draw mode', (
      tester,
    ) async {
      await tester.pumpWidget(_bar(drawEnabled: true));

      expect(find.byTooltip('Exit draw'), findsOneWidget);
      expect(find.byTooltip('Draw'), findsNothing);
    });

    testWidgets('disabled while the Score loads, still in place', (
      tester,
    ) async {
      // It greys out instead of disappearing: the bar used to arrive with the
      // scrubber, so every Setlist piece change moved the whole chrome.
      var draw = 0;
      await tester.pumpWidget(_bar(enabled: false, onToggleDraw: () => draw++));

      expect(_iconCentres(tester), hasLength(ScoreMenuQuickBar.slotCount));
      await tester.tap(find.byTooltip('Draw'));
      expect(draw, 0);
    });
  });

  group('ScoreMenuQuickBar labels', () {
    testWidgets('are drawn when the words measure', (tester) async {
      await tester.pumpWidget(_bar(labelFontSize: 8));

      expect(find.text('Bookmarks'), findsOneWidget);
      expect(find.text('Draw'), findsOneWidget);
      expect(find.text('Metronome'), findsOneWidget);
    });

    testWidgets('and left out when they do not, rather than overflowing', (
      tester,
    ) async {
      await tester.pumpWidget(_bar(labelFontSize: 11));

      expect(find.text('Bookmarks'), findsNothing);
      expect(find.text('Metronome'), findsNothing);
      // The icons and their tooltips stay either way.
      expect(find.byTooltip('Bookmarks'), findsOneWidget);
    });

    testWidgets('never appear merged into the scrubber row', (tester) async {
      await tester.pumpWidget(_bar(merged: true, labelFontSize: 8));

      expect(find.text('Bookmarks'), findsNothing);
      expect(find.byTooltip('Bookmarks'), findsOneWidget);
    });
  });

  group('ScoreMenuQuickBar shape', () {
    testWidgets('a row of its own keeps the gesture gap below it', (
      tester,
    ) async {
      await tester.pumpWidget(_bar());

      expect(
        tester.getSize(find.byType(ScoreMenuQuickBar)).height,
        kQuickBarHeight + kQuickBarGestureGap,
      );
    });

    testWidgets(
      'merged, it is bare icons — the bar it rides in owns the rest',
      (tester) async {
        await tester.pumpWidget(_bar(merged: true));

        final size = tester.getSize(find.byType(ScoreMenuQuickBar));
        expect(size.height, kQuickBarHeight);
        expect(size.width, kQuickBarMinSlotWidth * ScoreMenuQuickBar.slotCount);
      },
    );
  });
}
