import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

/// How long the position stays up after a turn (Spec 0036).
const kPagePillDuration = Duration(milliseconds: 1500);
const kPagePillFade = Duration(milliseconds: 200);

/// "12 / 56", shown for a moment after a page turn while the chrome is hidden
/// (Spec 0036).
///
/// PerformanceMode (0034) takes the PageNavBar away, which also takes away the
/// answer to "did that pedal press land?". This gives the answer back without
/// giving the chrome back: it appears only on a page *change*, only while the
/// chrome is down, and fades on its own.
///
/// Two things it deliberately is not:
///
/// - **Not chrome.** No reveal, no tap target, no setting. It is wrapped in
///   [IgnorePointer] because it floats over the bottom-right corner, which is
///   prime PageTurn tap area once the PageNavBar is gone (0034).
/// - **Not tied to the chrome countdown.** Its timer is its own; showing the
///   page number is not interaction and must not restart the auto-hide.
class PagePositionPill extends StatelessWidget {
  const PagePositionPill({
    super.key,
    required this.pageNumber,
    required this.pageCount,
    required this.enabled,
    this.duration = kPagePillDuration,
  });

  final int pageNumber;
  final int pageCount;

  /// True while the chrome is hidden; when the chrome is up the PageNavBar
  /// already says where we are.
  final bool enabled;

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TransientPill(
      text: '$pageNumber / $pageCount',
      // Only a turn brings it up — not a reveal, not a rebuild.
      trigger: pageNumber,
      enabled: enabled,
      duration: duration,
    );
  }
}

/// A pill that appears when [trigger] changes and fades on its own.
///
/// Extracted from [PagePositionPill] so a layout that re-resolved under the
/// musician's hands can say so in the same voice (Spec 0041), without either
/// message touching the chrome countdown or taking a tap.
class TransientPill extends StatefulWidget {
  const TransientPill({
    super.key,
    required this.text,
    required this.trigger,
    required this.enabled,
    this.duration = kPagePillDuration,
  });

  final String text;

  /// Changing this — and only this — brings the pill up.
  final Object? trigger;
  final bool enabled;
  final Duration duration;

  @override
  State<TransientPill> createState() => _TransientPillState();
}

class _TransientPillState extends State<TransientPill> {
  bool _visible = false;
  Timer? _timer;

  @override
  void didUpdateWidget(TransientPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) {
      if (_visible || _timer != null) _hide();
      return;
    }
    if (widget.trigger != oldWidget.trigger) _show();
  }

  void _show() {
    _timer?.cancel();
    _timer = Timer(widget.duration, () {
      if (mounted) setState(() => _visible = false);
      _timer = null;
    });
    if (!_visible) setState(() => _visible = true);
  }

  void _hide() {
    _timer?.cancel();
    _timer = null;
    if (_visible) setState(() => _visible = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: kPagePillFade,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.inverseSurface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: scheme.onInverseSurface.withValues(alpha: 0.2),
                      width: 0.8,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    child: Text(
                      widget.text,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: scheme.onInverseSurface,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
