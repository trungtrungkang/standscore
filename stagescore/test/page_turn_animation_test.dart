import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/pageturn/page_turn_animation.dart';

void main() {
  test('durations are ordered Fast < Normal < Slow; Off is zero', () {
    expect(PageTurnAnimationPreset.off.duration, Duration.zero);
    expect(
      PageTurnAnimationPreset.fast.duration <
          PageTurnAnimationPreset.normal.duration,
      isTrue,
    );
    expect(
      PageTurnAnimationPreset.normal.duration <
          PageTurnAnimationPreset.slow.duration,
      isTrue,
    );
  });

  test('fromName defaults to normal', () {
    expect(
      PageTurnAnimationPreset.fromName(null),
      PageTurnAnimationPreset.normal,
    );
    expect(
      PageTurnAnimationPreset.fromName('bogus'),
      PageTurnAnimationPreset.normal,
    );
    expect(
      PageTurnAnimationPreset.fromName('slow'),
      PageTurnAnimationPreset.slow,
    );
  });
}
