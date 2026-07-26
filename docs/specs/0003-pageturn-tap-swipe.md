# 0003 — PageTurn: tap zones and swipe

- **Status:** done
- **Type:** feature
- **Horizon:** H1
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0002 (done)
- **Parity IDs:** P0.3, P0.4
- **G3:** accepted (2026-07-23)
- **G4:** pass (2026-07-23)

## Problem

Musicians need hands-free-friendly page turns. Today PdfMode only scrolls/zooms via pdfrx defaults — there is no ScorePDF-style tap-zone or configurable swipe PageTurn.

## Outcome

In PdfMode, the user can turn pages with configurable tap zones and optional directional swipes, without opening a separate chrome control for every turn.

## In scope

- Tap zone modes: previous / next / left-right split / top-bottom split / disabled
- Swipe PageTurn: enable/disable per direction (up, down, left, right) as product toggles (sensible defaults OK)
- Defaults suitable for performance: left-right tap split (left=prev, right=next); horizontal swipe on
- Persist PageTurn prefs (app-level for this Spec; per-score later)
- Coexist with zoom/pan: when zoomed in, prefer pan over PageTurn swipe (document behavior)
- Draw mode still disables PageTurn gestures (same as pan/zoom lock)

## Out of scope

- Pedal / keyboard (P1.1)
- Full gesture map for menu/annotate edges (P1.2)
- Page turn delay / animation polish (P1.3–P1.4)
- Reverse direction (P1.5)
- Two-page / half-page layouts (P0.5–P0.6, P1.9)
- PageOrder / setlist

## Domain terms

**PageTurn**, **PdfMode**, **Score**

## Acceptance criteria

- [x] With left-right tap mode: tap left half → previous page; right half → next page
- [x] Top-bottom mode works analogously
- [x] Disabled mode: taps do not change page
- [x] Swipe can turn page in at least left/right when enabled
- [x] User can change tap mode in a simple settings entry from PdfMode
- [x] Draw mode ON → PageTurn taps/swipes do not fire
- [x] Prefs survive app restart

## UX notes

- Do not steal double-tap zoom if pdfrx uses it — prefer single tap for zones
- Show a one-time hint on first open of PdfMode after this Spec (“Tap right for next page”)

## Technical constraints

- Flutter + pdfrx; use viewer/page overlays or controller page navigation APIs
- Keep annotation overlay working

## Test plan

- Automated: PageTurn preference model + zone hit-testing pure functions
- Manual: multi-page Score on tablet; verify modes and draw-mode lockout
