import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:standscore/library/score_library.dart';
import 'package:standscore/library/shared_pdf_import.dart';

void main() {
  late Directory temp;
  late ScoreLibrary library;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('share_in_');
    library = ScoreLibrary(root: temp);
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test('isPdfPath accepts pdf names and file URLs', () {
    const importer = SharedPdfImport();
    expect(importer.isPdfPath('/tmp/chart.pdf'), isTrue);
    expect(importer.isPdfPath('file:///tmp/chart.PDF'), isTrue);
    expect(importer.isPdfPath('/tmp/notes.txt'), isFalse);
    expect(importer.isPdfPath('/tmp/archive.zip'), isFalse);
  });

  test('importPaths imports PDFs and skips non-PDFs', () async {
    final pdf = File(p.join(temp.path, 'incoming', 'Solo.pdf'));
    await pdf.parent.create(recursive: true);
    await pdf.writeAsBytes([0x25, 0x50, 0x44, 0x46]);
    final txt = File(p.join(temp.path, 'incoming', 'notes.txt'));
    await txt.writeAsString('hi');

    final imported = await const SharedPdfImport().importPaths(
      library: library,
      paths: [pdf.path, txt.path, '/missing/nope.pdf'],
    );

    expect(imported, hasLength(1));
    expect(imported.single.title, 'Solo');
    expect(await library.listScores(), hasLength(1));
  });
}
