import 'package:flutter/material.dart';
import 'package:standscore/layout/half_page.dart';
import 'package:standscore/layout/pdf_layout_mode.dart';
import 'package:standscore/layout/pdf_layout_prefs.dart';

Future<void> showLayoutSettingsSheet({
  required BuildContext context,
  required PdfLayoutPrefs prefs,
  required ValueChanged<PdfLayoutPrefs> onChanged,
}) async {
  var current = prefs;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          void update(PdfLayoutPrefs next) {
            current = next;
            setModalState(() {});
            onChanged(next);
          }

          final half = isHalfPageLayoutMode(current.mode);

          // Cap, not a fixed height: six chips must not open a sheet the size
          // of a screen (Spec 0035).
          final maxHeight = MediaQuery.sizeOf(context).height * 0.9;
          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              'Layout',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: PdfLayoutMode.values.map((mode) {
                            return ChoiceChip(
                              label: Text(mode.label),
                              selected: current.mode == mode,
                              onSelected: (_) =>
                                  update(current.copyWith(mode: mode)),
                            );
                          }).toList(),
                        ),
                        if (half) ...[
                          const SizedBox(height: 20),
                          Text(
                            'Half-page separator',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'How much of the next page peeks into view (app-wide).',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Slider(
                            value: current.halfPageSeparatorRatio,
                            min: halfPageSeparatorMin,
                            max: halfPageSeparatorMax,
                            divisions: 40,
                            label:
                                '${(current.halfPageSeparatorRatio * 100).round()}%',
                            onChanged: (v) => update(
                              current.copyWith(halfPageSeparatorRatio: v),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
