import 'package:flutter/material.dart';
import 'package:standscore/library/score.dart';
import 'package:standscore/setlist/setlist.dart';

/// Create / edit a Setlist (Spec 0012).
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                    padding: const EdgeInsets.only(bottom: 88),
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

class _AddScoresSheet extends StatefulWidget {
  const _AddScoresSheet({required this.scores});

  final List<Score> scores;

  @override
  State<_AddScoresSheet> createState() => _AddScoresSheetState();
}

class _AddScoresSheetState extends State<_AddScoresSheet> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.7;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Add scores',
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
              itemCount: widget.scores.length,
              itemBuilder: (context, index) {
                final score = widget.scores[index];
                final checked = _selected.contains(score.id);
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
