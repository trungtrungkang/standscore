/// One measure on the SyncMap timeline (≈ web `TimemapEntry`, Spec 0059/0061).
class SyncMapEntry {
  const SyncMapEntry({
    required this.timeMs,
    required this.measure,
    required this.beatTimestamps,
    required this.timeSignature,
    required this.tempo,
    required this.durationInQuarters,
    this.startsAtBeat = 0,
    int? physicalMeasure,
  }) : physicalMeasure = physicalMeasure ?? measure;

  /// Downbeat (or first audible beat) of this measure, milliseconds.
  final double timeMs;

  /// Latent visit index on the playback timeline (web `TimemapEntry.measure`).
  ///
  /// With an empty FormMap this equals the printed [physicalMeasure] (0059).
  final int measure;

  /// Printed MeasureBox number — playhead / badge use this (Spec 0061 G3 #3/#8).
  /// Not written to web JSON; derived at unroll.
  final int physicalMeasure;

  /// Per-beat timestamps; `[0] === timeMs`. Evenly spaced in time.
  final List<double> beatTimestamps;

  final String timeSignature;

  /// BPM of a quarter note.
  final double tempo;

  /// Audible duration of this measure in quarter notes (pickup-aware).
  final double durationInQuarters;

  /// 0-based beat index where audible music starts (web `startsAtBeat`).
  final int startsAtBeat;

  /// Duration in milliseconds derived from quarters × tempo.
  double get durationMs => durationInQuarters * (60000.0 / tempo);

  /// End of this entry on the timeline (exclusive for lookup).
  double get endMs => timeMs + durationMs;

  Map<String, dynamic> toWebJson() => {
    'timeMs': timeMs,
    'measure': measure,
    'beatTimestamps': beatTimestamps,
    'timeSignature': timeSignature,
    'tempo': tempo,
    'durationInQuarters': durationInQuarters,
    if (startsAtBeat > 0) 'startsAtBeat': startsAtBeat,
  };

  factory SyncMapEntry.fromWebJson(Map<String, dynamic> json) {
    final beatsRaw = json['beatTimestamps'] as List<dynamic>?;
    return SyncMapEntry(
      timeMs: (json['timeMs'] as num).toDouble(),
      measure: json['measure'] as int,
      beatTimestamps: [
        for (final b in beatsRaw ?? const []) (b as num).toDouble(),
      ],
      timeSignature: json['timeSignature'] as String? ?? '4/4',
      tempo: (json['tempo'] as num?)?.toDouble() ?? 120.0,
      durationInQuarters: (json['durationInQuarters'] as num?)?.toDouble() ?? 4.0,
      startsAtBeat: (json['startsAtBeat'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! SyncMapEntry) return false;
    if (other.timeMs != timeMs ||
        other.measure != measure ||
        other.physicalMeasure != physicalMeasure ||
        other.timeSignature != timeSignature ||
        other.tempo != tempo ||
        other.durationInQuarters != durationInQuarters ||
        other.startsAtBeat != startsAtBeat) {
      return false;
    }
    if (other.beatTimestamps.length != beatTimestamps.length) return false;
    for (var i = 0; i < beatTimestamps.length; i++) {
      if (other.beatTimestamps[i] != beatTimestamps[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    timeMs,
    measure,
    physicalMeasure,
    Object.hashAll(beatTimestamps),
    timeSignature,
    tempo,
    durationInQuarters,
    startsAtBeat,
  );
}

/// Computed SyncMap — pure value, not persisted in Spec 0059.
class SyncMap {
  const SyncMap(this.entries);

  final List<SyncMapEntry> entries;

  bool get isEmpty => entries.isEmpty;

  bool get isNotEmpty => entries.isNotEmpty;

  SyncMapEntry? get first => entries.isEmpty ? null : entries.first;

  SyncMapEntry? get last => entries.isEmpty ? null : entries.last;

  /// Total timeline length in ms (end of last entry).
  double get totalDurationMs => last?.endMs ?? 0;

  List<Map<String, dynamic>> toWebList() => [
    for (final e in entries) e.toWebJson(),
  ];

  factory SyncMap.fromWebList(List<dynamic> list) => SyncMap([
    for (final e in list) SyncMapEntry.fromWebJson(e as Map<String, dynamic>),
  ]);

  @override
  bool operator ==(Object other) {
    if (other is! SyncMap) return false;
    if (other.entries.length != entries.length) return false;
    for (var i = 0; i < entries.length; i++) {
      if (other.entries[i] != entries[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(entries);
}
