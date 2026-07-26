import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfrx/pdfrx.dart';
import 'package:standscore/annotation/annotation_painter.dart';
import 'package:standscore/annotation/annotation_store.dart';
import 'package:standscore/annotation/stamp_painter.dart';

/// Builds a new PDF with ink + stamps flattened onto source pages (Spec 0020).
///
/// Does not mutate the imported PDF. Uses source page order.
class AnnotationExporter {
  const AnnotationExporter();

  /// Render scale relative to PDF points (72 dpi). 2.0 ≈ 144 dpi.
  Future<Uint8List> exportBytes({
    required PdfDocument document,
    required AnnotationStore store,
    double scale = 2.0,
  }) async {
    final out = pw.Document();
    for (final page in document.pages) {
      final png = await _renderAnnotatedPagePng(
        page: page,
        store: store,
        scale: scale,
      );
      final pageFormat = PdfPageFormat(page.width, page.height);
      out.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: pw.EdgeInsets.zero,
          build: (context) {
            return pw.Image(
              pw.MemoryImage(png),
              fit: pw.BoxFit.fill,
              width: page.width,
              height: page.height,
            );
          },
        ),
      );
    }
    return out.save();
  }

  Future<Uint8List> _renderAnnotatedPagePng({
    required PdfPage page,
    required AnnotationStore store,
    required double scale,
  }) async {
    final fullWidth = page.width * scale;
    final fullHeight = page.height * scale;
    final pixelW = fullWidth.round();
    final pixelH = fullHeight.round();
    final rendered = await page.render(
      fullWidth: fullWidth,
      fullHeight: fullHeight,
      width: pixelW,
      height: pixelH,
    );
    if (rendered == null) {
      throw StateError('Failed to render PDF page ${page.pageNumber}');
    }

    final base = await rendered.createImage();
    rendered.dispose();

    final size = Size(base.width.toDouble(), base.height.toDouble());
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Offset.zero & size);
    canvas.drawImage(base, Offset.zero, Paint());
    base.dispose();

    AnnotationPainter(
      strokes: store.strokesForPage(page.pageNumber),
      inProgress: null,
      pageSize: size,
    ).paint(canvas, size);

    StampPainter(
      stamps: store.stampsForPage(page.pageNumber),
      pageSize: size,
    ).paint(canvas, size);

    final picture = recorder.endRecording();
    final image = await picture.toImage(pixelW, pixelH);
    picture.dispose();

    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (bytes == null) {
      throw StateError('Failed to encode page ${page.pageNumber}');
    }
    return bytes.buffer.asUint8List();
  }
}

/// Builds a multi-page PDF from PNG page images (testable without pdfrx).
Future<Uint8List> pdfFromPngPages(
  List<Uint8List> pngPages, {
  double pageWidth = 200,
  double pageHeight = 280,
}) async {
  final out = pw.Document();
  for (final png in pngPages) {
    out.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(pageWidth, pageHeight),
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.Image(
            pw.MemoryImage(png),
            fit: pw.BoxFit.fill,
            width: pageWidth,
            height: pageHeight,
          );
        },
      ),
    );
  }
  return out.save();
}
