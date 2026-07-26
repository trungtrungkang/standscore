import 'package:flutter/material.dart';
import 'package:standscore/jumplink/jump_link.dart';
import 'package:standscore/jumplink/jump_link_geometry.dart';

enum JumpLinkEditAction { save, delete }

class JumpLinkEditResult {
  const JumpLinkEditResult.save(this.link) : action = JumpLinkEditAction.save;
  const JumpLinkEditResult.delete()
      : action = JumpLinkEditAction.delete,
        link = null;

  final JumpLinkEditAction action;
  final JumpLink? link;
}

/// Create or edit a JumpLink (destination / color / size / delete).
Future<JumpLinkEditResult?> showJumpLinkEditor({
  required BuildContext context,
  required int pageCount,
  JumpLink? existing,
  required int originPage,
  int? initialDestination,
}) async {
  var destination = clampJumpDestination(
    existing?.destinationPage ?? initialDestination ?? (originPage < pageCount ? originPage + 1 : originPage),
    pageCount,
  );
  var colorValue = existing?.colorValue ?? defaultJumpLinkColorValue;
  var sizeScale = existing == null
      ? 1.0
      : (existing.normRect.width / defaultJumpLinkNormRect().width)
          .clamp(0.6, 1.8);

  final result = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
                top: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          existing == null ? 'Add jump link' : 'Edit jump link',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'cancel'),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'On page $originPage → jump to',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: destination <= 1
                            ? null
                            : () => setModalState(() => destination--),
                        icon: const Icon(Icons.remove),
                      ),
                      Expanded(
                        child: Text(
                          'Page $destination of $pageCount',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: destination >= pageCount
                            ? null
                            : () => setModalState(() => destination++),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Color', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final c in _palette)
                        ChoiceChip(
                          label: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black26),
                            ),
                          ),
                          selected: colorValue == c,
                          onSelected: (_) =>
                              setModalState(() => colorValue = c),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Button size',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Slider(
                    value: sizeScale,
                    min: 0.6,
                    max: 1.8,
                    divisions: 12,
                    label: sizeScale.toStringAsFixed(1),
                    onChanged: (v) => setModalState(() => sizeScale = v),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, 'save'),
                    child: Text(existing == null ? 'Add' : 'Save'),
                  ),
                  if (existing != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'delete'),
                      child: const Text('Delete'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    },
  );

  if (result == null || result == 'cancel') return null;
  if (result == 'delete') return const JumpLinkEditResult.delete();

  final base = defaultJumpLinkNormRect();
  final norm = Rect.fromLTWH(
    base.left,
    base.top,
    (base.width * sizeScale).clamp(0.12, 0.45),
    (base.height * sizeScale).clamp(0.05, 0.16),
  );

  if (existing != null) {
    return JumpLinkEditResult.save(
      existing.copyWith(
        destinationPage: destination,
        colorValue: colorValue,
        normRect: norm,
      ),
    );
  }

  return JumpLinkEditResult.save(
    JumpLink(
      id: 'pending',
      originPage: originPage,
      destinationPage: destination,
      normRect: norm,
      colorValue: colorValue,
      createdAt: DateTime.now().toUtc(),
    ),
  );
}

const _palette = <int>[
  defaultJumpLinkColorValue,
  0xCCDC2626,
  0xCC2563EB,
  0xCCCA8A04,
  0xCC7C3AED,
];
