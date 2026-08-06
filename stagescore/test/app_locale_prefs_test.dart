import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/theme/app_locale_pref.dart';
import 'package:stagescore/theme/app_locale_prefs_store.dart';

void main() {
  test('default is System (null language code)', () {
    expect(AppLocalePref.system.isSystem, isTrue);
    expect(AppLocalePref.system.locale, isNull);
  });

  test('prefs round-trip a plain language and a language+country pair', () async {
    final root = await Directory.systemTemp.createTemp('locale_');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    final store = AppLocalePrefsStore(root: root);
    expect(await store.load(), AppLocalePref.system);

    const vi = AppLocalePref(languageCode: 'vi');
    await store.save(vi);
    expect(await AppLocalePrefsStore(root: root).load(), vi);

    const zhTw = AppLocalePref(languageCode: 'zh', countryCode: 'TW');
    await store.save(zhTw);
    expect(await AppLocalePrefsStore(root: root).load(), zhTw);
  });

  test('clearing back to System removes the override', () async {
    final root = await Directory.systemTemp.createTemp('locale_clear_');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    final store = AppLocalePrefsStore(root: root);
    await store.save(const AppLocalePref(languageCode: 'ja'));
    await store.save(AppLocalePref.system);
    expect(await store.load(), AppLocalePref.system);
  });

  test('missing or invalid prefs file falls back to System', () async {
    final root = await Directory.systemTemp.createTemp('locale_bad_');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    expect(await AppLocalePrefsStore(root: root).load(), AppLocalePref.system);

    final file = File('${root.path}/app_locale_prefs.json');
    await file.writeAsString('not json');
    expect(await AppLocalePrefsStore(root: root).load(), AppLocalePref.system);

    await file.writeAsString('{"languageCode":""}');
    expect(await AppLocalePrefsStore(root: root).load(), AppLocalePref.system);
  });

  test('endonym is not translated by the active locale', () {
    expect(endonymFor(AppLocalePref.supported[1]), 'Tiếng Việt');
    expect(
      endonymFor(const Locale('zh', 'TW')),
      '繁體中文',
    );
  });
}
