import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/library/library_migration.dart';

/// Flat 0054 libraries → one root + children (Spec 0055).
void main() {
  Map<String, dynamic> piece({
    required String id,
    required String docId,
    required int first,
    required int last,
    String title = 'Piece',
    String createdAt = '2026-06-01T00:00:00.000Z',
  }) => {
    'id': id,
    'title': title,
    'pdfDocumentId': docId,
    'pageExtent': {'firstPage': first, 'lastPage': last},
    'createdAt': createdAt,
    'lastOpenedAt': null,
  };

  Map<String, dynamic> doc({
    required String id,
    String? title,
    String importedAt = '2026-01-01T00:00:00.000Z',
    String? originalFileName = 'Chopin Etudes.pdf',
  }) => {
    'id': id,
    'relativePath': 'documents/$id.pdf',
    'importedAt': importedAt,
    'pageCount': 148,
    'originalFileName': originalFileName,
    'title': title,
  };

  test('two flat pieces of one document get a synthetic root', () {
    final migrated = migrateHierarchy({
      'scores': [
        piece(id: 'p1', docId: 'book', first: 1, last: 8, title: 'No. 1'),
        piece(id: 'p2', docId: 'book', first: 9, last: 16, title: 'No. 2'),
      ],
      pdfDocumentsKey: [doc(id: 'book', title: 'Chopin Etudes')],
    });

    final scores = migrated['scores'] as List<dynamic>;
    expect(scores, hasLength(3));
    final roots = scores.where((s) => s['parentId'] == null).toList();
    final children = scores.where((s) => s['parentId'] != null).toList();
    expect(roots, hasLength(1));
    expect(children, hasLength(2));
    expect(roots.single['title'], 'Chopin Etudes');
    expect(roots.single['pageExtent'], isNull);
    expect(roots.single['pdfDocumentId'], 'book');
    expect(roots.single['createdAt'], '2026-01-01T00:00:00.000Z');
    expect(children.map((c) => c['parentId']).toSet(), {roots.single['id']});
    expect(children.map((c) => c['id']).toSet(), {'p1', 'p2'});
  });

  test('a lone Score is left alone', () {
    final manifest = {
      'scores': [
        {
          'id': 'solo',
          'title': 'Solo',
          'pdfDocumentId': 'solo',
          'pageExtent': null,
          'createdAt': '2026-01-02T03:04:05.000Z',
        },
      ],
      pdfDocumentsKey: [doc(id: 'solo', originalFileName: 'solo.pdf')],
    };
    final migrated = migrateHierarchy(manifest);
    expect(migrated['scores'], hasLength(1));
    expect((migrated['scores'] as List).single['parentId'], isNull);
  });

  test('is idempotent and skips groups that already have a root', () {
    final once = migrateHierarchy({
      'scores': [
        piece(id: 'p1', docId: 'book', first: 1, last: 8),
        piece(id: 'p2', docId: 'book', first: 9, last: 16),
      ],
      pdfDocumentsKey: [doc(id: 'book', title: 'Etudes')],
    });
    final twice = migrateHierarchy(once);
    expect(twice['scores'], once['scores']);
  });

  test('uses displayName from the file when the book has no title', () {
    final migrated = migrateHierarchy({
      'scores': [
        piece(id: 'p1', docId: 'book', first: 1, last: 8),
        piece(id: 'p2', docId: 'book', first: 9, last: 16),
      ],
      pdfDocumentsKey: [doc(id: 'book', title: null)],
    });
    final root = (migrated['scores'] as List).firstWhere(
      (s) => s['parentId'] == null,
    );
    expect(root['title'], 'Chopin Etudes');
  });

  test('two separate books each get their own root', () {
    final migrated = migrateHierarchy({
      'scores': [
        piece(id: 'a1', docId: 'a', first: 1, last: 2),
        piece(id: 'a2', docId: 'a', first: 3, last: 4),
        piece(id: 'b1', docId: 'b', first: 1, last: 2),
        piece(id: 'b2', docId: 'b', first: 3, last: 4),
      ],
      pdfDocumentsKey: [
        doc(id: 'a', title: 'Book A'),
        doc(id: 'b', title: 'Book B', originalFileName: 'b.pdf'),
      ],
    });
    final scores = migrated['scores'] as List<dynamic>;
    expect(scores, hasLength(6));
    final roots = scores.where((s) => s['parentId'] == null).toList();
    expect(roots.map((r) => r['title']).toSet(), {'Book A', 'Book B'});
  });
}
