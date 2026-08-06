import 'package:flutter/material.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/layout/page_scale.dart';
import 'package:stagescore/theme/app_tokens.dart';
import 'package:stagescore/ui/sheet_body.dart';

Future<void> showPageScaleSheet({
  required BuildContext context,
  required PageScalePrefs prefs,
  required String scoreId,
  required int? sourcePage,
  required ValueChanged<PageScalePrefs> onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
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
    final l10n = AppLocalizations.of(context);
    final editScale = _prefs.scaleForEdit(
      scoreId: widget.scoreId,
      sourcePage: widget.sourcePage,
    );
    final effective = _prefs.resolve(
      scoreId: widget.scoreId,
      sourcePage: widget.sourcePage,
    );

    return SheetBody(
      children: [
        Text(l10n.pageScaleSheetTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        // Say what this is before showing knobs: pinch changes the view
        // and forgets; this is remembered (Spec 0036).
        Text(l10n.pageScaleSheetExplainer, style: theme.textTheme.bodySmall),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.pageScaleSheetCurrent(effective.toStringAsFixed(2)),
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.pageScaleSheetAppliesTo, style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<PageScaleScope>(
          segments: [
            for (final scope in PageScaleScope.values)
              ButtonSegment(value: scope, label: Text(scope.label(l10n))),
          ],
          selected: {_prefs.editScope},
          onSelectionChanged: (selected) {
            _update(_prefs.copyWith(editScope: selected.first));
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _scopeHint(l10n, _prefs.editScope),
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Text(l10n.pageScaleSheetScale, style: theme.textTheme.labelLarge),
            const Spacer(),
            Text(l10n.pageScaleSheetScaleValue(editScale.toStringAsFixed(2))),
          ],
        ),
        Slider(
          value: editScale,
          min: PageScalePrefs.minScale,
          max: PageScalePrefs.maxScale,
          divisions: 20,
          label: l10n.pageScaleSheetScaleValue(editScale.toStringAsFixed(2)),
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
          title: Text(l10n.pageScaleSheetKeepScale),
          subtitle: Text(l10n.pageScaleSheetKeepScaleSubtitle),
          value: _prefs.locked,
          onChanged: (value) => _update(_prefs.copyWith(locked: value)),
        ),
      ],
    );
  }
}

/// What each scope covers, in the terms the musician is choosing between.
String _scopeHint(AppLocalizations l10n, PageScaleScope scope) =>
    switch (scope) {
      PageScaleScope.fixed => l10n.pageScaleSheetHintFixed,
      PageScaleScope.perScore => l10n.pageScaleSheetHintPerScore,
      PageScaleScope.perPage => l10n.pageScaleSheetHintPerPage,
    };
