import 'package:flutter/material.dart';
import 'package:standscore/ui/score_menu.dart';

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
    showDragHandle: true,
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
              padding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
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
                padding: const EdgeInsets.only(bottom: 12),
                children: [
                  for (final group in groups) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        group.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    for (final entry in group.entries)
                      ListTile(
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
