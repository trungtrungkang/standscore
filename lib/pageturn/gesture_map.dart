/// Non–PageTurn gesture assignments (Spec 0015 / P1.2).
enum GestureMapAction {
  showChrome,
  enterDraw,
  disabled,
}

enum GestureMapInput {
  longPress,
  topEdge,
  bottomEdge,
}

/// Which vertical edge band a Y coordinate falls in, if any.
enum VerticalEdgeBand { top, bottom }

/// Fraction of viewer height used for top/bottom edge bands.
const double gestureMapEdgeFraction = 0.06;

/// Minimum edge band thickness in logical pixels.
const double gestureMapEdgeMinPx = 24;

class GestureMap {
  const GestureMap({
    this.longPress = GestureMapAction.showChrome,
    this.topEdge = GestureMapAction.showChrome,
    this.bottomEdge = GestureMapAction.enterDraw,
  });

  final GestureMapAction longPress;
  final GestureMapAction topEdge;
  final GestureMapAction bottomEdge;

  GestureMapAction actionFor(GestureMapInput input) => switch (input) {
        GestureMapInput.longPress => longPress,
        GestureMapInput.topEdge => topEdge,
        GestureMapInput.bottomEdge => bottomEdge,
      };

  bool get hasShowChrome =>
      longPress == GestureMapAction.showChrome ||
      topEdge == GestureMapAction.showChrome ||
      bottomEdge == GestureMapAction.showChrome;

  GestureMap copyWith({
    GestureMapAction? longPress,
    GestureMapAction? topEdge,
    GestureMapAction? bottomEdge,
  }) =>
      GestureMap(
        longPress: longPress ?? this.longPress,
        topEdge: topEdge ?? this.topEdge,
        bottomEdge: bottomEdge ?? this.bottomEdge,
      );

  Map<String, dynamic> toJson() => {
        'longPress': longPress.name,
        'topEdge': topEdge.name,
        'bottomEdge': bottomEdge.name,
      };

  factory GestureMap.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const GestureMap();
    final map = GestureMap(
      longPress: _actionFromName(json['longPress'] as String?),
      topEdge: _actionFromName(json['topEdge'] as String?),
      bottomEdge: _actionFromName(json['bottomEdge'] as String?),
    );
    return validateGestureMap(map) ? map : const GestureMap();
  }
}

GestureMapAction _actionFromName(String? name) {
  return GestureMapAction.values.firstWhere(
    (a) => a.name == name,
    orElse: () => GestureMapAction.disabled,
  );
}

/// True when at least one input is Show menu.
bool validateGestureMap(GestureMap map) => map.hasShowChrome;

/// Thickness of each vertical edge band for [viewerHeight].
double gestureMapEdgeBandHeight(double viewerHeight) {
  if (viewerHeight <= 0) return gestureMapEdgeMinPx;
  return (viewerHeight * gestureMapEdgeFraction)
      .clamp(gestureMapEdgeMinPx, viewerHeight / 2)
      .toDouble();
}

/// Which edge band contains [localY], or null if in the middle.
VerticalEdgeBand? resolveVerticalEdgeBand({
  required double localY,
  required double viewerHeight,
}) {
  if (viewerHeight <= 0) return null;
  final band = gestureMapEdgeBandHeight(viewerHeight);
  if (localY < band) return VerticalEdgeBand.top;
  if (localY > viewerHeight - band) return VerticalEdgeBand.bottom;
  return null;
}

GestureMapInput? gestureInputForEdge(VerticalEdgeBand band) => switch (band) {
      VerticalEdgeBand.top => GestureMapInput.topEdge,
      VerticalEdgeBand.bottom => GestureMapInput.bottomEdge,
    };
