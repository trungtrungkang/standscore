import 'package:flutter/material.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/sync_map/sync_map_playback.dart';
import 'package:stagescore/theme/app_tokens.dart';
import 'package:stagescore/ui/playback_controls_bar.dart';

/// Compact draggable Play/Pause + Stop pill (Spec 0059 G4 float style).
class PlaybackFloatControls extends StatefulWidget {
  const PlaybackFloatControls({
    super.key,
    required this.playback,
    required this.enabled,
    required this.normX,
    required this.normY,
    required this.onNormChanged,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
  });

  final SyncMapPlayback playback;
  final bool enabled;

  /// Top-left of the pill as a fraction of free space (0–1).
  final double normX;
  final double normY;

  /// Called once when a drag ends (persist).
  final void Function(double normX, double normY) onNormChanged;

  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStop;

  @override
  State<PlaybackFloatControls> createState() => _PlaybackFloatControlsState();
}

class _PlaybackFloatControlsState extends State<PlaybackFloatControls> {
  static const _margin = 16.0;

  final GlobalKey _pillKey = GlobalKey();
  Size _pillSize = const Size(120, 48);

  /// Live position while dragging; null means use [widget.normX/Y].
  double? _dragNormX;
  double? _dragNormY;
  Offset? _dragStartGlobal;
  Offset? _pillOriginAtDrag;

  @override
  void didUpdateWidget(covariant PlaybackFloatControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_dragNormX == null &&
        (oldWidget.normX != widget.normX || oldWidget.normY != widget.normY)) {
      // Parent prefs caught up after save — nothing to do.
    }
  }

  void _measurePill() {
    final box = _pillKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final next = box.size;
    if (next != _pillSize) {
      setState(() => _pillSize = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final padding = MediaQuery.paddingOf(context);

    WidgetsBinding.instance.addPostFrameCallback((_) => _measurePill());

    return LayoutBuilder(
      builder: (context, constraints) {
        final freeW =
            (constraints.maxWidth - padding.left - padding.right - _margin * 2)
                .clamp(0.0, double.infinity);
        final freeH =
            (constraints.maxHeight - padding.top - padding.bottom - _margin * 2)
                .clamp(0.0, double.infinity);
        final maxX = (freeW - _pillSize.width).clamp(0.0, double.infinity);
        final maxY = (freeH - _pillSize.height).clamp(0.0, double.infinity);
        final nx = _dragNormX ?? widget.normX;
        final ny = _dragNormY ?? widget.normY;
        final left = padding.left + _margin + nx * maxX;
        final top = padding.top + _margin + ny * maxY;

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: left,
              top: top,
              child: ListenableBuilder(
                listenable: widget.playback,
                builder: (context, _) {
                  final phase = widget.playback.phase;
                  final countingIn = phase == SyncMapPlaybackPhase.countIn;
                  final playing =
                      phase == SyncMapPlaybackPhase.playing || countingIn;
                  final positionBeat = widget.playback.positionMeasureBeat;
                  final String? beatBadgeText;
                  final Color? beatBadgeColor;
                  if (countingIn) {
                    beatBadgeText = formatCountInRemaining(
                      widget.playback.countInRemaining ??
                          (measures: 0, beats: 0, beatsPerBar: 4),
                    );
                    beatBadgeColor = kCountInCountdownColor;
                  } else if (positionBeat != null) {
                    beatBadgeText = formatMeasureBeat(
                      positionBeat.measure,
                      positionBeat.beat,
                    );
                    beatBadgeColor = theme.colorScheme.primary;
                  } else {
                    beatBadgeText = null;
                    beatBadgeColor = null;
                  }

                  return GestureDetector(
                    onPanStart: (details) {
                      _dragStartGlobal = details.globalPosition;
                      _pillOriginAtDrag = Offset(left, top);
                      _dragNormX = nx;
                      _dragNormY = ny;
                    },
                    onPanUpdate: (details) {
                      final origin = _pillOriginAtDrag;
                      final start = _dragStartGlobal;
                      if (origin == null || start == null) return;
                      final delta = details.globalPosition - start;
                      final nextLeft = (origin.dx + delta.dx).clamp(
                        padding.left + _margin,
                        padding.left + _margin + maxX,
                      );
                      final nextTop = (origin.dy + delta.dy).clamp(
                        padding.top + _margin,
                        padding.top + _margin + maxY,
                      );
                      setState(() {
                        _dragNormX = maxX <= 0
                            ? 0.0
                            : (nextLeft - padding.left - _margin) / maxX;
                        _dragNormY = maxY <= 0
                            ? 0.0
                            : (nextTop - padding.top - _margin) / maxY;
                      });
                    },
                    onPanEnd: (_) {
                      final x = _dragNormX ?? widget.normX;
                      final y = _dragNormY ?? widget.normY;
                      setState(() {
                        _dragNormX = null;
                        _dragNormY = null;
                        _dragStartGlobal = null;
                        _pillOriginAtDrag = null;
                      });
                      widget.onNormChanged(x, y);
                    },
                    onPanCancel: () {
                      setState(() {
                        _dragNormX = null;
                        _dragNormY = null;
                        _dragStartGlobal = null;
                        _pillOriginAtDrag = null;
                      });
                    },
                    child: Material(
                      key: _pillKey,
                      elevation: 4,
                      color: theme.colorScheme.surfaceContainerHigh
                          .withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                              icon: Icon(
                                playing ? Icons.pause : Icons.play_arrow,
                              ),
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
                                padding: const EdgeInsets.only(
                                  right: AppSpacing.sm,
                                ),
                                child: PlaybackBeatBadge(
                                  text: beatBadgeText,
                                  color: beatBadgeColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
