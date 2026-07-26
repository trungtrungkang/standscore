# 0005 — Pedal and keyboard PageTurn

- **Status:** accepted
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0004 (done)
- **Parity IDs:** P1.1
- **G3:** accepted (2026-07-23)

## Problem

On stage, musicians turn pages with Bluetooth foot pedals that emulate keyboard keys. StandScore only supports tap/swipe PageTurn today.

## Outcome

In PdfMode, PageUp / Left / Up / Space go to the previous page (or spread), and PageDown / Right / Down / Enter go to the next — matching ScorePDF’s pedal mapping. Works while the viewer is focused; ignored in draw mode.

## In scope

- Hardware keyboard / HID pedal key mapping (ScorePDF-compatible):
  - Previous: PageUp, ArrowLeft, ArrowUp, Space
  - Next: PageDown, ArrowRight, ArrowDown, Enter
- Honor current layout PageTurn step (two-page → ±2)
- Draw mode: do not turn pages on these keys
- Optional short note in PdfMode settings that pedals are supported

## Out of scope

- Full custom gesture map (P1.2)
- Page turn delay (P1.3)
- MIDI foot controller protocols beyond keyboard HID
- iOS/Android background key handling outside the app

## Domain terms

**PageTurn**, **PdfMode**

## Acceptance criteria

- [ ] With a hardware keyboard (or simulator key events): Space → previous; Enter → next
- [ ] Arrow keys and PageUp/PageDown map as above
- [ ] Two-page layout advances by a spread
- [ ] Draw mode ON → keys do not change page
- [ ] Tap/swipe PageTurn still works

## Technical constraints

- Prefer Flutter `Focus` / `KeyboardListener` / pdfrx `onKey` if available
- Do not require a physical pedal for automated tests — simulate key events

## Test plan

- Automated: key → PageTurnAction mapping pure function
- Manual: Bluetooth pedal or Mac keyboard connected to device/simulator
