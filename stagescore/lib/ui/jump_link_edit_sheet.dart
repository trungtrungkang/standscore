import 'package:flutter/material.dart';
import 'package:stagescore/jumplink/jump_link.dart';
import 'package:stagescore/jumplink/jump_link_geometry.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/theme/app_tokens.dart';

enum JumpLinkEditAction { save, delete }

class JumpLinkEditResult {
  const JumpLinkEditResult.save(this.link) : action = JumpLinkEditAction.save;
  const JumpLinkEditResult.delete()
    : action = JumpLinkEditAction.delete,
      link = null;

  final JumpLinkEditAction action;
  final JumpLink? link;
}

const jumpLinkColorPalette = <int>[
  defaultJumpLinkColorValue,
  0xCCDC2626,
  0xCC2563EB,
  0xCCCA8A04,
  0xCC7C3AED,
];

/// Create or edit a JumpLink (destination / color / size / delete).
Future<JumpLinkEditResult?> showJumpLinkEditor({
  required BuildContext context,
  required int pageCount,
  JumpLink? existing,
  required int originPage,
  int? initialDestination,
}) async {
  return showModalBottomSheet<JumpLinkEditResult>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
            top: AppSpacing.sm,
          ),
          child: JumpLinkEditorForm(
            pageCount: pageCount,
            originPage: originPage,
            existing: existing,
            initialDestination: initialDestination,
            onCancel: () => Navigator.pop(context),
            onResult: (result) => Navigator.pop(context, result),
          ),
        ),
      );
    },
  );
}

/// Shared add/edit form — modal or embedded in the Jump Links sheet.
class JumpLinkEditorForm extends StatefulWidget {
  const JumpLinkEditorForm({
    super.key,
    required this.pageCount,
    required this.originPage,
    required this.onCancel,
    required this.onResult,
    this.existing,
    this.initialDestination,
    this.leading,
  });

  final int pageCount;
  final int originPage;
  final JumpLink? existing;
  final int? initialDestination;
  final VoidCallback onCancel;
  final ValueChanged<JumpLinkEditResult> onResult;

  /// Optional leading control (e.g. back) instead of Cancel text.
  final Widget? leading;

  @override
  State<JumpLinkEditorForm> createState() => _JumpLinkEditorFormState();
}

class _JumpLinkEditorFormState extends State<JumpLinkEditorForm> {
  late int _destination;
  late int _colorValue;
  late double _sizeScale;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _destination = clampJumpDestination(
      existing?.destinationPage ??
          widget.initialDestination ??
          (widget.originPage < widget.pageCount
              ? widget.originPage + 1
              : widget.originPage),
      widget.pageCount,
    );
    _colorValue = existing?.colorValue ?? defaultJumpLinkColorValue;
    _sizeScale = existing == null
        ? 1.0
        : (existing.normRect.width / defaultJumpLinkNormRect().width).clamp(
            0.6,
            1.8,
          );
  }

  void _save() {
    final base = defaultJumpLinkNormRect();
    final norm = Rect.fromLTWH(
      base.left,
      base.top,
      (base.width * _sizeScale).clamp(0.12, 0.45),
      (base.height * _sizeScale).clamp(0.05, 0.16),
    );
    final existing = widget.existing;
    if (existing != null) {
      widget.onResult(
        JumpLinkEditResult.save(
          existing.copyWith(
            destinationPage: _destination,
            colorValue: _colorValue,
            normRect: norm,
          ),
        ),
      );
      return;
    }
    widget.onResult(
      JumpLinkEditResult.save(
        JumpLink(
          id: 'pending',
          originPage: widget.originPage,
          destinationPage: _destination,
          normRect: norm,
          colorValue: _colorValue,
          createdAt: DateTime.now().toUtc(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final existing = widget.existing;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (widget.leading != null) ...[
              widget.leading!,
              const SizedBox(width: AppSpacing.xs),
            ],
            Expanded(
              child: Text(
                existing == null
                    ? l10n.jumpLinkEditSheetAddTitle
                    : l10n.jumpLinkEditSheetEditTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (widget.leading == null)
              TextButton(
                onPressed: widget.onCancel,
                child: Text(l10n.actionCancel),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.jumpLinkEditSheetOriginLabel(widget.originPage),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            IconButton(
              onPressed: _destination <= 1
                  ? null
                  : () => setState(() => _destination--),
              icon: const Icon(Icons.remove),
            ),
            Expanded(
              child: Text(
                l10n.jumpLinkEditSheetDestinationLabel(
                  _destination,
                  widget.pageCount,
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              onPressed: _destination >= widget.pageCount
                  ? null
                  : () => setState(() => _destination++),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.jumpLinkEditSheetColorLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          children: [
            for (final c in jumpLinkColorPalette)
              ChoiceChip(
                label: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Color(c),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black26),
                  ),
                ),
                selected: _colorValue == c,
                onSelected: (_) => setState(() => _colorValue = c),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.jumpLinkEditSheetSizeLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Slider(
          value: _sizeScale,
          min: 0.6,
          max: 1.8,
          divisions: 12,
          label: _sizeScale.toStringAsFixed(1),
          onChanged: (v) => setState(() => _sizeScale = v),
        ),
        const SizedBox(height: AppSpacing.sm),
        FilledButton(
          onPressed: _save,
          child: Text(existing == null ? l10n.actionAdd : l10n.actionSave),
        ),
        if (existing != null) ...[
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => widget.onResult(const JumpLinkEditResult.delete()),
            child: Text(l10n.actionDelete),
          ),
        ],
      ],
    );
  }
}
