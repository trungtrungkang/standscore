import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/library/score_library.dart';
import 'package:stagescore/library/score_overlays.dart';
import 'package:stagescore/label/label_store.dart';
import 'package:stagescore/setlist/setlist.dart';
import 'package:stagescore/setlist/setlist_store.dart';

void main() {
  late Directory temp;
  late ScoreLibrary library;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('standscore_lib_');
    library = ScoreLibrary(root: temp);
  });

  tearDown(() async {
    if (await temp.exists()) {
      await temp.delete(recursive: true);
    }
  });

  Future<File> writePdf(String name) async {
    final file = File(p.join(temp.path, name));
    await file.writeAsBytes([
      0x25, 0x50, 0x44, 0x46, // %PDF
      0x2d, 0x31, 0x2e, 0x34,
    ]);
    return file;
  }

  test('importPdf copies file and lists score by title', () async {
    final source = await writePdf('My Chart.pdf');
    final score = await library.importPdf(
      sourcePath: source.path,
      originalFileName: 'My Chart.pdf',
    );

    expect(score.title, 'My Chart');
    expect(await library.absoluteFile(score).exists(), isTrue);

    final listed = await library.listScores();
    expect(listed, hasLength(1));
    expect(listed.first.id, score.id);
  });

  test('importPdfs imports multiple files', () async {
    final a = await writePdf('a.pdf');
    final b = await writePdf('b.pdf');
    await library.importPdfs([
      (path: a.path, name: 'a.pdf'),
      (path: b.path, name: 'b.pdf'),
    ]);

    final listed = await library.listScores();
    expect(listed, hasLength(2));
    expect(listed.map((s) => s.title), containsAll(['a', 'b']));
  });

  test('listScores survives re-open of library root', () async {
    final source = await writePdf('persist.pdf');
    await library.importPdf(
      sourcePath: source.path,
      originalFileName: 'persist.pdf',
    );

    final reloaded = ScoreLibrary(root: temp);
    final listed = await reloaded.listScores();
    expect(listed, hasLength(1));
    expect(listed.first.title, 'persist');
  });

  test('replacePdf keep preserves overlays and Score id', () async {
    final original = await writePdf('v1.pdf');
    final score = await library.importPdf(
      sourcePath: original.path,
      originalFileName: 'Piece.pdf',
    );
    final annotation = File(
      p.join(temp.path, 'annotations', '${score.id}.json'),
    );
    await annotation.parent.create(recursive: true);
    await annotation.writeAsString('{"scoreId":"${score.id}","strokes":[]}');

    final labels = LabelStore(root: temp);
    await labels.load();
    final label = await labels.create('Band');
    await labels.setScoreLabels(score.id, {label.id});

    final replacement = await writePdf('v2.pdf');
    await replacement.writeAsBytes(const [0x25, 0x50, 0x44, 0x46, 0x2d, 0x32]);

    final updated = await library.replacePdf(
      scoreId: score.id,
      sourcePath: replacement.path,
      overlays: ReplacePdfOverlayChoice.keep,
    );

    expect(updated.scores.single.id, score.id);
    expect(updated.scores.single.title, 'Piece');
    expect(await annotation.exists(), isTrue);
    expect(await library.absoluteFile(score).readAsBytes(), [
      0x25,
      0x50,
      0x44,
      0x46,
      0x2d,
      0x32,
    ]);
    await labels.load();
    expect(labels.labelsForScore(score.id), {label.id});
  });

  test('replacePdf reset clears overlay files', () async {
    final original = await writePdf('old.pdf');
    final score = await library.importPdf(
      sourcePath: original.path,
      originalFileName: 'Old.pdf',
    );
    for (final path in scoreOverlayPaths(root: temp, scoreId: score.id)) {
      final file = File(path);
      await file.parent.create(recursive: true);
      await file.writeAsString('{}');
    }

    final replacement = await writePdf('new.pdf');
    await library.replacePdf(
      scoreId: score.id,
      sourcePath: replacement.path,
      overlays: ReplacePdfOverlayChoice.reset,
    );

    for (final path in scoreOverlayPaths(root: temp, scoreId: score.id)) {
      expect(await File(path).exists(), isFalse, reason: path);
    }
    expect((await library.listScores()).single.id, score.id);
  });

  test(
    'deleteScore removes PDF, overlays, labels, and setlist membership',
    () async {
      final keepSource = await writePdf('keep.pdf');
      final keep = await library.importPdf(
        sourcePath: keepSource.path,
        originalFileName: 'Keep.pdf',
      );
      final dropSource = await writePdf('drop.pdf');
      final drop = await library.importPdf(
        sourcePath: dropSource.path,
        originalFileName: 'Drop.pdf',
      );

      for (final path in scoreOverlayPaths(root: temp, scoreId: drop.id)) {
        final file = File(path);
        await file.parent.create(recursive: true);
        await file.writeAsString('{}');
      }

      final labels = LabelStore(root: temp);
      await labels.load();
      final label = await labels.create('Gig');
      await labels.setScoreLabels(drop.id, {label.id});
      await labels.setScoreLabels(keep.id, {label.id});

      final setlists = SetlistStore(root: temp);
      await setlists.upsert(
        Setlist(
          id: setlists.newId(),
          title: 'Night',
          scoreIds: [drop.id, keep.id, drop.id],
          createdAt: DateTime.utc(2026, 1, 1),
        ),
      );
      await setlists.upsert(
        Setlist(
          id: setlists.newId(),
          title: 'Only drop',
          scoreIds: [drop.id],
          createdAt: DateTime.utc(2026, 1, 2),
        ),
      );

      // Resolve the file before deleting: once the last Score on a document
      // is gone the document is gone too, so there is nothing left to ask.
      final droppedFile = library.absoluteFile(drop);
      await library.deleteScore(drop.id);
      await labels.setScoreLabels(drop.id, {});
      await setlists.removeScoreFromAll(drop.id);

      final listed = await library.listScores();
      expect(listed.map((s) => s.id), [keep.id]);
      expect(await droppedFile.exists(), isFalse);
      for (final path in scoreOverlayPaths(root: temp, scoreId: drop.id)) {
        expect(await File(path).exists(), isFalse, reason: path);
      }

      await labels.load();
      expect(labels.labelsForScore(drop.id), isEmpty);
      expect(labels.labelsForScore(keep.id), {label.id});

      final after = await setlists.list();
      expect(after, hasLength(2));
      final night = after.firstWhere((s) => s.title == 'Night');
      expect(night.scoreIds, [keep.id]);
      final onlyDrop = after.firstWhere((s) => s.title == 'Only drop');
      expect(onlyDrop.scoreIds, isEmpty);
    },
  );

  group('rename (Spec 0040)', () {
    test('retitles without touching the file on disk', () async {
      final source = await writePdf('doc_2024-11-03_18-22.pdf');
      final score = await library.importPdf(
        sourcePath: source.path,
        originalFileName: 'doc_2024-11-03_18-22.pdf',
      );
      final pdfPath = library.absoluteFile(score).path;

      final renamed = await library.renameScore(
        scoreId: score.id,
        title: '  Autumn Leaves  ',
      );

      expect(renamed.title, 'Autumn Leaves');
      expect(library.absoluteFile(renamed).path, pdfPath);
      expect(await File(pdfPath).exists(), isTrue);

      final listed = await library.listScores();
      expect(listed.single.title, 'Autumn Leaves');
      expect(listed.single.id, score.id);
    });

    test('a blank title leaves the Score alone', () async {
      final source = await writePdf('Chart.pdf');
      final score = await library.importPdf(
        sourcePath: source.path,
        originalFileName: 'Chart.pdf',
      );

      final result = await library.renameScore(scoreId: score.id, title: '   ');

      expect(result.title, 'Chart');
      expect((await library.listScores()).single.title, 'Chart');
    });

    test('an unknown Score is an error, not a silent no-op', () async {
      expect(
        () => library.renameScore(scoreId: 'nope', title: 'x'),
        throwsStateError,
      );
    });
  });

  group('page count (Spec 0040)', () {
    test('is recorded at import when the counter can read the file', () async {
      final counted = ScoreLibrary(root: temp, countPages: (path) async => 4);
      final source = await writePdf('Chart.pdf');

      final score = await counted.importPdf(
        sourcePath: source.path,
        originalFileName: 'Chart.pdf',
      );

      expect(counted.pageCountOf(score), 4);
      expect(counted.pageCountOf((await counted.listScores()).single), 4);
    });

    test('stays null when the PDF cannot be read', () async {
      final source = await writePdf('Chart.pdf');
      final score = await library.importPdf(
        sourcePath: source.path,
        originalFileName: 'Chart.pdf',
      );
      expect(library.pageCountOf(score), isNull);
    });

    test('backfills Scores imported before the count existed', () async {
      final source = await writePdf('Chart.pdf');
      await library.importPdf(
        sourcePath: source.path,
        originalFileName: 'Chart.pdf',
      );

      final counted = ScoreLibrary(root: temp, countPages: (path) async => 7);
      final filled = await counted.backfillPageCounts();

      expect(counted.pageCountOf(filled!.single), 7);
      expect(counted.pageCountOf((await counted.listScores()).single), 7);
      expect(
        await counted.backfillPageCounts(),
        isNull,
        reason: 'nothing left to count means no rewrite',
      );
    });

    test('is recounted when the PDF is replaced', () async {
      var pages = 3;
      final counted = ScoreLibrary(
        root: temp,
        countPages: (path) async => pages,
      );
      final source = await writePdf('Chart.pdf');
      final score = await counted.importPdf(
        sourcePath: source.path,
        originalFileName: 'Chart.pdf',
      );
      expect(counted.pageCountOf(score), 3);

      pages = 9;
      final replaced = await counted.replacePdf(
        scoreId: score.id,
        sourcePath: (await writePdf('Longer.pdf')).path,
        overlays: ReplacePdfOverlayChoice.keep,
      );

      expect(counted.pageCountOf(replaced.scores.single), 9);
      expect(counted.pageCountOf((await counted.listScores()).single), 9);
    });
  });
}
