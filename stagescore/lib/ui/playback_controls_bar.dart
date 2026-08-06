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

/// Compact Play / Pause / Stop + seek bar for PdfMode (Spec 0059).
class PlaybackControlsBar extends StatefulWidget {
  const PlaybackControlsBar({
    super.key,
    required this.playback,
    required this.enabled,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
  });

  final SyncMapPlayback playback;
  final bool enabled;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStop;

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
        // Live badge only while counting; hide after count-in ends.
        final countInText = countingIn
            ? '${l10n.playbackControlsCountInLabel} '
                '${formatCountInRemaining(
                  playback.countInRemaining ??
                      (measures: 0, beats: 0, beatsPerBar: 4),
                )}'
            : '';

        return Material(
          color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.92),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 40,
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
                        width: 40,
                        child: Text(
                          formatPlaybackTime(totalMs),
                          style: theme.textTheme.labelSmall,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            tooltip: playing
                                ? l10n.playbackControlsPause
                                : l10n.playbackControlsPlay,
                            onPressed: !widget.enabled
                                ? null
                                : () {
                                    if (playing) {
                                      widget.onPause();
                                    } else {
                                      widget.onPlay();
                                    }
                                  },
                            icon:
                                Icon(playing ? Icons.pause : Icons.play_arrow),
                          ),
                          IconButton(
                            tooltip: l10n.playbackControlsStop,
                            onPressed: !widget.enabled ||
                                    phase == SyncMapPlaybackPhase.stopped
                                ? null
                                : widget.onStop,
                            icon: const Icon(Icons.stop),
                          ),
                        ],
                      ),
                      if (countingIn)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            countInText,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
