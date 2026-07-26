import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:path/path.dart' as p;
import 'package:stagescore/annotation/annotation_geometry.dart';
import 'package:stagescore/annotation/draw_tool.dart';
import 'package:stagescore/annotation/stamp.dart';
import 'package:uuid/uuid.dart';

/// One ink stroke in normalized page coordinates (0–1), origin top-left of page.
class AnnotationStroke {
  AnnotationStroke({
    required this.id,
    required this.pageNumber,
    required List<Offset> points,
    this.tool = DrawTool.pen,
    this.color = DrawToolPresets.penColor,
    this.width = DrawToolPresets.penWidth,
  }) : points = List.unmodifiable(points);

  final String id;

  /// 1-based PDF source page number (pdfrx convention).
  final int pageNumber;

  /// Normalized points in \[0, 1\] relative to page width/height.
  final List<Offset> points;

  final DrawTool tool;
  final Color color;

  /// Stroke width as a fraction of page width.
  final double width;

  Map<String, dynamic> toJson() => {
    'id': id,
    'pageNumber': pageNumber,
    'tool': tool.name,
    'color': color.toARGB32(),
    'width': width,
    'points': [
      for (final pt in points) {'x': pt.dx, 'y': pt.dy},
    ],
  };

  factory AnnotationStroke.fromJson(Map<String, dynamic> json) {
    final toolName = json['tool'] as String? ?? DrawTool.pen.name;
    final tool = DrawTool.values.firstWhere(
      (t) => t.name == toolName,
      orElse: () => DrawTool.pen,
    );
    final inkTool = DrawToolPresets.isInkTool(tool) ? tool : DrawTool.pen;
    final rawPoints = json['points'] as List<dynamic>? ?? const [];
    return AnnotationStroke(
      id: json['id'] as String? ?? const Uuid().v4(),
      pageNumber: json['pageNumber'] as int,
      tool: inkTool,
      color: Color(
        json['color'] as int? ?? DrawToolPresets.penColor.toARGB32(),
      ),
      width: (json['width'] as num?)?.toDouble() ?? DrawToolPresets.penWidth,
      points: [
        for (final pt in rawPoints)
          Offset(
            ((pt as Map<String, dynamic>)['x'] as num).toDouble(),
            (pt['y'] as num).toDouble(),
          ),
      ],
    );
  }
}

sealed class _AnnotationEdit {
  const _AnnotationEdit();
}

class _AddStrokeEdit extends _AnnotationEdit {
  const _AddStrokeEdit(this.stroke);
  final AnnotationStroke stroke;
}

class _RemoveStrokesEdit extends _AnnotationEdit {
  const _RemoveStrokesEdit(this.strokes);
  final List<AnnotationStroke> strokes;
}

class _AddStampEdit extends _AnnotationEdit {
  const _AddStampEdit(this.stamp);
  final AnnotationStamp stamp;
}

class _RemoveStampEdit extends _AnnotationEdit {
  const _RemoveStampEdit(this.stamp);
  final AnnotationStamp stamp;
}

class _ReplaceStampEdit extends _AnnotationEdit {
  const _ReplaceStampEdit({required this.before, required this.after});
  final AnnotationStamp before;
  final AnnotationStamp after;
}

/// Annotation store: ink + stamps with undo/redo (Specs 0017 / 0019).
class AnnotationStore {
  AnnotationStore({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;
  final List<AnnotationStroke> _strokes = [];
  final List<AnnotationStamp> _stamps = [];
  final List<_AnnotationEdit> _undo = [];
  final List<_AnnotationEdit> _redo = [];

  List<AnnotationStroke> get strokes => List.unmodifiable(_strokes);

  List<AnnotationStamp> get stamps => List.unmodifiable(_stamps);

  List<AnnotationStroke> strokesForPage(int pageNumber) =>
      _strokes.where((s) => s.pageNumber == pageNumber).toList(growable: false);

  List<AnnotationStamp> stampsForPage(int pageNumber) =>
      _stamps.where((s) => s.pageNumber == pageNumber).toList(growable: false);

  int get length => _strokes.length;

  int get stampCount => _stamps.length;

  bool get canUndo => _undo.isNotEmpty;

  bool get canRedo => _redo.isNotEmpty;

  String newId() => _uuid.v4();

  void addStroke(AnnotationStroke stroke) {
    if (stroke.points.length < 2) return;
    if (!DrawToolPresets.isInkTool(stroke.tool)) return;
    _strokes.add(stroke);
    _undo.add(_AddStrokeEdit(stroke));
    _redo.clear();
  }

  AnnotationStroke createStroke({
    required int pageNumber,
    required List<Offset> points,
    required DrawTool tool,
    Color? color,
    double? width,
  }) {
    assert(DrawToolPresets.isInkTool(tool));
    return AnnotationStroke(
      id: newId(),
      pageNumber: pageNumber,
      points: points,
      tool: tool,
      color: color ?? DrawToolPresets.colorFor(tool),
      width: width ?? DrawToolPresets.widthFor(tool),
    );
  }

  int eraseAlong({
    required int pageNumber,
    required List<Offset> path,
    double radius = DrawToolPresets.eraserRadius,
  }) {
    if (path.isEmpty) return 0;
    final victims = _strokes
        .where(
          (s) =>
              s.pageNumber == pageNumber &&
              pathHitsStroke(path, s, radius: radius),
        )
        .toList(growable: false);
    if (victims.isEmpty) return 0;
    final ids = victims.map((s) => s.id).toSet();
    _strokes.removeWhere((s) => ids.contains(s.id));
    _undo.add(_RemoveStrokesEdit(victims));
    _redo.clear();
    return victims.length;
  }

  AnnotationStamp createStamp({
    required int pageNumber,
    required StampKind kind,
    required Offset center,
    Color? color,
    double? size,
    String? text,
  }) {
    return AnnotationStamp(
      id: newId(),
      pageNumber: pageNumber,
      kind: kind,
      center: Offset(center.dx.clamp(0.0, 1.0), center.dy.clamp(0.0, 1.0)),
      size: size ?? 0.06,
      color: color ?? DrawToolPresets.penColor,
      text: text,
    );
  }

  void addStamp(AnnotationStamp stamp) {
    _stamps.add(stamp);
    _undo.add(_AddStampEdit(stamp));
    _redo.clear();
  }

  bool deleteStamp(String id) {
    final index = _stamps.indexWhere((s) => s.id == id);
    if (index < 0) return false;
    final stamp = _stamps.removeAt(index);
    _undo.add(_RemoveStampEdit(stamp));
    _redo.clear();
    return true;
  }

  bool moveStamp(String id, Offset center) {
    final index = _stamps.indexWhere((s) => s.id == id);
    if (index < 0) return false;
    final before = _stamps[index];
    final after = before.copyWith(
      center: Offset(center.dx.clamp(0.0, 1.0), center.dy.clamp(0.0, 1.0)),
    );
    if (after.center == before.center) return false;
    _stamps[index] = after;
    _undo.add(_ReplaceStampEdit(before: before, after: after));
    _redo.clear();
    return true;
  }

  /// Topmost stamp under [point] on [pageNumber], or null.
  AnnotationStamp? hitTestStamp(int pageNumber, Offset point) {
    final pageStamps = stampsForPage(pageNumber);
    for (var i = pageStamps.length - 1; i >= 0; i--) {
      if (pageStamps[i].hitRect.contains(point)) return pageStamps[i];
    }
    return null;
  }

  bool undo() {
    if (_undo.isEmpty) return false;
    final edit = _undo.removeLast();
    switch (edit) {
      case _AddStrokeEdit(:final stroke):
        _strokes.removeWhere((s) => s.id == stroke.id);
      case _RemoveStrokesEdit(:final strokes):
        _strokes.addAll(strokes);
      case _AddStampEdit(:final stamp):
        _stamps.removeWhere((s) => s.id == stamp.id);
      case _RemoveStampEdit(:final stamp):
        _stamps.add(stamp);
      case _ReplaceStampEdit(:final before, :final after):
        final i = _stamps.indexWhere((s) => s.id == after.id);
        if (i >= 0) _stamps[i] = before;
    }
    _redo.add(edit);
    return true;
  }

  bool redo() {
    if (_redo.isEmpty) return false;
    final edit = _redo.removeLast();
    switch (edit) {
      case _AddStrokeEdit(:final stroke):
        _strokes.add(stroke);
      case _RemoveStrokesEdit(:final strokes):
        final ids = strokes.map((s) => s.id).toSet();
        _strokes.removeWhere((s) => ids.contains(s.id));
      case _AddStampEdit(:final stamp):
        _stamps.add(stamp);
      case _RemoveStampEdit(:final stamp):
        _stamps.removeWhere((s) => s.id == stamp.id);
      case _ReplaceStampEdit(:final before, :final after):
        final i = _stamps.indexWhere((s) => s.id == before.id);
        if (i >= 0) _stamps[i] = after;
    }
    _undo.add(edit);
    return true;
  }

  void clear() {
    _strokes.clear();
    _stamps.clear();
    _undo.clear();
    _redo.clear();
  }

  void replaceAll(List<AnnotationStroke> strokes) {
    clear();
    _strokes.addAll(strokes);
  }

  Map<String, dynamic> toJson(String scoreId) => {
    'scoreId': scoreId,
    'strokes': _strokes.map((s) => s.toJson()).toList(),
    'stamps': _stamps.map((s) => s.toJson()).toList(),
  };

  void loadJson(Map<String, dynamic> json) {
    clear();
    final strokeList = json['strokes'] as List<dynamic>? ?? const [];
    _strokes.addAll([
      for (final e in strokeList)
        AnnotationStroke.fromJson(e as Map<String, dynamic>),
    ]);
    final stampList = json['stamps'] as List<dynamic>? ?? const [];
    for (final e in stampList) {
      final stamp = AnnotationStamp.tryFromJson(e as Map<String, dynamic>);
      if (stamp != null) _stamps.add(stamp);
    }
  }
}

/// Per-Score annotation file under `standscore/annotations/<scoreId>.json`.
class AnnotationPersistence {
  AnnotationPersistence({required Directory root, required this.scoreId})
    : _file = File(p.join(root.path, 'annotations', '$scoreId.json'));

  final String scoreId;
  final File _file;

  Future<void> loadInto(AnnotationStore store) async {
    if (!await _file.exists()) {
      store.clear();
      return;
    }
    final json = jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
    store.loadJson(json);
  }

  Future<void> save(AnnotationStore store) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(store.toJson(scoreId)),
    );
  }
}
