import 'package:flutter/material.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/layout/display_prefs.dart';
import 'package:stagescore/theme/app_tokens.dart';
import 'package:stagescore/ui/sheet_body.dart';

final _borderPresets = <Color>[
  for (final value in DisplayPrefs.borderColorPresetValues) Color(value),
];

Future<void> showDisplaySheet({
  required BuildContext context,
  required DisplayPrefs prefs,
  required ValueChanged<DisplayPrefs> onChanged,
  required String performanceModeHint,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return _DisplaySheet(
        initial: prefs,
        onChanged: onChanged,
        performanceModeHint: performanceModeHint,
      );
    },
  );
}

class _DisplaySheet extends StatefulWidget {
  const _DisplaySheet({
    required this.initial,
    required this.onChanged,
    required this.performanceModeHint,
  });

  final DisplayPrefs initial;
  final ValueChanged<DisplayPrefs> onChanged;

  /// Names the user's own reveal gestures (Spec 0034).
  final String performanceModeHint;

  @override
  State<_DisplaySheet> createState() => _DisplaySheetState();
}

class _DisplaySheetState extends State<_DisplaySheet> {
  late DisplayPrefs _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = widget.initial;
  }

  void _update(DisplayPrefs next) {
    setState(() => _prefs = next);
    widget.onChanged(next);
  }

  Future<void> _pickCustomColor() async {
    var hsv = HSVColor.fromColor(_prefs.borderColor);
    final picked = await showDialog<Color>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.displaySheetBorderColorTitle),
          content: StatefulBuilder(
            builder: (context, setLocal) {
              final color = hsv.toColor();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(l10n.displaySheetHue(hsv.hue.round())),
                  Slider(
                    value: hsv.hue,
                    max: 360,
                    onChanged: (v) => setLocal(() => hsv = hsv.withHue(v)),
                  ),
                  Text(
                    l10n.displaySheetSaturation((hsv.saturation * 100).round()),
                  ),
                  Slider(
                    value: hsv.saturation,
                    onChanged: (v) =>
                        setLocal(() => hsv = hsv.withSaturation(v)),
                  ),
                  Text(l10n.displaySheetColorValue((hsv.value * 100).round())),
                  Slider(
                    value: hsv.value,
                    onChanged: (v) => setLocal(() => hsv = hsv.withValue(v)),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, hsv.toColor()),
              child: Text(l10n.actionOk),
            ),
          ],
        );
      },
    );
    if (picked != null) {
      _update(_prefs.copyWith(borderColorValue: picked.toARGB32()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return SheetBody(
      children: [
        Text(l10n.displaySheetTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.displaySheetPerformanceMode),
          subtitle: Text(widget.performanceModeHint),
          isThreeLine: true,
          value: _prefs.performanceMode,
          onChanged: (v) => _update(_prefs.copyWith(performanceMode: v)),
        ),
        const Divider(),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.displaySheetPageBorder),
          value: _prefs.borderEnabled,
          onChanged: (v) => _update(_prefs.copyWith(borderEnabled: v)),
        ),
        if (_prefs.borderEnabled) ...[
          Text(
            l10n.displaySheetThickness(_prefs.borderWidth.toStringAsFixed(1)),
            style: theme.textTheme.bodySmall,
          ),
          Slider(
            value: _prefs.borderWidth,
            min: DisplayPrefs.minBorderWidth,
            max: DisplayPrefs.maxBorderWidth,
            onChanged: (v) => _update(_prefs.copyWith(borderWidth: v)),
          ),
          Text(l10n.displaySheetColorLabel, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final color in _borderPresets)
                _BorderSwatch(
                  color: color,
                  selected: _prefs.borderColorValue == color.toARGB32(),
                  onTap: () => _update(
                    _prefs.copyWith(borderColorValue: color.toARGB32()),
                  ),
                ),
              ActionChip(
                avatar: const Icon(Icons.palette_outlined, size: 18),
                label: Text(l10n.displaySheetCustomChip),
                onPressed: _pickCustomColor,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const Divider(),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.displaySheetShowStatusBar),
          subtitle: Text(l10n.displaySheetShowStatusBarHint),
          value: _prefs.showStatusBar,
          onChanged: (v) => _update(_prefs.copyWith(showStatusBar: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.displaySheetAvoidNotches),
          subtitle: Text(l10n.displaySheetAvoidNotchesHint),
          value: _prefs.avoidNotches,
          onChanged: (v) => _update(_prefs.copyWith(avoidNotches: v)),
        ),
      ],
    );
  }
}

class _BorderSwatch extends StatelessWidget {
  const _BorderSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.outlineVariant,
            width: selected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}
