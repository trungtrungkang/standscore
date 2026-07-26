# 0020 — Hide annotations; export PDF with annotations

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0019 (done)
- **Parity IDs:** P2.4
- **G3:** accepted (2026-07-26)
- **G3 notes:** Hide = ink + stamps together; session-only (not persisted). Export = new PDF via share sheet; current Score only; **source PDF page order**; JumpLinks/Bookmarks not in export. Never mutate the imported PDF. Entering Draw forces annotations visible.
- **G4:** pass (2026-07-26)

## Problem

Musicians annotate Scores for rehearsal, then need a clean page for performance (hide ink/stamps without deleting) and a way to share or print a **flattened PDF** that includes those marks. ScorePDF covers both under hide + export-with-annotations.

## Outcome

In PdfMode, the user can **temporarily hide** all annotations (ink + stamps) while viewing, and **export** a PDF of the Score with annotations burned into the pages (share/save). Hide does not destroy data; export produces a new file.

## In scope

- Toggle: show/hide annotations for the current Score view (ink + stamps together)
- Export PDF with annotations flattened onto pages (share sheet)
- Export covers current Score (source PDF page order)
- JumpLinks / Bookmarks remain as today (not in export)
- Keep Draw / PageTurn / layouts working when annotations are visible again

## Out of scope

- Cloud sync
- Editing the source PDF text/content
- Per-layer hide (ink vs stamps separately)
- Dedicated stamp size / resize (deferred from 0019)
- Labels / filter / search / sort (P2.5–P2.7)
- Replace PDF (P2.8)
- Setlist-wide export

## Domain terms

**PdfMode**, **Score**, **Stamp**, annotations (ink + stamps)

## Acceptance criteria

Testable checklist (G4):

- [x] User can hide annotations and the page looks clean; toggle back restores them
- [x] Hide does not delete persisted annotation data
- [x] User can export a PDF that includes visible annotations on the pages
- [x] Exported file opens in a standard PDF viewer with marks present
- [x] Draw / PageTurn still work after hide/show and after export

## UX notes

- Hide control should be reachable without entering Draw (overflow or chrome)
- Export progress/feedback for multi-page Scores

## Technical constraints

- Render pages + composite overlays into page images; wrap as a new PDF (do not mutate import)
- TDD where pure (e.g. flatten/export helper); manual for share/export UX

## Test plan

- Automated: hide does not clear store; export helper produces multi-page PDF bytes when given pages
- Manual: annotate → hide → show → export → open export in Preview/Files
