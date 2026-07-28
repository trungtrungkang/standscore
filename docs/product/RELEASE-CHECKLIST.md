# v1 release checklist

**Status:** blockers closed (agent 2026-07-27); the remaining rows need the Orchestrator or store content
**Decision:** ship **v1 before Phase C** (Orchestrator 2026-07-27) — Phase C becomes 1.1
**Version in `pubspec.yaml`:** `1.0.0+4` (the line said `+1` until 2026-07-28; the build number now shows in About, so it is worth keeping honest)
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
| R19 | **Nothing a musician read said who makes the app.** Closed by Spec 0042: an About sheet under Library ⋯ (publisher, bundle-sourced version, site / privacy / support), one line in the Scores empty state, and the listing copy in R12. Spelling settled by ADR 0010 — humans read **Backing & Score**, identifiers keep `backingscore` | `done` |
| R20 | **`backingscore.com` did not mention StageScore anywhere**, so the app claimed an ecosystem its own site did not list. Written in the web repo 2026-07-28: a landing page at **`/stagescore`** (ADR 0011), a section on `/about` linking to it, and a StageScore block on `/support`. i18n keys sit in `en` and `vi`; the other seven locales fall back to English through the existing `deepMerge`, which is already how most of the About page renders. Everything is marked "coming soon to the App Store and Google Play" — honest until v1 is published, and the one string to change on launch day. **Not deployed yet** | `human` — review copy, then deploy |
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
| R10 | Privacy policy and support URL on `backingscore.com`. **support@backingscore.com receives mail** since 2026-07-28 (Cloudflare Email Routing; MX `route1/2/3.mx.cloudflare.net`), so the address the About sheet opens is real. Reading the privacy text turned up something worse than a gap — see R22. Both fixes shipped: a new `/support` page for Apple's Support URL field, and a StageScore section in `/privacy`. **Live on production 2026-07-28**, verified by fetching `/privacy`, `/terms`, `/support` and `/stagescore` — all 200 with the new text. The two URLs the store forms need are `https://backingscore.com/privacy` and `https://backingscore.com/support` | `done` |
| R22 | **The privacy policy contradicted the app, and then turned out to contradict the web product too.** It claimed Backing & Score "rigorously track and log the tracks you play", ran Mixpanel, billed through Paddle and RevenueCat, and reported play logs to Hal Leonard — while StageScore's `PrivacyInfo.xcprivacy` (R2) declares no tracking and no collection. Auditing the web codebase on the Orchestrator's instruction found **almost none of those vendors or behaviours exist**: no analytics package of any kind, no Paddle, and nothing anywhere reports play history. `/privacy` was rewritten from evidence and `/terms` corrected in two places. StageScore is now section 7, at the same URL the app already ships in `Brand.privacyUrl`. **One exception, caught late:** RevenueCat *is* real — a working webhook at `/api/webhooks/revenuecat` that grants entitlements from Apple and Google purchases. It is absent from `package.json` because a webhook needs no SDK, which is why the first pass missed it; it showed up in the production build output instead. Inert today (no `REVENUECAT_WEBHOOK_SECRET`), and now named in the policy beside Polar with both marked not yet switched on. **Deployed and verified 2026-07-28.** See R23 for the part the Orchestrator's brief did not survive contact with | `done` |
| R23 | **"We collect nothing" is not true of the web platform, and the policy must not say it.** The brief was that Backing & Score collects no user data; the schema says otherwise, and a policy that under-claims is as false as one that over-claims. Actually stored: account name / email / avatar / bio (`users`), **IP address and user-agent per sign-in** (`sessions`, written by better-auth), practice records — duration, tempo, Wait Mode score, MIDI-or-mic (`practice_sessions`, written from `actions/v5/gamification.ts`), XP and streaks (`user_stats`), social content, and Polar subscription state. The rewritten policy states each one and why the feature needs it, then says plainly what is *not* done: no analytics, no ad tech, no profiling, no sales, no reporting to publishers. That is both true and the stronger claim. **Does not affect StageScore itself** — the app still collects nothing. Orchestrator confirmed 2026-07-28: Sentry never configured (dropped from the provider list, replaced by a line saying no error monitoring runs), Polar still sandbox (payments written as not yet open), social feed off — verified in code as a private `_feed` route plus `socialFeed` defaulting false, so posts and comments came out. LiveKit and favourites stay: `/classroom/[id]/live` and the player and discover menus still reach them. **Live on production 2026-07-28** | `done` |
| R24 | **If streak / XP goes, the policy loses its most sensitive paragraph.** `practice_sessions` is the only row in R23 that records *what and how well you played* rather than what your account needs; it is also the only one a musician might not expect. The Orchestrator is weighing whether to disable it. Keeping it is defensible — the data is shown back to the player and goes nowhere — but disabling it removes a whole paragraph from `/privacy` and makes the "we store what your account needs" claim exactly true with no caveat. Decide before the policy deploys, since redeploying a privacy policy that has been public is a worse look than getting it right once. **Resolved 2026-07-28:** keep the feature, drop the storage. The audit found the table was **write-only** — one writer in `actions/v5/gamification.ts`, no reader anywhere — so streak and XP never needed it. Both inserts removed, the table removed from the schema, migration `0028_chemical_emma_frost.sql` generated (`DROP TABLE practice_sessions`, **not applied** — a destructive migration for the Orchestrator to run), and the dead `APPWRITE_PRACTICE_SESSIONS_COLLECTION_ID` constant deleted. The policy now says the run is thrown away and only four running totals survive. **Deployed 2026-07-28, so no new rows are being written** — but the migration drops a table with real rows in it and is the one piece still outstanding. Until it runs, the historical practice log is still held even though the policy says we do not keep one, which matters for a data request rather than for correctness of the running app | `todo` — apply migration `0028` |
| R21 | **No DMARC record on `backingscore.com`** (`_dmarc` is empty; root SPF is Cloudflare's, DKIM is Resend's). Not a store requirement, but Gmail and Yahoo have required DMARC from bulk senders since 2024, and every verification and password-reset mail the web app sends goes out under this domain. Start at `p=none` with a `rua=` address and watch the reports before tightening | `todo` |
| R11 | App Privacy / Data Safety forms. The app is offline-first and collects nothing; the answers must match the manifests from R2 | `todo` |
| R12 | Store listing: description, keywords, category (Music), age rating, screenshots at every required size. **Copy accepted by the Orchestrator 2026-07-28** — [`STORE-LISTING.md`](./STORE-LISTING.md) is the text we submit. What remains is the six screenshots, which need hardware and a locked logo (R6) first, or they get reshot | `todo` |
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
