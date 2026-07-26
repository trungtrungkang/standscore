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
            Text(
              'Effective on this page: ${effective.toStringAsFixed(2)}×',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text('Scope', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<PageScaleScope>(
              segments: [
                for (final scope in PageScaleScope.values)
                  ButtonSegment(
                    value: scope,
                    label: Text(scope.label),
                  ),
              ],
              selected: {_prefs.editScope},
              onSelectionChanged: (selected) {
                _update(_prefs.copyWith(editScope: selected.first));
              },
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
              title: const Text('Lock zoom'),
              subtitle: const Text('Disables pinch and double-tap scale'),
              value: _prefs.locked,
              onChanged: (value) => _update(_prefs.copyWith(locked: value)),
            ),
          ],
        ),
      ),
    );
  }
}
