import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/library/score_library.dart';
import 'package:stagescore/setlist/setlist.dart';
import 'package:stagescore/setlist/setlist_session.dart';

import 'support/test_l10n.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await testL10n();
  });

  test('SetlistSession.resolve skips missing Scores', () async {
    final root = await Directory.systemTemp.createTemp('setlist_session_');
    addTearDown(() => root.delete(recursive: true));
    final library = ScoreLibrary(root: root);
    await library.ensureReady();

    final pdf = File(p.join(root.path, 'a.pdf'));
    await pdf.writeAsBytes([0x25, 0x50, 0x44, 0x46]);
    final score = await library.importPdf(
      sourcePath: pdf.path,
      originalFileName: 'Alive.pdf',
    );

    final setlist = Setlist(
      id: 'sl1',
      title: 'Gig',
      scoreIds: [score.id, 'missing-id'],
      createdAt: DateTime.utc(2026, 7, 26),
    );

    final resolved = await SetlistSession.resolve(
      l10n: l10n,
      setlist: setlist,
      library: library,
    );
    expect(resolved.skipped, 1);
    expect(resolved.session, isNotNull);
    expect(resolved.session!.pieces, hasLength(1));
    expect(resolved.session!.pieces.first.score.id, score.id);
  });
}
