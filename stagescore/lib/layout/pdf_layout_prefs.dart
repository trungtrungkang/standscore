import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:stagescore/layout/pdf_layout_mode.dart';

class PdfLayoutPrefs {
  /// [mode] defaults to One page (Spec 0056). Auto used to be the default for
  /// a new install (0041 decision 3), but on the most common device shape it
  /// silently resolved to the Half Page peek — a layout the musician never
  /// picked. A new install now opens on the simplest mode; Auto stays fully
  /// pickable from the Layout sheet.
  const PdfLayoutPrefs({this.mode = PdfLayoutMode.single});

  final PdfLayoutMode mode;

  PdfLayoutPrefs copyWith({PdfLayoutMode? mode}) =>
      PdfLayoutPrefs(mode: mode ?? this.mode);

  Map<String, dynamic> toJson() => {'mode': mode.name};

  factory PdfLayoutPrefs.fromJson(Map<String, dynamic> json) {
    return PdfLayoutPrefs(
      mode: PdfLayoutMode.values.firstWhere(
        (m) => m.name == json['mode'],
        // A file with no readable mode keeps the pre-Auto default too.
        orElse: () => PdfLayoutMode.single,
      ),
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
