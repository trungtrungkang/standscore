// The two things the Library needs from a PDF it is not showing (Spec 0040):
// how long it is, and what it looks like. Both are allowed to fail — a file can
// be missing, corrupt or password-protected — so both answer null instead of
// throwing. This is the only place the Library layer touches pdfrx; everything
// upstream takes them as injected functions and tests without a PDF engine.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:pdfrx/pdfrx.dart';

/// Pages in the PDF at [path], or null if it cannot be read.
Future<int?> countPdfPages(String path) async {
  PdfDocument? doc;
  try {
    doc = await PdfDocument.openFile(path);
    return doc.pages.length;
  } catch (_) {
    return null;
  } finally {
    await doc?.dispose();
  }
}

/// PNG of one page of the PDF, [width] pixels wide, or null if it cannot be
/// rendered.
///
/// [pageNumber] is a 1-based absolute page of the file. It exists because a
/// Score is now a run of pages within a document (Spec 0052): always rendering
/// page 1 would give all twelve pieces of one book the same picture.
///
/// The whole page is rendered and the caller crops: cropping here would bake a
/// framing decision into the cache, and the file is small either way.
Future<Uint8List?> renderPdfFirstPagePng(
  String path, {
  int width = 240,
  int pageNumber = 1,
}) async {
  PdfDocument? doc;
  try {
    doc = await PdfDocument.openFile(path);
    if (doc.pages.isEmpty) return null;
    // A page number left over from a since-replaced, shorter file must not
    // throw; showing the first page is wrong but harmless, and the extent is
    // reported as truncated elsewhere.
    final index = (pageNumber - 1).clamp(0, doc.pages.length - 1);
    final page = doc.pages[index];
    if (page.width <= 0 || page.height <= 0) return null;
    final scale = width / page.width;
    final height = (page.height * scale).round();
    if (height <= 0) return null;

    final rendered = await page.render(
      fullWidth: page.width * scale,
      fullHeight: page.height * scale,
      width: width,
      height: height,
    );
    if (rendered == null) return null;
    final image = await rendered.createImage();
    rendered.dispose();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return bytes?.buffer.asUint8List();
  } catch (_) {
    return null;
  } finally {
    await doc?.dispose();
  }
}
