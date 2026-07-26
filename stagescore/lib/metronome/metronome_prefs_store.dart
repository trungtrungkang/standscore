import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:stagescore/metronome/metronome_prefs.dart';

/// App-level metronome prefs under `standscore/metronome_prefs.json`.
class MetronomePrefsStore {
  MetronomePrefsStore({required Directory root})
    : _file = File(p.join(root.path, 'metronome_prefs.json'));

  final File _file;

  Future<MetronomePrefs> load() async {
    if (!await _file.exists()) return const MetronomePrefs();
    try {
      final json =
          jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
      return MetronomePrefs.fromJson(json);
    } catch (_) {
      return const MetronomePrefs();
    }
  }

  Future<void> save(MetronomePrefs prefs) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(prefs.toJson()),
    );
  }
}
