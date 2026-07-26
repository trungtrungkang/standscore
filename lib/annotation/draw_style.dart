import 'dart:ui';

import 'package:standscore/annotation/draw_tool.dart';

/// App-level last-used stroke style (Spec 0018).
class DrawStylePrefs {
  const DrawStylePrefs({
    this.penColorValue = 0xFFE11D48,
    this.penWidth = DrawToolPresets.penWidth,
    this.markerColorValue = 0x99FACC15,
    this.markerWidth = DrawToolPresets.markerWidth,
    this.straightLine = false,
  });

  final int penColorValue;
  final double penWidth;
  final int markerColorValue;
  final double markerWidth;
  final bool straightLine;

  Color get penColor => Color(penColorValue);
  Color get markerColor => Color(markerColorValue);

  Color colorFor(DrawTool tool) => switch (tool) {
        DrawTool.pen => penColor,
        DrawTool.marker => markerColor,
        DrawTool.eraser || DrawTool.eyedropper => penColor,
      };

  double widthFor(DrawTool tool) => switch (tool) {
        DrawTool.pen => penWidth,
        DrawTool.marker => markerWidth,
        DrawTool.eraser => DrawToolPresets.eraserRadius * 2,
        DrawTool.eyedropper => penWidth,
      };

  DrawStylePrefs copyWith({
    int? penColorValue,
    double? penWidth,
    int? markerColorValue,
    double? markerWidth,
    bool? straightLine,
  }) {
    return DrawStylePrefs(
      penColorValue: penColorValue ?? this.penColorValue,
      penWidth: penWidth ?? this.penWidth,
      markerColorValue: markerColorValue ?? this.markerColorValue,
      markerWidth: markerWidth ?? this.markerWidth,
      straightLine: straightLine ?? this.straightLine,
    );
  }

  /// Apply a sampled/picked opaque color to the active ink tool.
  DrawStylePrefs withColorFor(DrawTool tool, Color color) {
    final argb = color.toARGB32();
    return switch (tool) {
      DrawTool.marker => copyWith(
          markerColorValue: _withMarkerAlpha(argb),
        ),
      _ => copyWith(penColorValue: 0xFF000000 | (argb & 0x00FFFFFF)),
    };
  }

  Map<String, dynamic> toJson() => {
        'penColor': penColorValue,
        'penWidth': penWidth,
        'markerColor': markerColorValue,
        'markerWidth': markerWidth,
        'straightLine': straightLine,
      };

  factory DrawStylePrefs.fromJson(Map<String, dynamic> json) {
    return DrawStylePrefs(
      penColorValue: json['penColor'] as int? ?? 0xFFE11D48,
      penWidth: (json['penWidth'] as num?)?.toDouble() ?? DrawToolPresets.penWidth,
      markerColorValue: json['markerColor'] as int? ?? 0x99FACC15,
      markerWidth:
          (json['markerWidth'] as num?)?.toDouble() ?? DrawToolPresets.markerWidth,
      straightLine: json['straightLine'] as bool? ?? false,
    );
  }
}

int _withMarkerAlpha(int argb) => 0x99000000 | (argb & 0x00FFFFFF);

/// Compact color palette for the Draw toolbar.
const List<int> drawColorPalette = <int>[
  0xFFE11D48, // rose
  0xFF2563EB, // blue
  0xFF16A34A, // green
  0xFFCA8A04, // amber
  0xFF000000, // black
  0xFFDC2626, // red
];

/// Discrete pen widths (fraction of page width) — keep 3 steps for compact UI.
const List<double> penWidthSteps = <double>[0.002, 0.004, 0.008];

/// Discrete marker widths.
const List<double> markerWidthSteps = <double>[0.016, 0.028, 0.040];

/// Collapse a freehand path to a straight segment when [straightLine] is on.
List<Offset> pointsForStroke({
  required List<Offset> raw,
  required bool straightLine,
}) {
  if (raw.length < 2) return raw;
  if (!straightLine) return raw;
  return <Offset>[raw.first, raw.last];
}
