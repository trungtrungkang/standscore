/// A selectable time signature for the metronome sheet.
class MeterChoice {
  const MeterChoice(this.beats, this.beatUnit);

  final int beats;
  final int beatUnit;

  String get label => '$beats/$beatUnit';

  @override
  bool operator ==(Object other) =>
      other is MeterChoice &&
      other.beats == beats &&
      other.beatUnit == beatUnit;

  @override
  int get hashCode => Object.hash(beats, beatUnit);
}

/// App-level metronome preferences (Spec 0030 / P2.13).
class MetronomePrefs {
  const MetronomePrefs({
    this.tempoBpm = defaultTempo,
    this.beatsPerBar = defaultBeatsPerBar,
    this.beatUnit = defaultBeatUnit,
    this.volume = defaultVolume,
    this.muted = false,
    this.accentEnabled = true,
    this.showBeatsOnScore = true,
  });

  static const minTempo = 40;
  static const maxTempo = 218;
  static const defaultTempo = 100;
  static const minBeatsPerBar = 1;
  static const maxBeatsPerBar = 12;
  static const defaultBeatsPerBar = 4;
  static const defaultBeatUnit = 4;
  static const defaultVolume = 0.8;

  /// Allowed note-value denominators for meter labels (click rate stays BPM).
  static const beatUnitChoices = <int>[2, 4, 8];

  /// Common meters offered in the sheet (accent groups + labels).
  static const meterChoices = <MeterChoice>[
    MeterChoice(2, 2),
    MeterChoice(2, 4),
    MeterChoice(3, 4),
    MeterChoice(3, 8),
    MeterChoice(4, 4),
    MeterChoice(5, 4),
    MeterChoice(5, 8),
    MeterChoice(6, 4),
    MeterChoice(6, 8),
    MeterChoice(7, 4),
    MeterChoice(7, 8),
    MeterChoice(9, 8),
    MeterChoice(12, 8),
  ];

  final int tempoBpm;
  final int beatsPerBar;

  /// Denominator of the time signature label (2, 4, or 8). Does not change BPM.
  final int beatUnit;
  final double volume;
  final bool muted;

  /// When false, every click is equal (no strong/weak beat).
  final bool accentEnabled;

  /// Whether a running metronome keeps a beat strip on the Score once the
  /// chrome has hidden itself (Spec 0030, reopened after G4).
  ///
  /// Defaults on: the strip only exists while the metronome runs, and starting
  /// it is a deliberate act. It also gives "Mute (visual only)" something to
  /// show — muted, the metronome had no output at all once the chrome went.
  final bool showBeatsOnScore;

  static int clampTempo(int value) => value.clamp(minTempo, maxTempo);

  static int clampBeatsPerBar(int value) =>
      value.clamp(minBeatsPerBar, maxBeatsPerBar);

  static int clampBeatUnit(int value) {
    if (beatUnitChoices.contains(value)) return value;
    return defaultBeatUnit;
  }

  static double clampVolume(double value) => value.clamp(0.0, 1.0);

  /// 0-based beat index within the bar; 0 is the accent when enabled.
  static int beatInBar({required int absoluteBeat, required int beatsPerBar}) {
    final n = clampBeatsPerBar(beatsPerBar);
    if (n <= 0) return 0;
    final beat = absoluteBeat % n;
    return beat < 0 ? beat + n : beat;
  }

  static bool isAccentBeat(int beatInBar) => beatInBar == 0;

  /// Interval between clicks for [tempoBpm].
  static Duration beatInterval(int tempoBpm) {
    final bpm = clampTempo(tempoBpm);
    return Duration(microseconds: (60000000 / bpm).round());
  }

  String get meterLabel => accentEnabled ? '$beatsPerBar/$beatUnit' : 'equal';

  MeterChoice get selectedMeter => MeterChoice(beatsPerBar, beatUnit);

  MetronomePrefs copyWith({
    int? tempoBpm,
    int? beatsPerBar,
    int? beatUnit,
    double? volume,
    bool? muted,
    bool? accentEnabled,
    bool? showBeatsOnScore,
  }) {
    return MetronomePrefs(
      tempoBpm: tempoBpm != null ? clampTempo(tempoBpm) : this.tempoBpm,
      beatsPerBar: beatsPerBar != null
          ? clampBeatsPerBar(beatsPerBar)
          : this.beatsPerBar,
      beatUnit: beatUnit != null ? clampBeatUnit(beatUnit) : this.beatUnit,
      volume: volume != null ? clampVolume(volume) : this.volume,
      muted: muted ?? this.muted,
      accentEnabled: accentEnabled ?? this.accentEnabled,
      showBeatsOnScore: showBeatsOnScore ?? this.showBeatsOnScore,
    );
  }

  /// Selects a labeled meter and enables accent grouping.
  MetronomePrefs withMeter(MeterChoice meter) {
    return copyWith(
      beatsPerBar: meter.beats,
      beatUnit: meter.beatUnit,
      accentEnabled: true,
    );
  }

  Map<String, dynamic> toJson() => {
    'tempoBpm': tempoBpm,
    'beatsPerBar': beatsPerBar,
    'beatUnit': beatUnit,
    'volume': volume,
    'muted': muted,
    'accentEnabled': accentEnabled,
    'showBeatsOnScore': showBeatsOnScore,
  };

  factory MetronomePrefs.fromJson(Map<String, dynamic> json) {
    return MetronomePrefs(
      tempoBpm: clampTempo((json['tempoBpm'] as num?)?.toInt() ?? defaultTempo),
      beatsPerBar: clampBeatsPerBar(
        (json['beatsPerBar'] as num?)?.toInt() ?? defaultBeatsPerBar,
      ),
      beatUnit: clampBeatUnit(
        (json['beatUnit'] as num?)?.toInt() ?? defaultBeatUnit,
      ),
      volume: clampVolume(
        (json['volume'] as num?)?.toDouble() ?? defaultVolume,
      ),
      muted: json['muted'] as bool? ?? false,
      accentEnabled: json['accentEnabled'] as bool? ?? true,
      // Installs whose prefs predate the key get the strip too, same as 0034
      // did for PerformanceMode: it is the behaviour we would have shipped.
      showBeatsOnScore: json['showBeatsOnScore'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MetronomePrefs &&
        other.tempoBpm == tempoBpm &&
        other.beatsPerBar == beatsPerBar &&
        other.beatUnit == beatUnit &&
        other.volume == volume &&
        other.muted == muted &&
        other.accentEnabled == accentEnabled &&
        other.showBeatsOnScore == showBeatsOnScore;
  }

  @override
  int get hashCode => Object.hash(
    tempoBpm,
    beatsPerBar,
    beatUnit,
    volume,
    muted,
    accentEnabled,
    showBeatsOnScore,
  );
}
