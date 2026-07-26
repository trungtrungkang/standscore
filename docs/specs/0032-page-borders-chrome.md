# 0032 — Page borders; status bar / notch options

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0031 (done)
- **Parity IDs:** P2.15
- **G3:** accepted (2026-07-26)
- **G3 notes:** Entry = PdfMode ⋯ → **Display…**. Border default off (~2 pt, dark gray); Half Page separator shares thickness/color when border on. Chrome defaults: status bar **hidden**; avoid notches **on**. Scope app-wide.
- **G4:** pass (2026-07-26 — after border overlay fix)

## Problem

On tablets with notches / Dynamic Island / home indicators, Score pages can sit under system chrome or waste space with padding. ScorePDF lets musicians toggle **page borders** (thickness + color) and choose **Show status bar** / **Avoid notches and bars**. StageScore PdfMode has no controls for page frame or system-inset policy.

## Outcome

In PdfMode, the user can show an optional **page border** (on/off, thickness, color) and control **system chrome**: whether the status bar is visible, and whether the Score layout **avoids notches and bars** (safe insets) or draws edge-to-edge. Choices persist. Annotate / PageTurn / Page scale remain usable.

## In scope

- Page border: on/off + thickness + color
- Apply border style to Half Page separator (ScorePDF parity)
- Show status bar: on/off (PdfMode)
- Avoid notches and bars: on/off (safe-area insets vs edge-to-edge)
- Entry: PdfMode ⋯ → Display…
- Persist preferences app-wide
- Works across Single / continuous / Half Page layouts

## Out of scope

- Metronome (0030)
- Max page DPI (deferred with 0031)
- Matching PDF gutter color to theme (cut in 0026)
- Per-Score / Per-Page border or chrome prefs
- Changing PDF crop boxes

## Domain terms

**PdfMode**, **Score**, **PdfDocument**

## Acceptance criteria

Testable checklist (G4):

- [x] User can toggle page border and see a frame around the page
- [x] Border thickness and color update the frame (and Half Page separator when applicable)
- [x] Show status bar on/off changes PdfMode system status bar visibility
- [x] Avoid notches on → content clears cutouts/home indicator; off → edge-to-edge where platform allows
- [x] Choices survive app restart
- [x] PageTurn / annotate / page scale still work with each combination

## UX notes

- One compact “Display” sheet: border block + chrome toggles
- Defaults: border **off**; show status bar **off** (immersive); avoid notches **on** (safe)
- Border presets short; custom color via existing picker patterns if cheap

## Technical constraints

- Prefer Flutter `SystemChrome` / `SafeArea` / `MediaQuery.padding`; no native forks
- Prefs round-trip TDD’d
- Do not break draw hit targets or PageTurn overlay

## Test plan

- Automated: display prefs serialize/deserialize; defaults
- Manual: border on Single + Half Page; status bar toggle; notch avoid on iPhone/iPad with cutout; restart
