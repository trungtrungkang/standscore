import 'dart:async';

import 'package:flutter/foundation.dart';

/// PerformanceMode chrome timings (Spec 0034).
const Duration kChromeAutoHideDelay = Duration(seconds: 5);
const Duration kChromeFadeDuration = Duration(milliseconds: 180);

/// Reveal / auto-hide state for the PdfMode AppBar + PageNavBar (Spec 0034).
///
/// Chrome is hidden only while PerformanceMode is on and the user is not
/// drawing. A reveal lasts [autoHideDelay], except while [isPinned] reports a
/// menu, sheet or dialog opened from the chrome is still on screen.
class PerformanceChrome extends ChangeNotifier {
  PerformanceChrome({
    this.autoHideDelay = kChromeAutoHideDelay,
    bool Function()? isPinned,
  }) : _isPinned = isPinned ?? _neverPinned;

  final Duration autoHideDelay;
  final bool Function() _isPinned;

  bool _enabled = false;
  bool _drawing = false;
  bool _revealed = false;
  Timer? _timer;

  static bool _neverPinned() => false;

  /// PerformanceMode is on and not suspended by Draw mode.
  bool get active => _enabled && !_drawing;

  /// True when the AppBar and PageNavBar should be visible.
  bool get shown => !active || _revealed;

  /// [keepChromeUp] leaves the chrome visible so the user sees what the
  /// preference changed; pass false when restoring saved prefs on open.
  void setPerformanceMode(bool enabled, {bool keepChromeUp = true}) {
    if (_enabled == enabled) return;
    _enabled = enabled;
    _revealed = keepChromeUp;
    _restart();
    notifyListeners();
  }

  /// Draw mode pins the chrome (the DrawToolbar must stay); leaving Draw
  /// returns to the hidden state.
  void setDrawing(bool drawing) {
    if (_drawing == drawing) return;
    _drawing = drawing;
    _revealed = false;
    _cancel();
    notifyListeners();
  }

  void reveal() {
    if (!active || _revealed) return;
    _revealed = true;
    _restart();
    notifyListeners();
  }

  void hide() {
    _cancel();
    if (!_revealed) return;
    _revealed = false;
    notifyListeners();
  }

  /// Interaction with visible chrome — restart the countdown.
  void keepAlive() {
    if (active && _revealed) _restart();
  }

  void _restart() {
    _cancel();
    if (!active || !_revealed) return;
    _timer = Timer(autoHideDelay, _onTimeout);
  }

  void _onTimeout() {
    _timer = null;
    if (_isPinned()) {
      _restart();
      return;
    }
    hide();
  }

  void _cancel() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }
}
