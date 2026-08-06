import 'package:flutter/material.dart';
import 'package:stagescore/measure_map/measure_map_store.dart';
import 'package:stagescore/sync_map/playback_prefs.dart';
import 'package:stagescore/sync_map/sync_map_playback.dart';

/// Bundle passed into page slots for the SyncMap playhead (Spec 0059).
class PlayheadOverlayConfig {
  const PlayheadOverlayConfig({
    required this.playback,
    required this.store,
    this.suppressed = false,
    this.color = const Color(PlaybackPrefs.defaultPlayheadColorValue),
    this.width = PlaybackPrefs.defaultPlayheadWidth,
    this.opacity = PlaybackPrefs.defaultPlayheadOpacity,
    this.heightScale = PlaybackPrefs.defaultPlayheadHeightScale,
  });

  final SyncMapPlayback playback;
  final MeasureMapStore store;

  /// True while MeasureMap editing — hide playhead (G3 2f).
  final bool suppressed;

  final Color color;
  final double width;
  final double opacity;

  /// ≥ 1.0 — expands the line vertically around the MeasureBox centre.
  final double heightScale;

  Color get paintColor => color.withValues(alpha: opacity);
}
