import 'package:flutter/material.dart';

/// App chrome appearance mode (Spec 0026 / P2.10).
enum AppThemeMode { system, light, dark }

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
  const AppAppearance({required this.mode, required this.seedColorValue});

  /// Primary BackingScore brand accent (`#EA6B24` / `#C8A856`).
  static const int brandOrangeValue = 0xFFEA6B24;
  static const int brandGoldValue = 0xFFC8A856;

  static const AppAppearance defaults = AppAppearance(
    mode: AppThemeMode.system,
    seedColorValue: brandOrangeValue,
  );

  /// BackingScore ecosystem accent presets.
  static const List<int> presetSeedValues = [
    brandOrangeValue, // BackingScore Orange
    brandGoldValue,   // BackingScore Metallic Gold
    0xFF2563EB,       // Royal Blue
    0xFF059669,       // Stage Emerald
    0xFFDC2626,       // Crimson
    0xFF7C3AED,       // Deep Violet
    0xFF475569,       // Slate Grey
  ];

  final AppThemeMode mode;
  final int seedColorValue;

  Color get seedColor => Color(seedColorValue);

  ThemeMode get themeMode => mode.themeMode;

  ThemeData themeData(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    final colorScheme = isDark
        ? baseScheme.copyWith(
            surface: const Color(0xFF121212),
            onSurface: const Color(0xFFFAFAFA),
            surfaceContainer: const Color(0xFF18181B),
            surfaceContainerHigh: const Color(0xFF27272A),
            outline: const Color(0xFF3F3F46),
            primary: seedColor,
          )
        : baseScheme;

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? const Color(0xFF09090B) : null,
      useMaterial3: true,
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  AppAppearance copyWith({AppThemeMode? mode, int? seedColorValue}) {
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
