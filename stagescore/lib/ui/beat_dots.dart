import 'package:flutter/material.dart';

/// Where the metronome is in the bar, as one dot per beat (Spec 0030).
///
/// Lived inside the metronome sheet until the beat strip on the Score needed
/// the same picture: one drawing of "which beat is this", so the sheet and the
/// Score can never disagree about the count or which dot is the accent.
class BeatDots extends StatelessWidget {
  const BeatDots({
    super.key,
    required this.beatsPerBar,
    required this.activeBeat,
    required this.accent,
    this.equalBeats = false,
    this.scale = 1,
    this.accentColor,
    this.activeColor,
    this.inactiveColor,
  });

  final int beatsPerBar;

  /// 0-based beat, or null when the metronome is not running.
  final int? activeBeat;
  final bool accent;

  /// When true no dot is drawn larger: an equal click has no strong beat.
  final bool equalBeats;

  /// Multiplier on the dot sizes. The strip on the Score is read at arm's
  /// length on a stand, the sheet's copy from a phone in the hand.
  final double scale;

  /// Overrides for the three states, so the same dots can be drawn on a sheet's
  /// own surface or on the dark ground of the strip over the Score. Null keeps
  /// the sheet's colours.
  final Color? accentColor;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final strong = accentColor ?? scheme.primary;
    final beat = activeColor ?? scheme.secondary;
    final idle = inactiveColor ?? scheme.outlineVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < beatsPerBar; i++)
          Container(
            width: (equalBeats || i != 0 ? 10 : 12) * scale,
            height: (equalBeats || i != 0 ? 10 : 12) * scale,
            margin: EdgeInsets.only(left: 4 * scale),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activeBeat == i
                  ? (equalBeats ? beat : (accent || i == 0 ? strong : beat))
                  : idle,
            ),
          ),
      ],
    );
  }
}
