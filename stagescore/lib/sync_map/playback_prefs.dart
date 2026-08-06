import 'package:flutter/material.dart';

/// How Playback controls are presented on PdfMode (Spec 0059 G4).
enum PlaybackControlsStyle {
  /// Full seek + transport docked above bottom chrome.
  docked,

  /// Compact Play/Pause + Stop pill, draggable over the score.
  floating,
}

/// App-level Playback controls prefs (Spec 0059).
class PlaybackPrefs {
  const PlaybackPrefs({
    this.showPlaybackControls = false,
    this.countInMeasures = defaultCountIn,
    this.style = PlaybackControlsStyle.docked,
    this.floatNormX = defaultFloatNormX,
    this.floatNormY = defaultFloatNormY,
    this.playheadColorValue = defaultPlayheadColorValue,
    this.playheadWidth = defaultPlayheadWidth,
    this.playheadOpacity = defaultPlayheadOpacity,
    this.playheadHeightScale = defaultPlayheadHeightScale,
  });

  static const minCountIn = 0;
  static const maxCountIn = 2;
  /// Off by default — G4 tightened Spec 0059 G3 11 (was 1).
  static const defaultCountIn = 0;

  /// Bottom-right of the safe area (top-left of pill in free space).
  static const defaultFloatNormX = 1.0;
  static const defaultFloatNormY = 1.0;

  /// Material red — readable on white / sepia; thinner default (G4).
  static const defaultPlayheadColorValue = 0xFFE53935;
  static const defaultPlayheadWidth = 1.4;
  static const minPlayheadWidth = 1.0;
  static const maxPlayheadWidth = 8.0;
  static const defaultPlayheadOpacity = 1.0;
  static const minPlayheadOpacity = 0.2;
  static const maxPlayheadOpacity = 1.0;

  /// Multiplier on MeasureBox height — 1.0 = flush with the box; never below.
  static const defaultPlayheadHeightScale = 1.0;
  static const minPlayheadHeightScale = 1.0;
  static const maxPlayheadHeightScale = 2.0;

  static const playheadColorPresets = <int>[
    defaultPlayheadColorValue, // red
    0xFF8B0000, // deep red
    0xFFFF8F00, // amber (matches count-in badge)
    0xFF00897B, // teal
    0xFF212121, // near-black
  ];

  /// ScoreMenu show/hide — default hidden (G3 2b).
  final bool showPlaybackControls;

  /// Count-in measures before Play from stop / first play. 0 / 1 / 2.
  final int countInMeasures;

  /// Docked bar vs floating pill.
  final PlaybackControlsStyle style;

  /// Pill top-left as a fraction of free space (0–1). `(1,1)` = bottom-right.
  final double floatNormX;
  final double floatNormY;

  /// ARGB playhead stroke color (opacity applied separately).
  final int playheadColorValue;

  /// Stroke width in logical pixels.
  final double playheadWidth;

  /// 0–1 multiplier on the color alpha.
  final double playheadOpacity;

  /// Vertical length vs MeasureBox height (≥ 1.0, centered on the box).
  final double playheadHeightScale;

  Color get playheadColor => Color(playheadColorValue);

  Color get playheadPaintColor =>
      playheadColor.withValues(alpha: playheadOpacity);

  static int clampCountIn(int value) => value.clamp(minCountIn, maxCountIn);

  static double clampNorm(double value) => value.clamp(0.0, 1.0);

  static double clampPlayheadWidth(double value) =>
      value.clamp(minPlayheadWidth, maxPlayheadWidth);

  static double clampPlayheadOpacity(double value) =>
      value.clamp(minPlayheadOpacity, maxPlayheadOpacity);

  static double clampPlayheadHeightScale(double value) =>
      value.clamp(minPlayheadHeightScale, maxPlayheadHeightScale);

  static PlaybackControlsStyle styleFromName(String? name) {
    for (final s in PlaybackControlsStyle.values) {
      if (s.name == name) return s;
    }
    return PlaybackControlsStyle.docked;
  }

  PlaybackPrefs copyWith({
    bool? showPlaybackControls,
    int? countInMeasures,
    PlaybackControlsStyle? style,
    double? floatNormX,
    double? floatNormY,
    int? playheadColorValue,
    double? playheadWidth,
    double? playheadOpacity,
    double? playheadHeightScale,
  }) {
    return PlaybackPrefs(
      showPlaybackControls: showPlaybackControls ?? this.showPlaybackControls,
      countInMeasures: countInMeasures != null
          ? clampCountIn(countInMeasures)
          : this.countInMeasures,
      style: style ?? this.style,
      floatNormX: floatNormX != null ? clampNorm(floatNormX) : this.floatNormX,
      floatNormY: floatNormY != null ? clampNorm(floatNormY) : this.floatNormY,
      playheadColorValue: playheadColorValue ?? this.playheadColorValue,
      playheadWidth: playheadWidth != null
          ? clampPlayheadWidth(playheadWidth)
          : this.playheadWidth,
      playheadOpacity: playheadOpacity != null
          ? clampPlayheadOpacity(playheadOpacity)
          : this.playheadOpacity,
      playheadHeightScale: playheadHeightScale != null
          ? clampPlayheadHeightScale(playheadHeightScale)
          : this.playheadHeightScale,
    );
  }

  Map<String, dynamic> toJson() => {
    'showPlaybackControls': showPlaybackControls,
    'countInMeasures': countInMeasures,
    'style': style.name,
    'floatNormX': floatNormX,
    'floatNormY': floatNormY,
    'playheadColorValue': playheadColorValue,
    'playheadWidth': playheadWidth,
    'playheadOpacity': playheadOpacity,
    'playheadHeightScale': playheadHeightScale,
  };

  factory PlaybackPrefs.fromJson(Map<String, dynamic> json) {
    return PlaybackPrefs(
      showPlaybackControls: json['showPlaybackControls'] as bool? ?? false,
      countInMeasures: clampCountIn(
        (json['countInMeasures'] as num?)?.toInt() ?? defaultCountIn,
      ),
      style: styleFromName(json['style'] as String?),
      floatNormX: clampNorm(
        (json['floatNormX'] as num?)?.toDouble() ?? defaultFloatNormX,
      ),
      floatNormY: clampNorm(
        (json['floatNormY'] as num?)?.toDouble() ?? defaultFloatNormY,
      ),
      playheadColorValue:
          (json['playheadColorValue'] as num?)?.toInt() ??
          defaultPlayheadColorValue,
      playheadWidth: clampPlayheadWidth(
        (json['playheadWidth'] as num?)?.toDouble() ?? defaultPlayheadWidth,
      ),
      playheadOpacity: clampPlayheadOpacity(
        (json['playheadOpacity'] as num?)?.toDouble() ??
            defaultPlayheadOpacity,
      ),
      playheadHeightScale: clampPlayheadHeightScale(
        (json['playheadHeightScale'] as num?)?.toDouble() ??
            defaultPlayheadHeightScale,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PlaybackPrefs &&
      other.showPlaybackControls == showPlaybackControls &&
      other.countInMeasures == countInMeasures &&
      other.style == style &&
      other.floatNormX == floatNormX &&
      other.floatNormY == floatNormY &&
      other.playheadColorValue == playheadColorValue &&
      other.playheadWidth == playheadWidth &&
      other.playheadOpacity == playheadOpacity &&
      other.playheadHeightScale == playheadHeightScale;

  @override
  int get hashCode => Object.hash(
    showPlaybackControls,
    countInMeasures,
    style,
    floatNormX,
    floatNormY,
    playheadColorValue,
    playheadWidth,
    playheadOpacity,
    playheadHeightScale,
  );
}
