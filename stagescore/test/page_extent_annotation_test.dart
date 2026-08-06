import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/annotation/annotation_store.dart';
import 'package:stagescore/annotation/draw_tool.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/score_library.dart';

/// Narrowing a PageExtent hides annotations; it must never destroy them
/// (Spec 0052, G3 #5).
///
/// This is the whole reason annotations stay anchored to absolute document
/// pages: the ink on page 40 is still ink on page 40 whether or not the piece
/// currently claims that page, so widening the extent again brings it back
/// rather than reconstructing it.
void main() {
  late Directory temp;
  late ScoreLibrary library;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('extent_annotation_test');
    library = ScoreLibrary(root: temp, countPages: (path) async => 60);
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test('narrowing then widening an extent leaves the ink untouched', () async {
    final source = File(p.join(temp.path, 'Book.pdf'));
    await source.writeAsBytes(const [0x25, 0x50, 0x44, 0x46]);
    final book = await library.importPdf(
      sourcePath: source.path,
      originalFileName: 'Book.pdf',
    );

    final persistence = AnnotationPersistence(root: temp, scoreId: book.id);
    final store = AnnotationStore();
    store.addStroke(
      store.createStroke(
        pageNumber: 40,
        points: const [Offset(0.1, 0.1), Offset(0.2, 0.2)],
        tool: DrawTool.pen,
      ),
    );
    await persistence.save(store);
    final before = await File(
      p.join(temp.path, 'annotations', '${book.id}.json'),
    ).readAsString();

    await library.updatePageExtent(
      scoreId: book.id,
      extent: const PageExtent(firstPage: 1, lastPage: 20),
    );
    await library.updatePageExtent(
      scoreId: book.id,
      extent: const PageExtent(firstPage: 1, lastPage: 60),
    );

    final after = await File(
      p.join(temp.path, 'annotations', '${book.id}.json'),
    ).readAsString();
    expect(after, before, reason: 'changing scope may not rewrite the ink');

    final reloaded = AnnotationStore();
    await persistence.loadInto(reloaded);
    expect(reloaded.strokes.single.pageNumber, 40);
    expect(reloaded.strokes.single.points, hasLength(greaterThan(1)));
  });
}
