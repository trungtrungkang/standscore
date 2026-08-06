import 'package:stagescore/measure_map/measure_map_store.dart';
import 'package:stagescore/sync_map/sync_map_playback.dart';

/// Bundle passed into page slots for the SyncMap playhead (Spec 0059).
class PlayheadOverlayConfig {
  const PlayheadOverlayConfig({
    required this.playback,
    required this.store,
    this.suppressed = false,
  });

  final SyncMapPlayback playback;
  final MeasureMapStore store;

  /// True while MeasureMap editing — hide playhead (G3 2f).
  final bool suppressed;
}
