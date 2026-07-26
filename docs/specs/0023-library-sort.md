# 0023 — Library sort (title, created, last viewed)

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0022 (done)
- **Parity IDs:** P2.7
- **G3:** accepted (2026-07-26)
- **G3 notes:** Modes = title A–Z; created newest-first; last viewed recent-first with **never-opened last**. Default = last viewed. Scores only. Filter → search → sort. Persist app-level preference.
- **G4:** pass (2026-07-26)

## Problem

The Library currently lists Scores in a fixed recency-ish order. Musicians need ScorePDF-style **sort**: by title, date created, or last viewed — so a large Library stays scannable after Label filter and search.

## Outcome

In the Library Scores tab, the user can choose a sort key — **title**, **created**, or **last viewed** — and the list reorders accordingly. The choice persists across restart. Sort applies after Label filter and search (0021–0022).

## In scope

- Sort modes for Scores: title (A–Z), created (newest first), last viewed (recent first; never-opened last)
- Compact control in Library Scores UI
- Persist last-used sort preference (app-level)
- Compose with Label filter + search (filter → search → sort)

## Out of scope

- Sort Setlists
- Custom manual drag-reorder of Library
- Replace PDF (P2.8)
- Multi-column / table Library layout

## Domain terms

**Library**, **Score**

## Acceptance criteria

Testable checklist (G4):

- [x] User can sort Scores by title
- [x] User can sort by created date
- [x] User can sort by last viewed
- [x] Sort choice survives app restart
- [x] Sort still works with Label filter and search active
- [x] Empty Library / empty filter results unchanged in meaning

## UX notes

- One compact control (menu) — not a settings deep-dive
- Show current sort clearly

## Technical constraints

- Pure sort helper TDD’d on Score fields (`title`, `createdAt`, `lastOpenedAt`)
- Prefs store under standscore root

## Test plan

- Automated: each sort key ordering; never-opened last for last-viewed
- Manual: switch sorts → restart → confirm; with search + Label filter
