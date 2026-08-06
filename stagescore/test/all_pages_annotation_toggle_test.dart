import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/annotation/all_pages_notes.dart';
import 'package:stagescore/annotation/annotation_store.dart';
import 'package:stagescore/annotation/draw_tool.dart';

/// All-pages Show piece notes: union for display, never write children (0055).
void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('all_pages_notes_');
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  AnnotationStroke stroke(AnnotationStore store, int page) => store.createStroke(
    pageNumber: page,
    points: const [Offset(0.1, 0.1), Offset(0.2, 0.2)],
    tool: DrawTool.pen,
  );

  test('union shows root and child ink on absolute pages', () async {
    final rootStore = AnnotationStore();
    rootStore.addStroke(stroke(rootStore, 1));

    final childStore = AnnotationStore();
    childStore.addStroke(stroke(childStore, 12));
    await AnnotationPersistence(root: temp, scoreId: 'child').save(childStore);

    final union = await buildAllPagesNotesUnion(
      root: temp,
      rootStore: rootStore,
      pieceScoreIds: const ['child'],
    );

    expect(union.strokesForPage(1), hasLength(1));
    expect(union.strokesForPage(12), hasLength(1));
  });

  test('saving the root store does not rewrite a child file', () async {
    final childStore = AnnotationStore();
    childStore.addStroke(stroke(childStore, 3));
    await AnnotationPersistence(root: temp, scoreId: 'child').save(childStore);
    final childFile = File('${temp.path}/annotations/child.json');
    final before = await childFile.readAsString();

    final rootStore = AnnotationStore();
    rootStore.addStroke(stroke(rootStore, 1));
    await AnnotationPersistence(root: temp, scoreId: 'root').save(rootStore);

    await buildAllPagesNotesUnion(
      root: temp,
      rootStore: rootStore,
      pieceScoreIds: const ['child'],
    );

    expect(await childFile.readAsString(), before);
  });
}
