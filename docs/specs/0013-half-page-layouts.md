# 0013 — Half-page layouts (T/B, L/R) + separator settings

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0012 (done)
- **Parity IDs:** P1.9
- **G3:** accepted (2026-07-26)
- **G3 notes:** Setlist last-page peek shows **next Score title** (not PDF). Separator scope Fixed only.
- **G4:** pass (2026-07-26)

## Problem

On tall phones and music stands, musicians often want the **next** system visible while finishing the current page — without a full PageTurn yet. StandScore only has single, two-page, and continuous scroll layouts. ScorePDF’s half-page modes show part of the next page behind a movable separator.

## Outcome

In PdfMode Layout settings, the user can choose **Half page (top/bottom)** or **Half page (left/right)**. The view shows the current performance page plus a portion of the next page across a separator. Separator position is configurable and persists. PageTurn advances the “current” page; the peek region updates to the following page (or empty / next-Setlist title at the end).

## In scope

- Two new layout modes: half-page top/bottom, half-page left/right
- Layout picker entry alongside existing modes (Spec 0004)
- Separator shows a fraction of the **next** PageOrder page (or blank slot)
- Drag handle (or equivalent) to adjust separator ratio while viewing
- Separator settings: ratio slider; scope **Fixed** (app-wide) for this Spec
- Persist layout mode + separator ratio with layout prefs
- PageTurn / pedal / slider jump still advance the current performance page
- Reverse page-turn (P1.5): for left/right half-page, peek side follows reverse (next peek on the right when reversed — match ScorePDF)
- Setlist (P1.7): on the last page of a Score, peek area may show the **next Score’s title** (not its PDF) until PageTurn crosses; optional — if costly, show empty peek instead (document choice at G3)
- Annotations remain on the current page surface (peek page is view-only for this Spec)

## Out of scope

- Separator scope Per Score / Per Page (ScorePDF advanced — later)
- “Disable half-page at minimum (5%)” per page
- Auto layout by device orientation
- Gesture map (P1.2)
- Jump links (P1.10)
- Drawing on the peek (next) page
- **Page turn amount 1/2** (ScorePDF “Turn Amount”) — Spec **0014** / P1.12. Half Page layout *overlays* a peek; Turn Amount *scrolls/advances* by half.

## Domain terms

**PdfMode**, **PageOrder**, **PageTurn**, **Setlist**

## Clarification (2026-07-26)

ScorePDF **Half Page** ≠ **Turn Amount**. This Spec is only the overlay layout (P1.9). Continuous half-step PageTurn is 0014.

## Acceptance criteria

Testable checklist (G4):

- [x] User can select Half page (top/bottom) and see current page + peek of next
- [x] User can select Half page (left/right) and see current page + peek of next
- [x] Adjusting the separator changes how much of the next page is visible
- [x] Separator ratio + half-page mode survive app restart
- [x] PageTurn next advances current page; peek updates to the new next page
- [x] On the last page of a lone Score, peek is empty (or clearly non-interactive)
- [x] Draw mode still works on the current page region
- [x] Existing single / two-page / fit width / fit height modes still work

## UX notes

- Labels: “Half page (top/bottom)”, “Half page (left/right)” — not engine jargon
- Separator drag control should be large enough for a music-stand finger/thumb
- Keep half-page settings near the layout picker (secondary sheet OK)

## Technical constraints

- Prefer extending `PdfLayoutMode` + layout prefs; dedicated half-page viewer if pdfrx `layoutPages` cannot express peek cleanly
- Page chrome (slider) still reflects current Score PageOrder length / current page
- TDD for separator ratio clamp + “next page” resolution (including end-of-Score)

## Test plan

- Automated: layout prefs round-trip including half-page modes + ratio; next-page index helper
- Manual: both half modes on phone; drag separator; PageTurn across boundary; Setlist last page of piece 1
