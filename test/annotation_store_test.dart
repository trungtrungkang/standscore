import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:standscore/annotation/annotation_geometry.dart';
import 'package:standscore/annotation/annotation_store.dart';
import 'package:standscore/annotation/draw_tool.dart';
import 'package:standscore/annotation/stamp.dart';

void main() {
  AnnotationStroke penStroke({
    String id = 'a',
    int page = 1,
    List<Offset> points = const [Offset(0.1, 0.1), Offset(0.2, 0.2)],
  }) {
    return AnnotationStroke(
      id: id,
      pageNumber: page,
      points: points,
      tool: DrawTool.pen,
    );
  }

  test('addStroke stores stroke; undo removes last', () {
    final store = AnnotationStore();
    store.addStroke(penStroke(id: '1', page: 1));
    store.addStroke(
      penStroke(
        id: '2',
        page: 2,
        points: const [Offset(0.3, 0.3), Offset(0.4, 0.4)],
      ),
    );

    expect(store.length, 2);
    expect(store.strokesForPage(1), hasLength(1));
    expect(store.undo(), isTrue);
    expect(store.length, 1);
    expect(store.strokesForPage(2), isEmpty);
    expect(store.undo(), isTrue);
    expect(store.undo(), isFalse);
  });

  test('redo restores undone add', () {
    final store = AnnotationStore();
    store.addStroke(penStroke(id: '1'));
    store.undo();
    expect(store.length, 0);
    expect(store.redo(), isTrue);
    expect(store.length, 1);
    expect(store.strokes.single.id, '1');
  });

  test('ignores strokes with fewer than two points', () {
    final store = AnnotationStore();
    store.addStroke(
      AnnotationStroke(
        id: 'x',
        pageNumber: 1,
        points: const [Offset(0.1, 0.1)],
      ),
    );
    expect(store.length, 0);
  });

  test('eraseAlong removes hit strokes and is undoable', () {
    final store = AnnotationStore();
    store.addStroke(
      penStroke(id: 'keep', points: const [Offset(0.8, 0.8), Offset(0.9, 0.9)]),
    );
    store.addStroke(
      penStroke(id: 'hit', points: const [Offset(0.1, 0.1), Offset(0.2, 0.2)]),
    );

    final removed = store.eraseAlong(
      pageNumber: 1,
      path: const [Offset(0.15, 0.15)],
    );
    expect(removed, 1);
    expect(store.strokes.map((s) => s.id), ['keep']);

    expect(store.undo(), isTrue);
    expect(store.strokes.map((s) => s.id), containsAll(['keep', 'hit']));
    expect(store.redo(), isTrue);
    expect(store.strokes.map((s) => s.id), ['keep']);
  });

  test('createStroke applies pen/marker presets', () {
    final store = AnnotationStore();
    final pen = store.createStroke(
      pageNumber: 1,
      points: const [Offset(0, 0), Offset(1, 1)],
      tool: DrawTool.pen,
    );
    final marker = store.createStroke(
      pageNumber: 1,
      points: const [Offset(0, 0), Offset(1, 1)],
      tool: DrawTool.marker,
    );
    expect(pen.width, DrawToolPresets.penWidth);
    expect(marker.width, DrawToolPresets.markerWidth);
    expect(marker.color.a, lessThan(1.0));
  });

  test('pathHitsStroke geometry', () {
    final stroke = penStroke(
      points: const [Offset(0.0, 0.5), Offset(1.0, 0.5)],
    );
    expect(pathHitsStroke(const [Offset(0.5, 0.5)], stroke), isTrue);
    expect(pathHitsStroke(const [Offset(0.5, 0.9)], stroke), isFalse);
    expect(
      distanceToSegment(
        const Offset(0.5, 0.6),
        const Offset(0, 0.5),
        const Offset(1, 0.5),
      ),
      closeTo(0.1, 1e-9),
    );
  });

  group('stamps (0019)', () {
    test('addStamp / deleteStamp undo redo', () {
      final store = AnnotationStore();
      final stamp = store.createStamp(
        pageNumber: 1,
        kind: StampKind.dynamicP,
        center: const Offset(0.4, 0.5),
      );
      store.addStamp(stamp);
      expect(store.stampCount, 1);

      expect(store.deleteStamp(stamp.id), isTrue);
      expect(store.stampCount, 0);
      expect(store.undo(), isTrue);
      expect(store.stampCount, 1);
      expect(store.redo(), isTrue);
      expect(store.stampCount, 0);
    });

    test('moveStamp is undoable', () {
      final store = AnnotationStore();
      final stamp = store.createStamp(
        pageNumber: 1,
        kind: StampKind.box,
        center: const Offset(0.2, 0.2),
      );
      store.addStamp(stamp);
      expect(store.moveStamp(stamp.id, const Offset(0.7, 0.8)), isTrue);
      expect(store.stamps.single.center, const Offset(0.7, 0.8));
      expect(store.undo(), isTrue);
      expect(store.stamps.single.center, const Offset(0.2, 0.2));
    });

    test('tryFromJson ignores unknown stamp kinds', () {
      final stamp = AnnotationStamp.tryFromJson({
        'id': 'x',
        'pageNumber': 1,
        'kind': 'smuflCustomFuture',
        'cx': 0.5,
        'cy': 0.5,
      });
      expect(stamp, isNull);
    });

    test('hitTestStamp returns topmost', () {
      final store = AnnotationStore();
      final a = store.createStamp(
        pageNumber: 1,
        kind: StampKind.circle,
        center: const Offset(0.5, 0.5),
        size: 0.1,
      );
      final b = store.createStamp(
        pageNumber: 1,
        kind: StampKind.box,
        center: const Offset(0.5, 0.5),
        size: 0.1,
      );
      store.addStamp(a);
      store.addStamp(b);
      expect(store.hitTestStamp(1, const Offset(0.5, 0.5))?.id, b.id);
    });
  });

  group('AnnotationPersistence', () {
    late Directory root;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('annotations_');
    });

    tearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    test('round-trips per Score', () async {
      final store = AnnotationStore();
      store.addStroke(
        store.createStroke(
          pageNumber: 1,
          points: const [Offset(0.1, 0.2), Offset(0.3, 0.4)],
          tool: DrawTool.marker,
        ),
      );

      final a = AnnotationPersistence(root: root, scoreId: 'score-a');
      final b = AnnotationPersistence(root: root, scoreId: 'score-b');
      await a.save(store);

      final loaded = AnnotationStore();
      await a.loadInto(loaded);
      expect(loaded.length, 1);
      expect(loaded.strokes.single.tool, DrawTool.marker);

      final other = AnnotationStore();
      await b.loadInto(other);
      expect(other.length, 0);

      expect(
        File(p.join(root.path, 'annotations', 'score-a.json')).existsSync(),
        isTrue,
      );
    });

    test('round-trips stamps with strokes', () async {
      final store = AnnotationStore();
      store.addStroke(
        store.createStroke(
          pageNumber: 1,
          points: const [Offset(0.1, 0.1), Offset(0.2, 0.2)],
          tool: DrawTool.pen,
        ),
      );
      store.addStamp(
        store.createStamp(
          pageNumber: 1,
          kind: StampKind.text,
          center: const Offset(0.3, 0.4),
          text: 'DS',
          color: const Color(0xFFE11D48),
        ),
      );

      final persistence = AnnotationPersistence(
        root: root,
        scoreId: 'score-stamps',
      );
      await persistence.save(store);

      final loaded = AnnotationStore();
      await persistence.loadInto(loaded);
      expect(loaded.length, 1);
      expect(loaded.stampCount, 1);
      expect(loaded.stamps.single.kind, StampKind.text);
      expect(loaded.stamps.single.text, 'DS');
    });

    test('load skips unknown stamp kinds', () async {
      final file = File(p.join(root.path, 'annotations', 'future.json'));
      await file.parent.create(recursive: true);
      await file.writeAsString('''
{
  "scoreId": "future",
  "strokes": [],
  "stamps": [
    {"id":"1","pageNumber":1,"kind":"dynamicP","cx":0.2,"cy":0.3,"size":0.06,"color":4294901760},
    {"id":"2","pageNumber":1,"kind":"unknownFuture","cx":0.5,"cy":0.5,"size":0.06,"color":4294901760}
  ]
}
''');
      final loaded = AnnotationStore();
      await AnnotationPersistence(
        root: root,
        scoreId: 'future',
      ).loadInto(loaded);
      expect(loaded.stampCount, 1);
      expect(loaded.stamps.single.kind, StampKind.dynamicP);
    });
  });
}
