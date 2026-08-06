import 'package:flutter/material.dart';
import 'package:stagescore/label/label.dart';
import 'package:stagescore/label/label_store.dart';
import 'package:stagescore/theme/app_tokens.dart';

/// Filter Scores by Label (Spec 0021).
///
/// Source-file filtering from Spec 0053 was removed in 0055: drill-in to a
/// book's pieces is the way to see one file, and two ways into the same list
/// was the overlap that slice cut.
Future<void> showLibraryFilterSheet({
  required BuildContext context,
  required LabelStore store,
  required Set<String> selectedLabelIds,
  required LabelFilterMode mode,
  required void Function(Set<String> selected, LabelFilterMode mode) onChanged,
}) {
  var localSelected = {...selectedLabelIds};
  var localMode = mode;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          void apply() => onChanged({...localSelected}, localMode);

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Filter',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          localSelected = {};
                          localMode = LabelFilterMode.any;
                          apply();
                          setModalState(() {});
                        },
                        child: const Text('Clear'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SegmentedButton<LabelFilterMode>(
                    segments: const [
                      ButtonSegment(
                        value: LabelFilterMode.any,
                        label: Text('Any'),
                      ),
                      ButtonSegment(
                        value: LabelFilterMode.all,
                        label: Text('All'),
                      ),
                      ButtonSegment(
                        value: LabelFilterMode.untagged,
                        label: Text('Untagged'),
                      ),
                    ],
                    selected: {localMode},
                    onSelectionChanged: (next) {
                      localMode = next.first;
                      apply();
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (localMode == LabelFilterMode.untagged)
                    Text(
                      'Showing Scores with no Labels.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else if (store.labels.isEmpty)
                    Text(
                      'No Labels yet. Create one from a Score’s Label menu.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final label in store.labels)
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(label.name),
                              value: localSelected.contains(label.id),
                              onChanged: (checked) {
                                if (checked == true) {
                                  localSelected.add(label.id);
                                } else {
                                  localSelected.remove(label.id);
                                }
                                apply();
                                setModalState(() {});
                              },
                            ),
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
