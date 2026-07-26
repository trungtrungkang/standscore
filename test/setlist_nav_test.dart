import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/setlist/setlist_nav.dart';

void main() {
  group('resolveSetlistPageTurn', () {
    test('stays within current Score when target in range', () {
      final next = resolveSetlistPageTurn(
        scoreIndex: 0,
        currentPage: 2,
        delta: 1,
        pageCounts: const [4, 3],
      );
      expect(next, const SetlistNavTarget(scoreIndex: 0, pageNumber: 3));

      final prev = resolveSetlistPageTurn(
        scoreIndex: 1,
        currentPage: 2,
        delta: -1,
        pageCounts: const [4, 3],
      );
      expect(prev, const SetlistNavTarget(scoreIndex: 1, pageNumber: 1));
    });

    test('next past last page goes to next Score page 1', () {
      final target = resolveSetlistPageTurn(
        scoreIndex: 0,
        currentPage: 4,
        delta: 1,
        pageCounts: const [4, 3],
      );
      expect(target, const SetlistNavTarget(scoreIndex: 1, pageNumber: 1));
    });

    test('previous from page 1 goes to previous Score last page', () {
      final target = resolveSetlistPageTurn(
        scoreIndex: 1,
        currentPage: 1,
        delta: -1,
        pageCounts: const [4, 3],
      );
      expect(target, const SetlistNavTarget(scoreIndex: 0, pageNumber: 4));
    });

    test('returns null at setlist ends', () {
      expect(
        resolveSetlistPageTurn(
          scoreIndex: 1,
          currentPage: 3,
          delta: 1,
          pageCounts: const [4, 3],
        ),
        isNull,
      );
      expect(
        resolveSetlistPageTurn(
          scoreIndex: 0,
          currentPage: 1,
          delta: -1,
          pageCounts: const [4, 3],
        ),
        isNull,
      );
    });

    test('two-page step overshoot crosses to next Score', () {
      final target = resolveSetlistPageTurn(
        scoreIndex: 0,
        currentPage: 3,
        delta: 2,
        pageCounts: const [4, 2],
      );
      expect(target, const SetlistNavTarget(scoreIndex: 1, pageNumber: 1));
    });
  });
}
