import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/library/library_migration.dart';

/// Progress update for backup / restore (Spec 0050).
class BackupProgress {
  const BackupProgress({
    required this.fraction,
    this.label,
    this.canCancel = true,
  });

  /// Bytes completed over bytes total, clamped to \[0, 1\].
  final double fraction;

  /// Score title (or file label) currently being processed, when known.
  final String? label;

  /// False once restore has renamed the live library aside — Cancel must stop.
  final bool canCancel;
}

/// Cooperative cancel for [LibraryBackup.createBackup] / [restoreBackup].
///
/// Bound to the worker isolate after it starts; [cancel] is safe to call
/// before that (it sets a local flag the worker sees via the bound port).
class LibraryBackupCancelToken {
  bool _requested = false;
  SendPort? _isolatePort;

  bool get isRequested => _requested;

  void cancel() {
    _requested = true;
    _isolatePort?.send(null);
  }

  void _bind(SendPort port) {
    _isolatePort = port;
    if (_requested) {
      port.send(null);
    }
  }
}

/// Thrown when the musician cancels a backup or restore before it finishes.
class LibraryBackupCancelledException implements Exception {
  const LibraryBackupCancelledException();

  @override
  String toString() => 'Backup cancelled.';
}

/// Creates and restores StageScore library ZIP backups (Spec 0027 / P2.11).
///
/// Spec 0050: compression by extension, work off the UI isolate, byte
/// progress, cancel without leaving a truncated ZIP.
class LibraryBackup {
  const LibraryBackup();

  // These two keep the pre-rename `standscore` spelling on purpose: renaming
  // them would make every backup ZIP taken before the rename unrestorable.
  static const markerFileName = 'standscore-backup.json';

  /// Bumped to `2` by Spec 0052, when `library.json` grew a `pdfDocuments`
  /// list. Only an older app reading a newer backup is refused: the check is
  /// *newer than mine*, not *different from mine*, so a `version: 1` backup
  /// still restores here and is migrated straight afterwards. Refusing it
  /// would lose data for exactly the people who keep backups.
  static const formatVersion = 2;
  static const formatId = 'standscore-backup';

  /// Writes a ZIP of [libraryRoot] (plus marker) to [zipFile].
  ///
  /// [zipFile] must not live inside [libraryRoot]. Work runs in a worker
  /// isolate; progress and cancel travel through [onProgress] / [cancelToken].
  Future<void> createBackup({
    required Directory libraryRoot,
    required File zipFile,
    void Function(BackupProgress progress)? onProgress,
    LibraryBackupCancelToken? cancelToken,
  }) async {
    await libraryRoot.create(recursive: true);
    await zipFile.parent.create(recursive: true);

    final partPath = '${zipFile.path}.part';
    if (await File(partPath).exists()) {
      await File(partPath).delete();
    }

    final receivePort = ReceivePort();
    final args = <String, Object?>{
      'libraryRootPath': libraryRoot.path,
      'zipPath': zipFile.path,
      'partPath': partPath,
      'progressPort': receivePort.sendPort,
    };
    await _awaitIsolateJob(
      receivePort: receivePort,
      onProgress: onProgress,
      cancelToken: cancelToken,
      start: () => Isolate.run(() => _createBackupWorker(args)),
    );
  }

  /// Replaces [libraryRoot] contents with the StageScore backup in [zipFile].
  ///
  /// Stages extract beside the library, validates the marker, then swaps.
  /// Cancel is only honored before the live library is renamed aside.
  Future<void> restoreBackup({
    required File zipFile,
    required Directory libraryRoot,
    void Function(BackupProgress progress)? onProgress,
    LibraryBackupCancelToken? cancelToken,
  }) async {
    if (!await zipFile.exists()) {
      throw const LibraryBackupException(
        'Backup file not found.',
        code: LibraryBackupErrorCode.fileNotFound,
      );
    }

    final parent = libraryRoot.parent;
    await parent.create(recursive: true);
    final stamp = DateTime.now().millisecondsSinceEpoch;

    final receivePort = ReceivePort();
    final args = <String, Object?>{
      'zipPath': zipFile.path,
      'libraryRootPath': libraryRoot.path,
      'stagingPath': p.join(parent.path, '.standscore_restore_$stamp'),
      'asidePath': p.join(parent.path, '.standscore_aside_$stamp'),
      'progressPort': receivePort.sendPort,
    };
    await _awaitIsolateJob(
      receivePort: receivePort,
      onProgress: onProgress,
      cancelToken: cancelToken,
      start: () => Isolate.run(() => _restoreBackupWorker(args)),
    );
  }

  Future<void> _awaitIsolateJob({
    required ReceivePort receivePort,
    required Future<Map<String, Object?>> Function() start,
    void Function(BackupProgress progress)? onProgress,
    LibraryBackupCancelToken? cancelToken,
  }) async {
    final sub = receivePort.listen((message) {
      if (message is! Map) return;
      final type = message['type'];
      if (type == 'ready') {
        final port = message['cancelPort'];
        if (port is SendPort) {
          cancelToken?._bind(port);
        }
      } else if (type == 'progress') {
        onProgress?.call(
          BackupProgress(
            fraction: (message['fraction'] as num).toDouble(),
            label: message['label'] as String?,
            canCancel: message['canCancel'] as bool? ?? true,
          ),
        );
      }
    });

    try {
      final result = await start();
      final status = result['status'] as String?;
      if (status == 'cancelled') {
        throw const LibraryBackupCancelledException();
      }
      if (status == 'error') {
        throw LibraryBackupException(
          result['message'] as String? ?? 'Backup failed.',
          code: _errorCodeFromName(result['code'] as String?),
          detail: result['detail'] as String?,
        );
      }
    } finally {
      await sub.cancel();
      receivePort.close();
    }
  }
}

// --- Worker isolate entry points (top-level so Isolate.run can send them) ---

Future<Map<String, Object?>> _createBackupWorker(Map<String, Object?> args) async {
  final libraryRootPath = args['libraryRootPath']! as String;
  final zipPath = args['zipPath']! as String;
  final partPath = args['partPath']! as String;
  final progressPort = args['progressPort']! as SendPort;

  return _withCancelPort(progressPort, (isCancelled) async {
    final libraryRoot = Directory(libraryRootPath);
    final partFile = File(partPath);
    final zipFile = File(zipPath);

    ZipFileEncoder? encoder;
    try {
      // Marker lives on disk so restore leaves it in the library tree.
      final marker = File(p.join(libraryRootPath, LibraryBackup.markerFileName));
      await marker.writeAsString(
        const JsonEncoder.withIndent('  ').convert({
          'format': LibraryBackup.formatId,
          'version': LibraryBackup.formatVersion,
        }),
      );

      if (isCancelled()) {
        return _cancelledResult(partPath: partPath);
      }

      final titles = _loadScoreTitles(libraryRootPath);
      final files = <File>[];
      await for (final entity in libraryRoot.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          files.add(entity);
        }
      }

      var totalBytes = 0;
      final sizes = <File, int>{};
      for (final file in files) {
        final size = (await file.stat()).size;
        sizes[file] = size;
        totalBytes += size;
      }

      _sendProgress(progressPort, fraction: 0, label: null);

      final activeEncoder = ZipFileEncoder()..create(partPath);
      encoder = activeEncoder;
      var doneBytes = 0;

      for (final file in files) {
        if (isCancelled()) {
          await activeEncoder.close();
          encoder = null;
          return _cancelledResult(partPath: partPath);
        }

        final rel = _posixRel(file.path, libraryRootPath);
        await _addFileWithCompression(activeEncoder, file, rel);

        doneBytes += sizes[file] ?? 0;
        final fraction = totalBytes == 0 ? 1.0 : doneBytes / totalBytes;
        _sendProgress(
          progressPort,
          fraction: fraction.clamp(0.0, 1.0),
          label: _labelForRelativePath(rel, titles),
        );
      }

      await activeEncoder.close();
      encoder = null;

      if (isCancelled()) {
        return _cancelledResult(partPath: partPath);
      }

      if (await zipFile.exists()) {
        await zipFile.delete();
      }
      await partFile.rename(zipPath);

      _sendProgress(progressPort, fraction: 1, label: null);
      return {'status': 'ok'};
    } on LibraryBackupException catch (e) {
      await _safeCloseEncoder(encoder);
      await _deleteIfExists(partPath);
      return {'status': 'error', 'message': e.message, 'code': e.code.name};
    } catch (e) {
      await _safeCloseEncoder(encoder);
      await _deleteIfExists(partPath);
      return {
        'status': 'error',
        'message': 'Could not create backup: $e',
        'code': LibraryBackupErrorCode.createFailed.name,
        'detail': '$e',
      };
    }
  });
}

Future<Map<String, Object?>> _restoreBackupWorker(Map<String, Object?> args) async {
  final zipPath = args['zipPath']! as String;
  final libraryRootPath = args['libraryRootPath']! as String;
  final stagingPath = args['stagingPath']! as String;
  final asidePath = args['asidePath']! as String;
  final progressPort = args['progressPort']! as SendPort;

  return _withCancelPort(progressPort, (isCancelled) async {
    final staging = Directory(stagingPath);
    final aside = Directory(asidePath);
    final libraryRoot = Directory(libraryRootPath);

    try {
      if (await staging.exists()) {
        await staging.delete(recursive: true);
      }
      await staging.create(recursive: true);

      if (isCancelled()) {
        await _deleteIfExists(stagingPath);
        return {'status': 'cancelled'};
      }

      final input = InputFileStream(zipPath);
      final archive = ZipDecoder().decodeStream(input);
      await input.close();

      final titles = _titlesFromArchive(archive);
      final fileEntries = [
        for (final entry in archive)
          if (entry.isFile) entry,
      ];
      final totalBytes = fileEntries.fold<int>(0, (sum, e) => sum + e.size);
      var doneBytes = 0;

      _sendProgress(progressPort, fraction: 0, label: null);

      for (final entry in archive) {
        if (isCancelled()) {
          await archive.clear();
          await _deleteIfExists(stagingPath);
          return {'status': 'cancelled'};
        }

        final filePath = p.normalize(p.join(stagingPath, entry.name));
        if (!_isWithin(stagingPath, filePath)) {
          continue;
        }

        if (entry.isSymbolicLink) {
          continue;
        }

        if (entry.isDirectory) {
          await Directory(filePath).create(recursive: true);
          continue;
        }

        final output = OutputFileStream(filePath);
        try {
          entry.writeContent(output);
        } catch (_) {}
        await output.close();

        doneBytes += entry.size;
        final fraction = totalBytes == 0 ? 1.0 : doneBytes / totalBytes;
        _sendProgress(
          progressPort,
          fraction: (fraction * 0.95).clamp(0.0, 0.95),
          label: _labelForRelativePath(entry.name, titles),
        );
      }

      await archive.clear();
      await _validateMarkerAt(staging);

      if (isCancelled()) {
        await _deleteIfExists(stagingPath);
        return {'status': 'cancelled'};
      }

      // Point of no return — Cancel must disable (Spec 0050).
      _sendProgress(
        progressPort,
        fraction: 0.96,
        label: null,
        canCancel: false,
      );

      if (await aside.exists()) {
        await aside.delete(recursive: true);
      }
      if (await libraryRoot.exists()) {
        await libraryRoot.rename(asidePath);
      }
      await staging.rename(libraryRootPath);
      // A `version: 1` backup passes the marker check and carries a pre-0052
      // manifest, so it is migrated here rather than at the next app start:
      // one restore mid-session would otherwise hand a manifest with no
      // `pdfDocuments` to code that expects one.
      _migrateRestoredManifest(libraryRootPath);

      if (await aside.exists()) {
        await aside.delete(recursive: true);
      }

      _sendProgress(
        progressPort,
        fraction: 1,
        label: null,
        canCancel: false,
      );
      return {'status': 'ok'};
    } on LibraryBackupException catch (e) {
      await _rollbackRestore(
        libraryRootPath: libraryRootPath,
        stagingPath: stagingPath,
        asidePath: asidePath,
      );
      return {'status': 'error', 'message': e.message, 'code': e.code.name};
    } catch (e) {
      await _rollbackRestore(
        libraryRootPath: libraryRootPath,
        stagingPath: stagingPath,
        asidePath: asidePath,
      );
      return {
        'status': 'error',
        'message': 'Could not restore backup: $e',
        'code': LibraryBackupErrorCode.restoreFailed.name,
        'detail': '$e',
      };
    }
  });
}

Future<Map<String, Object?>> _withCancelPort(
  SendPort progressPort,
  Future<Map<String, Object?>> Function(bool Function() isCancelled) body,
) async {
  final cancelPort = ReceivePort();
  var cancelled = false;
  final sub = cancelPort.listen((_) => cancelled = true);
  progressPort.send({'type': 'ready', 'cancelPort': cancelPort.sendPort});

  try {
    final result = await body(() => cancelled);
    return result;
  } finally {
    await sub.cancel();
    cancelPort.close();
  }
}

Future<void> _addFileWithCompression(
  ZipFileEncoder encoder,
  File file,
  String archiveName,
) async {
  final ext = p.extension(archiveName).toLowerCase();
  if (ext == '.pdf' || ext == '.png') {
    final fileStream = InputFileStream(file.path);
    final archiveFile = ArchiveFile.stream(archiveName, fileStream)
      ..compression = CompressionType.none
      ..lastModTime =
          (await file.lastModified()).millisecondsSinceEpoch ~/ 1000
      ..mode = (await file.stat()).mode;
    encoder.addArchiveFile(archiveFile);
    await fileStream.close();
  } else {
    await encoder.addFile(file, archiveName);
  }
}

void _sendProgress(
  SendPort port, {
  required double fraction,
  required String? label,
  bool canCancel = true,
}) {
  port.send({
    'type': 'progress',
    'fraction': fraction,
    'label': label,
    'canCancel': canCancel,
  });
}

Future<Map<String, Object?>> _cancelledResult({required String partPath}) async {
  await _deleteIfExists(partPath);
  return {'status': 'cancelled'};
}

Future<void> _safeCloseEncoder(ZipFileEncoder? encoder) async {
  if (encoder == null) return;
  try {
    await encoder.close();
  } catch (_) {}
}

Future<void> _deleteIfExists(String path) async {
  final file = File(path);
  if (await file.exists()) {
    await file.delete();
    return;
  }
  final dir = Directory(path);
  if (await dir.exists()) {
    await dir.delete(recursive: true);
  }
}

Future<void> _rollbackRestore({
  required String libraryRootPath,
  required String stagingPath,
  required String asidePath,
}) async {
  final libraryRoot = Directory(libraryRootPath);
  final aside = Directory(asidePath);
  if (!await libraryRoot.exists() && await aside.exists()) {
    await aside.rename(libraryRootPath);
  }
  await _deleteIfExists(stagingPath);
}

String _posixRel(String filePath, String rootPath) {
  var rel = p.relative(filePath, from: rootPath);
  return p.posix.fromUri(p.toUri(rel));
}

bool _isWithin(String parent, String child) {
  return p.isWithin(p.canonicalize(parent), p.canonicalize(child));
}

Map<String, String> _loadScoreTitles(String libraryRootPath) {
  try {
    final file = File(p.join(libraryRootPath, 'library.json'));
    if (!file.existsSync()) return {};
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return _titlesFromScoresJson(json['scores']);
  } catch (_) {
    return {};
  }
}

/// Bring a just-restored `library.json` up to the current layout (0052 + 0055).
///
/// Best-effort by design: a manifest this fails to rewrite is still the one
/// the user had a moment ago, and the same migration runs again at library
/// open. Throwing here would turn a restored library into a failed restore.
void _migrateRestoredManifest(String libraryRootPath) {
  try {
    final file = File(p.join(libraryRootPath, 'library.json'));
    if (!file.existsSync()) return;
    final decoded =
        jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final migrated = migrateLibraryManifest(decoded);
    if (identical(migrated, decoded)) return;
    file.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(migrated),
    );
  } catch (_) {
    // Left for migrateIfNeeded() at the next library open.
  }
}

Future<void> _validateMarkerAt(Directory root) async {
  final marker = File(p.join(root.path, LibraryBackup.markerFileName));
  if (!await marker.exists()) {
    throw const LibraryBackupException(
      'Not a StageScore backup (missing marker).',
      code: LibraryBackupErrorCode.missingMarker,
    );
  }
  try {
    final json =
        jsonDecode(await marker.readAsString()) as Map<String, dynamic>;
    if (json['format'] != LibraryBackup.formatId) {
      throw const LibraryBackupException(
        'Not a StageScore backup (unknown format).',
        code: LibraryBackupErrorCode.unknownFormat,
      );
    }
    final version = json['version'];
    if (version is! int ||
        version < 1 ||
        version > LibraryBackup.formatVersion) {
      throw const LibraryBackupException(
        'Unsupported StageScore backup version.',
        code: LibraryBackupErrorCode.unsupportedVersion,
      );
    }
  } on LibraryBackupException {
    rethrow;
  } catch (_) {
    throw const LibraryBackupException(
      'Not a StageScore backup (corrupt marker).',
      code: LibraryBackupErrorCode.corruptMarker,
    );
  }
}

LibraryBackupErrorCode _errorCodeFromName(String? name) {
  for (final code in LibraryBackupErrorCode.values) {
    if (code.name == name) return code;
  }
  return LibraryBackupErrorCode.generic;
}

Map<String, String> _titlesFromArchive(Archive archive) {
  try {
    final file = archive.findFile('library.json');
    if (file == null) return {};
    final json =
        jsonDecode(utf8.decode(file.content)) as Map<String, dynamic>;
    return _titlesFromScoresJson(json['scores']);
  } catch (_) {
    return {};
  }
}

Map<String, String> _titlesFromScoresJson(Object? scores) {
  if (scores is! List) return {};
  final map = <String, String>{};
  for (final raw in scores) {
    if (raw is! Map) continue;
    final id = raw['id'];
    final title = raw['title'];
    if (id is String && title is String) {
      map[id] = title;
    }
  }
  return map;
}

String? _labelForRelativePath(String rel, Map<String, String> titles) {
  final parts = p.posix.split(rel);
  if (parts.length >= 2) {
    final folder = parts[parts.length - 2];
    final base = parts.last;
    final id = p.basenameWithoutExtension(base);
    if ((folder == 'scores' ||
            folder == 'annotations' ||
            folder == 'page_orders' ||
            folder == 'bookmarks' ||
            folder == 'jumplinks' ||
            folder == 'measure_maps' ||
            folder == 'form_maps') &&
        titles.containsKey(id)) {
      return titles[id];
    }
  }
  if (rel == 'library.json' || rel.endsWith('_prefs.json')) {
    return null;
  }
  return p.basename(rel);
}

/// Machine-readable reason, so the UI can show a localized message instead of
/// the English [LibraryBackupException.message] baked in from a worker
/// isolate (no `BuildContext`/`AppLocalizations` crosses an `Isolate.run`
/// boundary, so the message text itself cannot carry the locale).
enum LibraryBackupErrorCode {
  fileNotFound,
  missingMarker,
  unknownFormat,
  unsupportedVersion,
  corruptMarker,
  createFailed,
  restoreFailed,
  generic,
}

class LibraryBackupException implements Exception {
  const LibraryBackupException(
    this.message, {
    this.code = LibraryBackupErrorCode.generic,
    this.detail,
  });

  /// English message, kept for logs and existing tests — not for UI display.
  final String message;
  final LibraryBackupErrorCode code;

  /// Raw lower-level error text for [LibraryBackupErrorCode.createFailed] /
  /// [LibraryBackupErrorCode.restoreFailed] — unavoidably unlocalized (it may
  /// come from the OS or a third-party package), but the sentence around it
  /// is.
  final String? detail;

  @override
  String toString() => message;
}

/// UI-facing message for [exception] — the one place `.message` (English,
/// isolate-safe) turns into the locale the musician is reading.
String libraryBackupErrorMessage(
  AppLocalizations l10n,
  LibraryBackupException exception,
) {
  switch (exception.code) {
    case LibraryBackupErrorCode.fileNotFound:
      return l10n.libraryBackupFileNotFound;
    case LibraryBackupErrorCode.missingMarker:
      return l10n.libraryBackupMissingMarker;
    case LibraryBackupErrorCode.unknownFormat:
      return l10n.libraryBackupUnknownFormat;
    case LibraryBackupErrorCode.unsupportedVersion:
      return l10n.libraryBackupUnsupportedVersion;
    case LibraryBackupErrorCode.corruptMarker:
      return l10n.libraryBackupCorruptMarker;
    case LibraryBackupErrorCode.createFailed:
      return l10n.libraryBackupCreateFailed(exception.detail ?? exception.message);
    case LibraryBackupErrorCode.restoreFailed:
      return l10n.libraryBackupRestoreFailed(exception.detail ?? exception.message);
    case LibraryBackupErrorCode.generic:
      return l10n.libraryBackupFailedGeneric;
  }
}
