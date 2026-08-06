import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/measure_map/measure_box.dart';
import 'package:stagescore/measure_map/measure_map_session.dart';
import 'package:stagescore/measure_map/measure_map_store.dart';

void main() {
  group('beatSplits defaults', () {
    test('even splits follow time signature numerator', () {
      expect(beatsFromTimeSignature('4/4'), 4);
      expect(beatsFromTimeSignature('3/4'), 3);
      expect(beatsFromTimeSignature('6/8'), 6);
      // N interior anchors (centres) — not barlines, not N−1 boundaries.
      expect(evenBeatSplits(4), [0.125, 0.375, 0.625, 0.875]);
      expect(evenBeatSplits(1), [0.5]);
      expect(evenBeatSplits(3), [1 / 6, 0.5, 5 / 6]);
    });

    test('normalizeBeatSplits migrates N−1 boundaries to N anchors', () {
      expect(
        normalizeBeatSplits([0.25, 0.5, 0.75], 4),
        [0.125, 0.375, 0.625, 0.875],
      );
      // Mistaken rev.2 right-edges ending at 1.0 → same centres.
      expect(
        normalizeBeatSplits([0.25, 0.5, 0.75, 1.0], 4),
        [0.125, 0.375, 0.625, 0.875],
      );
      expect(
        boundariesFromBeatAnchors([0.125, 0.375, 0.625, 0.875]),
        [0.25, 0.5, 0.75],
      );
    });
  });

  group('JSON round-trip', () {
    test('store survives encode → decode', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 2,
        x: 0.1,
        y: 0.2,
        width: 0.8,
        height: 0.1,
        measureCount: 4,
      );
      store.applyMeta(
        anchorId: store.boxes[2].id,
        scope: MeasureMetaScope.thisMeasure,
        timeSignature: '3/4',
        tempo: 90,
      );

      final json = store.toJson('score-a');
      final loaded = MeasureMapStore()..loadJson(json);

      expect(loaded.boxes.length, 4);
      expect(loaded.boxes.every((b) => b.pageNumber == 2), isTrue);
      expect(loaded.boxes.map((b) => b.measureNumber), [1, 2, 3, 4]);
      expect(loaded.resolveMeta(loaded.boxes[2]).timeSignature, '3/4');
      expect(loaded.resolveMeta(loaded.boxes[2]).tempo, 90);
      expect(loaded.boxes[2].beatSplits, evenBeatSplits(3));
      // Inherited: measure 4 keeps 3/4 after compact.
      expect(loaded.resolveMeta(loaded.boxes[3]).timeSignature, '3/4');
    });

    test('first measure defaults to 4/4 and 120', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 1,
        height: 0.1,
        measureCount: 2,
      );
      expect(store.boxes.first.timeSignature, kDefaultTimeSignature);
      expect(store.boxes.first.tempo, kDefaultTempo);
      expect(store.boxes[1].timeSignature, isNull);
      expect(store.resolveMeta(store.boxes[1]).tempo, 120);
    });
  });

  group('measureNumber renumber', () {
    test('delete mid-system renumbers continuously', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 1,
        height: 0.1,
        measureCount: 4,
      );
      final mid = store.boxes[1].id;
      expect(store.deleteMeasure(mid), isTrue);
      expect(store.boxes.map((b) => b.measureNumber), [1, 2, 3]);
      // Previous (first) expanded to cover deleted.
      expect(store.boxes.first.width, closeTo(0.5, 0.001));
      expect(store.boxes[1].x, closeTo(0.5, 0.001));
    });

    test('deleting first expands next leftward', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0.1,
        y: 0.2,
        width: 0.8,
        height: 0.1,
        measureCount: 4,
      );
      final first = store.boxes.first;
      final second = store.boxes[1];
      store.deleteMeasure(first.id);
      final newFirst = store.boxes.first;
      expect(newFirst.id, second.id);
      expect(newFirst.x, closeTo(0.1, 0.001));
      expect(newFirst.right, closeTo(second.right, 0.001));
    });

    test('deleting last remaining measure removes the system', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 1,
        height: 0.1,
        measureCount: 1,
      );
      expect(store.deleteMeasure(store.boxes.single.id), isTrue);
      expect(store.isEmpty, isTrue);
    });
  });

  group('setMeasureCount', () {
    test('decreasing N drops right and expands new rightmost', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 1,
        height: 0.1,
        measureCount: 4,
      );
      final leftWidths = store.boxes.take(2).map((b) => b.width).toList();
      store.setMeasureCount(store.boxes.first.id, 2);
      expect(store.boxes.length, 2);
      expect(store.boxes.first.width, leftWidths[0]);
      expect(store.boxes.last.right, closeTo(1.0, 0.001));
      expect(store.boxes.first.x, 0);
    });

    test('increasing N splits the rightmost only', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 1,
        height: 0.1,
        measureCount: 2,
      );
      final leftW = store.boxes.first.width;
      store.setMeasureCount(store.boxes.first.id, 4);
      expect(store.boxes.length, 4);
      expect(store.boxes.first.width, leftW);
      expect(store.boxes.last.right, closeTo(1.0, 0.001));
      // Three equal parts cover the old rightmost half.
      expect(store.boxes[1].width, closeTo(0.5 / 3, 0.001));
    });
  });

  group('copy layout', () {
    test('copies systems to another page without dialog counts', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0.1,
        y: 0.2,
        width: 0.8,
        height: 0.08,
        measureCount: 3,
      );
      store.addSystem(
        pageNumber: 1,
        x: 0.1,
        y: 0.4,
        width: 0.8,
        height: 0.08,
        measureCount: 3,
      );
      expect(store.copyLayoutFromPage(fromPage: 1, toPage: 2), isTrue);
      expect(store.boxesForPage(2).length, 6);
      expect(store.systemIndicesOnPage(2), [0, 1]);
      expect(store.boxes.map((b) => b.measureNumber).toList(), [
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
      ]);
    });
  });

  group('session sticky default', () {
    test('remembers within session and resets on exit', () {
      final session = MeasureMapSessionDefaults();
      expect(session.measureCount, 4);
      session.remember(3);
      expect(session.measureCount, 3);
      session.reset();
      expect(session.measureCount, 4);
    });
  });

  group('drag dividers', () {
    test('measure divider updates neighbouring widths', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 1,
        height: 0.1,
        measureCount: 2,
      );
      final left = store.boxes.first;
      store.dragMeasureDivider(leftId: left.id, newRight: 0.7);
      expect(store.boxes.first.width, closeTo(0.7, 0.001));
      expect(store.boxes.last.x, closeTo(0.7, 0.001));
      expect(store.boxes.last.width, closeTo(0.3, 0.001));
    });
  });

  group('resizeSystem / moveSystem', () {
    test('resize scales horizontal ratios and unifies height', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0.1,
        y: 0.2,
        width: 0.8,
        height: 0.1,
        measureCount: 4,
      );
      // Uneven divider: widen first box.
      store.dragMeasureDivider(leftId: store.boxes.first.id, newRight: 0.4);
      final r0 = (store.boxes[0].x - 0.1) / 0.8;
      final r1 = store.boxes[0].width / 0.8;

      expect(
        store.resizeSystem(
          pageNumber: 1,
          systemIndex: 0,
          x: 0.0,
          y: 0.3,
          width: 1.0,
          height: 0.15,
        ),
        isTrue,
      );
      expect(store.boxes.first.y, closeTo(0.3, 0.001));
      expect(store.boxes.every((b) => b.height == store.boxes.first.height), isTrue);
      expect(store.boxes.first.height, closeTo(0.15, 0.001));
      expect(store.boxes.first.x, closeTo(r0 * 1.0, 0.001));
      expect(store.boxes.first.width, closeTo(r1 * 1.0, 0.001));
      expect(store.boxes.last.right, closeTo(1.0, 0.001));
      // beatSplits and measureNumbers unchanged.
      expect(store.boxes.map((b) => b.measureNumber), [1, 2, 3, 4]);
      expect(store.boxes.first.beatSplits, evenBeatSplits(4));
    });

    test('resize rejects below min size', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0,
        y: 0,
        width: 1,
        height: 0.1,
        measureCount: 2,
      );
      expect(
        store.resizeSystem(
          pageNumber: 1,
          systemIndex: 0,
          x: 0,
          y: 0,
          width: 0.01,
          height: 0.1,
        ),
        isFalse,
      );
    });

    test('move clamps to page and keeps beatSplits', () {
      final store = MeasureMapStore();
      store.addSystem(
        pageNumber: 1,
        x: 0.1,
        y: 0.1,
        width: 0.5,
        height: 0.1,
        measureCount: 2,
      );
      final splits = List<double>.from(store.boxes.first.beatSplits);
      expect(
        store.moveSystem(pageNumber: 1, systemIndex: 0, dx: -0.2, dy: -0.2),
        isTrue,
      );
      // Clamped: cannot go left of 0 / above 0.
      expect(store.boxes.first.x, closeTo(0.0, 0.001));
      expect(store.boxes.first.y, closeTo(0.0, 0.001));
      expect(store.boxes.first.beatSplits, splits);
      expect(store.boxes.map((b) => b.measureNumber), [1, 2]);
    });
  });
}
