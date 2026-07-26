import 'package:flutter/material.dart';
import 'package:stagescore/layout/display_prefs.dart';

const _borderPresets = <Color>[
  Color(DisplayPrefs.defaultBorderColorValue),
  Color(0xFF000000),
  Color(0xFF0D8B86),
  Color(0xFFB45309),
];

Future<void> showDisplaySheet({
  required BuildContext context,
  required DisplayPrefs prefs,
  required ValueChanged<DisplayPrefs> onChanged,
  required String performanceModeHint,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
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
        return AlertDialog(
          title: const Text('Border color'),
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
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Hue ${hsv.hue.round()}'),
                  Slider(
                    value: hsv.hue,
                    max: 360,
                    onChanged: (v) => setLocal(() => hsv = hsv.withHue(v)),
                  ),
                  Text('Sat ${(hsv.saturation * 100).round()}%'),
                  Slider(
                    value: hsv.saturation,
                    onChanged: (v) =>
                        setLocal(() => hsv = hsv.withSaturation(v)),
                  ),
                  Text('Val ${(hsv.value * 100).round()}%'),
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
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, hsv.toColor()),
              child: const Text('OK'),
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Display', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Performance mode'),
              subtitle: Text(widget.performanceModeHint),
              isThreeLine: true,
              value: _prefs.performanceMode,
              onChanged: (v) => _update(_prefs.copyWith(performanceMode: v)),
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Page border'),
              value: _prefs.borderEnabled,
              onChanged: (v) => _update(_prefs.copyWith(borderEnabled: v)),
            ),
            if (_prefs.borderEnabled) ...[
              Text(
                'Thickness ${_prefs.borderWidth.toStringAsFixed(1)}',
                style: theme.textTheme.bodySmall,
              ),
              Slider(
                value: _prefs.borderWidth,
                min: DisplayPrefs.minBorderWidth,
                max: DisplayPrefs.maxBorderWidth,
                onChanged: (v) => _update(_prefs.copyWith(borderWidth: v)),
              ),
              Text('Color', style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
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
                    label: const Text('Custom'),
                    onPressed: _pickCustomColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show status bar'),
              subtitle: const Text('Clock and system icons at the top'),
              value: _prefs.showStatusBar,
              onChanged: (v) => _update(_prefs.copyWith(showStatusBar: v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Avoid notches and bars'),
              subtitle: const Text('Keep the Score clear of cutouts'),
              value: _prefs.avoidNotches,
              onChanged: (v) => _update(_prefs.copyWith(avoidNotches: v)),
            ),
          ],
        ),
      ),
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
