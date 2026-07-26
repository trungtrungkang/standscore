import 'dart:io';

import 'package:flutter/material.dart';
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

  group('applyPageColorFilter', () {
    test('off leaves the colour alone', () {
      expect(
        applyPageColorFilter(Colors.white, PageColorFilterMode.off),
        Colors.white,
      );
    });

    test('invert turns paper white into black', () {
      final inverted = applyPageColorFilter(
        Colors.white,
        PageColorFilterMode.invert,
      );
      expect(inverted, const Color(0xFF000000));
    });

    test('sepia warms paper white', () {
      final sepia = applyPageColorFilter(
        Colors.white,
        PageColorFilterMode.sepia,
      );
      // Red and green saturate on white, so only blue drops — exactly what
      // the filtered page shows in its white areas.
      expect(sepia.b, lessThan(sepia.g));
      expect(sepia.g, 1.0);
      expect(sepia.a, 1.0);
    });

    test('matches what the page filter paints', () {
      // Same matrix as PageColorFiltered, so surround and page stay in step.
      final matrix = PageColorFilterMode.green.colorMatrix!;
      final expectedRed =
          (matrix[0] * 255 + matrix[1] * 255 + matrix[2] * 255 + matrix[4])
              .clamp(0.0, 255.0)
              .round();
      final surround = applyPageColorFilter(
        Colors.white,
        PageColorFilterMode.green,
      );
      expect((surround.r * 255).round(), expectedRed);
    });
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
