# 0034 — Performance mode (hide AppBar + PageNavBar while viewing)

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0015 (done — reopens its “chrome always visible” cut); 0031 (done); 0032 (done); 0033 (done)
- **Parity IDs:** Q2 (roadmap B1)
- **G3:** accepted (2026-07-26)
- **G3 notes:** Reopens 0015’s “chrome always visible” cut. Entry = PdfMode ⋯ → **Display…**; app-wide, default **on** (Orchestrator, 2026-07-26 — stage-first default; existing installs inherit it). `showChrome` gesture: reveal when hidden, open ⋯ when visible; label “Show menu / chrome”. Auto-hide **5 s**, fixed. No page indicator while hidden (revisit in B3). Chrome as overlay over a constant-size viewer; Draw mode keeps today’s laid-out chrome.
- **G4:** pass (2026-07-26)

## Problem

On the stand, PdfMode still looks like a settings app: an `AppBar` (title, Draw, ⋯) is glued to the top and a `PageNavBar` (page label + scrubber) to the bottom of every Score, on every layout, at all times. They eat vertical space that the Score needs, and they put editing affordances in the musician’s eyeline during a piece. Spec 0015 deliberately cut immersive chrome (“StandScore keeps chrome visible”) because no reveal path existed yet — but 0015 also shipped **GestureMap**, whose `showChrome` action and “at least one input must be Show menu” rule now guarantee that reveal path. Roadmap B1 reopens the cut.

## Outcome

With **Performance mode** on, opening a Score in PdfMode shows the page and nothing else — no AppBar, no PageNavBar. A GestureMap input (default: long-press or top-edge tap) **reveals** the chrome; it hides again on its own after a few seconds or as soon as the musician goes back to the Score. PageTurn, pedal, pinch/zoom (0033), Jump Links and Draw all behave exactly as they do today. With Performance mode off, PdfMode looks and behaves exactly as it does now.

## Screen geometry (mental model)

```text
Performance mode ON, chrome hidden        after reveal (auto-hides ~5 s)
┌─────────────────────────────┐           ┌─────────────────────────────┐
│                             │           │ ‹ Title      ✏  ⋯          │ ← AppBar overlay
│                             │           ├─────────────────────────────┤
│           SCORE             │           │           SCORE             │ ← same size, not reflowed
│      (full body height)     │           │      (full body height)     │
│                             │           ├─────────────────────────────┤
│                             │           │ 3 / 12  ─────●───────       │ ← PageNavBar overlay
└─────────────────────────────┘           └─────────────────────────────┘
```

The viewer keeps the **same** size in both states; chrome floats over it. Reveal must not re-fit or scroll the Score.

## In scope

- `performanceMode` preference (on/off), app-wide, default **on**, persisted with the other PdfMode display prefs
- Entry point: PdfMode ⋯ → **Display…** (the 0032 sheet), one switch + one-line helper
- When on: AppBar and PageNavBar hidden on Score open; viewer gets the full body height
- First Score opened on an install keeps the chrome up (one-shot) with a snackbar naming the reveal gesture; later Scores open hidden
- Reveal via any GestureMap input mapped to `showChrome` (defaults from 0015: long-press, top edge)
- Auto-hide after a fixed idle timeout, and immediately on PageTurn / tap on the Score
- Chrome **pinned** (no auto-hide) while a menu, sheet or dialog opened from it is on screen
- Draw mode: chrome + DrawToolbar pinned and laid out normally while drawing; back to hidden on exit
- Animate reveal/hide (short fade/slide), no layout jump of the Score
- Works on Single / continuous / custom continuous / Half Page bodies
- Compose cleanly with 0032 system chrome prefs (status bar, avoid notches)
- One Score surface (`pdfSurfaceColor`) for gutters, margins and safe-area bands: paper white in light themes, dark surround in dark themes, so the hidden-chrome view is not a boxed-in Score
- That surface follows the 0025 Color filter (surfaces painted outside the filtered subtree get the matrix applied by hand)

## Out of scope

- ⋯ menu grouping / IA (**B2 — 0035**)
- “Stage preset” bundle (lock on + status bar off + performance mode) and Page-scale copy (**B3 — 0036**)
- Transient page-number indicator on pedal turns with chrome hidden (see G3 option 4)
- New GestureMap inputs (left/right edges) or new GestureMap actions
- Per-Score or per-Setlist performance-mode preference
- Library screen chrome
- Auto-hide **timeout** as a user setting (fixed constant this slice)
- Anything SmartMode / Transport (ADR 0008)

## Domain terms

**PdfMode**, **PageTurn**, **GestureMap** (already defined as “show chrome, enter draw, disabled”), **Score**, **Setlist**

**PerformanceMode** added to `CONTEXT.md` at G3 accept (G1).

## Decisions locked at G3

| # | Question | Locked |
|---|----------|--------|
| 1 | What does a `showChrome` gesture do when chrome is already visible? | **Open the ⋯ menu** (0015 behavior). Hidden → reveal only. One input, sensible in both states. |
| 2 | Gestures settings label for the action | Relabel **“Show menu”** → **“Show menu / chrome”**; enum `GestureMapAction.showChrome` unchanged. |
| 3 | Auto-hide idle timeout | **5 s**, fixed constant, no setting. |
| 4 | Page feedback while hidden (pedal turns) | **Cut this slice.** Reveal shows the scrubber; revisit in B3 if it hurts on device. |
| 5 | Default, and first open with no visible back button | **Default on** (stage-first). First Score on an install opens with chrome up + reveal-gesture snackbar, one-shot; fuller onboarding stays with C3 / 0039. |
| 6 | Bottom-edge tap entering Draw | **Draw dropped from GestureMap entirely** (Orchestrator, 2026-07-26). Landing in Draw from a stray tap is bad UX with or without Performance mode, so the action is gone from all three inputs and Draw is entered from the toolbar. Saved `enterDraw` assignments read back as Off, so installs need no migration step. |
| 7 | Header vs footer height | **AppBar 64 px, PageNavBar 48 px** (Orchestrator, 2026-07-26). The AppBar carries the title and every action; the PageNavBar carries one scrubber, so it drops to the minimum tap target and gives the Score the difference. Amended after device testing: the scrubber also keeps an 8 px gap below it, on top of the home-indicator inset — shortening the bar had put it flush against the strip the OS reads as a switch-apps swipe, and the drag stopped working. |

## Acceptance criteria

Testable checklist (G4):

- [x] Display sheet has a Performance mode switch; default **on**; survives app restart
- [x] Prefs saved before this Spec load with Performance mode on
- [x] With it off, PdfMode chrome behaves exactly as before this Spec
- [x] The very first Score opened shows the chrome plus the reveal-gesture snackbar, then fades
- [x] Every Score opened after that shows no AppBar and no PageNavBar
- [x] With it on, the Score is taller by the height of the removed chrome
- [x] A `showChrome` GestureMap input reveals AppBar + PageNavBar
- [x] Revealed chrome hides again after the idle timeout with no interaction
- [x] Revealed chrome hides immediately on PageTurn or a tap on the Score
- [x] Chrome stays visible while the ⋯ menu or a sheet opened from it is open
- [x] Entering Draw shows chrome + DrawToolbar and keeps them until Draw exits
- [x] Reveal/hide does not change page, scroll position or zoom
- [x] Pedal / keyboard PageTurn (0005) works with chrome hidden
- [x] Zoom lock (0031), pinch + double-tap (0033), Jump Links and Half Page unaffected
- [x] Status bar / avoid-notches prefs (0032) still apply in both states
- [x] With chrome hidden, no colour band reads as a bar above or below the Score

## UX notes

- Switch copy: **Performance mode** — “Hide the toolbar and page bar while you play. Long-press or tap the top edge to bring them back.”
- Helper must name the user’s **own** GestureMap mapping if it differs from the default
- Keep one reveal concept — do not add a second “tap anywhere to reveal”, which would fight PageTurn tap zones (0003)
- Do not gate the back navigation behind anything but reveal; leaving a Score must stay one reveal + one tap

## Technical constraints

- Render AppBar / PageNavBar as **overlays** over a constant-size body while performance mode is on, rather than adding/removing them from the `Column`. Removing them from layout resizes the viewer and makes `pdfrx` re-fit — that is the jump this Spec must avoid.
- Use a `Stack`, not the Scaffold `appBar` / `bottomNavigationBar` slots with `extendBody*`: those slots inflate the body’s `MediaQuery.padding` by the chrome height, so the viewer’s `SafeArea` clears an AppBar the musician cannot see.
- While performance mode is on the viewer keeps the **top** inset (the notch is a cutout) and drops the **bottom** one (the home indicator is an overlay bar). The bottom strip is where the right-hand PageTurn tap zone lives once the PageNavBar is hidden, so it must stay live.
- Draw mode is the exception: keep today’s laid-out AppBar + DrawToolbar (one reflow on enter/exit, same as today).
- Extend `DisplayPrefs` / `DisplayPrefsStore` (0032) rather than adding a new prefs file; keep JSON back-compat (`performanceMode` defaults false when absent).
- Chrome visibility is **runtime** state on `PdfModeScreen` — not persisted; Scores open hidden apart from the one-shot first-open reveal, whose `performanceHintShown` flag lives with the display prefs (same pattern as `PageTurnPrefs.hintShown`, Spec 0003).
- Reuse `_onGestureMapAction` and the existing edge-band helpers; no new gesture recognizers, no change to the gesture arena fixed in 0033.
- Cancel the auto-hide timer on dispose and while pinned.

## Test plan

- Automated: `DisplayPrefs` round-trip + default for `performanceMode`; widget test that chrome is absent when on and present when off; reveal via simulated GestureMap action; auto-hide via `FakeAsync`/`pumpAndSettle` past the timeout; pinned-while-drawing test
- Manual: on device — open Score in performance mode, run a 3-page piece with pedal, reveal → ⋯ → Display, draw and exit, Half Page, status bar off + notch avoid on, restart
