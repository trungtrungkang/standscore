import 'package:flutter/material.dart';
import 'package:stagescore/annotation/draw_style.dart';
import 'package:stagescore/annotation/draw_tool.dart';
import 'package:stagescore/annotation/stamp.dart';

/// Callback when the user arms a stamp for the next tap (Spec 0019).
typedef StampArmedCallback = void Function(StampKind kind, String? text);

/// One-row draw chrome: labeled color + tool + stamp + overflow (Specs 0018/0019).
class DrawToolbar extends StatelessWidget {
  const DrawToolbar({
    super.key,
    required this.tool,
    required this.style,
    required this.onToolChanged,
    required this.onStyleChanged,
    this.pendingStamp,
    this.onStampArmed,
    this.onUndo,
    this.onRedo,
    this.onDeleteStamp,
  });

  final DrawTool tool;
  final DrawStylePrefs style;
  final ValueChanged<DrawTool> onToolChanged;
  final ValueChanged<DrawStylePrefs> onStyleChanged;
  final StampKind? pendingStamp;
  final StampArmedCallback? onStampArmed;

  /// Draw-mode history. Null disables the button; these live here rather than
  /// in the AppBar so all Draw controls sit on one bar (Spec 0035).
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;

  /// Only offered while a Stamp is selected.
  final VoidCallback? onDeleteStamp;

  DrawTool get _inkTool =>
      tool == DrawTool.marker ? DrawTool.marker : DrawTool.pen;

  /// Pen and marker keep separate widths, so the steps differ too.
  List<double> get _widthSteps =>
      _inkTool == DrawTool.marker ? markerWidthSteps : penWidthSteps;

  /// Saved widths are free-form doubles; show the nearest step.
  int get _widthStepIndex {
    final width = style.widthFor(_inkTool);
    var best = 0;
    for (var i = 1; i < _widthSteps.length; i++) {
      if ((width - _widthSteps[i]).abs() < (width - _widthSteps[best]).abs()) {
        best = i;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final activeColor = style.colorFor(_inkTool);

    return Material(
      color: const Color(0xFF0D9488).withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Builder(
              builder: (buttonContext) {
                return _LabeledAction(
                  label: 'Color',
                  onTap: DrawToolPresets.isInkTool(tool)
                      ? () => _pickColor(buttonContext)
                      : null,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: activeColor.withValues(alpha: 1),
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.outline, width: 1.5),
                    ),
                  ),
                );
              },
            ),
            Builder(
              builder: (buttonContext) {
                return _LabeledAction(
                  label: _label(tool),
                  onTap: () => _pickTool(buttonContext),
                  child: Icon(_icon(tool), size: 22),
                );
              },
            ),
            Builder(
              builder: (buttonContext) {
                final ink = DrawToolPresets.isInkTool(tool);
                return _LabeledAction(
                  label: 'Size',
                  onTap: ink ? () => _pickWidth(buttonContext) : null,
                  child: _WidthDot(
                    step: ink ? _widthStepIndex : 1,
                    color: ink
                        ? scheme.onSurface
                        : Theme.of(context).disabledColor,
                  ),
                );
              },
            ),
            const Spacer(),
            _LabeledAction(
              label: 'Undo',
              onTap: onUndo,
              child: const Icon(Icons.undo, size: 22),
            ),
            _LabeledAction(
              label: 'Redo',
              onTap: onRedo,
              child: const Icon(Icons.redo, size: 22),
            ),
            if (onDeleteStamp != null)
              _LabeledAction(
                label: 'Delete',
                onTap: onDeleteStamp,
                child: const Icon(Icons.delete_outline, size: 22),
              ),
            _LabeledAction(
              label: pendingStamp == null ? 'Stamp' : 'Place',
              onTap: onStampArmed == null ? null : () => _pickStamp(context),
              child: Icon(
                pendingStamp == null
                    ? Icons.sticky_note_2_outlined
                    : Icons.touch_app_outlined,
                size: 22,
                color: pendingStamp == null ? null : const Color(0xFF0D9488),
              ),
            ),
            _LabeledAction(
              label: 'More',
              onTap: () => _openOptions(context),
              child: const Icon(Icons.more_horiz, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStamp(BuildContext context) async {
    final armed = onStampArmed;
    if (armed == null) return;

    final kind = await showModalBottomSheet<StampKind>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Stamps', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final k in StampKind.values)
                      ActionChip(
                        label: Text(k.label),
                        onPressed: () => Navigator.pop(context, k),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (kind == null || !context.mounted) return;

    String? text;
    if (kind == StampKind.text) {
      final controller = TextEditingController();
      text = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Text stamp'),
            content: TextField(
              controller: controller,
              autofocus: true,
              maxLength: 24,
              decoration: const InputDecoration(hintText: 'Short label'),
              onSubmitted: (v) => Navigator.pop(context, v.trim()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('Place'),
              ),
            ],
          );
        },
      );
      if (text == null || text.isEmpty) return;
    }

    armed(kind, text);
  }

  RelativeRect _anchorRect(BuildContext buttonContext) {
    final box = buttonContext.findRenderObject()! as RenderBox;
    final overlay =
        Overlay.of(buttonContext).context.findRenderObject()! as RenderBox;
    return RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
  }

  Future<void> _pickColor(BuildContext buttonContext) async {
    final anchor = _anchorRect(buttonContext);
    final selected = await showDialog<int>(
      context: buttonContext,
      barrierColor: Colors.black26,
      builder: (context) {
        final size = MediaQuery.sizeOf(context);
        // Place panel just under the color control.
        final left = anchor.left.clamp(12.0, size.width - 220);
        final top = (size.height - anchor.bottom + 4).clamp(
          48.0,
          size.height - 160,
        );

        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: 196,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final c in drawColorPalette)
                          InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.pop(context, c),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Color(c),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      (style.colorFor(_inkTool).toARGB32() &
                                              0x00FFFFFF) ==
                                          (c & 0x00FFFFFF)
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Colors.black26,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    if (selected == null) return;
    onStyleChanged(style.withColorFor(_inkTool, Color(selected)));
  }

  Future<void> _pickTool(BuildContext buttonContext) async {
    final selected = await showMenu<DrawTool>(
      context: buttonContext,
      position: _anchorRect(buttonContext),
      items: [
        for (final t in DrawTool.values)
          PopupMenuItem<DrawTool>(
            value: t,
            child: Row(
              children: [
                Icon(_icon(t), size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(_label(t))),
                if (tool == t) const Icon(Icons.check, size: 18),
              ],
            ),
          ),
      ],
    );
    if (selected == null) return;
    onToolChanged(selected);
  }

  Future<void> _pickWidth(BuildContext buttonContext) async {
    final steps = _widthSteps;
    final current = _widthStepIndex;
    final selected = await showMenu<int>(
      context: buttonContext,
      position: _anchorRect(buttonContext),
      items: [
        for (var i = 0; i < steps.length; i++)
          PopupMenuItem<int>(
            value: i,
            child: Row(
              children: [
                _WidthDot(step: i),
                const SizedBox(width: 12),
                Expanded(child: Text(_widthLabel(i))),
                if (i == current) const Icon(Icons.check, size: 18),
              ],
            ),
          ),
      ],
    );
    if (selected == null) return;
    final width = steps[selected];
    onStyleChanged(
      _inkTool == DrawTool.marker
          ? style.copyWith(markerWidth: width)
          : style.copyWith(penWidth: width),
    );
  }

  Future<void> _openOptions(BuildContext context) async {
    var localTool = tool;
    var localStyle = style;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final maxHeight = MediaQuery.sizeOf(context).height * 0.75;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final inkTool = localTool == DrawTool.marker
                ? DrawTool.marker
                : DrawTool.pen;
            final widths = localTool == DrawTool.marker
                ? markerWidthSteps
                : penWidthSteps;
            final activeWidth = localStyle.widthFor(inkTool);
            final selectedWidth = widths.reduce(
              (a, b) =>
                  (activeWidth - a).abs() <= (activeWidth - b).abs() ? a : b,
            );

            return SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Draw options',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tool',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final t in DrawTool.values)
                            ChoiceChip(
                              avatar: Icon(_icon(t), size: 18),
                              label: Text(_label(t)),
                              selected: localTool == t,
                              showCheckmark: false,
                              onSelected: (_) {
                                localTool = t;
                                onToolChanged(t);
                                setModalState(() {});
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Color',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final c in drawColorPalette)
                            InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                localStyle = localStyle.withColorFor(
                                  inkTool,
                                  Color(c),
                                );
                                onStyleChanged(localStyle);
                                setModalState(() {});
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Color(c),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        (localStyle
                                                    .colorFor(inkTool)
                                                    .toARGB32() &
                                                0x00FFFFFF) ==
                                            (c & 0x00FFFFFF)
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onSurface
                                        : Colors.black26,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Width',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: constraints.maxWidth,
                              child: SegmentedButton<double>(
                                style: const ButtonStyle(
                                  visualDensity: VisualDensity.compact,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                showSelectedIcon: false,
                                segments: [
                                  for (var i = 0; i < widths.length; i++)
                                    ButtonSegment(
                                      value: widths[i],
                                      label: Text(const ['S', 'M', 'L'][i]),
                                    ),
                                ],
                                selected: {selectedWidth},
                                onSelectionChanged: (next) {
                                  final w = next.first;
                                  localStyle = localTool == DrawTool.marker
                                      ? localStyle.copyWith(markerWidth: w)
                                      : localStyle.copyWith(penWidth: w);
                                  onStyleChanged(localStyle);
                                  setModalState(() {});
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Straight line'),
                        value: localStyle.straightLine,
                        onChanged: (v) {
                          localStyle = localStyle.copyWith(straightLine: v);
                          onStyleChanged(localStyle);
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static IconData _icon(DrawTool tool) => switch (tool) {
    DrawTool.pen => Icons.edit,
    DrawTool.marker => Icons.highlight,
    DrawTool.eraser => Icons.auto_fix_off,
    DrawTool.eyedropper => Icons.colorize,
  };

  static String _label(DrawTool tool) => switch (tool) {
    DrawTool.pen => 'Pen',
    DrawTool.marker => 'Marker',
    DrawTool.eraser => 'Eraser',
    DrawTool.eyedropper => 'Dropper',
  };
}

String _widthLabel(int step) => switch (step) {
  0 => 'Thin',
  1 => 'Medium',
  _ => 'Thick',
};

/// The active stroke width, drawn at that width (Spec 0035).
class _WidthDot extends StatelessWidget {
  const _WidthDot({required this.step, this.color});

  final int step;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final diameter = 8.0 + step * 5;
    return SizedBox(
      width: 22,
      height: 22,
      child: Center(
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: color ?? Theme.of(context).colorScheme.onSurface,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _LabeledAction extends StatelessWidget {
  const _LabeledAction({
    required this.label,
    required this.child,
    required this.onTap,
  });

  final String label;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme.merge(
              data: IconThemeData(
                color: disabled
                    ? Theme.of(context).disabledColor
                    : Theme.of(context).colorScheme.onSurface,
              ),
              child: child,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: disabled
                    ? Theme.of(context).disabledColor
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
