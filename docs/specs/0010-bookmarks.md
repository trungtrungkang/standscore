# 0010 — Bookmarks with custom titles + jump

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0009 (done)
- **Parity IDs:** P1.8
- **G3:** accepted (2026-07-26)
- **G4:** pass (2026-07-26)

## Problem

Musicians need named landing spots in a long Score (rehearsal letters, repeats, solos). StageScore only has page scrub/jump by number — no saved places per Score.

## Outcome

In PdfMode, the user can add a Bookmark on the current page with a custom title, list Bookmarks for the open Score, rename/delete them, and jump to a Bookmark’s page. Bookmarks persist with the Score.

## In scope

- Add Bookmark at current page (default title editable, e.g. “Page N” or user text)
- List Bookmarks for the open Score; tap → jump to page
- Rename and delete
- Persist per Score (JSON next to Score storage under `stagescore/`)
- Entry point from PdfMode (app bar or overflow — keep chrome light)

## Out of scope

- Jump links drawn on the page (P1.10)
- PageOrder editor (P1.6)
- Setlist (P1.7)
- Cloud sync
- Bookmark import from PDF outline/TOC (nice later)

## Domain terms

**Score**, **PdfMode**, **PageTurn**  
**Bookmark** — accepted into `CONTEXT.md` (G3).

## Acceptance criteria

- [x] User can add a Bookmark on the current page with a custom title
- [x] Bookmarks for the Score are listed and survive app restart
- [x] Tap a Bookmark jumps to its page
- [x] User can rename and delete a Bookmark
- [x] Bookmarks are per-Score (another Score does not show them)
- [x] Jump works in Single page and continuous layouts

## UX notes

- Prefer a simple list sheet; avoid a second full screen if possible
- Empty state: “No bookmarks yet”

## Technical constraints

- Store under Score id path already used by library
- Reuse `_jumpToPage` / page navigation from Spec 0009
- If a Bookmark page is out of range, **clamp to last page** (G3)

## Test plan

- Automated: Bookmark store round-trip; list filtered by Score id
- Manual: add/rename/delete/jump; switch Scores; restart
