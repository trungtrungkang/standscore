# 0014 — Page turn amount (1/1 vs 1/2)

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0013 (accepted / G4 pending)
- **Parity IDs:** P1.12
- **G3:** accepted (2026-07-26)
- **G3 notes:** Discrete Single / Half-page layout always step 1 page (Half turn amount ignored). Fit width/height Half = ~½ viewport scroll.
- **G4:** pass (2026-07-26)

## Problem

In continuous reading (especially **Fit width** vertical scroll), a full PageTurn jumps an entire page and can skip systems the musician still needs. ScorePDF’s **Turn Amount** lets PageTurn advance by half a page so current and next content stay on screen together. This is **not** the Half Page layout (P1.9 / Spec 0013): Half Page overlays a peek; Turn Amount actually scrolls/advances by a fraction.

## Outcome

In PdfMode PageTurn settings, the user can choose **Turn amount: Full (1/1)** or **Half (1/2)**. When Half is selected, each PageTurn (tap / swipe / pedal) advances by approximately half a viewport (or half a page step in discrete modes where applicable) instead of a full page. Choice persists at app level.

## In scope

- Setting: Turn amount `full` | `half` (default `full`)
- Entry in PageTurn settings sheet (near delay / animation / reverse)
- Persist with PageTurn prefs
- **Primary target:** Fit width (vertical continuous) and Fit height (horizontal continuous) — PageTurn scrolls by ~½ viewport along the scroll axis
- **Two-page spread:** Half amount advances by **one page** within the spread when that matches ScorePDF’s “turn one page at a time while in two-page display”; Full keeps current spread step (`pageTurnStepFor` = 2)
- **Single page** and **Half-page layout (0013):** Full = one performance page; Half may no-op as Full for this Spec (document) **or** still step one page — prefer: discrete page modes ignore half and always step one performance page (half is for scroll layouts + two-page refinement)
- Pedal / keyboard use the same amount
- Page slider jump-to-number and Bookmarks still jump to absolute performance pages (not half-steps)
- PageTurn delay / animation still apply to the resulting motion when animated

## Out of scope

- Half Page layout overlay / separator (P1.9 / 0013 — already separate)
- Custom fractions beyond 1/2 (e.g. 1/3)
- Per-score turn amount
- Changing how the page chrome page number reports fractional positions (report nearest performance page or topmost visible page — implementer picks simplest consistent rule)

## Domain terms

**PageTurn**, **PdfMode**  
**TurnAmount** — how far one PageTurn advances (`full` | `half`). Distinct from Half Page layout.

## Acceptance criteria

Testable checklist (G4):

- [x] User can set Turn amount Full vs Half; choice survives restart
- [x] Fit width + Half: PageTurn next scrolls ~half a viewport down (prev up); Full scrolls ~one page height
- [x] Fit height + Half: PageTurn next scrolls ~half a viewport sideways
- [x] Two-page + Half: PageTurn advances one page (not a full spread); Full advances a spread
- [x] Single page + Half: still one performance page per turn (no broken half-slide)
- [x] Half Page layout (0013) still works; Turn amount does not replace its peek UI
- [x] Bookmarks / page jump still go to whole performance pages

## UX notes

- Label clearly: “Turn amount” with options “Full page” / “Half page” — avoid confusing with layout “Half page (top/bottom)”
- Optional one-line hint under Half: “Best with Fit width scroll”

## Technical constraints

- Prefer deep helper: resolve scroll/page delta from layout mode + TurnAmount
- Continuous modes: scroll by `viewportExtent * 0.5` (half) or page-sized step (full) — document chosen mapping
- TDD for delta resolution matrix (mode × amount → step kind)

## Test plan

- Automated: turn-amount prefs round-trip; delta helper matrix
- Manual: Fit width + Half with pedal; compare Full; two-page Half vs Full; confirm 0013 Half Page layout unchanged
