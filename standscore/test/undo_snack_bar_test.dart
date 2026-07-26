import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standscore/ui/undo_snack_bar.dart';

void main() {
  Future<void> pumpSnackBar(
    WidgetTester tester, {
    required VoidCallback onUndo,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  undoSnackBar(message: 'chrome hidden', onUndo: onUndo),
                ),
                child: const Text('apply'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('apply'));
    await tester.pumpAndSettle();
  }

  testWidgets('goes away on its own', (tester) async {
    // Regression: SnackBar.persist defaults to `action != null`, so an Undo
    // snackbar sat on the Score forever (Spec 0036, found at G4).
    await pumpSnackBar(tester, onUndo: () {});
    expect(find.text('chrome hidden'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('chrome hidden'), findsNothing);
  });

  testWidgets('Undo still reaches the caller while it is up', (tester) async {
    var undone = 0;
    await pumpSnackBar(tester, onUndo: () => undone++);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(undone, 1);
    expect(find.text('chrome hidden'), findsNothing);
  });
}
