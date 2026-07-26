import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/ui/performance_chrome.dart';

/// Short auto-hide so tests do not wait out the 5 s stage default.
const _delay = Duration(milliseconds: 20);

PerformanceChrome _chrome({bool Function()? isPinned}) {
  final chrome = PerformanceChrome(autoHideDelay: _delay, isPinned: isPinned);
  addTearDown(chrome.dispose);
  return chrome;
}

Future<void> _pastAutoHide() => Future<void>.delayed(_delay * 3);

void main() {
  test('chrome stays shown while PerformanceMode is off', () async {
    final chrome = _chrome();

    expect(chrome.active, isFalse);
    expect(chrome.shown, isTrue);
    chrome.hide();
    await _pastAutoHide();
    expect(chrome.shown, isTrue);
  });

  test('turning PerformanceMode on keeps chrome up, then hides it', () async {
    final chrome = _chrome();

    chrome.setPerformanceMode(true);
    expect(chrome.active, isTrue);
    expect(chrome.shown, isTrue);

    await _pastAutoHide();
    expect(chrome.shown, isFalse);
  });

  test('restoring saved prefs opens hidden', () {
    final chrome = _chrome();

    chrome.setPerformanceMode(true, keepChromeUp: false);
    expect(chrome.shown, isFalse);
  });

  test('reveal hides again after the delay', () async {
    final chrome = _chrome();
    chrome.setPerformanceMode(true, keepChromeUp: false);

    chrome.reveal();
    expect(chrome.shown, isTrue);

    await _pastAutoHide();
    expect(chrome.shown, isFalse);
  });

  test('keepAlive restarts the countdown', () async {
    final chrome = _chrome();
    chrome.setPerformanceMode(true, keepChromeUp: false);
    chrome.reveal();

    for (var i = 0; i < 4; i++) {
      await Future<void>.delayed(_delay ~/ 2);
      chrome.keepAlive();
      expect(chrome.shown, isTrue);
    }

    await _pastAutoHide();
    expect(chrome.shown, isFalse);
  });

  test('stays shown while pinned by an open menu or sheet', () async {
    var pinned = true;
    final chrome = _chrome(isPinned: () => pinned);
    chrome.setPerformanceMode(true, keepChromeUp: false);
    chrome.reveal();

    await _pastAutoHide();
    expect(chrome.shown, isTrue);

    pinned = false;
    await _pastAutoHide();
    expect(chrome.shown, isFalse);
  });

  test('Draw mode pins chrome and exiting Draw hides it', () async {
    final chrome = _chrome();
    chrome.setPerformanceMode(true, keepChromeUp: false);

    chrome.setDrawing(true);
    expect(chrome.active, isFalse, reason: 'PerformanceMode suspended');
    expect(chrome.shown, isTrue);
    await _pastAutoHide();
    expect(chrome.shown, isTrue);

    chrome.setDrawing(false);
    expect(chrome.shown, isFalse);
  });

  test('PageTurn hides revealed chrome immediately', () {
    final chrome = _chrome();
    chrome.setPerformanceMode(true, keepChromeUp: false);
    chrome.reveal();

    chrome.hide();
    expect(chrome.shown, isFalse);
  });

  test('turning PerformanceMode off shows chrome again', () {
    final chrome = _chrome();

    chrome.setPerformanceMode(true, keepChromeUp: false);
    expect(chrome.shown, isFalse);

    chrome.setPerformanceMode(false);
    expect(chrome.active, isFalse);
    expect(chrome.shown, isTrue);
  });

  test('notifies listeners on reveal and hide', () {
    final chrome = _chrome();
    var notifications = 0;
    chrome.addListener(() => notifications++);

    chrome.setPerformanceMode(true, keepChromeUp: false);
    chrome.reveal();
    chrome.hide();
    expect(notifications, 3);
  });
}
