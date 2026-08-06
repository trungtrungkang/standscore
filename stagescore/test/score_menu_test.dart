import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/layout/page_color_filter.dart';
import 'package:stagescore/layout/pdf_layout_mode.dart';
import 'package:stagescore/layout/stage_preset.dart';
import 'package:stagescore/ui/score_menu.dart';
import 'package:stagescore/ui/score_menu_sheet.dart';

import 'support/test_l10n.dart';

late AppLocalizations _l10n;

List<ScoreMenuGroup> menu({
  PdfLayoutMode layoutMode = PdfLayoutMode.single,
  PdfLayoutMode? resolvedLayout,
  PageColorFilterMode colorFilter = PageColorFilterMode.off,
  bool zoomLocked = false,
  bool annotationsVisible = true,
  bool exporting = false,
  bool metronomeRunning = false,
  bool playbackControlsVisible = false,
  bool measureMapReady = true,
  StagePresetDirection stagePreset = StagePresetDirection.play,
}) {
  return buildScoreMenu(
    l10n: _l10n,
    layoutMode: layoutMode,
    resolvedLayout: resolvedLayout ?? layoutMode,
    colorFilter: colorFilter,
    zoomLocked: zoomLocked,
    annotationsVisible: annotationsVisible,
    exporting: exporting,
    metronomeRunning: metronomeRunning,
    playbackControlsVisible: playbackControlsVisible,
    measureMapReady: measureMapReady,
    stagePreset: stagePreset,
  );
}

Iterable<ScoreMenuEntry> entriesOf(List<ScoreMenuGroup> groups) =>
    groups.expand((g) => g.entries);

ScoreMenuEntry entryFor(List<ScoreMenuGroup> groups, ScoreMenuAction action) =>
    entriesOf(groups).firstWhere((e) => e.action == action);

/// [MaterialApp] with localization wired, for widgets under test that call
/// `AppLocalizations.of(context)` (`_ScoreMenuSheet`).
Widget _app(Widget home) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void main() {
  setUpAll(() async {
    _l10n = await testL10n();
  });

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
        // Playing is allowed 5: Stage / Metronome / Show-Hide Playback /
        // Playback settings / Page turn (Spec 0059 G4).
        final max = group.title == 'Playing' ? 5 : 4;
        expect(group.entries.length, lessThanOrEqualTo(max), reason: group.title);
      }
    });

    test('Layout always shows the current mode', () {
      expect(entryFor(menu(), ScoreMenuAction.layout).value, 'One page');
      expect(
        entryFor(
          menu(layoutMode: PdfLayoutMode.halfPageLeftRight),
          ScoreMenuAction.layout,
        ).value,
        'One page + side peek',
      );
    });

    test('Layout admits when the screen picked something else (0041)', () {
      expect(
        entryFor(
          menu(
            layoutMode: PdfLayoutMode.auto,
            resolvedLayout: PdfLayoutMode.twoPage,
          ),
          ScoreMenuAction.layout,
        ).value,
        'Auto · Two pages',
      );
      expect(
        entryFor(
          menu(
            layoutMode: PdfLayoutMode.twoPage,
            resolvedLayout: PdfLayoutMode.single,
          ),
          ScoreMenuAction.layout,
        ).value,
        'Two pages · One page',
        reason: 'a spread that did not fit must say so where it is read',
      );
    });

    test('Color filter and Page scale show state only when set', () {
      final off = menu();
      expect(entryFor(off, ScoreMenuAction.colorFilter).value, isNull);
      expect(entryFor(off, ScoreMenuAction.pageScale).value, isNull);

      final on = menu(colorFilter: PageColorFilterMode.sepia, zoomLocked: true);
      expect(
        entryFor(on, ScoreMenuAction.colorFilter).value,
        PageColorFilterMode.sepia.label(_l10n),
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

    test('the annotations icon reads as current state, not the tap ahead', () {
      expect(
        entryFor(menu(), ScoreMenuAction.toggleAnnotations).icon,
        kAnnotationsVisibleIcon,
        reason: 'default is visible, label offers to hide them',
      );
      expect(
        entryFor(
          menu(annotationsVisible: false),
          ScoreMenuAction.toggleAnnotations,
        ).icon,
        kAnnotationsHiddenIcon,
      );
    });
  });

  group('showScoreMenu', () {
    testWidgets('returns the tapped action and closes', (tester) async {
      ScoreMenuAction? chosen;
      var opened = false;
      await tester.pumpWidget(
        _app(
          Scaffold(
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
      // Playback controls (0059) adds a Playing row — scroll farther back up.
      await tester.scrollUntilVisible(find.text('Jump Links'), -120);

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
        _app(
          Scaffold(
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
        _app(
          Scaffold(
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

  group('Playback controls entry (Spec 0059)', () {
    test('toggles Show/Hide label and disables when MeasureMap empty', () {
      expect(
        entryFor(menu(), ScoreMenuAction.togglePlaybackControls).label,
        'Show Playback controls',
      );
      expect(
        entryFor(
          menu(playbackControlsVisible: true),
          ScoreMenuAction.togglePlaybackControls,
        ).label,
        'Hide Playback controls',
      );
      final disabled = entryFor(
        menu(measureMapReady: false),
        ScoreMenuAction.togglePlaybackControls,
      );
      expect(disabled.enabled, isFalse);
      expect(disabled.value, 'Map measures first');
    });

    test('Playback settings is always available', () {
      final entry = entryFor(menu(), ScoreMenuAction.playbackSettings);
      expect(entry.label, 'Playback settings…');
      expect(entry.enabled, isTrue);
    });
  });
}
