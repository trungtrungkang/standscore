import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:stagescore/annotation/draw_style.dart';

/// App-wide draw style under `standscore/draw_style_prefs.json`.
class DrawStylePrefsStore {
  DrawStylePrefsStore({required Directory root})
    : _file = File(p.join(root.path, 'draw_style_prefs.json'));

  final File _file;

  Future<DrawStylePrefs> load() async {
    if (!await _file.exists()) return const DrawStylePrefs();
    final json = jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
    return DrawStylePrefs.fromJson(json);
  }

  Future<void> save(DrawStylePrefs prefs) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(prefs.toJson()),
    );
  }
}
