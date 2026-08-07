// Spec 0069 (spike). SystemBox and ReadBox answer two different questions and
// the names are what keep them from drifting into one:
//
//   SystemBox — where the playhead runs. It hugs the system — every staff
//               sounding at once, so a piano grand staff is one box, not two —
//               which puts measure dividers on barlines and gives the playhead
//               sensible top and bottom edges (Spec 0058). It does not change.
//   ReadBox   — what the musician needs to see. Dynamics, pedal marks, lyrics,
//               chord symbols, ledger lines and tempo text all sit outside the
//               staff, so ReflowMode crops this, not a SystemBox.
//
// Everything here is arithmetic on a MeasureMap. No page image is opened and
// nothing is recognised, so this stays clear of the OMR boundary ADR 0006 and
// ADR 0019 draw, and it needs no new field on disk.

import 'package:stagescore/measure_map/measure_map_store.dart';

/// One system's reading area, in normalized page coordinates.
class ReadBox {
  const ReadBox({
    required this.pageNumber,
    required this.systemIndex,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.systemY,
    required this.systemHeight,
  });

  /// Absolute 1-based PdfDocument page — paper space, same as MeasureBox.
  final int pageNumber;

  final int systemIndex;

  final double x;
  final double y;
  final double width;
  final double height;

  /// The SystemBox inside this crop: the playhead still belongs there, not
  /// across the lyrics.
  final double systemY;
  final double systemHeight;

  double get right => x + width;

  double get bottom => y + height;

  /// How much larger this reads than the whole page shown at the same width.
  double get magnification => width <= 0 ? 1 : 1 / width;
}

/// Widest [contextFraction] that still guarantees ReadBoxes never overlap.
const kReadBoxMaxContext = 1.0;

/// ReadBoxes on one absolute paper page, in reading order (top to bottom).
///
/// [contextFraction] scales how much of the space between systems each ReadBox
/// claims: `0` is the bare SystemBox, `1` splits every gap evenly with the
/// neighbour. At `1` adjacent ReadBoxes touch and never overlap, which is what
/// makes a single slider safe to hand a musician — more context can only cost
/// magnification, never someone else's notes.
List<ReadBox> readBoxesForPage(
  MeasureMapStore store,
  int pageNumber, {
  double contextFraction = kReadBoxMaxContext,
}) {
  final c = contextFraction.clamp(0.0, kReadBoxMaxContext);

  final rects =
      <({
        int systemIndex,
        double x,
        double y,
        double width,
        double height,
      })>[];
  for (final index in store.systemIndicesOnPage(pageNumber)) {
    final r = store.systemRect(pageNumber: pageNumber, systemIndex: index);
    if (r == null) continue;
    rects.add((
      systemIndex: index,
      x: r.x,
      y: r.y,
      width: r.width,
      height: r.height,
    ));
  }
  if (rects.isEmpty) return const [];

  // Reading order is vertical and drawing order is not: a musician who misses a
  // system and draws it afterwards gets a systemIndex that does not increase
  // down the page.
  rects.sort((a, b) => a.y.compareTo(b.y));

  // Every system on a printed page shares one left and one right margin, so the
  // extremes are the right frame for all of them. This is self-correcting: a
  // system drawn from the first barline instead of from the clef still gets the
  // clef and key signature back from whichever system was drawn wider.
  var left = 1.0;
  var right = 0.0;
  for (final r in rects) {
    if (r.x < left) left = r.x;
    if (r.x + r.width > right) right = r.x + r.width;
  }

  final gaps = <double>[];
  for (var i = 1; i < rects.length; i++) {
    final gap = rects[i].y - (rects[i - 1].y + rects[i - 1].height);
    // Hand-drawn systems can overlap slightly; a negative gap would hand the
    // neighbour's staff to this ReadBox instead of taking blank space.
    gaps.add(gap < 0 ? 0 : gap);
  }

  // The page edge is the wrong measure for the first and last system: page 1
  // carries a title block and the last page trails off into margin, so both
  // would claim far more than a gap. The page's own typical gap is the honest
  // stand-in; a page with one system has none, so half its height is.
  final double fallback;
  if (gaps.isEmpty) {
    fallback = rects.first.height * 0.5;
  } else {
    fallback = gaps.reduce((a, b) => a + b) / gaps.length;
  }

  final out = <ReadBox>[];
  for (var i = 0; i < rects.length; i++) {
    final r = rects[i];
    final gapAbove = i == 0 ? fallback : gaps[i - 1];
    final gapBelow = i == rects.length - 1 ? fallback : gaps[i];
    var top = r.y - c * gapAbove / 2;
    var bottom = r.y + r.height + c * gapBelow / 2;
    if (top < 0) top = 0;
    if (bottom > 1) bottom = 1;
    out.add(
      ReadBox(
        pageNumber: pageNumber,
        systemIndex: r.systemIndex,
        x: left,
        y: top,
        width: right - left,
        height: bottom - top,
        systemY: r.y,
        systemHeight: r.height,
      ),
    );
  }
  return out;
}

/// Every ReadBox of a Score in reading order: by page, then top to bottom.
List<ReadBox> readBoxesForScore(
  MeasureMapStore store, {
  double contextFraction = kReadBoxMaxContext,
}) {
  final pages = store.boxes.map((b) => b.pageNumber).toSet().toList()..sort();
  return [
    for (final page in pages)
      ...readBoxesForPage(store, page, contextFraction: contextFraction),
  ];
}
