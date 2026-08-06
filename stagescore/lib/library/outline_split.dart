/// Turning a PDF's table of contents into proposed piece boundaries (0052).
///
/// This reads **structured metadata the file already carries**. It never looks
/// at the pixels of a page: detecting boundaries from the image is OMR, which
/// ADR 0006 and ADR 0019 keep closed. The two look alike in their result and
/// are nothing alike in their input, and that line is worth keeping by reflex.
library;

/// One node of a PDF outline, flattened out of pdfrx's `PdfOutlineNode`.
///
/// Kept as a plain type so the flattening below is testable without a PDF
/// engine — the same idiom `PdfPageCounter` uses to keep the library layer off
/// pdfrx.
class OutlineEntry {
  const OutlineEntry({required this.title, this.pageNumber, this.children = const []});

  final String title;

  /// 1-based destination page, or null.
  ///
  /// Nullable because pdfrx returns no destination when the outline node has
  /// no view (`FPDFDest_GetView` type 0). A real file does contain such nodes,
  /// so this is a normal case, not a corrupt one.
  final int? pageNumber;

  /// An outline is a tree: a collection split into chapters nests its pieces
  /// one level down, and reading only the top level would lose all of them.
  final List<OutlineEntry> children;
}

/// A proposed piece: where it starts and what to call it.
typedef OutlineSplitProposal = ({int startPage, String title});

/// Flatten [outline] into one proposal per destination, in page order.
///
/// Nodes without a destination are skipped without losing their children —
/// a chapter heading that points nowhere still contains the pieces. Duplicate
/// start pages collapse to the first title, since two pieces cannot begin on
/// the same page and the outer entry is the more general name.
List<OutlineSplitProposal> proposeSplitFromOutline(
  List<OutlineEntry> outline,
) {
  final byPage = <int, String>{};

  void walk(List<OutlineEntry> nodes) {
    for (final node in nodes) {
      final page = node.pageNumber;
      final title = node.title.trim();
      if (page != null && page >= 1 && title.isNotEmpty) {
        byPage.putIfAbsent(page, () => title);
      }
      if (node.children.isNotEmpty) walk(node.children);
    }
  }

  walk(outline);

  final pages = byPage.keys.toList()..sort();
  return [for (final page in pages) (startPage: page, title: byPage[page]!)];
}

/// Whether a freshly imported file looks like a collection worth offering to
/// split (Spec 0052, G3 #6).
///
/// Deliberately a suggestion and never a question in the import flow: import
/// takes many files at once, so asking per file would turn one import of a
/// dozen pieces into a dozen dialogs.
bool looksLikeCollection({
  required int? pageCount,
  required List<OutlineSplitProposal> proposals,
}) => proposals.length >= 2 || (pageCount != null && pageCount > 30);
