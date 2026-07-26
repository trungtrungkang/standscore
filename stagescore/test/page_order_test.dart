import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/pageorder/page_order.dart';
import 'package:stagescore/pageorder/page_order_store.dart';

void main() {
  group('PageOrder', () {
    test('identity and isIdentity', () {
      final order = PageOrder.identity(3);
      expect(order.length, 3);
      expect(order.isIdentity, isTrue);
      expect(order.entries.map((e) => e.sourcePage), [1, 2, 3]);
    });

    test('move / duplicate / remove / insertBlank / reset', () {
      var order = PageOrder.identity(3);
      order = order.move(0, 2);
      expect(order.entries.map((e) => e.sourcePage), [2, 3, 1]);
      expect(order.isIdentity, isFalse);

      order = order.duplicate(0);
      expect(order.entries.map((e) => e.sourcePage), [2, 2, 3, 1]);

      order = order.insertBlank(1);
      expect(order.entries[1].isBlank, isTrue);
      expect(order.length, 5);

      order = order.removeAt(1);
      expect(order.entries.map((e) => e.isBlank ? null : e.sourcePage), [
        2,
        2,
        3,
        1,
      ]);

      order = order.resetToOriginal();
      expect(order.isIdentity, isTrue);
      expect(order.length, 3);
    });

    test('remove refuses empty sequence', () {
      final order = PageOrder.identity(1);
      expect(order.removeAt(0).length, 1);
    });

    test('json round-trip', () {
      final order = PageOrder.identity(2).duplicate(0).insertBlank(1);
      final restored = PageOrder.fromJson(order.toJson());
      expect(restored.entries, order.entries);
      expect(restored.sourcePageCount, 2);
    });
  });

  test('PageOrderStore loadOrIdentity and save', () async {
    final root = await Directory.systemTemp.createTemp('page_order_');
    addTearDown(() => root.delete(recursive: true));
    final store = PageOrderStore(root: root, scoreId: 's1');

    final initial = await store.loadOrIdentity(2);
    expect(initial.isIdentity, isTrue);

    final custom = initial.duplicate(0);
    await store.save(custom);
    expect(
      File(p.join(root.path, 'page_orders', 's1.json')).existsSync(),
      isTrue,
    );

    final loaded = await store.loadOrIdentity(2);
    expect(loaded.length, 3);
    expect(loaded.isIdentity, isFalse);
  });
}
