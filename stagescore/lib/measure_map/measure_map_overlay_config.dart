import 'package:flutter/material.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/measure_map/measure_map_selection.dart';
import 'package:stagescore/measure_map/measure_map_store.dart';

/// Bundled MeasureMap overlay inputs — one optional object through page slots.
class MeasureMapOverlayConfig {
  const MeasureMapOverlayConfig({
    required this.store,
    required this.editEnabled,
    required this.onChanged,
    required this.onSystemDrawn,
    required this.selection,
    required this.onSelectionChanged,
    this.extent,
    this.highlightedId,
    this.editingBeatsId,
    this.onMeasureLongPress,
  });

  final MeasureMapStore store;
  final PageExtent? extent;
  final bool editEnabled;
  final MeasureMapSelection selection;
  final String? highlightedId;
  final String? editingBeatsId;
  final ValueChanged<MeasureMapSelection> onSelectionChanged;
  final VoidCallback onChanged;

  /// Rubber-band finished: parent shows the measure-count dialog then commits.
  final void Function(int pageNumber, Rect normalizedRect) onSystemDrawn;

  /// Long-press on a MeasureBox → select its parent SystemBox (Spec 0058 rev. 1).
  final ValueChanged<String>? onMeasureLongPress;

  String? get selectedMeasureId => selection.measureId;

  ({int pageNumber, int systemIndex})? get selectedSystem =>
      selection.systemKey;
}
