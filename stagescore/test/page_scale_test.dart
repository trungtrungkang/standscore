import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/layout/page_scale.dart';
import 'package:stagescore/layout/page_scale_prefs_store.dart';

void main() {
  test('resolve uses page → score → fixed inheritance', () {
    const prefs = PageScalePrefs(
      fixedScale: 1.0,
      scoreScales: {'a': 1.2},
      pageScales: {'a:3': 1.4},
    );
    expect(prefs.resolve(scoreId: 'a', sourcePage: 3), 1.4);
    expect(prefs.resolve(scoreId: 'a', sourcePage: 2), 1.2);
    expect(prefs.resolve(scoreId: 'b', sourcePage: 1), 1.0);
  });

  test('withEditedScale writes to the active edit scope', () {
    var prefs = const PageScalePrefs(editScope: PageScaleScope.fixed);
    prefs = prefs.withEditedScale(scoreId: 'a', sourcePage: 1, scale: 1.25);
    expect(prefs.fixedScale, 1.25);

    prefs = prefs.copyWith(editScope: PageScaleScope.perScore);
    prefs = prefs.withEditedScale(scoreId: 'a', sourcePage: 1, scale: 1.1);
    expect(prefs.scoreScales['a'], 1.1);
    expect(prefs.fixedScale, 1.25);

    prefs = prefs.copyWith(editScope: PageScaleScope.perPage);
    prefs = prefs.withEditedScale(scoreId: 'a', sourcePage: 2, scale: 0.8);
    expect(prefs.pageScales['a:2'], 0.8);
    expect(prefs.resolve(scoreId: 'a', sourcePage: 2), 0.8);
    expect(prefs.resolve(scoreId: 'a', sourcePage: 1), 1.1);
  });

  test('clampScale bounds values', () {
    expect(PageScalePrefs.clampScale(0.1), PageScalePrefs.minScale);
    expect(PageScalePrefs.clampScale(9), PageScalePrefs.maxScale);
  });

  test('prefs round-trip', () async {
    final root = await Directory.systemTemp.createTemp('page_scale_');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    const prefs = PageScalePrefs(
      editScope: PageScaleScope.perScore,
      locked: true,
      fixedScale: 1.1,
      scoreScales: {'s1': 1.2},
      pageScales: {'s1:2': 1.3},
    );
    await PageScalePrefsStore(root: root).save(prefs);
    expect(await PageScalePrefsStore(root: root).load(), prefs);
  });
}
