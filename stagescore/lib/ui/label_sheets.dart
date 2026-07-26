import 'package:flutter/material.dart';
import 'package:stagescore/label/label.dart';
import 'package:stagescore/label/label_store.dart';

/// Filter Scores by Labels (Spec 0021).
Future<void> showLabelFilterSheet({
  required BuildContext context,
  required LabelStore store,
  required Set<String> selectedLabelIds,
  required LabelFilterMode mode,
  required void Function(Set<String> selected, LabelFilterMode mode) onChanged,
}) {
  var localSelected = {...selectedLabelIds};
  var localMode = mode;

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          void apply() => onChanged({...localSelected}, localMode);

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Filter by Label',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          localSelected = {};
                          localMode = LabelFilterMode.any;
                          apply();
                          setModalState(() {});
                        },
                        child: const Text('Clear'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<LabelFilterMode>(
                    segments: const [
                      ButtonSegment(
                        value: LabelFilterMode.any,
                        label: Text('Any'),
                      ),
                      ButtonSegment(
                        value: LabelFilterMode.all,
                        label: Text('All'),
                      ),
                      ButtonSegment(
                        value: LabelFilterMode.untagged,
                        label: Text('Untagged'),
                      ),
                    ],
                    selected: {localMode},
                    onSelectionChanged: (next) {
                      localMode = next.first;
                      apply();
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  if (localMode == LabelFilterMode.untagged)
                    Text(
                      'Showing Scores with no Labels.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else if (store.labels.isEmpty)
                    Text(
                      'No Labels yet. Create one from a Score’s Label menu.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final label in store.labels)
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(label.name),
                              value: localSelected.contains(label.id),
                              onChanged: (checked) {
                                if (checked == true) {
                                  localSelected.add(label.id);
                                } else {
                                  localSelected.remove(label.id);
                                }
                                apply();
                                setModalState(() {});
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

/// Assign Labels to one Score + manage catalog.
Future<void> showScoreLabelsSheet({
  required BuildContext context,
  required LabelStore store,
  required String scoreId,
  required String scoreTitle,
  required VoidCallback onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final assigned = store.labelsForScore(scoreId);

          Future<void> reload() async {
            await store.load();
            onChanged();
            setModalState(() {});
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Labels · $scoreTitle',
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
                        child: const Text('Manage'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                      label: const Text('Create Label'),
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
                            title: const Text('New Label'),
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
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> reload() async {
            onChanged();
            setModalState(() {});
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Manage Labels',
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
                        child: const Text('Add'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (store.labels.isEmpty)
                    Text(
                      'No Labels yet.',
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
                              '${store.usageCount(label.id)} score'
                              '${store.usageCount(label.id) == 1 ? '' : 's'}',
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
                                        title: const Text('Delete Label?'),
                                        content: Text(
                                          usage == 0
                                              ? 'Delete “${label.name}”?'
                                              : 'Delete “${label.name}”? '
                                                    'It will be removed from $usage '
                                                    'score${usage == 1 ? '' : 's'}.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok != true) return;
                                    await store.delete(label.id);
                                    await reload();
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'rename',
                                  child: Text('Rename'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
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
    return AlertDialog(
      title: Text(widget.initial == null ? 'New Label' : 'Rename Label'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 40,
        decoration: const InputDecoration(hintText: 'Label name'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
