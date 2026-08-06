// A PDF's table of contents, read as the structured metadata the file already
// carries (Spec 0052). It never looks at the pixels of a page: deriving piece
// boundaries from the image is OMR, which ADR 0006 and ADR 0019 keep closed.
//
// Same contract as pdf_first_page.dart, for the same reason: a missing, corrupt
// or password-protected file answers null instead of throwing, and callers take
// this as an injected function so they test without a PDF engine.

import 'package:pdfrx/pdfrx.dart';
import 'package:stagescore/library/outline_split.dart';

/// Reads a PDF's outline, or answers null when the file cannot be read.
typedef PdfOutlineLoader = Future<List<OutlineEntry>?> Function(String path);

/// The outline of the PDF at [path], or null if it cannot be read.
///
/// A file with no table of contents is not a failure — it answers an empty
/// list, which the split screen shows as an unmarked grid.
Future<List<OutlineEntry>?> loadPdfOutline(String path) async {
  PdfDocument? doc;
  try {
    doc = await PdfDocument.openFile(path);
    return _toEntries(await doc.loadOutline());
  } catch (_) {
    return null;
  } finally {
    await doc?.dispose();
  }
}

List<OutlineEntry> _toEntries(List<PdfOutlineNode> nodes) => [
  for (final node in nodes)
    OutlineEntry(
      title: node.title,
      // A chapter heading that points nowhere keeps its place in the tree: its
      // children are the pieces, and dropping the node would drop them too.
      pageNumber: node.dest?.pageNumber,
      children: _toEntries(node.children),
    ),
];
