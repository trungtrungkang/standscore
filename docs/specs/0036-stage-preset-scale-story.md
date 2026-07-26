# 0036 — Stage preset, the scale story, and the hidden page indicator

- **Status:** accepted
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0031 (done — owns page scale + zoom lock); 0033 (done — owns pinch / double-tap); 0032 (done — owns Display and the chrome toggles); 0034 (done — deferred the page indicator here); 0035 (done — the ScoreMenu these entries live in)
- **Parity IDs:** Q4 (roadmap B3)
- **G3:** accepted (2026-07-26)
- **G3 notes:** Recommendations taken, with the preset revised at G3: **one ScoreMenu entry whose label flips with the current state**, in the **Playing** group — not two sibling entries in View. It follows the Show/Hide annotations idiom already in the menu, keeps every group inside 0035's four-entry ceiling, and "get ready to play" is a Playing verb, not a View one. Zoom lock stays in the bundle but is the first thing to cut if it feels wrong on device.

## Problem

Three loose ends, all about the same thing: the musician cannot tell what the app will do to the page when they touch it.

**Nobody knows what "Page scale" is.** There are two ways to change how big the music looks and they behave nothing alike. Pinch (0033) is transient, applies to what is on screen, and vanishes. Page scale (0031) is a persisted setting with a scope — Fixed, Per Score, or Per Page — that survives a restart. The sheet explains neither. Its lock switch says *"Lock zoom — Disables pinch and double-tap scale"*, which is accurate about the mechanism and silent about the point, which is that the music stays exactly where you left it when your sleeve brushes the screen mid-piece.

**The "get ready to play" moment takes five taps.** Performance mode, status bar, avoid notches, zoom lock and page scale are five switches across two sheets, and the musician wants them in one gesture before a set — then wants them *back* afterwards, because the settings that are right on stage (chrome hidden, zoom locked) are wrong while marking up a part at the kitchen table. Since 0034 flipped the app-wide defaults to stage-first, the missing move is arguably the return trip, not the departure.

**Chrome hidden means position hidden.** 0034 deferred this here in as many words: with the PageNavBar gone there is no page number anywhere, so a pedal turn that misfires — or a Half Page turn that moved half as far as expected — is invisible until the musician recognises the music. They asked "did that work?" and the app does not answer.

## Outcome

A musician can put the app into playing shape (and back) in one action, can read what page they are on after a turn without bringing the chrome back, and can tell from the Page scale sheet what pinch will and will not do to their setting.

## In scope

- A **preset** that applies the playing-shape settings in one action, and the same entry taking you back out
- Rewritten copy on the Page scale sheet: what the scope means, how pinch relates to it, what lock buys
- Copy on the lock switch stated as an outcome ("the music stays put") rather than a mechanism ("disables pinch")
- A **transient page indicator** shown on page change while chrome is hidden (0034)
- Wherever these live in the ScoreMenu (0035) and the Display sheet (0032), including their inline state

## Out of scope

- New scale capabilities: no new scopes, no new range, no per-Setlist bulk apply, no DPI (still deferred from 0031)
- Changing pinch or double-tap behaviour (0033) — this Spec explains it, it does not alter it
- Changing what Performance mode does (0034), only how it is switched on and off in a bundle
- A persistent page indicator, or any page indicator while chrome is visible (the PageNavBar is right there)
- Onboarding, coach marks or a tour (**C3 — 0039**)
- Per-Score presets, or presets the user can define

## Screen geometry (mental model)

```text
Page scale sheet today              proposed
┌──────────────────────────────┐    ┌──────────────────────────────┐
│ Page scale                   │    │ Page scale                   │
│ Scope  [Fixed|Score|Page]    │    │ How big the music is drawn,  │ ← what it is
│ Scale         1.00×          │    │ and it is remembered.        │
│ ──────●───────────           │    │ Applies to  [Fixed|Score|Page]│
│ [x] Lock zoom                │    │ Scale         1.00×          │
│     Disables pinch and       │    │ ──────●───────────           │
│     double-tap scale         │    │ [x] Keep this scale          │
└──────────────────────────────┘    │     Pinch and double-tap are │ ← relationship
                                    │     off, so nothing drifts   │
                                    └──────────────────────────────┘

chrome hidden, after a turn
┌──────────────────────────────┐
│                              │
│         (the Score)          │
│                        ┌────┐│
│                        │12/56││ ← fades after ~1.5 s
└────────────────────────┴────┘┘
```

## Domain terms

**PdfMode**, **PerformanceMode**, **PageTurn**, **Score**, **ScoreMenu**

A preset that bundles existing settings may want a name in `CONTEXT.md` at G1 — named **StagePreset** in `CONTEXT.md` at G1; *avoid*: stage mode, gig mode, performance mode (taken by 0034 and a different thing).

## Open questions for G3

| # | Question | Recommendation |
|---|----------|----------------|
| 1 | Is the preset a **mode** (a switch that owns the settings) or an **action** (a button that sets them)? | **An action.** A mode shadows five switches that stay independently flippable, and then has to answer "what happens when I turn Performance mode off while Stage preset is on" — a question with no good answer. A button plus **Undo** in the snackbar covers the misfire case without inventing a second source of truth. |
| 2 | One preset or two? | **One entry, two directions.** The label flips with the current state — "Set up to play" unless the prefs already match the play bundle exactly, in which case "Set up to practise". Same idiom as Show/Hide annotations, and no stored state: the label is derived from the switches themselves. Both directions matter — since 0034 the defaults are already stage-shaped, so the genuinely missing move is the way back, with chrome up and zoom unlocked for marking up a part. |
| 3 | What is in each bundle? | **Play:** Performance mode on, status bar hidden, zoom lock on, page scale untouched. **Practise:** Performance mode off, status bar shown, zoom lock off. Neither touches page borders, layout, colour filter or page order — those are taste, not stage readiness. Page scale is a number the musician chose; a preset must not overwrite it. |
| 4 | Where does the preset live? | **ScoreMenu → Playing**, above Metronome…. Getting ready to play is a Playing verb, not a question about how the page looks; View is also already at 0035's four-entry ceiling. Not the AppBar (0035 decision 3 promoted nothing) and not the Display sheet, which holds the individual switches — a shortcut past that sheet must not hide inside it. |
| 5 | Page indicator: when does it show? | **On page change only, while chrome is hidden**, fading after ~1.5 s. Not on tap, not on reveal (the PageNavBar answers then), and never persistent — a permanent badge is chrome by another name, which is what 0034 removed. |
| 6 | Is the indicator switchable? | **No setting.** It appears only in a state the musician opted into, lasts a second and a half, and costs nothing. A toggle for it would be the sixth switch in a Spec whose premise is that there are already too many. |
| 7 | Does the indicator show the Score's own page number or the PageOrder position? | **What the PageNavBar shows**, whatever that is (0011 / 0009) — two answers to "what page am I on" in the same app is worse than either answer. |
| 8 | Does "Keep this scale" stay the label for lock? | **Yes**, with the mechanism demoted to the subtitle. The ScoreMenu inline state (0035) keeps saying **Locked**, which is the word for the state; the switch is the word for the intent. |

## Acceptance criteria

Testable checklist (G4):

- [ ] One entry puts the app into playing shape: chrome hidden, status bar hidden, zoom locked
- [ ] The same entry, now reading the other way, brings it back: chrome visible, status bar visible, zoom unlocked
- [ ] The entry's label is derived from the current prefs, so flipping a switch by hand changes what it offers next
- [ ] Neither action changes page scale, layout, page order, colour filter or borders
- [ ] Undo restores every setting the preset changed, and only those
- [ ] The individual switches still work after a preset, and disagree with it freely (no mode to fight)
- [ ] Both actions survive a restart — they set the same persisted prefs the switches do, not a parallel state
- [ ] With chrome hidden, turning the page shows the position briefly and it fades on its own
- [ ] The indicator does not appear while chrome is visible, and never blocks a PageTurn tap zone
- [ ] The indicator agrees with the PageNavBar, including under a custom PageOrder and Half Page
- [ ] The Page scale sheet says what the scope applies to and what happens to pinch when the scale is kept
- [ ] Reachable and readable on the smallest supported phone width, light and dark (0026)

## UX notes

- The preset entries are verbs, and they say what they will do — a musician should not have to open them to find out. If the label needs a tooltip, the label is wrong.
- The Undo snackbar is the only feedback needed; do not also show a dialog asking to confirm. It must clear itself: a message the musician has to dismiss is worse than no message while the stand is in use.
- The indicator is a small pill in the bottom-right, over the Score, at low opacity: legible at arm's length on a stand, ignorable at a glance. It must not sit where the right-hand PageTurn tap zone lives (0034 kept that strip live to the screen edge) — draw it, but let taps through.
- The scale copy should avoid the word "zoom" where it means "scale", and vice versa. Today the sheet uses both for both.

## Technical constraints

- The preset writes the same `DisplayPrefs` and page-scale prefs the switches write; it adds no persisted state of its own. Undo is the previous values held in memory for the life of the snackbar, not a stored history.
- The Undo snackbar must set `persist: false`. Flutter defaults `SnackBar.persist` to `action != null`, so an actionable snackbar never times out — here it would sit across the bottom of the Score, over the PageTurn tap zone 0034 keeps live to the screen edge.
- The indicator reads the page number from whatever the PageNavBar reads, so a PageOrder change cannot make the two disagree.
- The indicator's timer is separate from `PerformanceChrome`'s auto-hide countdown and must not restart it — showing the page number is not a reveal.
- Rendering the indicator must not add a hit-test target over the Score; PageTurn taps in that corner keep working (0034).

## Test plan

- Automated: applying each preset produces the expected prefs and leaves scale / layout / order / filter / border untouched; undo restores the prior values exactly; the indicator shows on page change only while chrome is hidden and hides itself; the indicator's timer does not touch the chrome countdown; the indicator's number matches the PageNavBar's under a custom PageOrder
- Manual demo: on device — from cold start, "Set up to play", play a few pages with a pedal and read the position after each turn; "Set up to practise", mark up a page without the toolbar hiding; open Page scale and have someone who has not read this Spec explain what Fixed / Per Score / Per Page means
