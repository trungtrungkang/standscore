import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/brand/brand.dart';

/// Where the brand is allowed to appear (Spec 0042).
///
/// Two invariants, one test. **The brand has one definition** — the rename that
/// shipped "StandScore" to the Android launcher happened because the name was a
/// literal in as many files as used it. And **the brand never reaches the
/// stand**: PdfMode and PerformanceMode stay silent, which the Spec asks for as
/// an automated guard rather than a line in a review checklist.
///
/// A source-level check on purpose: `PdfModeScreen` cannot be pumped at all
/// (pdfrx needs the native viewer — see `pdf_mode_chrome_layout_test.dart`), so
/// a widget-level assertion would have to characterise a stub and would prove
/// nothing about the screen that actually ships.
void main() {
  /// `brand.dart` defines the strings; the Library reads them. Nothing else,
  /// and in particular nothing reachable from a Score being played.
  const allowed = {
    'lib/brand/brand.dart',
    'lib/ui/about_sheet.dart',
    'lib/ui/library_screen.dart',
  };

  final markers = <String>[Brand.publisher, 'backingscore.com', 'Brand.'];

  test('brand strings live in brand.dart and are read only by the Library', () {
    final offenders = <String, String>{};

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path;
      if (allowed.contains(path)) continue;

      final source = entity.readAsStringSync();
      for (final marker in markers) {
        if (source.contains(marker)) offenders[path] = marker;
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Brand strings escaped the Library. Read them from Brand in '
          'lib/brand/brand.dart, and keep them out of anything a musician can '
          'reach while playing (Spec 0042).',
    );
  });

  test('the publisher spelling is the one ADR 0010 accepted', () {
    // The ampersand form is what backingscore.com ships; the compressed form
    // belongs to identifiers only.
    expect(Brand.publisher, 'Backing & Score');
    expect(Brand.siteUrl, startsWith('https://'));
    expect(Brand.supportUri.scheme, 'mailto');
  });
}
