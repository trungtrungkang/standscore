import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/pageturn/page_turn_delay.dart';

void main() {
  group('PageTurnDelayGate', () {
    final t0 = DateTime.utc(2026, 7, 26, 12);

    test('delay Off allows rapid inputs', () {
      final gate = PageTurnDelayGate();
      expect(
        gate.allow(
          now: t0,
          kind: PageTurnInputKind.pedal,
          delay: Duration.zero,
          scope: PageTurnDelayScope.all,
        ),
        isTrue,
      );
      gate.lockAfterSuccess(
        now: t0,
        kind: PageTurnInputKind.pedal,
        delay: Duration.zero,
        scope: PageTurnDelayScope.all,
      );
      expect(
        gate.allow(
          now: t0.add(const Duration(milliseconds: 1)),
          kind: PageTurnInputKind.pedal,
          delay: Duration.zero,
          scope: PageTurnDelayScope.all,
        ),
        isTrue,
      );
    });

    test('blocks second input within delay window', () {
      final gate = PageTurnDelayGate();
      const delay = Duration(milliseconds: 500);
      expect(
        gate.allow(
          now: t0,
          kind: PageTurnInputKind.tap,
          delay: delay,
          scope: PageTurnDelayScope.all,
        ),
        isTrue,
      );
      gate.lockAfterSuccess(
        now: t0,
        kind: PageTurnInputKind.tap,
        delay: delay,
        scope: PageTurnDelayScope.all,
      );
      expect(
        gate.allow(
          now: t0.add(const Duration(milliseconds: 200)),
          kind: PageTurnInputKind.swipe,
          delay: delay,
          scope: PageTurnDelayScope.all,
        ),
        isFalse,
      );
      expect(
        gate.allow(
          now: t0.add(const Duration(milliseconds: 500)),
          kind: PageTurnInputKind.pedal,
          delay: delay,
          scope: PageTurnDelayScope.all,
        ),
        isTrue,
      );
    });

    test('pedalOnly gates pedal but not tap/swipe', () {
      final gate = PageTurnDelayGate();
      const delay = Duration(milliseconds: 500);
      gate.lockAfterSuccess(
        now: t0,
        kind: PageTurnInputKind.pedal,
        delay: delay,
        scope: PageTurnDelayScope.pedalOnly,
      );
      expect(
        gate.allow(
          now: t0.add(const Duration(milliseconds: 100)),
          kind: PageTurnInputKind.pedal,
          delay: delay,
          scope: PageTurnDelayScope.pedalOnly,
        ),
        isFalse,
      );
      expect(
        gate.allow(
          now: t0.add(const Duration(milliseconds: 100)),
          kind: PageTurnInputKind.tap,
          delay: delay,
          scope: PageTurnDelayScope.pedalOnly,
        ),
        isTrue,
      );
      expect(
        gate.allow(
          now: t0.add(const Duration(milliseconds: 100)),
          kind: PageTurnInputKind.swipe,
          delay: delay,
          scope: PageTurnDelayScope.pedalOnly,
        ),
        isTrue,
      );
    });

    test('pedalOnly: tap success does not arm pedal lockout', () {
      final gate = PageTurnDelayGate();
      const delay = Duration(milliseconds: 500);
      gate.lockAfterSuccess(
        now: t0,
        kind: PageTurnInputKind.tap,
        delay: delay,
        scope: PageTurnDelayScope.pedalOnly,
      );
      expect(
        gate.allow(
          now: t0.add(const Duration(milliseconds: 50)),
          kind: PageTurnInputKind.pedal,
          delay: delay,
          scope: PageTurnDelayScope.pedalOnly,
        ),
        isTrue,
      );
    });
  });

  test('PageTurnDelayPreset.fromMilliseconds', () {
    expect(PageTurnDelayPreset.fromMilliseconds(null), PageTurnDelayPreset.off);
    expect(PageTurnDelayPreset.fromMilliseconds(0), PageTurnDelayPreset.off);
    expect(
      PageTurnDelayPreset.fromMilliseconds(500),
      PageTurnDelayPreset.ms500,
    );
  });
}
