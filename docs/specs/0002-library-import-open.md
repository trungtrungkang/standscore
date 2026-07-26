# 0002 — Library: import PDF and open in PdfMode

- **Status:** done
- **Type:** feature
- **Horizon:** H1
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008, 0009
- **Depends on Specs:** 0001 (done / go)
- **Parity IDs:** P0.1, P0.2, P0.7, P0.8
- **G3:** accepted (2026-07-23)
- **G4:** pass (2026-07-23)

## Problem

The spike proved PDF + ink on one sample asset. A musician still cannot build a library from their own PDFs or reopen scores from a list.

## Outcome

User can import one or more PDFs from the device into a local library, see them listed by title, open any Score in PdfMode with pinch-zoom/pan, and return to the library.

## In scope

- Local Score library persistence (on-device; titles from filename by default)
- Import single + multiple PDFs from device (file picker / share-in if cheap)
- Library list UI (title; open on tap; show empty state)
- Open Score → PdfMode viewer (reuse pdfrx + existing zoom/pan)
- Back navigation library ↔ viewer
- Keep spike annotation entry point available while viewing (draw/undo) — no P2 polish required

## Out of scope

- PageTurn tap zones / swipe config (→ later Spec; P0.3–P0.4)
- Two-page / fit layouts (P0.5–P0.6)
- Setlist, labels, search, cloud sync
- SmartMode / Transport
- Annotation export; full ScorePDF annotate toolset

## Domain terms

**Score**, **PdfDocument**, **PdfMode**

## Acceptance criteria

Testable checklist (G4):

- [x] Import one PDF → appears in library with a title
- [x] Import multiple PDFs in one action → all appear
- [x] Tap a library row → opens PdfMode for that Score
- [x] Pinch-zoom and pan work in viewer (regression from spike)
- [x] Back returns to library without crashing; Score still listed
- [x] Empty library shows a clear CTA to import
- [x] Data survives app restart (local persistence)

## UX notes

- First launch: empty state + primary “Add PDF” control
- Titles default from file name (strip `.pdf`); rename can wait
- Viewer chrome: keep minimal (back, draw, undo) — not fullscreen-performance polish yet

## Technical constraints

- Flutter + pdfrx (ADR 0005)
- Bundle id unchanged
- Store PDF files under app documents; metadata in local DB or JSON — prefer simple and testable

## Test plan

- Automated: library add/list/open path for Score metadata (fake file paths OK)
- Manual: import real PDFs on iOS and Android; kill app; relaunch; reopen
