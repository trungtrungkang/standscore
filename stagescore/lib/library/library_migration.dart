/// Migration of `library.json` (Spec 0052 PdfDocument layout; Spec 0055 hierarchy).
///
/// Pure functions on decoded manifest content: no files, no directories, no PDF
/// engine. That is what makes the riskiest change — rewriting the manifest of
/// a real library — testable without fixtures, and it is the same idiom
/// `PdfPageCounter` uses to keep the library layer off pdfrx.
library;

import 'package:uuid/uuid.dart';

/// Manifest key holding the PdfDocument list.
///
/// Its *absence* is how a pre-0052 manifest is recognised: `library.json` has
/// never carried a version number (its payload was the single key `scores`),
/// so there is no number to compare and nowhere to record that migration has
/// run. The shape is the version.
const String pdfDocumentsKey = 'pdfDocuments';

/// True when [manifest] predates the PdfDocument layout.
bool needsPdfDocumentMigration(Map<String, dynamic> manifest) =>
    manifest[pdfDocumentsKey] == null;

/// [manifest] in the PdfDocument layout, or the same content when it already is.
///
/// Every Score becomes one PdfDocument covering the whole file, keeping the
/// Score's own id and — byte for byte — its `relativePath`, so nothing on disk
/// moves. Idempotent: running it twice changes nothing, which matters because
/// it runs both at library open and after every restore.
Map<String, dynamic> migrateManifest(Map<String, dynamic> manifest) {
  if (!needsPdfDocumentMigration(manifest)) return manifest;

  final scores = (manifest['scores'] as List<dynamic>? ?? const [])
      .cast<Map<String, dynamic>>();

  final documents = <Map<String, dynamic>>[];
  final migratedScores = <Map<String, dynamic>>[];

  for (final score in scores) {
    final id = score['id'] as String?;
    final relativePath = score['relativePath'] as String?;
    // A Score with no id or no file cannot be pointed at a document, and
    // inventing one would fabricate a path. Drop nothing else about it: the
    // entry is carried through untouched so a later fix still has the data.
    if (id == null || relativePath == null) {
      migratedScores.add(Map<String, dynamic>.from(score));
      continue;
    }

    documents.add({
      'id': id,
      'relativePath': relativePath,
      'importedAt': score['createdAt'],
      'pageCount': score['pageCount'],
      'originalFileName': null,
    });

    final migrated = Map<String, dynamic>.from(score)
      ..remove('relativePath')
      // Page count now lives on the document; on a Score it is derived from
      // the extent, and a stale copy here would be free to disagree with it.
      ..remove('pageCount')
      ..['pdfDocumentId'] = id
      // Null extent, not a whole-file extent: migration cannot know how long
      // an uncounted PDF is, and must not open one to find out.
      ..['pageExtent'] = null;
    migratedScores.add(migrated);
  }

  return {
    ...manifest,
    'scores': migratedScores,
    pdfDocumentsKey: documents,
  };
}

/// Flat 0054 libraries → one root Score per multi-piece document (Spec 0055).
///
/// When ≥ 2 Scores share a `pdfDocumentId` and none of them already has a
/// `parentId`, invent a root (`pageExtent: null`, title = book display name,
/// `createdAt` = the document's `importedAt`) and point every piece at it.
/// Idempotent: a second run finds the root already there and changes nothing.
/// `formatVersion` stays `2` — this is a shape change inside the same backup
/// generation, not a bump.
Map<String, dynamic> migrateHierarchy(Map<String, dynamic> manifest) {
  final scores = (manifest['scores'] as List<dynamic>? ?? const [])
      .map((e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
      .toList();
  final documents = (manifest[pdfDocumentsKey] as List<dynamic>? ?? const [])
      .cast<Map<String, dynamic>>();
  final docsById = {
    for (final doc in documents)
      if (doc['id'] is String) doc['id'] as String: doc,
  };

  final byDoc = <String, List<Map<String, dynamic>>>{};
  for (final score in scores) {
    final docId = score['pdfDocumentId'] as String?;
    if (docId == null) continue;
    (byDoc[docId] ??= []).add(score);
  }

  final uuid = const Uuid();
  final addedRoots = <Map<String, dynamic>>[];
  var changed = false;

  for (final entry in byDoc.entries) {
    final group = entry.value;
    if (group.length < 2) continue;
    // Already hierarchical: any parentId in the group, or a null-extent root
    // sitting next to pieces, means 0055 has already run for this document.
    if (group.any((s) => s['parentId'] != null)) continue;
    final hasWholeFileRoot = group.any((s) => s['pageExtent'] == null);
    if (hasWholeFileRoot && group.any((s) => s['pageExtent'] != null)) {
      // Root + pieces without parentId yet — attach pieces to the root.
      final root = group.firstWhere((s) => s['pageExtent'] == null);
      final rootId = root['id'] as String;
      for (final score in group) {
        if (identical(score, root)) continue;
        if (score['parentId'] == null) {
          score['parentId'] = rootId;
          changed = true;
        }
      }
      continue;
    }
    if (hasWholeFileRoot) continue;

    final doc = docsById[entry.key];
    final title = _bookDisplayName(doc);
    final importedAt = doc?['importedAt'] as String? ??
        group
            .map((s) => s['createdAt'] as String?)
            .whereType<String>()
            .fold<String?>(null, (a, b) {
              if (a == null) return b;
              return a.compareTo(b) <= 0 ? a : b;
            }) ??
        DateTime.now().toUtc().toIso8601String();
    final rootId = uuid.v4();
    final root = <String, dynamic>{
      'id': rootId,
      'title': title,
      'pdfDocumentId': entry.key,
      'pageExtent': null,
      'createdAt': importedAt,
      'lastOpenedAt': null,
    };
    addedRoots.add(root);
    for (final score in group) {
      score['parentId'] = rootId;
    }
    changed = true;
  }

  if (!changed) return manifest;
  return {
    ...manifest,
    'scores': [...scores, ...addedRoots],
    pdfDocumentsKey: documents,
  };
}

/// Run both migrations in order: PdfDocument layout, then hierarchy.
Map<String, dynamic> migrateLibraryManifest(Map<String, dynamic> manifest) =>
    migrateHierarchy(migrateManifest(manifest));

String _bookDisplayName(Map<String, dynamic>? doc) {
  if (doc == null) return 'Untitled book';
  final named = (doc['title'] as String?)?.trim();
  if (named != null && named.isNotEmpty) return named;
  final file = (doc['originalFileName'] as String?)?.trim();
  if (file == null || file.isEmpty) return 'Untitled book';
  if (file.length > 4 && file.toLowerCase().endsWith('.pdf')) {
    return file.substring(0, file.length - 4);
  }
  return file;
}
