import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/layout/display_prefs.dart';
import 'package:stagescore/layout/page_scale.dart';
import 'package:stagescore/layout/stage_preset.dart';

import 'support/test_l10n.dart';

void main() {
  const practising = DisplayPrefs(performanceMode: false, showStatusBar: true);
  const playing = DisplayPrefs(performanceMode: true, showStatusBar: false);
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await testL10n();
  });

  group('directionFor', () {
    test('offers the way back only from the exact play shape', () {
      expect(
        StagePreset.directionFor(
          display: playing,
          scale: const PageScalePrefs(locked: true),
        ),
        StagePresetDirection.practise,
      );
    });

    test('a half-set-up app is offered the rest of the way', () {
      // Chrome down but pinch still live: not ready, so finish the job.
      expect(
        StagePreset.directionFor(
          display: playing,
          scale: const PageScalePrefs(),
        ),
        StagePresetDirection.play,
      );
      expect(
        StagePreset.directionFor(
          display: practising,
          scale: const PageScalePrefs(locked: true),
        ),
        StagePresetDirection.play,
      );
    });

    test('follows switches flipped by hand — there is no mode to disagree', () {
      const before = PageScalePrefs(locked: true);
      expect(
        StagePreset.directionFor(display: playing, scale: before),
        StagePresetDirection.practise,
      );
      // Musician turns Performance mode off in the Display sheet.
      expect(
        StagePreset.directionFor(
          display: playing.copyWith(performanceMode: false),
          scale: before,
        ),
        StagePresetDirection.play,
      );
    });
  });

  group('applying', () {
    test('play hides the chrome and the status bar, and keeps the scale', () {
      final display = StagePreset.applyToDisplay(
        practising,
        StagePresetDirection.play,
      );
      final scale = StagePreset.applyToScale(
        const PageScalePrefs(),
        StagePresetDirection.play,
      );

      expect(display.performanceMode, isTrue);
      expect(display.showStatusBar, isFalse);
      expect(scale.locked, isTrue);
    });

    test('practise brings them back and frees pinch', () {
      final display = StagePreset.applyToDisplay(
        playing,
        StagePresetDirection.practise,
      );
      final scale = StagePreset.applyToScale(
        const PageScalePrefs(locked: true),
        StagePresetDirection.practise,
      );

      expect(display.performanceMode, isFalse);
      expect(display.showStatusBar, isTrue);
      expect(scale.locked, isFalse);
    });

    test('nothing outside the bundle is touched', () {
      const before = DisplayPrefs(
        borderEnabled: true,
        borderWidth: 4,
        avoidNotches: false,
        performanceHintShown: true,
      );
      final after = StagePreset.applyToDisplay(
        before,
        StagePresetDirection.play,
      );

      expect(after.borderEnabled, isTrue);
      expect(after.borderWidth, 4);
      expect(after.avoidNotches, isFalse);
      expect(after.performanceHintShown, isTrue);
    });

    test('a scale the musician chose survives the preset', () {
      const before = PageScalePrefs(
        fixedScale: 1.25,
        editScope: PageScaleScope.perScore,
        scoreScales: {'a': 1.4},
        pageScales: {'a:3': 0.8},
      );

      final after = StagePreset.applyToScale(before, StagePresetDirection.play);

      expect(after.locked, isTrue);
      expect(after.fixedScale, 1.25);
      expect(after.editScope, PageScaleScope.perScore);
      expect(after.scoreScales, {'a': 1.4});
      expect(after.pageScales, {'a:3': 0.8});
    });

    test('applying twice in the same direction changes nothing further', () {
      final once = StagePreset.applyToDisplay(
        practising,
        StagePresetDirection.play,
      );
      final twice = StagePreset.applyToDisplay(once, StagePresetDirection.play);
      expect(twice, once);
    });
  });

  group('changes', () {
    test('names what moved, for the Undo snackbar', () {
      expect(
        StagePreset.changes(
          l10n: l10n,
          beforeDisplay: practising,
          beforeScale: const PageScalePrefs(),
          afterDisplay: StagePreset.applyToDisplay(
            practising,
            StagePresetDirection.play,
          ),
          afterScale: StagePreset.applyToScale(
            const PageScalePrefs(),
            StagePresetDirection.play,
          ),
        ),
        ['chrome hidden', 'status bar hidden', 'scale kept'],
      );
    });

    test('is empty when the preset was a no-op', () {
      expect(
        StagePreset.changes(
          l10n: l10n,
          beforeDisplay: playing,
          beforeScale: const PageScalePrefs(locked: true),
          afterDisplay: playing,
          afterScale: const PageScalePrefs(locked: true),
        ),
        isEmpty,
      );
    });
  });
}
