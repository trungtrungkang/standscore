import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:path/path.dart' as p;
import 'package:stagescore/jumplink/jump_link.dart';
import 'package:uuid/uuid.dart';

/// Per-Score JumpLink persistence under `standscore/jumplinks/<scoreId>.json`.
class JumpLinkStore {
  JumpLinkStore({required Directory root, required this.scoreId, Uuid? uuid})
    : _file = File(p.join(root.path, 'jumplinks', '$scoreId.json')),
      _uuid = uuid ?? const Uuid();

  final String scoreId;
  final File _file;
  final Uuid _uuid;

  Future<List<JumpLink>> list() async {
    if (!await _file.exists()) return <JumpLink>[];
    final json = jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
    final list = json['jumpLinks'] as List<dynamic>? ?? const [];
    final links = list
        .map((e) => JumpLink.fromJson(e as Map<String, dynamic>))
        .toList();
    links.sort((a, b) {
      final byOrigin = a.originPage.compareTo(b.originPage);
      if (byOrigin != 0) return byOrigin;
      return a.createdAt.compareTo(b.createdAt);
    });
    return links;
  }

  Future<List<JumpLink>> forPage(int originPage) async {
    final all = await list();
    return all.where((l) => l.originPage == originPage).toList();
  }

  Future<JumpLink> add({
    required int originPage,
    required int destinationPage,
    Rect? normRect,
    int? colorValue,
  }) async {
    final link = JumpLink(
      id: _uuid.v4(),
      originPage: originPage,
      destinationPage: destinationPage,
      normRect: normRect ?? defaultJumpLinkNormRect(),
      colorValue: colorValue ?? defaultJumpLinkColorValue,
      createdAt: DateTime.now().toUtc(),
    );
    final items = [...await list(), link];
    await _write(items);
    return link;
  }

  Future<void> update(JumpLink link) async {
    final items = await list();
    final index = items.indexWhere((l) => l.id == link.id);
    if (index < 0) return;
    items[index] = link;
    await _write(items);
  }

  Future<void> delete(String id) async {
    final items = await list();
    items.removeWhere((l) => l.id == id);
    await _write(items);
  }

  Future<void> _write(List<JumpLink> links) async {
    await _file.parent.create(recursive: true);
    final payload = {
      'scoreId': scoreId,
      'jumpLinks': links.map((l) => l.toJson()).toList(),
    };
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
  }
}
