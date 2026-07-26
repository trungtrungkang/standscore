# Early phase: ScorePDF parity first

The first shippable product phase targets **PdfMode feature parity with ScorePDF**. SmartMode, Transport audio, BackingTrack, and OMR stay documented for architecture but are **out of scope for early Feature Specs** until PdfMode parity is accepted as “good enough to gig.”

**Status:** accepted  
**Decided by:** Human Orchestrator (2026-07-22)

## Considered options

- **Smart-Score-first** — rejected for early phase: longer path to a usable performance app; higher architectural risk before product feel is proven.
- **Thin PDF MVP then jump to MIDI** — rejected: leaves page-turn/setlist/annotation gaps that define the ScorePDF benchmark.
- **ScorePDF parity first (PdfMode)** — accepted: match the known performance UX, then layer SmartMode on a stable library/viewer.

## Consequences

- Horizons **H1–H2** (and PdfMode items previously parked in “polish”) are the only build targets until Orchestrator opens H3+.
- ADR 0003–0007 remain valid as **future architecture**; do not implement Verovio/Transport/OMR Specs in early phase except optional no-op seams if an early Spec explicitly allows.
- App shell (ADR 0005) should optimize for **PDF performance UX** in this phase; SmartMode hosting can be deferred but must not paint the shell into a dead end (see ADR 0005 options).
- Parity checklist: `docs/product/SCOREPDF-PARITY.md`.
- Early success metric = musician can gig from PDFs — not MusicXML practice.
