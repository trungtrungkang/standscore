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
      expect(resolveVerticalEdgeBand(localY: 500, viewerHeight: h), isNull);
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

    test('bottom edge defaults to Off (Spec 0034)', () {
      const map = GestureMap();
      expect(map.bottomEdge, GestureMapAction.disabled);
      expect(map.longPress, GestureMapAction.showChrome);
      expect(map.topEdge, GestureMapAction.showChrome);
    });

    test('a saved Draw assignment reads back as Off (Spec 0034)', () {
      final map = GestureMap.fromJson(const {
        'longPress': 'showChrome',
        'topEdge': 'enterDraw',
        'bottomEdge': 'enterDraw',
      });
      expect(map.topEdge, GestureMapAction.disabled);
      expect(map.bottomEdge, GestureMapAction.disabled);
      expect(map.longPress, GestureMapAction.showChrome);
    });

    test('rejects map with no showChrome', () {
      expect(
        validateGestureMap(
          const GestureMap(
            longPress: GestureMapAction.disabled,
            topEdge: GestureMapAction.disabled,
            bottomEdge: GestureMapAction.disabled,
          ),
        ),
        isFalse,
      );
    });
  });

  group('gestureMapRevealHint', () {
    test('names the default reveal inputs', () {
      final hint = gestureMapRevealHint(const GestureMap());
      expect(hint, contains('long-press or tap the top edge'));
    });

    test('names a single reveal input', () {
      final hint = gestureMapRevealHint(
        const GestureMap(
          longPress: GestureMapAction.disabled,
          topEdge: GestureMapAction.disabled,
          bottomEdge: GestureMapAction.showChrome,
        ),
      );
      expect(hint, contains('tap the bottom edge'));
      expect(hint, isNot(contains('long-press')));
    });
  });

  test('PageTurnPrefs round-trips gesture map', () async {
    final dir = await Directory.systemTemp.createTemp('gesture_map_');
    addTearDown(() => dir.delete(recursive: true));
    final store = PageTurnPrefsStore(root: dir);
    await store.save(
      const PageTurnPrefs(
        gestureMap: GestureMap(
          longPress: GestureMapAction.disabled,
          topEdge: GestureMapAction.showChrome,
          bottomEdge: GestureMapAction.showChrome,
        ),
      ),
    );
    final loaded = await store.load();
    expect(loaded.gestureMap.longPress, GestureMapAction.disabled);
    expect(loaded.gestureMap.topEdge, GestureMapAction.showChrome);
    expect(loaded.gestureMap.bottomEdge, GestureMapAction.showChrome);
  });
}
