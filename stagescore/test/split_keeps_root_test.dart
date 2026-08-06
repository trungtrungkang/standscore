import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/library/score.dart';
import 'package:stagescore/library/score_library.dart';

/// splitScore keeps the root whole-file and makes children (Spec 0055).
void main() {
  late Directory temp;
  late ScoreLibrary library;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('split_root_');
    library = ScoreLibrary(root: temp, countPages: (path) async => 20);
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  Future<Score> importBook() async {
    final source = File(p.join(temp.path, 'Chopin Etudes.pdf'));
    await source.writeAsString('%PDF-1.4');
    return library.importPdf(
      sourcePath: source.path,
      originalFileName: 'Chopin Etudes.pdf',
    );
  }

  test('first split keeps the root id and pageExtent null', () async {
    final book = await importBook();
    final after = await library.splitScore(
      scoreId: book.id,
      marks: const [
        (startPage: 1, title: 'No. 1'),
        (startPage: 11, title: 'No. 2'),
      ],
    );

    expect(after, hasLength(3));
    final root = after.firstWhere((s) => s.id == book.id);
    expect(root.parentId, isNull);
    expect(root.pageExtent, isNull);
    expect(root.title, 'Chopin Etudes');
    final children = after.where((s) => s.parentId == book.id).toList();
    expect(children, hasLength(2));
    expect(children.map((c) => c.title).toList(), ['No. 1', 'No. 2']);
    expect(children.every((c) => c.pageExtent != null), isTrue);
  });

  test('resplit of a child stays one layer under the same root', () async {
    final book = await importBook();
    final first = await library.splitScore(
      scoreId: book.id,
      marks: const [
        (startPage: 1, title: 'First half'),
        (startPage: 11, title: 'Second half'),
      ],
    );
    final second = first.firstWhere((s) => s.title == 'Second half');

    final after = await library.splitScore(
      scoreId: second.id,
      marks: const [
        (startPage: 11, title: 'Two'),
        (startPage: 15, title: 'Three'),
      ],
    );

    expect(after.where((s) => s.parentId == null), hasLength(1));
    final children = after.where((s) => s.parentId == book.id).toList();
    expect(children, hasLength(3));
    expect(children.every((c) => c.parentId == book.id), isTrue);
    expect(
      after.where((s) => s.parentId != null && s.parentId != book.id),
      isEmpty,
      reason: 'a child must not grow children of its own',
    );
    // The piece being split keeps its id as the first sibling.
    expect(after.any((s) => s.id == second.id), isTrue);
    expect(
      after.firstWhere((s) => s.id == second.id).pageExtent?.firstPage,
      11,
    );
  });
}
