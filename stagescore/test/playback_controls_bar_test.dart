import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/ui/playback_controls_bar.dart';

void main() {
  test('formatPlaybackTime is m:ss from milliseconds', () {
    expect(formatPlaybackTime(0), '0:00');
    expect(formatPlaybackTime(1500), '0:01');
    expect(formatPlaybackTime(60 * 1000), '1:00');
    expect(formatPlaybackTime(125 * 1000), '2:05');
  });

  test('formatCountInRemaining is measures.beat (1-based beat)', () {
    expect(
      formatCountInRemaining((measures: 2, beats: 4, beatsPerBar: 4)),
      '2.4',
    );
    expect(
      formatCountInRemaining((measures: 1, beats: 1, beatsPerBar: 4)),
      '1.1',
    );
  });

  test('formatMeasureBeat is measure.beat', () {
    expect(formatMeasureBeat(12, 3), '12.3');
  });

  test('beat badge width sample covers three-digit measure', () {
    expect(kPlaybackBeatBadgeWidthSample.length, greaterThanOrEqualTo(5));
    expect(kPlaybackBeatBadgeWidthSample, contains('.'));
  });
}
