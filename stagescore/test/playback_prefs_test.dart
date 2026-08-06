import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/sync_map/playback_prefs.dart';
import 'package:stagescore/sync_map/playback_prefs_store.dart';

void main() {
  group('PlaybackPrefs', () {
    test('defaults: controls hidden, count-in off', () {
      const p = PlaybackPrefs();
      expect(p.showPlaybackControls, isFalse);
      expect(p.countInMeasures, 0);
    });

    test('count-in clamps to 0..2', () {
      expect(PlaybackPrefs.clampCountIn(-1), 0);
      expect(PlaybackPrefs.clampCountIn(5), 2);
      expect(
        const PlaybackPrefs().copyWith(countInMeasures: 2).countInMeasures,
        2,
      );
    });

    test('json round-trip', () {
      const p = PlaybackPrefs(showPlaybackControls: true, countInMeasures: 1);
      expect(PlaybackPrefs.fromJson(p.toJson()), p);
    });

    test('missing keys fall back to defaults', () {
      final p = PlaybackPrefs.fromJson({});
      expect(p.showPlaybackControls, isFalse);
      expect(p.countInMeasures, 0);
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
