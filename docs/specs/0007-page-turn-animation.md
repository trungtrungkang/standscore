# 0007 — Page turn animation on/off + speed

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0006 (done)
- **Parity IDs:** P1.4
- **G3:** accepted (2026-07-26)
- **G4:** pass (2026-07-26)

## Problem

Single-page PageTurn always animates at a fixed ~320ms. ScorePDF lets musicians disable the animation (instant jump) or pick a speed — useful on stage when delay lockout is on and they want snappy or silent turns.

## Outcome

In PdfMode PageTurn settings, the user can turn page-turn animation Off (instant) or choose a speed preset. The choice applies to Single page slider turns (and any other layout that uses animated `goToPage` for PageTurn). Persists at app level.

## In scope

- Animation toggle / presets: e.g. Off · Fast · Normal · Slow (exact labels OK to refine)
- Wire Single page `goToPage` duration from prefs (Off → `Duration.zero` / jump)
- Persist with PageTurn prefs JSON
- Visible in PageTurn settings near delay controls

## Out of scope

- Custom gesture map (P1.2)
- Reverse page-turn direction (P1.5)
- Fancy 3D curl / book flip beyond horizontal slider
- Per-score animation override
- Changing continuous scroll (fit width/height) physics

## Domain terms

**PageTurn**, **PdfMode**

## Acceptance criteria

- [x] Off → PageTurn jumps with no slide animation
- [x] A non-Off preset → visible horizontal slide on Single page next/prev
- [x] Speed presets feel ordered (Fast < Normal < Slow duration)
- [x] Setting survives app restart
- [x] Works with page-turn delay (0006) still enabled

## UX notes

- Plain labels; default **Normal** (close to current 320ms behavior)
- Keep delay and animation as separate controls

## Technical constraints

- Prefer existing `SinglePageSliderController.goToPage(duration:)`
- Animation prefs apply to **Single page** slider turns via `goToPage(duration:)`. Continuous pdfrx layouts (fit width/height, two-page) keep engine default navigation.

## Test plan

- Automated: prefs round-trip for animation preset; duration mapping pure function
- Manual: Single page Off vs Slow; mash with delay On
