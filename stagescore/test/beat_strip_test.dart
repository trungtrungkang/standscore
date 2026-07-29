import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/metronome/metronome_engine.dart';
import 'package:stagescore/metronome/metronome_prefs.dart';
import 'package:stagescore/ui/beat_dots.dart';
import 'package:stagescore/ui/beat_strip.dart';

/// The beat strip on the Score (Spec 0030, reopened after G4).
///
/// PerformanceMode hides the chrome five seconds in, which used to take the
/// metronome's only picture with it.
///
/// The engine is never started here: starting it opens an audio session and a
/// wakelock that no widget test has. `beatInBar` and `isRunning` are what the
/// strip reads, so a fake standing in for the engine tests the strip honestly.
class _FakeEngine extends MetronomeEngine {
  _FakeEngine({MetronomePrefs prefs = const MetronomePrefs()})
    : _fakePrefs = prefs;

  MetronomePrefs _fakePrefs;
  bool _running = false;
  int _beat = 0;

  @override
  MetronomePrefs get prefs => _fakePrefs;

  @override
  bool get isRunning => _running;

  @override
  int get beatInBar => _beat;

  @override
  bool get isAccent => _beat == 0 && _fakePrefs.accentEnabled;

  @override
  Future<void> updatePrefs(MetronomePrefs prefs) async {
    _fakePrefs = prefs;
    notifyListeners();
  }

  void fakeStart() {
    _running = true;
    notifyListeners();
  }

  void fakeBeat(int beat) {
    _beat = beat;
    notifyListeners();
  }
}

double _opacity(WidgetTester tester) {
  return tester
      .widget<AnimatedOpacity>(
        find.ancestor(
          of: find.byType(BeatDots),
          matching: find.byType(AnimatedOpacity),
        ),
      )
      .opacity;
}

Future<void> _pump(
  WidgetTester tester,
  _FakeEngine engine, {
  required bool chromeShown,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            const Center(child: Text('score')),
            BeatStrip(engine: engine, chromeShown: chromeShown),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('nothing shows while the metronome is stopped', (tester) async {
    final engine = _FakeEngine();
    await _pump(tester, engine, chromeShown: false);
    expect(_opacity(tester), 0);
  });

  testWidgets('a running metronome shows the beat once the chrome is gone', (
    tester,
  ) async {
    final engine = _FakeEngine();
    await _pump(tester, engine, chromeShown: false);

    engine.fakeStart();
    await tester.pumpAndSettle();
    expect(_opacity(tester), 1);
  });

  testWidgets('but not while the chrome is up — the AppBar sits there', (
    tester,
  ) async {
    final engine = _FakeEngine()..fakeStart();
    await _pump(tester, engine, chromeShown: true);
    expect(_opacity(tester), 0);
  });

  testWidgets('the preference turns it off without stopping the metronome', (
    tester,
  ) async {
    final engine = _FakeEngine()..fakeStart();
    await _pump(tester, engine, chromeShown: false);
    expect(_opacity(tester), 1);

    // Toggled from the sheet, which does not rebuild the screen: the strip has
    // to hear this from the engine itself.
    engine.updatePrefs(engine.prefs.copyWith(showBeatsOnScore: false));
    await tester.pumpAndSettle();

    expect(_opacity(tester), 0);
    expect(engine.isRunning, isTrue, reason: 'the clicks keep going');
  });

  testWidgets('it takes no tap — the Score behind it stays reachable', (
    tester,
  ) async {
    final engine = _FakeEngine()..fakeStart();
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => taps++,
                ),
              ),
              BeatStrip(engine: engine, chromeShown: false),
            ],
          ),
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(find.byType(BeatDots)));
    await tester.pump();
    expect(taps, 1, reason: 'the tap has to reach the PageTurn zone below');
  });

  testWidgets('one dot per beat, and the bar position is the active one', (
    tester,
  ) async {
    final engine = _FakeEngine(prefs: const MetronomePrefs(beatsPerBar: 3))
      ..fakeStart()
      ..fakeBeat(2);
    await _pump(tester, engine, chromeShown: false);

    final dots = tester.widget<BeatDots>(find.byType(BeatDots));
    expect(dots.beatsPerBar, 3);
    expect(dots.activeBeat, 2);

    engine.fakeBeat(0);
    await tester.pump();
    expect(tester.widget<BeatDots>(find.byType(BeatDots)).activeBeat, 0);
    expect(tester.widget<BeatDots>(find.byType(BeatDots)).accent, isTrue);
  });

  testWidgets(
    'the strip is bigger than the sheet copy — it is read on a stand',
    (tester) async {
      final engine = _FakeEngine()..fakeStart();
      await _pump(tester, engine, chromeShown: false);
      expect(
        tester.widget<BeatDots>(find.byType(BeatDots)).scale,
        greaterThan(1),
      );
    },
  );
}
