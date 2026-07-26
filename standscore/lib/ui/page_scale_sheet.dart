import 'package:flutter/material.dart';
import 'package:standscore/layout/page_scale.dart';

Future<void> showPageScaleSheet({
  required BuildContext context,
  required PageScalePrefs prefs,
  required String scoreId,
  required int? sourcePage,
  required ValueChanged<PageScalePrefs> onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return _PageScaleSheet(
        initial: prefs,
        scoreId: scoreId,
        sourcePage: sourcePage,
        onChanged: onChanged,
      );
    },
  );
}

class _PageScaleSheet extends StatefulWidget {
  const _PageScaleSheet({
    required this.initial,
    required this.scoreId,
    required this.sourcePage,
    required this.onChanged,
  });

  final PageScalePrefs initial;
  final String scoreId;
  final int? sourcePage;
  final ValueChanged<PageScalePrefs> onChanged;

  @override
  State<_PageScaleSheet> createState() => _PageScaleSheetState();
}

class _PageScaleSheetState extends State<_PageScaleSheet> {
  late PageScalePrefs _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = widget.initial;
  }

  void _update(PageScalePrefs next) {
    setState(() => _prefs = next);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editScale = _prefs.scaleForEdit(
      scoreId: widget.scoreId,
      sourcePage: widget.sourcePage,
    );
    final effective = _prefs.resolve(
      scoreId: widget.scoreId,
      sourcePage: widget.sourcePage,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Page scale', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            // Say what this is before showing knobs: pinch changes the view
            // and forgets; this is remembered (Spec 0036).
            Text(
              'How big the music is drawn, remembered between sessions. '
              'Pinching changes the view for now; this changes it for good.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'On this page right now: ${effective.toStringAsFixed(2)}×',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text('Applies to', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<PageScaleScope>(
              segments: [
                for (final scope in PageScaleScope.values)
                  ButtonSegment(value: scope, label: Text(scope.label)),
              ],
              selected: {_prefs.editScope},
              onSelectionChanged: (selected) {
                _update(_prefs.copyWith(editScope: selected.first));
              },
            ),
            const SizedBox(height: 8),
            Text(
              _scopeHint(_prefs.editScope),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text('Scale', style: theme.textTheme.labelLarge),
                const Spacer(),
                Text('${editScale.toStringAsFixed(2)}×'),
              ],
            ),
            Slider(
              value: editScale,
              min: PageScalePrefs.minScale,
              max: PageScalePrefs.maxScale,
              divisions: 20,
              label: '${editScale.toStringAsFixed(2)}×',
              onChanged: (value) {
                _update(
                  _prefs.withEditedScale(
                    scoreId: widget.scoreId,
                    sourcePage: widget.sourcePage,
                    scale: value,
                  ),
                );
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              // The intent, not the mechanism — the mechanism is the subtitle.
              title: const Text('Keep this scale'),
              subtitle: const Text(
                'Pinch and double-tap are off, so a stray touch mid-piece '
                'cannot move the music',
              ),
              value: _prefs.locked,
              onChanged: (value) => _update(_prefs.copyWith(locked: value)),
            ),
          ],
        ),
      ),
    );
  }
}

/// What each scope covers, in the terms the musician is choosing between.
String _scopeHint(PageScaleScope scope) => switch (scope) {
  PageScaleScope.fixed => 'Every Score, unless one has its own scale',
  PageScaleScope.perScore => 'This Score only, on every page of it',
  PageScaleScope.perPage =>
    'This page only — a dense page can be bigger '
        'without changing the rest',
};
