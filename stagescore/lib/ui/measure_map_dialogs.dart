import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/measure_map/measure_map_store.dart';
import 'package:stagescore/theme/app_tokens.dart';

/// Ask how many MeasureBoxes a new SystemBox should contain (Spec 0058 G3 #11).
///
/// Returns null on cancel. [initialCount] is the sticky session default.
Future<int?> showMeasureCountDialog({
  required BuildContext context,
  required int initialCount,
  String? title,
}) {
  return showDialog<int>(
    context: context,
    builder: (ctx) => _MeasureCountDialog(
      initialCount: initialCount,
      title: title,
    ),
  );
}

/// Owns its [TextEditingController] so dispose runs after the route unmounts
/// (disposing immediately after [showDialog] returns races the exit animation).
class _MeasureCountDialog extends StatefulWidget {
  const _MeasureCountDialog({
    required this.initialCount,
    this.title,
  });

  final int initialCount;
  final String? title;

  @override
  State<_MeasureCountDialog> createState() => _MeasureCountDialogState();
}

class _MeasureCountDialogState extends State<_MeasureCountDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: '${widget.initialCount}',
  );

  @override
  void initState() {
    super.initState();
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final n = int.tryParse(_controller.text.trim());
    if (n == null || n < 1) return;
    Navigator.pop(context, n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title ?? l10n.measureMapMeasureCountTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: l10n.measureMapMeasureCountLabel,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.actionOk),
        ),
      ],
    );
  }
}

/// Jump to a mapped measure number (Spec 0058 G3 #6).
Future<int?> showGoToMeasureDialog({required BuildContext context}) {
  return showDialog<int>(
    context: context,
    builder: (ctx) => const _GoToMeasureDialog(),
  );
}

class _GoToMeasureDialog extends StatefulWidget {
  const _GoToMeasureDialog();

  @override
  State<_GoToMeasureDialog> createState() => _GoToMeasureDialogState();
}

class _GoToMeasureDialogState extends State<_GoToMeasureDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final n = int.tryParse(_controller.text.trim());
    if (n != null && n >= 1) Navigator.pop(context, n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.measureMapGoToTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: l10n.measureMapGoToLabel,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.actionOk),
        ),
      ],
    );
  }
}

/// Tempo / time-signature edit + scope (Spec 0058 G3 #14).
class MeasureMetaEditResult {
  const MeasureMetaEditResult({
    required this.timeSignature,
    required this.tempo,
    required this.scope,
    this.nextN,
  });

  final String timeSignature;
  final double tempo;
  final MeasureMetaScope scope;
  final int? nextN;
}

Future<MeasureMetaEditResult?> showMeasureMetaDialog({
  required BuildContext context,
  required String initialTimeSignature,
  required double initialTempo,
}) {
  return showDialog<MeasureMetaEditResult>(
    context: context,
    builder: (ctx) => _MeasureMetaDialog(
      initialTimeSignature: initialTimeSignature,
      initialTempo: initialTempo,
    ),
  );
}

class _MeasureMetaDialog extends StatefulWidget {
  const _MeasureMetaDialog({
    required this.initialTimeSignature,
    required this.initialTempo,
  });

  final String initialTimeSignature;
  final double initialTempo;

  @override
  State<_MeasureMetaDialog> createState() => _MeasureMetaDialogState();
}

class _MeasureMetaDialogState extends State<_MeasureMetaDialog> {
  late final TextEditingController _tsController = TextEditingController(
    text: widget.initialTimeSignature,
  );
  late final TextEditingController _tempoController = TextEditingController(
    text: widget.initialTempo == widget.initialTempo.roundToDouble()
        ? '${widget.initialTempo.round()}'
        : '${widget.initialTempo}',
  );
  final TextEditingController _nextNController = TextEditingController(
    text: '4',
  );
  MeasureMetaScope _scope = MeasureMetaScope.thisMeasure;

  @override
  void dispose() {
    _tsController.dispose();
    _tempoController.dispose();
    _nextNController.dispose();
    super.dispose();
  }

  void _submit() {
    final ts = _tsController.text.trim();
    final tempo = double.tryParse(_tempoController.text.trim());
    if (ts.isEmpty || tempo == null || tempo <= 0) return;
    final n = int.tryParse(_nextNController.text.trim());
    if (_scope == MeasureMetaScope.nextN && (n == null || n < 1)) {
      return;
    }
    Navigator.pop(
      context,
      MeasureMetaEditResult(
        timeSignature: ts,
        tempo: tempo,
        scope: _scope,
        nextN: n,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.measureMapMetaTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tsController,
              decoration: InputDecoration(
                labelText: l10n.measureMapTimeSignatureLabel,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _tempoController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.measureMapTempoLabel,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.measureMapMetaScopeTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            RadioGroup<MeasureMetaScope>(
              groupValue: _scope,
              onChanged: (v) {
                if (v != null) setState(() => _scope = v);
              },
              child: Column(
                children: [
                  for (final s in MeasureMetaScope.values)
                    RadioListTile<MeasureMetaScope>(
                      value: s,
                      title: Text(_scopeLabel(l10n, s)),
                      dense: true,
                    ),
                ],
              ),
            ),
            if (_scope == MeasureMetaScope.nextN)
              TextField(
                controller: _nextNController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.measureMapMetaNextNLabel,
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.actionOk),
        ),
      ],
    );
  }
}

String _scopeLabel(AppLocalizations l10n, MeasureMetaScope scope) {
  return switch (scope) {
    MeasureMetaScope.thisMeasure => l10n.measureMapScopeThisMeasure,
    MeasureMetaScope.thisSystem => l10n.measureMapScopeThisSystem,
    MeasureMetaScope.thisPage => l10n.measureMapScopeThisPage,
    MeasureMetaScope.restOfScore => l10n.measureMapScopeRestOfScore,
    MeasureMetaScope.nextN => l10n.measureMapScopeNextN,
  };
}

/// Confirm wipe of the whole MeasureMap (Spec 0058 G3 #9).
Future<bool> confirmClearMeasureMap(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.measureMapClearTitle),
      content: Text(l10n.measureMapClearBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.measureMapClearConfirm),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Confirm deleting a multi-measure system.
Future<bool> confirmDeleteSystem(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.measureMapDeleteSystemTitle),
      content: Text(l10n.measureMapDeleteSystemBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.actionDelete),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Pick a source page to copy layout from (secondary path, Spec 0058 G3 #4).
Future<int?> showCopyLayoutPageDialog({
  required BuildContext context,
  required int currentPage,
  required int maxPage,
}) {
  return showDialog<int>(
    context: context,
    builder: (ctx) => _CopyLayoutPageDialog(
      currentPage: currentPage,
      maxPage: maxPage,
    ),
  );
}

class _CopyLayoutPageDialog extends StatefulWidget {
  const _CopyLayoutPageDialog({
    required this.currentPage,
    required this.maxPage,
  });

  final int currentPage;
  final int maxPage;

  @override
  State<_CopyLayoutPageDialog> createState() => _CopyLayoutPageDialogState();
}

class _CopyLayoutPageDialogState extends State<_CopyLayoutPageDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.currentPage > 1 ? '${widget.currentPage - 1}' : '1',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final n = int.tryParse(_controller.text.trim());
    if (n != null &&
        n >= 1 &&
        n <= widget.maxPage &&
        n != widget.currentPage) {
      Navigator.pop(context, n);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.measureMapCopyFromPageTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: l10n.measureMapCopyFromPageLabel,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.actionOk),
        ),
      ],
    );
  }
}
