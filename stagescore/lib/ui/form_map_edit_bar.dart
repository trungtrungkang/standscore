import 'package:flutter/material.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/theme/app_tokens.dart';

/// Bottom actions while FormMap edit mode is on (Spec 0061).
class FormMapEditBar extends StatelessWidget {
  const FormMapEditBar({
    super.key,
    required this.measureSelected,
    required this.onDone,
    required this.onSetMarker,
    required this.onSetJump,
    required this.onAddRepeat,
    required this.onClearMeasure,
    required this.onClearAll,
  });

  final bool measureSelected;
  final VoidCallback onDone;
  final VoidCallback onSetMarker;
  final VoidCallback onSetJump;
  final VoidCallback onAddRepeat;
  final VoidCallback onClearMeasure;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 6,
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!measureSelected)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.xs,
                    AppSpacing.sm,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    l10n.formMapEmptyHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    TextButton(
                      onPressed: onDone,
                      child: Text(l10n.formMapDone),
                    ),
                    TextButton(
                      onPressed: onAddRepeat,
                      child: Text(l10n.formMapAddRepeat),
                    ),
                    if (measureSelected) ...[
                      TextButton(
                        onPressed: onSetMarker,
                        child: Text(l10n.formMapSetMarker),
                      ),
                      TextButton(
                        onPressed: onSetJump,
                        child: Text(l10n.formMapSetJump),
                      ),
                      TextButton(
                        onPressed: onClearMeasure,
                        child: Text(l10n.formMapClearMeasure),
                      ),
                    ],
                    TextButton(
                      onPressed: onClearAll,
                      child: Text(l10n.formMapClearAll),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
