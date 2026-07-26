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

  /// Load stored order, or identity for [sourcePageCount] when missing.
  Future<PageOrder> loadOrIdentity(int sourcePageCount) async {
    if (!await _file.exists()) {
      return PageOrder.identity(sourcePageCount);
    }
    final json = jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
    final loaded = PageOrder.fromJson(json);
    // PDF replaced with different page count → prefer stored if non-empty,
    // but refresh sourcePageCount for Reset.
    if (loaded.sourcePageCount != sourcePageCount) {
      return PageOrder(
        entries: loaded.entries,
        sourcePageCount: sourcePageCount,
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
