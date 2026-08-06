import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/layout/half_page.dart';
import 'package:stagescore/layout/pdf_layout_mode.dart';
import 'package:stagescore/layout/pdf_layout_prefs.dart';

void main() {
  test('isHalfPageLayoutMode', () {
    expect(isHalfPageLayoutMode(PdfLayoutMode.halfPageTopBottom), isTrue);
    expect(isHalfPageLayoutMode(PdfLayoutMode.halfPageLeftRight), isTrue);
    expect(isHalfPageLayoutMode(PdfLayoutMode.single), isFalse);
  });

  test('PdfLayoutPrefs round-trips half-page mode', () async {
    final dir = await Directory.systemTemp.createTemp('half_page_prefs_');
    addTearDown(() => dir.delete(recursive: true));
    final store = PdfLayoutPrefsStore(root: dir);
    await store.save(const PdfLayoutPrefs(mode: PdfLayoutMode.halfPageLeftRight));
    final loaded = await store.load();
    expect(loaded.mode, PdfLayoutMode.halfPageLeftRight);
  });
}
