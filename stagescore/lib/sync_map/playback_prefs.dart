/// App-level Playback controls prefs (Spec 0059).
class PlaybackPrefs {
  const PlaybackPrefs({
    this.showPlaybackControls = false,
    this.countInMeasures = defaultCountIn,
  });

  static const minCountIn = 0;
  static const maxCountIn = 2;
  /// Off by default — G4 tightened Spec 0059 G3 11 (was 1).
  static const defaultCountIn = 0;

  /// ScoreMenu show/hide — default hidden (G3 2b).
  final bool showPlaybackControls;

  /// Count-in measures before Play from stop / first play. 0 / 1 / 2.
  final int countInMeasures;

  static int clampCountIn(int value) => value.clamp(minCountIn, maxCountIn);

  PlaybackPrefs copyWith({
    bool? showPlaybackControls,
    int? countInMeasures,
  }) {
    return PlaybackPrefs(
      showPlaybackControls: showPlaybackControls ?? this.showPlaybackControls,
      countInMeasures: countInMeasures != null
          ? clampCountIn(countInMeasures)
          : this.countInMeasures,
    );
  }

  Map<String, dynamic> toJson() => {
    'showPlaybackControls': showPlaybackControls,
    'countInMeasures': countInMeasures,
  };

  factory PlaybackPrefs.fromJson(Map<String, dynamic> json) {
    return PlaybackPrefs(
      showPlaybackControls: json['showPlaybackControls'] as bool? ?? false,
      countInMeasures: clampCountIn(
        (json['countInMeasures'] as num?)?.toInt() ?? defaultCountIn,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PlaybackPrefs &&
      other.showPlaybackControls == showPlaybackControls &&
      other.countInMeasures == countInMeasures;

  @override
  int get hashCode => Object.hash(showPlaybackControls, countInMeasures);
}
