import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:standscore/theme/app_appearance.dart';

/// App-level appearance under `standscore/app_appearance_prefs.json`.
class AppAppearancePrefsStore {
  AppAppearancePrefsStore({required Directory root})
    : _file = File(p.join(root.path, 'app_appearance_prefs.json'));

  final File _file;

  Future<AppAppearance> load() async {
    if (!await _file.exists()) return AppAppearance.defaults;
    try {
      final json =
          jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
      final modeName = json['mode'] as String?;
      AppThemeMode mode = AppAppearance.defaults.mode;
      for (final candidate in AppThemeMode.values) {
        if (candidate.name == modeName) {
          mode = candidate;
          break;
        }
      }
      final seedRaw = json['seedColor'];
      final seed = seedRaw is int
          ? seedRaw
          : int.tryParse('$seedRaw') ?? AppAppearance.brandTealValue;
      // Require opaque ARGB-ish value; fall back if nonsense.
      if (seed <= 0) return AppAppearance.defaults;
      return AppAppearance(mode: mode, seedColorValue: seed);
    } catch (_) {
      return AppAppearance.defaults;
    }
  }

  Future<void> save(AppAppearance appearance) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'mode': appearance.mode.name,
        'seedColor': appearance.seedColorValue,
      }),
    );
  }
}
