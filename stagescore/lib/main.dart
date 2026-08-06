import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/library/library_root.dart';
import 'package:stagescore/theme/app_appearance.dart';
import 'package:stagescore/theme/app_appearance_prefs_store.dart';
import 'package:stagescore/theme/app_locale_pref.dart';
import 'package:stagescore/theme/app_locale_prefs_store.dart';
import 'package:stagescore/ui/library_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await pdfrxFlutterInitialize();
  runApp(const StageScoreApp());
}

class StageScoreApp extends StatefulWidget {
  const StageScoreApp({super.key});

  @override
  State<StageScoreApp> createState() => _StageScoreAppState();
}

class _StageScoreAppState extends State<StageScoreApp> {
  AppAppearance _appearance = AppAppearance.defaults;
  AppAppearancePrefsStore? _appearanceStore;
  AppLocalePref _localePref = AppLocalePref.system;
  AppLocalePrefsStore? _localeStore;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final root = await openLibraryRoot();
    final appearanceStore = AppAppearancePrefsStore(root: root);
    final localeStore = AppLocalePrefsStore(root: root);
    final appearance = await appearanceStore.load();
    final localePref = await localeStore.load();
    if (!mounted) return;
    setState(() {
      _appearanceStore = appearanceStore;
      _appearance = appearance;
      _localeStore = localeStore;
      _localePref = localePref;
    });
  }

  Future<void> _onAppearanceChanged(AppAppearance next) async {
    setState(() => _appearance = next);
    await _appearanceStore?.save(next);
  }

  Future<void> _onLocaleChanged(AppLocalePref next) async {
    setState(() => _localePref = next);
    await _localeStore?.save(next);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StageScore',
      debugShowCheckedModeBanner: false,
      themeMode: _appearance.themeMode,
      theme: _appearance.themeData(Brightness.light),
      darkTheme: _appearance.themeData(Brightness.dark),
      locale: _localePref.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: LibraryScreen(
        appearance: _appearance,
        onAppearanceChanged: _onAppearanceChanged,
        localePref: _localePref,
        onLocaleChanged: _onLocaleChanged,
        onLibraryRestored: _loadPrefs,
      ),
    );
  }
}
