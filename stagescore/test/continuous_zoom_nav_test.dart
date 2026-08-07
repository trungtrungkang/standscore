import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/pdf/continuous_zoom_nav.dart';

void main() {
  test('pageTopFocus centres the page and puts its top at the viewport top', () {
    const page = Rect.fromLTWH(0, 100, 200, 400);
    const view = Size(100, 200);
    const zoom = 2.0;

    final focus = pageTopFocus(pageRect: page, viewSize: view, zoom: zoom);

    // Horizontal centre of the page.
    expect(focus.dx, 100);
    // Half the viewport in document units below the page top → top edge
    // sits on the top of the view when calcMatrixFor centres on [focus].
    expect(focus.dy, 100 + 200 / (2 * 2.0));
  });

  test('pageTopFocus scales the vertical offset with zoom', () {
    const page = Rect.fromLTWH(10, 0, 80, 300);
    const view = Size(80, 160);

    final atFit = pageTopFocus(pageRect: page, viewSize: view, zoom: 1.0);
    final pinched = pageTopFocus(pageRect: page, viewSize: view, zoom: 2.0);

    expect(atFit.dx, pinched.dx);
    expect(atFit.dy, 80); // 0 + 160/2
    expect(pinched.dy, 40); // 0 + 160/4 — closer to the page top when zoomed
  });
}
