import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/metronome/metronome_engine.dart';
import 'package:stagescore/sync_map/sync_map_playback.dart';
import 'package:stagescore/ui/playback_float_controls.dart';

void main() {
  testWidgets('float pill shows play and stop', (tester) async {
    final playback = SyncMapPlayback(
      metronome: MetronomeEngine(),
      clickPlayer: ({required bool accent}) async {},
    );
    addTearDown(playback.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PlaybackFloatControls(
            playback: playback,
            enabled: true,
            normX: 1,
            normY: 1,
            onNormChanged: (_, __) {},
            onPlay: () {},
            onPause: () {},
            onStop: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsOneWidget);
  });
}
