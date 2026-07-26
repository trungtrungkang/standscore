# 0016 — Jump links (on-page tap → page)

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0015 (done); 0011 PageOrder (done)
- **Parity IDs:** P1.10
- **G3:** accepted (2026-07-26)
- **G3 notes:** JumpLink = on-page tap target → performance page (distinct from Bookmark list). Destination = 1-based PageOrder page (same as Bookmarks).
- **G4:** pass (2026-07-26)
- **UX revision (2026-07-26):** Orchestrator pass — entry = PdfMode ⋯ → **Jump Links** list sheet (Bookmarks-like); Add / Edit / Delete from that sheet (same sheet, no stacked modals); on-page long-press edit kept.

## Problem

Bookmarks jump from a list; PageOrder handles repeats offline. Musicians also need **visible buttons on the page** (coda, D.S., rehearsal spots) that jump to another performance page with one tap — without opening a sheet. ScorePDF’s jump-link feature places tappable targets on the score for this.

## Outcome

In PdfMode, the user manages **JumpLinks** from a **Jump Links** list (like Bookmarks): add, edit, or delete. Each link is a visible tap target on a page that navigates to a chosen destination page in the current Score’s PageOrder. Links persist with the Score; tapping one on the page jumps; long-press on the page still edits.

## In scope

- Entry: PdfMode ⋯ → **Jump Links** → list sheet (Add / Edit / Delete)
- Add / Edit UI stays **inside** the Jump Links sheet (no second stacked modal)
- Placement: origin (button) on the **current** page when adding; destination = 1-based PageOrder page (same numbering as Bookmarks)
- Visible button on the page (default size + color); tap → jump to destination
- List tap → navigate to the link’s origin page
- Edit: from list **⋯ Edit**, or on-page long-press → change size, color, destination, or delete
- Persist per Score (JSON under Score storage)
- Work in Single page and continuous layouts; jump uses existing page navigation (`_jumpToPage` / equivalent)
- When PageOrder changes and a destination is out of range → clamp to last page (same as Bookmarks)

## Out of scope

- PDF outline / embedded PDF link annotations import
- Setlist cross-Score jump links (destination stays within the open Score; Setlist title jump remains 0012)
- Drawing tools / stamps (P2)
- Cloud sync
- Assigning JumpLink open to GestureMap (0015)

## Domain terms

**Score**, **PdfMode**, **PageOrder**, **PageTurn**, **Bookmark**  
**JumpLink** — on-page tap target that jumps to another performance page (`CONTEXT.md`).

## Acceptance criteria

Testable checklist (G4):

- [x] User can open **Jump Links** from PdfMode ⋯ and see the list of links for this Score
- [x] User can add a JumpLink (origin on current page) with a destination page from the list sheet
- [x] User can edit or delete a link from the list sheet
- [x] Add / Edit does not stack a second modal over the Jump Links sheet
- [x] Tapping the on-page link jumps to the destination page
- [x] Links persist across restart and are per-Score
- [x] User can edit size/color/destination or delete via on-page long-press
- [x] Jump works in Single page and continuous layouts
- [x] Out-of-range destination clamps to last page
- [x] PageTurn / GestureMap still work; link tap does not also PageTurn

## UX notes

- Mirror Bookmarks: list sheet with Add; trailing Edit / Delete; tap row → go to origin page
- Button must be obvious enough for a gig glance; avoid tiny invisible hit areas
- Creating a link should not require Draw mode (separate from annotate)
- **Drag** the button to a clear margin / empty spot so it does not cover notes; long-press edits

## Technical constraints

- Store under Score id path; deep model for link geometry + destination
- Hit-test JumpLinks before PageTurn / GestureMap center taps when overlapping
- TDD: store round-trip; clamp destination; hit-test ordering

## Test plan

- Automated: JumpLink store; destination clamp; hit-test prefers link over PageTurn
- Manual: ⋯ Jump Links → Add → list shows link → Edit / Delete; tap on-page jump; long-press edit; restart
