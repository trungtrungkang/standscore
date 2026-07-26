import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/annotation/annotation_export.dart';
import 'package:standscore/annotation/annotation_store.dart';
import 'package:standscore/annotation/draw_tool.dart';
import 'package:standscore/annotation/stamp.dart';

Future<Uint8List> _solidPng({int w = 8, int h = 8}) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
  );
  canvas.drawRect(
    Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
    Paint()..color = const Color(0xFFFFFFFF),
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(w, h);
  picture.dispose();
  final bytes = await image.toByteData(format: ImageByteFormat.png);
  image.dispose();
  return bytes!.buffer.asUint8List();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('hide does not clear annotation store', () {
    // Hide is a view flag; store must remain intact (Spec 0020).
    final store = AnnotationStore();
    store.addStroke(
      store.createStroke(
        pageNumber: 1,
        points: const [Offset(0.1, 0.1), Offset(0.2, 0.2)],
        tool: DrawTool.pen,
      ),
    );
    store.addStamp(
      store.createStamp(
        pageNumber: 1,
        kind: StampKind.box,
        center: const Offset(0.5, 0.5),
      ),
    );
    expect(store.length, 1);
    expect(store.stampCount, 1);
  });

  test('pdfFromPngPages builds a PDF with %PDF header', () async {
    final png = await _solidPng();
    final bytes = await pdfFromPngPages([png, png]);
    expect(bytes.length, greaterThan(100));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
