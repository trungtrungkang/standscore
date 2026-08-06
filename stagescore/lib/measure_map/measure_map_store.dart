import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/measure_map/measure_box.dart';
import 'package:uuid/uuid.dart';

/// Scope when applying tempo / time-signature edits (Spec 0058 G3 #14).
enum MeasureMetaScope {
  thisMeasure,
  thisSystem,
  thisPage,
  restOfScore,
  nextN,
}

/// One Score ↔ one MeasureMap. Incomplete maps are valid (Spec 0058).
///
/// SystemBox is not stored separately — group [MeasureBox] by
/// `(pageNumber, systemIndex)`.
class MeasureMapStore {
  MeasureMapStore({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;
  final List<MeasureBox> _boxes = [];

  List<MeasureBox> get boxes => List.unmodifiable(_boxes);

  bool get isEmpty => _boxes.isEmpty;

  bool get isNotEmpty => _boxes.isNotEmpty;

  void clear() => _boxes.clear();

  MeasureBox? byId(String id) {
    for (final b in _boxes) {
      if (b.id == id) return b;
    }
    return null;
  }

  MeasureBox? byMeasureNumber(int measureNumber) {
    for (final b in _boxes) {
      if (b.measureNumber == measureNumber) return b;
    }
    return null;
  }

  /// Boxes on an absolute paper page, sorted left-to-right within systems.
  List<MeasureBox> boxesForPage(int pageNumber) {
    final list = _boxes.where((b) => b.pageNumber == pageNumber).toList();
    list.sort((a, b) {
      final sys = a.systemIndex.compareTo(b.systemIndex);
      if (sys != 0) return sys;
      return a.x.compareTo(b.x);
    });
    return list;
  }

  /// Boxes whose page falls inside [extent]; boxes outside stay on disk.
  List<MeasureBox> boxesVisibleIn(PageExtent? extent) {
    if (extent == null) return List.unmodifiable(_boxes);
    return [
      for (final b in _boxes)
        if (extent.contains(b.pageNumber)) b,
    ];
  }

  /// Boxes on [pageNumber] that fall inside [extent] (null = whole file).
  List<MeasureBox> boxesForPageInExtent(int pageNumber, PageExtent? extent) {
    if (extent != null && !extent.contains(pageNumber)) return const [];
    return boxesForPage(pageNumber);
  }

  List<MeasureBox> boxesInSystem({
    required int pageNumber,
    required int systemIndex,
  }) {
    final list = _boxes
        .where((b) => b.pageNumber == pageNumber && b.systemIndex == systemIndex)
        .toList();
    list.sort((a, b) => a.x.compareTo(b.x));
    return list;
  }

  /// System indices present on [pageNumber], ascending.
  List<int> systemIndicesOnPage(int pageNumber) {
    final set = <int>{};
    for (final b in _boxes) {
      if (b.pageNumber == pageNumber) set.add(b.systemIndex);
    }
    final list = set.toList()..sort();
    return list;
  }

  /// Union rect of a system (SystemBox geometry).
  ({double x, double y, double width, double height})? systemRect({
    required int pageNumber,
    required int systemIndex,
  }) {
    final sys = boxesInSystem(pageNumber: pageNumber, systemIndex: systemIndex);
    if (sys.isEmpty) return null;
    final left = sys.first.x;
    final right = sys.last.right;
    final top = sys.map((b) => b.y).reduce((a, b) => a < b ? a : b);
    final bottom = sys.map((b) => b.bottom).reduce((a, b) => a > b ? a : b);
    return (x: left, y: top, width: right - left, height: bottom - top);
  }

  /// Resolve inherited tempo / time signature for [box] in score order.
  ResolvedMeasureMeta resolveMeta(MeasureBox box) {
    String ts = kDefaultTimeSignature;
    double tempo = kDefaultTempo;
    final ordered = List<MeasureBox>.from(_boxes)
      ..sort((a, b) => a.measureNumber.compareTo(b.measureNumber));
    for (final b in ordered) {
      if (b.timeSignature != null) ts = b.timeSignature!;
      if (b.tempo != null) tempo = b.tempo!;
      if (b.id == box.id) break;
    }
    return ResolvedMeasureMeta(timeSignature: ts, tempo: tempo);
  }

  /// Renumber every box 1..N in reading order: page, system, x.
  void renumberMeasures() {
    final ordered = List<MeasureBox>.from(_boxes)
      ..sort((a, b) {
        final p = a.pageNumber.compareTo(b.pageNumber);
        if (p != 0) return p;
        final s = a.systemIndex.compareTo(b.systemIndex);
        if (s != 0) return s;
        return a.x.compareTo(b.x);
      });
    _boxes
      ..clear()
      ..addAll([
        for (var i = 0; i < ordered.length; i++)
          ordered[i].copyWith(measureNumber: i + 1),
      ]);
  }

  /// Drop stored tempo/timeSig when equal to the previous measure's effective.
  void compactInheritedMeta() {
    if (_boxes.isEmpty) return;
    renumberMeasures();
    final ordered = List<MeasureBox>.from(_boxes)
      ..sort((a, b) => a.measureNumber.compareTo(b.measureNumber));
    final out = <MeasureBox>[];
    var runningTs = kDefaultTimeSignature;
    var runningTempo = kDefaultTempo;
    for (var i = 0; i < ordered.length; i++) {
      final b = ordered[i];
      final ts = b.timeSignature ?? runningTs;
      final tempo = b.tempo ?? runningTempo;
      if (i == 0) {
        out.add(
          b.copyWith(
            timeSignature: ts,
            tempo: tempo,
          ),
        );
      } else {
        final storeTs = ts != runningTs ? ts : null;
        final storeTempo = tempo != runningTempo ? tempo : null;
        out.add(
          b.copyWith(
            clearTimeSignature: storeTs == null,
            clearTempo: storeTempo == null,
            timeSignature: storeTs,
            tempo: storeTempo,
          ),
        );
      }
      runningTs = ts;
      runningTempo = tempo;
    }
    _boxes
      ..clear()
      ..addAll(out);
  }

  /// Draw a SystemBox → [measureCount] evenly split MeasureBoxes.
  List<MeasureBox> addSystem({
    required int pageNumber,
    required double x,
    required double y,
    required double width,
    required double height,
    required int measureCount,
    int? systemIndex,
  }) {
    assert(measureCount >= 1);
    final sys =
        systemIndex ??
        (systemIndicesOnPage(pageNumber).isEmpty
            ? 0
            : systemIndicesOnPage(pageNumber).last + 1);
    final w = width / measureCount;
    // Inherit meta from the last measure before this insertion point.
    final prior = _boxes.isEmpty
        ? null
        : (List<MeasureBox>.from(_boxes)
                ..sort((a, b) => a.measureNumber.compareTo(b.measureNumber)))
              .last;
    final priorMeta = prior == null
        ? const ResolvedMeasureMeta(
            timeSignature: kDefaultTimeSignature,
            tempo: kDefaultTempo,
          )
        : resolveMeta(prior);
    final beats = beatsFromTimeSignature(priorMeta.timeSignature);
    final splits = evenBeatSplits(beats);
    final created = <MeasureBox>[];
    for (var i = 0; i < measureCount; i++) {
      created.add(
        MeasureBox(
          id: _uuid.v4(),
          pageNumber: pageNumber,
          measureNumber: 0, // renumber below
          systemIndex: sys,
          x: x + w * i,
          y: y,
          width: w,
          height: height,
          timeSignature: _boxes.isEmpty && i == 0
              ? kDefaultTimeSignature
              : null,
          tempo: _boxes.isEmpty && i == 0 ? kDefaultTempo : null,
          beatSplits: splits,
        ),
      );
    }
    _boxes.addAll(created);
    renumberMeasures();
    compactInheritedMeta();
    return [
      for (final c in created) byId(c.id)!,
    ];
  }

  /// Delete one MeasureBox; expand the neighbour (Spec 0058 G3 #12).
  ///
  /// Returns `true` if something changed. Deleting the last box of a system
  /// removes the whole system.
  bool deleteMeasure(String id) {
    final box = byId(id);
    if (box == null) return false;
    final sys = boxesInSystem(
      pageNumber: box.pageNumber,
      systemIndex: box.systemIndex,
    );
    if (sys.length <= 1) {
      _boxes.removeWhere(
        (b) =>
            b.pageNumber == box.pageNumber && b.systemIndex == box.systemIndex,
      );
      renumberMeasures();
      compactInheritedMeta();
      return true;
    }
    final idx = sys.indexWhere((b) => b.id == id);
    if (idx < 0) return false;
    if (idx == 0) {
      // First → next expands left.
      final next = sys[1];
      final newX = box.x;
      final newW = next.right - box.x;
      _replace(next.copyWith(x: newX, width: newW));
    } else {
      // Previous expands right to cover deleted.
      final prev = sys[idx - 1];
      final newW = box.right - prev.x;
      _replace(prev.copyWith(width: newW));
    }
    _boxes.removeWhere((b) => b.id == id);
    renumberMeasures();
    compactInheritedMeta();
    return true;
  }

  /// Delete every MeasureBox in a system.
  bool deleteSystem({required int pageNumber, required int systemIndex}) {
    final before = _boxes.length;
    _boxes.removeWhere(
      (b) => b.pageNumber == pageNumber && b.systemIndex == systemIndex,
    );
    if (_boxes.length == before) return false;
    renumberMeasures();
    compactInheritedMeta();
    return true;
  }

  /// Change measure count of the system containing [measureId] (G3 #13).
  ///
  /// Decreasing N drops rightmost boxes and expands the new rightmost to the
  /// system edge. Increasing N evenly splits the rightmost box. Left geometry
  /// is preserved.
  bool setMeasureCount(String measureId, int newCount) {
    if (newCount < 1) return false;
    final box = byId(measureId);
    if (box == null) return false;
    final sys = boxesInSystem(
      pageNumber: box.pageNumber,
      systemIndex: box.systemIndex,
    );
    if (sys.isEmpty) return false;
    if (newCount == sys.length) return false;

    final systemLeft = sys.first.x;
    final systemRight = sys.last.right;
    final y = sys.first.y;
    final height = sys.first.height;
    final meta = resolveMeta(sys.first);
    final beats = beatsFromTimeSignature(meta.timeSignature);
    final splits = evenBeatSplits(beats);

    if (newCount < sys.length) {
      final keep = sys.sublist(0, newCount);
      final dropIds = {for (final b in sys.sublist(newCount)) b.id};
      _boxes.removeWhere((b) => dropIds.contains(b.id));
      final last = keep.last;
      _replace(last.copyWith(width: systemRight - last.x));
    } else {
      final extra = newCount - sys.length;
      final rightmost = sys.last;
      final leftKeep = sys.sublist(0, sys.length - 1);
      // Split rightmost into (1 + extra) equal parts covering [rightmost.x, systemRight].
      final span = systemRight - rightmost.x;
      final partW = span / (1 + extra);
      _replace(rightmost.copyWith(width: partW));
      for (var i = 1; i <= extra; i++) {
        _boxes.add(
          MeasureBox(
            id: _uuid.v4(),
            pageNumber: box.pageNumber,
            measureNumber: 0,
            systemIndex: box.systemIndex,
            x: rightmost.x + partW * i,
            y: y,
            width: partW,
            height: height,
            beatSplits: List<double>.from(splits),
          ),
        );
      }
      // Ensure left boxes untouched (already are); clamp any float drift.
      for (final b in leftKeep) {
        if (b.x < systemLeft) {
          _replace(b.copyWith(x: systemLeft));
        }
      }
    }
    renumberMeasures();
    compactInheritedMeta();
    return true;
  }

  /// Minimum SystemBox size in normalized page space (Spec 0058 rev. 1).
  static const minSystemWidth = 0.02;
  static const minSystemHeight = 0.01;

  /// Resize a system to [x]/[y]/[width]/[height] (clamped to the page).
  ///
  /// Horizontal positions of MeasureBoxes are scaled proportionally so uneven
  /// dividers are preserved. Vertical: every box shares the new y/height.
  bool resizeSystem({
    required int pageNumber,
    required int systemIndex,
    required double x,
    required double y,
    required double width,
    required double height,
  }) {
    final sys = boxesInSystem(
      pageNumber: pageNumber,
      systemIndex: systemIndex,
    );
    if (sys.isEmpty) return false;

    var left = x.clamp(0.0, 1.0);
    var top = y.clamp(0.0, 1.0);
    var w = width;
    var h = height;
    if (left + w > 1.0) w = 1.0 - left;
    if (top + h > 1.0) h = 1.0 - top;
    if (w < minSystemWidth || h < minSystemHeight) return false;

    final oldLeft = sys.first.x;
    final oldRight = sys.last.right;
    final oldW = oldRight - oldLeft;
    if (oldW <= 0) return false;

    for (final b in sys) {
      final relX = (b.x - oldLeft) / oldW;
      final relW = b.width / oldW;
      _replace(
        b.copyWith(
          x: left + relX * w,
          y: top,
          width: relW * w,
          height: h,
        ),
      );
    }
    return true;
  }

  /// Translate a system by [dx]/[dy], clamping so it stays on the page.
  bool moveSystem({
    required int pageNumber,
    required int systemIndex,
    required double dx,
    required double dy,
  }) {
    final rect = systemRect(pageNumber: pageNumber, systemIndex: systemIndex);
    if (rect == null) return false;
    var ndx = dx;
    var ndy = dy;
    if (rect.x + ndx < 0) ndx = -rect.x;
    if (rect.y + ndy < 0) ndy = -rect.y;
    if (rect.x + rect.width + ndx > 1) ndx = 1 - rect.x - rect.width;
    if (rect.y + rect.height + ndy > 1) ndy = 1 - rect.y - rect.height;
    if (ndx == 0 && ndy == 0) return false;

    final sys = boxesInSystem(
      pageNumber: pageNumber,
      systemIndex: systemIndex,
    );
    for (final b in sys) {
      _replace(b.copyWith(x: b.x + ndx, y: b.y + ndy));
    }
    return true;
  }

  /// Drag a measure divider: [leftId] is the box to the left of the divider.
  /// [newRight] is the new right edge of that box (absolute normalized x).
  bool dragMeasureDivider({
    required String leftId,
    required double newRight,
  }) {
    final left = byId(leftId);
    if (left == null) return false;
    final sys = boxesInSystem(
      pageNumber: left.pageNumber,
      systemIndex: left.systemIndex,
    );
    final idx = sys.indexWhere((b) => b.id == leftId);
    if (idx < 0 || idx >= sys.length - 1) return false;
    final right = sys[idx + 1];
    final minX = left.x + 0.01;
    final maxX = right.right - 0.01;
    final clamped = newRight.clamp(minX, maxX);
    _replace(left.copyWith(width: clamped - left.x));
    _replace(
      right.copyWith(x: clamped, width: right.right - clamped),
    );
    return true;
  }

  /// Drag a beat-anchor line inside [measureId]. All N anchors are draggable
  /// (they are interior — not the measure barlines).
  bool dragBeatSplit({
    required String measureId,
    required int splitIndex,
    required double newRatio,
  }) {
    final box = byId(measureId);
    if (box == null) return false;
    final splits = List<double>.from(box.beatSplits);
    if (splitIndex < 0 || splitIndex >= splits.length) return false;
    final lo = splitIndex == 0 ? 0.01 : splits[splitIndex - 1] + 0.01;
    final hi = splitIndex == splits.length - 1
        ? 0.99
        : splits[splitIndex + 1] - 0.01;
    splits[splitIndex] = newRatio.clamp(lo, hi);
    _replace(box.copyWith(beatSplits: splits));
    return true;
  }

  /// Apply tempo / time signature over a scope (Spec 0058 G3 #14).
  ///
  /// Changing time signature resets beatSplits to even for every box in range.
  /// Set pickup start beat for one measure (Spec 0059 Option B). `0` clears.
  bool setStartsAtBeat(String id, int startsAtBeat) {
    final box = byId(id);
    if (box == null) return false;
    final beats = beatsFromTimeSignature(resolveMeta(box).timeSignature);
    final clamped = startsAtBeat.clamp(0, beats - 1);
    if (box.startsAtBeat == clamped) return false;
    _replace(box.copyWith(startsAtBeat: clamped));
    return true;
  }

  bool applyMeta({
    required String anchorId,
    required MeasureMetaScope scope,
    String? timeSignature,
    double? tempo,
    int? nextN,
  }) {
    final anchor = byId(anchorId);
    if (anchor == null) return false;
    if (timeSignature == null && tempo == null) return false;

    final targets = _scopeTargets(
      anchor: anchor,
      scope: scope,
      nextN: nextN,
    );
    if (targets.isEmpty) return false;

    final resetBeats = timeSignature != null;
    final beats = beatsFromTimeSignature(
      timeSignature ?? resolveMeta(anchor).timeSignature,
    );
    final splits = evenBeatSplits(beats);

    for (final id in targets) {
      final b = byId(id);
      if (b == null) continue;
      _replace(
        b.copyWith(
          timeSignature: timeSignature ?? b.timeSignature,
          tempo: tempo ?? b.tempo,
          beatSplits: resetBeats ? List<double>.from(splits) : null,
        ),
      );
    }
    compactInheritedMeta();
    return true;
  }

  List<String> _scopeTargets({
    required MeasureBox anchor,
    required MeasureMetaScope scope,
    int? nextN,
  }) {
    final ordered = List<MeasureBox>.from(_boxes)
      ..sort((a, b) => a.measureNumber.compareTo(b.measureNumber));
    switch (scope) {
      case MeasureMetaScope.thisMeasure:
        return [anchor.id];
      case MeasureMetaScope.thisSystem:
        return [
          for (final b in boxesInSystem(
            pageNumber: anchor.pageNumber,
            systemIndex: anchor.systemIndex,
          ))
            b.id,
        ];
      case MeasureMetaScope.thisPage:
        return [
          for (final b in boxesForPage(anchor.pageNumber)) b.id,
        ];
      case MeasureMetaScope.restOfScore:
        return [
          for (final b in ordered)
            if (b.measureNumber >= anchor.measureNumber) b.id,
        ];
      case MeasureMetaScope.nextN:
        final n = nextN ?? 1;
        final start = ordered.indexWhere((b) => b.id == anchor.id);
        if (start < 0) return const [];
        return [
          for (final b in ordered.skip(start).take(n)) b.id,
        ];
    }
  }

  /// Copy systems from [fromPage] onto [toPage] (Spec 0058 G3 #4).
  ///
  /// Existing boxes on [toPage] are replaced. No measure-count dialog.
  bool copyLayoutFromPage({required int fromPage, required int toPage}) {
    if (fromPage == toPage) return false;
    final source = boxesForPage(fromPage);
    if (source.isEmpty) return false;
    _boxes.removeWhere((b) => b.pageNumber == toPage);
    for (final b in source) {
      _boxes.add(
        MeasureBox(
          id: _uuid.v4(),
          pageNumber: toPage,
          measureNumber: 0,
          systemIndex: b.systemIndex,
          x: b.x,
          y: b.y,
          width: b.width,
          height: b.height,
          beatSplits: List<double>.from(b.beatSplits),
          // Meta is re-inherited after renumber; do not copy overrides blindly.
        ),
      );
    }
    renumberMeasures();
    compactInheritedMeta();
    return true;
  }

  void _replace(MeasureBox box) {
    final i = _boxes.indexWhere((b) => b.id == box.id);
    if (i < 0) {
      _boxes.add(box);
    } else {
      _boxes[i] = box;
    }
  }

  Map<String, dynamic> toJson(String scoreId) => {
    'scoreId': scoreId,
    'measures': _boxes.map((b) => b.toJson()).toList(),
  };

  void loadJson(Map<String, dynamic> json) {
    clear();
    final list = json['measures'] as List<dynamic>? ?? const [];
    _boxes.addAll([
      for (final e in list) MeasureBox.fromJson(e as Map<String, dynamic>),
    ]);
    migrateBeatSplits();
  }

  /// Convert legacy N−1 / mistaken trailing-`1.0` payloads to N interior anchors.
  void migrateBeatSplits() {
    for (final b in List<MeasureBox>.from(_boxes)) {
      final beats = beatsFromTimeSignature(resolveMeta(b).timeSignature);
      final next = normalizeBeatSplits(b.beatSplits, beats);
      if (!_listEquals(b.beatSplits, next)) {
        _replace(b.copyWith(beatSplits: next));
      }
    }
  }

  static bool _listEquals(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if ((a[i] - b[i]).abs() > 1e-9) return false;
    }
    return true;
  }

  /// Web `pdfMeasureMap` array shape (no scoreId wrapper).
  List<Map<String, dynamic>> toWebList() => [
    for (final b in _boxes) b.toWebJson(),
  ];

  void loadWebList(List<dynamic> list) {
    clear();
    _boxes.addAll([
      for (final e in list) MeasureBox.fromWebJson(e as Map<String, dynamic>),
    ]);
    migrateBeatSplits();
  }
}
