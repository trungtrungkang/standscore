# 0009 — Page slider + jump to page number

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0008 (done)
- **Parity IDs:** P1.11
- **G3:** accepted (2026-07-26)
- **G4:** pass (2026-07-26)

## Problem

Long PDFs force many PageTurns to reach a distant page. ScorePDF offers a page scrubber and jump-to-page. StageScore only advances one step (or spread) at a time.

## Outcome

In PdfMode, the musician can see the current page (and total), scrub with a page slider, and jump to a page number. Jump honors the current layout step where relevant (e.g. two-page may land on a spread-aligned page — document chosen behavior). Choice of whether the chrome is always visible vs ephemeral can be minimal for this slice.

## In scope

- Current page / page count indicator in PdfMode
- Horizontal page slider (scrub → go to page)
- Jump-to-page: tap indicator or control → enter page number → go
- Works in Single page (slider host) and continuous pdfrx layouts
- Does not bypass page-turn delay for *step* turns; direct jump may skip delay (document: jump is intentional navigation, not a double-turn)

## Out of scope

- PageOrder editor (P1.6)
- Bookmarks (P1.8)
- Jump links on-page (P1.10)
- Thumbnail strip
- Per-score last-read page restore (nice later)

## Domain terms

**PdfMode**, **PageTurn**, **PageOrder**

## Acceptance criteria

- [x] User sees current page and total while viewing a Score
- [x] Dragging the slider moves to the chosen page
- [x] User can enter a page number and jump there
- [x] Out-of-range input is rejected or clamped with clear feedback
- [x] Works after switching layout modes
- [x] Draw mode: slider/jump still usable (or explicitly disabled with reason — pick one at G3)

## UX notes

- Prefer a compact bottom bar; avoid covering the score when idle if easy (auto-hide OK)
- Default G3 proposal: chrome visible; jump dialog for number entry
- Draw mode: **keep navigation chrome usable** (annotation ≠ trap user on a page)

## Technical constraints

- Single page: `SinglePageSliderController.goToPage`
- Continuous: `PdfViewerController.goToPage`
- Two-page: jump to page number; step size for pedal/tap unchanged

## Test plan

- Automated: clamp/parse page number helper; prefs not required unless we add “show slider” toggle
- Manual: 20+ page PDF; Single + fit width; jump + scrub; draw mode
