import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/label/label.dart';
import 'package:stagescore/label/label_filter.dart';
import 'package:stagescore/label/label_store.dart';
import 'package:stagescore/library/score.dart';

Score _score(String id) => Score(
  id: id,
  title: id,
  pdfDocumentId: id,
  createdAt: DateTime.utc(2026),
);

void main() {
  group('filterScoresByLabels', () {
    final scores = [_score('a'), _score('b'), _score('c')];
    final assignments = {
      'a': {'jazz', 'band'},
      'b': {'jazz'},
      'c': <String>{},
    };

    test('any matches scores with at least one selected Label', () {
      final result = filterScoresByLabels(
        scores: scores,
        assignments: assignments,
        selectedLabelIds: {'band'},
        mode: LabelFilterMode.any,
      );
      expect(result.map((s) => s.id), ['a']);
    });

    test('all requires every selected Label', () {
      final result = filterScoresByLabels(
        scores: scores,
        assignments: assignments,
        selectedLabelIds: {'jazz', 'band'},
        mode: LabelFilterMode.all,
      );
      expect(result.map((s) => s.id), ['a']);
    });

    test('untagged returns scores with no Labels', () {
      final result = filterScoresByLabels(
        scores: scores,
        assignments: assignments,
        selectedLabelIds: {'jazz'},
        mode: LabelFilterMode.untagged,
      );
      expect(result.map((s) => s.id), ['c']);
    });

    test('empty selection in any/all returns all scores', () {
      final result = filterScoresByLabels(
        scores: scores,
        assignments: assignments,
        selectedLabelIds: {},
        mode: LabelFilterMode.any,
      );
      expect(result, hasLength(3));
    });
  });

  group('LabelStore', () {
    late Directory root;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('labels_');
    });

    tearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    test('create rename reorder delete persist', () async {
      final store = LabelStore(root: root);
      await store.load();
      final jazz = await store.create('Jazz');
      final band = await store.create('Band');
      expect(store.labels.map((l) => l.name), ['Jazz', 'Band']);

      await store.rename(jazz.id, 'Jazz Combo');
      await store.reorder(0, 1);
      expect(store.labels.map((l) => l.name), ['Band', 'Jazz Combo']);

      await store.setScoreLabels('score-1', {jazz.id, band.id});
      expect(store.usageCount(jazz.id), 1);

      await store.delete(band.id);
      expect(store.labels.map((l) => l.name), ['Jazz Combo']);
      expect(store.labelsForScore('score-1'), {jazz.id});

      final reloaded = LabelStore(root: root);
      await reloaded.load();
      expect(reloaded.labels.map((l) => l.name), ['Jazz Combo']);
      expect(reloaded.labelsForScore('score-1'), {jazz.id});
    });
  });
}
