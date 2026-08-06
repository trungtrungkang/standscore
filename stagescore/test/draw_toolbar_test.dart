import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/annotation/draw_style.dart';
import 'package:stagescore/annotation/draw_tool.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/ui/draw_toolbar.dart';

/// Draw-mode controls belong on one bar, not split between the AppBar and the
/// DrawToolbar (Spec 0035).
Future<void> pumpToolbar(
  WidgetTester tester, {
  DrawTool tool = DrawTool.pen,
  DrawStylePrefs style = const DrawStylePrefs(),
  ValueChanged<DrawStylePrefs>? onStyleChanged,
  VoidCallback? onUndo,
  VoidCallback? onRedo,
  VoidCallback? onDeleteStamp,
}) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: DrawToolbar(
          tool: tool,
          style: style,
          onToolChanged: (_) {},
          onStyleChanged: onStyleChanged ?? (_) {},
          onUndo: onUndo,
          onRedo: onRedo,
          onDeleteStamp: onDeleteStamp,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('carries Undo and Redo', (tester) async {
    var undos = 0;
    var redos = 0;
    await pumpToolbar(tester, onUndo: () => undos++, onRedo: () => redos++);

    await tester.tap(find.text('Undo'));
    await tester.tap(find.text('Redo'));
    expect(undos, 1);
    expect(redos, 1);
  });

  testWidgets('Undo and Redo stay put when there is no history', (
    tester,
  ) async {
    await pumpToolbar(tester);

    // Still shown, so the bar does not reflow as history comes and goes.
    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('Redo'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pump();
  });

  group('Size', () {
    testWidgets('sets the pen width without touching the marker', (
      tester,
    ) async {
      DrawStylePrefs? saved;
      await pumpToolbar(tester, onStyleChanged: (s) => saved = s);

      await tester.tap(find.text('Size'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thick'));
      await tester.pumpAndSettle();

      expect(saved!.penWidth, penWidthSteps.last);
      expect(saved!.markerWidth, const DrawStylePrefs().markerWidth);
    });

    testWidgets('offers the marker steps while the marker is active', (
      tester,
    ) async {
      DrawStylePrefs? saved;
      await pumpToolbar(
        tester,
        tool: DrawTool.marker,
        onStyleChanged: (s) => saved = s,
      );

      await tester.tap(find.text('Size'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thin'));
      await tester.pumpAndSettle();

      expect(saved!.markerWidth, markerWidthSteps.first);
      expect(saved!.penWidth, const DrawStylePrefs().penWidth);
    });

    testWidgets('is off for tools with no adjustable width', (tester) async {
      await pumpToolbar(tester, tool: DrawTool.eraser);

      await tester.tap(find.text('Size'));
      await tester.pumpAndSettle();
      expect(find.text('Medium'), findsNothing);
    });
  });

  testWidgets('Delete appears only with a Stamp selected', (tester) async {
    await pumpToolbar(tester);
    expect(find.text('Delete'), findsNothing);

    var deletes = 0;
    await pumpToolbar(tester, onDeleteStamp: () => deletes++);
    expect(find.text('Delete'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    expect(deletes, 1);
  });
}
