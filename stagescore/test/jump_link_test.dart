import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/jumplink/jump_link.dart';
import 'package:stagescore/jumplink/jump_link_geometry.dart';
import 'package:stagescore/jumplink/jump_link_store.dart';

void main() {
  group('clampJumpDestination', () {
    test('clamps like page jump', () {
      expect(clampJumpDestination(0, 10), 1);
      expect(clampJumpDestination(99, 10), 10);
      expect(clampJumpDestination(5, 10), 5);
    });
  });

  group('moveJumpLinkNormRect', () {
    test('moves and clamps to page bounds', () {
      const start = Rect.fromLTWH(0.7, 0.8, 0.2, 0.1);
      final moved = moveJumpLinkNormRect(
        start,
        const Offset(-100, -50),
        const Size(200, 200),
      );
      expect(moved.left, closeTo(0.2, 0.001));
      expect(moved.top, closeTo(0.55, 0.001));
      expect(moved.width, closeTo(0.2, 0.001));
      expect(moved.height, closeTo(0.1, 0.001));

      final clamped = moveJumpLinkNormRect(
        start,
        const Offset(1000, 1000),
        const Size(200, 200),
      );
      expect(clamped.left, closeTo(0.8, 0.001));
      expect(clamped.top, closeTo(0.9, 0.001));
    });
  });

  group('hitTestJumpLinks', () {
    final link = JumpLink(
      id: 'a',
      originPage: 2,
      destinationPage: 5,
      normRect: const Rect.fromLTWH(0.5, 0.5, 0.2, 0.1),
      colorValue: defaultJumpLinkColorValue,
      createdAt: DateTime.utc(2026),
    );

    test('hits when tap is inside fitted page rect', () {
      const viewer = Size(400, 600);
      // Page aspect 2/3 → fills height, width 400.
      final hit = hitTestJumpLinks(
        links: [link],
        originPage: 2,
        localInViewer: const Offset(240, 330),
        viewerSize: viewer,
        pageAspectRatio: 2 / 3,
      );
      expect(hit?.id, 'a');
    });

    test('misses other origin pages', () {
      final hit = hitTestJumpLinks(
        links: [link],
        originPage: 1,
        localInViewer: const Offset(240, 330),
        viewerSize: const Size(400, 600),
        pageAspectRatio: 2 / 3,
      );
      expect(hit, isNull);
    });

    test('prefers later link when overlapping', () {
      final later = JumpLink(
        id: 'b',
        originPage: 2,
        destinationPage: 9,
        normRect: link.normRect,
        colorValue: defaultJumpLinkColorValue,
        createdAt: DateTime.utc(2026, 2),
      );
      final hit = hitTestJumpLinks(
        links: [link, later],
        originPage: 2,
        localInViewer: const Offset(240, 330),
        viewerSize: const Size(400, 600),
        pageAspectRatio: 2 / 3,
      );
      expect(hit?.id, 'b');
    });
  });

  group('JumpLinkStore', () {
    late Directory root;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('jumplinks_');
    });

    tearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    test('round-trips per Score id', () async {
      final a = JumpLinkStore(root: root, scoreId: 'score-a');
      final b = JumpLinkStore(root: root, scoreId: 'score-b');

      await a.add(originPage: 1, destinationPage: 3);
      await a.add(originPage: 2, destinationPage: 1);
      await b.add(originPage: 1, destinationPage: 2);

      final listedA = await a.list();
      expect(listedA, hasLength(2));
      expect(listedA.map((e) => e.originPage), [1, 2]);

      final listedB = await b.list();
      expect(listedB, hasLength(1));

      expect(
        File(p.join(root.path, 'jumplinks', 'score-a.json')).existsSync(),
        isTrue,
      );
    });

    test('update and delete', () async {
      final store = JumpLinkStore(root: root, scoreId: 's1');
      final created = await store.add(originPage: 1, destinationPage: 2);
      await store.update(created.copyWith(destinationPage: 4));
      var listed = await store.list();
      expect(listed.single.destinationPage, 4);

      await store.delete(created.id);
      listed = await store.list();
      expect(listed, isEmpty);
    });
  });
}
