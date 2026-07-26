# 0019 — Symbols, shapes, text stamps + tool settings

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0018 (done)
- **Parity IDs:** P2.3
- **G3:** accepted (2026-07-26)
- **G3 notes:** Catalog = p, f, sharp, flat, natural, box, circle, arrow, text. Tap to place; tap stamp to select → delete; drag selected to move. Unknown stamp kinds ignored on load. New-stamp size/color reuse pen Width/Color; dedicated stamp size UI + resize selected → later slice.
- **G4:** pass (2026-07-26)

## Problem

Freehand ink (0017–0018) is not enough for common rehearsal marks: dynamics, accidentals, boxes, arrows, and short text. ScorePDF offers **symbols / shapes / text stamps** so musicians can place reusable marks without drawing every time.

## Outcome

In PdfMode Draw mode, the user can place **symbol stamps**, **simple shapes**, and **text stamps** on the page, adjust basic tool settings (size/color where relevant), move/delete a placed stamp, and persist them with the Score alongside ink strokes.

## In scope

- Stamp catalog: small built-in set (e.g. dynamics *p/f*, sharp/flat/natural, box, circle, arrow, text) — exact set locked at G3
- Tap (or tap-drag for shapes) to place on the current page in normalized coords
- Text stamp: prompt for short string; place as overlay
- Color/size settings for stamps (reuse draw style where sensible)
- Select placed stamp → delete (and optional drag-to-move if cheap)
- Persist with Score annotation storage (extend JSON; backward compatible)
- Entry from Draw chrome (⋯ or a Stamps tool) without a second full-screen editor

## Out of scope

- Full music-font / SMuFL catalog
- Dedicated stamp size control / resize selected stamp (deferred — later slice; 0019 uses pen Width for new stamps)
- Hide annotations; export PDF with annotations (P2.4)
- Cloud sync
- Editing PDF text content

## Domain terms

**PdfMode**, **Score**, Draw tools  
**Stamp** — placed symbol/shape/text mark (distinct from freehand stroke)

## Acceptance criteria

Testable checklist (G4):

- [x] User can place at least one symbol, one shape, and one text stamp
- [x] Stamps survive app restart for that Score
- [x] User can delete a placed stamp
- [x] Color/size (or equivalent) applies to new stamps
- [x] Freehand Pen/Marker/Eraser still work (0017–0018)
- [x] PageTurn / layouts unaffected when Draw is off

## UX notes

- Keep Draw chrome compact; stamp picker as sheet or grid, not a wall of chips on the main toolbar
- Text entry: simple dialog; no rich text

## Technical constraints

- Normalized page coordinates; deep store with undo/redo for place/delete
- TDD: serialize/deserialize stamps; ignore unknown stamp kinds gracefully

## Test plan

- Automated: stamp JSON round-trip; delete/undo
- Manual: place symbol + text → restart → delete; confirm ink still works
