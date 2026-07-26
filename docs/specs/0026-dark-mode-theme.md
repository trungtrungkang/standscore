# 0026 — Dark mode + theme color

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0025 (done)
- **Parity IDs:** P2.10
- **G3:** accepted (2026-07-26)
- **G3 notes:** Appearance = Light / Dark / System. Accent = brand teal `#0D8B86` default + short presets + custom HSV pick. Entry = Library AppBar ⋯ → Appearance…. Persist app-wide. Page tint stays 0025; **no** “match PDF gutter to theme”.
- **G4:** pass (2026-07-26)

## Problem

ScorePDF lets musicians run the app chrome in **dark mode** and pick a **theme color** so Library / menus / toolbars match stage lighting and personal taste. StageScore currently ships a single light Material theme. Page tint (0025) already covers Score pages; this slice covers **app chrome**.

## Outcome

The user can choose **light / dark / system** appearance and a **theme accent color**. Choices persist app-wide. PdfMode page rendering stays controlled by the existing color filter (0025); this Spec does not re-tint PDF pages.

## In scope

- Appearance mode: Light / Dark / System (follow OS)
- Theme accent color (Material seed) with a small preset set + optional custom pick
- Persist prefs app-wide; apply on cold start
- Library, PdfMode chrome (AppBar, menus, sheets, FABs), draw toolbar respect theme
- Entry: Library AppBar ⋯ → Appearance…

## Out of scope

- Page color filter modes (0025 — already done)
- “Match PDF background to theme” (ScorePDF option)
- Per-Score themes
- Dynamic / wallpaper-based Material You color extraction
- Branding asset redesign (logo/splash stay as configured)
- Backup / restore (P2.11)

## Domain terms

**Library**, **PdfMode**

## Acceptance criteria

Testable checklist (G4):

- [x] User can switch Light / Dark / System; UI chrome updates
- [x] System mode follows OS light/dark
- [x] User can pick a theme accent; primary chrome colors update
- [x] Choices survive app restart
- [x] PdfMode pages still use color filter independently (filter Off ≠ forced dark pages)
- [x] Draw / Library / menus remain usable in dark + custom accent

## UX notes

- Prefer a single Appearance sheet (mode + accent) over scattered toggles
- Keep presets short; custom color must not require a design tool

## Technical constraints

- Flutter `ThemeData` / `ColorScheme.fromSeed`; `themeMode` on `MaterialApp`
- Prefs round-trip TDD’d
- Do not bake theme into PDF export

## Test plan

- Automated: prefs serialize/deserialize for mode + accent
- Manual: System flip OS theme; Dark + accent in Library + PdfMode; color filter still independent
