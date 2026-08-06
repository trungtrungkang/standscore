import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:stagescore/measure_map/measure_map_store.dart';

/// Per-Score MeasureMap under `standscore/measure_maps/<scoreId>.json`.
class MeasureMapPersistence {
  MeasureMapPersistence({required Directory root, required this.scoreId})
    : _file = File(p.join(root.path, 'measure_maps', '$scoreId.json'));

  final String scoreId;
  final File _file;

  File get file => _file;

  Future<void> loadInto(MeasureMapStore store) async {
    if (!await _file.exists()) {
      store.clear();
      return;
    }
    final json = jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
    store.loadJson(json);
  }

  Future<void> save(MeasureMapStore store) async {
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
