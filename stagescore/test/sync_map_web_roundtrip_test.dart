import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/sync_map/sync_map_entry.dart';

void main() {
  test('TimemapEntry subset survives encode → decode', () {
    const entry = SyncMapEntry(
      timeMs: 500,
      measure: 2,
      beatTimestamps: [500, 1000, 1500, 2000],
      timeSignature: '4/4',
      tempo: 120,
      durationInQuarters: 4,
      startsAtBeat: 0,
    );
    final round = SyncMapEntry.fromWebJson(entry.toWebJson());
    expect(round, entry);
    expect(round.toWebJson().containsKey('startsAtBeat'), isFalse);
  });

  test('startsAtBeat round-trips when > 0', () {
    const entry = SyncMapEntry(
      timeMs: 0,
      measure: 1,
      beatTimestamps: [0],
      timeSignature: '4/4',
      tempo: 120,
      durationInQuarters: 1,
      startsAtBeat: 3,
    );
    final json = entry.toWebJson();
    expect(json['startsAtBeat'], 3);
    expect(SyncMapEntry.fromWebJson(json), entry);
  });

  test('SyncMap list round-trip', () {
    final map = SyncMap([
      const SyncMapEntry(
        timeMs: 0,
        measure: 1,
        beatTimestamps: [0, 500],
        timeSignature: '2/4',
        tempo: 120,
        durationInQuarters: 2,
      ),
      const SyncMapEntry(
        timeMs: 1000,
        measure: 2,
        beatTimestamps: [1000, 1500, 2000, 2500],
        timeSignature: '4/4',
        tempo: 120,
        durationInQuarters: 4,
      ),
    ]);
    expect(SyncMap.fromWebList(map.toWebList()), map);
  });
}
