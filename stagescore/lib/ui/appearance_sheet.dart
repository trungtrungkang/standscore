import 'package:flutter/material.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/theme/app_appearance.dart';
import 'package:stagescore/theme/app_tokens.dart';

Future<void> showAppearanceSheet({
  required BuildContext context,
  required AppAppearance appearance,
  required ValueChanged<AppAppearance> onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return _AppearanceSheet(initial: appearance, onChanged: onChanged);
    },
  );
}

class _AppearanceSheet extends StatefulWidget {
  const _AppearanceSheet({required this.initial, required this.onChanged});

  final AppAppearance initial;
  final ValueChanged<AppAppearance> onChanged;

  @override
  State<_AppearanceSheet> createState() => _AppearanceSheetState();
}

class _AppearanceSheetState extends State<_AppearanceSheet> {
  late AppAppearance _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initial;
  }

  void _update(AppAppearance next) {
    setState(() => _current = next);
    widget.onChanged(next);
  }

  Future<void> _pickCustomColor() async {
    final picked = await showDialog<Color>(
      context: context,
      builder: (context) => _CustomColorDialog(initial: _current.seedColor),
    );
    if (picked == null) return;
    _update(_current.copyWith(seedColorValue: picked.toARGB32()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.appearanceSheetTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.appearanceSheetMode, style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<AppThemeMode>(
              segments: [
                for (final mode in AppThemeMode.values)
                  ButtonSegment(value: mode, label: Text(mode.label(l10n))),
              ],
              selected: {_current.mode},
              onSelectionChanged: (selected) {
                _update(_current.copyWith(mode: selected.first));
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.appearanceSheetThemeColor,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final value in AppAppearance.presetSeedValues)
                  _AccentSwatch(
                    color: Color(value),
                    selected: _current.seedColorValue == value,
                    onTap: () =>
                        _update(_current.copyWith(seedColorValue: value)),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.palette_outlined, size: 18),
                  label: Text(l10n.appearanceSheetCustomChip),
                  onPressed: _pickCustomColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
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
        width: 40,
        height: 40,
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
        child: selected
            ? Icon(
                Icons.check,
                size: 20,
                color:
                    ThemeData.estimateBrightnessForColor(color) ==
                        Brightness.dark
                    ? Colors.white
                    : Colors.black,
              )
            : null,
      ),
    );
  }
}

class _CustomColorDialog extends StatefulWidget {
  const _CustomColorDialog({required this.initial});

  final Color initial;

  @override
  State<_CustomColorDialog> createState() => _CustomColorDialogState();
}

class _CustomColorDialogState extends State<_CustomColorDialog> {
  late HSVColor _hsv;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    final color = _hsv.toColor();
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.appearanceSheetCustomColorDialog),
      content: Column(
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
          _SliderRow(
            label: l10n.appearanceSheetHue,
            value: _hsv.hue,
            max: 360,
            onChanged: (v) => setState(() => _hsv = _hsv.withHue(v)),
          ),
          _SliderRow(
            label: l10n.appearanceSheetSat,
            value: _hsv.saturation,
            max: 1,
            onChanged: (v) => setState(() => _hsv = _hsv.withSaturation(v)),
          ),
          _SliderRow(
            label: l10n.appearanceSheetVal,
            value: _hsv.value,
            max: 1,
            onChanged: (v) => setState(() => _hsv = _hsv.withValue(v)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, color),
          child: Text(l10n.actionApply),
        ),
      ],
    );
  }
}

/// Width the value label of a slider row reserves. A measurement, not a step:
/// it is as wide as the longest label these rows show, so the sliders below
/// each other start at the same x.
const double _sliderValueLabelWidth = 36;

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: _sliderValueLabelWidth, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.clamp(0, max),
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
