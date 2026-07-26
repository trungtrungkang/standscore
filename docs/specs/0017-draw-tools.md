# 0017 — Draw tools (pen, marker, eraser, undo/redo)

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0001 (spike done); P1 done (0013–0016)
- **Parity IDs:** P2.1
- **G3:** accepted (2026-07-26)
- **G3 notes:** Eraser = remove whole strokes the gesture hits (stroke-level). Fixed pen/marker presets OK. Persist per Score.
- **G4:** pass (2026-07-26)

## Problem

PdfMode already has a minimal Draw mode (freehand ink + Undo from the spike). Musicians need ScorePDF-class tools for rehearsal marks: **pen**, **marker/highlighter**, **eraser**, and **redo** — without hunting through a heavy editor.

## Outcome

In PdfMode Draw mode, the user can choose pen / marker / eraser, ink on the current page with sensible defaults, undo and redo strokes, and leave Draw mode to restore PageTurn. Strokes persist with the Score across restart (beyond in-memory spike behavior if not already persisted).

## In scope

- Tool picker while Draw is on: **Pen** · **Marker** (semi-transparent wider stroke) · **Eraser**
- Undo + **Redo** (app bar or draw chrome)
- Persist annotations per Score (JSON under Score storage) — load on open, save on change
- Keep existing: Draw toggle, pan/zoom/PageTurn locked while drawing, GestureMap Show menu still works
- Default pen color + width; marker distinct width/opacity (fixed presets OK for this Spec)

## Out of scope

- Full color / width panels, eyedropper, straight line (P2.2)
- Symbols / shapes / text stamps (P2.3)
- Hide annotations; export PDF with annotations (P2.4)
- Vector eraser of individual strokes by hit-test sophistication beyond “erase under finger” / stroke delete — prefer stroke-level erase or path erase; pick simplest that feels usable
- Cloud sync

## Domain terms

**PdfMode**, **Score**  
Ink / annotation strokes (implementation; UI may say “Draw”)

## Acceptance criteria

Testable checklist (G4):

- [x] User can switch Pen / Marker / Eraser in Draw mode
- [x] Pen draws opaque freehand; Marker draws wider translucent stroke
- [x] Eraser removes ink under the gesture (or whole strokes it hits — document choice)
- [x] Undo and Redo work across tool switches
- [x] Annotations survive app restart for that Score
- [x] Exiting Draw restores PageTurn / pan-zoom as today
- [x] Existing PageTurn / JumpLink / Half Page layouts still work with Draw off

## UX notes

- Keep Draw chrome compact (toolbar strip or chips under app bar) — not a second full screen
- Eraser should not require a settings deep-dive

## Technical constraints

- Keep normalized page coordinates (spike)
- Deep `AnnotationStore` (or successor) with undo/redo stacks; TDD store behavior
- Persist under Score id path alongside bookmarks / jump links

## Test plan

- Automated: store undo/redo; persist round-trip; tool kind on stroke
- Manual: pen → marker → erase → undo/redo → restart → ink still there
