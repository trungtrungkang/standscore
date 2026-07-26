import 'package:flutter/material.dart';
import 'package:stagescore/layout/half_page.dart';
import 'package:stagescore/layout/layout_fit.dart';
import 'package:stagescore/layout/pdf_layout_mode.dart';
import 'package:stagescore/layout/pdf_layout_prefs.dart';
import 'package:stagescore/pageturn/layout_navigation.dart';
import 'package:stagescore/pageturn/page_turn_prefs.dart';

/// Layout picker (Specs 0004 / 0013, rebuilt by 0041).
///
/// Rows rather than chips, because every row has to carry a sentence: what the
/// musician gets, and what their thumb does to turn a page. Six unexplained
/// chips left both answers nowhere in the app.
Future<void> showLayoutSettingsSheet({
  required BuildContext context,
  required PdfLayoutPrefs prefs,
  required PageTurnPrefs pageTurnPrefs,
  required ValueChanged<PdfLayoutPrefs> onChanged,
  VoidCallback? onOpenPageTurnSettings,
}) async {
  var current = prefs;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          void update(PdfLayoutPrefs next) {
            current = next;
            setModalState(() {});
            onChanged(next);
          }

          // The screen is the honest input: it is what the layout has to fit
          // into, and unlike the viewer it does not shrink when chrome appears.
          final fit = LayoutFit(viewSize: MediaQuery.sizeOf(context));
          final resolved = resolveLayoutMode(
            stored: current.mode,
            fit: fit,
            peekRatio: current.halfPageSeparatorRatio,
          );
          final half = isHalfPageLayoutMode(resolved);
          final freePeekPercent = (fit.freePeek * 100).round();

          // Cap, not a fixed height: the sheet ends where its content does
          // (Spec 0035).
          final maxHeight = MediaQuery.sizeOf(context).height * 0.9;
          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              'Layout',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: 12),
                      children: [
                        for (final mode in pickableLayoutModes)
                          _LayoutRow(
                            mode: mode,
                            selected: current.mode == mode,
                            resolvedForAuto: mode == PdfLayoutMode.auto
                                ? fit.recommendedMode(
                                    peekRatio: current.halfPageSeparatorRatio,
                                  )
                                : null,
                            fallsBack:
                                mode == PdfLayoutMode.twoPage &&
                                !fit.spreadFits,
                            recommended:
                                mode ==
                                fit.recommendedMode(
                                  peekRatio: current.halfPageSeparatorRatio,
                                ),
                            pageTurnPrefs: pageTurnPrefs,
                            onSelected: () =>
                                update(current.copyWith(mode: mode)),
                          ),
                        if (half) ...[
                          const Divider(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'How much of the next page peeks in',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  freePeekPercent > 0
                                      ? 'Free up to $freePeekPercent% on this '
                                            'screen — past that the music gets '
                                            'smaller.'
                                      : 'On this screen the peek always makes '
                                            'the music smaller.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          _PeekSlider(
                            ratio: current.halfPageSeparatorRatio,
                            freePeek: fit.freePeek,
                            onChanged: (v) => update(
                              current.copyWith(halfPageSeparatorRatio: v),
                            ),
                          ),
                        ],
                        if (onOpenPageTurnSettings != null) ...[
                          const Divider(height: 24),
                          ListTile(
                            leading: const Icon(Icons.swipe_outlined),
                            title: const Text('Page turn settings'),
                            subtitle: const Text(
                              'Tap zones, swipe, pedal, animation',
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              onOpenPageTurnSettings();
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _LayoutRow extends StatelessWidget {
  const _LayoutRow({
    required this.mode,
    required this.selected,
    required this.resolvedForAuto,
    required this.fallsBack,
    required this.recommended,
    required this.pageTurnPrefs,
    required this.onSelected,
  });

  final PdfLayoutMode mode;
  final bool selected;

  /// What Auto would pick right now — only set on the Auto row.
  final PdfLayoutMode? resolvedForAuto;

  /// This viewport cannot show what the mode asks for.
  final bool fallsBack;
  final bool recommended;
  final PageTurnPrefs pageTurnPrefs;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auto = resolvedForAuto;
    final drawnMode = auto ?? mode;
    // One line, because the sheet has six rows and 0035 does not let a
    // settings surface grow into something that reads as a pushed screen.
    final subtitle = fallsBack
        ? 'One page on this screen — rotate for a spread'
        : [
            if (auto != null) 'Now: ${auto.label}',
            navigationHintFor(drawnMode, pageTurnPrefs),
          ].join(' · ');

    return ListTile(
      dense: true,
      onTap: onSelected,
      selected: selected,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
      ),
      title: Row(
        children: [
          Flexible(child: Text(mode.label)),
          if (recommended) ...[
            const SizedBox(width: 8),
            // Advice, never a lock: every mode stays pickable on every screen.
            Text(
              'fits this screen',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(subtitle),
    );
  }
}

/// Separator slider with the point where the peek stops being free marked on
/// it (Spec 0041). Marked, not clamped — the ratio is the musician's.
class _PeekSlider extends StatelessWidget {
  const _PeekSlider({
    required this.ratio,
    required this.freePeek,
    required this.onChanged,
  });

  final double ratio;
  final double freePeek;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final costs = ratio > freePeek;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Slider(
            value: ratio,
            min: halfPageSeparatorMin,
            max: halfPageSeparatorMax,
            divisions: 40,
            label: '${(ratio * 100).round()}%',
            secondaryTrackValue: freePeek.clamp(
              halfPageSeparatorMin,
              halfPageSeparatorMax,
            ),
            onChanged: onChanged,
          ),
          Text(
            costs
                ? '${(ratio * 100).round()}% — the music is smaller than it '
                      'would be on one page'
                : '${(ratio * 100).round()}% — the music is full size',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
