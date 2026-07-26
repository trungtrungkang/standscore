import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:standscore/layout/page_color_filter.dart';

/// App-level page color filter under `standscore/page_color_filter_prefs.json`.
class PageColorFilterPrefsStore {
  PageColorFilterPrefsStore({required Directory root})
      : _file = File(p.join(root.path, 'page_color_filter_prefs.json'));

  final File _file;

  Future<PageColorFilterMode> load() async {
    if (!await _file.exists()) return PageColorFilterMode.off;
    final json = jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
    final name = json['mode'] as String?;
    for (final mode in PageColorFilterMode.values) {
      if (mode.name == name) return mode;
    }
    return PageColorFilterMode.off;
  }

  Future<void> save(PageColorFilterMode mode) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert({'mode': mode.name}),
    );
  }
}
