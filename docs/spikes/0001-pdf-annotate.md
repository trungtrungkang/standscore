# Spike 0001 — PDF open, zoom, annotate

- **Spec:** `docs/specs/0001-spike-pdf-annotate.md`
- **Date:** 2026-07-22
- **Closed:** 2026-07-23
- **Stack:** Flutter 3.44 + **pdfrx** (PDFium)
- **App id:** `com.backingscore.scoreapp`
- **Code:** `sheet-app/standscore/`

## What was built

- Flutter iOS/Android scaffold with correct bundle/application id
- Asset sample PDF (6 pages, faux staves)
- `PdfViewer.asset` + `pageOverlaysBuilder` annotation overlay
- Strokes stored in **normalized page coordinates** (survive zoom/pan)
- Draw mode toggles `panEnabled` / `scaleEnabled` off while inking
- Undo via app bar
- Unit tests for `AnnotationStore`
- iOS simulator build verified

## Orchestrator demo

| Criterion | Result |
|-----------|--------|
| Device PDF + annotate feel | **Accepted by Orchestrator (go)** |
| Pinch-zoom / pan usable | pass (Orchestrator) |
| Ink stays registered under zoom | pass (Orchestrator) |
| Undo works | pass (Orchestrator) |

## Go / no-go

**Status: go** (Human Orchestrator, 2026-07-23)

→ Proceed to H1 P0 Feature Specs. ADR 0005 (Flutter + pdfrx) remains the shell.

## Notes for implementer

- Run: `cd sheet-app/standscore && flutter run`
- Draw mode must be ON to annotate (otherwise viewer eats gestures for pan/zoom)
- Export-with-annotations not in this spike
