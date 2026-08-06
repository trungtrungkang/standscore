import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:stagescore/pageorder/page_order.dart';

/// Per-Score PageOrder at `standscore/page_orders/<scoreId>.json`.
class PageOrderStore {
  PageOrderStore({required Directory root, required this.scoreId})
    : _file = File(p.join(root.path, 'page_orders', '$scoreId.json'));

  final String scoreId;
  final File _file;

  /// The stored order, or null when this Score has never had one.
  ///
  /// Separate from [loadOrIdentity] because "no file yet" and "a sequence the
  /// musician built" are different answers to the question an extent change
  /// asks: an identity order has nothing to lose (Spec 0052).
  Future<PageOrder?> loadStored() async {
    if (!await _file.exists()) return null;
    final json = jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
    return PageOrder.fromJson(json);
  }

  /// Load stored order, or the plain order over the Score's own pages.
  ///
  /// [sourceFirstPage] is the first absolute document page the Score covers —
  /// 1 unless it is one piece of a shared PDF (Spec 0052).
  Future<PageOrder> loadOrIdentity(
    int sourcePageCount, {
    int sourceFirstPage = 1,
  }) async {
    final loaded = await loadStored();
    if (loaded == null) {
      return PageOrder.forExtent(
        firstPage: sourceFirstPage,
        pageCount: sourcePageCount,
      );
    }
    // A count of zero means the piece has no pages we can point at right now —
    // the PDF would not open, or a replacement file is shorter than the extent.
    // Neither is a reason to throw away the sequence the musician built, so the
    // stored order waits for the file to come back.
    if (sourcePageCount < 1) return loaded;
    // The extent moved, or the PDF was replaced with one of a different length.
    // Keep the sequence the musician built, minus the slots that now point
    // outside the piece — a slot past the end is a page turn onto nothing.
    if (loaded.sourcePageCount != sourcePageCount ||
        loaded.sourceFirstPage != sourceFirstPage) {
      return loaded.restrictedTo(
        firstPage: sourceFirstPage,
        lastPage: sourceFirstPage + sourcePageCount - 1,
      );
    }
    return loaded;
  }

  Future<void> save(PageOrder order) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(order.toJson()),
    );
  }
}
