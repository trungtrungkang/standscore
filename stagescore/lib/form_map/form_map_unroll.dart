import 'package:stagescore/form_map/form_map.dart';
import 'package:stagescore/measure_map/measure_box.dart';
import 'package:stagescore/measure_map/measure_map_store.dart';
import 'package:stagescore/sync_map/sync_map_entry.dart';
import 'package:stagescore/sync_map/sync_map_from_measure_map.dart';

/// Result of MeasureMap × FormMap → SyncMap (Spec 0061).
sealed class SyncMapBuildResult {
  const SyncMapBuildResult();
}

class SyncMapBuildSuccess extends SyncMapBuildResult {
  const SyncMapBuildSuccess(this.map);
  final SyncMap map;
}

class SyncMapBuildFailure extends SyncMapBuildResult {
  const SyncMapBuildFailure(this.reason);
  final String reason;
}

/// Build SyncMap from MeasureMap + FormMap.
///
/// Empty [form] → identical to [syncMapFromMeasureMap] (0059), with
/// [SyncMapEntry.physicalMeasure] == [SyncMapEntry.measure].
///
/// Non-empty form → web-spirit unroll (`unrollMeasures`): latent `measure`,
/// runtime [SyncMapEntry.physicalMeasure] for playhead / badge.
SyncMapBuildResult syncMapFromMeasureMapAndForm(
  MeasureMapStore store,
  FormMap form,
) {
  if (store.isEmpty) return const SyncMapBuildSuccess(SyncMap([]));
  if (form.isEmpty) {
    final linear = syncMapFromMeasureMap(store);
    return SyncMapBuildSuccess(linear);
  }

  final ordered = List<MeasureBox>.from(store.boxes)
    ..sort((a, b) => a.measureNumber.compareTo(b.measureNumber));
  final n = ordered.length;
  final indexByPhysical = <int, int>{
    for (var i = 0; i < n; i++) ordered[i].measureNumber: i,
  };

  // Validate form references exist on the MeasureMap.
  for (final r in form.repeats) {
    if (!indexByPhysical.containsKey(r.startMeasure) ||
        !indexByPhysical.containsKey(r.endMeasure)) {
      return const SyncMapBuildFailure('formInvalidMissingMeasure');
    }
    if (r.startMeasure > r.endMeasure || r.times < 1) {
      return const SyncMapBuildFailure('formInvalidRepeat');
    }
  }
  for (final e in form.endings) {
    if (!indexByPhysical.containsKey(e.startMeasure) ||
        !indexByPhysical.containsKey(e.endMeasure)) {
      return const SyncMapBuildFailure('formInvalidMissingMeasure');
    }
    if (e.startMeasure > e.endMeasure || e.endingNumber < 1) {
      return const SyncMapBuildFailure('formInvalidEnding');
    }
  }
  for (final m in form.markers) {
    if (!indexByPhysical.containsKey(m.measure)) {
      return const SyncMapBuildFailure('formInvalidMissingMeasure');
    }
  }
  for (final j in form.jumps) {
    if (!indexByPhysical.containsKey(j.measure)) {
      return const SyncMapBuildFailure('formInvalidMissingMeasure');
    }
  }

  final repeatStartAt = <int, int>{}; // physical → physical start
  final repeatEndAt = <int, FormRepeatRegion>{}; // physical end → region
  for (final r in form.repeats) {
    repeatStartAt[r.startMeasure] = r.startMeasure;
    repeatEndAt[r.endMeasure] = r;
  }

  final endingsCovering = <_EndingSpan>[
    for (final e in form.endings)
      _EndingSpan(
        startIdx: indexByPhysical[e.startMeasure]!,
        endIdx: indexByPhysical[e.endMeasure]!,
        endingNumber: e.endingNumber,
      ),
  ];

  final segnoIdx = <String, int>{};
  final codaIdx = <String, int>{};
  final fineAt = <int>{}; // physical measures with Fine
  final toCodaAt = <int, String>{}; // physical → targetId (jump or marker)
  final daCapoAt = <int>{};
  final dalSegnoAt = <int, String>{};

  for (final m in form.markers) {
    final idx = indexByPhysical[m.measure]!;
    switch (m.kind) {
      case FormMarkerKind.segno:
        segnoIdx[m.targetId] = idx;
      case FormMarkerKind.coda:
        codaIdx[m.targetId] = idx;
      case FormMarkerKind.fine:
        fineAt.add(m.measure);
      case FormMarkerKind.toCoda:
        toCodaAt[m.measure] = m.targetId;
    }
  }
  for (final j in form.jumps) {
    switch (j.kind) {
      case FormJumpKind.daCapo:
        daCapoAt.add(j.measure);
      case FormJumpKind.dalSegno:
        dalSegnoAt[j.measure] = j.targetId;
      case FormJumpKind.toCoda:
        toCodaAt[j.measure] = j.targetId;
    }
  }

  final firstBox = ordered.first;
  final firstMeta = store.resolveMeta(firstBox);
  final firstParts = parseTimeSignatureParts(firstMeta.timeSignature);
  final firstStartsAt = firstBox.startsAtBeat.clamp(0, firstParts.numerator - 1);
  var latentMeasure = firstStartsAt > 0 ? 0 : 1;

  final entries = <SyncMapEntry>[];
  var cursorMs = 0.0;
  var i = 0;
  var repeatStartIdx = 0;
  final repeatCounts = <int, int>{}; // endIdx → playCount so far
  var currentPass = 1;
  var jumped = false;
  var iterations = 0;
  final maxIterations = n * 10;

  while (i < n && iterations < maxIterations) {
    iterations++;
    final box = ordered[i];
    final physical = box.measureNumber;

    // 1) Volta gate — skip endings that are not for the current pass.
    final covering = _endingAt(endingsCovering, i);
    if (covering != null &&
        i == covering.startIdx &&
        covering.endingNumber != currentPass) {
      i = covering.endIdx + 1;
      continue;
    }

    // 2) Emit visit.
    final built = _buildEntry(
      store: store,
      box: box,
      cursorMs: cursorMs,
      latentMeasure: latentMeasure,
      physicalMeasure: physical,
    );
    entries.add(built.entry);
    cursorMs = built.nextCursorMs;
    latentMeasure++;

    // Forward bar only anchors the jump-back target. [currentPass] is owned by
    // the backward bar — resetting it here would undo volta pass after `:|`.
    if (repeatStartAt.containsKey(physical)) {
      repeatStartIdx = i;
    }

    // 3) Local repeat (disabled after D.C. / D.S.).
    if (!jumped) {
      final region = repeatEndAt[physical];
      if (region != null) {
        final playCount = repeatCounts[i] ?? 1;
        if (playCount < region.times) {
          repeatCounts[i] = playCount + 1;
          currentPass = playCount + 1;
          i = indexByPhysical[region.startMeasure] ?? repeatStartIdx;
          continue;
        } else {
          repeatCounts.remove(i);
          currentPass = 1;
        }
      }
    }

    // 4) Navigation.
    if (!jumped) {
      if (daCapoAt.contains(physical)) {
        jumped = true;
        i = 0;
        continue;
      }
      final segnoTarget = dalSegnoAt[physical];
      if (segnoTarget != null) {
        final target = segnoIdx[segnoTarget];
        if (target != null) {
          jumped = true;
          i = target;
          continue;
        }
      }
    } else {
      final codaTarget = toCodaAt[physical];
      if (codaTarget != null) {
        final target = codaIdx[codaTarget];
        if (target != null) {
          i = target;
          continue;
        }
      }
      if (fineAt.contains(physical)) {
        break;
      }
    }

    i++;
  }

  if (iterations >= maxIterations) {
    return const SyncMapBuildFailure('formInvalidLoop');
  }
  if (entries.isEmpty) {
    return const SyncMapBuildFailure('formInvalidEmptyTimeline');
  }

  return SyncMapBuildSuccess(SyncMap(entries));
}

class _EndingSpan {
  const _EndingSpan({
    required this.startIdx,
    required this.endIdx,
    required this.endingNumber,
  });
  final int startIdx;
  final int endIdx;
  final int endingNumber;
}

_EndingSpan? _endingAt(List<_EndingSpan> spans, int idx) {
  for (final s in spans) {
    if (idx >= s.startIdx && idx <= s.endIdx) return s;
  }
  return null;
}

({SyncMapEntry entry, double nextCursorMs}) _buildEntry({
  required MeasureMapStore store,
  required MeasureBox box,
  required double cursorMs,
  required int latentMeasure,
  required int physicalMeasure,
}) {
  final meta = store.resolveMeta(box);
  final parts = parseTimeSignatureParts(meta.timeSignature);
  final beatsInBar = parts.numerator;
  final startBeat = box.startsAtBeat.clamp(0, beatsInBar - 1);
  final audibleBeats = beatsInBar - startBeat;
  final qPerBeat = quartersPerBeat(parts.denominator);
  final durationInQuarters = audibleBeats * qPerBeat;
  final tempo = meta.tempo <= 0 ? kDefaultTempo : meta.tempo;
  final msPerQuarter = 60000.0 / tempo;
  final msPerBeat = msPerQuarter * qPerBeat;

  final beatTimestamps = [
    for (var b = 0; b < audibleBeats; b++) cursorMs + b * msPerBeat,
  ];

  return (
    entry: SyncMapEntry(
      timeMs: cursorMs,
      measure: latentMeasure,
      physicalMeasure: physicalMeasure,
      beatTimestamps: beatTimestamps,
      timeSignature: meta.timeSignature,
      tempo: tempo,
      durationInQuarters: durationInQuarters,
      startsAtBeat: startBeat,
    ),
    nextCursorMs: cursorMs + audibleBeats * msPerBeat,
  );
}
