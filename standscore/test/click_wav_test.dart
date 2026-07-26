import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/metronome/click_wav.dart';

void main() {
  test('loop length matches tempo and beats', () {
    const tempo = 60;
    const beats = 4;
    final wav = synthesizeMetronomeLoopWav(
      tempoBpm: tempo,
      beatsPerBar: beats,
      accentEnabled: true,
    );
    // 44-byte header + 16-bit mono PCM
    final pcmBytes = wav.length - 44;
    final samples = pcmBytes ~/ 2;
    final expected = metronomeSampleRate * beats; // 60 BPM → 1s/beat
    expect(samples, expected);
    expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF');
  });

  test('equal meter loop is one beat long', () {
    final wav = synthesizeMetronomeLoopWav(
      tempoBpm: 120,
      beatsPerBar: 4,
      accentEnabled: false,
    );
    final samples = (wav.length - 44) ~/ 2;
    expect(samples, metronomeSampleRate ~/ 2); // 0.5s at 120 BPM
  });

  test('loop contains energy near beat starts', () {
    final wav = synthesizeMetronomeLoopWav(
      tempoBpm: 60,
      beatsPerBar: 2,
      accentEnabled: true,
    );
    final pcm = ByteData.sublistView(wav, 44);
    int energyNear(int sample) {
      var sum = 0;
      for (var i = 0; i < 200; i++) {
        final idx = (sample + i) * 2;
        if (idx + 1 >= pcm.lengthInBytes) break;
        sum += pcm.getInt16(idx, Endian.little).abs();
      }
      return sum;
    }

    expect(energyNear(0), greaterThan(0));
    expect(energyNear(metronomeSampleRate), greaterThan(0));
    // Mid-beat silence should be quieter than the click onset.
    expect(energyNear(metronomeSampleRate ~/ 2), lessThan(energyNear(0)));
  });
}
