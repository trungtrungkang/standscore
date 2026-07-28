import 'package:flutter/material.dart';

/// True when the interactive transform is meaningfully zoomed in.
///
/// Used to decide whether pan should be allowed (only when zoomed, so a
/// single-finger PageTurn swipe still works at fit) and whether a page's
/// zoom counts as "set" for the cross-page sync (post-0043 pinch-to-zoom).
bool isInteractivelyZoomed(Matrix4 matrix) => matrix.getMaxScaleOnAxis() > 1.05;
