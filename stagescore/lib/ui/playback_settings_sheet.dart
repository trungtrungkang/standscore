import 'package:flutter/material.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/sync_map/playback_prefs.dart';
import 'package:stagescore/theme/app_tokens.dart';
import 'package:stagescore/ui/sheet_body.dart';

Future<void> showPlaybackSettingsSheet({
  required BuildContext context,
  required PlaybackPrefs prefs,
  required ValueChanged<PlaybackPrefs> onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return _PlaybackSettingsSheet(initial: prefs, onChanged: onChanged);
    },
  );
}

class _PlaybackSettingsSheet extends StatefulWidget {
  const _PlaybackSettingsSheet({
    required this.initial,
    required this.onChanged,
  });

  final PlaybackPrefs initial;
  final ValueChanged<PlaybackPrefs> onChanged;

  @override
  State<_PlaybackSettingsSheet> createState() => _PlaybackSettingsSheetState();
}

class _PlaybackSettingsSheetState extends State<_PlaybackSettingsSheet> {
  late PlaybackPrefs _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = widget.initial;
  }

  void _update(PlaybackPrefs next) {
    setState(() => _prefs = next);
    widget.onChanged(next);
  }

  Future<void> _pickCustomPlayheadColor() async {
    var hsv = HSVColor.fromColor(_prefs.playheadColor);
    final picked = await showDialog<Color>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.playbackSettingsPlayheadColor),
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
                  const SizedBox(height: AppSpacing.sm),
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
      _update(_prefs.copyWith(playheadColorValue: picked.toARGB32()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return SheetBody(
      children: [
        Text(l10n.playbackSettingsTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.metronomeSheetPlaybackStyle,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.metronomeSheetPlaybackStyleHint,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text(l10n.metronomeSheetPlaybackStyleDocked),
              selected: _prefs.style == PlaybackControlsStyle.docked,
              onSelected: (_) => _update(
                _prefs.copyWith(style: PlaybackControlsStyle.docked),
              ),
            ),
            ChoiceChip(
              label: Text(l10n.metronomeSheetPlaybackStyleFloating),
              selected: _prefs.style == PlaybackControlsStyle.floating,
              onSelected: (_) => _update(
                _prefs.copyWith(style: PlaybackControlsStyle.floating),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.metronomeSheetCountIn,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.metronomeSheetCountInHint,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text(l10n.metronomeSheetCountInNone),
              selected: _prefs.countInMeasures == 0,
              onSelected: (_) =>
                  _update(_prefs.copyWith(countInMeasures: 0)),
            ),
            ChoiceChip(
              label: Text(l10n.metronomeSheetCountInOne),
              selected: _prefs.countInMeasures == 1,
              onSelected: (_) =>
                  _update(_prefs.copyWith(countInMeasures: 1)),
            ),
            ChoiceChip(
              label: Text(l10n.metronomeSheetCountInTwo),
              selected: _prefs.countInMeasures == 2,
              onSelected: (_) =>
                  _update(_prefs.copyWith(countInMeasures: 2)),
            ),
          ],
        ),
        const Divider(height: AppSpacing.xl),
        Text(
          l10n.playbackSettingsPlayhead,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.playbackSettingsPlayheadHint,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        _PlayheadPreview(prefs: _prefs),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.playbackSettingsPlayheadColor,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final value in PlaybackPrefs.playheadColorPresets)
              _PlayheadSwatch(
                color: Color(value),
                selected: _prefs.playheadColorValue == value,
                onTap: () =>
                    _update(_prefs.copyWith(playheadColorValue: value)),
              ),
            ActionChip(
              avatar: const Icon(Icons.palette_outlined, size: 18),
              label: Text(l10n.displaySheetCustomChip),
              onPressed: _pickCustomPlayheadColor,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.playbackSettingsPlayheadSize(
            _prefs.playheadWidth.toStringAsFixed(1),
          ),
          style: theme.textTheme.bodySmall,
        ),
        Slider(
          value: _prefs.playheadWidth,
          min: PlaybackPrefs.minPlayheadWidth,
          max: PlaybackPrefs.maxPlayheadWidth,
          onChanged: (v) => _update(_prefs.copyWith(playheadWidth: v)),
        ),
        Text(
          l10n.playbackSettingsPlayheadHeight(
            (_prefs.playheadHeightScale * 100).round(),
          ),
          style: theme.textTheme.bodySmall,
        ),
        Slider(
          value: _prefs.playheadHeightScale,
          min: PlaybackPrefs.minPlayheadHeightScale,
          max: PlaybackPrefs.maxPlayheadHeightScale,
          onChanged: (v) =>
              _update(_prefs.copyWith(playheadHeightScale: v)),
        ),
        Text(
          l10n.playbackSettingsPlayheadOpacity(
            (_prefs.playheadOpacity * 100).round(),
          ),
          style: theme.textTheme.bodySmall,
        ),
        Slider(
          value: _prefs.playheadOpacity,
          min: PlaybackPrefs.minPlayheadOpacity,
          max: PlaybackPrefs.maxPlayheadOpacity,
          onChanged: (v) => _update(_prefs.copyWith(playheadOpacity: v)),
        ),
      ],
    );
  }
}

class _PlayheadPreview extends StatelessWidget {
  const _PlayheadPreview({required this.prefs});

  final PlaybackPrefs prefs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: CustomPaint(
        painter: _PreviewPainter(
          color: prefs.playheadPaintColor,
          strokeWidth: prefs.playheadWidth,
          heightScale: prefs.playheadHeightScale,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PreviewPainter extends CustomPainter {
  _PreviewPainter({
    required this.color,
    required this.strokeWidth,
    required this.heightScale,
  });

  final Color color;
  final double strokeWidth;
  final double heightScale;

  @override
  void paint(Canvas canvas, Size size) {
    // Band = MeasureBox at 100%; playhead grows from its centre.
    final bandTop = size.height * 0.28;
    final bandHeight = size.height * 0.44;
    final bandPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(12, bandTop, size.width - 24, bandHeight),
        const Radius.circular(4),
      ),
      bandPaint,
    );

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final x = size.width * 0.5;
    final lineHeight = bandHeight * heightScale.clamp(1.0, 2.0);
    final lineTop = bandTop - (lineHeight - bandHeight) / 2;
    canvas.drawLine(
      Offset(x, lineTop),
      Offset(x, lineTop + lineHeight),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PreviewPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.heightScale != heightScale;
}

class _PlayheadSwatch extends StatelessWidget {
  const _PlayheadSwatch({
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
