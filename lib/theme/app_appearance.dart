import 'package:flutter/material.dart';

/// App chrome appearance mode (Spec 0026 / P2.10).
enum AppThemeMode {
  system,
  light,
  dark,
}

extension AppThemeModeX on AppThemeMode {
  String get label => switch (this) {
        AppThemeMode.system => 'System',
        AppThemeMode.light => 'Light',
        AppThemeMode.dark => 'Dark',
      };

  ThemeMode get themeMode => switch (this) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };
}

/// Persisted app chrome theme: mode + Material seed accent.
class AppAppearance {
  const AppAppearance({
    required this.mode,
    required this.seedColorValue,
  });

  /// Brand teal used for splash / launcher (`#0D8B86`).
  static const int brandTealValue = 0xFF0D8B86;

  static const AppAppearance defaults = AppAppearance(
    mode: AppThemeMode.system,
    seedColorValue: brandTealValue,
  );

  /// Short accent presets (includes brand teal).
  static const List<int> presetSeedValues = [
    brandTealValue,
    0xFF1565C0, // blue
    0xFF6A1B9A, // purple
    0xFFC62828, // red
    0xFFEF6C00, // orange
    0xFF2E7D32, // green
    0xFF455A64, // blue grey
  ];

  final AppThemeMode mode;
  final int seedColorValue;

  Color get seedColor => Color(seedColorValue);

  ThemeMode get themeMode => mode.themeMode;

  ThemeData themeData(Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
      useMaterial3: true,
    );
  }

  AppAppearance copyWith({
    AppThemeMode? mode,
    int? seedColorValue,
  }) {
    return AppAppearance(
      mode: mode ?? this.mode,
      seedColorValue: seedColorValue ?? this.seedColorValue,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppAppearance &&
        other.mode == mode &&
        other.seedColorValue == seedColorValue;
  }

  @override
  int get hashCode => Object.hash(mode, seedColorValue);
}
