# 0022 — Search by title (+ bookmark search)

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0021 (done)
- **Parity IDs:** P2.6
- **G3:** accepted (2026-07-26)
- **G3 notes:** Live filter as you type (case-insensitive substring). Match **title OR any Bookmark title**. Label filter first, then search. Scores tab only (not Setlists). Query is session-only.
- **G4:** pass (2026-07-26)

## Problem

With a growing Library, finding a Score by scrolling is slow. ScorePDF lets musicians **search by title** and also find Scores via **Bookmark** titles — StageScore needs the same discoverability without leaving the Library.

## Outcome

In the Library, the user can type a search query and see Scores whose **title** matches or that have a **Bookmark** title matching the query. Results update as the user types. Search composes with the existing Label filter (Label first, then search).

## In scope

- Library search field for Scores (title match; case-insensitive substring)
- Bookmark-title search across Scores (load Bookmark stores as needed)
- Clear query restores the filtered/unfiltered list
- Compose with Label filter (0021): Label filter first, then search
- Entry on Library Scores tab

## Out of scope

- Full-text search inside PDF page content / OMR
- Search Setlists
- Sort controls (P2.7)
- Cloud / server search
- Search JumpLink titles

## Domain terms

**Library**, **Score**, **Bookmark**, **Label**

## Acceptance criteria

Testable checklist (G4):

- [x] User can search and see Scores matching title
- [x] User can find a Score by Bookmark title match
- [x] Clearing search restores the prior list (respecting Label filter if any)
- [x] Search + Label filter can be used together
- [x] Empty query / no matches shows a clear empty state

## UX notes

- Compact search in Library list header — not a separate full-screen browser
- Live filter as you type

## Technical constraints

- Pure match helpers TDD’d; Bookmark index loaded async / cached on Library open+reload
- Reuse existing per-Score BookmarkStore paths

## Test plan

- Automated: title match; bookmark match; compose with empty query
- Manual: search title → search bookmark name → clear → with Label filter
