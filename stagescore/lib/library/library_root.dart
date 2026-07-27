import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Name of the library folder inside the app documents directory.
///
/// Deliberately still the pre-rename product name: every installed copy of the
/// app already keeps its Scores, annotations and prefs under this folder, and
/// `LibraryBackup` ZIPs are archives of it. Renaming it orphans both. Nothing
/// the musician reads comes from here.
const libraryRootDirName = 'standscore';

/// The library folder, created if it is not there yet.
Future<Directory> openLibraryRoot() async {
  final docs = await getApplicationDocumentsDirectory();
  final root = Directory(p.join(docs.path, libraryRootDirName));
  await root.create(recursive: true);
  return root;
}
