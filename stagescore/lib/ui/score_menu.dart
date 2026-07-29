import 'package:flutter/material.dart';
import 'package:stagescore/layout/page_color_filter.dart';
import 'package:stagescore/layout/pdf_layout_mode.dart';
import 'package:stagescore/layout/stage_preset.dart';

/// Everything the ScoreMenu can dispatch (Spec 0035).
///
/// One entry per value, built in [buildScoreMenu]: adding a value without
/// placing it in a group fails `score_menu_test.dart`, so a later Spec cannot
/// half-add a destination.
enum ScoreMenuAction {
  bookmarks,
  jumpLinks,
  pageOrder,
  toggleAnnotations,
  exportAnnotated,
  layout,
  display,
  colorFilter,
  pageScale,
  metronome,
  pageTurnSettings,
  stagePreset,
}

/// The glyph for each [ScoreMenuAction], named once so the `⋯` sheet and the
/// quick-bar shortcuts (Spec 0043) never disagree about which icon means
/// "Bookmarks". Drawn from Material Symbols — already
/// in Flutter, so picking a shape from a catalogue like opensvg.dev never
/// needs a new dependency or a vendored SVG.
const kBookmarksIcon = Icons.bookmarks_outlined;
const kJumpLinksIcon = Icons.link_outlined;
const kPageOrderIcon = Icons.reorder_outlined;
const kAnnotationsVisibleIcon = Icons.visibility_outlined;
const kAnnotationsHiddenIcon = Icons.visibility_off_outlined;
const kExportAnnotatedIcon = Icons.ios_share_outlined;
const kLayoutIcon = Icons.view_column_outlined;
const kDisplayIcon = Icons.settings_display_outlined;
const kColorFilterIcon = Icons.invert_colors_outlined;
const kPageScaleIcon = Icons.zoom_in_outlined;
// Generic fallback only: both the quick-bar and the `⋯` sheet draw Metronome
// with the app's own MetronomeIcon glyph instead of this one — the Material
// stand-in read as unrelated next to it (fixed before G4, Spec 0043
// revision 2). Kept so the model still has *an* IconData for every action.
const kMetronomeIcon = Icons.speed_outlined;
const kPageTurnSettingsIcon = Icons.swipe_outlined;
const kStagePresetIcon = Icons.theater_comedy_outlined;

/// A row in the ScoreMenu. [value] is the current state shown alongside the
/// label, so the musician can read it without opening the destination.
/// [icon] is required: Spec 0043 revision 2 asked for every entry to carry
/// one, in the sheet as much as on any quick-bar shortcut.
class ScoreMenuEntry {
  const ScoreMenuEntry({
    required this.action,
    required this.label,
    required this.icon,
    this.value,
    this.enabled = true,
  });

  final ScoreMenuAction action;
  final String label;
  final IconData icon;
  final String? value;
  final bool enabled;
}

class ScoreMenuGroup {
  const ScoreMenuGroup({required this.title, required this.entries});

  final String title;
  final List<ScoreMenuEntry> entries;
}

/// The ScoreMenu for the Score currently on screen.
///
/// Group names are verbs the musician would say out loud, and each group stays
/// short enough to scan mid-piece (Spec 0035).
/// What the Layout row says without being opened (Specs 0035 / 0041).
///
/// Auto is only honest if it admits what it picked, and a spread that could
/// not fit has to say so where the musician is already looking.
String layoutMenuValue({
  required PdfLayoutMode stored,
  required PdfLayoutMode resolved,
}) {
  if (stored == resolved) return stored.label;
  return '${stored.label} · ${resolved.label}';
}

List<ScoreMenuGroup> buildScoreMenu({
  required PdfLayoutMode layoutMode,
  required PdfLayoutMode resolvedLayout,
  required PageColorFilterMode colorFilter,
  required bool zoomLocked,
  required bool annotationsVisible,
  required bool exporting,
  required bool metronomeRunning,
  required StagePresetDirection stagePreset,
}) {
  return [
    ScoreMenuGroup(
      title: 'Go to',
      entries: const [
        ScoreMenuEntry(
          action: ScoreMenuAction.bookmarks,
          label: 'Bookmarks',
          icon: kBookmarksIcon,
        ),
        ScoreMenuEntry(
          action: ScoreMenuAction.jumpLinks,
          label: 'Jump Links',
          icon: kJumpLinksIcon,
        ),
        // Here rather than under View: it changes what "next page" means.
        ScoreMenuEntry(
          action: ScoreMenuAction.pageOrder,
          label: 'Page order…',
          icon: kPageOrderIcon,
        ),
      ],
    ),
    ScoreMenuGroup(
      title: 'Marks',
      entries: [
        ScoreMenuEntry(
          action: ScoreMenuAction.toggleAnnotations,
          label: annotationsVisible ? 'Hide annotations' : 'Show annotations',
          // Reads as current state, same as the AppBar's own View shortcut:
          // the label says what tapping does, the icon says what is true now.
          icon: annotationsVisible
              ? kAnnotationsVisibleIcon
              : kAnnotationsHiddenIcon,
        ),
        ScoreMenuEntry(
          action: ScoreMenuAction.exportAnnotated,
          label: exporting ? 'Exporting…' : 'Export PDF with annotations',
          icon: kExportAnnotatedIcon,
          enabled: !exporting,
        ),
      ],
    ),
    ScoreMenuGroup(
      title: 'View',
      entries: [
        ScoreMenuEntry(
          action: ScoreMenuAction.layout,
          label: 'Layout',
          icon: kLayoutIcon,
          value: layoutMenuValue(stored: layoutMode, resolved: resolvedLayout),
        ),
        const ScoreMenuEntry(
          action: ScoreMenuAction.display,
          label: 'Display…',
          icon: kDisplayIcon,
        ),
        ScoreMenuEntry(
          action: ScoreMenuAction.colorFilter,
          label: 'Color filter…',
          icon: kColorFilterIcon,
          value: colorFilter == PageColorFilterMode.off
              ? null
              : colorFilter.label,
        ),
        ScoreMenuEntry(
          action: ScoreMenuAction.pageScale,
          label: 'Page scale…',
          icon: kPageScaleIcon,
          value: zoomLocked ? 'Locked' : null,
        ),
      ],
    ),
    ScoreMenuGroup(
      title: 'Playing',
      entries: [
        // One entry, both directions: the label is read off the current prefs
        // rather than a mode the musician could contradict (Spec 0036).
        ScoreMenuEntry(
          action: ScoreMenuAction.stagePreset,
          label: StagePreset.labelFor(stagePreset),
          icon: kStagePresetIcon,
        ),
        ScoreMenuEntry(
          action: ScoreMenuAction.metronome,
          label: metronomeRunning ? 'Metronome (running)…' : 'Metronome…',
          icon: kMetronomeIcon,
        ),
        const ScoreMenuEntry(
          action: ScoreMenuAction.pageTurnSettings,
          label: 'Page turn settings',
          icon: kPageTurnSettingsIcon,
        ),
      ],
    ),
  ];
}
