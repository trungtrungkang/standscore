import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:stagescore/layout/page_scale.dart';

/// App-level page scale prefs under `standscore/page_scale_prefs.json`.
class PageScalePrefsStore {
  PageScalePrefsStore({required Directory root})
    : _file = File(p.join(root.path, 'page_scale_prefs.json'));

  final File _file;

  Future<PageScalePrefs> load() async {
    if (!await _file.exists()) return const PageScalePrefs();
    try {
      final json =
          jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
      return PageScalePrefs.fromJson(json);
    } catch (_) {
      return const PageScalePrefs();
    }
  }

  Future<void> save(PageScalePrefs prefs) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(prefs.toJson()),
    );
  }
}
