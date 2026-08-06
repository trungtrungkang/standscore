import 'package:flutter/material.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/theme/app_tokens.dart';

/// Bottom actions while MeasureMap edit mode is on (Spec 0058 rev. 1).
class MeasureMapEditBar extends StatelessWidget {
  const MeasureMapEditBar({
    super.key,
    required this.systemSelected,
    required this.measureSelected,
    required this.editingBeats,
    required this.canCopyPrevious,
    required this.onDone,
    required this.onCopyPrevious,
    required this.onCopyFromPage,
    required this.onDeleteMeasure,
    required this.onSetMeasureCount,
    required this.onDeleteSystem,
    required this.onEditMeta,
    required this.onToggleEditBeats,
    required this.onClearAll,
  });

  final bool systemSelected;
  final bool measureSelected;
  final bool editingBeats;
  final bool canCopyPrevious;
  final VoidCallback onDone;
  final VoidCallback onCopyPrevious;
  final VoidCallback onCopyFromPage;
  final VoidCallback onDeleteMeasure;
  final VoidCallback onSetMeasureCount;
  final VoidCallback onDeleteSystem;
  final VoidCallback onEditMeta;
  final VoidCallback onToggleEditBeats;
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
              if (!systemSelected && !measureSelected)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.xs,
                    AppSpacing.sm,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    l10n.measureMapEmptyHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    TextButton(
                      onPressed: onDone,
                      child: Text(l10n.measureMapDone),
                    ),
                    if (canCopyPrevious)
                      TextButton(
                        onPressed: onCopyPrevious,
                        child: Text(l10n.measureMapCopyPrevious),
                      ),
                    TextButton(
                      onPressed: onCopyFromPage,
                      child: Text(l10n.measureMapCopyFromPageTitle),
                    ),
                    if (systemSelected) ...[
                      TextButton(
                        onPressed: onSetMeasureCount,
                        child: Text(l10n.measureMapSetMeasureCount),
                      ),
                      TextButton(
                        onPressed: onDeleteSystem,
                        child: Text(l10n.measureMapDeleteSystem),
                      ),
                    ],
                    if (measureSelected) ...[
                      TextButton(
                        onPressed: onDeleteMeasure,
                        child: Text(l10n.measureMapDeleteMeasure),
                      ),
                      TextButton(
                        onPressed: onEditMeta,
                        child: Text(l10n.measureMapEditMeta),
                      ),
                      TextButton(
                        onPressed: onToggleEditBeats,
                        child: Text(
                          editingBeats
                              ? l10n.measureMapDone
                              : l10n.measureMapEditBeats,
                        ),
                      ),
                    ],
                    TextButton(
                      onPressed: onClearAll,
                      child: Text(l10n.measureMapClearAll),
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
