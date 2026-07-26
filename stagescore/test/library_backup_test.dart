import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/library/library_backup.dart';

void main() {
  test('backup then restore preserves score PDF and annotation JSON', () async {
    final source = await Directory.systemTemp.createTemp('ss_src_');
    final dest = await Directory.systemTemp.createTemp('ss_dst_');
    final zipDir = await Directory.systemTemp.createTemp('ss_zip_');
    addTearDown(() async {
      for (final d in [source, dest, zipDir]) {
        if (await d.exists()) await d.delete(recursive: true);
      }
    });

    final pdfRel = p.join('scores', 'abc.pdf');
    final annRel = p.join('annotations', 'abc.json');
    await File(
      p.join(source.path, pdfRel),
    ).create(recursive: true).then((f) => f.writeAsBytes([1, 2, 3, 4]));
    await File(
      p.join(source.path, annRel),
    ).create(recursive: true).then((f) => f.writeAsString('{"strokes":[]}'));
    await File(
      p.join(source.path, 'library.json'),
    ).writeAsString('{"scores":[]}');

    final zip = File(p.join(zipDir.path, 'backup.zip'));
    await const LibraryBackup().createBackup(libraryRoot: source, zipFile: zip);
    expect(await zip.exists(), isTrue);

    await File(p.join(dest.path, 'library.json')).writeAsString('stale');

    await const LibraryBackup().restoreBackup(zipFile: zip, libraryRoot: dest);

    expect(await File(p.join(dest.path, pdfRel)).readAsBytes(), [1, 2, 3, 4]);
    expect(
      await File(p.join(dest.path, annRel)).readAsString(),
      '{"strokes":[]}',
    );
    expect(
      await File(p.join(dest.path, LibraryBackup.markerFileName)).exists(),
      isTrue,
    );
  });

  test(
    'restore rejects ZIP without marker and leaves library intact',
    () async {
      final library = await Directory.systemTemp.createTemp('ss_lib_');
      final zipDir = await Directory.systemTemp.createTemp('ss_badzip_');
      addTearDown(() async {
        for (final d in [library, zipDir]) {
          if (await d.exists()) await d.delete(recursive: true);
        }
      });

      final keep = File(p.join(library.path, 'library.json'));
      await keep.writeAsString('keep-me');

      final zip = File(p.join(zipDir.path, 'not-standscore.zip'));
      final encoder = ZipFileEncoder()..create(zip.path);
      final tmp = File(p.join(zipDir.path, 'readme.txt'));
      await tmp.writeAsBytes([9]);
      await encoder.addFile(tmp, 'readme.txt');
      await encoder.close();

      await expectLater(
        () => const LibraryBackup().restoreBackup(
          zipFile: zip,
          libraryRoot: library,
        ),
        throwsA(isA<LibraryBackupException>()),
      );
      expect(await keep.readAsString(), 'keep-me');
    },
  );
}
