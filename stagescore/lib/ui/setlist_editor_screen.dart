import 'package:flutter/material.dart';
import 'package:stagescore/library/score.dart';
import 'package:stagescore/setlist/setlist.dart';
import 'package:stagescore/theme/app_tokens.dart';

/// Create / edit a Setlist (Spec 0012 / 0055).
class SetlistEditorScreen extends StatefulWidget {
  const SetlistEditorScreen({
    super.key,
    required this.initial,
    required this.libraryScores,
  });

  final Setlist initial;
  final List<Score> libraryScores;

  @override
  State<SetlistEditorScreen> createState() => _SetlistEditorScreenState();
}

class _SetlistEditorScreenState extends State<SetlistEditorScreen> {
  late Setlist _setlist;
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _setlist = widget.initial;
    _titleController = TextEditingController(text: _setlist.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Score? _scoreById(String id) {
    for (final s in widget.libraryScores) {
      if (s.id == id) return s;
    }
    return null;
  }

  Future<void> _addScores() async {
    final available = widget.libraryScores;
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import PDFs into the library first.')),
      );
      return;
    }
    final selected = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddScoresSheet(scores: available),
    );
    if (selected == null || selected.isEmpty || !mounted) return;
    setState(() {
      var next = _setlist;
      for (final id in selected) {
        next = next.addScore(id);
      }
      _setlist = next;
    });
  }

  void _done() {
    final title = _titleController.text.trim();
    final result = _setlist.rename(title.isEmpty ? 'Setlist' : title);
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit setlist'),
        actions: [TextButton(onPressed: _done, child: const Text('Done'))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addScores,
        icon: const Icon(Icons.add),
        label: const Text('Add scores'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Setlist title',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
            ),
          ),
          Expanded(
            child: _setlist.scoreIds.isEmpty
                ? const Center(child: Text('No scores yet — tap Add scores.'))
                : ReorderableListView.builder(
                    padding: const EdgeInsets.only(bottom: kFabScrollClearance),
                    itemCount: _setlist.scoreIds.length,
                    onReorderItem: (oldIndex, newIndex) {
                      setState(
                        () => _setlist = _setlist.move(oldIndex, newIndex),
                      );
                    },
                    itemBuilder: (context, index) {
                      final id = _setlist.scoreIds[index];
                      final score = _scoreById(id);
                      final title = score?.title ?? 'Missing score';
                      return ListTile(
                        key: ValueKey('$id-$index'),
                        leading: Text('${index + 1}.'),
                        title: Text(title),
                        subtitle: score == null
                            ? const Text('Removed from library')
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Remove',
                              onPressed: () {
                                setState(
                                  () => _setlist = _setlist.removeAt(index),
                                );
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_handle),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Picker: roots first; drill into a root to pick a child (Spec 0055).
class _AddScoresSheet extends StatefulWidget {
  const _AddScoresSheet({required this.scores});

  final List<Score> scores;

  @override
  State<_AddScoresSheet> createState() => _AddScoresSheetState();
}

class _AddScoresSheetState extends State<_AddScoresSheet> {
  final Set<String> _selected = {};
  String? _drillRootId;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.7;
    final roots = rootsOnly(widget.scores);
    Score? drilling;
    final drillId = _drillRootId;
    if (drillId != null) {
      for (final s in widget.scores) {
        if (s.id == drillId) {
          drilling = s;
          break;
        }
      }
    }
    final list = drilling == null
        ? roots
        : childrenOfRoot(widget.scores, drilling.id);

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                if (drilling != null)
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => setState(() => _drillRootId = null),
                    icon: const Icon(Icons.arrow_back),
                  ),
                Expanded(
                  child: Text(
                    drilling == null ? 'Add scores' : drilling.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: _selected.isEmpty
                      ? null
                      : () => Navigator.pop(context, _selected.toList()),
                  child: Text('Add (${_selected.length})'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final score = list[index];
                final checked = _selected.contains(score.id);
                final childCount = drilling == null
                    ? childrenOfRoot(widget.scores, score.id).length
                    : 0;
                if (drilling == null && childCount > 0) {
                  return ListTile(
                    title: Text(score.title),
                    subtitle: Text(
                      '$childCount ${childCount == 1 ? 'piece' : 'pieces'}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: checked,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selected.add(score.id);
                              } else {
                                _selected.remove(score.id);
                              }
                            });
                          },
                        ),
                        IconButton(
                          tooltip: 'Pieces',
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () =>
                              setState(() => _drillRootId = score.id),
                        ),
                      ],
                    ),
                    onTap: () => setState(() => _drillRootId = score.id),
                  );
                }
                return CheckboxListTile(
                  value: checked,
                  title: Text(score.title),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selected.add(score.id);
                      } else {
                        _selected.remove(score.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
