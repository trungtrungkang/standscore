# StandScore (Flutter)

Product of [BackingScore](https://backingscore.com). Bundle ID: `com.backingscore.scoreapp`.

## Run

```bash
cd sheet-app/standscore
flutter pub get
flutter test
flutter run -d <device>
```

## Specs implemented

| Spec | Status |
|------|--------|
| 0001 PDF annotate spike | done (go) |
| 0002 Library import/open | done (G4 pass) |
| 0003 PageTurn tap/swipe | done (G4 pass) |
| 0005 Pedal/keyboard PageTurn | **accepted — awaiting G4** |

### Spec 0005 demo (G4)

1. Open multi-page Score (viewer has focus)
2. Keyboard: Space → previous; Enter → next
3. Arrows / PageUp / PageDown match ScorePDF mapping
4. Two-page layout → keys advance by a spread
5. Draw mode ON → keys do not turn pages
6. Page turn settings sheet shows pedal help text

