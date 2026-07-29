import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/theme/app_appearance.dart';
import 'package:stagescore/theme/app_tokens.dart';

/// The token layer and the component themes built on it (Spec 0044).
void main() {
  group('token scales', () {
    test('spacing steps ascend with no duplicate', () {
      expect(AppSpacing.steps, [4, 8, 12, 16, 24]);
      expect(AppSpacing.steps.toSet(), hasLength(AppSpacing.steps.length));
      for (var i = 1; i < AppSpacing.steps.length; i++) {
        expect(AppSpacing.steps[i], greaterThan(AppSpacing.steps[i - 1]));
      }
    });

    test('radius steps ascend with no duplicate', () {
      expect(AppRadius.steps, [4, 8, 12]);
      expect(AppRadius.steps.toSet(), hasLength(AppRadius.steps.length));
      for (var i = 1; i < AppRadius.steps.length; i++) {
        expect(AppRadius.steps[i], greaterThan(AppRadius.steps[i - 1]));
      }
    });

    test('the FAB clearance stays a measurement, not a step', () {
      expect(kFabScrollClearance, 88);
      expect(AppSpacing.steps, isNot(contains(kFabScrollClearance)));
    });
  });

  group('component themes', () {
    for (final brightness in Brightness.values) {
      test('every sheet inherits a drag handle in $brightness', () {
        final theme = AppAppearance.defaults.themeData(brightness);

        expect(theme.bottomSheetTheme.showDragHandle, isTrue);
        // Without this a scrolling list paints over Material's rounded corners.
        expect(theme.bottomSheetTheme.clipBehavior, Clip.antiAlias);
        // Material's own 28 on a bottom sheet is left alone.
        expect(theme.bottomSheetTheme.shape, isNull);
      });

      test('chips are pinned to the corner scale in $brightness', () {
        final theme = AppAppearance.defaults.themeData(brightness);
        final shape = theme.chipTheme.shape as RoundedRectangleBorder;

        expect(shape.borderRadius, BorderRadius.circular(AppRadius.sm));
        expect(theme.chipTheme.padding, const EdgeInsets.all(AppSpacing.sm));
      });
    }

    /// The component themes must be built from the running `ColorScheme`, not
    /// from colours typed in by hand — otherwise dark mode and every accent a
    /// musician picks in Appearance (Spec 0026) become a second palette that
    /// nobody remembers to update.
    test('no component theme carries a hand-written brand colour', () {
      const purple = 0xFF6A1B9A;
      final appearance = AppAppearance.defaults.copyWith(
        seedColorValue: purple,
      );

      for (final brightness in Brightness.values) {
        final theme = appearance.themeData(brightness);
        final colours = <Color?>[
          theme.bottomSheetTheme.backgroundColor,
          theme.bottomSheetTheme.dragHandleColor,
          theme.bottomSheetTheme.surfaceTintColor,
          theme.chipTheme.backgroundColor,
          theme.chipTheme.selectedColor,
          theme.chipTheme.checkmarkColor,
        ];

        expect(
          colours.whereType<Color>().map((c) => c.toARGB32()),
          isNot(contains(AppAppearance.brandTealValue)),
          reason:
              'A component theme pinned brand teal instead of reading the '
              'ColorScheme, so the accent chosen in Appearance is ignored '
              '(Spec 0026 / 0044).',
        );
      }
    });
  });
}
