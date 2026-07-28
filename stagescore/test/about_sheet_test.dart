import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/brand/brand.dart';
import 'package:stagescore/ui/about_sheet.dart';

/// The About sheet (Spec 0042): who makes this, which build it is, and three
/// links out. Both platform seams are injected, so nothing here touches a
/// method channel.
void main() {
  late List<Uri> opened;
  late bool launchSucceeds;

  setUp(() {
    opened = [];
    launchSucceeds = true;
  });

  Future<void> openSheet(
    WidgetTester tester, {
    Future<AppBuild> Function()? readBuild,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showAboutSheet(
                context: context,
                readBuild:
                    readBuild ??
                    () async =>
                        const AppBuild(version: '9.9.9', buildNumber: '42'),
                launch: (url) async {
                  opened.add(url);
                  return launchSucceeds;
                },
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('names the publisher and the product', (tester) async {
    await openSheet(tester);

    expect(find.text('About ${Brand.productName}'), findsOneWidget);
    expect(find.text(Brand.productName), findsOneWidget);
    expect(find.text('Part of Backing & Score'), findsOneWidget);
    expect(find.text(Brand.aboutBlurb), findsOneWidget);
  });

  testWidgets('shows the version the bundle reports, not a literal', (
    tester,
  ) async {
    // A version no pubspec will ever hold: a hardcoded string cannot pass.
    await openSheet(tester);

    expect(find.text('Version 9.9.9 (42)'), findsOneWidget);
  });

  testWidgets('drops the parenthesis when there is no build number', (
    tester,
  ) async {
    await openSheet(
      tester,
      readBuild: () async => const AppBuild(version: '1.2.3', buildNumber: ''),
    );

    expect(find.text('Version 1.2.3'), findsOneWidget);
  });

  testWidgets('reads even when the bundle cannot be queried', (tester) async {
    await openSheet(
      tester,
      readBuild: () async => throw StateError('no channel'),
    );

    expect(find.text('Part of Backing & Score'), findsOneWidget);
    expect(find.textContaining('Version'), findsNothing);
  });

  testWidgets('each row opens its own destination', (tester) async {
    await openSheet(tester);

    await tester.tap(find.text('backingscore.com'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Privacy policy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Support'));
    await tester.pumpAndSettle();

    expect(opened.map((u) => u.toString()), [
      Brand.siteUrl,
      Brand.privacyUrl,
      Brand.supportUri.toString(),
    ]);
    expect(opened.last.scheme, 'mailto');
  });

  testWidgets('a link that cannot open says so instead of doing nothing', (
    tester,
  ) async {
    launchSucceeds = false;
    await openSheet(tester);

    await tester.tap(find.text('backingscore.com'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not open'), findsOneWidget);
  });

  testWidgets('Done closes the sheet', (tester) async {
    await openSheet(tester);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('About ${Brand.productName}'), findsNothing);
  });
}
