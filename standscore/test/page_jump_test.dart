import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/pageturn/page_jump.dart';

void main() {
  group('parsePageNumber', () {
    test('parses integers', () {
      expect(parsePageNumber('12'), 12);
      expect(parsePageNumber(' 3 '), 3);
    });

    test('rejects empty and non-integers', () {
      expect(parsePageNumber(''), isNull);
      expect(parsePageNumber('  '), isNull);
      expect(parsePageNumber('1.5'), isNull);
      expect(parsePageNumber('ab'), isNull);
    });
  });

  group('clampPageNumber', () {
    test('clamps into range', () {
      expect(clampPageNumber(0, 10), 1);
      expect(clampPageNumber(1, 10), 1);
      expect(clampPageNumber(10, 10), 10);
      expect(clampPageNumber(99, 10), 10);
    });

    test('empty document defaults to 1', () {
      expect(clampPageNumber(5, 0), 1);
    });
  });
}
