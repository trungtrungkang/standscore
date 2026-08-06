import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/pdf_document.dart';

/// One piece of music: a run of pages within a PdfDocument (Spec 0052).
///
/// Before 0052 a Score owned a file outright via `relativePath`. It now names a
/// PdfDocument and, optionally, which pages of it are this piece — so a
/// 200-page collection can hold many Scores that each sort, filter, annotate and
/// join Setlists like any other.
///
/// Since 0055 a Score may also **contain** child Scores: the root
/// (`parentId == null`) is the Library row for the whole file; children point
/// at it and each hold a PageExtent. There is no domain type `Piece` — a child
/// is a Score; "piece" is UI copy only (ADR 0019, decision 11 revision 6).
class Score {
  const Score({
    required this.id,
    required this.title,
    required this.pdfDocumentId,
    required this.createdAt,
    this.pageExtent,
    this.parentId,
    this.lastOpenedAt,
  });

  final String id;
  final String title;

  /// The PdfDocument holding this piece's pages.
  final String pdfDocumentId;

  /// Which pages of the document are this piece, or null for all of them.
  ///
  /// Null is the ordinary case — a Score imported from its own PDF — and it is
  /// not the same as an extent covering the whole file: null means "whatever
  /// this document turns out to be", which is what migration can record
  /// without opening a single PDF to learn its length. A root that has been
  /// split also keeps null: that is the whole-file Score *Open full score*
  /// opens (Spec 0055).
  final PageExtent? pageExtent;

  /// Id of the parent Score, or null when this Score is a root.
  ///
  /// One definition of "root": `parentId == null`. Children never nest — a
  /// resplit of a child produces siblings under the same parent (Spec 0055).
  final String? parentId;

  final DateTime createdAt;
  final DateTime? lastOpenedAt;

  /// Whether this Score is a Library root (`parentId == null`).
  bool get isRoot => parentId == null;

  /// Pages in this piece, given its document, or null while the document's
  /// length is still unknown.
  ///
  /// Computed, never stored: an extent already says how long the piece is, and
  /// a second stored copy is a pair of values free to disagree on the one
  /// number every Library row displays (Spec 0052, G3 #4).
  int? pageCountIn(PdfDocument? document) =>
      pageExtent?.length ?? document?.pageCount;

  /// This piece's pages in a file that turned out to be [documentPageCount]
  /// pages long — for whoever has just opened the PDF and knows better than the
  /// manifest does.
  ///
  /// Clamped, because a stored extent can outlive the file it described: Replace
  /// PDF can hand a Score a shorter one. Null in the two cases where there is
  /// nothing honest to show: a file that would not open, and an extent that
  /// starts past the end of the file it has left. Neither may fall back to the
  /// whole document — that is how a piece silently becomes the book.
  PageExtent? extentIn(int documentPageCount) {
    if (documentPageCount < 1) return null;
    final extent = pageExtent;
    if (extent == null) return PageExtent.whole(documentPageCount);
    return extent.clampedTo(documentPageCount);
  }

  /// Absolute document page for the piece's first page — what the thumbnail
  /// renders, and the reason 24 pieces of one book no longer share one image.
  int get firstAbsolutePage => pageExtent?.firstPage ?? 1;

  Score copyWith({
    String? title,
    DateTime? lastOpenedAt,
    String? pdfDocumentId,
    PageExtent? pageExtent,
    bool clearPageExtent = false,
    String? parentId,
    bool clearParentId = false,
  }) {
    return Score(
      id: id,
      title: title ?? this.title,
      pdfDocumentId: pdfDocumentId ?? this.pdfDocumentId,
      createdAt: createdAt,
      pageExtent: clearPageExtent ? null : (pageExtent ?? this.pageExtent),
      parentId: clearParentId ? null : (parentId ?? this.parentId),
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'pdfDocumentId': pdfDocumentId,
    'pageExtent': pageExtent?.toJson(),
    if (parentId != null) 'parentId': parentId,
    'createdAt': createdAt.toIso8601String(),
    'lastOpenedAt': lastOpenedAt?.toIso8601String(),
  };

  factory Score.fromJson(Map<String, dynamic> json) {
    final extent = json['pageExtent'] as Map<String, dynamic>?;
    return Score(
      id: json['id'] as String,
      title: json['title'] as String,
      pdfDocumentId: json['pdfDocumentId'] as String,
      pageExtent: extent == null ? null : PageExtent.fromJson(extent),
      parentId: json['parentId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastOpenedAt: json['lastOpenedAt'] == null
          ? null
          : DateTime.parse(json['lastOpenedAt'] as String),
    );
  }
}

/// Scores whose [Score.parentId] is null — the default Library list (Spec 0055).
List<Score> rootsOnly(Iterable<Score> scores) =>
    [for (final score in scores) if (score.isRoot) score];

/// Children of [rootId], ordered by first page then title then id.
List<Score> childrenOfRoot(Iterable<Score> scores, String rootId) {
  final children = [
    for (final score in scores)
      if (score.parentId == rootId) score,
  ];
  children.sort((a, b) {
    final byPage = a.firstAbsolutePage.compareTo(b.firstAbsolutePage);
    if (byPage != 0) return byPage;
    final byTitle = a.title.toLowerCase().compareTo(b.title.toLowerCase());
    return byTitle != 0 ? byTitle : a.id.compareTo(b.id);
  });
  return children;
}
