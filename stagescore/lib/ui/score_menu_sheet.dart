import 'package:flutter/material.dart';
import 'package:stagescore/theme/app_tokens.dart';
import 'package:stagescore/ui/metronome_icon.dart';
import 'package:stagescore/ui/score_menu.dart';

/// Opens the ScoreMenu and resolves to the chosen action, or null if the
/// musician dismissed it (Spec 0035).
///
/// A route on purpose: PerformanceMode keeps the chrome up while the screen's
/// route is not the current one, so the auto-hide countdown cannot fire behind
/// this sheet (Spec 0034).
Future<ScoreMenuAction?> showScoreMenu({
  required BuildContext context,
  required List<ScoreMenuGroup> groups,
}) {
  return showModalBottomSheet<ScoreMenuAction>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ScoreMenuSheet(groups: groups),
  );
}

class _ScoreMenuSheet extends StatelessWidget {
  const _ScoreMenuSheet({required this.groups});

  final List<ScoreMenuGroup> groups;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ConstrainedBox(
        // Same shape as the Layout / Page turn sheets: a Done row means the
        // list can use the height without trapping anyone (Spec 0035).
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                0,
                AppSpacing.xs,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: Text('Menu', style: theme.textTheme.titleLarge),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                children: [
                  for (final group in groups) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.xs,
                      ),
                      child: Text(
                        group.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    for (final entry in group.entries)
                      ListTile(
                        // Metronome keeps the app's own glyph here — the same
                        // one the quick-bar draws — rather than the generic
                        // Material stand-in `entry.icon` carries for it,
                        // which read as unrelated next to the real thing.
                        leading: entry.action == ScoreMenuAction.metronome
                            ? const MetronomeIcon()
                            : Icon(entry.icon),
                        title: Text(entry.label),
                        trailing: entry.value == null
                            ? null
                            : Text(
                                entry.value!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                        enabled: entry.enabled,
                        onTap: () => Navigator.of(context).pop(entry.action),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
