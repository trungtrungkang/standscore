import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/annotation/annotation_store.dart';

void main() {
  test('AnnotationStore is available for PdfMode spike', () {
    expect(AnnotationStore().length, 0);
  });
}
