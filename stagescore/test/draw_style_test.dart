import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/annotation/annotation_store.dart';
import 'package:stagescore/annotation/draw_style.dart';
import 'package:stagescore/annotation/draw_style_prefs_store.dart';
import 'package:stagescore/annotation/draw_tool.dart';
import 'package:stagescore/annotation/ink_sampler.dart';

void main() {
  group('pointsForStroke', () {
    test('keeps freehand path', () {
      const raw = [Offset(0, 0), Offset(0.2, 0.1), Offset(0.5, 0.4)];
      expect(pointsForStroke(raw: raw, straightLine: false), raw);
    });

    test('collapses to endpoints when straight', () {
      const raw = [Offset(0.1, 0.1), Offset(0.2, 0.3), Offset(0.8, 0.9)];
      expect(pointsForStroke(raw: raw, straightLine: true), const [
        Offset(0.1, 0.1),
        Offset(0.8, 0.9),
      ]);
    });
  });

  group('DrawStylePrefsStore', () {
    late Directory root;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('draw_style_');
    });

    tearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    test('round-trips color and width', () async {
      final store = DrawStylePrefsStore(root: root);
      final prefs = const DrawStylePrefs(
        penColorValue: 0xFF2563EB,
        penWidth: 0.008,
        markerWidth: 0.040,
        straightLine: true,
      );
      await store.save(prefs);
      final loaded = await store.load();
      expect(loaded.penColorValue, 0xFF2563EB);
      expect(loaded.penWidth, 0.008);
      expect(loaded.markerWidth, 0.040);
      expect(loaded.straightLine, isTrue);
      expect(
        File(p.join(root.path, 'draw_style_prefs.json')).existsSync(),
        isTrue,
      );
    });
  });

  group('sampleInkColor', () {
    test('returns topmost stroke color under point', () {
      final store = AnnotationStore();
      store.addStroke(
        store.createStroke(
          pageNumber: 1,
          points: const [Offset(0.1, 0.1), Offset(0.3, 0.1)],
          tool: DrawTool.pen,
          color: const Color(0xFF0000FF),
        ),
      );
      store.addStroke(
        store.createStroke(
          pageNumber: 1,
          points: const [Offset(0.2, 0.05), Offset(0.2, 0.2)],
          tool: DrawTool.pen,
          color: const Color(0xFFFF0000),
        ),
      );

      final hit = sampleInkColor(
        store: store,
        pageNumber: 1,
        point: const Offset(0.2, 0.1),
      );
      expect(hit?.toARGB32(), const Color(0xFFFF0000).toARGB32());

      expect(
        sampleInkColor(
          store: store,
          pageNumber: 1,
          point: const Offset(0.9, 0.9),
        ),
        isNull,
      );
    });
  });
}
