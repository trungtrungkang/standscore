import 'dart:io';

import 'package:stagescore/annotation/annotation_store.dart';

/// Union of root ink with every child's ink for all-pages viewing (Spec 0055).
///
/// Display only: the returned store is never persisted. Callers keep writing
/// through the root's own [AnnotationPersistence].
Future<AnnotationStore> buildAllPagesNotesUnion({
  required Directory root,
  required AnnotationStore rootStore,
  required List<String> pieceScoreIds,
}) async {
  final union = AnnotationStore();
  union.importAllFrom(rootStore);
  for (final id in pieceScoreIds) {
    final piece = AnnotationStore();
    await AnnotationPersistence(root: root, scoreId: id).loadInto(piece);
    union.importAllFrom(piece);
  }
  return union;
}
