import 'package:flutter/material.dart';

/// Custom metronome glyph from [assets/icons/metronome.png].
class MetronomeIcon extends StatelessWidget {
  const MetronomeIcon({super.key, this.size = 24, this.color});

  static const assetPath = 'assets/icons/metronome.png';

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolved =
        color ??
        IconTheme.of(context).color ??
        DefaultTextStyle.of(context).style.color;
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      color: resolved,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.medium,
    );
  }
}
