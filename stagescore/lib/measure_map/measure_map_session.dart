/// Sticky default MeasureBox count while MeasureMap edit mode is open.
///
/// Lives in PdfMode session memory only — never written to
/// `measure_maps/<scoreId>.json` or app prefs (Spec 0058 G3 #11).
class MeasureMapSessionDefaults {
  static const int initial = 4;

  int measureCount = initial;

  void remember(int count) {
    if (count >= 1) measureCount = count;
  }

  void reset() => measureCount = initial;
}
