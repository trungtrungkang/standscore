import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/layout/page_color_filter.dart';
import 'package:stagescore/layout/pdf_layout_mode.dart';
import 'package:stagescore/layout/stage_preset.dart';
import 'package:stagescore/ui/score_menu.dart';
import 'package:stagescore/ui/score_menu_sheet.dart';

import 'support/test_l10n.dart';

/// Where a piece came from, in the one place a musician can reach mid-piece
/// (Spec 0052).
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await testL10n();
  });

  Future<void> pumpMenu(WidgetTester tester, {String? subtitle}) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showScoreMenu(
                context: context,
                subtitle: subtitle,
                groups: buildScoreMenu(
                  l10n: l10n,
                  layoutMode: PdfLayoutMode.single,
                  resolvedLayout: PdfLayoutMode.single,
                  colorFilter: PageColorFilterMode.off,
                  zoomLocked: false,
                  annotationsVisible: true,
                  exporting: false,
                  metronomeRunning: false,
                  playbackControlsVisible: false,
                  measureMapReady: true,
                  stagePreset: StagePresetDirection.play,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('a piece of a book says which pages of which file it is', (
    tester,
  ) async {
    await pumpMenu(tester, subtitle: 'Pages 12–19 of Chopin Etudes.pdf');

    expect(find.text('Menu'), findsOneWidget);
    expect(find.text('Pages 12–19 of Chopin Etudes.pdf'), findsOneWidget);
  });

  testWidgets('a Score that is a whole file says nothing extra', (
    tester,
  ) async {
    await pumpMenu(tester);

    expect(find.text('Menu'), findsOneWidget);
    expect(
      find.textContaining('Pages'),
      findsNothing,
      reason: 'someone who never split anything sees the menu they had',
    );
  });
}
