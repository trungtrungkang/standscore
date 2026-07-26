# 0041 — Layout modes: what each one is for, and which one this screen wants

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0004 (done — owns the four original modes); 0013 (done — owns the half-page peek and its separator); 0014 (done — owns Turn amount); 0003 / 0015 (done — own tap zones, swipe and the GestureMap); 0033 (done — owns pinch vs swipe); 0035 (done — owns the ScoreMenu row this sheet hangs off); 0036 (owns `pdfFitZoom`, which this Spec generalises)
- **Parity IDs:** P0.5 / P0.6 (**reopen candidates**), Q9 (new polish row)
- **G3:** accepted (2026-07-26)
- **G3 notes:** All nine recommendations taken as drafted. Fit height leaves the picker (`wont` on that half of P0.6, enum kept for restores); **Auto** is a real mode, default for new installs only, re-resolving on rotation and announcing itself once through the 0036 pill; tap zones and swipe gain a **Match layout** default rather than per-layout copies of the settings; Two pages on a viewport too narrow falls back to one page and says so, from `LayoutFit` rather than an orientation flag. **LayoutFit** added to `CONTEXT.md` (G1).
- **G4:** pass (2026-07-26)
- **G4 notes:** Two decisions were forced by the device run and are recorded above as build refinements: "a spread fits" and "a spread is free" are separate thresholds (see decision 6), and **decision 10** — the peek clips the next page at reading size instead of fitting a whole page into the band, which was the difference between the mode being free and the mode being worth having. Three page-reset faults were also fixed here rather than deferred, because two of them were exposed by Auto re-resolving on rotation: every viewer now opens on the authoritative page, and the screen no longer swaps Scaffold shape when Draw suspends PerformanceMode.

## Problem

PdfMode offers six layouts as six flat chips of equal weight:

```text
Single page · Two pages · Fit width (scroll) · Fit height (scroll) ·
Half page (top/bottom) · Half page (left/right)
```

Nothing in that sheet says what any of them is *for*, and two of the names describe a zoom rule ("fit width") that the app no longer implements as stated — since 0036 the fit is computed by `pdfFitZoom` and the persisted size belongs to Page scale (0031). What those two modes actually select is a **scroll direction**. The labels are lying about the setting.

Underneath the naming sits a bigger finding, and it is the reason this Spec exists.

**Which layout is right is not a taste. It is arithmetic the app can already do.** A PDF page has a fixed aspect ratio — √2 ≈ 0.707 wide-over-tall for A4, and near enough for most scanned parts. A viewport has one too. Compare the two and every layout question answers itself:

- **Viewport narrower than the page** (any phone in portrait) → the page is width-bound and there is *vertical* slack. Spend it on a peek of the next page. A spread is impossible.
- **Viewport the same shape as the page** (a 4:3 tablet in portrait) → no slack in either direction. One page, and everything else costs music size.
- **Viewport wider than the page** (anything in landscape) → the page is height-bound and there is *horizontal* slack, often half the screen. Spend it on a second page.

Two consequences, both measurable:

**Free peek.** The peek that Half page (top/bottom) shows costs nothing until it eats the vertical slack. The break-even is `1 − viewportAspect / pageAspect`. On a 393×852 phone that is **35%**, and the app's default separator is **28%** — so on the most common device in the world, Half page (top/bottom) draws the music at *exactly the same size as Single page* and throws in a quarter of the next page for free. Nobody is told this. On a 375×667 phone the free amount is only 20%, so the same default silently shrinks the music by 15%. Same setting, opposite outcome, no feedback either way.

**Wasted screen.** On a 1194×834 tablet in landscape, Single page draws a 589-pt-wide page and leaves **51% of the screen empty**, while Two pages draws each page 578 pt — 2% smaller for twice the music. Single page is close to a mistake there, and it is the default.

**Fit height has no job.** Its output is whatever the screen's aspect happens to produce: one page on a tablet in portrait (a duplicate of Single page), two across in tablet landscape (a duplicate of Two pages), three tiny ones on a phone in landscape, and on a phone in portrait a page **591 pt wide inside a 393-pt viewport** — a third of every system cut off, pannable only by hand. It is the one mode that cannot be described to a musician in terms of what they get.

**And the turn gesture ignores all of this.** Tap zones, the four swipe switches and Turn amount are one global set shared by six layouts whose pages move along different axes. Fit width scrolls vertically but is turned by a horizontal swipe and left/right tap zones; Half page (top/bottom) peeks vertically and is turned horizontally; Fit height scrolls horizontally *and* is turned horizontally, so the scroll drag and the turn gesture are the same motion competing in one gesture arena. Turn amount's Half is a silent no-op in three modes of six.

## Outcome

The Layout sheet names each mode by the job it does, says how it turns pages, and tells the musician which one this screen can actually afford — or picks it for them. Each layout's next/prev gesture runs along the axis its pages move. Nothing about zoom, scale or annotation changes.

## Screen geometry (mental model)

Rendered A4 page, per viewport (logical pt, margins ignored):

```text
                     phone portrait   phone landscape   tablet portrait   tablet landscape
                        393×852          852×393           834×1194          1194×834
viewport aspect          0.46             2.17              0.70              1.43
─────────────────────────────────────────────────────────────────────────────────────────
Single page            393×556          278×393           834×1180           589×834
                    35% height free  67% width free      fits exactly     51% width free
Two pages              193×273          273×386           409×578            578×819
                      unreadable        marginal        readable, tight    best on this
Half page (T/B 28%)    393×556           n/a             632×895              n/a
                     peek is FREE                      costs 24% of size
Fit height             591 wide         3 across         ≈ Single page      2 across
                    1/3 cropped         tiny           (duplicate)        (duplicate)
```

Proposed sheet:

```text
today                                proposed
┌────────────────────────────┐       ┌──────────────────────────────────────┐
│ [Single page] [Two pages]  │       │ Layout            Auto · Two pages   │
│ [Fit width (scroll)]       │       ├──────────────────────────────────────┤
│ [Fit height (scroll)]      │       │ ▣ Auto            best for this screen│
│ [Half page (top/bottom)]   │       │ ▢ One page        tap left / right    │
│ [Half page (left/right)]   │       │ ▢ Two pages       ✓ fits this screen  │
└────────────────────────────┘       │ ▢ One page + peek tap top / bottom    │
   six peers, no explanation         │ ▢ Scroll          swipe up / down     │
                                     ├──────────────────────────────────────┤
                                     │ Page turn settings…                  │
                                     └──────────────────────────────────────┘
```

## In scope

- Rename the modes to the job they do, and drop the engine vocabulary ("fit", "scroll" as a suffix)
- An **Auto** layout that resolves from the viewport, showing what it resolved to
- Per-mode navigation: tap zones and swipe default to the axis the layout moves along
- Resolve the Fit height scroll-vs-turn collision, whichever way G3 decides the mode's fate
- The peek slider marks where the peek stops being free on *this* screen
- Two pages on a viewport too narrow for it (the portrait-phone case left open on 2026-07-26)
- Turn amount shown only where it does something
- A route from the Layout sheet to Page turn settings, since the two jointly decide one behaviour

## Out of scope

- New layouts: no three-up, no thumbnail grid, no reflow, no margin cropping
- Per-Score layout override (still deferred from 0004)
- Changing pinch, double-tap or Page scale (0031 / 0033 / 0036) — this Spec spends the slack, it does not change the zoom rules
- Changing what a pedal does: pedal stays document-order in every layout (0008)
- Setlist boundary behaviour (0012)
- Onboarding or coach marks for the new picker (**C3 — 0039**)
- Anything SmartMode / Transport (ADR 0008)

## Domain terms

**PdfMode**, **PageTurn**, **PageOrder**, **ScoreMenu**, **GestureMap**

**LayoutFit** added to `CONTEXT.md` at G1: the derived answer to "what can this viewport afford" (does a spread fit, how much peek is free, which mode is recommended). Derived from viewport and page aspect on every build, never stored. *Avoid:* "auto layout" as the concept name — that is the user-facing mode, not the calculation.

## Decisions locked at G3

| # | Question | Locked |
|---|----------|--------|
| 1 | Does **Fit height** survive? | **Cut it from the picker.** It is the only mode whose result cannot be stated to a musician without naming their device, and on the most common one it crops a third of every system. Keep the enum value so restores and old prefs still load, mapping it to Scroll. Parity row **P0.6** gets annotated `wont` for the fit-height half with this reason, not quietly marked done. |
| 2 | Is **Auto** a mode or a badge on the recommended row? | **A mode**, listed first, showing what it resolved to ("Auto · Two pages") in the sheet and in the ScoreMenu's inline state (0035). A badge alone leaves the musician doing the choosing on every rotation, which is the work this Spec is trying to remove. It is a stored *choice* whose resolution is a pure function of the viewport, so it adds no second source of truth — same shape as the 0036 preset label. |
| 3 | Does Auto become the default? | **New installs only.** Existing installs keep the mode they chose; changing what someone's stand does overnight is exactly the complaint 0034 got. |
| 4 | May Auto change layout **while playing**? | **On rotation only**, never on a page turn, and it must announce itself with the same transient pill 0036 introduced ("Two pages"). A layout that changes under your hands mid-piece with no explanation is worse than a wrong layout. |
| 5 | Tap zones and swipe per layout — how? | **A `Match layout` default value** on the existing Tap zones and Swipe settings, rather than six copies of the settings. Left/right for horizontal layouts (One page, Two pages, peek-on-side), top/bottom and swipe up/down for vertical ones (Scroll, peek-on-top). Whoever has already set an explicit value keeps it. |
| 6 | **Two pages** on a viewport too narrow for a spread | *(Build refinement: this needs a different threshold from decision 2. **Fits** is an absolute floor — 240 pt per page — and governs this fallback; **free** is `viewAspect ≥ 2 × pageAspect` and governs what Auto picks, so a portrait tablet keeps a spread it asked for without being pushed into one.)* **Fall back to one page and say so** — the row reads "Two pages · one page on this screen", the pref is untouched, rotating restores the spread. Completes 0004's own acceptance wording, "see facing pages *when width allows*", which never had an implementation. Threshold from `LayoutFit`, not from an orientation flag: a tablet in portrait shows a genuinely usable spread and must not be punished for being portrait. |
| 7 | Free-peek marker: mark the slider, or clamp the default to it? | **Mark it, do not clamp.** A tick and a "free up to 35%" caption teaches the trade; silently clamping would move a setting the musician chose. |
| 8 | Full turn in a scrolling layout | **One viewport, not one page index.** `goToPage` with a top anchor skips whatever did not fit — invisible on a phone, where the page has 35% slack, and real on a 768-wide tablet where an A4 page at fit width is 1087 pt tall inside 1024. A page turn must never skip unread music. |
| 9 | Does Turn amount stay global? | **Yes, but hidden where it does nothing** — One page and the peek modes ignore it (`resolvePageTurnStep` already returns one page for all three). A setting that visibly does nothing teaches the musician the app is lying. |
| 10 | *(Raised in build, after the picker went on device)* What is actually **in** the peek band? | **The top of the next page, at the size the current page is drawn at, clipped.** It was a whole page fitted into the band — 42% scale on a phone, notes present and unreadable, which made the free-peek arithmetic true and the mode worthless. A peek is worth the screen it costs only if the musician can read the first system off it, so the page is laid out at the current page's width and the overflow is cut. Below that scale the mode should not exist; this is what makes decision 2's "peek is free" mean something. |

## Acceptance criteria

Testable checklist (G4):

- [x] Every layout row says how it turns pages, in the picker, before it is chosen
- [x] Auto picks two pages on a landscape tablet, one page on a portrait tablet, and peek-capable one page on a portrait phone
- [x] Auto shows what it resolved to, in the sheet and in the ScoreMenu inline state
- [x] Rotating with Auto on re-resolves the layout, announces it once, and keeps the current page
- [x] Turning the page never changes the layout, in Auto or out of it
- [x] Changing layout keeps the page the musician is on, in every layout and both directions (as does entering and leaving Draw mode, which suspends PerformanceMode and rebuilds the same chrome)
- [x] Choosing Two pages on a viewport that cannot fit a spread shows one page, says so, and restores the spread on rotation without the musician re-picking
- [x] With Tap zones on `Match layout`, tapping the bottom half advances in a vertically-scrolling layout and the right half advances in a horizontal one
- [x] With Swipe on `Match layout`, the swipe axis matches the layout's motion axis
- [x] An explicitly chosen tap mode or swipe direction survives this Spec unchanged
- [x] In a scrolling layout, one full turn advances by at most one viewport and never skips unread music
- [x] **n/a** — in the horizontally-scrolling layout, a drag either scrolls or turns: Q1 cut the only layout that scrolled sideways, so there is nothing left to arbitrate
- [x] The peek slider shows where the peek stops costing music size on the current screen, and the mark moves on rotation
- [x] The peek shows the top of the next page at the same note size as the page beside it, cut off rather than shrunk, on both peek layouts
- [x] Turn amount is not offered in layouts that ignore it
- [x] Old `layout_prefs.json`, including a stored `fitHeight`, loads into a sensible mode without an error
- [x] Pedal keys advance document-order in every layout, unchanged (0008)
- [x] Reachable and readable on the smallest supported phone width, light and dark (0026)

## UX notes

- A layout row is a promise about what the musician will see and what their thumb should do. If a row needs a second sentence to be understood, the name is wrong.
- Say what a mode gives, not how it is computed: "One page + peek — see the start of the next page" beats any sentence containing the word "fit".
- The recommendation is advice, never a lock. Every mode stays pickable on every screen, including the ones that will look bad; the sheet says so and lets the musician be wrong on purpose.
- Do not animate a layout change. Re-laying out the score is jarring enough without a transition on top.
- The free-peek caption is the only place in the app that explains the geometry, and it should read like a fact about the screen, not a warning.

## Technical constraints

- The arithmetic lives in one pure function beside `pdfFitZoom`, taking viewport and page aspect and returning what the viewport affords. The picker, the Auto resolution, the two-page fallback and the peek marker must all read the same function — four copies of √2 in four files is how this drifts.
- Auto resolves at build time from the current viewport; it is never written back into `layout_prefs.json`. The stored value stays `auto`.
- `PdfLayoutMode.fitHeight` stays in the enum whatever Q1 decides, because 0027 restores and existing prefs files contain it.
- `Match layout` is a new sentinel on the existing tap/swipe prefs, not a new prefs file, and `PageTurnPrefs.fromJson` must read older files unchanged (absent key → the explicit value they already had).
- Resolving the drag collision must not weaken 0033: two-finger pinch still passes through, and swipe still yields to pan when the musician is zoomed in.
- Layout changes re-fit the viewer through the existing 0036 path, so a musician who has pinched keeps their zoom.
- The peek band clips; it does not fit. The width it lays the next page out at comes from the same `half_page.dart` geometry the JumpLink pane rect uses, so a tap and a peek never disagree about where the page is.

## Test plan

- Automated: the affordance function against the four viewports in the table above (free peek, spread fits, recommended mode); Auto resolution per viewport; the two-page fallback threshold, including a portrait tablet that must *not* fall back; `Match layout` resolving to the right axis per mode; full turn in a scrolling layout advancing by a viewport and stopping at the document end; prefs round-trip including a legacy `fitHeight` value
- Manual demo: on device — phone portrait, phone landscape and tablet both ways; pick Auto and rotate mid-piece; turn pages with a thumb in each layout and check nothing scrolls twice; drag the peek slider past the free mark and watch the music shrink; a pedal run through every layout
