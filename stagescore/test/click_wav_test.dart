import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/metronome/click_wav.dart';

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

  test('equal meter loop still spans the bar', () {
    // It used to be one beat long, which sounds identical but made the play
    // head a position within a *beat* rather than within the bar — so the beat
    // clock needed a second mapping for this mode. Spending the extra samples
    // buys one mapping for every meter (Spec 0030, second reopen).
    final wav = synthesizeMetronomeLoopWav(
      tempoBpm: 120,
      beatsPerBar: 4,
      accentEnabled: false,
    );
    final samples = (wav.length - 44) ~/ 2;
    expect(samples, metronomeSampleRate * 2); // 4 beats × 0.5s at 120 BPM
  });

  test('equal meter clicks are all the same, unlike an accented bar', () {
    int onsetPeak(Uint8List wav, int beat, int samplesPerBeat) {
      final pcm = ByteData.sublistView(wav, 44);
      var peak = 0;
      for (var i = 0; i < 400; i++) {
        final idx = (beat * samplesPerBeat + i) * 2;
        if (idx + 1 >= pcm.lengthInBytes) break;
        final s = pcm.getInt16(idx, Endian.little).abs();
        if (s > peak) peak = s;
      }
      return peak;
    }

    const bpm = 120;
    final samplesPerBeat = metronomeSamplesPerBeat(tempoBpm: bpm);
    final equal = synthesizeMetronomeLoopWav(
      tempoBpm: bpm,
      beatsPerBar: 4,
      accentEnabled: false,
    );
    for (var beat = 1; beat < 4; beat++) {
      expect(
        onsetPeak(equal, beat, samplesPerBeat),
        onsetPeak(equal, 0, samplesPerBeat),
        reason: 'beat $beat should be indistinguishable from the first',
      );
    }
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
