import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:stagescore/theme/app_locale_pref.dart';

/// App-level language override under `standscore/app_locale_prefs.json` —
/// same shape and same root as [AppAppearancePrefsStore] (Spec 0057).
class AppLocalePrefsStore {
  AppLocalePrefsStore({required Directory root})
    : _file = File(p.join(root.path, 'app_locale_prefs.json'));

  final File _file;

  Future<AppLocalePref> load() async {
    if (!await _file.exists()) return AppLocalePref.system;
    try {
      final json =
          jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
      final languageCode = json['languageCode'] as String?;
      if (languageCode == null || languageCode.isEmpty) {
        return AppLocalePref.system;
      }
      return AppLocalePref(
        languageCode: languageCode,
        countryCode: json['countryCode'] as String?,
      );
    } catch (_) {
      return AppLocalePref.system;
    }
  }

  Future<void> save(AppLocalePref pref) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'languageCode': pref.languageCode,
        'countryCode': pref.countryCode,
      }),
    );
  }
}
