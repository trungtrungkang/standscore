import 'package:flutter/material.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/ui/draw_icon.dart';
import 'package:stagescore/ui/metronome_icon.dart';
import 'package:stagescore/ui/quick_bar_fit.dart';
import 'package:stagescore/ui/score_menu.dart';

/// Shortcuts for the actions a musician reaches for with the instrument still
/// in their hands (Spec 0043 revision 3).
///
/// The rule matters more than the list, because the list was picked three times
/// by taste before this: an action earns a place in the bottom chrome only if
/// it is wanted *mid-piece*. Bookmarks (the repeat you have to jump to), Draw
/// (the fingering you just got wrong) and the Metronome pass that test. Layout
/// and the View group do not — they are how a Score is set up before playing,
/// and they were also a group sitting beside its own child on one row, so the
/// same sheet had two entrances of different depths. Everything, these three
/// included, still lists in `⋯`, which stays the one place where every action
/// has a name.
///
/// The row's shape comes from [QuickBarFit] rather than from a constant: see
/// [merged] and the labels this draws only when they measure.
class ScoreMenuQuickBar extends StatelessWidget {
  const ScoreMenuQuickBar({
    super.key,
    required this.metronomeRunning,
    required this.metronomeAccent,
    required this.onOpenMetronome,
    required this.drawEnabled,
    required this.onToggleDraw,
    required this.onOpenBookmarks,
    this.fit,
    this.merged = false,
    this.enabled = true,
    this.avoidNotches = true,
  });

  /// How many shortcuts this bar carries, named here because this widget owns
  /// the list — [QuickBarFit] answers for whatever number it is given, so a
  /// later Spec adding a fourth shortcut does not have to touch the geometry.
  static const int slotCount = 3;

  final bool metronomeRunning;

  /// True on the accented beat of the bar. Only a pulse in how the running
  /// icon is tinted — the tint itself says "running".
  final bool metronomeAccent;
  final VoidCallback onOpenMetronome;

  final bool drawEnabled;
  final VoidCallback onToggleDraw;

  final VoidCallback onOpenBookmarks;

  /// Geometry for this screen. Computed from the context when omitted, so the
  /// bar stands on its own; PdfMode passes the fit it already made the [merged]
  /// decision with, so the two can never disagree.
  final QuickBarFit? fit;

  /// Whether these shortcuts are being drawn inside the PageNavBar's row
  /// instead of on one of their own — the shape [QuickBarFit.mergeIntoPageNav]
  /// asks for on a screen too short to stack two rows of chrome.
  ///
  /// Merged, this is a bare row of icons: the bar it rides in owns the surface,
  /// the safe area and the gesture gap, and there is no room for labels beside
  /// a scrubber.
  final bool merged;

  /// False while the Score's prefs are still loading, matching `⋯`: the
  /// shortcuts stay in place and grey out rather than appearing late, which is
  /// what made the whole chrome jump on every Setlist piece change.
  final bool enabled;

  /// When false, sit edge-to-edge over the home indicator (Spec 0032). Only
  /// the bottom-most chrome reserves the inset.
  final bool avoidNotches;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final shortcuts = _shortcuts(l10n, theme);

    if (merged) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final shortcut in shortcuts)
            _QuickBarButton(
              shortcut: shortcut,
              width: kQuickBarMinSlotWidth,
              label: null,
            ),
        ],
      );
    }

    final resolved =
        fit ??
        QuickBarFit(
          screenSize: MediaQuery.sizeOf(context),
          slotCount: slotCount,
          bottomInset: avoidNotches ? MediaQuery.paddingOf(context).bottom : 0,
        );
    final labelStyle =
        theme.textTheme.labelSmall ?? const TextStyle(fontSize: 11);
    final showLabels = quickBarLabelsFit(
      // Every word this row could draw, not just today's: measuring only
      // "Draw" would let the row change shape on entering draw mode, when the
      // musician is least able to afford a moving target.
      labels: shortcuts.expand((s) => s.labels),
      style: labelStyle,
      textScaler: MediaQuery.textScalerOf(context),
      slotWidth: resolved.slotWidth,
    );

    return ExcludeFocus(
      child: Material(
        elevation: 2,
        color: theme.colorScheme.surface,
        child: SafeArea(
          top: false,
          left: avoidNotches,
          right: avoidNotches,
          bottom: avoidNotches,
          child: Padding(
            padding: const EdgeInsets.only(bottom: kQuickBarGestureGap),
            child: SizedBox(
              height: kQuickBarHeight,
              child: Row(
                // Centred as one group of fixed-width slots rather than spread
                // over the width: the shortcuts keep the same spacing on a
                // phone and on a tablet, and starting the metronome no longer
                // shifts the icons beside it (it is always here now).
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final shortcut in shortcuts)
                    _QuickBarButton(
                      shortcut: shortcut,
                      width: resolved.slotWidth,
                      label: showLabels ? shortcut.label : null,
                      labelStyle: labelStyle,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// In the reading order of the `⋯` sheet's groups — Go to, Marks, Playing —
  /// so the two surfaces agree about where a thing lives.
  List<_Shortcut> _shortcuts(AppLocalizations l10n, ThemeData theme) {
    final primary = theme.colorScheme.primary;
    return [
      _Shortcut(
        label: l10n.scoreMenuQuickBarBookmarks,
        icon: const Icon(kBookmarksIcon),
        onPressed: enabled ? onOpenBookmarks : null,
      ),
      _Shortcut(
        label: drawEnabled
            ? l10n.scoreMenuQuickBarExitDraw
            : l10n.scoreMenuQuickBarDraw,
        alternateLabels: [
          l10n.scoreMenuQuickBarDraw,
          l10n.scoreMenuQuickBarExitDraw,
        ],
        icon: const DrawIcon(),
        color: drawEnabled ? primary : null,
        onPressed: enabled ? onToggleDraw : null,
      ),
      _Shortcut(
        // The tooltip and the label say the same word; the state is in the
        // tint, so a running metronome does not need a longer label than a
        // stopped one to say so.
        label: l10n.scoreMenuQuickBarMetronome,
        icon: const MetronomeIcon(),
        // Tinted while running, and a shade stronger on the accented beat.
        // Before this the icon only existed *while* running, which cost the
        // musician the one thing a shortcut is for — starting it — and moved
        // every icon beside it the moment it appeared.
        color: metronomeRunning
            ? (metronomeAccent ? primary : primary.withValues(alpha: 0.55))
            : null,
        tooltip: metronomeRunning
            ? l10n.scoreMenuQuickBarMetronomeRunning
            : l10n.scoreMenuQuickBarMetronome,
        onPressed: enabled ? onOpenMetronome : null,
      ),
    ];
  }
}

/// One shortcut: what it draws, what it is called, what it does.
@immutable
class _Shortcut {
  const _Shortcut({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.alternateLabels = const [],
    this.tooltip,
    this.color,
  });

  final String label;

  /// Every word this slot could show, for measuring — a slot whose label flips
  /// with state must reserve room for the longest of them.
  final List<String> alternateLabels;

  final Widget icon;
  final String? tooltip;

  /// Tint for both the glyph and its label when the shortcut is showing state
  /// (draw mode on, metronome running). Null keeps the ambient icon colour.
  final Color? color;

  final VoidCallback? onPressed;

  Iterable<String> get labels =>
      alternateLabels.isEmpty ? [label] : alternateLabels;
}

class _QuickBarButton extends StatelessWidget {
  const _QuickBarButton({
    required this.shortcut,
    required this.width,
    required this.label,
    this.labelStyle,
  });

  final _Shortcut shortcut;
  final double width;

  /// Null draws the icon alone — either merged into the PageNavBar row, or on
  /// a slot too narrow for the words (see [quickBarLabelsFit]).
  final String? label;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = label;
    final tint = shortcut.onPressed == null
        ? theme.disabledColor
        : shortcut.color;
    final glyph = IconTheme.merge(
      data: IconThemeData(color: tint),
      child: shortcut.icon,
    );
    return IconButton(
      tooltip: shortcut.tooltip ?? shortcut.label,
      onPressed: shortcut.onPressed,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(
        width: width,
        height: kQuickBarHeight,
      ),
      icon: text == null
          ? glyph
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                glyph,
                const SizedBox(height: kQuickBarLabelGap),
                Text(
                  text,
                  maxLines: 1,
                  softWrap: false,
                  style: labelStyle?.copyWith(color: tint),
                ),
              ],
            ),
    );
  }
}
