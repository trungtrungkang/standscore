import 'package:flutter/material.dart';

/// PdfMode page color filter (Spec 0025 / P2.9).
enum PageColorFilterMode {
  off,
  sepia,
  green,
  invert,
}

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
            0.393, 0.769, 0.189, 0, 0,
            0.349, 0.686, 0.168, 0, 0,
            0.272, 0.534, 0.131, 0, 0,
            0, 0, 0, 1, 0,
          ],
        PageColorFilterMode.green => const [
            0.70, 0.15, 0.05, 0, 0,
            0.10, 0.85, 0.10, 0, 8,
            0.05, 0.20, 0.55, 0, 0,
            0, 0, 0, 1, 0,
          ],
        PageColorFilterMode.invert => const [
            -1, 0, 0, 0, 255,
            0, -1, 0, 0, 255,
            0, 0, -1, 0, 255,
            0, 0, 0, 1, 0,
          ],
      };
}

/// Wraps [child] with the active page color filter when not [PageColorFilterMode.off].
class PageColorFiltered extends StatelessWidget {
  const PageColorFiltered({
    super.key,
    required this.mode,
    required this.child,
  });

  final PageColorFilterMode mode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final filter = mode.colorFilter;
    if (filter == null) return child;
    return ColorFiltered(colorFilter: filter, child: child);
  }
}
