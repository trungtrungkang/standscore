import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:stagescore/form_map/form_map_store.dart';

/// Per-Score FormMap under `standscore/form_maps/<scoreId>.json`.
class FormMapPersistence {
  FormMapPersistence({required Directory root, required this.scoreId})
      : _file = File(p.join(root.path, 'form_maps', '$scoreId.json'));

  final String scoreId;
  final File _file;

  File get file => _file;

  Future<void> loadInto(FormMapStore store) async {
    if (!await _file.exists()) {
      store.clear();
      return;
    }
    final json = jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
    store.loadJson(json);
  }

  Future<void> save(FormMapStore store) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(store.toJson(scoreId)),
    );
  }

  Future<void> delete() async {
    if (await _file.exists()) {
      await _file.delete();
    }
  }
}
