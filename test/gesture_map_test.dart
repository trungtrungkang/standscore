import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/pageturn/gesture_map.dart';
import 'package:standscore/pageturn/page_turn_prefs.dart';
import 'package:standscore/pageturn/page_turn_prefs_store.dart';

void main() {
  group('gestureMapEdgeBand', () {
    test('resolves top and bottom with 6% bands', () {
      const h = 1000.0;
      expect(
        resolveVerticalEdgeBand(localY: 10, viewerHeight: h),
        VerticalEdgeBand.top,
      );
      expect(
        resolveVerticalEdgeBand(localY: 500, viewerHeight: h),
        isNull,
      );
      expect(
        resolveVerticalEdgeBand(localY: 990, viewerHeight: h),
        VerticalEdgeBand.bottom,
      );
    });

    test('enforces minimum band height', () {
      const h = 100.0;
      final band = gestureMapEdgeBandHeight(h);
      expect(band, gestureMapEdgeMinPx);
      expect(
        resolveVerticalEdgeBand(localY: 20, viewerHeight: h),
        VerticalEdgeBand.top,
      );
    });
  });

  group('validateGestureMap', () {
    test('defaults are valid', () {
      expect(validateGestureMap(const GestureMap()), isTrue);
    });

    test('rejects map with no showChrome', () {
      expect(
        validateGestureMap(
          const GestureMap(
            longPress: GestureMapAction.disabled,
            topEdge: GestureMapAction.enterDraw,
            bottomEdge: GestureMapAction.disabled,
          ),
        ),
        isFalse,
      );
    });
  });

  test('PageTurnPrefs round-trips gesture map', () async {
    final dir = await Directory.systemTemp.createTemp('gesture_map_');
    addTearDown(() => dir.delete(recursive: true));
    final store = PageTurnPrefsStore(root: dir);
    await store.save(
      const PageTurnPrefs(
        gestureMap: GestureMap(
          longPress: GestureMapAction.showChrome,
          topEdge: GestureMapAction.enterDraw,
          bottomEdge: GestureMapAction.disabled,
        ),
      ),
    );
    final loaded = await store.load();
    expect(loaded.gestureMap.longPress, GestureMapAction.showChrome);
    expect(loaded.gestureMap.topEdge, GestureMapAction.enterDraw);
    expect(loaded.gestureMap.bottomEdge, GestureMapAction.disabled);
  });
}
