import 'package:stagescore/measure_map/measure_box.dart';
import 'package:stagescore/measure_map/measure_map_store.dart';
import 'package:stagescore/sync_map/sync_map_entry.dart';

/// Parse `"4/4"` → numerator / denominator. Invalid → `4/4`.
({int numerator, int denominator}) parseTimeSignatureParts(String ts) {
  final slash = ts.indexOf('/');
  if (slash < 0) {
    final n = int.tryParse(ts.trim()) ?? 4;
    return (numerator: n.clamp(1, 32), denominator: 4);
  }
  final num = int.tryParse(ts.substring(0, slash).trim()) ?? 4;
  final den = int.tryParse(ts.substring(slash + 1).trim()) ?? 4;
  return (
    numerator: num.clamp(1, 32),
    denominator: den <= 0 ? 4 : den,
  );
}

/// Quarters spanned by one beat of [denominator] (e.g. `/4` → 1, `/8` → 0.5).
double quartersPerBeat(int denominator) => 4.0 / denominator;

/// Pure MeasureMap → SyncMap (ADR 0019 quyết định 3c; Spec 0059).
///
/// - Duration from resolved tempo + time signature — **not** [MeasureBox.beatSplits].
/// - Gaps in measure numbers are skipped (no invented silence).
/// - [MeasureBox.startsAtBeat] shortens the audible span (Option B pickup).
SyncMap syncMapFromMeasureMap(MeasureMapStore store) {
  if (store.isEmpty) return const SyncMap([]);

  final ordered = List<MeasureBox>.from(store.boxes)
    ..sort((a, b) => a.measureNumber.compareTo(b.measureNumber));

  final entries = <SyncMapEntry>[];
  var cursorMs = 0.0;

  for (final box in ordered) {
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
      for (var i = 0; i < audibleBeats; i++) cursorMs + i * msPerBeat,
    ];

    entries.add(
      SyncMapEntry(
        timeMs: cursorMs,
        measure: box.measureNumber,
        beatTimestamps: beatTimestamps,
        timeSignature: meta.timeSignature,
        tempo: tempo,
        durationInQuarters: durationInQuarters,
        startsAtBeat: startBeat,
      ),
    );
    cursorMs += audibleBeats * msPerBeat;
  }

  return SyncMap(entries);
}

/// Locate the entry containing [timeMs], or the last if past the end.
SyncMapEntry? entryAtTime(SyncMap map, double timeMs) {
  if (map.isEmpty) return null;
  for (final e in map.entries) {
    if (timeMs < e.endMs - 1e-9) return e;
  }
  return map.last;
}

/// Nearest (measure, beatIndexInEntry) for [timeMs] after a map rebuild.
({int measure, int beatIndex})? nearestMeasureBeat(SyncMap map, double timeMs) {
  final entry = entryAtTime(map, timeMs);
  if (entry == null) return null;
  final beats = entry.beatTimestamps;
  if (beats.isEmpty) return (measure: entry.measure, beatIndex: 0);
  var best = 0;
  var bestDist = double.infinity;
  for (var i = 0; i < beats.length; i++) {
    final d = (beats[i] - timeMs).abs();
    if (d < bestDist) {
      bestDist = d;
      best = i;
    }
  }
  return (measure: entry.measure, beatIndex: best);
}
