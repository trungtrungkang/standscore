# v1 release checklist

**Status:** the 2026-07-27 blockers are closed and **v1 is back to being a set of human errands that run in parallel.** Ads and the `remove_ads` purchase moved into `1.0.0` on 2026-07-30 and then back out to **1.1** the same day (ADR 0018 decision 10). The reversal is not indecision: the second look found that AdMob will not serve ads to an app that is not yet on a store (decision 13), so shipping ads in v1 buys **zero revenue on launch day** while putting a sequential tier-L chain and up to 90 days of tax paperwork in front of the release date. Nothing about the app v1 ships has changed since 2026-07-28, and **nothing in this file or `STORE-LISTING.md` should be edited for ads until the 1.1 build is ready to submit**
**Decision:** ship **v1 before Phase C** (Orchestrator 2026-07-27) — Phase C becomes 1.1, alongside ads
**What is left for v1:** R16 — see the **v1 submission runbook** at the bottom. R5 / R6 / R9 closed 2026-07-31; R24 closed 2026-08-01; R12 closed 2026-08-01
**Version in `pubspec.yaml`:** `1.0.0+7` (the line said `+1` until 2026-07-28; the build number now shows in About, so it is worth keeping honest — `+7` on 2026-08-06 replaces the Half Page overlay with continuous scroll, Spec 0056)
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
| R5 | **Domain / trademark check for the name "StageScore".** Closed 2026-07-31: the name is registered. Store listing title on **both** App Store Connect and Google Play is **`StageScore — Sheet Music`**; the installed app name (home screen / launcher) stays **`StageScore`** — already what `CFBundleDisplayName` and `android:label` ship. See [`STORE-LISTING.md`](./STORE-LISTING.md) | `done` |
| R19 | **Nothing a musician read said who makes the app.** Closed by Spec 0042: an About sheet under Library ⋯ (publisher, bundle-sourced version, site / privacy / support), one line in the Scores empty state, and the listing copy in R12. Spelling settled by ADR 0010 — humans read **Backing & Score**, identifiers keep `backingscore` | `done` |
| R20 | **`backingscore.com` did not mention StageScore anywhere**, so the app claimed an ecosystem its own site did not list. Written in the web repo 2026-07-28: a landing page at **`/stagescore`** (ADR 0011), a section on `/about` linking to it, and a StageScore block on `/support`. i18n keys sit in `en` and `vi`; the other seven locales fall back to English through the existing `deepMerge`, which is already how most of the About page renders. Everything is marked "coming soon to the App Store and Google Play" — honest until v1 is published, and the one string to change on launch day. **Deployed — this row said "not deployed yet" until 2026-07-30, when fetching the URLs returned `200` for `/privacy`, `/support` and `/stagescore`.** It contradicted R10, which had recorded the same check on 2026-07-28; R10 was right | `done` — deployed and verified. Copy review is the Orchestrator's call, and the "coming soon" line is the one string to change on launch day |
| R6 | **Logo locked 2026-07-31** to the current mark at `stagescore/assets/brand/stagescore-logo.png` (flat stand silhouette; launcher icons and splash already generated from it via `flutter_launcher_icons` / `flutter_native_splash`). Screenshots (R12) may proceed | `done` |

## Product decisions

| # | Item | Status |
|---|------|--------|
| R7 | **Monetization model** (`VISION.md` question 5). **Answered 2026-07-30: the app stays free and fully featured, a banner runs in Library, and one `remove_ads` purchase turns it off for good** — but **in 1.1**, not v1. Nothing is ever locked behind a paywall; what is sold is the absence of ads. Written up as **ADR 0018** (tier **L**, all ten G2 questions answered, Security Review already run — `pass` with conditions), implemented by **Spec 0051** (thirteen G3 questions answered). The placement moved 1.1 → v1 → 1.1 in one day; the last move stands on new evidence rather than taste (decision 13). **For v1 this row is closed in the form the store listing already describes: free, no ads, no in-app purchase.** Everything else here is 1.1 work: R25, R26, R27, and the ads columns of R11 and R12 | `done` for v1 — free, no IAP. ADR 0018 answers 1.1 |
| R8 | Ship v1 now vs finish Phase C first | `done` — ship now (2026-07-27) |
| R9 | Which parity rows are acceptable `wont` for v1 (`VISION.md` question 8). **Accepted 2026-07-31:** fit height (0041 / P0.6 half) and max page DPI (0031 / P2.14 half) stay `wont` for v1 — reopen DPI only if sharpness blocks gigs | `done` |

## Store submission mechanics

| # | Item | Status |
|---|------|--------|
| R10 | Privacy policy and support URL on `backingscore.com`. **support@backingscore.com receives mail** since 2026-07-28 (Cloudflare Email Routing; MX `route1/2/3.mx.cloudflare.net`), so the address the About sheet opens is real. Reading the privacy text turned up something worse than a gap — see R22. Both fixes shipped: a new `/support` page for Apple's Support URL field, and a StageScore section in `/privacy`. **Live on production 2026-07-28**, verified by fetching `/privacy`, `/terms`, `/support` and `/stagescore` — all 200 with the new text. The two URLs the store forms need are `https://backingscore.com/privacy` and `https://backingscore.com/support` | `done` |
| R22 | **The privacy policy contradicted the app, and then turned out to contradict the web product too.** It claimed Backing & Score "rigorously track and log the tracks you play", ran Mixpanel, billed through Paddle and RevenueCat, and reported play logs to Hal Leonard — while StageScore's `PrivacyInfo.xcprivacy` (R2) declares no tracking and no collection. Auditing the web codebase on the Orchestrator's instruction found **almost none of those vendors or behaviours exist**: no analytics package of any kind, no Paddle, and nothing anywhere reports play history. `/privacy` was rewritten from evidence and `/terms` corrected in two places. StageScore is now section 7, at the same URL the app already ships in `Brand.privacyUrl`. **One exception, caught late:** RevenueCat *is* real — a working webhook at `/api/webhooks/revenuecat` that grants entitlements from Apple and Google purchases. It is absent from `package.json` because a webhook needs no SDK, which is why the first pass missed it; it showed up in the production build output instead. Inert today (no `REVENUECAT_WEBHOOK_SECRET`), and now named in the policy beside Polar with both marked not yet switched on. **Deployed and verified 2026-07-28.** See R23 for the part the Orchestrator's brief did not survive contact with | `done` |
| R23 | **"We collect nothing" is not true of the web platform, and the policy must not say it.** The brief was that Backing & Score collects no user data; the schema says otherwise, and a policy that under-claims is as false as one that over-claims. Actually stored: account name / email / avatar / bio (`users`), **IP address and user-agent per sign-in** (`sessions`, written by better-auth), practice records — duration, tempo, Wait Mode score, MIDI-or-mic (`practice_sessions`, written from `actions/v5/gamification.ts`), XP and streaks (`user_stats`), social content, and Polar subscription state. The rewritten policy states each one and why the feature needs it, then says plainly what is *not* done: no analytics, no ad tech, no profiling, no sales, no reporting to publishers. That is both true and the stronger claim. **Does not affect StageScore itself** — the app still collects nothing. Orchestrator confirmed 2026-07-28: Sentry never configured (dropped from the provider list, replaced by a line saying no error monitoring runs), Polar still sandbox (payments written as not yet open), social feed off — verified in code as a private `_feed` route plus `socialFeed` defaulting false, so posts and comments came out. LiveKit and favourites stay: `/classroom/[id]/live` and the player and discover menus still reach them. **Live on production 2026-07-28** | `done` |
| R24 | **If streak / XP goes, the policy loses its most sensitive paragraph.** `practice_sessions` is the only row in R23 that records *what and how well you played* rather than what your account needs; it is also the only one a musician might not expect. The Orchestrator is weighing whether to disable it. Keeping it is defensible — the data is shown back to the player and goes nowhere — but disabling it removes a whole paragraph from `/privacy` and makes the "we store what your account needs" claim exactly true with no caveat. Decide before the policy deploys, since redeploying a privacy policy that has been public is a worse look than getting it right once. **Resolved 2026-07-28:** keep the feature, drop the storage. The audit found the table was **write-only** — one writer in `actions/v5/gamification.ts`, no reader anywhere — so streak and XP never needed it. Both inserts removed, the table removed from the schema, migration `0028_chemical_emma_frost.sql` generated (`DROP TABLE practice_sessions`), and the dead `APPWRITE_PRACTICE_SESSIONS_COLLECTION_ID` constant deleted. The policy now says the run is thrown away and only four running totals survive. Writes stopped on deploy 2026-07-28. **Migration applied — Orchestrator confirmed 2026-08-01 that `practice_sessions` is dropped on production.** Policy and database now agree | `done` |
| R21 | **No DMARC record on `backingscore.com`** (`_dmarc` is empty; root SPF is Cloudflare's, DKIM is Resend's). Not a store requirement, but Gmail and Yahoo have required DMARC from bulk senders since 2024, and every verification and password-reset mail the web app sends goes out under this domain. Start at `p=none` with a `rua=` address and watch the reports before tightening | `todo` |
| R11 | App Privacy / Data Safety forms. **For v1 this is a transcription job again:** both forms say **no data collected, no data shared, no tracking**, matching the two `PrivacyInfo.xcprivacy` files from R2, which are correct as they stand. Do not pre-answer for ads — the forms are filled per submission, and an early answer makes v1's declaration false. At 1.1 they gain the advertising ID, purchase history, the SDK manifests' entries and Play's "Contains ads" label; `NSPrivacyTracking` stays `false` even then, because declaring tracking would *require* an ATT prompt (App Review 5.1.2) that ADR 0018 decision 5 forbids — a constraint on the code, not a form field. **One answer that does apply at v1:** Play's *Target audience* is a separate form from the age rating, and it must say **13+** from the first submission (Security Review S2) | `todo` — v1 answers are known, see [`STORE-LISTING.md`](./STORE-LISTING.md) |
| R12 | Store listing: description, keywords, category (Music), age rating, **target audience 13+**, screenshots at every required size. The copy in [`STORE-LISTING.md`](./STORE-LISTING.md) **is the text we submit** — accepted 2026-07-28, store title updated 2026-07-31 to **`StageScore — Sheet Music`** on both stores (R5). **Screenshots complete 2026-08-01** (Orchestrator). Logo locked (R6). Library framed so a bottom banner in 1.1 costs one reshoot, not six | `done` |
| R13 | Bundled `assets/sample_score.pdf` — was a MuPDF-produced orphan binary printing **"StandScore spike"** on every staff, which shipped and is imported into the user's library by the Library's sample action. No text search could find it (compressed content streams). Regenerated from `tool/generate_sample_score.dart`: six A4 pages, empty staves, our own text. Rights question dissolves — we author it. | `done` |
| R14 | Android SDK levels: `compileSdk`/`targetSdk` 36, `minSdk` 24 from Flutter 3.44.6 defaults. Clears Play's current target-API floor | `done` |
| R15 | iOS deployment target: **not the mismatch it looked like.** Every target (Runner, ShareExtension, tests) already built at 14.0 and the Podfile pins 14.0; the 13.0 was a stale *project-level* default no target inherited. Aligned to 14.0 anyway so a future target cannot pick up 13.0 | `done` |
| R16 | Release-build smoke test on physical devices, both platforms: page turns, pedal, share-in, backup/restore, metronome audio. Needs hardware and an Apple signing identity | `todo` |
| R18 | `flutter build appbundle` warns *failed to strip debug symbols from native libraries*, and the AAB is 71 MB (pdfium plus the audio engine across ABIs). Under Play's limit, so not a blocker; revisit if download size matters. `flutter doctor` also reports Android licenses unaccepted (`flutter doctor --android-licenses`). **Measure again once the ads SDK is in** — it pulls in part of Play Services | `todo` |
| R25 | **Selling an in-app purchase needs tax and banking on file at both stores — no longer a v1 blocker, still the longest wait in the project.** Apple's Paid Applications Agreement has to be *active* before an IAP product can even be created (not merely before money arrives), Play needs a merchant account, and a Vietnamese entity files US tax forms (W-8BEN / W-8BEN-E) whose processing can take **up to 90 days**. v1 sells nothing, so this blocks **1.1** — but **start it now anyway**, because it depends on no code and on nobody here, and starting it late is the one way to make it block a release date. Steps in the runbook below | `human` — start now, blocks 1.1 |
| R27 | **1.1.** **RevenueCat has to be set up under `com.backingscore.scoreapp`, and the prototype's setup is in the way.** The Orchestrator chose RevenueCat over a bare `in_app_purchase` on 2026-07-30 (ADR 0018 decision 11), which promotes ADR 0017's question 6 from later-cleanup to release blocker: the existing configuration, IAP products and `premium` entitlement belong to `com.backingscore.app`, the dead Ionic prototype. StageScore needs its **own project** (the two identity models do not share cleanly — web links customers to `users.id`, StageScore stays anonymous), its own `no_ads` entitlement, and no `Purchases.logIn` anywhere. Decide the fate of the old bundle at the same time | `human` |
| R26 | **1.1, and by necessity rather than by choice. AdMob account plus `app-ads.txt` at the root of `backingscore.com` — this cannot finish before launch.** The file declares that `com.backingscore.scoreapp` may sell inventory under that domain. It lives in the **web repo** (ADR 0012 — no CI joins the two), so it is hand-checked at submit like the privacy and support pages. **What changed on 2026-07-30:** since January 2025 AdMob *requires* new apps to be verified with `app-ads.txt`, verification requires AdMob to crawl the developer website **from a published store listing**, and an unverified app "won't be able to fully serve ads". So the sequence is forced — publish, then verify, then AdMob's app readiness review, then fill. **v1 launches with the ad layer serving nothing** (ADR 0018 decision 13), and the account work below is everything that *can* be done beforehand | `todo` — steps 1–6 now, the rest after launch |

---

## v1 submission runbook

Written 2026-07-30, when ads went back to 1.1 and v1 became a short list again.
Updated 2026-07-31: R5, R6 and R9 closed. Updated 2026-08-01: R24 and R12
closed (`practice_sessions` dropped; screenshots shot). Health check
2026-07-30 still holds: **`flutter analyze` clean, 365/365 tests green**, and
`/privacy`, `/support`, `/stagescore` all returning `200`. What is left is
R16 (device smoke) and store forms.

**Closed 2026-07-31 — no longer gates.**

1. **R6 — logo locked** to `stagescore/assets/brand/stagescore-logo.png`. Icons
   and splash already match; screenshots may proceed.
2. **R5 — name settled.** "StageScore" is registered. Store title on both
   stores: **`StageScore — Sheet Music`**. Installed name stays **`StageScore`**.
3. **R9 — two `wont`s accepted for v1:** fit height (0041) and max page DPI
   (0031).

**In parallel — none of these depends on another.**

4. **R16 — release-build smoke test on real hardware, both platforms.** Page
   turns, Bluetooth pedal, share-in, backup/restore, metronome audio. Needs an
   Apple signing identity. This is the only check that exercises what the tests
   cannot, and R17 is the standing reminder that a debug run proves nothing
   about a release build.
5. ~~**R12 — six screenshots.**~~ **Done 2026-08-01** — shot from the list
   in [`STORE-LISTING.md`](./STORE-LISTING.md).
6. ~~**R24 — apply migration `0028`.**~~ **Done 2026-08-01** —
   `practice_sessions` dropped on production; `/privacy` and the DB agree.

**Store setup, once the above is moving.**

7. Apple Developer → register the App ID **`com.backingscore.scoreapp`**;
   App Store Connect → create the app. Name field:
   **`StageScore — Sheet Music`**. **No IAP capability needed for v1** — that
   is 1.1, and it is what R25 unlocks. Home-screen label comes from the binary
   (`CFBundleDisplayName` = `StageScore`) and is not this field.
8. Play Console → create the app with the same package name. Title:
   **`StageScore — Sheet Music`**. Launcher label stays `StageScore`.
9. Fill the store forms from [`STORE-LISTING.md`](./STORE-LISTING.md), which is
   the accepted text: names, description, keywords, category Music, age rating
   4+/Everyone, and **target audience 13+** — a *separate* form, and answering
   it wrong is expensive later (Security Review S2).
10. R11 — App Privacy and Data safety: **no data collected, no data shared, no
    tracking**, matching the two `PrivacyInfo.xcprivacy` files. Do not
    pre-answer for ads.
11. URLs: privacy `https://backingscore.com/privacy`, support
    `https://backingscore.com/support`, marketing
    `https://backingscore.com/stagescore`. All three verified live. **Fill the
    marketing field even though v1 does not need it** — at 1.1 AdMob crawls that
    hostname to find `app-ads.txt`, and an empty field means the clock never
    starts (R26).
12. Build and upload. `flutter build appbundle --release` signs from
    `android/key.properties` (R1); on a machine without that file the build
    comes out **unsigned by design**, so check `jarsigner -verify` before
    uploading. R18's *failed to strip debug symbols* warning and the 71 MB size
    are known and not blocking.

**On launch day:** change the "coming soon to the App Store and Google Play"
line on `/stagescore` (R20) to the real store links.

**Not blocking v1, worth doing when convenient:** R21 (DMARC at `p=none` — not a
store requirement, but every verification mail from the web app goes out under
this domain) and R18 (measure again when the ads SDK lands).

---

## Account and paperwork runbook — **1.1** (R25 / R26 / R27)

Written 2026-07-30 while ads were briefly in v1; kept intact because it is the
same work, just later. **None of it blocks v1.** Track A should still start
today, because its wait is measured in weeks and nothing here can shorten it;
Track C can start whenever; Track B *cannot* finish before v1 is published, by
Google's own rule (ADR 0018 decision 13).

### Track A — the money (R25). Longest lead time in all of v1.

Apple, strictly in order, because each step unlocks the next:

1. Confirm the Apple Developer Program membership is **active** and that you hold
   the **Account Holder** role. Nobody else can sign the agreement.
2. App Store Connect → **Business → Agreements** → the **Paid Apps** row →
   *View and Agree to Terms*.
3. Signing is what makes the tax forms appear. **Every developer completes a US
   tax form regardless of country.** A Vietnamese entity is then routed to
   W-8BEN-E (company) or W-8BEN (individual) by a questionnaire — answer the
   questions, do not pick the form yourself.
4. **Banking cannot be entered until the tax forms are submitted.** Add the bank
   account; if an Admin or Finance role enters it, the Account Holder has to
   approve it before it processes.
5. Watch the status. Once the setup is complete the agreement usually goes
   **Active within about 24 hours** — but **tax form processing can take up to
   90 days** in the bad case. That spread is the entire reason this track starts
   before anything else. If the status lingers, the cause is a form still under
   review, not a failed signature; one incomplete form holds the whole contract.
6. **Until the agreement is Active you cannot create the IAP product at all** —
   not "cannot get paid", cannot create.

Google, in parallel:

7. Play Console → **Setup → Payments profile** → create or link a Google
   payments merchant profile. The same US tax paperwork applies.

App records, needed by Track C rather than by the money:

8. Apple Developer → Certificates, Identifiers & Profiles → register the App ID
   `com.backingscore.scoreapp` **with the In-App Purchase capability**.
9. App Store Connect → create the app with that bundle ID.
10. Play Console → create the app `com.backingscore.scoreapp`.

### Track B — AdMob (R26). Short, but read ADR 0018 decision 13 first.

1. Create the AdMob account. It is a Google account and can share the Play
   payments profile.
2. Add **two** apps — iOS and Android — both `com.backingscore.scoreapp`. Answer
   that the app is *not yet listed on a store*; you get the App IDs immediately,
   and those are what go in `AndroidManifest.xml` and `Info.plist`. **A missing
   AdMob App ID crashes the app at launch**, it does not merely disable ads.
3. Create one **banner** ad unit per platform, named for the surface it serves
   (`library-banner-ios`, `library-banner-android`).
4. **Turn auto-refresh off on both units.** A console setting, so it never
   appears in a diff and no code review can catch it — and with it on, the
   banner keeps requesting over the network while a musician is playing, because
   Library stays mounted under the Score route (Spec 0051, G3 #5).
5. Blocking controls → ad content rating **G**. It has to match the age rating
   filed in R12.
6. Publish `app-ads.txt` at the root of `backingscore.com` (**web repo**) with
   the exact line AdMob shows in the account — the `google.com, pub-<id>,
   DIRECT, <cert>` form. Check it by fetching `https://backingscore.com/app-ads.txt`
   in a browser.
7. **Then stop, and do not read the unverified warning as a mistake.**
   Verification needs AdMob to crawl the developer website from a *published*
   listing, so the rest — crawl, *Verify app*, the app readiness review — only
   happens after launch. Budget at least 24 hours from the listing going live,
   realistically longer.

### Track C — RevenueCat (R27). Blocked on Track A's app records, not on its money.

1. Create a **new RevenueCat project** for StageScore. Do not reuse the
   prototype's. While you are in there, rename the old project so it says Ionic
   prototype / web — the confusion this prevents is the one R27 exists for.
2. Add two apps: App Store (bundle `com.backingscore.scoreapp`) and Play Store
   (package `com.backingscore.scoreapp`).
3. Apple credentials: App Store Connect → **Users and Access → Integrations →
   In-App Purchase** → generate a key, download the `.p8`, copy the Issuer ID,
   upload both to RevenueCat. **Apple shows the `.p8` once.**
4. Google credentials: a Google Cloud **service account** with Play Developer
   API access, granted permission in Play Console; download the JSON key and
   upload it to RevenueCat.
5. Create the product in **both stores** with the identical id **`remove_ads`** —
   non-consumable on Apple, one-time managed product on Play. Needs Track A
   step 6 on the Apple side.
6. In RevenueCat: entitlement **`no_ads`**, both products attached, and an
   Offering (`default`) with a package holding the product. Without an Offering,
   `getOfferings` returns nothing and the buy button has nothing to sell.
7. Copy the two **public** SDK API keys, one per platform. They are public by
   design and are the only keys the app carries.
8. Test accounts: an Apple **sandbox tester** (Users and Access → Sandbox), and
   on Play a **licence tester** plus a build on the internal track.

### What the code actually waits for

Much less than the three tracks above, because Spec 0051 puts both SDKs behind
ports with fakes:

| Work | Needs |
|------|-------|
| Phase 1 — entitlement port, cache, guard tests, About rows, every widget test | **nothing external** |
| Phase 2 — wire AdMob | App IDs and unit ids (Track B 1–3); Google's test units work before any of it |
| Phase 2 — wire RevenueCat | the two public SDK keys (Track C 1–7) |
| G4 — a real sandbox purchase | Track A complete, plus Track C 5 and 8 |
| Real ad fill | after launch — explicitly **not** a G4 criterion |

Before any of it, two gates, both the Orchestrator's and both free of external
dependencies: **ADR 0018 → `accepted`**, then the **Security Review**.

---

## Not blocking v1

| Item | Where it lives |
|------|----------------|
| Phase C slices 0037–0039 | `IMPROVEMENT-ROADMAP.md` — now 1.1 |
| SmartMode / Transport / BackingTrack / OMR | ADR 0008, Phase D gate |
| Cloud sync, multi-device | later product decision |
| Max page DPI | cut with 0031 |
