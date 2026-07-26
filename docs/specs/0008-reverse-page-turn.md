# 0008 — Reverse page-turn direction

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0007 (done)
- **Parity IDs:** P1.5
- **G3:** accepted (2026-07-26)
- **G4:** pass (2026-07-26)

## Problem

Some scores (and RTL reading habits) want “next” to enter from the left. StandScore always uses LTR PageTurn (next from the right). ScorePDF offers a reverse direction toggle.

## Outcome

In PdfMode PageTurn settings, the user can enable **Reverse page-turn direction**. When on, next/prev swap visual slide direction and the meaning of tap zones / swipe / pedal for advancing vs going back stays consistent with “next = later page in PageOrder” (only the motion and left/right gesture mapping reverse). Choice persists at app level.

## In scope

- Toggle: Reverse page-turn direction (default Off)
- Single page: reverse horizontal slide (next from left → right when reversed)
- Invert horizontal tap zones and horizontal swipe mapping when reversed (left half → next, swipe right → next, etc.)
- Pedal/keyboard: keep ScorePDF key → previous/next semantics (Space still previous page number); do **not** invert which key means “later page”
- Persist with PageTurn prefs
- Visible in PageTurn settings

## Out of scope

- Custom gesture map beyond direction reverse (P1.2)
- Vertical tap/swipe remapping quirks beyond what’s needed for consistency
- Per-score override
- RTL locale auto-enable

## Domain terms

**PageTurn**, **PdfMode**, **PageOrder**

## Acceptance criteria

- [x] Reverse Off → current LTR behavior (next from right)
- [x] Reverse On → Single page next animates from left; prev from right
- [x] Reverse On → left tap / swipe-right advance to later page (and mirrors)
- [x] Pedal keys still: Space/←/↑/PageUp = earlier page; Enter/→/↓/PageDown = later page
- [x] Setting survives app restart
- [x] Works with delay (0006) and animation (0007)

## UX notes

- Label: “Reverse page-turn direction”
- Short helper: “For books that turn the other way”

## Technical constraints

- Prefer flipping animation + horizontal gesture mapping; keep `PageTurnAction.next/previous` as document order
- Document pedal non-inversion in Spec (above) so implementers do not “helpfully” swap keys

## Test plan

- Automated: mapping helper for reverse horizontal tap/swipe; prefs round-trip
- Manual: Single page Off vs On; pedal still advances correctly
