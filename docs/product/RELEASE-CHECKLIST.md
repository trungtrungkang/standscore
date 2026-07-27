# v1 release checklist

**Status:** blockers closed (agent 2026-07-27); the remaining rows need the Orchestrator or store content
**Decision:** ship **v1 before Phase C** (Orchestrator 2026-07-27) — Phase C becomes 1.1
**Version in `pubspec.yaml`:** `1.0.0+1`
**Bundle / application ID:** `com.backingscore.scoreapp` (ADR 0009)

This is not a Feature Spec and has no G3/G4. It is the list of things that stand
between the current build and a store submission, written down because the
roadmap covers product slices only and says nothing about shipping.

Status legend: `blocker` | `todo` | `done` | `human` (only the Orchestrator can close it)

---

## Blockers — all closed 2026-07-27

| # | Item | Status |
|---|------|--------|
| R1 | **Android release builds were signed with the debug keystore.** Now: a PKCS12 upload key (RSA 4096, 10000 days, alias `upload`, `CN=StageScore, O=BackingScore, C=VN`, SHA-256 `BE:13:32:FC:…:97:B3`) lives at `~/keystores/stagescore-upload.jks`, outside the repo. `android/key.properties` (gitignored, mode 600) points at it. `build.gradle.kts` builds a real `release` signing config from that file and, when the file is absent, leaves the release build **unsigned rather than debug-signed** — a debug-signed artifact looks shippable and is not. Verified: `flutter build appbundle --release` produces a 71 MB AAB and `jarsigner -verify` reports *jar verified*, signed by the upload cert. | `done` |
| R2 | **No iOS privacy manifest.** Now: `ios/Runner/PrivacyInfo.xcprivacy` and `ios/ShareExtension/PrivacyInfo.xcprivacy`, both added to their target's Resources phase through the `xcodeproj` gem (an 8-line `project.pbxproj` diff, no reformatting). Both declare no tracking and no collected data. Accessed-API reasons were chosen from evidence, not guesswork — see below. Verified: both files appear inside the built `Runner.app` and `Runner.app/PlugIns/ShareExtension.appex`. | `done` |
| R17 | **iOS release builds were broken by the folder rename** (found only because R2 needed a release build). `build/` and `.dart_tool/` carried absolute paths into the pre-rename `sheet-app/standscore/`, so Xcode looked for `pdfium_flutter`'s XCFramework under a directory that no longer exists. `flutter clean` fixes it; nothing in tracked source was wrong. Worth knowing that no debug run would have caught this. | `done` |

### Why those privacy reasons

Four bundled plugins ship no manifest of their own (`audio_session`, `flutter_soloud`,
`pdfium_flutter`, `share_handler_ios`), so the app manifest has to cover them. Grepping
their sources rather than guessing gave exactly three categories:

| Category | Reason | Evidence |
|----------|--------|----------|
| `FileTimestamp` | `C617.1` (files in the app container) | Spec 0040 keys the thumbnail cache on the PDF's mtime; miniaudio inside `flutter_soloud` stats files it opens |
| `UserDefaults` | `1C8F.1` (App Group) | `share_handler_ios` passes shared PDFs from the extension to the app through App Group defaults (Spec 0029) |
| `SystemBootTime` | `35F9.1` (elapsed time between in-app events) | miniaudio's timing path, behind the metronome (Spec 0030) |

## Brand and naming

| # | Item | Status |
|---|------|--------|
| R3 | Rename StandScore → StageScore finished for everything a musician reads: Android launcher label, iOS `CFBundleDisplayName`, ShareExtension display name, in-app title, Library app bar, backup ZIP filename, brand asset filenames | `done` |
| R4 | On-device library root (`<documents>/standscore/`) and backup `formatId` keep the old spelling **on purpose** — renaming orphans existing libraries and older backups. Each now has exactly one definition (`libraryRootDirName` in `lib/library/library_root.dart`, and `LibraryBackup`'s constants); the root was previously a literal repeated in three screens, so renaming one would have pointed part of the app at an empty folder while the rest kept working. The metronome's in-memory loop id and the sample-import temp filename *were* renamed, since neither is persisted | `done` |
| R5 | **Domain / trademark check for the name "StageScore"** before submit. Open since 2026-07-22 (`VISION.md` question 1). The lean-lock search found no obvious store collision, which is not a trademark search. | `human` |
| R6 | Logo is still marked *draft before store lock*. Launcher icons and splash are generated from it, so locking it is a prerequisite, not polish. | `human` |

## Product decisions

| # | Item | Status |
|---|------|--------|
| R7 | **Monetization model, if any**, before public release (`VISION.md` question 5) | `human` |
| R8 | Ship v1 now vs finish Phase C first | `done` — ship now (2026-07-27) |
| R9 | Which parity rows are acceptable `wont` for v1 (`VISION.md` question 8). Currently cut: fit height layout (0041), max page DPI (0031) | `human` |

## Store submission mechanics

| # | Item | Status |
|---|------|--------|
| R10 | Privacy policy and support URL on `backingscore.com` — both stores require reachable URLs | `todo` |
| R11 | App Privacy / Data Safety forms. The app is offline-first and collects nothing; the answers must match the manifests from R2 | `todo` |
| R12 | Store listing: description, keywords, category (Music), age rating, screenshots at every required size | `todo` |
| R13 | Bundled `assets/sample_score.pdf` — was a MuPDF-produced orphan binary printing **"StandScore spike"** on every staff, which shipped and is imported into the user's library by the Library's sample action. No text search could find it (compressed content streams). Regenerated from `tool/generate_sample_score.dart`: six A4 pages, empty staves, our own text. Rights question dissolves — we author it. | `done` |
| R14 | Android SDK levels: `compileSdk`/`targetSdk` 36, `minSdk` 24 from Flutter 3.44.6 defaults. Clears Play's current target-API floor | `done` |
| R15 | iOS deployment target: **not the mismatch it looked like.** Every target (Runner, ShareExtension, tests) already built at 14.0 and the Podfile pins 14.0; the 13.0 was a stale *project-level* default no target inherited. Aligned to 14.0 anyway so a future target cannot pick up 13.0 | `done` |
| R16 | Release-build smoke test on physical devices, both platforms: page turns, pedal, share-in, backup/restore, metronome audio. Needs hardware and an Apple signing identity | `todo` |
| R18 | `flutter build appbundle` warns *failed to strip debug symbols from native libraries*, and the AAB is 71 MB (pdfium plus the audio engine across ABIs). Under Play's limit, so not a blocker; revisit if download size matters. `flutter doctor` also reports Android licenses unaccepted (`flutter doctor --android-licenses`) | `todo` |

---

## Not blocking v1

| Item | Where it lives |
|------|----------------|
| Phase C slices 0037–0039 | `IMPROVEMENT-ROADMAP.md` — now 1.1 |
| SmartMode / Transport / BackingTrack / OMR | ADR 0008, Phase D gate |
| Cloud sync, multi-device | later product decision |
| Max page DPI | cut with 0031 |
