import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:stagescore/library/score_thumbnails.dart';

/// The first page of a Score, small enough to recognise it by (Spec 0040).
///
/// Recognition, not preview: the box is cropped to the top of the page, where
/// the title and first system live, because a whole page at 44 px is a grey
/// smudge. Until the render lands — and forever, if the file is unreadable —
/// it shows the generic PDF glyph the list used before 0040, so a row never
/// waits on a thumbnail and never breaks without one.
class ScoreThumbnailTile extends StatefulWidget {
  const ScoreThumbnailTile({
    super.key,
    required this.thumbnails,
    required this.scoreId,
    required this.pdf,
    this.width = 44,
    this.height = 56,
  });

  final ScoreThumbnails? thumbnails;
  final String scoreId;
  final File pdf;
  final double width;
  final double height;

  @override
  State<ScoreThumbnailTile> createState() => _ScoreThumbnailTileState();
}

class _ScoreThumbnailTileState extends State<ScoreThumbnailTile> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(ScoreThumbnailTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The list recycles rows by index, so the same State can be handed a
    // different Score mid-scroll.
    if (oldWidget.scoreId != widget.scoreId ||
        oldWidget.pdf.path != widget.pdf.path ||
        oldWidget.thumbnails != widget.thumbnails) {
      setState(() => _bytes = null);
      _resolve();
    }
  }

  Future<void> _resolve() async {
    final thumbnails = widget.thumbnails;
    if (thumbnails == null) return;
    final scoreId = widget.scoreId;
    final bytes = await thumbnails.thumbnail(scoreId: scoreId, pdf: widget.pdf);
    if (!mounted || bytes == null || scoreId != widget.scoreId) return;
    setState(() => _bytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bytes = _bytes;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: bytes == null
              ? Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                )
              : Image.memory(
                  bytes,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  gaplessPlayback: true,
                  errorBuilder: (context, _, _) => Icon(
                    Icons.picture_as_pdf_outlined,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
        ),
      ),
    );
  }
}
