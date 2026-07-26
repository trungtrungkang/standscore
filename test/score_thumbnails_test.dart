import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:standscore/library/score_thumbnails.dart';

void main() {
  late Directory temp;
  late Directory cacheDir;
  late int renders;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('standscore_thumbs_');
    cacheDir = Directory(p.join(temp.path, 'cache'));
    renders = 0;
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  Future<File> writePdf(String name, {String bytes = 'one'}) async {
    final file = File(p.join(temp.path, name));
    await file.writeAsString(bytes);
    return file;
  }

  ScoreThumbnails thumbnails({bool renderable = true}) {
    return ScoreThumbnails(
      cacheDir: cacheDir,
      render: (path, {int width = 240}) async {
        renders++;
        return renderable ? Uint8List.fromList([1, 2, 3]) : null;
      },
    );
  }

  test('renders once, then answers from cache', () async {
    final pdf = await writePdf('a.pdf');
    final cache = thumbnails();

    expect(await cache.thumbnail(scoreId: 'a', pdf: pdf), isNotNull);
    expect(await cache.thumbnail(scoreId: 'a', pdf: pdf), isNotNull);
    expect(renders, 1);
  });

  test('a fresh instance reads the cache off disk', () async {
    final pdf = await writePdf('a.pdf');
    await thumbnails().thumbnail(scoreId: 'a', pdf: pdf);
    renders = 0;

    expect(await thumbnails().thumbnail(scoreId: 'a', pdf: pdf), isNotNull);
    expect(renders, 0);
  });

  test('replacing the PDF under the same Score id re-renders', () async {
    final pdf = await writePdf('a.pdf');
    await thumbnails().thumbnail(scoreId: 'a', pdf: pdf);

    // What Replace PDF (0024) and Restore (0027) do: same id, new bytes.
    await pdf.writeAsString('two');
    await pdf.setLastModified(DateTime.now().add(const Duration(minutes: 1)));
    renders = 0;
    final cache = thumbnails();
    expect(await cache.thumbnail(scoreId: 'a', pdf: pdf), isNotNull);

    expect(renders, 1);
    final files = cacheDir.listSync().whereType<File>();
    expect(files.length, 1, reason: 'the stale render should be swept');
  });

  test('evict removes the Score from disk and memory', () async {
    final pdf = await writePdf('a.pdf');
    final cache = thumbnails();
    await cache.thumbnail(scoreId: 'a', pdf: pdf);

    await cache.evict('a');

    expect(cacheDir.listSync(), isEmpty);
    renders = 0;
    await cache.thumbnail(scoreId: 'a', pdf: pdf);
    expect(renders, 1);
  });

  test('an unrenderable PDF costs one attempt, not one per scroll', () async {
    final pdf = await writePdf('bad.pdf');
    final cache = thumbnails(renderable: false);

    expect(await cache.thumbnail(scoreId: 'bad', pdf: pdf), isNull);
    expect(await cache.thumbnail(scoreId: 'bad', pdf: pdf), isNull);
    expect(renders, 1);
  });

  test('a missing file answers null without rendering', () async {
    final cache = thumbnails();
    final missing = File(p.join(temp.path, 'gone.pdf'));

    expect(await cache.thumbnail(scoreId: 'gone', pdf: missing), isNull);
    expect(renders, 0);
  });
}
