import 'package:stagescore/layout/pdf_layout_mode.dart';

/// Whether [mode] is one of the two Half Page layouts (Spec 0013, reworked
/// into continuous scroll by Spec 0056).
bool isHalfPageLayoutMode(PdfLayoutMode mode) =>
    mode == PdfLayoutMode.halfPageTopBottom ||
    mode == PdfLayoutMode.halfPageLeftRight;
