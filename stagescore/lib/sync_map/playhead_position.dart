import 'package:stagescore/measure_map/measure_box.dart';
import 'package:stagescore/measure_map/measure_map_store.dart';
import 'package:stagescore/sync_map/sync_map_entry.dart';

/// Playhead on the page — normalized 0–1 coords (Spec 0059).
class PlayheadPosition {
  const PlayheadPosition({
    required this.pageNumber,
    required this.x,
    required this.y,
    required this.top,
    required this.height,
    required this.measure,
    required this.beatIndex,
  });

  /// Absolute 1-based PdfDocument page.
  final int pageNumber;

  /// Normalized X within the page (vertical line).
  final double x;

  /// Normalized Y (vertical centre of the MeasureBox).
  final double y;

  /// Top of the MeasureBox (normalized) — playhead spans this box.
  final double top;

  /// Height of the MeasureBox (normalized).
  final double height;

  final int measure;

  /// 0-based index within the entry's audible [beatTimestamps].
  final int beatIndex;
}

/// Absolute page X of the first audible beat anchor for [entry]/[box].
double _firstAudibleX(SyncMapEntry entry, MeasureBox box, MeasureMapStore store) {
  final meta = store.resolveMeta(box);
  final beatsInBar = beatsFromTimeSignature(meta.timeSignature);
  final anchors = normalizeBeatSplits(box.beatSplits, beatsInBar);
  if (anchors.isEmpty) return box.x;
  final start = entry.startsAtBeat.clamp(0, anchors.length - 1);
  return box.x + box.width * anchors[start].clamp(0.0, 1.0);
}

/// Map timeline [timeMs] → page geometry via SyncMap × MeasureMap beatSplits.
///
/// Within a measure, interpolates between consecutive [beatSplits]. On the
/// **last beat**, if the next measure is on the same page, interpolates in
/// page space toward that measure's first audible anchor so the handoff is
/// continuous (no jump at the barline).
PlayheadPosition? playheadAtTime({
  required SyncMap syncMap,
  required MeasureMapStore store,
  required double timeMs,
}) {
  if (syncMap.isEmpty) return null;
  final clamped = timeMs.clamp(0.0, syncMap.totalDurationMs);

  var entryIndex = 0;
  for (var i = 0; i < syncMap.entries.length; i++) {
    if (clamped < syncMap.entries[i].endMs - 1e-9) {
      entryIndex = i;
      break;
    }
    entryIndex = i;
  }
  final entry = syncMap.entries[entryIndex];

  final box = store.byMeasureNumber(entry.physicalMeasure);
  if (box == null) return null;

  final meta = store.resolveMeta(box);
  final beatsInBar = beatsFromTimeSignature(meta.timeSignature);
  final anchors = normalizeBeatSplits(box.beatSplits, beatsInBar);
  final startBeat = entry.startsAtBeat.clamp(0, beatsInBar - 1);

  final timestamps = entry.beatTimestamps;
  if (timestamps.isEmpty || anchors.isEmpty) {
    return PlayheadPosition(
      pageNumber: box.pageNumber,
      x: box.x,
      y: box.y + box.height / 2,
      top: box.y,
      height: box.height,
      measure: entry.physicalMeasure,
      beatIndex: 0,
    );
  }

  var beatIndex = 0;
  for (var i = 0; i < timestamps.length; i++) {
    if (clamped + 1e-9 >= timestamps[i]) beatIndex = i;
  }

  final beatStartMs = timestamps[beatIndex];
  final beatEndMs = beatIndex + 1 < timestamps.length
      ? timestamps[beatIndex + 1]
      : entry.endMs;
  final span = (beatEndMs - beatStartMs).clamp(1e-9, double.infinity);
  final t = ((clamped - beatStartMs) / span).clamp(0.0, 1.0);

  final anchorIndex = (startBeat + beatIndex).clamp(0, anchors.length - 1);
  final leftX = box.x + box.width * anchors[anchorIndex].clamp(0.0, 1.0);

  late final double rightX;
  late final double rightTop;
  late final double rightHeight;
  late final int pageNumber;

  final isLastBeat = beatIndex == timestamps.length - 1;
  final next = entryIndex + 1 < syncMap.entries.length
      ? syncMap.entries[entryIndex + 1]
      : null;
  final nextBox =
      next == null ? null : store.byMeasureNumber(next.physicalMeasure);

  if (isLastBeat &&
      next != null &&
      nextBox != null &&
      nextBox.pageNumber == box.pageNumber) {
    // Smooth handoff into the next measure's first audible beat (same page).
    rightX = _firstAudibleX(next, nextBox, store);
    rightTop = nextBox.y;
    rightHeight = nextBox.height;
    pageNumber = box.pageNumber;
  } else if (anchorIndex + 1 < anchors.length) {
    rightX = box.x + box.width * anchors[anchorIndex + 1].clamp(0.0, 1.0);
    rightTop = box.y;
    rightHeight = box.height;
    pageNumber = box.pageNumber;
  } else {
    // Last measure on this timeline, or next is on another page — ease to
    // the right edge of the current box.
    rightX = box.right;
    rightTop = box.y;
    rightHeight = box.height;
    pageNumber = box.pageNumber;
  }

  final x = leftX + (rightX - leftX) * t;
  final top = box.y + (rightTop - box.y) * t;
  final height = box.height + (rightHeight - box.height) * t;

  return PlayheadPosition(
    pageNumber: pageNumber,
    x: x,
    y: top + height / 2,
    top: top,
    height: height,
    measure: entry.physicalMeasure,
    beatIndex: beatIndex,
  );
}
