import 'package:flutter/material.dart';
import 'package:stagescore/metronome/metronome_engine.dart';
import 'package:stagescore/theme/app_tokens.dart';
import 'package:stagescore/ui/beat_dots.dart';

/// The metronome's beat, kept on the Score after the chrome has hidden
/// (Spec 0030, reopened after G4).
///
/// PerformanceMode (0034) takes the chrome away five seconds into a piece,
/// which took the metronome's only picture with it — and for a musician who
/// turned on "Mute (visual only)" that left the metronome with no output at
/// all. This gives the beat back without giving the chrome back.
///
/// Modelled on `PagePositionPill` (0036), and deliberately the same three
/// things it is not: not chrome (no reveal, no tap target, and its own
/// preference rather than a chrome one), wrapped in [IgnorePointer] so PageTurn
/// taps pass straight through, and never touching the chrome's countdown.
///
/// Top centre, against the page's own top margin: on a stand that is the part
/// of the screen nearest eye level, and it is the one band of a Score that
/// carries no notes. It hides while the chrome is up, because the AppBar
/// occupies exactly that band and the quick-bar's metronome glyph is already
/// tinted down there.
class BeatStrip extends StatelessWidget {
  const BeatStrip({super.key, required this.engine, required this.chromeShown});

  /// Listened to directly. The beat changes several times a second and this is
  /// the only subtree that has to follow it — not the screen holding the PDF
  /// viewer (Spec 0030 reopen, decision 4). Whether to show at all is read from
  /// the engine here too, so toggling the preference in the sheet takes effect
  /// without the screen rebuilding.
  final MetronomeEngine engine;

  /// The one thing the engine cannot know.
  final bool chromeShown;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: ListenableBuilder(
              listenable: engine,
              builder: (context, _) {
                final prefs = engine.prefs;
                final visible =
                    !chromeShown && engine.isRunning && prefs.showBeatsOnScore;
                return AnimatedOpacity(
                  opacity: visible ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      // The Score underneath is paper: the dots need a ground
                      // of their own or one lands on a note head and reads as
                      // part of the music.
                      color: scheme.inverseSurface.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: BeatDots(
                        beatsPerBar: prefs.beatsPerBar,
                        activeBeat: engine.isRunning ? engine.beatInBar : null,
                        accent: engine.isRunning && engine.isAccent,
                        equalBeats: !prefs.accentEnabled,
                        // Read at arm's length on a stand, not in the hand.
                        scale: 1.6,
                        // Named against the inverse surface this sits on, so
                        // the dots hold their contrast in both themes.
                        accentColor: scheme.inversePrimary,
                        activeColor: scheme.onInverseSurface,
                        inactiveColor: scheme.onInverseSurface.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
