import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/measure_map/measure_map_persistence.dart';
import 'package:stagescore/measure_map/measure_map_store.dart';

void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('measure_map_persist_');
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test('load / save round-trip by scoreId', () async {
    final store = MeasureMapStore();
    store.addSystem(
      pageNumber: 1,
      x: 0,
      y: 0.1,
      width: 1,
      height: 0.1,
      measureCount: 3,
    );
    final persistence = MeasureMapPersistence(root: temp, scoreId: 'abc');
    await persistence.save(store);

    expect(await persistence.file.exists(), isTrue);
    expect(
      persistence.file.path,
      p.join(temp.path, 'measure_maps', 'abc.json'),
    );

    final loaded = MeasureMapStore();
    await MeasureMapPersistence(root: temp, scoreId: 'abc').loadInto(loaded);
    expect(loaded.boxes.length, 3);
    expect(loaded.boxes.first.measureNumber, 1);
  });

  test('missing file clears the store', () async {
    final store = MeasureMapStore();
    store.addSystem(
      pageNumber: 1,
      x: 0,
      y: 0,
      width: 1,
      height: 0.1,
      measureCount: 1,
    );
    await MeasureMapPersistence(root: temp, scoreId: 'gone').loadInto(store);
    expect(store.isEmpty, isTrue);
  });

  test('delete removes the file', () async {
    final store = MeasureMapStore();
    store.addSystem(
      pageNumber: 1,
      x: 0,
      y: 0,
      width: 1,
      height: 0.1,
      measureCount: 1,
    );
    final persistence = MeasureMapPersistence(root: temp, scoreId: 'x');
    await persistence.save(store);
    await persistence.delete();
    expect(await persistence.file.exists(), isFalse);
  });
}
