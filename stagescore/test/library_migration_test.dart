import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/library/library_migration.dart';

Map<String, dynamic> _oldScore({
  required String id,
  String title = 'Etude',
  int? pageCount = 4,
}) => {
  'id': id,
  'title': title,
  'relativePath': 'scores/$id.pdf',
  'createdAt': '2026-01-02T03:04:05.000Z',
  'lastOpenedAt': null,
  'pageCount': pageCount,
};

void main() {
  group('migrateManifest', () {
    test('recognises an old manifest by the missing key, not by a version', () {
      expect(needsPdfDocumentMigration({'scores': []}), isTrue);
      expect(
        needsPdfDocumentMigration({'scores': [], pdfDocumentsKey: []}),
        isFalse,
      );
    });

    test('gives every Score one document covering its whole file', () {
      final migrated = migrateManifest({
        'scores': [_oldScore(id: 'a'), _oldScore(id: 'b', pageCount: 12)],
      });

      final documents = migrated[pdfDocumentsKey] as List<dynamic>;
      expect(documents, hasLength(2));
      expect(documents.first, {
        'id': 'a',
        'relativePath': 'scores/a.pdf',
        'importedAt': '2026-01-02T03:04:05.000Z',
        'pageCount': 4,
        'originalFileName': null,
      });

      final scores = migrated['scores'] as List<dynamic>;
      expect(scores.first['pdfDocumentId'], 'a');
      expect(scores.first['pageExtent'], isNull);
      expect(scores.last['pdfDocumentId'], 'b');
    });

    test('keeps relativePath on the document byte for byte', () {
      final migrated = migrateManifest({
        'scores': [
          {
            'id': 'weird',
            'title': 'Odd path',
            'relativePath': 'scores/Bach — Prélude (1).pdf',
            'createdAt': '2026-01-02T03:04:05.000Z',
            'pageCount': 3,
          },
        ],
      });
      final documents = migrated[pdfDocumentsKey] as List<dynamic>;
      expect(documents.single['relativePath'], 'scores/Bach — Prélude (1).pdf');
    });

    test('moves pageCount to the document and off the Score', () {
      final migrated = migrateManifest({
        'scores': [_oldScore(id: 'a', pageCount: 9)],
      });
      expect((migrated[pdfDocumentsKey] as List).single['pageCount'], 9);
      expect((migrated['scores'] as List).single.containsKey('pageCount'), isFalse);
      expect(
        (migrated['scores'] as List).single.containsKey('relativePath'),
        isFalse,
      );
    });

    test('carries an uncounted PDF through without opening it', () {
      final migrated = migrateManifest({
        'scores': [_oldScore(id: 'a', pageCount: null)],
      });
      expect((migrated[pdfDocumentsKey] as List).single['pageCount'], isNull);
      expect((migrated['scores'] as List).single['pageExtent'], isNull);
    });

    test('is idempotent: a second run changes nothing', () {
      final once = migrateManifest({
        'scores': [_oldScore(id: 'a'), _oldScore(id: 'b')],
      });
      final twice = migrateManifest(once);
      expect(twice, once);
    });

    test('an already-migrated manifest is returned untouched', () {
      final manifest = {
        'scores': [
          {
            'id': 'a',
            'title': 'Etude',
            'pdfDocumentId': 'doc-1',
            'pageExtent': {'firstPage': 12, 'lastPage': 19},
            'createdAt': '2026-01-02T03:04:05.000Z',
          },
        ],
        pdfDocumentsKey: [
          {
            'id': 'doc-1',
            'relativePath': 'documents/doc-1.pdf',
            'importedAt': '2026-01-02T03:04:05.000Z',
            'pageCount': 200,
            'originalFileName': 'Chopin Etudes.pdf',
          },
        ],
      };
      expect(migrateManifest(manifest), same(manifest));
    });

    test('an empty library migrates cleanly', () {
      final migrated = migrateManifest({'scores': []});
      expect(migrated['scores'], isEmpty);
      expect(migrated[pdfDocumentsKey], isEmpty);
    });

    test('a manifest with no scores key at all migrates cleanly', () {
      final migrated = migrateManifest(<String, dynamic>{});
      expect(migrated['scores'], isEmpty);
      expect(migrated[pdfDocumentsKey], isEmpty);
    });

    test('preserves unrelated top-level keys', () {
      final migrated = migrateManifest({
        'scores': [_oldScore(id: 'a')],
        'somethingElse': {'kept': true},
      });
      expect(migrated['somethingElse'], {'kept': true});
    });

    test('a Score with no relativePath is carried through, not dropped', () {
      final migrated = migrateManifest({
        'scores': [
          {'id': 'broken', 'title': 'No file', 'createdAt': '2026-01-02T03:04:05.000Z'},
          _oldScore(id: 'a'),
        ],
      });
      expect(migrated['scores'], hasLength(2));
      expect((migrated[pdfDocumentsKey] as List), hasLength(1));
      expect((migrated['scores'] as List).first['id'], 'broken');
    });
  });
}
