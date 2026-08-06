import 'package:flutter/material.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/theme/app_tokens.dart';

/// App chrome appearance mode (Spec 0026 / P2.10).
enum AppThemeMode { system, light, dark }

extension AppThemeModeX on AppThemeMode {
  String label(AppLocalizations l10n) => switch (this) {
    AppThemeMode.system => l10n.themeModeSystem,
    AppThemeMode.light => l10n.themeModeLight,
    AppThemeMode.dark => l10n.themeModeDark,
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
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      // Every settings sheet advertises the same way out (Spec 0044). The flag
      // lives here rather than at the 19 call sites so a new sheet inherits it.
      // `clipBehavior` is the other half: without it a scrolling list paints
      // over Material's rounded top corners.
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        clipBehavior: Clip.antiAlias,
      ),
      // Pinned to the corner scale rather than overridden: these match Material
      // 3's own chip defaults today, so chips follow the scale if it is ever
      // retuned and look unchanged until then. Density stays a widget decision
      // — `ChipThemeData` has no field for it (Spec 0044, câu hỏi G3 số 6).
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        padding: const EdgeInsets.all(AppSpacing.sm),
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
