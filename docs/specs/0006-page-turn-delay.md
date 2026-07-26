# 0006 — Page turn delay (anti double-turn)

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0005 (accepted; G4 pending)
- **Parity IDs:** P1.3
- **G3:** accepted (2026-07-26)
- **G4:** pass (2026-07-26)

## Problem

On stage, Bluetooth pedals and fast taps often fire twice. Musicians skip an extra page. ScorePDF offers a short lockout after each PageTurn; StageScore accepts every action immediately.

## Outcome

After a successful PageTurn in PdfMode, further PageTurn inputs are ignored for a configurable delay. The musician can choose whether the lockout applies to all inputs or pedal/keyboard only. Choice persists at app level.

## In scope

- Page turn delay duration (ScorePDF-style presets or a small set of options, e.g. Off / 0.3s / 0.5s / 1.0s — exact labels OK to refine in UX notes)
- Scope toggle: **all PageTurn inputs** vs **pedal/keyboard only** (tap/swipe still immediate when pedal-only)
- Persist prefs with existing PageTurn prefs (or adjacent JSON under `stagescore/`)
- Apply lockout after next/prev from tap, swipe, pedal/keyboard, and single-page slider programmatic turns
- Draw mode unchanged (keys already ignored)

## Out of scope

- Custom gesture map (P1.2)
- Animation on/off + speed (P1.4)
- Reverse page-turn direction (P1.5)
- Per-score delay override
- MIDI non-HID pedals

## Domain terms

**PageTurn**, **PdfMode**

## Acceptance criteria

- [x] With delay Off, rapid PageTurn inputs all apply (current behavior)
- [x] With delay On (e.g. 0.5s), a second PageTurn within the window is ignored
- [x] After the delay elapses, the next PageTurn applies
- [x] Pedal-only mode: keyboard/pedal is delayed; tap/swipe is not
- [x] All-inputs mode: tap, swipe, and pedal share the same lockout
- [x] Setting survives app restart
- [x] Visible in PageTurn settings (near existing tap/swipe controls)

## UX notes

- Prefer plain labels: “Page turn delay”, “Apply to: All / Pedal & keyboard only”
- Default: **Off** (G3)

## Technical constraints

- One shared lockout clock for PdfMode (not per-layout duplicate state)
- Do not require a physical pedal for automated tests — drive `_applyAction` / delay helper directly

## Test plan

- Automated: delay gate pure function / small class (action allowed vs blocked given timestamps + prefs)
- Manual: set 0.5s, mash Space/Enter or tap zones; confirm single advance then unlock
