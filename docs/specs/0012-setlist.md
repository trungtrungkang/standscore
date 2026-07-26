# 0012 — Setlist: group Scores, continuous performance, jump by title

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0011 (done)
- **Parity IDs:** P1.7
- **G3:** accepted (2026-07-26)
- **G3 notes:** Library = Scores | Setlists segmented list. Missing Score in Setlist → skip on open (do not crash); show snackbar if any skipped.
- **G4:** pass (2026-07-26)

## Problem

A gig or rehearsal often needs several Scores in a fixed order. Today the musician must leave PdfMode, find the next Score in the library, and reopen it — breaking flow. ScorePDF Setlists keep pieces in one continuous performance session.

## Outcome

The user can create a **Setlist** (ordered group of Scores), open it into PdfMode, turn pages continuously across piece boundaries, and jump to the start of any piece by title without returning to the library.

## In scope

- Create / rename / delete Setlists
- Edit membership: add Scores from the library, remove entries, reorder
- Persist Setlists on device (under `standscore/`)
- Library surfaces Setlists (alongside Scores) and opens a Setlist into PdfMode
- Continuous performance: PageTurn past the last page of Score *N* lands on page 1 of Score *N+1* (and previous from page 1 of *N* lands on the last page of *N−1*)
- Each Score still uses its own PageOrder, Bookmarks, and annotations
- In PdfMode while a Setlist is open: tap the **title** (app bar) → sheet listing Setlist pieces → tap a title jumps to that piece’s first performance page
- Page slider / page chrome reflect the **current Score’s** PageOrder length (not a flattened global page count across the Setlist)
- Empty Setlist cannot open into PdfMode (clear message / disable open)

## Out of scope

- Labels / filter (P2.5)
- Library search / sort polish (P2.6–P2.7) beyond listing Setlists
- Half-page layouts (P1.9)
- Gesture map (P1.2)
- Jump links on the page (P1.10)
- Cross-Score Bookmarks or a global Setlist page index
- Sharing / export / cloud sync of Setlists
- Duplicating a Score into a Setlist as a copy of PDF bytes (reference Score ids only)

## Domain terms

**Setlist**, **Score**, **PdfMode**, **PageOrder**, **PageTurn**, **Bookmark**

## Acceptance criteria

Testable checklist (G4):

- [x] User can create a Setlist, add ≥2 Scores, reorder them, and save
- [x] Setlist appears in the library and survives app restart
- [x] Opening a Setlist shows the first Score in PdfMode
- [x] PageTurn next on the last page of Score 1 opens page 1 of Score 2 (same session)
- [x] PageTurn previous on page 1 of Score 2 returns to the last page of Score 1
- [x] Tapping the app-bar title lists Setlist pieces; tapping a piece jumps to its start
- [x] Bookmarks / PageOrder / annotations stay scoped to the Score currently shown
- [x] User can rename and delete a Setlist
- [x] Opening a single Score from the library (not via Setlist) behaves as before (no Setlist title-jump UI)

## UX notes

- **Library:** prefer a simple way to reach Setlists without a heavy IA redesign — e.g. segmented control or secondary list section (“Setlists”) above/below Scores; keep “Add PDF” primary
- **Editor:** pick Scores from the existing library; drag/reorder; confirm before delete Setlist
- **PdfMode title:** when opened from a Setlist, title shows the **current Score** title (tappable); when opened as a lone Score, title is not a Setlist jump control
- Missing Score id in a Setlist (deleted Score): skip or show a one-line error for that slot — do not crash open

## Technical constraints

- Deep module: `Setlist` model + store; PdfMode receives an optional Setlist session (ordered Score ids + current index), not a merged PDF
- Crossing a Score boundary reloads the next Score’s file path / PageOrder / BookmarkStore / AnnotationStore for that Score id
- PageTurn delay / animation / reverse prefs remain app-level and apply across boundaries
- TDD for Setlist mutate helpers (add, remove, move) and boundary page-turn target resolution

## Test plan

- Automated: Setlist persistence round-trip; next/prev boundary resolution given per-Score page counts
- Manual: 3-Score Setlist on device; pedal/tap across boundaries; title jump; delete middle Score from library and reopen Setlist
