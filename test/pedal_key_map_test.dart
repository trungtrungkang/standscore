import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/pageturn/page_turn_prefs.dart';
import 'package:standscore/pageturn/pedal_key_map.dart';

void main() {
  test('maps ScorePDF previous keys', () {
    for (final key in [
      LogicalKeyboardKey.pageUp,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.space,
    ]) {
      expect(resolvePedalKeyAction(key), PageTurnAction.previous, reason: '$key');
    }
  });

  test('maps ScorePDF next keys', () {
    for (final key in [
      LogicalKeyboardKey.pageDown,
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.enter,
      LogicalKeyboardKey.numpadEnter,
    ]) {
      expect(resolvePedalKeyAction(key), PageTurnAction.next, reason: '$key');
    }
  });

  test('ignores unrelated keys', () {
    expect(resolvePedalKeyAction(LogicalKeyboardKey.keyA), isNull);
    expect(resolvePedalKeyAction(LogicalKeyboardKey.home), isNull);
  });
}
