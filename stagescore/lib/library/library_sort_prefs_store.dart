import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:stagescore/library/library_sort.dart';

/// App-level Library sort under `standscore/library_sort_prefs.json`.
class LibrarySortPrefsStore {
  LibrarySortPrefsStore({required Directory root})
    : _file = File(p.join(root.path, 'library_sort_prefs.json'));

  final File _file;

  Future<LibrarySortMode> load() async {
    if (!await _file.exists()) return LibrarySortMode.lastViewed;
    final json = jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
    final name = json['mode'] as String?;
    for (final mode in LibrarySortMode.values) {
      if (mode.name == name) return mode;
    }
    return LibrarySortMode.lastViewed;
  }

  Future<void> save(LibrarySortMode mode) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert({'mode': mode.name}),
    );
  }
}
