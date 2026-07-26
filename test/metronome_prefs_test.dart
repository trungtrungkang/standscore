import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/metronome/metronome_prefs.dart';
import 'package:standscore/metronome/metronome_prefs_store.dart';

void main() {
  test('beatInBar accents beat 0 for common meters', () {
    expect(MetronomePrefs.beatInBar(absoluteBeat: 0, beatsPerBar: 4), 0);
    expect(MetronomePrefs.beatInBar(absoluteBeat: 1, beatsPerBar: 4), 1);
    expect(MetronomePrefs.beatInBar(absoluteBeat: 4, beatsPerBar: 4), 0);
    expect(MetronomePrefs.isAccentBeat(0), isTrue);
    expect(MetronomePrefs.isAccentBeat(1), isFalse);
    expect(MetronomePrefs.beatInBar(absoluteBeat: 5, beatsPerBar: 3), 2);
    expect(MetronomePrefs.beatInBar(absoluteBeat: 6, beatsPerBar: 3), 0);
    expect(MetronomePrefs.beatInBar(absoluteBeat: 12, beatsPerBar: 12), 0);
    expect(MetronomePrefs.beatInBar(absoluteBeat: 9, beatsPerBar: 9), 0);
  });

  test('clamp tempo and volume', () {
    expect(MetronomePrefs.clampTempo(10), MetronomePrefs.minTempo);
    expect(MetronomePrefs.clampTempo(300), MetronomePrefs.maxTempo);
    expect(MetronomePrefs.clampVolume(1.5), 1.0);
    expect(MetronomePrefs.clampBeatUnit(8), 8);
    expect(MetronomePrefs.clampBeatUnit(16), MetronomePrefs.defaultBeatUnit);
  });

  test('beatInterval at 60 BPM is one second', () {
    expect(MetronomePrefs.beatInterval(60).inMilliseconds, 1000);
  });

  test('prefs round-trip', () async {
    final root = await Directory.systemTemp.createTemp('metronome_');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    const prefs = MetronomePrefs(
      tempoBpm: 72,
      beatsPerBar: 6,
      beatUnit: 8,
      volume: 0.45,
      muted: true,
      accentEnabled: false,
    );
    await MetronomePrefsStore(root: root).save(prefs);
    expect(await MetronomePrefsStore(root: root).load(), prefs);
  });

  test('legacy prefs default beatUnit to 4', () {
    final prefs = MetronomePrefs.fromJson({
      'tempoBpm': 100,
      'beatsPerBar': 3,
      'volume': 0.8,
      'muted': false,
      'accentEnabled': true,
    });
    expect(prefs.beatUnit, 4);
    expect(prefs.meterLabel, '3/4');
  });

  test('equal meter disables accent label', () {
    const equal = MetronomePrefs(accentEnabled: false);
    expect(equal.meterLabel.toLowerCase(), 'equal');
    expect(const MetronomePrefs().meterLabel, '4/4');
  });

  test('meter choices cover common signatures', () {
    expect(
      MetronomePrefs.meterChoices.map((m) => m.label).toList(),
      containsAll([
        '2/2',
        '3/4',
        '3/8',
        '4/4',
        '5/8',
        '6/8',
        '7/8',
        '9/8',
        '12/8',
      ]),
    );
    expect(
      const MetronomePrefs().withMeter(const MeterChoice(9, 8)).meterLabel,
      '9/8',
    );
  });
}
