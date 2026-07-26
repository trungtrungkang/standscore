# 0033 — Pinch / double-tap zoom coexist with PageTurn (P0.7 reopen)

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0031 (done); 0032 (done)
- **Parity IDs:** P0.7 (reopen); Q1
- **G3:** accepted (2026-07-26)
- **G3 notes:** Double-tap toggle fit ↔ ~2×. PageTurn single-finger only; ≥2 pointers pass through for pinch. PerformancePageSlot paths + identity PdfViewer. Build before 0030.
- **G4:** pass (2026-07-26)

## Problem

P0.7 claims pinch + double-tap zoom, but PdfMode’s PageTurn interaction layer often wins the gesture arena, so pinch does not reliably scale the page. Double-tap zoom was never implemented. Zoom lock (0031) is hard to demo or trust when unlocked zoom does not work. Improvement roadmap A1 reopens P0.7 for honesty.

## Outcome

When zoom is **unlocked**, the musician can **pinch** to scale the current page and **double-tap** to toggle a useful zoom level; pan works when zoomed. PageTurn tap/swipe still work for single-finger navigation and do not steal two-finger pinch. When zoom is **locked** (0031), pinch and double-tap scale stay disabled. Draw mode and JumpLink drag remain usable.

## In scope

- Two-finger pinch scale reaches `InteractiveViewer` (or equivalent) when unlocked
- PageTurn swipe/drag does not claim multi-touch scale gestures
- Double-tap toggles zoom (fit ↔ ~2×)
- Pan when zoomed (existing intent of P0.7)
- Honor 0031 zoom lock (`scaleEnabled` / no double-tap scale when locked)
- Works on Single / Half Page / continuous custom slots using `PerformancePageSlot`
- Identity continuous `PdfViewer` path: scaleEnabled already gated by lock — verify pinch still usable when unlocked

## Out of scope

- Metronome (0030 — next after this Spec)
- Performance mode / menu IA (Phase B)
- Max page DPI
- Peek-then-snap while locked (already cut in 0031)
- Changing Page scale slider semantics (0031)

## Domain terms

**PdfMode**, **PageTurn**, **Score**

## Acceptance criteria

Testable checklist (G4):

- [x] With lock off, pinch-in / pinch-out visibly scales the page
- [x] With lock off, double-tap toggles zoom as documented
- [x] With lock on, pinch and double-tap do not change scale
- [x] Single-finger tap / swipe PageTurn still work when not drawing
- [x] Two-finger pinch does not trigger a PageTurn
- [x] When zoomed, pan works (where layout allows)
- [x] Draw mode still draws; JumpLink long-press / drag still work

## UX notes

- Prefer transparent behavior over a new “Zoom mode” toggle
- Keep defaults: unlocked unless user set lock in Page scale sheet

## Technical constraints

- "Zoomed in" is measured against the zoom the layout opens at in the *current* viewport (`pdfFitZoom`), not pdfrx's `minScale`. `minScale` is the scale that fits one whole page, so in landscape a Score sitting at its own fit zoom read as 3× zoomed and swipe PageTurn switched itself off.
- Fix hit-testing / gesture arena between `PageTurnInteractionLayer` and `InteractiveViewer`
- Prefer translucent overlay that does not win scale; or route scale to the viewer under the overlay
- Manual demo on device required (simulator gestures may mislead)

## Test plan

- Automated: toggle-zoom matrix helper
- Manual: lock off → pinch → pan → PageTurn; lock on → pinch ignored; double-tap; draw; Half Page
