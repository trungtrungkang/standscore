import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

/// Renders the first page of the PDF at [path] as PNG bytes (Spec 0040).
typedef ScoreThumbnailRenderer =
    Future<Uint8List?> Function(String path, {int width});

/// First-page thumbnails for the Library list, cached so a scroll never
/// renders (Spec 0040).
///
/// Two rules shape this class:
///
/// - **Derived data, not library data.** The cache lives outside the library
///   root, so it is never swept into a backup ZIP (0027) and the OS may purge
///   it. Anything here can be rebuilt from the PDFs.
/// - **The file's own mtime is the cache key.** Replace PDF (0024) and Restore
///   (0027) both swap bytes under an unchanged Score id, so keying by id alone
///   would show yesterday's page. Keying by id *and* mtime makes staleness
///   impossible rather than something callers must remember to invalidate.
///
/// A failed render is remembered as a miss for the session, so a corrupt file
/// costs one attempt instead of one per scroll.
class ScoreThumbnails {
  ScoreThumbnails({
    required this._cacheDir,
    required this._render,
    this.width = 240,
  });

  final Directory _cacheDir;
  final ScoreThumbnailRenderer _render;
  final int width;

  final Map<String, Uint8List?> _memory = {};
  final Map<String, Future<Uint8List?>> _inFlight = {};

  /// The thumbnail for [scoreId], or null if [pdf] cannot be rendered.
  ///
  /// Safe to call from a widget build: repeated calls for the same key share
  /// one render and answer from memory afterwards.
  Future<Uint8List?> thumbnail({
    required String scoreId,
    required File pdf,
  }) async {
    final key = await _key(scoreId, pdf);
    if (key == null) return null;
    if (_memory.containsKey(key)) return _memory[key];
    return _inFlight[key] ??= _load(scoreId, pdf, key);
  }

  /// Drop everything cached for [scoreId] — call on Delete (0028).
  Future<void> evict(String scoreId) async {
    _memory.removeWhere((key, _) => key.startsWith('$scoreId-'));
    _inFlight.removeWhere((key, _) => key.startsWith('$scoreId-'));
    await _deleteFiles(scoreId, keep: null);
  }

  Future<Uint8List?> _load(String scoreId, File pdf, String key) async {
    try {
      final file = File(p.join(_cacheDir.path, '$key.png'));
      if (await file.exists()) {
        return _remember(key, await file.readAsBytes());
      }
      final bytes = await _render(pdf.path, width: width);
      if (bytes == null) return _remember(key, null);
      await _cacheDir.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
      // The Score kept its id but got new bytes; its old renders are dead.
      await _deleteFiles(scoreId, keep: file.path);
      return _remember(key, bytes);
    } catch (_) {
      return _remember(key, null);
    } finally {
      _inFlight.remove(key);
    }
  }

  Uint8List? _remember(String key, Uint8List? bytes) {
    _memory[key] = bytes;
    return bytes;
  }

  Future<String?> _key(String scoreId, File pdf) async {
    try {
      final stat = await pdf.stat();
      if (stat.type == FileSystemEntityType.notFound) return null;
      return '$scoreId-${stat.modified.millisecondsSinceEpoch}';
    } catch (_) {
      return null;
    }
  }

  Future<void> _deleteFiles(String scoreId, {required String? keep}) async {
    try {
      if (!await _cacheDir.exists()) return;
      await for (final entity in _cacheDir.list()) {
        if (entity is! File) continue;
        if (entity.path == keep) continue;
        if (!p.basename(entity.path).startsWith('$scoreId-')) continue;
        await entity.delete();
      }
    } catch (_) {
      // A stale thumbnail we failed to delete is harmless; it is keyed by an
      // mtime nothing will ask for again.
    }
  }
}
