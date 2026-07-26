import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:standscore/layout/display_prefs.dart';

/// App-level display prefs under `standscore/display_prefs.json`.
class DisplayPrefsStore {
  DisplayPrefsStore({required Directory root})
      : _file = File(p.join(root.path, 'display_prefs.json'));

  final File _file;

  Future<DisplayPrefs> load() async {
    if (!await _file.exists()) return const DisplayPrefs();
    try {
      final json =
          jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
      return DisplayPrefs.fromJson(json);
    } catch (_) {
      return const DisplayPrefs();
    }
  }

  Future<void> save(DisplayPrefs prefs) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(prefs.toJson()),
    );
  }
}
