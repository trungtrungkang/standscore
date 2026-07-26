import 'package:flutter/material.dart';
import 'package:stagescore/jumplink/jump_link.dart';
import 'package:stagescore/jumplink/jump_link_geometry.dart';

/// Interactive JumpLink buttons in viewer coordinates (tap / long-press / drag).
class JumpLinkInteractiveLayer extends StatelessWidget {
  const JumpLinkInteractiveLayer({
    super.key,
    required this.pageRect,
    required this.links,
    required this.onTap,
    required this.onLongPress,
    required this.onMoveEnd,
  });

  final Rect pageRect;
  final List<JumpLink> links;
  final ValueChanged<JumpLink> onTap;
  final ValueChanged<JumpLink> onLongPress;
  final ValueChanged<JumpLink> onMoveEnd;

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty || pageRect.isEmpty) {
      return const SizedBox.shrink();
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        for (final link in links)
          Positioned.fromRect(
            rect: jumpLinkPixelRect(link, pageRect),
            child: _DraggableJumpLinkButton(
              key: ValueKey(link.id),
              link: link,
              pageSize: pageRect.size,
              onTap: () => onTap(link),
              onLongPress: () => onLongPress(link),
              onMoveEnd: onMoveEnd,
            ),
          ),
      ],
    );
  }
}

class _DraggableJumpLinkButton extends StatefulWidget {
  const _DraggableJumpLinkButton({
    super.key,
    required this.link,
    required this.pageSize,
    required this.onTap,
    required this.onLongPress,
    required this.onMoveEnd,
  });

  final JumpLink link;
  final Size pageSize;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<JumpLink> onMoveEnd;

  @override
  State<_DraggableJumpLinkButton> createState() =>
      _DraggableJumpLinkButtonState();
}

class _DraggableJumpLinkButtonState extends State<_DraggableJumpLinkButton> {
  var _delta = Offset.zero;
  var _didDrag = false;

  Offset _clampedDelta(Offset proposed) {
    final next = moveJumpLinkNormRect(
      widget.link.normRect,
      proposed,
      widget.pageSize,
    );
    final ox = widget.link.normRect.left * widget.pageSize.width;
    final oy = widget.link.normRect.top * widget.pageSize.height;
    final nx = next.left * widget.pageSize.width;
    final ny = next.top * widget.pageSize.height;
    return Offset(nx - ox, ny - oy);
  }

  void _commit() {
    if (!_didDrag) {
      _delta = Offset.zero;
      return;
    }
    final next = widget.link.copyWith(
      normRect: moveJumpLinkNormRect(
        widget.link.normRect,
        _delta,
        widget.pageSize,
      ),
    );
    _delta = Offset.zero;
    _didDrag = false;
    widget.onMoveEnd(next);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _delta,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_didDrag) return;
          widget.onTap();
        },
        onLongPress: () {
          if (_didDrag) return;
          widget.onLongPress();
        },
        onPanStart: (_) {
          _didDrag = false;
          _delta = Offset.zero;
        },
        onPanUpdate: (details) {
          final nextDelta = _clampedDelta(_delta + details.delta);
          if (nextDelta != _delta) {
            _didDrag = true;
          }
          setState(() => _delta = nextDelta);
        },
        onPanEnd: (_) => _commit(),
        onPanCancel: _commit,
        child: Material(
          color: widget.link.color,
          elevation: _didDrag ? 4 : 1,
          borderRadius: BorderRadius.circular(6),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '→ ${widget.link.destinationPage}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
