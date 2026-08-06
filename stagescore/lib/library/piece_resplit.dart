/// Pure logic for redefining an already-split root's pieces from a fresh set
/// of marks ("Edit pieces", a Spec 0055 follow-up).
///
/// [splitScore] only ever *adds* children — the reason `_canSplit` refuses a
/// root that already has some (Spec 0055, G3 #10: one layer, resplit happens
/// on children). Edit pieces needs the opposite: replace the whole set with
/// one child per mark, while keeping a piece's id — and therefore every
/// annotation, bookmark, jump link, Label and Setlist membership keyed to
/// that id — wherever its exact page range survives unchanged.
library;

import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/score.dart';
import 'package:stagescore/library/score_library.dart' show SplitMark;

/// What [planPieceResplit] worked out: the next set of children to write, and
/// which former children did not survive.
class PieceResplitPlan {
  const PieceResplitPlan({required this.children, required this.removedIds});

  /// The full next set of children for the root, one per surviving mark.
  final List<Score> children;

  /// Ids of former children with no matching page range among the new marks.
  /// Whatever was keyed to them (annotations, bookmarks, jump links, Labels,
  /// Setlist membership) is about to be lost — the caller is expected to have
  /// warned about that before committing this plan.
  final List<String> removedIds;
}

/// Turns [marks] into a [PieceResplitPlan], matching against [oldChildren] by
/// exact `(firstPage, lastPage)` — not by title, not by position — so
/// reordering marks or renaming a piece never loses its data by accident.
///
/// Marks are clamped and de-duplicated the same way [splitScore]'s are.
/// Fewer than two surviving marks is not a valid resplit; the caller is
/// expected to have refused already, so this is a no-op returning
/// [oldChildren] unchanged.
PieceResplitPlan planPieceResplit({
  required List<Score> oldChildren,
  required List<SplitMark> marks,
  required PageExtent bounds,
  required String rootId,
  required String pdfDocumentId,
  required String bookTitle,
  required DateTime now,
  required String Function() nextId,
}) {
  final sorted = [...marks]..sort((a, b) => a.startPage.compareTo(b.startPage));
  final kept = <SplitMark>[];
  for (final mark in sorted) {
    final start = mark.startPage.clamp(bounds.firstPage, bounds.lastPage);
    if (kept.isNotEmpty && start <= kept.last.startPage) continue;
    kept.add((startPage: start, title: mark.title));
  }
  if (kept.length < 2) {
    return PieceResplitPlan(children: oldChildren, removedIds: const []);
  }

  final extents = [
    for (var i = 0; i < kept.length; i++)
      PageExtent(
        firstPage: kept[i].startPage,
        lastPage: i + 1 < kept.length
            ? kept[i + 1].startPage - 1
            : bounds.lastPage,
      ),
  ];

  final unmatched = [...oldChildren];
  final children = <Score>[];
  for (var i = 0; i < kept.length; i++) {
    final extent = extents[i];
    final matchIndex = unmatched.indexWhere((c) => c.pageExtent == extent);
    final title = kept[i].title.trim();
    if (matchIndex >= 0) {
      final match = unmatched.removeAt(matchIndex);
      children.add(
        match.copyWith(
          pageExtent: extent,
          title: title.isEmpty ? match.title : title,
        ),
      );
    } else {
      children.add(
        Score(
          id: nextId(),
          title: title.isEmpty ? '$bookTitle — ${i + 1}' : title,
          pdfDocumentId: pdfDocumentId,
          pageExtent: extent,
          parentId: rootId,
          createdAt: now,
        ),
      );
    }
  }
  return PieceResplitPlan(
    children: children,
    removedIds: [for (final c in unmatched) c.id],
  );
}
