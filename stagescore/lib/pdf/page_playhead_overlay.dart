import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:stagescore/sync_map/playhead_overlay_config.dart';
import 'package:stagescore/sync_map/playhead_position.dart';

/// Deep red playhead — readable on white / sepia paper (Spec 0059).
const kPlayheadColor = Color(0xFF8B0000);

/// Vertical playhead line on one PDF page (Spec 0059).
///
/// Rebuilds only this overlay via [ListenableBuilder] on the playback clock.
class PagePlayheadOverlay extends StatelessWidget {
  const PagePlayheadOverlay({
    super.key,
    required this.pageRect,
    required this.page,
    required this.config,
  });

  final Rect pageRect;
  final PdfPage page;
  final PlayheadOverlayConfig config;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: config.playback,
      builder: (context, _) {
        final playback = config.playback;
        if (config.suppressed || !playback.playheadVisible) {
          return const SizedBox.shrink();
        }
        final pos = playheadAtTime(
          syncMap: playback.map,
          store: config.store,
          timeMs: playback.positionMs,
        );
        if (pos == null || pos.pageNumber != page.pageNumber) {
          return const SizedBox.shrink();
        }
        final x = pos.x * pageRect.width;
        final top = pos.top * pageRect.height;
        final height = pos.height * pageRect.height;
        return IgnorePointer(
          child: CustomPaint(
            size: pageRect.size,
            painter: _PlayheadPainter(x: x, top: top, height: height),
          ),
        );
      },
    );
  }
}

class _PlayheadPainter extends CustomPainter {
  _PlayheadPainter({
    required this.x,
    required this.top,
    required this.height,
  });

  final double x;
  final double top;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kPlayheadColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(x, top), Offset(x, top + height), paint);
  }

  @override
  bool shouldRepaint(covariant _PlayheadPainter oldDelegate) =>
      oldDelegate.x != x ||
      oldDelegate.top != top ||
      oldDelegate.height != height;
}
