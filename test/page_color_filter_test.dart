import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/layout/page_color_filter.dart';
import 'package:standscore/layout/page_color_filter_prefs_store.dart';

void main() {
  test('off has no matrix; other modes provide 20-length matrices', () {
    expect(PageColorFilterMode.off.colorMatrix, isNull);
    expect(PageColorFilterMode.off.colorFilter, isNull);
    for (final mode in [
      PageColorFilterMode.sepia,
      PageColorFilterMode.green,
      PageColorFilterMode.invert,
    ]) {
      expect(mode.colorMatrix, hasLength(20));
      expect(mode.colorFilter, isNotNull);
    }
  });

  test('prefs round-trip', () async {
    final root = await Directory.systemTemp.createTemp('color_filter_');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    final store = PageColorFilterPrefsStore(root: root);
    expect(await store.load(), PageColorFilterMode.off);
    await store.save(PageColorFilterMode.sepia);
    expect(
      await PageColorFilterPrefsStore(root: root).load(),
      PageColorFilterMode.sepia,
    );
  });
}
