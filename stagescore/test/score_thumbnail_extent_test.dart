import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/library/score_thumbnails.dart';

/// The thumbnail cache keys on mtime, and editing a PageExtent does not touch
/// the file — so without the page in the key a re-extented Score would keep
/// showing the old cover forever (Spec 0052).
void main() {
  late Directory temp;
  late Directory cacheDir;
  var renders = 0;
  final renderedPages = <int>[];

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('thumb_extent_test');
    cacheDir = Directory(p.join(temp.path, 'cache'));
    renders = 0;
    renderedPages.clear();
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  ScoreThumbnails thumbnails() => ScoreThumbnails(
    cacheDir: cacheDir,
    render: (path, {int width = 240, int pageNumber = 1}) async {
      renders++;
      renderedPages.add(pageNumber);
      return Uint8List.fromList([pageNumber]);
    },
  );

  Future<File> writePdf(String name) async {
    final file = File(p.join(temp.path, name));
    await file.writeAsString('pdf');
    return file;
  }

  test('a new PageExtent re-renders even though the file never changed', () async {
    final pdf = await writePdf('book.pdf');
    final cache = thumbnails();
    final before = await pdf.stat();

    expect(await cache.thumbnail(scoreId: 'a', pdf: pdf, pageNumber: 1), [1]);
    expect(await cache.thumbnail(scoreId: 'a', pdf: pdf, pageNumber: 12), [12]);

    expect(renders, 2);
    expect(renderedPages, [1, 12]);
    expect(
      (await pdf.stat()).modified,
      before.modified,
      reason: 'the extent moved, the file did not',
    );
  });

  test('the same page still answers from cache', () async {
    final pdf = await writePdf('book.pdf');
    final cache = thumbnails();

    await cache.thumbnail(scoreId: 'a', pdf: pdf, pageNumber: 12);
    await cache.thumbnail(scoreId: 'a', pdf: pdf, pageNumber: 12);

    expect(renders, 1);
  });

  test('pieces of one book get their own picture, not the cover', () async {
    final pdf = await writePdf('book.pdf');
    final cache = thumbnails();

    final first = await cache.thumbnail(scoreId: 'a', pdf: pdf, pageNumber: 1);
    final seventh = await cache.thumbnail(
      scoreId: 'g',
      pdf: pdf,
      pageNumber: 49,
    );

    expect(first, isNot(seventh));
    expect(renderedPages, [1, 49]);
  });

  test('evicting a Score drops every page it cached', () async {
    final pdf = await writePdf('book.pdf');
    final cache = thumbnails();
    await cache.thumbnail(scoreId: 'a', pdf: pdf, pageNumber: 1);
    await cache.thumbnail(scoreId: 'a', pdf: pdf, pageNumber: 12);

    await cache.evict('a');

    await cache.thumbnail(scoreId: 'a', pdf: pdf, pageNumber: 1);
    expect(renders, 3, reason: 'nothing survived the eviction');
  });
}
