import 'package:flutter/services.dart';
import 'package:standscore/pageturn/page_turn_prefs.dart';

/// ScorePDF-compatible HID / keyboard pedal mapping.
PageTurnAction? resolvePedalKeyAction(LogicalKeyboardKey key) {
  switch (key) {
    case LogicalKeyboardKey.pageUp:
    case LogicalKeyboardKey.arrowLeft:
    case LogicalKeyboardKey.arrowUp:
    case LogicalKeyboardKey.space:
      return PageTurnAction.previous;
    case LogicalKeyboardKey.pageDown:
    case LogicalKeyboardKey.arrowRight:
    case LogicalKeyboardKey.arrowDown:
    case LogicalKeyboardKey.enter:
    case LogicalKeyboardKey.numpadEnter:
      return PageTurnAction.next;
    default:
      return null;
  }
}
