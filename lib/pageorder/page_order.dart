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
  });

  final List<PageOrderEntry> entries;

  /// Page count of the underlying PDF (for Reset / identity).
  final int sourcePageCount;

  int get length => entries.length;

  bool get isIdentity {
    if (entries.length != sourcePageCount) return false;
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      if (e.isBlank || e.sourcePage != i + 1) return false;
    }
    return true;
  }

  factory PageOrder.identity(int sourcePageCount) {
    final n = sourcePageCount < 0 ? 0 : sourcePageCount;
    return PageOrder(
      sourcePageCount: n,
      entries: [
        for (var i = 1; i <= n; i++) PageOrderEntry.pdf(i),
      ],
    );
  }

  PageOrder copyWithEntries(List<PageOrderEntry> entries) => PageOrder(
        entries: List.unmodifiable(entries),
        sourcePageCount: sourcePageCount,
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

  PageOrder resetToOriginal() => PageOrder.identity(sourcePageCount);

  Map<String, dynamic> toJson() => {
        'sourcePageCount': sourcePageCount,
        'entries': entries.map((e) => e.toJson()).toList(),
      };

  factory PageOrder.fromJson(Map<String, dynamic> json) {
    final sourcePageCount = json['sourcePageCount'] as int? ?? 0;
    final raw = json['entries'] as List<dynamic>? ?? const [];
    final entries = raw
        .map((e) => PageOrderEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    if (entries.isEmpty && sourcePageCount > 0) {
      return PageOrder.identity(sourcePageCount);
    }
    return PageOrder(
      sourcePageCount: sourcePageCount,
      entries: List.unmodifiable(entries),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PageOrder &&
      sourcePageCount == other.sourcePageCount &&
      _listEquals(entries, other.entries);

  @override
  int get hashCode => Object.hash(sourcePageCount, Object.hashAll(entries));
}

bool _listEquals(List<PageOrderEntry> a, List<PageOrderEntry> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
