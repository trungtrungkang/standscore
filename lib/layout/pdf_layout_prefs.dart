import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:standscore/layout/half_page.dart';
import 'package:standscore/layout/pdf_layout_mode.dart';

class PdfLayoutPrefs {
  const PdfLayoutPrefs({
    this.mode = PdfLayoutMode.single,
    this.halfPageSeparatorRatio = halfPageSeparatorDefault,
  });

  final PdfLayoutMode mode;

  /// Fraction of the viewport used for the next-page peek (Fixed / app-wide).
  final double halfPageSeparatorRatio;

  PdfLayoutPrefs copyWith({
    PdfLayoutMode? mode,
    double? halfPageSeparatorRatio,
  }) => PdfLayoutPrefs(
    mode: mode ?? this.mode,
    halfPageSeparatorRatio: halfPageSeparatorRatio != null
        ? clampHalfPageSeparatorRatio(halfPageSeparatorRatio)
        : this.halfPageSeparatorRatio,
  );

  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'halfPageSeparatorRatio': halfPageSeparatorRatio,
  };

  factory PdfLayoutPrefs.fromJson(Map<String, dynamic> json) {
    final ratio = (json['halfPageSeparatorRatio'] as num?)?.toDouble();
    return PdfLayoutPrefs(
      mode: PdfLayoutMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => PdfLayoutMode.single,
      ),
      halfPageSeparatorRatio: ratio == null
          ? halfPageSeparatorDefault
          : clampHalfPageSeparatorRatio(ratio),
    );
  }
}

class PdfLayoutPrefsStore {
  PdfLayoutPrefsStore({required Directory root})
    : _file = File(p.join(root.path, 'layout_prefs.json'));

  final File _file;

  Future<PdfLayoutPrefs> load() async {
    if (!await _file.exists()) return const PdfLayoutPrefs();
    final json = jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
    return PdfLayoutPrefs.fromJson(json);
  }

  Future<void> save(PdfLayoutPrefs prefs) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(prefs.toJson()),
    );
  }
}
