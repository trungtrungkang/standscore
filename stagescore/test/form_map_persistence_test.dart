import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/form_map/form_map.dart';
import 'package:stagescore/form_map/form_map_persistence.dart';
import 'package:stagescore/form_map/form_map_store.dart';

void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('form_map_');
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test('round-trip save / load', () async {
    final store = FormMapStore();
    store.setForm(
      FormMap(
        repeats: const [
          FormRepeatRegion(
            id: 'r1',
            startMeasure: 1,
            endMeasure: 4,
            times: 3,
          ),
        ],
        endings: const [
          FormEnding(
            id: 'e1',
            startMeasure: 3,
            endMeasure: 3,
            endingNumber: 1,
          ),
        ],
        markers: const [
          FormMarker(id: 's', measure: 2, kind: FormMarkerKind.segno),
        ],
        jumps: const [
          FormJump(id: 'dc', measure: 8, kind: FormJumpKind.daCapo),
        ],
      ),
    );

    final persistence = FormMapPersistence(root: temp, scoreId: 'abc');
    await persistence.save(store);

    expect(
      persistence.file.path,
      p.join(temp.path, 'form_maps', 'abc.json'),
    );

    final loaded = FormMapStore();
    await persistence.loadInto(loaded);
    expect(loaded.form, store.form);
  });

  test('missing file → empty FormMap', () async {
    final persistence = FormMapPersistence(root: temp, scoreId: 'missing');
    final store = FormMapStore()
      ..setForm(
        FormMap(
          markers: const [
            FormMarker(id: 's', measure: 1, kind: FormMarkerKind.segno),
          ],
        ),
      );
    await persistence.loadInto(store);
    expect(store.isEmpty, isTrue);
  });
}
