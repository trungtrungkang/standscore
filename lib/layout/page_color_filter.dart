import 'package:flutter/material.dart';

/// PdfMode page color filter (Spec 0025 / P2.9).
enum PageColorFilterMode { off, sepia, green, invert }

extension PageColorFilterModeX on PageColorFilterMode {
  String get label => switch (this) {
    PageColorFilterMode.off => 'Off',
    PageColorFilterMode.sepia => 'Sepia',
    PageColorFilterMode.green => 'Green',
    PageColorFilterMode.invert => 'Invert',
  };

  /// Null means no [ColorFiltered] wrapper.
  ColorFilter? get colorFilter {
    final matrix = colorMatrix;
    if (matrix == null) return null;
    return ColorFilter.matrix(matrix);
  }

  /// 5×4 color matrix, or null for identity/off.
  List<double>? get colorMatrix => switch (this) {
    PageColorFilterMode.off => null,
    PageColorFilterMode.sepia => const [
      0.393,
      0.769,
      0.189,
      0,
      0,
      0.349,
      0.686,
      0.168,
      0,
      0,
      0.272,
      0.534,
      0.131,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ],
    PageColorFilterMode.green => const [
      0.70,
      0.15,
      0.05,
      0,
      0,
      0.10,
      0.85,
      0.10,
      0,
      8,
      0.05,
      0.20,
      0.55,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ],
    PageColorFilterMode.invert => const [
      -1,
      0,
      0,
      0,
      255,
      0,
      -1,
      0,
      0,
      255,
      0,
      0,
      -1,
      0,
      255,
      0,
      0,
      0,
      1,
      0,
    ],
  };
}

/// Applies the same matrix a [PageColorFiltered] would, to a single [color].
///
/// Painted surfaces around the page (gutter, safe-area bands) sit outside the
/// filtered subtree, so they need the filter applied by hand to stay in step
/// with the page (Spec 0025 / 0034).
Color applyPageColorFilter(Color color, PageColorFilterMode mode) {
  final matrix = mode.colorMatrix;
  if (matrix == null) return color;

  final r = color.r * 255.0;
  final g = color.g * 255.0;
  final b = color.b * 255.0;
  final a = color.a * 255.0;

  int channel(int row) {
    final i = row * 5;
    final value =
        matrix[i] * r +
        matrix[i + 1] * g +
        matrix[i + 2] * b +
        matrix[i + 3] * a +
        matrix[i + 4];
    return value.clamp(0.0, 255.0).round();
  }

  return Color.fromARGB(channel(3), channel(0), channel(1), channel(2));
}

/// Wraps [child] with the active page color filter when not [PageColorFilterMode.off].
class PageColorFiltered extends StatelessWidget {
  const PageColorFiltered({super.key, required this.mode, required this.child});

  final PageColorFilterMode mode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final filter = mode.colorFilter;
    if (filter == null) return child;
    return ColorFiltered(colorFilter: filter, child: child);
  }
}
