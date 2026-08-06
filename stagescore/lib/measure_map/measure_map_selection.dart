import 'dart:ui' show Offset;

/// Mutually exclusive MeasureMap edit selection (Spec 0058 rev. 1).
sealed class MeasureMapSelection {
  const MeasureMapSelection();

  static const none = MeasureMapSelectionNone();

  bool get isNone => this is MeasureMapSelectionNone;
  bool get isMeasure => this is MeasureMapSelectionMeasure;
  bool get isSystem => this is MeasureMapSelectionSystem;

  String? get measureId => switch (this) {
    MeasureMapSelectionMeasure(:final id) => id,
    _ => null,
  };

  ({int pageNumber, int systemIndex})? get systemKey => switch (this) {
    MeasureMapSelectionSystem(:final pageNumber, :final systemIndex) => (
      pageNumber: pageNumber,
      systemIndex: systemIndex,
    ),
    _ => null,
  };
}

final class MeasureMapSelectionNone extends MeasureMapSelection {
  const MeasureMapSelectionNone();
}

final class MeasureMapSelectionMeasure extends MeasureMapSelection {
  const MeasureMapSelectionMeasure(this.id);
  final String id;
}

final class MeasureMapSelectionSystem extends MeasureMapSelection {
  const MeasureMapSelectionSystem({
    required this.pageNumber,
    required this.systemIndex,
  });

  final int pageNumber;
  final int systemIndex;

  bool matches({required int pageNumber, required int systemIndex}) =>
      this.pageNumber == pageNumber && this.systemIndex == systemIndex;
}

/// Which outer edge of a SystemBox was hit.
enum SystemEdge { left, right, top, bottom }

/// Hit-test helpers for SystemBox chrome (normalized page coords).
class SystemBoxHit {
  SystemBoxHit._();

  static const defaultSlopPx = 12.0;

  /// True when [pos] lies on the frame ring (near border, not deep inside).
  static bool hitFrameRing({
    required ({double x, double y, double width, double height}) rect,
    required Offset pos,
    required double pageWidthPx,
    required double pageHeightPx,
    double slopPx = defaultSlopPx,
  }) {
    if (pageWidthPx <= 0 || pageHeightPx <= 0) return false;
    final sx = slopPx / pageWidthPx;
    final sy = slopPx / pageHeightPx;
    final left = rect.x;
    final right = rect.x + rect.width;
    final top = rect.y;
    final bottom = rect.y + rect.height;
    final inExpanded =
        pos.dx >= left - sx &&
        pos.dx <= right + sx &&
        pos.dy >= top - sy &&
        pos.dy <= bottom + sy;
    if (!inExpanded) return false;
    final deepInside =
        pos.dx >= left + sx &&
        pos.dx <= right - sx &&
        pos.dy >= top + sy &&
        pos.dy <= bottom - sy;
    return !deepInside;
  }

  /// Nearest edge when [pos] is on the frame ring; null otherwise.
  static SystemEdge? hitEdge({
    required ({double x, double y, double width, double height}) rect,
    required Offset pos,
    required double pageWidthPx,
    required double pageHeightPx,
    double slopPx = defaultSlopPx,
  }) {
    if (!hitFrameRing(
      rect: rect,
      pos: pos,
      pageWidthPx: pageWidthPx,
      pageHeightPx: pageHeightPx,
      slopPx: slopPx,
    )) {
      return null;
    }
    final sx = slopPx / pageWidthPx;
    final sy = slopPx / pageHeightPx;
    final left = rect.x;
    final right = rect.x + rect.width;
    final top = rect.y;
    final bottom = rect.y + rect.height;
    final dLeft = (pos.dx - left).abs();
    final dRight = (pos.dx - right).abs();
    final dTop = (pos.dy - top).abs();
    final dBottom = (pos.dy - bottom).abs();
    SystemEdge? best;
    var bestD = double.infinity;
    void consider(SystemEdge e, double d, double slop) {
      if (d <= slop && d < bestD) {
        best = e;
        bestD = d;
      }
    }

    consider(SystemEdge.left, dLeft, sx);
    consider(SystemEdge.right, dRight, sx);
    consider(SystemEdge.top, dTop, sy);
    consider(SystemEdge.bottom, dBottom, sy);
    return best;
  }
}
