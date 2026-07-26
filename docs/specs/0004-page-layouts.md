# 0004 — Page layouts: single, two-page, fit width/height

- **Status:** done
- **Type:** feature
- **Horizon:** H1
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0003 (done)
- **Parity IDs:** P0.5, P0.6
- **G3:** accepted (2026-07-23)
- **G4:** pass (2026-07-23)

## Problem

PdfMode currently uses pdfrx’s default continuous layout. ScorePDF users expect explicit single-page, two-page spread, and fit-width / fit-height reading modes for tablets and phones.

## Outcome

From PdfMode, the user can switch page layout among single page, two-page spread, fit width (vertical scroll), and fit height (horizontal scroll). The choice persists at app level for this Spec.

## Amendment (2026-07-24) — Single page = horizontal slider

- **Verified:** 2026-07-25 (Orchestrator)

ScorePDF **Single page** is discrete (one page at a time), not continuous vertical scroll:

- Only one page visible
- Next page animates **right → left** (incoming from the right)
- Previous page animates **left → right**

**Fit width** remains vertical continuous scroll; **fit height** remains horizontal continuous scroll. StandScore maps Single page to a dedicated `PageView` slider (`SinglePageSlider`), not pdfrx vertical `layoutPages`.

## In scope

- Layout modes: single page, two-page spread, fit width, fit height
- Simple layout picker in PdfMode (near PageTurn settings)
- Persist selected layout (app-level JSON next to other prefs)
- PageTurn still works in single/two-page modes (document behavior if scroll modes differ)
- Annotation overlay remains usable in all modes

## Out of scope

- Half-page layouts (P1.9)
- Auto layout by orientation (can follow later)
- Per-score layout override
- Reverse page-turn direction (P1.5)
- Pedal (P1.1)

## Domain terms

**PdfMode**, **PageTurn**

## Acceptance criteria

- [x] User can select single-page layout and see one page at a time (horizontal slider; next from right, prev from left)
- [x] User can select two-page spread and see facing pages when width allows
- [x] Fit width shows pages at full viewer width with vertical scroll
- [x] Fit height shows pages at full viewer height with horizontal scroll (or equivalent pdfrx mapping)
- [x] Layout choice survives app restart
- [x] Draw mode and annotation still work after switching layouts

## UX notes

- Labels in plain language (not engine jargon)
- Don’t require leaving PdfMode to change layout

## Technical constraints

- Prefer pdfrx layout / view-mode APIs; document chosen mapping in a short note under `docs/spikes/` only if non-obvious
- Keep PageTurn prefs intact
- Two pages must open on a whole spread, so the taller page of the pair binds the zoom as well as the spread's width. pdfrx fits the document *width*, which on a phone in landscape pushes the bottom of the music off the screen — the app computes its own fit (`pdfFitZoom`) and re-applies it when the viewport changes.

## Test plan

- Automated: layout prefs store round-trip
- Manual: switch all four modes on tablet; annotate; restart
