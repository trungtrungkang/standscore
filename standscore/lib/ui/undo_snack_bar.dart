import 'package:flutter/material.dart';

/// Says what just changed and offers to put it back (Spec 0036).
///
/// `persist` is set explicitly because its default is `action != null`: in
/// Flutter 3.44 any snackbar carrying an action stays up until something else
/// replaces it. On a music stand that is the wrong trade twice over — it sits
/// across the bottom of the Score, and it sits exactly where the PageTurn tap
/// zone lives once the chrome is hidden (0034). Undo here is a convenience
/// with a short window, not a decision waiting on the musician, so it times
/// out like any other message.
SnackBar undoSnackBar({required String message, required VoidCallback onUndo}) {
  return SnackBar(
    content: Text(message),
    persist: false,
    action: SnackBarAction(label: 'Undo', onPressed: onUndo),
  );
}
