# 0029 — Share-in PDF from other apps

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0027 (done), 0028 (done)
- **Parity IDs:** P2.12
- **G3:** accepted (2026-07-26)
- **G3 notes:** After import → **Library Scores** + snackbar (no auto-open PdfMode). **iOS + Android**. Multi-file supported. Reuse `importPdf`. Non-PDF ignored. App group `group.com.backingscore.scoreapp`.
- **G4:** pass (2026-07-26)

## Problem

Musicians often receive sheet music as a PDF in Mail, Files, Drive, or Messages. ScorePDF appears in the system **Share** / **Open in** sheet so the file lands in the Library without a separate file-picker dance. StageScore today only imports via the in-app **+** picker.

## Outcome

When the user shares one or more PDF files to StageScore from another app (or opens a PDF with StageScore), each PDF is imported as a new **Score** in the Library (same path as in-app import). The Library refreshes and the user can open the new Score(s).

## In scope

- iOS: Share Extension + document types for PDF
- Android: `ACTION_SEND` / `ACTION_SEND_MULTIPLE` / `ACTION_VIEW` for `application/pdf`
- Import via existing `ScoreLibrary.importPdf(s)` semantics (title from filename, new Score id)
- Cold start and warm start both accept shared file(s)
- After import: Library Scores tab + snackbar (“Imported N scores”)
- Non-PDF payloads ignored (no Library corruption)

## Out of scope

- Importing StageScore backup ZIP via share (use Restore)
- Share-out of Library Scores (except existing annotated export / backup)
- Auto-open PdfMode after share-in
- Deduping by content hash (always create a new Score)
- MusicXML / images / other formats

## Domain terms

**Library**, **Score**, **PdfDocument**

## Acceptance criteria

Testable checklist (G4):

- [x] Sharing a PDF to StageScore from another app creates a Library Score
- [x] Sharing multiple PDFs at once imports each (if platform allows)
- [x] Title matches source filename (minus `.pdf`)
- [x] Works when StageScore was not already running
- [x] Works when StageScore was already in foreground / background
- [x] Library list shows the new Score(s) without manual refresh hack
- [x] Non-PDF share does not corrupt the Library

## UX notes

- Prefer landing on Library Scores tab after share-in
- Brief snackbar (“Imported N scores”) is enough; no wizard

## Technical constraints

- Prefer a maintained Flutter receive-share plugin (`share_handler`)
- Reuse `ScoreLibrary.importPdf` — do not invent a second import path
- Copy into app documents before relying on ephemeral share URLs

## Test plan

- Automated: shared path(s) → importPdf → Score appears in temp library
- Manual: Share PDF from Files/Mail → StageScore; multi-share; app killed then share
