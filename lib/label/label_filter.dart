import 'package:standscore/label/label.dart';
import 'package:standscore/library/score.dart';

/// Pure Library filter by Labels (Spec 0021).
List<Score> filterScoresByLabels({
  required List<Score> scores,
  required Map<String, Set<String>> assignments,
  required Set<String> selectedLabelIds,
  required LabelFilterMode mode,
}) {
  if (mode == LabelFilterMode.untagged) {
    return [
      for (final score in scores)
        if ((assignments[score.id] ?? const {}).isEmpty) score,
    ];
  }

  if (selectedLabelIds.isEmpty) {
    return List<Score>.from(scores);
  }

  return [
    for (final score in scores)
      if (_matches(
        scoreLabels: assignments[score.id] ?? const {},
        selected: selectedLabelIds,
        mode: mode,
      ))
        score,
  ];
}

bool _matches({
  required Set<String> scoreLabels,
  required Set<String> selected,
  required LabelFilterMode mode,
}) {
  return switch (mode) {
    LabelFilterMode.any => selected.any(scoreLabels.contains),
    LabelFilterMode.all => selected.every(scoreLabels.contains),
    LabelFilterMode.untagged => scoreLabels.isEmpty,
  };
}
