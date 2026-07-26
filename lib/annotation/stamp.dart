import 'dart:ui';

import 'package:standscore/annotation/draw_tool.dart';

/// Built-in stamp catalog (Spec 0019 / G3).
enum StampKind {
  dynamicP,
  dynamicF,
  sharp,
  flat,
  natural,
  box,
  circle,
  arrow,
  text,
}

extension StampKindX on StampKind {
  bool get isShape =>
      this == StampKind.box ||
      this == StampKind.circle ||
      this == StampKind.arrow;

  /// Short picker label (one token — avoid glyph+label duplication).
  String get label => switch (this) {
        StampKind.dynamicP => 'p',
        StampKind.dynamicF => 'f',
        StampKind.sharp => '\u266F',
        StampKind.flat => '\u266D',
        StampKind.natural => '\u266E',
        StampKind.box => 'Box',
        StampKind.circle => 'Circle',
        StampKind.arrow => 'Arrow',
        StampKind.text => 'Text',
      };

  /// Glyph drawn on the page for symbol stamps (empty for shapes/text).
  String get glyph => switch (this) {
        StampKind.dynamicP => 'p',
        StampKind.dynamicF => 'f',
        StampKind.sharp => '\u266F',
        StampKind.flat => '\u266D',
        StampKind.natural => '\u266E',
        StampKind.text => '',
        StampKind.box || StampKind.circle || StampKind.arrow => '',
      };
}

/// Placed stamp in normalized page coordinates (Spec 0019).
class AnnotationStamp {
  const AnnotationStamp({
    required this.id,
    required this.pageNumber,
    required this.kind,
    required this.center,
    this.size = 0.06,
    this.color = DrawToolPresets.penColor,
    this.text,
  });

  final String id;
  final int pageNumber;
  final StampKind kind;

  /// Normalized center on the page (0–1).
  final Offset center;

  /// Size as a fraction of page width.
  final double size;

  final Color color;

  /// Only for [StampKind.text].
  final String? text;

  AnnotationStamp copyWith({
    Offset? center,
    double? size,
    Color? color,
    String? text,
  }) {
    return AnnotationStamp(
      id: id,
      pageNumber: pageNumber,
      kind: kind,
      center: center ?? this.center,
      size: size ?? this.size,
      color: color ?? this.color,
      text: text ?? this.text,
    );
  }

  /// Axis-aligned hit box in normalized coords.
  Rect get hitRect {
    final w = kind == StampKind.arrow ? size * 1.6 : size * 1.2;
    final h = kind == StampKind.arrow ? size * 0.8 : size * 1.2;
    return Rect.fromCenter(center: center, width: w, height: h);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pageNumber': pageNumber,
        'kind': kind.name,
        'cx': center.dx,
        'cy': center.dy,
        'size': size,
        'color': color.toARGB32(),
        if (text != null) 'text': text,
      };

  /// Returns null if [kind] is unknown (forward-compatible load).
  static AnnotationStamp? tryFromJson(Map<String, dynamic> json) {
    final kindName = json['kind'] as String?;
    if (kindName == null) return null;
    StampKind? kind;
    for (final k in StampKind.values) {
      if (k.name == kindName) {
        kind = k;
        break;
      }
    }
    if (kind == null) return null;
    final id = json['id'] as String?;
    final page = json['pageNumber'] as int?;
    if (id == null || page == null) return null;
    return AnnotationStamp(
      id: id,
      pageNumber: page,
      kind: kind,
      center: Offset(
        (json['cx'] as num).toDouble(),
        (json['cy'] as num).toDouble(),
      ),
      size: (json['size'] as num?)?.toDouble() ?? 0.06,
      color: Color(json['color'] as int? ?? DrawToolPresets.penColor.toARGB32()),
      text: json['text'] as String?,
    );
  }
}
