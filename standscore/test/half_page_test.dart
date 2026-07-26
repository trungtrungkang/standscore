import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/layout/half_page.dart';
import 'package:standscore/layout/pdf_layout_mode.dart';
import 'package:standscore/layout/pdf_layout_prefs.dart';

void main() {
  group('half page helpers', () {
    test('clampHalfPageSeparatorRatio', () {
      expect(clampHalfPageSeparatorRatio(0.01), halfPageSeparatorMin);
      expect(clampHalfPageSeparatorRatio(0.9), halfPageSeparatorMax);
      expect(clampHalfPageSeparatorRatio(0.3), 0.3);
    });

    test('halfPageNextPerformancePage null at end', () {
      expect(halfPageNextPerformancePage(currentPage: 3, pageCount: 3), isNull);
      expect(halfPageNextPerformancePage(currentPage: 2, pageCount: 3), 3);
      expect(halfPageNextPerformancePage(currentPage: 1, pageCount: 0), isNull);
    });

    test('isHalfPageLayoutMode', () {
      expect(isHalfPageLayoutMode(PdfLayoutMode.halfPageTopBottom), isTrue);
      expect(isHalfPageLayoutMode(PdfLayoutMode.halfPageLeftRight), isTrue);
      expect(isHalfPageLayoutMode(PdfLayoutMode.single), isFalse);
    });
  });

  test('PdfLayoutPrefs round-trips half-page mode + ratio', () async {
    final dir = await Directory.systemTemp.createTemp('half_page_prefs_');
    addTearDown(() => dir.delete(recursive: true));
    final store = PdfLayoutPrefsStore(root: dir);
    await store.save(
      const PdfLayoutPrefs(
        mode: PdfLayoutMode.halfPageLeftRight,
        halfPageSeparatorRatio: 0.35,
      ),
    );
    final loaded = await store.load();
    expect(loaded.mode, PdfLayoutMode.halfPageLeftRight);
    expect(loaded.halfPageSeparatorRatio, 0.35);
  });
}
