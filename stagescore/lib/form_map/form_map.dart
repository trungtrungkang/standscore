/// Form structure for one Score — repeats, voltas, markers, jumps (Spec 0061).
///
/// Empty FormMap = play every physical measure once (0059). Geometry stays on
/// MeasureMap; this layer only orders visits on the playback timeline.
class FormMap {
  FormMap({
    List<FormRepeatRegion>? repeats,
    List<FormEnding>? endings,
    List<FormMarker>? markers,
    List<FormJump>? jumps,
  })  : repeats = List.unmodifiable(repeats ?? const []),
        endings = List.unmodifiable(endings ?? const []),
        markers = List.unmodifiable(markers ?? const []),
        jumps = List.unmodifiable(jumps ?? const []);

  final List<FormRepeatRegion> repeats;
  final List<FormEnding> endings;
  final List<FormMarker> markers;
  final List<FormJump> jumps;

  bool get isEmpty =>
      repeats.isEmpty && endings.isEmpty && markers.isEmpty && jumps.isEmpty;

  bool get isNotEmpty => !isEmpty;

  FormMap copyWith({
    List<FormRepeatRegion>? repeats,
    List<FormEnding>? endings,
    List<FormMarker>? markers,
    List<FormJump>? jumps,
  }) {
    return FormMap(
      repeats: repeats ?? this.repeats,
      endings: endings ?? this.endings,
      markers: markers ?? this.markers,
      jumps: jumps ?? this.jumps,
    );
  }

  Map<String, dynamic> toJson(String scoreId) => {
        'scoreId': scoreId,
        'repeats': [for (final r in repeats) r.toJson()],
        'endings': [for (final e in endings) e.toJson()],
        'markers': [for (final m in markers) m.toJson()],
        'jumps': [for (final j in jumps) j.toJson()],
      };

  factory FormMap.fromJson(Map<String, dynamic> json) {
    return FormMap(
      repeats: [
        for (final e in (json['repeats'] as List<dynamic>? ?? const []))
          FormRepeatRegion.fromJson(e as Map<String, dynamic>),
      ],
      endings: [
        for (final e in (json['endings'] as List<dynamic>? ?? const []))
          FormEnding.fromJson(e as Map<String, dynamic>),
      ],
      markers: [
        for (final e in (json['markers'] as List<dynamic>? ?? const []))
          FormMarker.fromJson(e as Map<String, dynamic>),
      ],
      jumps: [
        for (final e in (json['jumps'] as List<dynamic>? ?? const []))
          FormJump.fromJson(e as Map<String, dynamic>),
      ],
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! FormMap) return false;
    return _listEq(repeats, other.repeats) &&
        _listEq(endings, other.endings) &&
        _listEq(markers, other.markers) &&
        _listEq(jumps, other.jumps);
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(repeats),
        Object.hashAll(endings),
        Object.hashAll(markers),
        Object.hashAll(jumps),
      );
}

bool _listEq<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Repeat region on physical measures: play [startMeasure]…[endMeasure]
/// [times] times (default 2 = once through + one repeat).
class FormRepeatRegion {
  const FormRepeatRegion({
    required this.id,
    required this.startMeasure,
    required this.endMeasure,
    this.times = 2,
  });

  final String id;
  final int startMeasure;
  final int endMeasure;
  final int times;

  Map<String, dynamic> toJson() => {
        'id': id,
        'startMeasure': startMeasure,
        'endMeasure': endMeasure,
        'times': times,
      };

  factory FormRepeatRegion.fromJson(Map<String, dynamic> json) =>
      FormRepeatRegion(
        id: json['id'] as String,
        startMeasure: json['startMeasure'] as int,
        endMeasure: json['endMeasure'] as int,
        times: (json['times'] as num?)?.toInt() ?? 2,
      );

  @override
  bool operator ==(Object other) =>
      other is FormRepeatRegion &&
      other.id == id &&
      other.startMeasure == startMeasure &&
      other.endMeasure == endMeasure &&
      other.times == times;

  @override
  int get hashCode => Object.hash(id, startMeasure, endMeasure, times);
}

/// Volta / ending bracket on physical measures.
class FormEnding {
  const FormEnding({
    required this.id,
    required this.startMeasure,
    required this.endMeasure,
    required this.endingNumber,
  });

  final String id;
  final int startMeasure;
  final int endMeasure;
  final int endingNumber;

  Map<String, dynamic> toJson() => {
        'id': id,
        'startMeasure': startMeasure,
        'endMeasure': endMeasure,
        'endingNumber': endingNumber,
      };

  factory FormEnding.fromJson(Map<String, dynamic> json) => FormEnding(
        id: json['id'] as String,
        startMeasure: json['startMeasure'] as int,
        endMeasure: json['endMeasure'] as int,
        endingNumber: json['endingNumber'] as int,
      );

  @override
  bool operator ==(Object other) =>
      other is FormEnding &&
      other.id == id &&
      other.startMeasure == startMeasure &&
      other.endMeasure == endMeasure &&
      other.endingNumber == endingNumber;

  @override
  int get hashCode =>
      Object.hash(id, startMeasure, endMeasure, endingNumber);
}

/// Passive marker on a physical measure (Segno / Coda / Fine / To Coda label).
enum FormMarkerKind {
  segno,
  coda,
  fine,
  toCoda,
}

class FormMarker {
  const FormMarker({
    required this.id,
    required this.measure,
    required this.kind,
    this.targetId = '1',
  });

  final String id;
  final int measure;
  final FormMarkerKind kind;

  /// String id matching jump targets (web segno/coda ids). Default `'1'`.
  final String targetId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'measure': measure,
        'kind': kind.name,
        if (targetId != '1') 'targetId': targetId,
      };

  factory FormMarker.fromJson(Map<String, dynamic> json) => FormMarker(
        id: json['id'] as String,
        measure: json['measure'] as int,
        kind: FormMarkerKind.values.byName(json['kind'] as String),
        targetId: json['targetId'] as String? ?? '1',
      );

  @override
  bool operator ==(Object other) =>
      other is FormMarker &&
      other.id == id &&
      other.measure == measure &&
      other.kind == kind &&
      other.targetId == targetId;

  @override
  int get hashCode => Object.hash(id, measure, kind, targetId);
}

/// Active navigation instruction on a physical measure.
enum FormJumpKind {
  daCapo,
  dalSegno,
  toCoda,
}

class FormJump {
  const FormJump({
    required this.id,
    required this.measure,
    required this.kind,
    this.targetId = '1',
  });

  final String id;
  final int measure;
  final FormJumpKind kind;
  final String targetId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'measure': measure,
        'kind': kind.name,
        if (targetId != '1') 'targetId': targetId,
      };

  factory FormJump.fromJson(Map<String, dynamic> json) => FormJump(
        id: json['id'] as String,
        measure: json['measure'] as int,
        kind: FormJumpKind.values.byName(json['kind'] as String),
        targetId: json['targetId'] as String? ?? '1',
      );

  @override
  bool operator ==(Object other) =>
      other is FormJump &&
      other.id == id &&
      other.measure == measure &&
      other.kind == kind &&
      other.targetId == targetId;

  @override
  int get hashCode => Object.hash(id, measure, kind, targetId);
}
