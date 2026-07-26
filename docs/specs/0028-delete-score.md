# 0028 — Delete Score from Library

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0027 (accepted; hygiene gap may ship before/with G4)
- **Parity IDs:** P0.9
- **G3:** accepted (2026-07-26)
- **G3 notes:** Entry = Library Score ⋯ → Delete… (confirm). Hard-delete PDF + overlays + Label assignments; strip Score id from all Setlists (**keep empty Setlists**). Delete only from Library UI — PdfMode is not open for that Score when user is on Library (no special in-viewer delete this slice).
- **G4:** pass (2026-07-26)

## Problem

A musician who imports the wrong PDF (or no longer needs a piece) cannot remove a **Score** from the Library. Setlists already support Delete; Score ⋯ only offers Labels and Replace PDF. Without Delete, mistaken imports accumulate with no recovery path short of reinstall or hand-editing storage.

## Outcome

From the Library Scores list, the user can **Delete** a Score with confirmation. The Score disappears from the list; its PdfDocument and per-Score overlays are removed; Label assignments for that Score are cleared; the Score is removed from any Setlists that referenced it.

## In scope

- Library Score ⋯ → Delete…
- Confirm dialog (destructive, names the Score)
- Remove: PDF file, annotations, bookmarks, jump links, page order, Label assignments
- Remove Score id from all Setlist membership lists (empty Setlists kept)
- Refresh Library UI after delete
- Cancel leaves everything unchanged

## Out of scope

- Trash / undo delete / soft-delete
- Bulk multi-select delete
- Delete entry from PdfMode chrome
- Cloud sync / remote delete
- “Remove from Setlist only” (already editable in Setlist editor)
- Auto-deleting empty Setlists

## Domain terms

**Library**, **Score**, **Setlist**, **Label**, **PdfDocument**

## Acceptance criteria

Testable checklist (G4):

- [x] User can delete a Score from Library Score ⋯
- [x] Confirm required; Cancel does not delete
- [x] Deleted Score no longer appears in Library
- [x] PDF and overlay files for that Score are gone
- [x] Label assignment for that Score is cleared
- [x] Setlists no longer list that Score id
- [x] Other Scores untouched

## UX notes

- Wording must make clear this deletes the Score (not only a Label)
- Place Delete below Replace in the Score menu (destructive last)

## Technical constraints

- Prefer one `ScoreLibrary.deleteScore` that owns file + manifest cleanup; Label/Setlist stores updated in the same user action
- TDD: delete removes manifest entry + PDF + overlays; Setlist/Label side effects covered

## Test plan

- Automated: deleteScore removes PDF + overlays + manifest row; strips id from Setlist + Label assignment
- Manual: import → annotate → add to Setlist → delete → gone everywhere; other Scores remain
