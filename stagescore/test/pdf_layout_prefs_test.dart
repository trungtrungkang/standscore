import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/layout/pdf_layout_mode.dart';
import 'package:stagescore/layout/pdf_layout_prefs.dart';

void main() {
  test('pageTurnStepFor is 2 in twoPage mode', () {
    expect(pageTurnStepFor(PdfLayoutMode.twoPage), 2);
    expect(pageTurnStepFor(PdfLayoutMode.single), 1);
    expect(pageTurnStepFor(PdfLayoutMode.fitWidth), 1);
  });

  test('PdfLayoutPrefsStore round-trips', () async {
    final dir = await Directory.systemTemp.createTemp('layout_prefs_');
    addTearDown(() => dir.delete(recursive: true));
    final store = PdfLayoutPrefsStore(root: dir);
    await store.save(const PdfLayoutPrefs(mode: PdfLayoutMode.twoPage));
    final loaded = await store.load();
    expect(loaded.mode, PdfLayoutMode.twoPage);
  });
}
