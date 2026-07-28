# 0042 — StageScore reads as part of Backing & Score

- **Status:** accepted
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0009, **0010 (accepted 2026-07-28 — it had to land first)**
- **Depends on Specs:** 0035 (the sheet idiom this reuses), 0040 (the Library rows and empty states it edits), 0027 (backup naming, already branded)
- **Release rows touched:** R10 (privacy / support URLs), R12 (store listing)
- **Number note:** 0036–0039 are reserved by the accepted roadmap; 0040 and 0041 are done. 0042 is the next free number.
- **G3:** accepted (2026-07-28), ships in **v1**
- **G3 notes:** Answers to the seven questions below. **Q1** the ampersand — ADR 0010 accepted the same day. **Q2** tappable, so `url_launcher` is in and the Android `<queries>` entry with it. **Q3, Q4, Q5** as recommended: one line plus one sentence, `package_info_plus` rather than a constant, and the empty-state line stays. **Q6 not taken** — the accepted scope is About + empty state + listing + sweep, so the Library app bar keeps the mark alone and the wordmark question stays open for a later slice. **Q7** v1.

## Problem

**Nothing a musician reads inside StageScore says who makes it.** Grepping `lib/` for the publisher name, the domain, or any ecosystem word returns zero hits. The app is a product of Backing & Score in the ADRs, in the bundle ID, and in the README — three places no user will ever open.

The Library app bar is the clearest case. It carries the mark and nothing else:

```dart
title: Semantics(
  label: 'StageScore',
  child: ClipRRect(... Image.asset('assets/brand/stagescore-logo.png', height: 32 ...)),
),
```

A 32-pixel teal square. Even the product's own name is only in the accessibility label, and the publisher is nowhere.

**There is no About screen, which is where ADR 0009 parked the publisher.** 0009 says in as many words: *"BackingScore can appear in About / legal; StageScore is the app-facing name."* The Library ⋯ menu has exactly three entries — Appearance…, Backup…, Restore… — so the place that decision points at does not exist. A consequence of the same gap: **the app never shows its version**, so a musician reporting a problem cannot say which build they are on, and we are about to ship to two stores where that is the first question support asks.

**The store listing is unwritten and is the biggest surface of all.** R12 is still `todo`. Most people who ever read a sentence positioning this app will read it there, before install, not after.

**The link is one-directional at best.** `backingscore.com`'s codebase does not mention StageScore anywhere — zero hits across `apps/web`. Telling a musician in the app that this belongs to a larger ecosystem, when the ecosystem's own site does not list it, is a claim they cannot check. That half is another repo's work, but the Spec that makes the claim should name the dependency.

**And the name itself is spelled two ways.** The repo says *BackingScore*; the shipped web product says *Backing & Score* everywhere. Printing the wrong one into a store listing is the expensive version of this mistake. ADR 0010 exists to settle it first.

## Outcome

A musician can tell, in their first minute with StageScore, that it comes from **Backing & Score** and roughly what else that gets them — and can find the version, the site, and support when something goes wrong. While they are playing, they see none of it.

## Principle this slice commits to

Brand belongs in **low-frequency, high-attention** places: the store listing, first run, and About. It does not belong on stage. PdfMode and PerformanceMode stay silent, and an automated guard test keeps them that way rather than a note in a review checklist.

## Screen geometry (mental model)

```text
Library ⋯ today          Library ⋯ proposed        About sheet
┌──────────────────┐     ┌──────────────────┐      ┌─────────────────────────────┐
│ Appearance…      │     │ Appearance…      │      │ About StageScore      Done  │
│ Backup…          │     │ Backup…          │      ├─────────────────────────────┤
│ Restore…         │     │ Restore…         │      │  ▣  StageScore              │
└──────────────────┘     │ About StageScore…│      │     Version 1.0.0 (4)       │
                         └──────────────────┘      │                             │
                                                   │  Part of Backing & Score —  │
Scores empty state, added line                     │  interactive scores, backing│
┌───────────────────────────────────┐              │  tracks and classrooms on   │
│        🎵  No scores yet          │              │  the web.                   │
│  Import PDF sheet music from your │              │                             │
│  device to build your library.    │              │  🌐 backingscore.com      → │
│         [ Add PDF ]               │              │  🔒 Privacy policy        → │
│      Add sample score             │              │  ✉️  Support              → │
│                                   │              └─────────────────────────────┘
│  A Backing & Score app        ←   │  new, quiet, one line
└───────────────────────────────────┘
```

## In scope

- **An About sheet**, opened from Library ⋯, built on the 0035 idiom (bottom sheet, title + **Done**, sized to content). It shows: the mark and product name; the version and build number **read from the bundle, not typed into a string**; one line naming Backing & Score and one sentence on what the web side does; and rows for the site, the privacy policy, and support.
- **One quiet publisher line in the Scores empty state** — the only screen every new install passes through, and the only one with room to spare. The Setlists empty state does not get one; by then they already know.
- **A store listing draft (R12)** whose first sentence names the ecosystem, recorded next to the release checklist so submission is copy-and-paste rather than improvisation.
- **The ADR 0010 spelling sweep**: `pubspec.yaml` description, `AGENTS.md`, `CONTEXT.md`, `VISION.md`, both READMEs. Prose only; no identifier moves.

## Out of scope

- Accounts, login, sync, or any StageScore ↔ backingscore.com data path. Nothing in this slice makes a network call except handing a URL to the system browser.
- Any brand string in PdfMode, PerformanceMode, or the ScoreMenu.
- In-app web content, embedded webviews, deep links, or "open this Score on the web".
- The **reverse cross-link** — listing StageScore on backingscore.com. Different repo, and the more valuable half of the ecosystem story; raise it with that team as a sibling task.
- Splash and launcher wordmark. The generated assets come from the logo, and R6 (logo lock) owns that decision.
- **Localisation.** StageScore is English-only while the web product ships nine locales, Vietnamese included. That is a real gap between the two products and a slice of its own, not a rider on this one.

## Domain terms

No G1 needed. "Backing & Score" is a brand, not domain language, and belongs in the ADR rather than `CONTEXT.md`. The Spec otherwise reuses **Score**, **Setlist**, **PdfMode**, **PerformanceMode**, and **ScoreMenu** as defined there.

## Acceptance criteria

- [ ] Library ⋯ carries an **About StageScore…** entry; opening it shows the sheet and **Done** closes it
- [ ] The sheet shows the version **and** build number, sourced from the bundle — a test proves it is not a literal by asserting it matches what the platform reports
- [ ] The sheet names Backing & Score in the spelling ADR 0010 settles, with no feature claim StageScore itself does not deliver
- [ ] Site, privacy, and support rows each open in the system browser; on a device with no browser or no network the app shows a message and does not crash
- [ ] The About sheet renders fully offline (no network call on build)
- [ ] The Scores empty state carries the publisher line; the Setlists empty state does not
- [ ] **Guard:** a widget test drives PdfMode with chrome shown, chrome hidden, and Draw active, and asserts the rendered tree contains no brand or URL string
- [ ] The store listing draft exists and its first sentence names Backing & Score
- [ ] No user-visible "BackingScore" left in docs or `pubspec.yaml`; identifiers unchanged and still `com.backingscore.*`

## UX notes

- About is a **sheet, not a route** — 0035 already taught the app that ⋯ entries open sheets, and a pushed screen for a static panel would be the odd one out.
- Copy must not promise what StageScore does not have. No sync, no account, no "continue on the web". One line of who, one sentence of what else exists.
- The empty-state line is a caption, not a banner: body-small, secondary colour, below the sample-score button, not competing with **Add PDF**.

## Technical constraints

- **Offline-first (VISION).** Nothing here may block first paint on a network result.
- Two candidate new dependencies, both pending G3: `package_info_plus` (version and build) and `url_launcher` (the three rows). Neither adds a runtime permission.
- If `url_launcher` is taken, Android 11+ package visibility needs a `<queries>` entry for `ACTION_VIEW` + `https` in the manifest, or the links silently no-op in the release build. Worth naming here because a debug run on an older device would not catch it.
- iOS: opening `https` needs no `LSApplicationQueriesSchemes` entry, and neither dependency changes the R2 privacy manifests. Re-verify at build rather than assuming.

## Test plan

- **Automated:** the ⋯ entry and sheet contents (extending `library_screen_test.dart`); the empty-state line; the version-not-a-literal assertion; the PdfMode silence guard across three chrome states.
- **Manual demo:** fresh install → empty state shows the line → About opens → each of the three rows lands on the right page → airplane mode → About still opens and a tapped link fails gracefully.

## Build notes (three deviations from the G3 draft)

1. **The PdfMode guard is a source check, not a widget test.** `PdfModeScreen` cannot be pumped at all — pdfrx needs the native viewer, which is why `pdf_mode_chrome_layout_test.dart` characterises a stub — so a widget assertion would have proved something about the stub and nothing about the screen that ships. `brand_reach_test.dart` instead walks `lib/` and fails if the publisher string, the domain, or `Brand.` appears outside `brand.dart`, `about_sheet.dart` and `library_screen.dart`. It is the stronger invariant anyway: it also catches the *duplication* that put "StandScore" on the Android launcher.
2. **Support is an address, not a page.** The site has `/privacy` and `/terms` but no support route; the address published on its own legal pages is `support@backingscore.com`, so the row opens a `mailto:` with a pre-filled subject. That needs a second Android `<queries>` entry (`SENDTO` + `mailto`) alongside the `https` one, for the same package-visibility reason.
3. **Brand strings got their own module**, `lib/brand/brand.dart`, rather than living in the About sheet. Two consumers already exist (About and the empty state) and the listing copy is a third reader off-code; one definition is the rule the library root already follows.

Both new dependencies turned out to be **promotions of existing transitive ones** — `share_plus` already pulled `url_launcher` and `package_info_plus` into the lockfile — so nothing new entered the dependency graph.

## G3 questions (recommendation given for each)

1. **Spelling — "Backing & Score" or "BackingScore"?** *Recommend:* the ampersand, per ADR 0010, since it is what the ecosystem already ships. This one blocks the rest.
2. **Tappable links or copyable text?** *Recommend:* tappable, via `url_launcher`. R10 needs a reachable privacy policy and support URL for both stores anyway, and About is the natural home for them; a URL a musician has to retype on a tablet is a dead end.
3. **How much ecosystem does the copy describe?** *Recommend:* one line plus one sentence. A feature list rots the moment the web product ships anything, and this app cannot deliver any of it.
4. **Version source — `package_info_plus` or a generated constant?** *Recommend:* the package. A constant is a second source of truth against `pubspec.yaml` and will drift on the first hotfix.
5. **Does the empty state get the line, or is About enough?** *Recommend:* the line. Nobody opens ⋯ → About on their first run, which is the only moment this message has to land.
6. **Does the Library app bar gain a "StageScore" wordmark next to the mark?** *Recommend:* only if it fits — the bar already holds sort-with-label, filter, labels, and ⋯, and a 360 dp phone may not have the room. Measure before committing, and the publisher line never goes here.
7. **v1 or 1.1?** *Recommend:* v1. The naming decision and the listing copy are release-checklist rows already open, and the About sheet is additive, offline, and testable — but it is a scope call on a build the Orchestrator has decided to ship, so it is yours.
