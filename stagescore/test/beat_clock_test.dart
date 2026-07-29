import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/metronome/beat_clock.dart';
import 'package:stagescore/metronome/click_wav.dart';

void main() {
  // 120 BPM: exactly 500 ms per beat, so the arithmetic stays readable.
  const interval = Duration(milliseconds: 500);

  int beatAt(int ms, {int beatsPerBar = 4}) => beatInBarFromLoopPosition(
    position: Duration(milliseconds: ms),
    beatInterval: interval,
    beatsPerBar: beatsPerBar,
  );

  group('beatInBarFromLoopPosition', () {
    test('the play head maps to the beat that is sounding', () {
      expect(beatAt(0), 0);
      expect(beatAt(499), 0, reason: 'still inside beat 1');
      expect(beatAt(500), 1);
      expect(beatAt(1000), 2);
      expect(beatAt(1999), 3);
    });

    test('the bar wraps back to the accent', () {
      expect(beatAt(2000), 0, reason: 'one bar of 4/4 at 120 BPM');
      expect(beatAt(2500), 1);
    });

    test('a play head that accumulates across repeats still lands', () {
      // The plugin does not promise whether the reported position wraps at the
      // loop end or keeps counting. Reducing modulo the bar covers both, and
      // this is the case that would drift if it did not.
      expect(beatAt(2000 * 50), 0, reason: '50 bars in');
      expect(beatAt(2000 * 50 + 1500), 3);
    });

    test('reading late gives the current beat, not the next one', () {
      // Statelessness is the point: a dropped frame must not shift the count.
      expect(beatAt(1200), 2);
      expect(beatAt(1300), 2, reason: 'a 100 ms stall does not advance a beat');
    });

    test('a position before the loop start still lands inside the bar', () {
      expect(
        beatInBarFromLoopPosition(
          position: const Duration(milliseconds: -1),
          beatInterval: interval,
          beatsPerBar: 4,
        ),
        3,
      );
    });

    test('meters other than 4/4 wrap on their own bar', () {
      expect(beatAt(1000, beatsPerBar: 3), 2);
      expect(beatAt(1500, beatsPerBar: 3), 0);
      expect(beatAt(500, beatsPerBar: 1), 0, reason: 'one beat per bar');
      expect(beatAt(5500, beatsPerBar: 12), 11);
    });

    test('a nonsensical interval reports the downbeat instead of dividing', () {
      expect(
        beatInBarFromLoopPosition(
          position: const Duration(milliseconds: 400),
          beatInterval: Duration.zero,
          beatsPerBar: 4,
        ),
        0,
      );
    });
  });

  group('the clock and the buffer agree', () {
    // The invariant that keeps a dot on its click: the beat length the clock
    // divides by must be the beat length the buffer was written with. If these
    // drift apart, a play head that accumulates walks the dots off the beat.
    for (final bpm in [40, 60, 100, 120, 218]) {
      test('$bpm BPM: bar length matches the generated loop', () {
        const beats = 4;
        final wav = synthesizeMetronomeLoopWav(
          tempoBpm: bpm,
          beatsPerBar: beats,
          accentEnabled: true,
        );
        final samples = (wav.length - 44) ~/ 2;
        final audioInterval = metronomeAudioBeatInterval(tempoBpm: bpm);
        expect(
          samples,
          metronomeSamplesPerBeat(tempoBpm: bpm) * beats,
          reason: 'loop spans the bar',
        );
        // Same quantity expressed two ways, within the rounding to whole µs.
        final barFromSamples = samples / metronomeSampleRate * 1000000;
        final barFromClock = audioInterval.inMicroseconds * beats;
        expect((barFromSamples - barFromClock).abs(), lessThan(beats + 1));
      });
    }

    test('the last beat of the loop never reads as the first of the next', () {
      // One sample short of the bar must still be the final beat, or the dots
      // flick to the downbeat early once per bar.
      const bpm = 218;
      const beats = 7;
      final interval = metronomeAudioBeatInterval(tempoBpm: bpm);
      final barUs = interval.inMicroseconds * beats;
      expect(
        beatInBarFromLoopPosition(
          position: Duration(microseconds: barUs - 1),
          beatInterval: interval,
          beatsPerBar: beats,
        ),
        beats - 1,
      );
    });
  });
}
