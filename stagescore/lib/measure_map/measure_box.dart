import 'package:uuid/uuid.dart';

/// Default time signature for the first MeasureBox in a Score (Spec 0058 G3 #3).
const kDefaultTimeSignature = '4/4';

/// Default tempo (BPM) for the first MeasureBox in a Score (Spec 0058 G3 #3).
const kDefaultTempo = 120.0;

/// Number of BeatBoxes implied by a time-signature string such as `4/4`.
///
/// Uses the numerator. Invalid or empty input falls back to `4`.
int beatsFromTimeSignature(String? timeSignature) {
  if (timeSignature == null || timeSignature.isEmpty) return 4;
  final slash = timeSignature.indexOf('/');
  final top = slash < 0
      ? timeSignature
      : timeSignature.substring(0, slash);
  return int.tryParse(top.trim())?.clamp(1, 32) ?? 4;
}

/// Even **beat-anchor** positions for [beats] BeatBoxes — **N interior**
/// ratios (not the measure barlines). Spec 0058 rev. 2: each line marks where
/// that beat's notes sit so the musician can drag it onto the print.
///
/// Default = centre of each equal slice: `(i + 0.5) / N`. Width / anchor
/// position on the page is not duration (ADR 0019 quyết định 3b).
///
/// Web still stores N−1 **boundaries** between beats; convert with
/// [boundariesFromBeatAnchors] / [beatAnchorsFromBoundaries].
List<double> evenBeatSplits(int beats) {
  if (beats <= 0) return const [];
  return [for (var i = 0; i < beats; i++) (i + 0.5) / beats];
}

/// Region centres from web/legacy N−1 boundary ratios (edges at 0 and 1).
List<double> beatAnchorsFromBoundaries(List<double> boundaries) {
  final edges = <double>[0.0, ...boundaries, 1.0];
  return [
    for (var i = 0; i < edges.length - 1; i++)
      (edges[i] + edges[i + 1]) / 2,
  ];
}

/// Web N−1 boundaries = midpoints between consecutive StageScore anchors.
List<double> boundariesFromBeatAnchors(List<double> anchors) {
  if (anchors.length <= 1) return const [];
  return [
    for (var i = 0; i < anchors.length - 1; i++)
      (anchors[i] + anchors[i + 1]) / 2,
  ];
}

/// Migrate on-disk / web payloads into N interior beat anchors.
///
/// Idempotent when [splits] is already N anchors for [beats].
List<double> normalizeBeatSplits(List<double> splits, int beats) {
  if (beats <= 0) return const [];
  if (splits.isEmpty) return evenBeatSplits(beats);
  // Already N interior anchors for this meter.
  if (splits.length == beats && splits.last < 1.0 - 1e-9) {
    return List<double>.from(splits);
  }
  // Mistaken rev.2 right-edges ending at 1.0 → centres of those slices.
  if (splits.length == beats && splits.last >= 1.0 - 1e-9) {
    return beatAnchorsFromBoundaries(splits.sublist(0, splits.length - 1));
  }
  // Classic / web N−1 boundaries for this meter.
  if (splits.length == beats - 1) {
    return beatAnchorsFromBoundaries(splits);
  }
  // Count disagrees with resolved meter — even anchors (do not double-convert).
  return evenBeatSplits(beats);
}

/// One measure box on a PDF page — geometry only, not time (Spec 0058).
///
/// Coordinates are normalized 0–1, origin top-left of the **paper page**
/// ([pageNumber] is the absolute 1-based PdfDocument page).
class MeasureBox {
  const MeasureBox({
    required this.id,
    required this.pageNumber,
    required this.measureNumber,
    required this.systemIndex,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.timeSignature,
    this.tempo,
    this.beatSplits = const [],
    this.startsAtBeat = 0,
  });

  final String id;

  /// Absolute 1-based PdfDocument page (paper space — same as annotations).
  final int pageNumber;

  /// Continuous 1-based measure index within this Score (Spec 0058 G3 #2).
  final int measureNumber;

  /// System (staff system) index on [pageNumber]; rebuilds SystemBox by group.
  final int systemIndex;

  /// Left edge in normalized page coords \[0, 1\].
  final double x;

  /// Top edge in normalized page coords \[0, 1\].
  final double y;

  /// Width in normalized page coords.
  final double width;

  /// Height in normalized page coords.
  final double height;

  /// Stored only when different from the previous measure; else inherited.
  final String? timeSignature;

  /// Stored only when different from the previous measure; else inherited.
  final double? tempo;

  /// N interior beat-anchor ratios (0..1), one per beat — not barlines.
  /// Web wire format is N−1 boundaries between beats.
  final List<double> beatSplits;

  /// 0-based beat index where audible music starts (Spec 0059 Option B).
  ///
  /// `0` = full measure from the written downbeat. Stored only when &gt; 0.
  final int startsAtBeat;

  MeasureBox copyWith({
    String? id,
    int? pageNumber,
    int? measureNumber,
    int? systemIndex,
    double? x,
    double? y,
    double? width,
    double? height,
    String? timeSignature,
    double? tempo,
    List<double>? beatSplits,
    int? startsAtBeat,
    bool clearTimeSignature = false,
    bool clearTempo = false,
  }) {
    return MeasureBox(
      id: id ?? this.id,
      pageNumber: pageNumber ?? this.pageNumber,
      measureNumber: measureNumber ?? this.measureNumber,
      systemIndex: systemIndex ?? this.systemIndex,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      timeSignature: clearTimeSignature
          ? null
          : (timeSignature ?? this.timeSignature),
      tempo: clearTempo ? null : (tempo ?? this.tempo),
      beatSplits: beatSplits ?? this.beatSplits,
      startsAtBeat: startsAtBeat ?? this.startsAtBeat,
    );
  }

  /// Right edge in normalized coords.
  double get right => x + width;

  /// Bottom edge in normalized coords.
  double get bottom => y + height;

  bool containsPoint(double px, double py) =>
      px >= x && px <= right && py >= y && py <= bottom;

  Map<String, dynamic> toJson() => {
    'id': id,
    'pageNumber': pageNumber,
    'measureNumber': measureNumber,
    'systemIndex': systemIndex,
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    if (timeSignature != null) 'timeSignature': timeSignature,
    if (tempo != null) 'tempo': tempo,
    if (beatSplits.isNotEmpty) 'beatSplits': beatSplits,
    if (startsAtBeat > 0) 'startsAtBeat': startsAtBeat,
  };

  factory MeasureBox.fromJson(Map<String, dynamic> json) {
    final splitsRaw = json['beatSplits'] as List<dynamic>?;
    final raw = [
      for (final s in splitsRaw ?? const []) (s as num).toDouble(),
    ];
    // Full migration needs resolved meter (inheritance) — store.loadJson
    // calls [normalizeBeatSplits] after load. Keep raw here.
    return MeasureBox(
      id: json['id'] as String? ?? const Uuid().v4(),
      pageNumber: json['pageNumber'] as int,
      measureNumber: json['measureNumber'] as int,
      systemIndex: json['systemIndex'] as int,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      timeSignature: json['timeSignature'] as String?,
      tempo: (json['tempo'] as num?)?.toDouble(),
      beatSplits: raw,
      startsAtBeat: (json['startsAtBeat'] as num?)?.toInt() ?? 0,
    );
  }

  /// Web `MeasureBox` shape (`pageIndex`, no `tempo` / `noteEvents`).
  ///
  /// Exports N−1 **boundaries** derived from N interior anchors.
  Map<String, dynamic> toWebJson() {
    final webSplits = boundariesFromBeatAnchors(beatSplits);
    return {
      'id': id,
      'pageIndex': pageNumber,
      'measureNumber': measureNumber,
      'systemIndex': systemIndex,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      if (timeSignature != null) 'timeSignature': timeSignature,
      if (webSplits.isNotEmpty) 'beatSplits': webSplits,
      if (startsAtBeat > 0) 'startsAtBeat': startsAtBeat,
    };
  }

  factory MeasureBox.fromWebJson(Map<String, dynamic> json) {
    final splitsRaw = json['beatSplits'] as List<dynamic>?;
    final raw = [
      for (final s in splitsRaw ?? const []) (s as num).toDouble(),
    ];
    final ts = json['timeSignature'] as String?;
    // When TS is on the payload, convert N−1 → N now; otherwise leave raw
    // for [MeasureMapStore.migrateBeatSplits] (needs inheritance).
    final splits = ts != null
        ? normalizeBeatSplits(raw, beatsFromTimeSignature(ts))
        : raw;
    return MeasureBox(
      id: json['id'] as String? ?? const Uuid().v4(),
      pageNumber: json['pageIndex'] as int,
      measureNumber: json['measureNumber'] as int,
      systemIndex: json['systemIndex'] as int,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      timeSignature: ts,
      beatSplits: splits,
      startsAtBeat: (json['startsAtBeat'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Effective tempo / time signature after walking inheritance (Spec 0058 G3 #3).
class ResolvedMeasureMeta {
  const ResolvedMeasureMeta({
    required this.timeSignature,
    required this.tempo,
  });

  final String timeSignature;
  final double tempo;
}
