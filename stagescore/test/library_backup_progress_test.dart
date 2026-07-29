import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/library/library_backup.dart';

void main() {
  test('pdf and png entries are stored; json is deflated', () async {
    final source = await Directory.systemTemp.createTemp('ss_comp_');
    final zipDir = await Directory.systemTemp.createTemp('ss_compzip_');
    addTearDown(() async {
      for (final d in [source, zipDir]) {
        if (await d.exists()) await d.delete(recursive: true);
      }
    });

    await File(p.join(source.path, 'scores', 'a.pdf'))
        .create(recursive: true)
        .then((f) => f.writeAsBytes(List.filled(256, 1)));
    await File(p.join(source.path, 'thumbs', 'a.png'))
        .create(recursive: true)
        .then((f) => f.writeAsBytes(List.filled(64, 2)));
    await File(p.join(source.path, 'annotations', 'a.json'))
        .create(recursive: true)
        .then((f) => f.writeAsString('{"strokes":[]}'))
        .then((_) {});
    await File(
      p.join(source.path, 'library.json'),
    ).writeAsString('{"scores":[{"id":"a","title":"Alpha"}]}');

    final zip = File(p.join(zipDir.path, 'backup.zip'));
    await const LibraryBackup().createBackup(libraryRoot: source, zipFile: zip);

    final archive = ZipDecoder().decodeBytes(await zip.readAsBytes());
    CompressionType? pdfType;
    CompressionType? pngType;
    CompressionType? jsonType;
    for (final entry in archive) {
      if (!entry.isFile) continue;
      final name = entry.name;
      if (name.endsWith('.pdf')) pdfType = entry.compression;
      if (name.endsWith('.png')) pngType = entry.compression;
      if (name.endsWith('.json') && name.contains('annotations')) {
        jsonType = entry.compression;
      }
    }
    expect(pdfType, CompressionType.none);
    expect(pngType, CompressionType.none);
    expect(jsonType, CompressionType.deflate);
  });

  test('progress is monotonic and ends at 1.0', () async {
    final source = await Directory.systemTemp.createTemp('ss_prog_');
    final zipDir = await Directory.systemTemp.createTemp('ss_progzip_');
    addTearDown(() async {
      for (final d in [source, zipDir]) {
        if (await d.exists()) await d.delete(recursive: true);
      }
    });

    for (var i = 0; i < 5; i++) {
      await File(p.join(source.path, 'scores', '$i.pdf'))
          .create(recursive: true)
          .then((f) => f.writeAsBytes(List.filled(100 + i * 20, i)));
      await File(p.join(source.path, 'annotations', '$i.json'))
          .create(recursive: true)
          .then((f) => f.writeAsString('{"i":$i}'));
    }
    await File(p.join(source.path, 'library.json')).writeAsString('{"scores":[]}');

    final fractions = <double>[];
    final zip = File(p.join(zipDir.path, 'backup.zip'));
    await const LibraryBackup().createBackup(
      libraryRoot: source,
      zipFile: zip,
      onProgress: (p) => fractions.add(p.fraction),
    );

    expect(fractions, isNotEmpty);
    expect(fractions.last, 1.0);
    for (var i = 1; i < fractions.length; i++) {
      expect(fractions[i], greaterThanOrEqualTo(fractions[i - 1]));
    }
  });

  test('cancel leaves no zip or part at destination', () async {
    final source = await Directory.systemTemp.createTemp('ss_cancel_');
    final zipDir = await Directory.systemTemp.createTemp('ss_cancelzip_');
    addTearDown(() async {
      for (final d in [source, zipDir]) {
        if (await d.exists()) await d.delete(recursive: true);
      }
    });

    // Enough files that cancel mid-progress is reachable.
    for (var i = 0; i < 30; i++) {
      await File(p.join(source.path, 'scores', '$i.pdf'))
          .create(recursive: true)
          .then((f) => f.writeAsBytes(Uint8List(8192)));
    }
    await File(p.join(source.path, 'library.json')).writeAsString('{"scores":[]}');

    final zip = File(p.join(zipDir.path, 'backup.zip'));
    final token = LibraryBackupCancelToken();
    var sawProgress = false;

    await expectLater(
      () => const LibraryBackup().createBackup(
        libraryRoot: source,
        zipFile: zip,
        cancelToken: token,
        onProgress: (p) {
          if (p.fraction > 0 && !sawProgress) {
            sawProgress = true;
            token.cancel();
          }
        },
      ),
      throwsA(isA<LibraryBackupCancelledException>()),
    );

    expect(await zip.exists(), isFalse);
    expect(await File('${zip.path}.part').exists(), isFalse);
  });

  test('legacy fully-deflated ZIP still restores', () async {
    final library = await Directory.systemTemp.createTemp('ss_legacy_');
    final zipDir = await Directory.systemTemp.createTemp('ss_legacyzip_');
    addTearDown(() async {
      for (final d in [library, zipDir]) {
        if (await d.exists()) await d.delete(recursive: true);
      }
    });

    await File(p.join(library.path, 'library.json')).writeAsString('stale');

    final staging = await Directory.systemTemp.createTemp('ss_legacystage_');
    addTearDown(() async {
      if (await staging.exists()) await staging.delete(recursive: true);
    });
    await File(p.join(staging.path, 'scores', 'old.pdf'))
        .create(recursive: true)
        .then((f) => f.writeAsBytes([7, 7, 7]));
    await File(p.join(staging.path, 'annotations', 'old.json'))
        .create(recursive: true)
        .then((f) => f.writeAsString('{"strokes":[1]}'));
    await File(p.join(staging.path, LibraryBackup.markerFileName)).writeAsString(
      '{"format":"${LibraryBackup.formatId}","version":${LibraryBackup.formatVersion}}',
    );
    await File(p.join(staging.path, 'library.json')).writeAsString('{"scores":[]}');

    final zip = File(p.join(zipDir.path, 'old-style.zip'));
    final encoder = ZipFileEncoder()..create(zip.path);
    // Default level = deflate for every file (pre-0050 behaviour).
    await encoder.addDirectory(staging, includeDirName: false);
    await encoder.close();

    await const LibraryBackup().restoreBackup(
      zipFile: zip,
      libraryRoot: library,
    );

    expect(
      await File(p.join(library.path, 'scores', 'old.pdf')).readAsBytes(),
      [7, 7, 7],
    );
    expect(
      await File(p.join(library.path, 'annotations', 'old.json')).readAsString(),
      '{"strokes":[1]}',
    );
  });
}
