import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:standscore/label/label.dart';
import 'package:uuid/uuid.dart';

/// Global Label catalog + Score assignments under `standscore/labels.json`.
class LabelStore {
  LabelStore({required Directory root, Uuid? uuid})
    : _file = File(p.join(root.path, 'labels.json')),
      _uuid = uuid ?? const Uuid();

  final File _file;
  final Uuid _uuid;

  List<Label> _labels = [];
  final Map<String, Set<String>> _assignments = {};

  List<Label> get labels => List.unmodifiable(_labels);

  /// scoreId → label ids.
  Map<String, Set<String>> get assignments => {
    for (final e in _assignments.entries)
      e.key: Set<String>.unmodifiable(e.value),
  };

  Set<String> labelsForScore(String scoreId) =>
      Set<String>.unmodifiable(_assignments[scoreId] ?? const {});

  Future<void> load() async {
    if (!await _file.exists()) {
      _labels = [];
      _assignments.clear();
      return;
    }
    final json = jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
    final list = json['labels'] as List<dynamic>? ?? const [];
    _labels = [for (final e in list) Label.fromJson(e as Map<String, dynamic>)];
    _assignments.clear();
    final raw = json['assignments'] as Map<String, dynamic>? ?? const {};
    for (final entry in raw.entries) {
      final ids = (entry.value as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toSet();
      if (ids.isNotEmpty) _assignments[entry.key] = ids;
    }
  }

  Future<void> save() async {
    await _file.parent.create(recursive: true);
    final payload = {
      'labels': _labels.map((l) => l.toJson()).toList(),
      'assignments': {
        for (final e in _assignments.entries)
          if (e.value.isNotEmpty) e.key: e.value.toList(),
      },
    };
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
  }

  Future<Label> create(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Label name is empty');
    }
    final label = Label(id: _uuid.v4(), name: trimmed);
    _labels = [..._labels, label];
    await save();
    return label;
  }

  Future<void> rename(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final index = _labels.indexWhere((l) => l.id == id);
    if (index < 0) return;
    _labels = [
      for (var i = 0; i < _labels.length; i++)
        if (i == index) _labels[i].copyWith(name: trimmed) else _labels[i],
    ];
    await save();
  }

  /// Hard-delete Label and remove from all Score assignments.
  Future<void> delete(String id) async {
    _labels = [
      for (final l in _labels)
        if (l.id != id) l,
    ];
    for (final scoreId in _assignments.keys.toList()) {
      final next = {..._assignments[scoreId]!}..remove(id);
      if (next.isEmpty) {
        _assignments.remove(scoreId);
      } else {
        _assignments[scoreId] = next;
      }
    }
    await save();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _labels.length) return;
    if (newIndex < 0 || newIndex >= _labels.length) return;
    if (oldIndex == newIndex) return;
    final items = [..._labels];
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    _labels = items;
    await save();
  }

  Future<void> setScoreLabels(String scoreId, Set<String> labelIds) async {
    final known = _labels.map((l) => l.id).toSet();
    final next = labelIds.where(known.contains).toSet();
    if (next.isEmpty) {
      _assignments.remove(scoreId);
    } else {
      _assignments[scoreId] = next;
    }
    await save();
  }

  int usageCount(String labelId) {
    var n = 0;
    for (final ids in _assignments.values) {
      if (ids.contains(labelId)) n++;
    }
    return n;
  }
}
