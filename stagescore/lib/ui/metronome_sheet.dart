import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stagescore/metronome/metronome_engine.dart';
import 'package:stagescore/metronome/metronome_prefs.dart';
import 'package:stagescore/ui/metronome_icon.dart';

Future<void> showMetronomeSheet({
  required BuildContext context,
  required MetronomeEngine engine,
  required ValueChanged<MetronomePrefs> onPrefsChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return _MetronomeSheet(engine: engine, onPrefsChanged: onPrefsChanged);
    },
  );
}

class _MetronomeSheet extends StatefulWidget {
  const _MetronomeSheet({required this.engine, required this.onPrefsChanged});

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
    final engine = widget.engine;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const MetronomeIcon(size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Metronome', style: theme.textTheme.titleLarge),
                ),
                _BeatDots(
                  beatsPerBar: _prefs.beatsPerBar,
                  activeBeat: engine.isRunning ? engine.beatInBar : null,
                  accent: engine.isRunning && engine.isAccent,
                  equalBeats: !_prefs.accentEnabled,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Tempo', style: theme.textTheme.titleSmall),
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
            Text('Meter', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'Equal = same click every beat. Labels group accents; tempo is BPM.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Equal'),
                  selected: !_prefs.accentEnabled,
                  onSelected: (_) =>
                      _update(_prefs.copyWith(accentEnabled: false)),
                ),
                for (final meter in MetronomePrefs.meterChoices)
                  ChoiceChip(
                    label: Text(meter.label),
                    selected:
                        _prefs.accentEnabled && _prefs.selectedMeter == meter,
                    onSelected: (_) => _update(_prefs.withMeter(meter)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mute (visual only)'),
              value: _prefs.muted,
              onChanged: (v) => _update(_prefs.copyWith(muted: v)),
            ),
            if (!_prefs.muted) ...[
              Text(
                'Volume ${(_prefs.volume * 100).round()}%',
                style: theme.textTheme.titleSmall,
              ),
              Slider(
                value: _prefs.volume,
                onChanged: (v) => _update(_prefs.copyWith(volume: v)),
              ),
            ],
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => engine.toggle(),
              icon: Icon(engine.isRunning ? Icons.stop : Icons.play_arrow),
              label: Text(engine.isRunning ? 'Stop' : 'Start'),
            ),
          ],
        ),
      ),
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

  void _submit() {
    final n = int.tryParse(_controller.text.trim());
    if (n == null) {
      setState(() => _error = 'Enter a number');
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
    return AlertDialog(
      title: const Text('Tempo (BPM)'),
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
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('OK')),
      ],
    );
  }
}

class _BeatDots extends StatelessWidget {
  const _BeatDots({
    required this.beatsPerBar,
    required this.activeBeat,
    required this.accent,
    this.equalBeats = false,
  });

  final int beatsPerBar;
  final int? activeBeat;
  final bool accent;
  final bool equalBeats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < beatsPerBar; i++)
          Container(
            width: equalBeats || i != 0 ? 10 : 12,
            height: equalBeats || i != 0 ? 10 : 12,
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activeBeat == i
                  ? (equalBeats
                        ? scheme.secondary
                        : (accent || i == 0
                              ? scheme.primary
                              : scheme.secondary))
                  : scheme.outlineVariant,
            ),
          ),
      ],
    );
  }
}
