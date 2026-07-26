# 0031 — Zoom lock + page scaling (fixed / per Score / per page)

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0029 (done); 0030 deferred
- **Parity IDs:** P2.14
- **G3:** accepted (2026-07-26)
- **G3 notes:** **Scale + lock only** (no DPI). Lock = **disable pinch/double-tap scale**. Entry = PdfMode ⋯ → **Page scale…**. Scopes Fixed / Per Score / Per Page with inheritance page → score → fixed. Range ~0.5×–1.5×.
- **G4:** pass (2026-07-26)

## Problem

On stage, musicians often want a stable magnification — pinch zoom can drift mid-performance. ScorePDF lets users **lock page scaling** at Fixed / Per Score / Per Page levels. StageScore has pinch/double-tap zoom but no lock or scoped scale preference.

## Outcome

In PdfMode, the user can set a **page scale** and choose its scope — **Fixed** (app-wide), **Per Score**, or **Per Page** — and optionally **lock** so pinch/double-tap scaling is disabled. Settings persist. Annotate / PageTurn remain usable at the locked scale.

## In scope

- Page scale control (~0.5×–1.5×)
- Scope modes: Fixed / Per Score / Per Page (inheritance: Page ← Score ← Fixed)
- Zoom lock on/off (when locked, pinch/double-tap scale disabled)
- Entry: PdfMode ⋯ → Page scale…
- Persist preferences for the chosen scopes
- Works across Single / continuous / Half Page layouts where scale applies

## Out of scope

- Metronome (0030 deferred)
- Page borders / status bar / notch (P2.15)
- Max page DPI / render resolution (deferred; ScorePDF OOM risk)
- Per-Setlist “apply scale to all Scores” bulk action
- Changing PDF crop / trim boxes in the file
- Peek-then-snap pinch while locked

## Domain terms

**PdfMode**, **Score**, **PdfDocument**

## Acceptance criteria

Testable checklist (G4):

- [x] User can set page scale and see the Score update
- [x] Fixed / Per Score / Per Page scopes behave with documented inheritance
- [x] With lock on, pinch/double-tap scale is disabled
- [x] Per-Score scale survives reopen of that Score
- [x] Per-Page scale applies only to that page
- [x] Other Scores unaffected by a Per-Score setting on Score A

## UX notes

- One “Page scale” sheet: scope + slider + lock toggle
- Keep defaults safe (1.0×, unlocked)

## Technical constraints

- Prefer applying scale in the viewer transform layer; avoid re-encoding PDFs
- TDD: prefs inheritance resolution (page → score → fixed); prefs round-trip

## Test plan

- Automated: resolveEffectiveScale(fixed, score, page); prefs round-trip
- Manual: Fixed 1.2× → all Scores; Per Score on A; Per Page on page 3; lock disables pinch
