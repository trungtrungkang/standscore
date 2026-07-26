import 'dart:ui';

/// Active draw tool in PdfMode Draw mode (Specs 0017 / 0018).
enum DrawTool { pen, marker, eraser, eyedropper }

/// Defaults and eraser geometry.
abstract final class DrawToolPresets {
  static const Color penColor = Color(0xFFE11D48);
  static const double penWidth = 0.004;

  static const Color markerColor = Color(0x99FACC15);
  static const double markerWidth = 0.028;

  /// Normalized hit radius for stroke-level erase.
  static const double eraserRadius = 0.028;

  static Color colorFor(DrawTool tool) => switch (tool) {
    DrawTool.pen || DrawTool.eyedropper => penColor,
    DrawTool.marker => markerColor,
    DrawTool.eraser => const Color(0x66FFFFFF),
  };

  static double widthFor(DrawTool tool) => switch (tool) {
    DrawTool.pen || DrawTool.eyedropper => penWidth,
    DrawTool.marker => markerWidth,
    DrawTool.eraser => eraserRadius * 2,
  };

  static bool isInkTool(DrawTool tool) =>
      tool == DrawTool.pen || tool == DrawTool.marker;
}
