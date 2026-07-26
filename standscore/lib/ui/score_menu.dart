import 'package:standscore/layout/page_color_filter.dart';
import 'package:standscore/layout/pdf_layout_mode.dart';
import 'package:standscore/layout/stage_preset.dart';

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

/// A row in the ScoreMenu. [value] is the current state shown alongside the
/// label, so the musician can read it without opening the destination.
class ScoreMenuEntry {
  const ScoreMenuEntry({
    required this.action,
    required this.label,
    this.value,
    this.enabled = true,
  });

  final ScoreMenuAction action;
  final String label;
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
        ScoreMenuEntry(action: ScoreMenuAction.bookmarks, label: 'Bookmarks'),
        ScoreMenuEntry(action: ScoreMenuAction.jumpLinks, label: 'Jump Links'),
        // Here rather than under View: it changes what "next page" means.
        ScoreMenuEntry(action: ScoreMenuAction.pageOrder, label: 'Page order…'),
      ],
    ),
    ScoreMenuGroup(
      title: 'Marks',
      entries: [
        ScoreMenuEntry(
          action: ScoreMenuAction.toggleAnnotations,
          label: annotationsVisible ? 'Hide annotations' : 'Show annotations',
        ),
        ScoreMenuEntry(
          action: ScoreMenuAction.exportAnnotated,
          label: exporting ? 'Exporting…' : 'Export PDF with annotations',
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
          value: layoutMenuValue(stored: layoutMode, resolved: resolvedLayout),
        ),
        const ScoreMenuEntry(
          action: ScoreMenuAction.display,
          label: 'Display…',
        ),
        ScoreMenuEntry(
          action: ScoreMenuAction.colorFilter,
          label: 'Color filter…',
          value: colorFilter == PageColorFilterMode.off
              ? null
              : colorFilter.label,
        ),
        ScoreMenuEntry(
          action: ScoreMenuAction.pageScale,
          label: 'Page scale…',
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
        ),
        ScoreMenuEntry(
          action: ScoreMenuAction.metronome,
          label: metronomeRunning ? 'Metronome (running)…' : 'Metronome…',
        ),
        const ScoreMenuEntry(
          action: ScoreMenuAction.pageTurnSettings,
          label: 'Page turn settings',
        ),
      ],
    ),
  ];
}
