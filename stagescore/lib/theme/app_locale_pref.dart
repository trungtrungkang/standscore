import 'package:flutter/material.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';

/// Language override for the app UI (Spec 0057).
///
/// `null` means "follow the system locale" — the common case, and the only
/// state a fresh install has. A non-null value pins the UI to one of
/// [AppLocalePref.supported] regardless of what the device is set to.
class AppLocalePref {
  const AppLocalePref({this.languageCode, this.countryCode});

  static const AppLocalePref system = AppLocalePref();

  /// Locales the app ships translations for — same set as the web product
  /// (Spec 0057, decision 2). Order is the order the language sheet lists
  /// them in.
  static const List<Locale> supported = [
    Locale('en'),
    Locale('vi'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  final String? languageCode;
  final String? countryCode;

  bool get isSystem => languageCode == null;

  /// The [Locale] to pass to `MaterialApp.locale`, or null to let Flutter
  /// resolve the system locale against [AppLocalizations.supportedLocales].
  Locale? get locale =>
      languageCode == null ? null : Locale(languageCode!, countryCode);

  AppLocalePref copyWith({
    String? languageCode,
    String? countryCode,
    bool clear = false,
  }) {
    if (clear) return AppLocalePref.system;
    return AppLocalePref(
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppLocalePref &&
        other.languageCode == languageCode &&
        other.countryCode == countryCode;
  }

  @override
  int get hashCode => Object.hash(languageCode, countryCode);
}

/// Endonym shown in the language picker — deliberately not an ARB string:
/// "Tiếng Việt" reads the same regardless of which language the picker is
/// currently displayed in, the same way a keyboard language switcher never
/// translates its own entries.
String endonymFor(Locale locale) {
  if (locale.languageCode == 'zh' && locale.countryCode == 'TW') {
    return '繁體中文';
  }
  return switch (locale.languageCode) {
    'en' => 'English',
    'vi' => 'Tiếng Việt',
    'es' => 'Español',
    'fr' => 'Français',
    'de' => 'Deutsch',
    'ja' => '日本語',
    'ko' => '한국어',
    'zh' => '简体中文',
    _ => locale.languageCode,
  };
}
