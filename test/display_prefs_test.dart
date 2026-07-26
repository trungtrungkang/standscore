import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/layout/display_prefs.dart';
import 'package:standscore/layout/display_prefs_store.dart';

void main() {
  test('defaults match Spec 0032', () {
    const prefs = DisplayPrefs();
    expect(prefs.borderEnabled, isFalse);
    expect(prefs.borderWidth, DisplayPrefs.defaultBorderWidth);
    expect(prefs.borderColorValue, DisplayPrefs.defaultBorderColorValue);
    expect(prefs.showStatusBar, isFalse);
    expect(prefs.avoidNotches, isTrue);
  });

  test('performance mode defaults on (Spec 0034)', () {
    const prefs = DisplayPrefs();
    expect(prefs.performanceMode, isTrue);
    expect(
      DisplayPrefs.fromJson(const {'borderEnabled': true}).performanceMode,
      isTrue,
      reason: 'prefs saved before 0034 also get the stage default',
    );
    expect(
      DisplayPrefs.fromJson(const {'performanceMode': false}).performanceMode,
      isFalse,
    );
  });

  test('first-open chrome hint is one-shot (Spec 0034)', () {
    const prefs = DisplayPrefs();
    expect(prefs.performanceHintShown, isFalse);
    expect(
      prefs.copyWith(performanceHintShown: true).performanceHintShown,
      isTrue,
    );
  });

  test('clampBorderWidth bounds values', () {
    expect(DisplayPrefs.clampBorderWidth(0.1), DisplayPrefs.minBorderWidth);
    expect(DisplayPrefs.clampBorderWidth(99), DisplayPrefs.maxBorderWidth);
  });

  test('prefs round-trip', () async {
    final root = await Directory.systemTemp.createTemp('display_prefs_');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    const prefs = DisplayPrefs(
      borderEnabled: true,
      borderWidth: 3.5,
      borderColorValue: 0xFF0D8B86,
      showStatusBar: true,
      avoidNotches: false,
      performanceMode: false,
      performanceHintShown: true,
    );
    await DisplayPrefsStore(root: root).save(prefs);
    expect(await DisplayPrefsStore(root: root).load(), prefs);
  });
}
