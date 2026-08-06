import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/layout/display_prefs.dart';
import 'package:stagescore/layout/page_scale.dart';

/// Which way the one preset entry is pointing (Spec 0036).
enum StagePresetDirection {
  /// Chrome down, status bar hidden, scale kept: about to play.
  play,

  /// Chrome up, status bar back, pinch free: marking up a part.
  practise,
}

/// The settings a musician changes on their way to and from the stand.
///
/// Deliberately **not** a mode. Nothing here is persisted about the preset
/// itself: it writes the same prefs the individual switches write, and
/// [directionFor] reads those prefs back to decide what to offer next. So a
/// musician who flips one switch by hand has not put the app in a state the
/// preset disagrees with — there is nothing to disagree with (Spec 0036).
///
/// Scope is narrow on purpose: page scale, layout, page order, colour filter
/// and borders are taste, not stage readiness, and a preset that overwrote a
/// scale the musician chose would be a bug wearing a feature's clothes.
class StagePreset {
  const StagePreset._();

  /// What the entry offers next, given where the settings already are.
  ///
  /// Only an exact match for the play shape offers the way back; anything
  /// partial offers to finish the job.
  static StagePresetDirection directionFor({
    required DisplayPrefs display,
    required PageScalePrefs scale,
  }) {
    final ready =
        display.performanceMode && !display.showStatusBar && scale.locked;
    return ready ? StagePresetDirection.practise : StagePresetDirection.play;
  }

  static String labelFor(AppLocalizations l10n, StagePresetDirection direction) =>
      switch (direction) {
        StagePresetDirection.play => l10n.stagePresetSetUpToPlay,
        StagePresetDirection.practise => l10n.stagePresetSetUpToPractise,
      };

  static DisplayPrefs applyToDisplay(
    DisplayPrefs display,
    StagePresetDirection direction,
  ) {
    final play = direction == StagePresetDirection.play;
    return display.copyWith(performanceMode: play, showStatusBar: !play);
  }

  static PageScalePrefs applyToScale(
    PageScalePrefs scale,
    StagePresetDirection direction,
  ) {
    return scale.copyWith(locked: direction == StagePresetDirection.play);
  }

  /// What just changed, for the Undo snackbar — empty when the preset was a
  /// no-op, which is the case worth not bragging about.
  static List<String> changes({
    required AppLocalizations l10n,
    required DisplayPrefs beforeDisplay,
    required PageScalePrefs beforeScale,
    required DisplayPrefs afterDisplay,
    required PageScalePrefs afterScale,
  }) {
    return [
      if (beforeDisplay.performanceMode != afterDisplay.performanceMode)
        afterDisplay.performanceMode
            ? l10n.stagePresetChromeHidden
            : l10n.stagePresetChromeShown,
      if (beforeDisplay.showStatusBar != afterDisplay.showStatusBar)
        afterDisplay.showStatusBar
            ? l10n.stagePresetStatusBarShown
            : l10n.stagePresetStatusBarHidden,
      if (beforeScale.locked != afterScale.locked)
        afterScale.locked ? l10n.stagePresetScaleKept : l10n.stagePresetPinchFree,
    ];
  }
}
