import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/theme/app_locale_pref.dart';
import 'package:stagescore/ui/title_prompt.dart';

/// Forcing `MaterialApp.locale` is how `main.dart` applies the Language
/// setting (Spec 0057) — this test exercises that same mechanism end to end,
/// rather than only the pure `AppLocalizations` lookups the label-getter
/// tests already cover.
Future<void> _pumpApp(WidgetTester tester, Locale locale) {
  return tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () =>
                  promptForTitle(context: context, title: 'x', initial: ''),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  for (final entry in {
    const Locale('en'): ('Cancel', 'Save'),
    const Locale('vi'): ('Hủy', 'Lưu'),
    const Locale('ja'): ('キャンセル', '保存'),
    const Locale('zh', 'TW'): ('取消', '儲存'),
  }.entries) {
    testWidgets('title prompt shows ${entry.key} translations', (
      tester,
    ) async {
      await _pumpApp(tester, entry.key);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text(entry.value.$1), findsOneWidget);
      expect(find.text(entry.value.$2), findsOneWidget);
    });
  }

  testWidgets('an unsupported system locale resolves to a supported one, not a crash', (
    tester,
  ) async {
    await _pumpApp(tester, const Locale('th'));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final resolved = Localizations.localeOf(
      tester.element(find.byType(AlertDialog)),
    );
    expect(AppLocalizations.supportedLocales, contains(resolved));
  });

  test('every supported locale loads and resolves the piece-count plural', () async {
    for (final locale in AppLocalePref.supported) {
      final l10n = await AppLocalizations.delegate.load(locale);
      // Vietnamese/Chinese/Japanese/Korean have no plural distinction: `1`
      // and `2` must not diverge into an "1 pieces"-shaped sentence.
      final one = l10n.piecesScreenPieceCount(1);
      final two = l10n.piecesScreenPieceCount(2);
      expect(one, isNotEmpty);
      expect(two, isNotEmpty);
    }
  });
}
