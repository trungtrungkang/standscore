import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:standscore/setlist/setlist.dart';
import 'package:uuid/uuid.dart';

/// Setlist persistence at `standscore/setlists.json` (Spec 0012).
class SetlistStore {
  SetlistStore({
    required Directory root,
    Uuid? uuid,
  })  : _file = File(p.join(root.path, 'setlists.json')),
        _uuid = uuid ?? const Uuid();

  final File _file;
  final Uuid _uuid;

  String newId() => _uuid.v4();

  Future<List<Setlist>> list() async {
    if (!await _file.exists()) return <Setlist>[];
    final json = jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
    final raw = json['setlists'] as List<dynamic>? ?? const [];
    final items = raw
        .map((e) => Setlist.fromJson(e as Map<String, dynamic>))
        .toList();
    items.sort((a, b) {
      final aKey = a.lastOpenedAt ?? a.createdAt;
      final bKey = b.lastOpenedAt ?? b.createdAt;
      return bKey.compareTo(aKey);
    });
    return items;
  }

  Future<void> upsert(Setlist setlist) async {
    final items = await list();
    final index = items.indexWhere((s) => s.id == setlist.id);
    if (index < 0) {
      items.add(setlist);
    } else {
      items[index] = setlist;
    }
    await _write(items);
  }

  Future<void> delete(String id) async {
    final items = await list();
    items.removeWhere((s) => s.id == id);
    await _write(items);
  }

  /// Strip [scoreId] from every Setlist; empty Setlists are kept (Spec 0028).
  Future<void> removeScoreFromAll(String scoreId) async {
    final items = await list();
    var changed = false;
    final next = <Setlist>[];
    for (final setlist in items) {
      final updated = setlist.removeScoreId(scoreId);
      if (updated.scoreIds.length != setlist.scoreIds.length) {
        changed = true;
      }
      next.add(updated);
    }
    if (changed) await _write(next);
  }

  Future<Setlist> markOpened(Setlist setlist) async {
    final updated = setlist.copyWith(lastOpenedAt: DateTime.now().toUtc());
    await upsert(updated);
    return updated;
  }

  Future<void> _write(List<Setlist> setlists) async {
    await _file.parent.create(recursive: true);
    final payload = {
      'setlists': setlists.map((s) => s.toJson()).toList(),
    };
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
  }
}
