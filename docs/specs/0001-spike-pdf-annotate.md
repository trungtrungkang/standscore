# 0001 — Spike: PDF open, zoom, and annotate on device

- **Status:** done
- **Type:** spike
- **Horizon:** H0 / pre-H1
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008, 0009
- **Depends on Specs:** —
- **G4:** go (2026-07-23) — see `docs/spikes/0001-pdf-annotate.md`

## Problem

We chose Flutter for PdfMode performance, but have not yet proven PDFium + stylus ink feel “good enough to gig” on real tablets. Building the full library without that proof risks a dead-end stack.

## Outcome

A minimal Flutter app (bundle id `com.backingscore.scoreapp`) on **one iPad** and **one Android tablet** can open a multi-page PDF, pinch-zoom/pan smoothly, draw annotation strokes (finger and stylus if available), undo, and keep strokes aligned after zoom/pan.

## In scope

- Flutter project scaffold with application id `com.backingscore.scoreapp`
- Pick and wire a PDFium-based Flutter PDF viewer
- Page coordinate annotation overlay (draw + undo)
- Manual demo script on two devices
- Short written spike report: library chosen, issues, go/no-go for H1

## Out of scope

- Full library / setlist / ScorePDF parity features
- SmartMode / Verovio / Transport / BackingTrack
- Export PDF with annotations (may note as follow-up)
- Polish UI / branding beyond showing the logo optionally
- Flutter Web

## Domain terms

**PdfMode**, **PdfDocument**, **Score** (minimal: one local PDF file treated as a Score stand-in)

## Acceptance criteria

- [ ] App runs on iOS tablet and Android tablet with id `com.backingscore.scoreapp`
- [ ] Open a local sample PDF (≥ 5 pages, music-like content)
- [ ] Pinch-zoom and pan remain usable (Orchestrator subjective “no fighting the UI”)
- [ ] Draw ink on the page; strokes stay registered to the page under zoom/pan
- [ ] Undo removes last stroke
- [ ] Stylus path tested if hardware available (Apple Pencil or equivalent); finger path always tested
- [ ] Spike report checked into `docs/spikes/0001-pdf-annotate.md` with **go** or **no-go** + rationale

## Technical constraints

- Flutter per ADR 0005
- Prefer open-source PDFium binding; if blocked, document paid SDK as contingency (do not silently switch)
- Annotation must not be implemented as a screenshot-baked layer that breaks on zoom

## Test plan

- Automated: smoke test that PDF bytes load / page count > 0 (if feasible in CI without GPU)
- Manual demo: Orchestrator follows acceptance checklist on both devices

## Spike-only fields

- **Question:** Can Flutter + PDFium deliver ScorePDF-class PDF view + annotation feel on target tablets?
- **Time box:** 2 days agent work + 1 Orchestrator demo session
- **Success metric:** Orchestrator marks checklist pass → **go** for H1 P0 Specs; else **no-go** and revisit ADR 0005
- **Outputs:** spike report; optional ADR amendment if library choice is non-obvious
