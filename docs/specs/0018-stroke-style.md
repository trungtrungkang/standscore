# 0018 — Stroke width, color, straight line, eyedropper

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0017 (done)
- **Parity IDs:** P2.2
- **G3:** accepted (2026-07-26)
- **G3 notes:** Eyedropper samples **existing ink** under the tap (not PDF raster). Palette + discrete widths. Straight-line chip toggles constrained strokes.
- **G4:** pass (2026-07-26)

## Problem

Draw mode (0017) only offers fixed Pen / Marker presets. Musicians need to pick **color** and **stroke width**, draw a **straight line**, and optionally sample a color with an **eyedropper** — without leaving PdfMode.

## Outcome

In Draw mode, the user can change pen/marker color and width from compact controls, draw straight lines (tap-drag constrained), and use an eyedropper to set the current color from the page (or from existing ink — document at G3). Choices persist for the session; app-level last-used defaults OK.

## In scope

- Color picker (small palette + optional custom) for Pen / Marker
- Width control (discrete steps or slider) for Pen / Marker
- Straight-line mode (or modifier): stroke is a line between start and end
- Eyedropper tool to set current draw color
- Persist last-used color/width at app level (SharedPreferences / prefs file)
- Eraser unchanged from 0017

## Out of scope

- Symbols / shapes / text stamps (P2.3)
- Hide annotations; export PDF (P2.4)
- Per-stroke style editing after commit (select-and-restyle)
- Full desktop-class color wheel unless cheap

## Domain terms

**PdfMode**, Draw tools (Pen / Marker / Eraser from 0017)

## Acceptance criteria

Testable checklist (G4):

- [x] User can change Pen/Marker color; next strokes use it
- [x] User can change stroke width; next strokes use it
- [x] Straight-line mode produces a straight segment
- [x] Eyedropper sets the active color
- [x] Last-used color/width survive app restart
- [x] Eraser / undo / redo / persist strokes still work (0017)

## UX notes

- Keep controls in the Draw toolbar strip — avoid a second full screen
- Straight line should be obvious when active (chip or icon)

## Technical constraints

- Extend `AnnotationStroke` / store without breaking existing JSON (defaults for missing fields)
- TDD for prefs + straight-line point generation

## Test plan

- Automated: prefs round-trip; straight line endpoints; stroke JSON backward compatible
- Manual: color → width → line → eyedropper → restart
