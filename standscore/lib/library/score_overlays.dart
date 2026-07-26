import 'dart:io';

import 'package:path/path.dart' as p;

/// Per-Score overlay files cleared on Replace PDF → reset (Spec 0024).
///
/// Does not touch Labels or Setlists.
Future<void> clearScoreOverlays({
  required Directory root,
  required String scoreId,
}) async {
  final paths = [
    p.join(root.path, 'annotations', '$scoreId.json'),
    p.join(root.path, 'bookmarks', '$scoreId.json'),
    p.join(root.path, 'jumplinks', '$scoreId.json'),
    p.join(root.path, 'page_orders', '$scoreId.json'),
  ];
  for (final path in paths) {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

/// Overlay file paths for a Score (for tests / diagnostics).
List<String> scoreOverlayPaths({
  required Directory root,
  required String scoreId,
}) {
  return [
    p.join(root.path, 'annotations', '$scoreId.json'),
    p.join(root.path, 'bookmarks', '$scoreId.json'),
    p.join(root.path, 'jumplinks', '$scoreId.json'),
    p.join(root.path, 'page_orders', '$scoreId.json'),
  ];
}
