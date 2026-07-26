# 0024 — Replace PDF (keep or reset overlays)

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0023 (done)
- **Parity IDs:** P2.8
- **G3:** accepted (2026-07-26)
- **G3 notes:** Entry = Library Score ⋯ menu. Overlays = annotations (ink+stamps), bookmarks, jump links, page order. **Keep** leaves overlay files; **Reset** deletes them. Labels + Setlist membership + Score id/title unchanged. Page-count mismatch: keep overlays as stored; viewers clamp invalid pages (no blocking dialog).
- **G4:** pass (2026-07-26)

## Problem

Musicians often get a revised PDF of the same piece (new edition, fixed pages). Today they would re-import as a new Score and lose organization. ScorePDF lets them **replace the PDF** for an existing Score and choose whether to **keep** or **reset** overlays.

## Outcome

From the Library, the user can pick a new PDF file to replace the current Score’s PdfDocument. They choose **keep overlays** or **reset overlays**. The Score identity (id, title, Labels) remains; the file bytes update.

## In scope

- Replace PDF for an existing Score (file picker)
- Choice: keep overlays vs reset overlays (confirm dialog)
- Overlays covered: annotations, bookmarks, jump links, page order
- Persist updated file under existing Score path
- Entry from Library Score menu

## Out of scope

- Cloud sync / conflict merge
- Partial page replace
- Color filter / dark mode (P2.9–P2.10)
- Auto-detect same piece via hash
- Renaming Score from new filename (keep title)
- PdfMode ⋯ entry (Library only this slice)

## Domain terms

**Library**, **Score**, **PdfDocument**, annotations, **Bookmark**, **JumpLink**, **PageOrder**

## Acceptance criteria

Testable checklist (G4):

- [x] User can replace a Score’s PDF with another file
- [x] Keep overlays: prior annotations (and locked overlay set) still load for that Score
- [x] Reset overlays: overlays cleared; PDF opens clean
- [x] Score id / Labels unchanged after replace
- [x] Opening the Score shows the new PDF pages
- [x] Failed pick / cancel leaves the Score unchanged

## UX notes

- Confirm destructive reset clearly
- Keep vs Reset as explicit dialog actions after file pick

## Technical constraints

- Do not invent a second Score id; replace file in place
- TDD: keep vs reset persistence paths
- Page-count mismatch: clamp in viewers (existing)

## Test plan

- Automated: replace keep preserves annotation JSON; reset clears stores
- Manual: annotate → replace keep → marks remain; replace reset → clean; Labels intact
