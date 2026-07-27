// Regenerates assets/sample_score.pdf, the placeholder Score behind the
// Library's "import sample" action. Empty staves on purpose: we ship no music
// we do not own.
//
//   dart run tool/generate_sample_score.dart
//
// The asset used to be an orphan binary carrying the pre-rename product name on
// every staff, which no text search could find (its content streams are
// compressed). Keep this script so the pages stay greppable through their source.
import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const _output = 'assets/sample_score.pdf';
const _pageCount = 6;
const _stavesPerPage = 4;
const _brandTeal = PdfColor.fromInt(0xFF0D8B86);

Future<void> main() async {
  final doc = pw.Document(title: 'StageScore sample score');

  for (var page = 1; page <= _pageCount; page++) {
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(48, 64, 48, 40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            for (var staff = 1; staff <= _stavesPerPage; staff++)
              _staff(page: page, staff: staff),
            pw.Spacer(),
            pw.Text(
              'StageScore sample · page $page of $_pageCount · not real music',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
      ),
    );
  }

  final file = File(_output);
  await file.writeAsBytes(await doc.save());
  stdout.writeln('wrote $_output ($_pageCount pages)');
}

pw.Widget _staff({required int page, required int staff}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 30),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          'StageScore sample · page $page / staff $staff',
          style: pw.TextStyle(fontSize: 9, color: _brandTeal),
        ),
        pw.SizedBox(height: 10),
        for (var line = 0; line < 5; line++) ...[
          pw.Container(height: 0.7, color: PdfColors.black),
          if (line < 4) pw.SizedBox(height: 7),
        ],
      ],
    ),
  );
}
