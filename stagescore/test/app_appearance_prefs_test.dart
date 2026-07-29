import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/theme/app_appearance.dart';
import 'package:stagescore/theme/app_appearance_prefs_store.dart';

void main() {
  test('defaults are system mode and brand teal', () {
    expect(AppAppearance.defaults.mode, AppThemeMode.system);
    expect(AppAppearance.defaults.seedColorValue, AppAppearance.brandTealValue);
    expect(AppAppearance.defaults.themeMode, ThemeMode.system);
  });

  /// The app shipped two teals for two years — `0xFF0D8B86` in the theme and
  /// the launcher, `0xFF0D9488` in the draw toolbar, a stamp outline and a
  /// JumpLink — because nine points of green is not something an eye catches
  /// (Spec 0044). One value now, and the only Dart file allowed to *define* it
  /// as the brand is `app_appearance.dart`; the other two mentions are content
  /// a musician can change, which is why they spell the number out instead of
  /// borrowing the brand constant.
  test('the brand teal has one definition and no second value', () {
    const brand = 'FF0D8B86';
    const secondTeal = '0D9488';
    const contentDefaults = {
      // A border colour offered in the Display sheet.
      'lib/layout/display_prefs.dart',
      // The colour a new JumpLink starts at.
      'lib/jumplink/jump_link.dart',
    };

    final definitions = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();

      expect(
        source,
        isNot(contains(secondTeal)),
        reason: '${entity.path} brought back the second teal (Spec 0044).',
      );
      if (source.toUpperCase().contains(brand) &&
          !contentDefaults.contains(entity.path)) {
        definitions.add(entity.path);
      }
    }

    expect(definitions, ['lib/theme/app_appearance.dart']);
  });

  test('prefs round-trip mode and accent', () async {
    final root = await Directory.systemTemp.createTemp('appearance_');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    final store = AppAppearancePrefsStore(root: root);
    expect(await store.load(), AppAppearance.defaults);

    const next = AppAppearance(
      mode: AppThemeMode.dark,
      seedColorValue: 0xFF1565C0,
    );
    await store.save(next);
    expect(await AppAppearancePrefsStore(root: root).load(), next);
  });

  test('invalid prefs fall back to defaults', () async {
    final root = await Directory.systemTemp.createTemp('appearance_bad_');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    final file = File('${root.path}/app_appearance_prefs.json');
    await file.writeAsString('{"mode":"nope","seedColor":"x"}');
    expect(
      await AppAppearancePrefsStore(root: root).load(),
      AppAppearance.defaults,
    );
  });
}
