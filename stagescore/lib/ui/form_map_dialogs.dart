import 'package:flutter/material.dart';
import 'package:stagescore/form_map/form_map.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/theme/app_tokens.dart';

/// Result of the unified repeat + volta dialog.
typedef FormRepeatEdit = ({
  int start,
  int end,
  int times,
  ({int start, int end})? pass1,
  ({int start, int end})? pass2,
});

/// null = dismissed; [kind] null inside the record = clear marker.
Future<({FormMarkerKind? kind})?> pickFormMarker(
  BuildContext context, {
  FormMarkerKind? current,
}) async {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<({FormMarkerKind? kind})>(
    context: context,
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.formMapMarkerNone),
              subtitle: Text(l10n.formMapMarkerNoneDesc),
              selected: current == null,
              onTap: () => Navigator.pop(ctx, (kind: null)),
            ),
            ListTile(
              title: Text(l10n.formMapMarkerSegno),
              subtitle: Text(l10n.formMapMarkerSegnoDesc),
              selected: current == FormMarkerKind.segno,
              onTap: () =>
                  Navigator.pop(ctx, (kind: FormMarkerKind.segno)),
            ),
            ListTile(
              title: Text(l10n.formMapMarkerCoda),
              subtitle: Text(l10n.formMapMarkerCodaDesc),
              selected: current == FormMarkerKind.coda,
              onTap: () => Navigator.pop(ctx, (kind: FormMarkerKind.coda)),
            ),
            ListTile(
              title: Text(l10n.formMapMarkerToCoda),
              subtitle: Text(l10n.formMapMarkerToCodaDesc),
              selected: current == FormMarkerKind.toCoda,
              onTap: () =>
                  Navigator.pop(ctx, (kind: FormMarkerKind.toCoda)),
            ),
            ListTile(
              title: Text(l10n.formMapMarkerFine),
              subtitle: Text(l10n.formMapMarkerFineDesc),
              selected: current == FormMarkerKind.fine,
              onTap: () => Navigator.pop(ctx, (kind: FormMarkerKind.fine)),
            ),
          ],
        ),
      );
    },
  );
}

/// null = dismissed; [kind] null inside the record = clear jump.
Future<({FormJumpKind? kind})?> pickFormJump(
  BuildContext context, {
  FormJumpKind? current,
}) async {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<({FormJumpKind? kind})>(
    context: context,
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.formMapJumpNone),
              subtitle: Text(l10n.formMapJumpNoneDesc),
              selected: current == null,
              onTap: () => Navigator.pop(ctx, (kind: null)),
            ),
            ListTile(
              title: Text(l10n.formMapJumpDaCapo),
              subtitle: Text(l10n.formMapJumpDaCapoDesc),
              selected: current == FormJumpKind.daCapo,
              onTap: () =>
                  Navigator.pop(ctx, (kind: FormJumpKind.daCapo)),
            ),
            ListTile(
              title: Text(l10n.formMapJumpDalSegno),
              subtitle: Text(l10n.formMapJumpDalSegnoDesc),
              selected: current == FormJumpKind.dalSegno,
              onTap: () =>
                  Navigator.pop(ctx, (kind: FormJumpKind.dalSegno)),
            ),
            ListTile(
              title: Text(l10n.formMapJumpToCoda),
              subtitle: Text(l10n.formMapJumpToCodaDesc),
              selected: current == FormJumpKind.toCoda,
              onTap: () =>
                  Navigator.pop(ctx, (kind: FormJumpKind.toCoda)),
            ),
          ],
        ),
      );
    },
  );
}

/// Repeat region + optional 1st / 2nd ending (volta) in one dialog.
Future<FormRepeatEdit?> promptFormRepeat(
  BuildContext context, {
  int? initialStart,
  int? initialEnd,
  int initialTimes = 2,
  ({int start, int end})? initialPass1,
  ({int start, int end})? initialPass2,
}) {
  return showDialog<FormRepeatEdit>(
    context: context,
    builder: (ctx) => _FormRepeatDialog(
      initialStart: initialStart,
      initialEnd: initialEnd,
      initialTimes: initialTimes,
      initialPass1: initialPass1,
      initialPass2: initialPass2,
    ),
  );
}

/// Owns its [TextEditingController]s so dispose runs after the route unmounts
/// (disposing immediately after [showDialog] returns races the exit animation).
class _FormRepeatDialog extends StatefulWidget {
  const _FormRepeatDialog({
    this.initialStart,
    this.initialEnd,
    this.initialTimes = 2,
    this.initialPass1,
    this.initialPass2,
  });

  final int? initialStart;
  final int? initialEnd;
  final int initialTimes;
  final ({int start, int end})? initialPass1;
  final ({int start, int end})? initialPass2;

  @override
  State<_FormRepeatDialog> createState() => _FormRepeatDialogState();
}

class _FormRepeatDialogState extends State<_FormRepeatDialog> {
  late final TextEditingController _startCtrl = TextEditingController(
    text: widget.initialStart?.toString() ?? '',
  );
  late final TextEditingController _endCtrl = TextEditingController(
    text: widget.initialEnd?.toString() ?? '',
  );
  late final TextEditingController _timesCtrl = TextEditingController(
    text: '${widget.initialTimes}',
  );
  late final TextEditingController _pass1StartCtrl = TextEditingController(
    text: widget.initialPass1?.start.toString() ?? '',
  );
  late final TextEditingController _pass1EndCtrl = TextEditingController(
    text: widget.initialPass1?.end.toString() ?? '',
  );
  late final TextEditingController _pass2StartCtrl = TextEditingController(
    text: widget.initialPass2?.start.toString() ?? '',
  );
  late final TextEditingController _pass2EndCtrl = TextEditingController(
    text: widget.initialPass2?.end.toString() ?? '',
  );

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    _timesCtrl.dispose();
    _pass1StartCtrl.dispose();
    _pass1EndCtrl.dispose();
    _pass2StartCtrl.dispose();
    _pass2EndCtrl.dispose();
    super.dispose();
  }

  ({int start, int end})? _optionalRange(
    TextEditingController startCtrl,
    TextEditingController endCtrl,
  ) {
    final startText = startCtrl.text.trim();
    final endText = endCtrl.text.trim();
    if (startText.isEmpty && endText.isEmpty) return null;
    final start = int.tryParse(startText.isEmpty ? endText : startText);
    final end = int.tryParse(endText.isEmpty ? startText : endText);
    if (start == null || end == null || start > end) return null;
    return (start: start, end: end);
  }

  void _submit() {
    final start = int.tryParse(_startCtrl.text.trim());
    final end = int.tryParse(_endCtrl.text.trim());
    final times = int.tryParse(_timesCtrl.text.trim()) ?? 2;
    if (start == null || end == null || start > end || times < 1) return;

    final pass1 = _optionalRange(_pass1StartCtrl, _pass1EndCtrl);
    final pass2 = _optionalRange(_pass2StartCtrl, _pass2EndCtrl);
    // If user typed only one side of a volta range incompletely, reject.
    if ((_pass1StartCtrl.text.trim().isNotEmpty ||
            _pass1EndCtrl.text.trim().isNotEmpty) &&
        pass1 == null) {
      return;
    }
    if ((_pass2StartCtrl.text.trim().isNotEmpty ||
            _pass2EndCtrl.text.trim().isNotEmpty) &&
        pass2 == null) {
      return;
    }

    Navigator.pop(
      context,
      (
        start: start,
        end: end,
        times: times,
        pass1: pass1,
        pass2: pass2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(l10n.formMapAddRepeat),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _startCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.formMapStartMeasure),
            ),
            TextField(
              controller: _endCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.formMapEndMeasure),
            ),
            TextField(
              controller: _timesCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.formMapRepeatTimes),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.formMapVoltaSection,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.formMapVoltaHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.formMapPass1Label,
              style: theme.textTheme.labelLarge,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pass1StartCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.formMapStartMeasure,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _pass1EndCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.formMapEndMeasure,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.formMapPass2Label,
              style: theme.textTheme.labelLarge,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pass2StartCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.formMapStartMeasure,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _pass2EndCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.formMapEndMeasure,
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}

Future<bool> confirmClearFormMap(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.formMapClearTitle),
      content: Text(l10n.formMapClearBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.formMapClearConfirm),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Ask before replacing an existing overlapping repeat region.
Future<bool> confirmReplaceFormRepeat(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.formMapReplaceRepeatTitle),
      content: Text(l10n.formMapReplaceRepeatBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.formMapReplaceConfirm),
        ),
      ],
    ),
  );
  return ok ?? false;
}
