/// Which PageTurn inputs participate in the anti-double-turn lockout (Spec 0006).
enum PageTurnDelayScope {
  /// Tap, swipe, and pedal/keyboard share one lockout clock.
  all,

  /// Only pedal/keyboard is gated; tap/swipe always apply.
  pedalOnly,
}

/// Source of a PageTurn attempt (for delay scope).
enum PageTurnInputKind { tap, swipe, pedal }

/// Preset delays matching Spec 0006 UX.
enum PageTurnDelayPreset {
  off(Duration.zero),
  ms300(Duration(milliseconds: 300)),
  ms500(Duration(milliseconds: 500)),
  ms1000(Duration(milliseconds: 1000));

  const PageTurnDelayPreset(this.duration);
  final Duration duration;

  static PageTurnDelayPreset fromMilliseconds(int? ms) {
    if (ms == null || ms <= 0) return PageTurnDelayPreset.off;
    return PageTurnDelayPreset.values.firstWhere(
      (p) => p.duration.inMilliseconds == ms,
      orElse: () => PageTurnDelayPreset.off,
    );
  }
}

/// Shared lockout clock for PdfMode PageTurn (Spec 0006).
class PageTurnDelayGate {
  DateTime? _lockedUntil;

  /// Returns true if this input may turn the page now.
  bool allow({
    required DateTime now,
    required PageTurnInputKind kind,
    required Duration delay,
    required PageTurnDelayScope scope,
  }) {
    if (!_appliesTo(kind, scope) || delay <= Duration.zero) return true;
    final until = _lockedUntil;
    if (until != null && now.isBefore(until)) return false;
    return true;
  }

  /// Arm the lockout after a successful PageTurn.
  void lockAfterSuccess({
    required DateTime now,
    required PageTurnInputKind kind,
    required Duration delay,
    required PageTurnDelayScope scope,
  }) {
    if (!_appliesTo(kind, scope) || delay <= Duration.zero) return;
    _lockedUntil = now.add(delay);
  }

  void reset() => _lockedUntil = null;

  bool _appliesTo(PageTurnInputKind kind, PageTurnDelayScope scope) {
    return switch (scope) {
      PageTurnDelayScope.all => true,
      PageTurnDelayScope.pedalOnly => kind == PageTurnInputKind.pedal,
    };
  }
}
