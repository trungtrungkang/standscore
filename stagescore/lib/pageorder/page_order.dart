import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// One slot in the performance sequence (Spec 0011).
class PageOrderEntry {
  const PageOrderEntry._({
    required this.id,
    required this.sourcePage,
    required this.isBlank,
  });

  factory PageOrderEntry.pdf(int sourcePage, {String? id}) {
    assert(sourcePage >= 1);
    return PageOrderEntry._(
      id: id ?? _uuid.v4(),
      sourcePage: sourcePage,
      isBlank: false,
    );
  }

  factory PageOrderEntry.blank({String? id}) {
    return PageOrderEntry._(
      id: id ?? _uuid.v4(),
      sourcePage: null,
      isBlank: true,
    );
  }

  final String id;

  /// 1-based PDF page when [isBlank] is false.
  final int? sourcePage;
  final bool isBlank;

  Map<String, dynamic> toJson() => isBlank
      ? {'id': id, 'type': 'blank'}
      : {'id': id, 'type': 'pdf', 'sourcePage': sourcePage};

  factory PageOrderEntry.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? _uuid.v4();
    if (json['type'] == 'blank') return PageOrderEntry.blank(id: id);
    return PageOrderEntry.pdf(json['sourcePage'] as int, id: id);
  }

  @override
  bool operator ==(Object other) => other is PageOrderEntry && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// User-defined performance page sequence for a Score.
class PageOrder {
  const PageOrder({
    required this.entries,
    required this.sourcePageCount,
    this.sourceFirstPage = 1,
  });

  final List<PageOrderEntry> entries;

  /// How many source pages the Score has — the length of its PageExtent, which
  /// is the length of the PDF only while a document holds a single Score.
  final int sourcePageCount;

  /// Absolute PdfDocument page the Score's own pages begin at (Spec 0052).
  ///
  /// 1 for a Score that is a whole file, which is why it has a default and is
  /// left out of the JSON: a library that never split anything keeps its page
  /// order files byte for byte.
  final int sourceFirstPage;

  int get sourceLastPage => sourceFirstPage + sourcePageCount - 1;

  int get length => entries.length;

  bool get isIdentity {
    if (entries.length != sourcePageCount) return false;
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      if (e.isBlank || e.sourcePage != sourceFirstPage + i) return false;
    }
    return true;
  }

  factory PageOrder.identity(int sourcePageCount) =>
      PageOrder.forExtent(firstPage: 1, pageCount: sourcePageCount);

  /// Every page of one run of a document, in file order (Spec 0052).
  factory PageOrder.forExtent({
    required int firstPage,
    required int pageCount,
  }) {
    final first = firstPage < 1 ? 1 : firstPage;
    final n = pageCount < 0 ? 0 : pageCount;
    return PageOrder(
      sourceFirstPage: first,
      sourcePageCount: n,
      entries: [for (var i = 0; i < n; i++) PageOrderEntry.pdf(first + i)],
    );
  }

  PageOrder copyWithEntries(List<PageOrderEntry> entries) => PageOrder(
    entries: List.unmodifiable(entries),
    sourcePageCount: sourcePageCount,
    sourceFirstPage: sourceFirstPage,
  );

  PageOrder move(int from, int to) {
    if (from < 0 || from >= entries.length) return this;
    if (to < 0 || to >= entries.length) return this;
    if (from == to) return this;
    final next = [...entries];
    final item = next.removeAt(from);
    next.insert(to, item);
    return copyWithEntries(next);
  }

  PageOrder duplicate(int index) {
    if (index < 0 || index >= entries.length) return this;
    final next = [...entries];
    final src = next[index];
    final copy = src.isBlank
        ? PageOrderEntry.blank()
        : PageOrderEntry.pdf(src.sourcePage!);
    next.insert(index + 1, copy);
    return copyWithEntries(next);
  }

  /// Removes entry; refuses to leave the sequence empty.
  PageOrder removeAt(int index) {
    if (index < 0 || index >= entries.length) return this;
    if (entries.length <= 1) return this;
    final next = [...entries]..removeAt(index);
    return copyWithEntries(next);
  }

  PageOrder insertBlank(int index) {
    final i = index.clamp(0, entries.length);
    final next = [...entries]..insert(i, PageOrderEntry.blank());
    return copyWithEntries(next);
  }

  PageOrder resetToOriginal() =>
      PageOrder.forExtent(firstPage: sourceFirstPage, pageCount: sourcePageCount);

  /// Slots pointing at a page outside `[firstPage, lastPage]`.
  ///
  /// Narrowing a PageExtent has to say how many slots it is about to drop
  /// *before* the musician confirms, not report it afterwards (Spec 0052).
  int slotsOutside({required int firstPage, required int lastPage}) => entries
      .where(
        (e) =>
            !e.isBlank &&
            (e.sourcePage! < firstPage || e.sourcePage! > lastPage),
      )
      .length;

  /// This sequence rebased on `[firstPage, lastPage]`, without the slots that
  /// now fall outside it.
  ///
  /// Blanks survive: they belong to the performance sequence, not to the paper.
  /// If nothing addressable is left, the piece falls back to its plain page
  /// order rather than to a run of blank pages.
  PageOrder restrictedTo({required int firstPage, required int lastPage}) {
    final count = lastPage - firstPage + 1;
    if (count < 1) {
      return PageOrder.forExtent(firstPage: firstPage, pageCount: 0);
    }
    final kept = [
      for (final e in entries)
        if (e.isBlank ||
            (e.sourcePage! >= firstPage && e.sourcePage! <= lastPage))
          e,
    ];
    if (!kept.any((e) => !e.isBlank)) {
      return PageOrder.forExtent(firstPage: firstPage, pageCount: count);
    }
    return PageOrder(
      entries: List.unmodifiable(kept),
      sourcePageCount: count,
      sourceFirstPage: firstPage,
    );
  }

  Map<String, dynamic> toJson() => {
    'sourcePageCount': sourcePageCount,
    if (sourceFirstPage != 1) 'sourceFirstPage': sourceFirstPage,
    'entries': entries.map((e) => e.toJson()).toList(),
  };

  factory PageOrder.fromJson(Map<String, dynamic> json) {
    final sourcePageCount = json['sourcePageCount'] as int? ?? 0;
    final sourceFirstPage = json['sourceFirstPage'] as int? ?? 1;
    final raw = json['entries'] as List<dynamic>? ?? const [];
    final entries = raw
        .map((e) => PageOrderEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    if (entries.isEmpty && sourcePageCount > 0) {
      return PageOrder.forExtent(
        firstPage: sourceFirstPage,
        pageCount: sourcePageCount,
      );
    }
    return PageOrder(
      sourcePageCount: sourcePageCount,
      sourceFirstPage: sourceFirstPage,
      entries: List.unmodifiable(entries),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PageOrder &&
      sourcePageCount == other.sourcePageCount &&
      sourceFirstPage == other.sourceFirstPage &&
      _listEquals(entries, other.entries);

  @override
  int get hashCode =>
      Object.hash(sourcePageCount, sourceFirstPage, Object.hashAll(entries));
}

bool _listEquals(List<PageOrderEntry> a, List<PageOrderEntry> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
