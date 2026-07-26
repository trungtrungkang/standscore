import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:standscore/bookmark/bookmark.dart';
import 'package:uuid/uuid.dart';

/// Per-Score Bookmark persistence under `standscore/bookmarks/<scoreId>.json`.
class BookmarkStore {
  BookmarkStore({
    required Directory root,
    required this.scoreId,
    Uuid? uuid,
  })  : _file = File(p.join(root.path, 'bookmarks', '$scoreId.json')),
        _uuid = uuid ?? const Uuid();

  final String scoreId;
  final File _file;
  final Uuid _uuid;

  Future<List<Bookmark>> list() async {
    if (!await _file.exists()) return <Bookmark>[];
    final json = jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
    final list = json['bookmarks'] as List<dynamic>? ?? const [];
    final bookmarks = list
        .map((e) => Bookmark.fromJson(e as Map<String, dynamic>))
        .toList();
    bookmarks.sort((a, b) {
      final byPage = a.pageNumber.compareTo(b.pageNumber);
      if (byPage != 0) return byPage;
      return a.createdAt.compareTo(b.createdAt);
    });
    return bookmarks;
  }

  Future<Bookmark> add({
    required String title,
    required int pageNumber,
  }) async {
    final trimmed = title.trim();
    final bookmark = Bookmark(
      id: _uuid.v4(),
      title: trimmed.isEmpty ? 'Page $pageNumber' : trimmed,
      pageNumber: pageNumber,
      createdAt: DateTime.now().toUtc(),
    );
    final items = [...await list(), bookmark];
    await _write(items);
    return bookmark;
  }

  Future<void> rename(String id, String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    final items = await list();
    final index = items.indexWhere((b) => b.id == id);
    if (index < 0) return;
    items[index] = items[index].copyWith(title: trimmed);
    await _write(items);
  }

  Future<void> delete(String id) async {
    final items = await list();
    items.removeWhere((b) => b.id == id);
    await _write(items);
  }

  Future<void> _write(List<Bookmark> bookmarks) async {
    await _file.parent.create(recursive: true);
    final payload = {
      'scoreId': scoreId,
      'bookmarks': bookmarks.map((b) => b.toJson()).toList(),
    };
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
  }
}
