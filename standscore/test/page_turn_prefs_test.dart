import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:standscore/pageturn/gesture_map.dart';
import 'package:standscore/pageturn/page_turn_animation.dart';
import 'package:standscore/pageturn/page_turn_delay.dart';
import 'package:standscore/pageturn/page_turn_prefs.dart';
import 'package:standscore/pageturn/page_turn_prefs_store.dart';

void main() {
  group('resolveTapAction', () {
    const size = Size(200, 100);

    test('leftRight splits horizontally', () {
      expect(
        resolveTapAction(
          localPosition: const Offset(10, 50),
          viewSize: size,
          mode: PageTurnTapMode.leftRight,
        ),
        PageTurnAction.previous,
      );
      expect(
        resolveTapAction(
          localPosition: const Offset(150, 50),
          viewSize: size,
          mode: PageTurnTapMode.leftRight,
        ),
        PageTurnAction.next,
      );
    });

    test('topBottom splits vertically', () {
      expect(
        resolveTapAction(
          localPosition: const Offset(100, 10),
          viewSize: size,
          mode: PageTurnTapMode.topBottom,
        ),
        PageTurnAction.previous,
      );
      expect(
        resolveTapAction(
          localPosition: const Offset(100, 80),
          viewSize: size,
          mode: PageTurnTapMode.topBottom,
        ),
        PageTurnAction.next,
      );
    });

    test('disabled returns null', () {
      expect(
        resolveTapAction(
          localPosition: const Offset(150, 50),
          viewSize: size,
          mode: PageTurnTapMode.disabled,
        ),
        isNull,
      );
    });

    test('reverseHorizontal flips leftRight zones', () {
      expect(
        resolveTapAction(
          localPosition: const Offset(10, 50),
          viewSize: size,
          mode: PageTurnTapMode.leftRight,
          reverseHorizontal: true,
        ),
        PageTurnAction.next,
      );
      expect(
        resolveTapAction(
          localPosition: const Offset(150, 50),
          viewSize: size,
          mode: PageTurnTapMode.leftRight,
          reverseHorizontal: true,
        ),
        PageTurnAction.previous,
      );
    });
  });

  group('resolveSwipeAction', () {
    const prefs = PageTurnPrefs();

    test('swipe left goes next', () {
      expect(
        resolveSwipeAction(velocity: const Offset(-400, 0), prefs: prefs),
        PageTurnAction.next,
      );
    });

    test('swipe right goes previous', () {
      expect(
        resolveSwipeAction(velocity: const Offset(400, 0), prefs: prefs),
        PageTurnAction.previous,
      );
    });

    test('reverseHorizontal flips horizontal swipes', () {
      expect(
        resolveSwipeAction(
          velocity: const Offset(-400, 0),
          prefs: prefs,
          reverseHorizontal: true,
        ),
        PageTurnAction.previous,
      );
      expect(
        resolveSwipeAction(
          velocity: const Offset(400, 0),
          prefs: prefs,
          reverseHorizontal: true,
        ),
        PageTurnAction.next,
      );
    });
  });

  test('PageTurnPrefsStore round-trips', () async {
    final dir = await Directory.systemTemp.createTemp('pt_prefs_');
    addTearDown(() => dir.delete(recursive: true));
    final store = PageTurnPrefsStore(root: dir);
    final prefs = const PageTurnPrefs(
      tapMode: PageTurnTapMode.topBottom,
      swipeUp: true,
      hintShown: true,
      delayPreset: PageTurnDelayPreset.ms500,
      delayScope: PageTurnDelayScope.pedalOnly,
      animationPreset: PageTurnAnimationPreset.slow,
      reverseDirection: true,
    );
    await store.save(prefs);
    final loaded = await store.load();
    expect(loaded.tapMode, PageTurnTapMode.topBottom);
    expect(loaded.swipeUp, isTrue);
    expect(loaded.hintShown, isTrue);
    expect(loaded.delayPreset, PageTurnDelayPreset.ms500);
    expect(loaded.delayScope, PageTurnDelayScope.pedalOnly);
    expect(loaded.animationPreset, PageTurnAnimationPreset.slow);
    expect(loaded.reverseDirection, isTrue);
    expect(File(p.join(dir.path, 'pageturn_prefs.json')).existsSync(), isTrue);
  });

  test('prefs saved with a Draw gesture load with it Off (Spec 0034)', () {
    final prefs = PageTurnPrefs.fromJson(const {
      'tapMode': 'leftRight',
      'gestureMap': {
        'longPress': 'showChrome',
        'topEdge': 'showChrome',
        'bottomEdge': 'enterDraw',
      },
    });
    expect(prefs.gestureMap.bottomEdge, GestureMapAction.disabled);
    expect(prefs.gestureMap.topEdge, GestureMapAction.showChrome);
    expect(prefs.tapMode, PageTurnTapMode.leftRight);
  });
}
