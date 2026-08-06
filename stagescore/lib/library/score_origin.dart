import 'package:stagescore/library/page_extent.dart';

/// "Pages 12–19 of Chopin Etudes.pdf", or null when the Score is a whole file.
///
/// Provenance shows up as one line and stops there. Giving the document a row
/// of its own would rebuild the file browser this app deliberately does not
/// have (ADR 0019, decision 11) — a Score is a piece of music, and the file it
/// came out of is a detail the musician can look up, not a thing to manage.
String? scoreOriginLine({
  required PageExtent? extent,
  required String? documentName,
  required int? documentPageCount,
}) {
  if (extent == null) return null;
  // A Score that happens to cover every page of its file is not "a piece of"
  // anything, so saying where it came from would only add noise.
  if (documentPageCount != null && extent.coversWholeDocument(documentPageCount)) {
    return null;
  }
  final pages = extent.length == 1
      ? 'Page ${extent.firstPage}'
      : 'Pages ${extent.firstPage}–${extent.lastPage}';
  final name = documentName?.trim();
  if (name == null || name.isEmpty) return pages;
  return '$pages of $name';
}
