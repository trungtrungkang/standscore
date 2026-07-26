/// Page-turn slide animation presets for Single page (Spec 0007).
enum PageTurnAnimationPreset {
  off(Duration.zero),
  fast(Duration(milliseconds: 180)),
  normal(Duration(milliseconds: 320)),
  slow(Duration(milliseconds: 520));

  const PageTurnAnimationPreset(this.duration);
  final Duration duration;

  static PageTurnAnimationPreset fromName(String? name) {
    return PageTurnAnimationPreset.values.firstWhere(
      (p) => p.name == name,
      orElse: () => PageTurnAnimationPreset.normal,
    );
  }
}
