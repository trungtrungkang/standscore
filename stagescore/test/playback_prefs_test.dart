import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/sync_map/playback_prefs.dart';
import 'package:stagescore/sync_map/playback_prefs_store.dart';

void main() {
  group('PlaybackPrefs', () {
    test('defaults: controls hidden, count-in off, docked', () {
      const p = PlaybackPrefs();
      expect(p.showPlaybackControls, isFalse);
      expect(p.countInMeasures, 0);
      expect(p.style, PlaybackControlsStyle.docked);
      expect(p.floatNormX, 1.0);
      expect(p.floatNormY, 1.0);
      expect(p.playheadColorValue, PlaybackPrefs.defaultPlayheadColorValue);
      expect(p.playheadWidth, PlaybackPrefs.defaultPlayheadWidth);
      expect(p.playheadOpacity, PlaybackPrefs.defaultPlayheadOpacity);
      expect(p.playheadHeightScale, PlaybackPrefs.defaultPlayheadHeightScale);
    });

    test('count-in clamps to 0..2', () {
      expect(PlaybackPrefs.clampCountIn(-1), 0);
      expect(PlaybackPrefs.clampCountIn(5), 2);
      expect(
        const PlaybackPrefs().copyWith(countInMeasures: 2).countInMeasures,
        2,
      );
    });

    test('float norm clamps to 0..1', () {
      expect(PlaybackPrefs.clampNorm(-0.2), 0.0);
      expect(PlaybackPrefs.clampNorm(1.5), 1.0);
      final p = const PlaybackPrefs().copyWith(
        floatNormX: 0.25,
        floatNormY: 0.75,
      );
      expect(p.floatNormX, 0.25);
      expect(p.floatNormY, 0.75);
    });

    test('playhead width and opacity clamp', () {
      expect(PlaybackPrefs.clampPlayheadWidth(0.1), 1.0);
      expect(PlaybackPrefs.clampPlayheadWidth(99), 8.0);
      expect(PlaybackPrefs.clampPlayheadOpacity(0.0), 0.2);
      expect(PlaybackPrefs.clampPlayheadOpacity(2.0), 1.0);
      expect(PlaybackPrefs.clampPlayheadHeightScale(0.5), 1.0);
      expect(PlaybackPrefs.clampPlayheadHeightScale(3.0), 2.0);
      final p = const PlaybackPrefs().copyWith(
        playheadWidth: 4.0,
        playheadOpacity: 0.5,
        playheadColorValue: 0xFFE53935,
        playheadHeightScale: 1.4,
      );
      expect(p.playheadWidth, 4.0);
      expect(p.playheadOpacity, 0.5);
      expect(p.playheadColorValue, 0xFFE53935);
      expect(p.playheadHeightScale, 1.4);
      expect(p.playheadPaintColor.a, closeTo(0.5, 0.001));
    });

    test('json round-trip includes style and float', () {
      const p = PlaybackPrefs(
        showPlaybackControls: true,
        countInMeasures: 1,
        style: PlaybackControlsStyle.floating,
        floatNormX: 0.2,
        floatNormY: 0.8,
        playheadColorValue: 0xFFFF8F00,
        playheadWidth: 3.5,
        playheadOpacity: 0.7,
        playheadHeightScale: 1.5,
      );
      expect(PlaybackPrefs.fromJson(p.toJson()), p);
    });

    test('missing keys fall back to defaults', () {
      final p = PlaybackPrefs.fromJson({});
      expect(p.showPlaybackControls, isFalse);
      expect(p.countInMeasures, 0);
      expect(p.style, PlaybackControlsStyle.docked);
      expect(p.floatNormX, 1.0);
      expect(p.floatNormY, 1.0);
      expect(p.playheadColorValue, PlaybackPrefs.defaultPlayheadColorValue);
      expect(p.playheadWidth, PlaybackPrefs.defaultPlayheadWidth);
      expect(p.playheadOpacity, PlaybackPrefs.defaultPlayheadOpacity);
      expect(p.playheadHeightScale, PlaybackPrefs.defaultPlayheadHeightScale);
    });

    test('unknown style name falls back to docked', () {
      final p = PlaybackPrefs.fromJson({'style': 'tablet'});
      expect(p.style, PlaybackControlsStyle.docked);
    });
  });

  group('PlaybackPrefsStore', () {
    test('save / load round-trip', () async {
      final dir = await Directory.systemTemp.createTemp('playback_prefs_');
      addTearDown(() => dir.delete(recursive: true));
      final store = PlaybackPrefsStore(root: dir);
      const prefs = PlaybackPrefs(
        showPlaybackControls: true,
        countInMeasures: 2,
        style: PlaybackControlsStyle.floating,
        floatNormX: 0.1,
        floatNormY: 0.9,
      );
      await store.save(prefs);
      expect(await store.load(), prefs);
    });

    test('missing file → defaults', () async {
      final dir = await Directory.systemTemp.createTemp('playback_prefs_miss_');
      addTearDown(() => dir.delete(recursive: true));
      expect(await PlaybackPrefsStore(root: dir).load(), const PlaybackPrefs());
    });
  });
}
