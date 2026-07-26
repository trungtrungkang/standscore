# 0025 — Color filter (sepia / green / invert)

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0024 (done)
- **Parity IDs:** P2.9
- **G3:** accepted (2026-07-26)
- **G3 notes:** Modes = Off / Sepia / Green / Invert. App-level persist. Entry = PdfMode ⋯ menu. Apply via ColorFiltered (does not mutate PDF). Page content + on-page annotations tint together; does not change app chrome colors.
- **G4:** pass (2026-07-26)

## Problem

Bright white PDF pages strain eyes under stage lights or at night. ScorePDF offers **page color filters** (sepia, green, invert) so musicians can tint the Score view without editing the file. StageScore needs the same comfort controls in PdfMode.

## Outcome

In PdfMode, the user can apply a **color filter** to the rendered pages — **Off**, **Sepia**, **Green**, or **Invert**. The choice persists app-wide. Annotations and PageTurn remain usable with the filter on.

## In scope

- PdfMode ⋯ control to pick color filter
- Modes: Off / Sepia / Green / Invert
- Persist preference (app-level)
- Apply to page rendering without mutating the imported PDF
- Works across Single / continuous / Half Page layouts

## Out of scope

- Dark mode / theme color for the whole app chrome (P2.10)
- Per-page different filters
- Per-Score filter preference
- Exporting PDF with filter baked in
- Editing PDF colors in the file

## Domain terms

**PdfMode**, **Score**, **PdfDocument**

## Acceptance criteria

Testable checklist (G4):

- [x] User can switch among Off / Sepia / Green / Invert
- [x] Filter is visible on the Score pages
- [x] Choice survives app restart
- [x] Draw / stamps / PageTurn still work with a filter on
- [x] Turning filter Off restores the original page look

## UX notes

- Compact submenu under ⋯ — not a wall of preview cards
- Filter should not break jump-link / draw hit targets

## Technical constraints

- ColorFiltered / matrix; no re-encoding pages
- Prefs round-trip TDD’d

## Test plan

- Automated: prefs serialize/deserialize; matrix non-identity for each mode
- Manual: each filter on Single + Half Page; draw with sepia; restart
