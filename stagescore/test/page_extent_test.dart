import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/library/page_extent.dart';

void main() {
  group('PageExtent', () {
    test('length counts both ends', () {
      expect(const PageExtent(firstPage: 12, lastPage: 19).length, 8);
      expect(const PageExtent(firstPage: 5, lastPage: 5).length, 1);
    });

    test('whole document starts at page 1', () {
      expect(PageExtent.whole(200), const PageExtent(firstPage: 1, lastPage: 200));
    });

    test('contains is inclusive at both ends', () {
      const extent = PageExtent(firstPage: 12, lastPage: 19);
      expect(extent.contains(11), isFalse);
      expect(extent.contains(12), isTrue);
      expect(extent.contains(19), isTrue);
      expect(extent.contains(20), isFalse);
    });

    test('converts absolute page to page-within-piece and back', () {
      const extent = PageExtent(firstPage: 12, lastPage: 19);
      expect(extent.toRelative(12), 1);
      expect(extent.toRelative(19), 8);
      expect(extent.toAbsolute(1), 12);
      expect(extent.toAbsolute(8), 19);
    });

    test('conversion round-trips across the whole extent', () {
      const extent = PageExtent(firstPage: 12, lastPage: 19);
      for (var page = extent.firstPage; page <= extent.lastPage; page++) {
        expect(extent.toAbsolute(extent.toRelative(page)!), page);
      }
    });

    test('conversion refuses pages outside the piece', () {
      const extent = PageExtent(firstPage: 12, lastPage: 19);
      expect(extent.toRelative(11), isNull);
      expect(extent.toRelative(20), isNull);
      expect(extent.toAbsolute(0), isNull);
      expect(extent.toAbsolute(9), isNull);
    });

    test('a shorter file truncates an extent, or invalidates it entirely', () {
      const extent = PageExtent(firstPage: 12, lastPage: 19);
      expect(extent.clampedTo(200), extent);
      expect(
        extent.clampedTo(15),
        const PageExtent(firstPage: 12, lastPage: 15),
      );
      // Replace PDF with a file shorter than the extent's start leaves nothing
      // to show, and Spec 0052 requires reporting that rather than repairing it.
      expect(extent.clampedTo(8), isNull);
      expect(extent.clampedTo(0), isNull);
    });

    test('an extent with lastPage before firstPage is invalid', () {
      expect(const PageExtent(firstPage: 5, lastPage: 4).isValid, isFalse);
      expect(const PageExtent(firstPage: 0, lastPage: 3).isValid, isFalse);
      expect(const PageExtent(firstPage: 1, lastPage: 1).isValid, isTrue);
    });

    test('survives a JSON round trip', () {
      const extent = PageExtent(firstPage: 12, lastPage: 19);
      expect(PageExtent.fromJson(extent.toJson()), extent);
    });
  });
}
