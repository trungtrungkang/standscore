import 'package:flutter/material.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
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
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.setlistEditorImportFirst)),
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
    final l10n = AppLocalizations.of(context);
    final title = _titleController.text.trim();
    final result = _setlist.rename(
      title.isEmpty ? l10n.setlistEditorDefaultTitle : title,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.setlistEditorAppBarTitle),
        actions: [TextButton(onPressed: _done, child: Text(l10n.actionDone))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addScores,
        icon: const Icon(Icons.add),
        label: Text(l10n.setlistEditorAddScores),
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
              decoration: InputDecoration(
                labelText: l10n.setlistEditorTitleFieldLabel,
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
            ),
          ),
          Expanded(
            child: _setlist.scoreIds.isEmpty
                ? Center(child: Text(l10n.setlistEditorEmpty))
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
                      final title =
                          score?.title ?? l10n.setlistEditorMissingScore;
                      return ListTile(
                        key: ValueKey('$id-$index'),
                        leading: Text('${index + 1}.'),
                        title: Text(title),
                        subtitle: score == null
                            ? Text(l10n.setlistEditorRemovedFromLibrary)
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: l10n.setlistEditorRemoveTooltip,
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
    final l10n = AppLocalizations.of(context);
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
                    tooltip: l10n.actionBack,
                    onPressed: () => setState(() => _drillRootId = null),
                    icon: const Icon(Icons.arrow_back),
                  ),
                Expanded(
                  child: Text(
                    drilling == null
                        ? l10n.setlistEditorAddScores
                        : drilling.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: _selected.isEmpty
                      ? null
                      : () => Navigator.pop(context, _selected.toList()),
                  child: Text(l10n.setlistEditorAddCount(_selected.length)),
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
                    subtitle: Text(l10n.setlistEditorPieceCount(childCount)),
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
                          tooltip: l10n.setlistEditorPiecesTooltip,
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
