import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/measure_map/measure_box.dart';
import 'package:stagescore/measure_map/measure_map_store.dart';

/// Fixture shaped like web `MeasureBox` in
/// `packages/shared/src/lib/daw/types.ts` (no StageScore repo dependency).
const webFixture = [
  {
    'id': 'm1',
    'pageIndex': 1,
    'measureNumber': 1,
    'systemIndex': 0,
    'x': 0.1,
    'y': 0.2,
    'width': 0.2,
    'height': 0.08,
    'timeSignature': '4/4',
    'beatSplits': [0.25, 0.5, 0.75],
  },
  {
    'id': 'm2',
    'pageIndex': 1,
    'measureNumber': 2,
    'systemIndex': 0,
    'x': 0.3,
    'y': 0.2,
    'width': 0.2,
    'height': 0.08,
    'beatSplits': [0.3, 0.6],
  },
];

void main() {
  test('web JSON → store → web JSON is lossless for shared fields', () {
    final store = MeasureMapStore()..loadWebList(webFixture);
    expect(store.boxes.length, 2);
    expect(store.boxes.first.pageNumber, 1);
    // StageScore: N interior anchors; web: N−1 boundaries.
    expect(store.boxes.first.beatSplits, evenBeatSplits(4));
    // m2 has no timeSignature → inherits 4/4; 2 web splits ≠ 3 → even 4.
    expect(store.boxes[1].beatSplits, evenBeatSplits(4));

    final encoded = store.toWebList();
    expect(encoded[0]['pageIndex'], 1);
    // Even 4/4 anchors ↔ classic web boundaries losslessly.
    expect(encoded[0]['beatSplits'], [0.25, 0.5, 0.75]);
    expect(encoded[0].containsKey('pageNumber'), isFalse);
    expect(encoded[0].containsKey('tempo'), isFalse);
    expect(encoded[0].containsKey('noteEvents'), isFalse);

    final round = MeasureMapStore()..loadWebList(encoded);
    expect(round.boxes.first.beatSplits, evenBeatSplits(4));
    expect(round.boxes.first.toWebJson()['beatSplits'], [0.25, 0.5, 0.75]);
  });

  test('StageScore box exports pageIndex for web', () {
    final box = MeasureBox(
      id: 'a',
      pageNumber: 3,
      measureNumber: 7,
      systemIndex: 1,
      x: 0.05,
      y: 0.1,
      width: 0.2,
      height: 0.05,
      tempo: 100,
      timeSignature: '3/4',
      beatSplits: evenBeatSplits(3),
    );
    final web = box.toWebJson();
    expect(web['pageIndex'], 3);
    expect(web.containsKey('tempo'), isFalse);
    final back = MeasureBox.fromWebJson(web);
    expect(back.pageNumber, 3);
    expect(back.tempo, isNull);
    expect(back.beatSplits, evenBeatSplits(3));
  });
}
