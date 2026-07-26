import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:stagescore/theme/app_appearance.dart';
import 'package:stagescore/theme/app_appearance_prefs_store.dart';
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
  AppAppearancePrefsStore? _store;

  @override
  void initState() {
    super.initState();
    _loadAppearance();
  }

  Future<void> _loadAppearance() async {
    final root = Directory(
      p.join((await getApplicationDocumentsDirectory()).path, 'standscore'),
    );
    await root.create(recursive: true);
    final store = AppAppearancePrefsStore(root: root);
    final appearance = await store.load();
    if (!mounted) return;
    setState(() {
      _store = store;
      _appearance = appearance;
    });
  }

  Future<void> _onAppearanceChanged(AppAppearance next) async {
    setState(() => _appearance = next);
    await _store?.save(next);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StageScore',
      debugShowCheckedModeBanner: false,
      themeMode: _appearance.themeMode,
      theme: _appearance.themeData(Brightness.light),
      darkTheme: _appearance.themeData(Brightness.dark),
      home: LibraryScreen(
        appearance: _appearance,
        onAppearanceChanged: _onAppearanceChanged,
        onLibraryRestored: _loadAppearance,
      ),
    );
  }
}
