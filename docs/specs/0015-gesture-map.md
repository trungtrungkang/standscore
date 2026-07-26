# 0015 — Gesture map (long-press, edge taps → menu / annotate)

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0014 (done)
- **Parity IDs:** P1.2
- **G3:** accepted (2026-07-26)
- **G3 notes:** Keep StageScore chrome always visible (no immersive hide). Show menu = open ⋯ overflow (or equivalent). Defaults: long-press + top → Show menu; bottom → Draw.
- **G4:** pass (2026-07-26)

## Problem

PdfMode already has **PageTurn** (Spec 0003): tap left/right (or top/bottom) halves to change page. That uses most of the screen.

Musicians also need quick access to **non–page-turn** actions during a gig — especially opening the menu / app chrome and entering Draw — without hunting for a small app-bar icon. ScorePDF solves this with a separate **gesture map**: long-press and thin top/bottom **edge** taps map to menu / annotate / off, so they do not fight the big PageTurn zones.

## What this Spec is (and is not)

| | **PageTurn tap zones (0003)** | **GestureMap (0015)** |
|--|--|--|
| Purpose | Previous / next page | Menu or Off |
| Where | Large halves of the viewer | Long-press anywhere; thin top & bottom edge strips |
| Example | Tap right half → next page | Tap top edge → open the ⋯ menu |

**Not in this Spec:** left/right edge actions, metronome, jump links, custom “open bookmarks” catalog, auto-hiding AppBar (ScorePDF immersive) — StageScore keeps chrome visible.

## Outcome

The user can open **Page turn → Gestures** (or equivalent) and assign each of these inputs to one action:

| Input | Meaning |
|-------|---------|
| **Long-press** | Press and hold on the score (not in Draw mode for Draw action) |
| **Top edge** | Short tap in a thin band along the **top** of the viewer |
| **Bottom edge** | Short tap in a thin band along the **bottom** of the viewer |

| Action (UI label) | Behavior in StageScore |
|-------------------|------------------------|
| **Show menu** | Open the PdfMode **⋯** overflow menu (chrome stays always visible). Do not PageTurn. |
| ~~**Draw**~~ | **Removed in Spec 0034.** Landing in Draw mode from a stray tap was a surprise the player had to undo mid-piece; Draw is entered from the toolbar only. Saved `enterDraw` assignments read back as Off. |
| **Off** | Edge: fall through to PageTurn if applicable. Long-press: do nothing. |

**Hard rule (ScorePDF):** at least one of {long-press, top edge, bottom edge} must be **Show menu**. Settings must reject or auto-correct configs that leave menu unreachable by gesture.

Choices persist at app level.

## Screen geometry (mental model)

```text
┌─────────────────────────────┐
│████ TOP EDGE (~6% height) ██│  ← GestureMap (tap)
├─────────────────────────────┤
│                             │
│   LEFT HALF  │  RIGHT HALF  │  ← PageTurn (0003), if L/R mode
│   (prev)     │  (next)      │
│                             │
│        LONG-PRESS OK        │  ← GestureMap (hold)
├─────────────────────────────┤
│██ BOTTOM EDGE (~6% height) █│  ← GestureMap (tap)
└─────────────────────────────┘
     PageNavBar (outside viewer) stays as today
```

- Edge bands with a non-Off action **win over** PageTurn.
- Edge bands mapped to Off: tap may PageTurn (e.g. top/bottom PageTurn mode).
- Outside the bands, PageTurn and swipe behave exactly as today (0003–0014).
- Long-press must not fire a PageTurn on release.

## Defaults (G3 locked)

| Input | Default action |
|-------|----------------|
| Long-press | Show menu |
| Top edge | Show menu |
| Bottom edge | ~~Draw~~ → **Off** (Spec 0034, along with the Draw action itself) |

## In scope

- Settings UI: three rows (Long-press / Top edge / Bottom edge), each a choice of Show menu · ~~Draw~~ · Off
- Validation: ≥1 Show menu
- Edge band height: **6%** of viewer height (clamp min ~24 logical px)
- Wire into the PageTurn interaction layer:
  - **Draw mode OFF:** edges + long-press honor the map; PageTurn as today
  - **Draw mode ON:** PageTurn off; **Show menu** still works if mapped; **Off** does nothing
- Persist beside PageTurn prefs (same JSON file)
- Pedal / keyboard unchanged

## Out of scope

- Assigning left/right edges
- Metronome (P2.13)
- Actions beyond Show menu / Off
- Auto-hiding the AppBar / immersive mode (explicitly deferred; keep current always-visible chrome — **reopened by Spec 0034**, where Show menu / chrome also reveals hidden chrome)
- Jump links (P1.10)

## Domain terms

**PageTurn**, **PdfMode**, **GestureMap**

## Acceptance criteria

- [x] User can assign each of long-press, top edge, bottom edge to Show menu / ~~Draw~~ / Off
- [x] Cannot save a map with zero Show menu assignments
- [x] Top/bottom edge taps (non-Off) run the mapped action and never PageTurn
- [x] Long-press runs the mapped action and does not PageTurn on lift
- [x] ~~Draw action enables existing Draw mode~~ (action removed, Spec 0034)
- [x] Show menu opens the ⋯ overflow menu
- [x] Center (non-edge) taps still PageTurn per 0003
- [x] Prefs survive restart
- [x] Defaults: long-press and top → Show menu; bottom → ~~Draw~~ Off (Spec 0034)

## UX notes

- Section title: **Gestures** (under Page turn settings)
- Helper: “Edge taps are thin strips at the top and bottom — not the same as Top/bottom page-turn zones.”

## Technical constraints

- Deep helpers: `isInVerticalEdgeBand`, `validateGestureMap`, edge/long-press resolve
- TDD those helpers; widget wiring thin
- Must not break Half Page layout (0013) or Turn Amount (0014)

## Test plan

- Automated: prefs round-trip; edge band math; validateGestureMap rejects no-Show-menu
- Manual: bottom edge → next page (Off falls through); long-press → ⋯ menu; tap center right → next page
