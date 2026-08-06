import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/library/library_backup.dart';
import 'package:stagescore/library/library_migration.dart';

/// Spec 0052 bumps `formatVersion` to 2, and the bump only protects one
/// direction: an older app refuses a newer file. The other direction — this
/// app opening a `version: 1` backup — has to keep working, because refusing
/// it would lose data for exactly the people careful enough to keep backups.
void main() {
  late Directory libraryRoot;
  late Directory zipDir;

  setUp(() async {
    libraryRoot = await Directory.systemTemp.createTemp('ss_ver_lib_');
    zipDir = await Directory.systemTemp.createTemp('ss_ver_zip_');
  });

  tearDown(() async {
    for (final d in [libraryRoot, zipDir]) {
      if (await d.exists()) await d.delete(recursive: true);
    }
  });

  /// A backup ZIP whose marker claims [version], carrying [manifest].
  Future<File> writeBackupZip({
    required int version,
    required String manifest,
  }) async {
    final staging = await Directory.systemTemp.createTemp('ss_ver_stage_');
    addTearDown(() async {
      if (await staging.exists()) await staging.delete(recursive: true);
    });
    await File(p.join(staging.path, 'library.json')).writeAsString(manifest);
    await File(
      p.join(staging.path, p.join('scores', 'abc.pdf')),
    ).create(recursive: true).then((f) => f.writeAsBytes([1, 2, 3, 4]));
    await File(
      p.join(staging.path, LibraryBackup.markerFileName),
    ).writeAsString(
      jsonEncode({'format': LibraryBackup.formatId, 'version': version}),
    );

    final zip = File(p.join(zipDir.path, 'backup-v$version.zip'));
    final encoder = ZipFileEncoder()..create(zip.path);
    await encoder.addDirectory(staging, includeDirName: false);
    await encoder.close();
    return zip;
  }

  test('the format id and marker name keep the old spelling', () {
    // Both are already written on users' disks; renaming them would make every
    // backup taken before the product rename unrestorable.
    expect(LibraryBackup.formatId, 'standscore-backup');
    expect(LibraryBackup.markerFileName, 'standscore-backup.json');
    expect(LibraryBackup.formatVersion, 2);
  });

  test('a version 1 backup restores and is migrated on the way in', () async {
    final zip = await writeBackupZip(
      version: 1,
      manifest: jsonEncode({
        'scores': [
          {
            'id': 'abc',
            'title': 'Old Piece',
            'relativePath': 'scores/abc.pdf',
            'createdAt': '2026-01-02T03:04:05.000Z',
            'pageCount': 4,
          },
        ],
      }),
    );

    await const LibraryBackup().restoreBackup(
      zipFile: zip,
      libraryRoot: libraryRoot,
    );

    final manifest =
        jsonDecode(
              await File(p.join(libraryRoot.path, 'library.json')).readAsString(),
            )
            as Map<String, dynamic>;

    expect(needsPdfDocumentMigration(manifest), isFalse);
    final documents = manifest[pdfDocumentsKey] as List<dynamic>;
    expect(documents.single['relativePath'], 'scores/abc.pdf');
    expect(documents.single['pageCount'], 4);
    final score = (manifest['scores'] as List<dynamic>).single;
    expect(score['pdfDocumentId'], 'abc');
    expect(score['title'], 'Old Piece');
    // The bytes came across too; migration is not a substitute for restore.
    expect(
      await File(p.join(libraryRoot.path, 'scores', 'abc.pdf')).readAsBytes(),
      [1, 2, 3, 4],
    );
  });

  test('a version 2 backup restores without being rewritten', () async {
    final payload = {
      'scores': [
        {
          'id': 's1',
          'title': 'Piece',
          'pdfDocumentId': 'd1',
          'pageExtent': {'firstPage': 12, 'lastPage': 19},
          'createdAt': '2026-01-02T03:04:05.000Z',
        },
      ],
      pdfDocumentsKey: [
        {
          'id': 'd1',
          'relativePath': 'scores/abc.pdf',
          'importedAt': '2026-01-02T03:04:05.000Z',
          'pageCount': 200,
          'originalFileName': 'Book.pdf',
        },
      ],
    };
    final zip = await writeBackupZip(version: 2, manifest: jsonEncode(payload));

    await const LibraryBackup().restoreBackup(
      zipFile: zip,
      libraryRoot: libraryRoot,
    );

    final manifest =
        jsonDecode(
              await File(p.join(libraryRoot.path, 'library.json')).readAsString(),
            )
            as Map<String, dynamic>;
    expect(manifest, payload);
  });

  test('a backup from a newer app is refused', () async {
    final zip = await writeBackupZip(version: 3, manifest: '{"scores":[]}');
    await File(p.join(libraryRoot.path, 'library.json')).writeAsString('keep');

    await expectLater(
      const LibraryBackup().restoreBackup(
        zipFile: zip,
        libraryRoot: libraryRoot,
      ),
      throwsA(
        isA<LibraryBackupException>().having(
          (e) => e.message,
          'message',
          'Unsupported StageScore backup version.',
        ),
      ),
    );
    expect(
      await File(p.join(libraryRoot.path, 'library.json')).readAsString(),
      'keep',
      reason: 'a refused restore leaves the library alone',
    );
  });
}
