import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/metronome/metronome_engine.dart';
import 'package:stagescore/metronome/metronome_prefs.dart';
import 'package:stagescore/theme/app_tokens.dart';
import 'package:stagescore/ui/beat_dots.dart';
import 'package:stagescore/ui/metronome_icon.dart';
import 'package:stagescore/ui/sheet_body.dart';

Future<void> showMetronomeSheet({
  required BuildContext context,
  required MetronomeEngine engine,
  required ValueChanged<MetronomePrefs> onPrefsChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return _MetronomeSheet(
        engine: engine,
        onPrefsChanged: onPrefsChanged,
      );
    },
  );
}

class _MetronomeSheet extends StatefulWidget {
  const _MetronomeSheet({
    required this.engine,
    required this.onPrefsChanged,
  });

  final MetronomeEngine engine;
  final ValueChanged<MetronomePrefs> onPrefsChanged;

  @override
  State<_MetronomeSheet> createState() => _MetronomeSheetState();
}

class _MetronomeSheetState extends State<_MetronomeSheet> {
  late MetronomePrefs _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = widget.engine.prefs;
    widget.engine.addListener(_onEngine);
  }

  @override
  void dispose() {
    widget.engine.removeListener(_onEngine);
    super.dispose();
  }

  void _onEngine() {
    if (mounted) setState(() {});
  }

  void _update(MetronomePrefs next) {
    setState(() => _prefs = next);
    widget.onPrefsChanged(next);
  }

  Future<void> _editTempo() async {
    final value = await showDialog<int>(
      context: context,
      builder: (context) => _TempoDialog(initialBpm: _prefs.tempoBpm),
    );
    if (!mounted || value == null) return;
    _update(_prefs.copyWith(tempoBpm: value));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final engine = widget.engine;
    return SheetBody(
      children: [
        Row(
          children: [
            const MetronomeIcon(size: 28),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                l10n.metronomeSheetTitle,
                style: theme.textTheme.titleLarge,
              ),
            ),
            BeatDots(
              beatsPerBar: _prefs.beatsPerBar,
              activeBeat: engine.isRunning ? engine.beatInBar : null,
              accent: engine.isRunning && engine.isAccent,
              equalBeats: !_prefs.accentEnabled,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Text(l10n.metronomeSheetTempo, style: theme.textTheme.titleSmall),
            const Spacer(),
            TextButton(
              onPressed: _editTempo,
              child: Text('${_prefs.tempoBpm} BPM'),
            ),
          ],
        ),
        Slider(
          value: _prefs.tempoBpm.toDouble(),
          min: MetronomePrefs.minTempo.toDouble(),
          max: MetronomePrefs.maxTempo.toDouble(),
          divisions: MetronomePrefs.maxTempo - MetronomePrefs.minTempo,
          label: '${_prefs.tempoBpm}',
          onChanged: (v) => _update(_prefs.copyWith(tempoBpm: v.round())),
        ),
        Text(l10n.metronomeSheetMeter, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.metronomeSheetMeterHint, style: theme.textTheme.bodySmall),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(l10n.metronomeSheetEqual),
              selected: !_prefs.accentEnabled,
              onSelected: (_) => _update(_prefs.copyWith(accentEnabled: false)),
            ),
            for (final meter in MetronomePrefs.meterChoices)
              ChoiceChip(
                label: Text(meter.label),
                selected: _prefs.accentEnabled && _prefs.selectedMeter == meter,
                onSelected: (_) => _update(_prefs.withMeter(meter)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.metronomeSheetMute),
          value: _prefs.muted,
          onChanged: (v) => _update(_prefs.copyWith(muted: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.metronomeSheetShowBeats),
          subtitle: Text(l10n.metronomeSheetShowBeatsHint),
          value: _prefs.showBeatsOnScore,
          onChanged: (v) => _update(_prefs.copyWith(showBeatsOnScore: v)),
        ),
        if (!_prefs.muted) ...[
          Text(
            l10n.metronomeSheetVolume((_prefs.volume * 100).round()),
            style: theme.textTheme.titleSmall,
          ),
          Slider(
            value: _prefs.volume,
            onChanged: (v) => _update(_prefs.copyWith(volume: v)),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        FilledButton.icon(
          onPressed: () => engine.toggle(),
          icon: Icon(engine.isRunning ? Icons.stop : Icons.play_arrow),
          label: Text(
            engine.isRunning
                ? l10n.metronomeSheetStop
                : l10n.metronomeSheetStart,
          ),
        ),
      ],
    );
  }
}

/// Owns its [TextEditingController] so dispose happens after the route unmounts
/// (disposing immediately after [showDialog] returns races the exit animation).
class _TempoDialog extends StatefulWidget {
  const _TempoDialog({required this.initialBpm});

  final int initialBpm;

  @override
  State<_TempoDialog> createState() => _TempoDialogState();
}

class _TempoDialogState extends State<_TempoDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.initialBpm}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(AppLocalizations l10n) {
    final n = int.tryParse(_controller.text.trim());
    if (n == null) {
      setState(() => _error = l10n.metronomeSheetEnterNumber);
      return;
    }
    if (n < MetronomePrefs.minTempo || n > MetronomePrefs.maxTempo) {
      setState(
        () => _error =
            '${MetronomePrefs.minTempo}–${MetronomePrefs.maxTempo} BPM',
      );
      return;
    }
    Navigator.pop(context, n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.metronomeSheetTempoDialogTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: '${MetronomePrefs.minTempo}–${MetronomePrefs.maxTempo}',
          errorText: _error,
        ),
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        onSubmitted: (_) => _submit(l10n),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => _submit(l10n),
          child: Text(l10n.actionOk),
        ),
      ],
    );
  }
}
