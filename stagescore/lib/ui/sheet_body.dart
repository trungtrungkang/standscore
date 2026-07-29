import 'package:flutter/material.dart';

/// Share of the screen a settings sheet may take at most (Spec 0035).
const double kSheetMaxHeightFraction = 0.9;

/// The body of a settings sheet: sized by its content, scrolled when the screen
/// is shorter than the content.
///
/// Spec 0035 fixed the first half of this — sheets pinned to a fraction of the
/// screen read as a pushed route — and the sheets rewritten then also carry a
/// title row with **Done** and a `Flexible` list, so they already scroll. The
/// plainer ones (Metronome, Display, Page scale) were a `Column` under a
/// `Padding` with nothing scrollable in them, which is fine right up to the
/// point where the screen is shorter than the content: a phone in landscape
/// gives a bottom sheet barely 336 pt, and the Metronome's own content wants
/// 480, so it overflowed and its Start button could not be reached at all.
///
/// Both properties belong together, which is why they live in one widget:
/// capping without scrolling hides content, and scrolling without capping lets
/// a sheet cover the Score.
class SheetBody extends StatelessWidget {
  const SheetBody({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 24),
  });

  final List<Widget> children;

  /// Around the content, before the keyboard inset is added to the bottom.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.sizeOf(context).height * kSheetMaxHeightFraction,
        ),
        child: SingleChildScrollView(
          padding: padding.add(
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}
