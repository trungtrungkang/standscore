import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/setlist/setlist.dart';

void main() {
  group('Setlist mutate', () {
    test('addScore / removeAt / move / rename', () {
      final created = DateTime.utc(2026, 7, 26);
      var list = Setlist(
        id: 'sl1',
        title: 'Gig',
        scoreIds: const [],
        createdAt: created,
      );

      list = list.addScore('a').addScore('b').addScore('c');
      expect(list.scoreIds, ['a', 'b', 'c']);

      list = list.move(0, 2);
      expect(list.scoreIds, ['b', 'c', 'a']);

      list = list.removeAt(1);
      expect(list.scoreIds, ['b', 'a']);

      list = list.rename('Encore');
      expect(list.title, 'Encore');
      expect(list.id, 'sl1');
    });

    test(
      'addScore ignores empty id and duplicate adjacent? allows same score twice',
      () {
        final list = Setlist(
          id: 'sl1',
          title: 'Gig',
          scoreIds: const ['a'],
          createdAt: DateTime.utc(2026, 7, 26),
        ).addScore('a');
        // Same Score may appear twice (encore) — ScorePDF-style ordered refs.
        expect(list.scoreIds, ['a', 'a']);
        expect(list.addScore('').scoreIds, ['a', 'a']);
      },
    );

    test('json round-trip', () {
      final list = Setlist(
        id: 'sl1',
        title: 'Gig',
        scoreIds: const ['a', 'b'],
        createdAt: DateTime.utc(2026, 7, 26, 1, 2, 3),
        lastOpenedAt: DateTime.utc(2026, 7, 26, 4, 5, 6),
      );
      final restored = Setlist.fromJson(list.toJson());
      expect(restored.id, list.id);
      expect(restored.title, list.title);
      expect(restored.scoreIds, list.scoreIds);
      expect(restored.createdAt, list.createdAt);
      expect(restored.lastOpenedAt, list.lastOpenedAt);
    });
  });
}
