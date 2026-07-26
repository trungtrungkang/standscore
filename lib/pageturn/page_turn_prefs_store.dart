import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:standscore/pageturn/page_turn_prefs.dart';

class PageTurnPrefsStore {
  PageTurnPrefsStore({required Directory root})
    : _file = File(p.join(root.path, 'pageturn_prefs.json'));

  final File _file;

  Future<PageTurnPrefs> load() async {
    if (!await _file.exists()) return const PageTurnPrefs();
    final json = jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
    return PageTurnPrefs.fromJson(json);
  }

  Future<void> save(PageTurnPrefs prefs) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(prefs.toJson()),
    );
  }
}
