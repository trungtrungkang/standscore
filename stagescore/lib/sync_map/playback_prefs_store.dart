import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:stagescore/sync_map/playback_prefs.dart';

/// App-level playback prefs under `standscore/playback_prefs.json`.
class PlaybackPrefsStore {
  PlaybackPrefsStore({required Directory root})
    : _file = File(p.join(root.path, 'playback_prefs.json'));

  final File _file;

  Future<PlaybackPrefs> load() async {
    if (!await _file.exists()) return const PlaybackPrefs();
    try {
      final json =
          jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
      return PlaybackPrefs.fromJson(json);
    } catch (_) {
      return const PlaybackPrefs();
    }
  }

  Future<void> save(PlaybackPrefs prefs) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(prefs.toJson()),
    );
  }
}
