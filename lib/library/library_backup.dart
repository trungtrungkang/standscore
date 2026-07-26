import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

/// Creates and restores StandScore library ZIP backups (Spec 0027 / P2.11).
class LibraryBackup {
  const LibraryBackup();

  static const markerFileName = 'standscore-backup.json';
  static const formatVersion = 1;
  static const formatId = 'standscore-backup';

  /// Writes a ZIP of [libraryRoot] (plus marker) to [zipFile].
  ///
  /// [zipFile] must not live inside [libraryRoot].
  Future<void> createBackup({
    required Directory libraryRoot,
    required File zipFile,
  }) async {
    await libraryRoot.create(recursive: true);
    await zipFile.parent.create(recursive: true);
    if (await zipFile.exists()) {
      await zipFile.delete();
    }

    // Marker lives on disk so restore leaves it in the library tree.
    final marker = File(p.join(libraryRoot.path, markerFileName));
    await marker.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'format': formatId,
        'version': formatVersion,
      }),
    );

    final encoder = ZipFileEncoder()..create(zipFile.path);
    try {
      await encoder.addDirectory(libraryRoot, includeDirName: false);
    } finally {
      await encoder.close();
    }
  }

  /// Replaces [libraryRoot] contents with the StandScore backup in [zipFile].
  ///
  /// Stages extract beside the library, validates the marker, then swaps.
  Future<void> restoreBackup({
    required File zipFile,
    required Directory libraryRoot,
  }) async {
    if (!await zipFile.exists()) {
      throw const LibraryBackupException('Backup file not found.');
    }

    final parent = libraryRoot.parent;
    await parent.create(recursive: true);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final staging = Directory(p.join(parent.path, '.standscore_restore_$stamp'));
    final aside = Directory(p.join(parent.path, '.standscore_aside_$stamp'));

    if (await staging.exists()) {
      await staging.delete(recursive: true);
    }
    await staging.create(recursive: true);

    try {
      await extractFileToDisk(zipFile.path, staging.path);
      await _validateMarker(staging);

      if (await aside.exists()) {
        await aside.delete(recursive: true);
      }
      if (await libraryRoot.exists()) {
        await libraryRoot.rename(aside.path);
      }
      await staging.rename(libraryRoot.path);

      if (await aside.exists()) {
        await aside.delete(recursive: true);
      }
    } catch (e) {
      // Best-effort rollback if we moved the live library aside.
      if (!await libraryRoot.exists() && await aside.exists()) {
        await aside.rename(libraryRoot.path);
      }
      if (await staging.exists()) {
        await staging.delete(recursive: true);
      }
      if (e is LibraryBackupException) rethrow;
      throw LibraryBackupException('Could not restore backup: $e');
    }
  }

  Future<void> _validateMarker(Directory root) async {
    final marker = File(p.join(root.path, markerFileName));
    if (!await marker.exists()) {
      throw const LibraryBackupException(
        'Not a StandScore backup (missing marker).',
      );
    }
    try {
      final json = jsonDecode(await marker.readAsString()) as Map<String, dynamic>;
      if (json['format'] != formatId) {
        throw const LibraryBackupException(
          'Not a StandScore backup (unknown format).',
        );
      }
      final version = json['version'];
      if (version is! int || version < 1 || version > formatVersion) {
        throw const LibraryBackupException(
          'Unsupported StandScore backup version.',
        );
      }
    } on LibraryBackupException {
      rethrow;
    } catch (_) {
      throw const LibraryBackupException(
        'Not a StandScore backup (corrupt marker).',
      );
    }
  }
}

class LibraryBackupException implements Exception {
  const LibraryBackupException(this.message);

  final String message;

  @override
  String toString() => message;
}
