/// Colored chip painted on a MeasureBox during FormMap edit (Spec 0061).
enum FormOverlayBadgeKind {
  /// Repeat start / end (`|:`, `:|×n`).
  repeat,

  /// Volta / 1st–2nd ending (`1.`, `2.`).
  ending,

  /// Segno / Coda / Fine / To Coda marker.
  marker,

  /// D.C. / D.S. / To Coda jump.
  jump,
}

class FormOverlayBadge {
  const FormOverlayBadge({required this.label, required this.kind});

  final String label;
  final FormOverlayBadgeKind kind;
}
