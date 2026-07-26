import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/layout/page_color_filter.dart';
import 'package:standscore/layout/pdf_layout_mode.dart';
import 'package:standscore/layout/stage_preset.dart';
import 'package:standscore/ui/score_menu.dart';
import 'package:standscore/ui/score_menu_sheet.dart';

List<ScoreMenuGroup> menu({
  PdfLayoutMode layoutMode = PdfLayoutMode.single,
  PageColorFilterMode colorFilter = PageColorFilterMode.off,
  bool zoomLocked = false,
  bool annotationsVisible = true,
  bool exporting = false,
  bool metronomeRunning = false,
  StagePresetDirection stagePreset = StagePresetDirection.play,
}) {
  return buildScoreMenu(
    layoutMode: layoutMode,
    colorFilter: colorFilter,
    zoomLocked: zoomLocked,
    annotationsVisible: annotationsVisible,
    exporting: exporting,
    metronomeRunning: metronomeRunning,
    stagePreset: stagePreset,
  );
}

Iterable<ScoreMenuEntry> entriesOf(List<ScoreMenuGroup> groups) =>
    groups.expand((g) => g.entries);

ScoreMenuEntry entryFor(List<ScoreMenuGroup> groups, ScoreMenuAction action) =>
    entriesOf(groups).firstWhere((e) => e.action == action);

void main() {
  group('buildScoreMenu', () {
    test('every action is placed in exactly one group', () {
      final actions = entriesOf(menu()).map((e) => e.action).toList();
      expect(actions.toSet(), ScoreMenuAction.values.toSet());
      expect(
        actions.length,
        ScoreMenuAction.values.length,
        reason: 'an action must not appear twice',
      );
    });

    test('groups stay short enough to scan mid-piece', () {
      final groups = menu();
      expect(groups.map((g) => g.title), ['Go to', 'Marks', 'View', 'Playing']);
      for (final group in groups) {
        expect(group.entries.length, lessThanOrEqualTo(4), reason: group.title);
      }
    });

    test('Layout always shows the current mode', () {
      expect(entryFor(menu(), ScoreMenuAction.layout).value, 'Single page');
      expect(
        entryFor(
          menu(layoutMode: PdfLayoutMode.halfPageLeftRight),
          ScoreMenuAction.layout,
        ).value,
        'Half page (left/right)',
      );
    });

    test('Color filter and Page scale show state only when set', () {
      final off = menu();
      expect(entryFor(off, ScoreMenuAction.colorFilter).value, isNull);
      expect(entryFor(off, ScoreMenuAction.pageScale).value, isNull);

      final on = menu(colorFilter: PageColorFilterMode.sepia, zoomLocked: true);
      expect(
        entryFor(on, ScoreMenuAction.colorFilter).value,
        PageColorFilterMode.sepia.label,
      );
      expect(entryFor(on, ScoreMenuAction.pageScale).value, 'Locked');
    });

    test('labels follow annotation, export and metronome state', () {
      expect(
        entryFor(menu(), ScoreMenuAction.toggleAnnotations).label,
        'Hide annotations',
      );
      expect(
        entryFor(
          menu(annotationsVisible: false),
          ScoreMenuAction.toggleAnnotations,
        ).label,
        'Show annotations',
      );

      final exporting = entryFor(
        menu(exporting: true),
        ScoreMenuAction.exportAnnotated,
      );
      expect(exporting.label, 'Exporting…');
      expect(exporting.enabled, isFalse);

      expect(
        entryFor(menu(metronomeRunning: true), ScoreMenuAction.metronome).label,
        'Metronome (running)…',
      );
    });
  });

  group('showScoreMenu', () {
    testWidgets('returns the tapped action and closes', (tester) async {
      ScoreMenuAction? chosen;
      var opened = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  opened = true;
                  chosen = await showScoreMenu(
                    context: context,
                    groups: menu(zoomLocked: true),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(opened, isTrue);
      expect(find.text('Go to'), findsOneWidget);

      // The last group is below the fold on a short screen: it must be
      // reachable by scrolling the sheet, not clipped away.
      await tester.scrollUntilVisible(find.text('Page scale…'), 80);
      expect(find.text('Locked'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Jump Links'), -80);

      await tester.tap(find.text('Jump Links'));
      await tester.pumpAndSettle();
      expect(chosen, ScoreMenuAction.jumpLinks);
      expect(find.text('Go to'), findsNothing);
    });

    testWidgets('Done leaves the menu without choosing anything', (
      tester,
    ) async {
      var chosen = ScoreMenuAction.bookmarks;
      var closed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  final result = await showScoreMenu(
                    context: context,
                    groups: menu(),
                  );
                  closed = true;
                  if (result != null) chosen = result;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final screen = tester.getSize(find.byType(MaterialApp));
      final sheet = tester.getSize(find.byType(BottomSheet));
      expect(
        sheet.height,
        lessThanOrEqualTo(screen.height),
        reason: 'the sheet must never outgrow its screen',
      );

      // The way out that does not depend on hitting a thin barrier strip.
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(closed, isTrue);
      expect(find.byType(BottomSheet), findsNothing);
      expect(chosen, ScoreMenuAction.bookmarks, reason: 'nothing was chosen');
    });

    testWidgets('a disabled entry cannot be chosen', (tester) async {
      ScoreMenuAction? chosen;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  chosen = await showScoreMenu(
                    context: context,
                    groups: menu(exporting: true),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exporting…'));
      await tester.pumpAndSettle();
      expect(chosen, isNull);
      expect(find.text('Exporting…'), findsOneWidget);
    });
  });

  group('stage preset entry (Spec 0036)', () {
    test('is one entry in Playing, reading the way it will go', () {
      final playing = menu().firstWhere((g) => g.title == 'Playing');
      expect(
        playing.entries.map((e) => e.label).first,
        'Set up to play',
        reason: 'it leads the group a musician reads before a set',
      );

      expect(
        entryFor(
          menu(stagePreset: StagePresetDirection.practise),
          ScoreMenuAction.stagePreset,
        ).label,
        'Set up to practise',
      );
    });
  });
}
