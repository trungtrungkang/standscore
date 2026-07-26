import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/theme/app_appearance.dart';
import 'package:standscore/theme/app_appearance_prefs_store.dart';

void main() {
  test('defaults are system mode and brand teal', () {
    expect(AppAppearance.defaults.mode, AppThemeMode.system);
    expect(AppAppearance.defaults.seedColorValue, AppAppearance.brandTealValue);
    expect(AppAppearance.defaults.themeMode, ThemeMode.system);
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
