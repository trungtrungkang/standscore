import 'dart:math' as math;

import 'package:stagescore/form_map/form_map.dart';

/// In-memory FormMap for the open Score (Spec 0061).
class FormMapStore {
  FormMap _form = FormMap();

  FormMap get form => _form;

  bool get isEmpty => _form.isEmpty;

  bool get isNotEmpty => _form.isNotEmpty;

  void clear() => _form = FormMap();

  void load(FormMap form) => _form = form;

  void loadJson(Map<String, dynamic> json) => _form = FormMap.fromJson(json);

  Map<String, dynamic> toJson(String scoreId) => _form.toJson(scoreId);

  void setForm(FormMap form) => _form = form;

  void upsertRepeat(FormRepeatRegion region) {
    final next = [
      for (final r in _form.repeats)
        if (r.id != region.id) r,
      region,
    ];
    _form = _form.copyWith(repeats: next);
  }

  /// Existing repeats whose measure range overlaps [start]…[end] (inclusive).
  List<FormRepeatRegion> overlappingRepeats({
    required int start,
    required int end,
  }) {
    return [
      for (final r in _form.repeats)
        if (r.startMeasure <= end && start <= r.endMeasure) r,
    ];
  }

  /// Drop overlapping repeats, then insert [region].
  void replaceOverlappingRepeats(FormRepeatRegion region) {
    final next = [
      for (final r in _form.repeats)
        if (!(r.startMeasure <= region.endMeasure &&
            region.startMeasure <= r.endMeasure))
          r,
      region,
    ];
    _form = _form.copyWith(repeats: next);
  }

  void removeRepeat(String id) {
    _form = _form.copyWith(
      repeats: [for (final r in _form.repeats) if (r.id != id) r],
    );
  }

  /// Save a repeat and optional volta (1st / 2nd ending) in one edit.
  ///
  /// Scrubs endings that overlap the old/new repeat span (and volta measures),
  /// then writes [pass1] / [pass2] when provided.
  void applyRepeatWithVoltas({
    required FormRepeatRegion region,
    required bool replaceOverlapping,
    ({int start, int end})? pass1,
    ({int start, int end})? pass2,
  }) {
    final conflicts = overlappingRepeats(
      start: region.startMeasure,
      end: region.endMeasure,
    );
    var lo = region.startMeasure;
    var hi = region.endMeasure + 1; // 2nd ending often sits just after :|
    for (final r in conflicts) {
      lo = math.min(lo, r.startMeasure);
      hi = math.max(hi, r.endMeasure + 1);
    }
    if (pass1 != null) {
      lo = math.min(lo, pass1.start);
      hi = math.max(hi, pass1.end);
    }
    if (pass2 != null) {
      lo = math.min(lo, pass2.start);
      hi = math.max(hi, pass2.end);
    }

    if (replaceOverlapping) {
      replaceOverlappingRepeats(region);
    } else {
      upsertRepeat(region);
    }

    final kept = [
      for (final e in _form.endings)
        if (!(e.startMeasure <= hi && lo <= e.endMeasure)) e,
    ];
    final next = [...kept];
    if (pass1 != null) {
      next.add(
        FormEnding(
          id: 'ending-1-${pass1.start}-${pass1.end}',
          startMeasure: pass1.start,
          endMeasure: pass1.end,
          endingNumber: 1,
        ),
      );
    }
    if (pass2 != null) {
      next.add(
        FormEnding(
          id: 'ending-2-${pass2.start}-${pass2.end}',
          startMeasure: pass2.start,
          endMeasure: pass2.end,
          endingNumber: 2,
        ),
      );
    }
    _form = _form.copyWith(endings: next);
  }

  FormEnding? endingForPassNear({
    required int endingNumber,
    required int repeatStart,
    required int repeatEnd,
  }) {
    FormEnding? best;
    for (final e in _form.endings) {
      if (e.endingNumber != endingNumber) continue;
      final near = e.startMeasure >= repeatStart &&
          e.startMeasure <= repeatEnd + 1;
      final overlaps =
          e.startMeasure <= repeatEnd && e.endMeasure >= repeatStart;
      if (!near && !overlaps) continue;
      best = e;
    }
    return best;
  }

  void upsertEnding(FormEnding ending) {
    final next = [
      for (final e in _form.endings)
        if (e.id != ending.id) e,
      ending,
    ];
    _form = _form.copyWith(endings: next);
  }

  void removeEnding(String id) {
    _form = _form.copyWith(
      endings: [for (final e in _form.endings) if (e.id != id) e],
    );
  }

  void setMarkerOnMeasure({
    required int measure,
    FormMarkerKind? kind,
    String targetId = '1',
  }) {
    final kept = [
      for (final m in _form.markers)
        if (m.measure != measure) m,
    ];
    if (kind == null) {
      _form = _form.copyWith(markers: kept);
      return;
    }
    _form = _form.copyWith(
      markers: [
        ...kept,
        FormMarker(
          id: 'marker-$measure-${kind.name}',
          measure: measure,
          kind: kind,
          targetId: targetId,
        ),
      ],
    );
  }

  void setJumpOnMeasure({
    required int measure,
    FormJumpKind? kind,
    String targetId = '1',
  }) {
    final kept = [
      for (final j in _form.jumps)
        if (j.measure != measure) j,
    ];
    if (kind == null) {
      _form = _form.copyWith(jumps: kept);
      return;
    }
    _form = _form.copyWith(
      jumps: [
        ...kept,
        FormJump(
          id: 'jump-$measure-${kind.name}',
          measure: measure,
          kind: kind,
          targetId: targetId,
        ),
      ],
    );
  }

  /// Clear all form annotations that reference [measure].
  void clearMeasure(int measure) {
    _form = FormMap(
      repeats: [
        for (final r in _form.repeats)
          if (r.startMeasure != measure && r.endMeasure != measure) r,
      ],
      endings: [
        for (final e in _form.endings)
          if (e.startMeasure != measure && e.endMeasure != measure) e,
      ],
      markers: [
        for (final m in _form.markers)
          if (m.measure != measure) m,
      ],
      jumps: [
        for (final j in _form.jumps)
          if (j.measure != measure) j,
      ],
    );
  }

  FormMarker? markerAt(int measure) {
    for (final m in _form.markers) {
      if (m.measure == measure) return m;
    }
    return null;
  }

  FormJump? jumpAt(int measure) {
    for (final j in _form.jumps) {
      if (j.measure == measure) return j;
    }
    return null;
  }
}
