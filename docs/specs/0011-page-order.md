# 0011 — PageOrder: reorder, duplicate, delete, blank pages

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0010 (done)
- **Parity IDs:** P1.6
- **G3:** accepted (2026-07-26)
- **G4:** pass (2026-07-26)

## Problem

Performance PDFs often need repeats, skipped covers, or inserted blank rest pages without editing the original file. StageScore always shows PDF pages in file order. ScorePDF’s PageOrder lets musicians rearrange the performance sequence.

## Outcome

For a Score in PdfMode, the user can edit **PageOrder**: reorder pages, duplicate a page, delete a page from the performance sequence, and insert blank pages. PdfMode navigation (PageTurn, slider, Bookmarks) follows PageOrder. The original PDF file is not rewritten; PageOrder is metadata per Score.

## In scope

- PageOrder editor UI (list of performance pages with source page / blank)
- Reorder (drag or move up/down)
- Duplicate a page entry
- Remove a page entry from the sequence (not delete PDF bytes)
- Insert blank page(s) at a chosen position
- **Reset to original** (restore identity order 1…N from the PDF)
- Persist PageOrder per Score
- PdfMode reads through PageOrder (page N in UI = Nth entry)
- Default: identity order (1…N matching the PDF) when no custom PageOrder exists
- Bookmarks store performance page index (PageOrder position); document migration: existing bookmarks remain valid against identity order
- Entry from PdfMode via app bar **⋯ overflow menu** → “Page order…” (not a dedicated app-bar icon)

## Out of scope

- Half-page layouts (P1.9)
- Setlist (P1.7)
- Jump links (P1.10)
- Export flattened PDF of PageOrder
- Cropping / rotating individual pages

## Domain terms

**PageOrder**, **Score**, **PdfMode**, **Bookmark**, **PageTurn**

## Acceptance criteria

- [x] New Score has identity PageOrder (matches PDF page count)
- [x] User can reorder pages and see the new sequence in PdfMode
- [x] User can duplicate a page; turning pages shows it twice in sequence
- [x] User can remove a page from the sequence
- [x] User can insert a blank page and see a blank view at that position
- [x] User can Reset to original PDF page order
- [x] PageOrder survives app restart
- [x] Page slider / page count reflect PageOrder length
- [x] Bookmarks jump to PageOrder positions

## UX notes

- **Entry (G3):** PdfMode app bar **⋯** → “Page order…” (keeps primary icons light)
- Editor: list of performance entries; per-row **⋯**: Duplicate · Insert blank · Remove; drag/reorder; toolbar/action **Reset to original** (confirm if sequence was customized)
- Blank page: plain empty surface (no fake staff required)

## Technical constraints

- Prefer deep module: `PageOrder` model + store; PdfMode maps performance index → PDF page or blank
- Single-page slider and continuous layouts both consume the same mapping
- TDD for PageOrder mutate helpers (move, duplicate, remove, insertBlank)

## Test plan

- Automated: PageOrder operations + persistence round-trip
- Manual: duplicate a page, insert blank, reorder, navigate with slider and bookmarks
