import 'package:flutter/material.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/sync_map/sync_map_playback.dart';
import 'package:stagescore/theme/app_tokens.dart';

/// Format timeline milliseconds as `m:ss` (seconds unit on the bar).
String formatPlaybackTime(double ms) {
  final totalSec = (ms / 1000).floor().clamp(0, 99 * 60 + 59);
  final m = totalSec ~/ 60;
  final s = totalSec % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

/// Count-in remaining as `measures.beat` (e.g. `2.4`, `1.1`).
String formatCountInRemaining(({int measures, int beats, int beatsPerBar}) r) {
  return '${r.measures}.${r.beats}';
}

/// Score position as `measure.beat` (1-based beat).
String formatMeasureBeat(int measure, int beat) => '$measure.$beat';

/// Amber-orange for the live count-in countdown (Playback controls badge).
const Color kCountInCountdownColor = Color(0xFFFF8F00);

/// Fixed width for `m:ss` labels flanking the seek slider (compact density).
const double kPlaybackTimeLabelWidth = 36;

/// Widest sample for the beat badge slot — 3-digit measure + 2-digit beat.
///
/// Keeps Play/Stop (and the floating pill) from shifting when `9.4` → `10.1`.
/// Tabular figures alone only equalize digit advance, not digit *count*.
const String kPlaybackBeatBadgeWidthSample = '888.88';

/// Fixed-width `measure.beat` / count-in label so sibling chrome does not jump.
class PlaybackBeatBadge extends StatelessWidget {
  const PlaybackBeatBadge({
    super.key,
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
      fontWeight: FontWeight.w600,
    );
    final painter = TextPainter(
      text: TextSpan(text: kPlaybackBeatBadgeWidthSample, style: style),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    return SizedBox(
      width: painter.width,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.right,
        maxLines: 1,
        overflow: TextOverflow.clip,
      ),
    );
  }
}

/// Docked Play / Pause / Stop + seek bar for PdfMode (Spec 0059).
class PlaybackControlsBar extends StatefulWidget {
  const PlaybackControlsBar({
    super.key,
    required this.playback,
    required this.enabled,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
    this.includeBottomSafeArea = true,
  });

  final SyncMapPlayback playback;
  final bool enabled;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStop;

  /// When false, the bar sits above PageNav which already owns the home
  /// indicator inset — avoid double padding.
  final bool includeBottomSafeArea;

  @override
  State<PlaybackControlsBar> createState() => _PlaybackControlsBarState();
}

class _PlaybackControlsBarState extends State<PlaybackControlsBar> {
  /// Local value while the thumb is dragged — avoids fighting the clock.
  double? _dragMs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: widget.playback,
      builder: (context, _) {
        final playback = widget.playback;
        final phase = playback.phase;
        final countingIn = phase == SyncMapPlaybackPhase.countIn;
        final playing = phase == SyncMapPlaybackPhase.playing || countingIn;
        final totalMs = playback.totalDurationMs;
        final positionMs = _dragMs ?? playback.positionMs;
        final maxMs = totalMs <= 0 ? 1.0 : totalMs;
        final canSeek = widget.enabled && totalMs > 0 && !countingIn;
        final positionBeat = playback.positionMeasureBeat;
        final String? beatBadgeText;
        final Color? beatBadgeColor;
        if (countingIn) {
          beatBadgeText = formatCountInRemaining(
            playback.countInRemaining ??
                (measures: 0, beats: 0, beatsPerBar: 4),
          );
          beatBadgeColor = kCountInCountdownColor;
        } else if (positionBeat != null) {
          beatBadgeText =
              formatMeasureBeat(positionBeat.measure, positionBeat.beat);
          beatBadgeColor = theme.colorScheme.primary;
        } else {
          beatBadgeText = null;
          beatBadgeColor = null;
        }

        final row = Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              SizedBox(
                width: kPlaybackTimeLabelWidth,
                child: Text(
                  formatPlaybackTime(positionMs),
                  style: theme.textTheme.labelSmall,
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                  ),
                  child: Slider(
                    value: positionMs.clamp(0.0, maxMs),
                    min: 0,
                    max: maxMs,
                    onChanged: !canSeek
                        ? null
                        : (v) {
                            setState(() => _dragMs = v);
                            playback.seekTo(v);
                          },
                    onChangeEnd: !canSeek
                        ? null
                        : (v) {
                            playback.seekTo(v);
                            setState(() => _dragMs = null);
                          },
                  ),
                ),
              ),
              SizedBox(
                width: kPlaybackTimeLabelWidth,
                child: Text(
                  formatPlaybackTime(totalMs),
                  style: theme.textTheme.labelSmall,
                  textAlign: TextAlign.left,
                ),
              ),
              IconButton(
                tooltip: playing
                    ? l10n.playbackControlsPause
                    : l10n.playbackControlsPlay,
                visualDensity: VisualDensity.compact,
                onPressed: !widget.enabled
                    ? null
                    : () {
                        if (playing) {
                          widget.onPause();
                        } else {
                          widget.onPlay();
                        }
                      },
                icon: Icon(playing ? Icons.pause : Icons.play_arrow),
              ),
              IconButton(
                tooltip: l10n.playbackControlsStop,
                visualDensity: VisualDensity.compact,
                onPressed: !widget.enabled ||
                        phase == SyncMapPlaybackPhase.stopped
                    ? null
                    : widget.onStop,
                icon: const Icon(Icons.stop),
              ),
              if (beatBadgeText != null && beatBadgeColor != null)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: PlaybackBeatBadge(
                    text: beatBadgeText,
                    color: beatBadgeColor,
                  ),
                ),
            ],
          ),
        );

        return Material(
          color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.92),
          child: widget.includeBottomSafeArea
              ? SafeArea(top: false, child: row)
              : row,
        );
      },
    );
  }
}
