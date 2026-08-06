/// The run of PdfDocument pages that belongs to one Score (Spec 0052).
///
/// Extent is *scope* — which pages are this piece — and it is not PageOrder,
/// which is *sequence*. PageOrder runs inside an extent: it may repeat a page,
/// insert a blank, or reorder, but every PDF page it names lies within the
/// extent. Mixing the two is the most expensive mistake available here, so the
/// types are deliberately not interchangeable.
///
/// Both bounds are 1-based and inclusive, matching the pdfrx page convention
/// already used by annotations and `PageOrderEntry.sourcePage`.
class PageExtent {
  const PageExtent({required this.firstPage, required this.lastPage});

  /// Whole document, for a Score that owns its PDF outright.
  factory PageExtent.whole(int pageCount) =>
      PageExtent(firstPage: 1, lastPage: pageCount < 1 ? 1 : pageCount);

  final int firstPage;
  final int lastPage;

  /// Pages in this piece. This is what the Library row shows, and it is
  /// arithmetic — never a second stored value that could drift from the bounds.
  int get length => lastPage - firstPage + 1;

  bool get isValid => firstPage >= 1 && lastPage >= firstPage;

  bool contains(int absolutePage) =>
      absolutePage >= firstPage && absolutePage <= lastPage;

  /// Absolute PdfDocument page → 1-based page within this piece, or null when
  /// the page lies outside. The relative number exists only for display; Spec
  /// 0052 forbids storing it, because it shifts when the extent changes.
  int? toRelative(int absolutePage) =>
      contains(absolutePage) ? absolutePage - firstPage + 1 : null;

  /// 1-based page within this piece → absolute PdfDocument page, or null when
  /// the piece is not that long.
  int? toAbsolute(int relativePage) {
    if (relativePage < 1 || relativePage > length) return null;
    return firstPage + relativePage - 1;
  }

  /// Extent clamped to a document of [pageCount] pages, or null when it no
  /// longer describes anything — which is what Replace PDF with a shorter file
  /// produces, and what must be reported rather than silently repaired.
  PageExtent? clampedTo(int pageCount) {
    if (pageCount < 1 || firstPage > pageCount) return null;
    if (lastPage <= pageCount) return this;
    return PageExtent(firstPage: firstPage, lastPage: pageCount);
  }

  bool coversWholeDocument(int pageCount) =>
      firstPage == 1 && lastPage == pageCount;

  PageExtent copyWith({int? firstPage, int? lastPage}) => PageExtent(
    firstPage: firstPage ?? this.firstPage,
    lastPage: lastPage ?? this.lastPage,
  );

  Map<String, dynamic> toJson() => {
    'firstPage': firstPage,
    'lastPage': lastPage,
  };

  factory PageExtent.fromJson(Map<String, dynamic> json) => PageExtent(
    firstPage: json['firstPage'] as int,
    lastPage: json['lastPage'] as int,
  );

  @override
  bool operator ==(Object other) =>
      other is PageExtent &&
      firstPage == other.firstPage &&
      lastPage == other.lastPage;

  @override
  int get hashCode => Object.hash(firstPage, lastPage);

  @override
  String toString() => 'PageExtent($firstPage–$lastPage)';
}
