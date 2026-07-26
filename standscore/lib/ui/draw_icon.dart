import 'package:flutter/material.dart';

/// Custom draw glyph from [assets/icons/draw.png].
class DrawIcon extends StatelessWidget {
  const DrawIcon({super.key, this.size = 24, this.color});

  static const assetPath = 'assets/icons/draw.png';

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
