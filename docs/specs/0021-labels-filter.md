# 0021 — Labels + filter (Any/All, untagged); reorder labels

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0020 (done)
- **Parity IDs:** P2.5
- **G3:** accepted (2026-07-26)
- **G3 notes:** Labels on **Scores only** this slice (Setlists later). Delete Label = confirm if in use, then hard-delete + unlink. No Label colors. Filter modes Any / All / Untagged. Catalog + assignments persist; active filter is session-only.
- **G4:** pass (2026-07-26)

## Problem

As the Library grows, musicians need to organize Scores (and optionally Setlists) with reusable **Labels** and filter the list — matching ScorePDF’s label/filter model (Any / All / untagged) and reorderable label list.

## Outcome

In the Library, the user can create/rename/delete **Labels**, assign Labels to Scores, reorder Labels, and filter the Score list by Labels with **Any** / **All** match modes plus an **untagged** filter. Label catalog and assignments persist across restart.

## In scope

- Global Label catalog: create, rename, delete, reorder
- Assign / remove Labels on a Score (multi-label OK)
- Library filter: selected Labels + match mode **Any** or **All**; filter for **untagged** Scores
- Persist Labels + Score↔Label links under app storage
- Entry from Library UI (not PdfMode chrome)

## Out of scope

- Labels on Setlists (later)
- Search by title / bookmark search (P2.6)
- Sort: title, created, last viewed (P2.7)
- Labels on individual pages / annotations
- Cloud sync
- Color themes for Labels

## Domain terms

**Library**, **Score**, **Setlist**  
**Label** — already in `CONTEXT.md`

## Acceptance criteria

Testable checklist (G4):

- [x] User can create a Label and assign it to a Score
- [x] User can filter Library by Label(s) with Any and All modes
- [x] Untagged filter shows Scores with no Labels
- [x] User can reorder Labels; order survives restart
- [x] Rename/delete Label updates the catalog (delete removes link from Scores)
- [x] PdfMode / annotations unaffected

## UX notes

- Keep Library list readable; filter as chips or a compact sheet, not a wall of controls
- Deleting a Label confirms when Scores still use it

## Technical constraints

- Deep Label store + pure filter function (TDD)
- Do not invent synonyms for Label (no “tag” / “category” in UI copy)

## Test plan

- Automated: filter Any/All/untagged; reorder persist
- Manual: create labels → assign → filter → reorder → restart
