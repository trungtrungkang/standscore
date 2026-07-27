# StageScore (Flutter)

Product of [BackingScore](https://backingscore.com). Bundle ID: `com.backingscore.scoreapp`.

## Run

```bash
cd sheet-app/stagescore
flutter pub get
flutter test
flutter run -d <device>
```

## Specs implemented

Per-Spec status lives in [`../docs/specs/`](../docs/specs) and the capability rows in
[`SCOREPDF-PARITY.md`](../docs/product/SCOREPDF-PARITY.md). Do not keep a second
list here — it drifted once already.

## On-device paths

The library root is `<app documents>/standscore/`, and backup ZIPs are marked
`standscore-backup.json`. Both keep the pre-rename spelling deliberately:
changing them would orphan existing libraries and older backups. Nothing the
musician reads says `standscore`.

Each has exactly one definition — `libraryRootDirName` in `lib/library/library_root.dart`
and the constants in `lib/library/library_backup.dart`. The root used to be a
literal in three screens, where renaming one of them would have pointed part of
the app at an empty folder. Prefs-store doc comments still spell the path out for
readability; they are prose, not a second source of truth.

