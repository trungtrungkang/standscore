// Spec 0069 (spike) — throwaway. It answers two questions that cannot be read
// out of the code: does a strip cropped from a real PDF read well when
// magnified, and does the computed ReadBox catch everything a musician needs?
//
// Strings here are plain English on purpose (Spec 0069): translating a screen
// that may be deleted into nine locales is waste. The ScoreMenu label that
// opens it goes through ARB like every other entry.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:stagescore/measure_map/measure_map_store.dart';
import 'package:stagescore/reflow/read_box.dart';
import 'package:stagescore/theme/app_tokens.dart';

class ReflowSpikeScreen extends StatefulWidget {
  const ReflowSpikeScreen({
    super.key,
    required this.filePath,
    required this.measureMap,
    required this.title,
  });

  final String filePath;
  final MeasureMapStore measureMap;
  final String title;

  @override
  State<ReflowSpikeScreen> createState() => _ReflowSpikeScreenState();
}

class _Strip {
  _Strip(this.box, this.image);

  final ReadBox box;
  final ui.Image image;
}

class _ReflowSpikeScreenState extends State<ReflowSpikeScreen> {
  // A strip is one line of a page, so this is generous; the cap only exists so
  // a 4-inch-wide crop on a high-DPI tablet cannot ask PDFium for a bitmap
  // measured in hundreds of megabytes.
  static const _maxPixelWidth = 2400.0;

  PdfDocument? _doc;
  List<int> _pages = const [];
  int _pageAt = 0;
  double _contextFraction = kReadBoxMaxContext;
  bool _showSystemBox = true;

  List<_Strip> _strips = const [];
  double _renderedWidth = 0;
  bool _busy = false;
  String? _error;

  /// Bumped on every render so a slow crop from a previous page or context
  /// value cannot land on screen after a newer one.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _pages = widget.measureMap.boxes.map((b) => b.pageNumber).toSet().toList()
      ..sort();
    unawaited(_open());
  }

  @override
  void dispose() {
    _generation++;
    for (final strip in _strips) {
      strip.image.dispose();
    }
    unawaited(_doc?.dispose());
    super.dispose();
  }

  Future<void> _open() async {
    PdfDocument? doc;
    try {
      doc = await PdfDocument.openFile(widget.filePath);
    } catch (_) {
      if (mounted) setState(() => _error = 'Cannot open this PDF.');
      return;
    }
    if (!mounted) {
      await doc.dispose();
      return;
    }
    setState(() => _doc = doc);
  }

  Future<void> _render(double logicalWidth) async {
    final doc = _doc;
    if (doc == null || _pages.isEmpty || logicalWidth <= 0) return;

    final dpr = MediaQuery.of(context).devicePixelRatio;
    final targetWidth = (logicalWidth * dpr).clamp(1.0, _maxPixelWidth);
    final pageNumber = _pages[_pageAt];
    final boxes = readBoxesForPage(
      widget.measureMap,
      pageNumber,
      contextFraction: _contextFraction,
    );

    final generation = ++_generation;
    setState(() => _busy = true);

    final made = <_Strip>[];
    for (final box in boxes) {
      final image = await _renderStrip(doc, box, targetWidth);
      if (generation != _generation) {
        image?.dispose();
        for (final strip in made) {
          strip.image.dispose();
        }
        return;
      }
      if (image != null) made.add(_Strip(box, image));
    }
    if (!mounted || generation != _generation) {
      for (final strip in made) {
        strip.image.dispose();
      }
      return;
    }

    final previous = _strips;
    setState(() {
      _strips = made;
      _renderedWidth = logicalWidth;
      _busy = false;
    });
    for (final strip in previous) {
      strip.image.dispose();
    }
  }

  Future<ui.Image?> _renderStrip(
    PdfDocument doc,
    ReadBox box,
    double targetWidth,
  ) async {
    final index = box.pageNumber - 1;
    if (index < 0 || index >= doc.pages.length) return null;
    final page = doc.pages[index];
    if (page.width <= 0 || page.height <= 0) return null;
    if (box.width <= 0 || box.height <= 0) return null;

    // Scale the whole page up so that the crop alone comes out targetWidth
    // wide: this is the magnification the musician will actually read at.
    final scale = targetWidth / (box.width * page.width);
    final fullWidth = page.width * scale;
    final fullHeight = page.height * scale;
    final width = (box.width * fullWidth).round();
    final height = (box.height * fullHeight).round();
    if (width <= 0 || height <= 0) return null;

    PdfImage? rendered;
    try {
      rendered = await page.render(
        x: (box.x * fullWidth).round(),
        y: (box.y * fullHeight).round(),
        width: width,
        height: height,
        fullWidth: fullWidth,
        fullHeight: fullHeight,
      );
      if (rendered == null) return null;
      return await rendered.createImage();
    } catch (_) {
      return null;
    } finally {
      rendered?.dispose();
    }
  }

  void _step(int delta) {
    final next = _pageAt + delta;
    if (next < 0 || next >= _pages.length) return;
    setState(() => _pageAt = next);
    if (_renderedWidth > 0) unawaited(_render(_renderedWidth));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Reflow (spike) — ${widget.title}'),
        actions: [
          IconButton(
            tooltip: 'Previous page',
            onPressed: _pageAt > 0 ? () => _step(-1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Center(
            child: Text(
              _pages.isEmpty ? '—' : 'p.${_pages[_pageAt]}',
              style: theme.textTheme.labelLarge,
            ),
          ),
          IconButton(
            tooltip: 'Next page',
            onPressed: _pageAt < _pages.length - 1 ? () => _step(1) : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody(theme)),
          const Divider(height: 1),
          _buildControls(theme),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_error != null) {
      return Center(child: Text(_error!, style: theme.textTheme.bodyLarge));
    }
    if (_pages.isEmpty) {
      return const Center(child: Text('This Score has no MeasureMap yet.'));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (_doc != null && width > 0 && width != _renderedWidth && !_busy) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) unawaited(_render(width));
          });
        }
        if (_strips.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              itemCount: _strips.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
              itemBuilder: (context, i) => _buildStrip(theme, _strips[i], i),
            ),
            if (_busy)
              const Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: SizedBox(
                  width: AppSpacing.lg,
                  height: AppSpacing.lg,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStrip(ThemeData theme, _Strip strip, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ColoredBox(
          color: Colors.white,
          child: AspectRatio(
            aspectRatio: strip.image.width / strip.image.height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: RawImage(image: strip.image, fit: BoxFit.fill),
                ),
                if (_showSystemBox)
                  Positioned.fill(
                    child: CustomPaint(painter: _SystemBoxPainter(strip.box)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            'Line ${index + 1} · system ${strip.box.systemIndex} · '
            '×${strip.box.magnification.toStringAsFixed(2)}',
            style: theme.textTheme.labelSmall,
          ),
        ),
      ],
    );
  }

  Widget _buildControls(ThemeData theme) {
    final first = _strips.isEmpty ? null : _strips.first;
    // Measured against the whole screen, not against this screen's viewport:
    // the AppBar and this control panel belong to the spike, and ReflowMode
    // would hand the musician the full page.
    final media = MediaQuery.of(context);
    final viewport = media.size.height - media.padding.top;
    final fit = first == null || _renderedWidth <= 0
        ? null
        : viewport / (_renderedWidth * first.image.height / first.image.width);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('Context'),
                Expanded(
                  child: Slider(
                    value: _contextFraction,
                    max: kReadBoxMaxContext,
                    divisions: 20,
                    label: _contextFraction.toStringAsFixed(2),
                    onChanged: (v) => setState(() => _contextFraction = v),
                    onChangeEnd: (_) {
                      if (_renderedWidth > 0) {
                        unawaited(_render(_renderedWidth));
                      }
                    },
                  ),
                ),
                Text(_contextFraction.toStringAsFixed(2)),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _strips.isEmpty
                        ? '—'
                        : '${_strips.length} lines · '
                              '×${_strips.first.box.magnification.toStringAsFixed(2)}'
                              '${fit == null ? '' : ' · ${fit.toStringAsFixed(1)} fit full-screen'}',
                    style: theme.textTheme.labelMedium,
                  ),
                ),
                const Text('Show SystemBox'),
                Switch(
                  value: _showSystemBox,
                  onChanged: (v) => setState(() => _showSystemBox = v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Outlines the SystemBox inside a ReadBox, so the added context is readable
/// as a distance rather than guessed at.
class _SystemBoxPainter extends CustomPainter {
  _SystemBoxPainter(this.box);

  final ReadBox box;

  @override
  void paint(Canvas canvas, Size size) {
    if (box.height <= 0) return;
    final top = (box.systemY - box.y) / box.height * size.height;
    final bottom =
        (box.systemY + box.systemHeight - box.y) / box.height * size.height;
    canvas.drawRect(
      Rect.fromLTRB(0, top, size.width, bottom),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.blue.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(_SystemBoxPainter oldDelegate) => oldDelegate.box != box;
}
