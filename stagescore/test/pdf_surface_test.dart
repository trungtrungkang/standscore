import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/pdf/pdf_surface.dart';

Future<Color> _surfaceFor(WidgetTester tester, Brightness brightness) async {
  late Color color;
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D8B86),
          brightness: brightness,
        ),
      ),
      home: Builder(
        builder: (context) {
          color = pdfSurfaceColor(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return color;
}

void main() {
  testWidgets('light theme surrounds the page with paper white', (
    tester,
  ) async {
    expect(
      await _surfaceFor(tester, Brightness.light),
      const Color(0xFFFFFFFF),
    );
  });

  testWidgets('dark theme keeps a dark surround', (tester) async {
    final color = await _surfaceFor(tester, Brightness.dark);
    expect(color.computeLuminance(), lessThan(0.1));
  });
}
