import 'package:flutter/material.dart';
import 'package:stagescore/pdf/zoom_toggle.dart';

/// Pinch/pan transform shared across the pages of a reading order.
///
/// Double-tap zoom was cut (post-0043 follow-up): pairing it with tap on the
/// same `GestureDetector` forced Flutter's gesture arena to hold every tap
/// for `kDoubleTapTimeout` before firing PageTurn. Pinch is now the only zoom
/// gesture, and — separately requested the same week — the *whole* view a
/// musician sets up on one page follows them to the next, not just the scale:
/// a scan with a wide left margin and a narrow right one is worth panning
/// past once, not on every page. `SinglePageSlider` and
/// `ContinuousPageOrderView` (which now also draws the Half Page layouts,
/// Spec 0056) each keep one `TransformationController` per page, so nothing
/// shares state between them unless something does it on purpose. Both call
/// these free functions identically; kept here, once, so they cannot drift
/// and so this logic is unit-testable without a real `PdfDocument` (pdfrx
/// needs the native viewer, which `flutter test` cannot provide — see
/// `pdf_mode_chrome_layout_test.dart`).

/// The transform to remember once a pinch/pan gesture settles at [value] —
/// `null` once back at fit (no meaningful zoom), so the next page opens at
/// fit too instead of carrying a stale pan nobody asked for.
Matrix4? nextSharedZoomTransform(Matrix4 value) {
  if (!isInteractivelyZoomed(value)) return null;
  return value.clone();
}

/// True if [next] is a meaningfully different transform than [current] —
/// ignores sub-percent float drift from `InteractiveViewer` settling, so
/// that does not retrigger a sync onto every other page for no visible
/// change.
bool sharedZoomTransformChanged(Matrix4? current, Matrix4? next) {
  if (current == null || next == null) return current != next;
  final a = current.storage;
  final b = next.storage;
  for (var i = 0; i < a.length; i++) {
    if ((a[i] - b[i]).abs() >= 0.005) return true;
  }
  return false;
}

/// The matrix a page's `TransformationController` should carry for the
/// shared [transform] — identity (fit) when `null`. Always a fresh copy: two
/// controllers must never share one mutable `Matrix4` instance.
Matrix4 sharedZoomMatrix(Matrix4? transform) =>
    transform == null ? Matrix4.identity() : transform.clone();

/// How long a page's transform must sit still before it is shared with the
/// rest of the reading order.
///
/// `InteractiveViewer.onInteractionEnd` fires the instant fingers lift, but
/// documents its own caveat: "a pan may cause an inertia animation after
/// this is called as well" — `_handleInertiaAnimation` keeps writing to the
/// same `TransformationController` for several more frames after that. Read
/// the value at `onInteractionEnd` and it is the position mid-fling, not the
/// one the musician actually stopped at, so the page they turn to opens
/// wherever their finger happened to be at release rather than where they
/// were looking when it settled. Waiting for the controller to stop
/// notifying for this long (well past a 60–120 fps animation's frame gap)
/// catches the true rest position instead, at the cost of this much delay
/// before a page turned to *during* the fling would show the final view —
/// imperceptible next to the deliberate second gesture PageTurn needs anyway.
const kZoomSettleDelay = Duration(milliseconds: 150);
