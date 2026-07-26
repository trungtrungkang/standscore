# 0027 — Backup / restore (ZIP)

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0026 (done)
- **Parity IDs:** P2.11
- **G3:** accepted (2026-07-26)
- **G3 notes:** ZIP = entire `standscore/` tree including app prefs. Restore = **full replace** (not merge). Marker `standscore-backup.json` (format version) required; reject without it. Entry = Library ⋯ Backup / Restore. No in-app backup history.
- **G4:** pass (2026-07-26)

## Problem

Musicians need a portable copy of their Library when changing devices or before a risky experiment. ScorePDF backs up and restores via a **ZIP** shared out of the app. StandScore stores Scores, overlays, Labels, Setlists, and prefs under the local `standscore/` tree but has no export/import of that tree yet.

## Outcome

From the Library, the user can **Backup** (build a ZIP of Library data and share it) and **Restore** (pick a StandScore ZIP and replace local Library data). After restore, Scores / overlays / Labels / Setlists match the backup.

## In scope

- Backup: zip the `standscore/` library tree → share sheet (Files / AirDrop / Drive…)
- Restore: pick a `.zip` → confirm overwrite → replace library data → reload Library UI
- Include: PDFs, annotations, bookmarks, jump links, page orders, Labels, Setlists, library manifest, app prefs under `standscore/`
- Entry: Library AppBar ⋯ (Backup… / Restore…)
- Clear confirm that restore **overwrites** current data
- Reject / error clearly on non-StandScore or corrupt ZIPs

## Out of scope

- Cloud sync / incremental merge / selective Score restore
- Keeping multiple in-app backup file history (ScorePDF “Backup File” list)
- Encrypting the ZIP
- Migrating ScorePDF’s ZIP format
- Share-in of a single PDF from other apps (P2.12)
- Cross-version schema migration beyond format version check

## Domain terms

**Library**, **Score**, **Setlist**, **Label**, **PdfDocument**

## Acceptance criteria

Testable checklist (G4):

- [x] User can create a backup ZIP and share it out of the app
- [x] Restore from that ZIP brings back Scores, annotations, Labels, Setlists
- [x] Restore confirms overwrite before replacing data
- [x] Cancel restore leaves current Library unchanged
- [x] Invalid ZIP shows an error and does not wipe the Library
- [x] Library UI refreshes after a successful restore

## UX notes

- Destructive restore needs an explicit confirm
- Progress feedback for large libraries (spinner / blocking dialog ok)

## Technical constraints

- Prefer zip of on-disk tree; do not invent a parallel database
- TDD: backup bytes round-trip through restore into a temp root
- Atomic-ish restore: stage extract then swap; avoid half-wiped Library on failure
- Marker file `standscore-backup.json` with format version

## Test plan

- Automated: backup → restore into empty temp root preserves score file + annotation JSON; invalid ZIP rejected
- Manual: annotate + Label + Setlist → backup → restore → open Score
