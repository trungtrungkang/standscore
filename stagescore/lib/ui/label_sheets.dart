import 'package:flutter/material.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/label/label_store.dart';
import 'package:stagescore/theme/app_tokens.dart';

/// Assign Labels to one Score + manage catalog.
///
/// Filtering the Library moved to `library_filter_sheet.dart` when it grew a
/// second dimension (Spec 0053): a sheet that also filters by source file is
/// not a Label sheet, whatever it was called first.
Future<void> showScoreLabelsSheet({
  required BuildContext context,
  required LabelStore store,
  required String scoreId,
  required String scoreTitle,
  required VoidCallback onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final l10n = AppLocalizations.of(context);
          final assigned = store.labelsForScore(scoreId);

          Future<void> reload() async {
            await store.load();
            onChanged();
            setModalState(() {});
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.labelSheetsTitle(scoreTitle),
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await showManageLabelsSheet(
                            context: context,
                            store: store,
                            onChanged: () async {
                              await reload();
                            },
                          );
                          await reload();
                        },
                        child: Text(l10n.labelSheetsManage),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.actionDone),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (store.labels.isEmpty)
                    TextButton.icon(
                      onPressed: () async {
                        final name = await _promptLabelName(context);
                        if (name == null) return;
                        final label = await store.create(name);
                        await store.setScoreLabels(scoreId, {
                          ...assigned,
                          label.id,
                        });
                        await reload();
                      },
                      icon: const Icon(Icons.add),
                      label: Text(l10n.labelSheetsCreateLabel),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final label in store.labels)
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(label.name),
                              value: assigned.contains(label.id),
                              onChanged: (checked) async {
                                final next = {...assigned};
                                if (checked == true) {
                                  next.add(label.id);
                                } else {
                                  next.remove(label.id);
                                }
                                await store.setScoreLabels(scoreId, next);
                                await reload();
                              },
                            ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.add),
                            title: Text(l10n.labelSheetsNewLabel),
                            onTap: () async {
                              final name = await _promptLabelName(context);
                              if (name == null) return;
                              final label = await store.create(name);
                              await store.setScoreLabels(scoreId, {
                                ...store.labelsForScore(scoreId),
                                label.id,
                              });
                              await reload();
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

/// Create / rename / delete / reorder Labels.
Future<void> showManageLabelsSheet({
  required BuildContext context,
  required LabelStore store,
  required VoidCallback onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final l10n = AppLocalizations.of(context);
          Future<void> reload() async {
            onChanged();
            setModalState(() {});
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.labelSheetsManageTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final name = await _promptLabelName(context);
                          if (name == null) return;
                          await store.create(name);
                          await reload();
                        },
                        child: Text(l10n.actionAdd),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.actionDone),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (store.labels.isEmpty)
                    Text(
                      l10n.labelSheetsNoLabelsYet,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.5,
                      ),
                      child: ReorderableListView.builder(
                        shrinkWrap: true,
                        buildDefaultDragHandles: false,
                        itemCount: store.labels.length,
                        onReorderItem: (oldIndex, newIndex) async {
                          await store.reorder(oldIndex, newIndex);
                          await reload();
                        },
                        itemBuilder: (context, index) {
                          final label = store.labels[index];
                          return ListTile(
                            key: ValueKey(label.id),
                            title: Text(label.name),
                            subtitle: Text(
                              l10n.labelSheetsUsageCount(
                                store.usageCount(label.id),
                              ),
                            ),
                            leading: ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_handle),
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) async {
                                switch (value) {
                                  case 'rename':
                                    final name = await _promptLabelName(
                                      context,
                                      initial: label.name,
                                    );
                                    if (name == null) return;
                                    await store.rename(label.id, name);
                                    await reload();
                                  case 'delete':
                                    final usage = store.usageCount(label.id);
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(l10n.labelSheetsDeleteTitle),
                                        content: Text(
                                          usage == 0
                                              ? l10n.labelSheetsDeleteConfirm(
                                                  label.name,
                                                )
                                              : l10n
                                                    .labelSheetsDeleteConfirmWithUsage(
                                                      label.name,
                                                      usage,
                                                    ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text(l10n.actionCancel),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: Text(l10n.actionDelete),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok != true) return;
                                    await store.delete(label.id);
                                    await reload();
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'rename',
                                  child: Text(l10n.actionRename),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(l10n.actionDelete),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<String?> _promptLabelName(
  BuildContext context, {
  String? initial,
}) async {
  final result = await showDialog<String>(
    context: context,
    builder: (context) => _LabelNameDialog(initial: initial),
  );
  if (result == null || result.isEmpty) return null;
  return result;
}

/// Owns its [TextEditingController] so dispose is safe after the route closes.
class _LabelNameDialog extends StatefulWidget {
  const _LabelNameDialog({this.initial});

  final String? initial;

  @override
  State<_LabelNameDialog> createState() => _LabelNameDialogState();
}

class _LabelNameDialogState extends State<_LabelNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(
        widget.initial == null
            ? l10n.labelSheetsNewLabel
            : l10n.labelSheetsRenameLabelTitle,
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 40,
        decoration: InputDecoration(hintText: l10n.labelSheetsNameHint),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.actionSave)),
      ],
    );
  }
}
