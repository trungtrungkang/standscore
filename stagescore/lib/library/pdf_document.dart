/// A PDF file in the library, owned by one or more Scores (Spec 0052).
///
/// Before 0052 a Score *was* its file. A fake book or an etude collection is
/// one file holding many pieces, so the file became its own entity and Score
/// became a piece within one, delimited by a PageExtent.
///
/// Since 0055 the Library row for a split book is the **root Score**, not this
/// entity. PdfDocument still holds `title` as a fallback / sync target when the
/// root is renamed, but it never appears as a row, never opens, and never
/// enters a Setlist (ADR 0019, decision 11 revision 6).
class PdfDocument {
  const PdfDocument({
    required this.id,
    required this.relativePath,
    required this.importedAt,
    this.pageCount,
    this.originalFileName,
    this.title,
  });

  final String id;

  /// Path relative to the library root.
  ///
  /// Two layouts coexist on purpose and permanently: documents migrated from
  /// before 0052 keep `scores/<scoreId>.pdf`, new imports write
  /// `documents/<docId>.pdf`. Migration moves no bytes, because moving files is
  /// the one step that could fail halfway through a multi-gigabyte library and
  /// leave nothing openable. Always read this field; never rebuild the path
  /// from the id.
  final String relativePath;

  final DateTime importedAt;

  /// Pages in the file, or null until counted.
  ///
  /// Stored, unlike `Score.pageCount`, because it is a property of the file and
  /// learning it means opening the PDF. Nullable for the same reason it was on
  /// Score before 0052: the Library list must render before every file on disk
  /// has been read.
  final int? pageCount;

  /// File name as imported. Kept even after the book is renamed: it is the fact
  /// of where these bytes came from, which a rename does not change.
  final String? originalFileName;

  /// Name the musician gave the book, or null to go by the file name.
  ///
  /// Nullable rather than defaulted at import so that "never renamed" stays
  /// distinguishable from "renamed to exactly the file name" — and so an old
  /// manifest needs no migration to read (Spec 0054).
  final String? title;

  /// What a person should see this book called.
  ///
  /// The extension goes: a header row names a book, not a file. Spec 0053 had
  /// argued the opposite — that `.pdf` earns its place because the file is the
  /// answer to "where did this piece come from" — and that held only while the
  /// file name was the one name the app knew (Spec 0054, G3 #2).
  // The "Untitled book" fallback below stays a plain English literal on
  // purpose (not an ARB key): it flows through pure model-layer functions
  // with no `BuildContext` (`splitScore`, `buildLibraryRows`, sort keys) that
  // ~40 existing tests call directly, and it only fires when a PdfDocument
  // has neither a `title` nor a usable `originalFileName` — a defensive
  // default, not a string a musician is expected to see routinely.
  String get displayName {
    final named = title?.trim();
    if (named != null && named.isNotEmpty) return named;
    final file = originalFileName?.trim();
    if (file == null || file.isEmpty) return 'Untitled book';
    // Only `.pdf`, and only as a suffix: every file here is a PDF, so that is
    // the one ending that carries no meaning. Anything else a musician typed is
    // part of the name — a book called "Vol. 2" must not come back as "Vol".
    if (file.length > 4 && file.toLowerCase().endsWith('.pdf')) {
      return file.substring(0, file.length - 4);
    }
    return file;
  }

  /// Whether this book has a name of its own, rather than the placeholder.
  ///
  /// A book with nothing to call itself is not offered as a filter source: a
  /// chip reading "Untitled book" narrows the Library to something the musician
  /// cannot recognise (Spec 0053, and still true after 0054 gave books names).
  bool get hasOwnName =>
      (title?.trim().isNotEmpty ?? false) ||
      (originalFileName?.trim().isNotEmpty ?? false);

  /// Every caller must go through here rather than rebuilding the object.
  ///
  /// `replacePdf` used to construct a `PdfDocument` field by field, which meant
  /// every field added later was silently dropped by the one path that changes
  /// a file's bytes — a rename lost on Replace PDF, with no error and no red
  /// test. The two `clear` flags exist because `null` has to mean "leave it
  /// alone" for the other callers: renaming to nothing goes back to the file
  /// name, and a file whose pages could not be counted must not keep the old
  /// count.
  PdfDocument copyWith({
    int? pageCount,
    String? relativePath,
    String? title,
    bool clearTitle = false,
    bool clearPageCount = false,
  }) => PdfDocument(
    id: id,
    relativePath: relativePath ?? this.relativePath,
    importedAt: importedAt,
    pageCount: clearPageCount ? null : (pageCount ?? this.pageCount),
    originalFileName: originalFileName,
    title: clearTitle ? null : (title ?? this.title),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'relativePath': relativePath,
    'importedAt': importedAt.toIso8601String(),
    'pageCount': pageCount,
    'originalFileName': originalFileName,
    'title': title,
  };

  factory PdfDocument.fromJson(Map<String, dynamic> json) => PdfDocument(
    id: json['id'] as String,
    relativePath: json['relativePath'] as String,
    importedAt: DateTime.parse(json['importedAt'] as String),
    pageCount: json['pageCount'] as int?,
    originalFileName: json['originalFileName'] as String?,
    title: json['title'] as String?,
  );
}
