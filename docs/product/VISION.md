# Product Vision

**Product name:** StandScore  
**Publisher:** BackingScore ([backingscore.com](https://backingscore.com))  
**Bundle ID:** `com.backingscore.scoreapp` *(ADR 0009)*  
**Status:** accepted (G0 — Human Orchestrator 2026-07-22)  
**Last updated:** 2026-07-22 (G0 + Flutter shell accepted)

---

## One-liner

**StandScore** (by **BackingScore**) is a multi-platform sheet music app that **first matches ScorePDF-class PDF performance UX**, then adds **Smart Score** (MusicXML), practice Transport, and **BackingTrack** play-along — orchestrated by a human, built primarily by AI against locked specs.

---

## Who it is for

- **Primary (early phase):** Instrumentalists who perform from digital PDF scores (tablet on a stand)
- **Later:** Learners who want follow-along playback, wait-mode, and band BackingTracks
- Secondary: teachers building setlists for students

---

## Problem

1. Generic PDF readers fail on stage: unreliable page turns, weak setlists, awkward repeats/codas.
2. ScorePDF sets the bar for PDF performance UX; we must clear that bar before betting on SmartMode.
3. Longer-term: ScorePDF-class apps do not own photo → MusicXML → practice with synced audio/backing.

---

## Product pillars

| Pillar | Promise | Early phase |
|--------|---------|-------------|
| **Performance PDF** | Tap/swipe/pedal page turns, layouts, reorder, annotations, setlists — **parity target: ScorePDF** | **In scope** |
| **Smart Score** | MusicXML + Verovio, AutoPlay, WaitMode | After parity |
| **Play along** | BackingTrack via multi-lane Transport | After Smart Score core |
| **Capture path** | OMR + CorrectionSession | Later |
| **Multi-platform** | iOS, Android, Web — offline-first for performance | Shell per ADR 0005; PDF UX first |

---

## Non-goals (for now)

- Full notation editor rivaling MuseScore desktop
- Social network / feed
- Replacing DAW / recording suite (attach + align + mix BackingTracks; not a full timeline editor)
- Perfect fully automatic OMR with no human correction
- Embedding MuseScore as in-app renderer
- **Early phase:** SmartMode, OMR, BackingTrack Feature Specs (architecture docs only — ADR 0008)

---

## Success

### Early (Gate for opening H3+)

- Musician can run a short gig from PDFs with pedal + setlist + PageOrder without fighting the UI
- PdfMode covers the ScorePDF parity checklist (`docs/product/SCOREPDF-PARITY.md`) at a level the Orchestrator accepts

### Later

- Learner can import MusicXML, hear MIDI, use WaitMode, and play with a BackingTrack
- Web + mobile share Smart Score Transport behavior

---

## Capability horizons (not a sprint plan)

**Early phase = H0 + H1 + H2 only** until ADR 0008 exit criteria are met.

| Horizon | Focus |
|---------|--------|
| **H0** | Process + language + ADRs locked enough to build |
| **H1** | ScorePDF **P0**: import, library, layouts, PageTurn (tap/swipe/zoom) |
| **H2** | ScorePDF **P1–P2**: pedal, gestures, setlist, PageOrder, bookmarks, half-page, annotate, labels, export, backup, metronome, filters… |
| **H3** | Smart Score core (blocked until early parity accepted) |
| **H4** | WaitMode + PracticePolicy |
| **H5** | BackingTrack + SyncMap |
| **H6** | OMR + CorrectionSession |
| **H7** | Remaining polish / differentiation beyond ScorePDF |

Parity IDs and tracking: [`SCOREPDF-PARITY.md`](./SCOREPDF-PARITY.md).

---

## Competitive reference

- **Early benchmark (PDF):** [ScorePDF](https://enoiu.com/en/app/scorepdf/) — **follow closely**
- **Later differentiation:** Smart Score + Transport + BackingTrack; web client; human-gated AI delivery

---

## Open product questions (need Human)

1. ~~Product name / publisher / bundle ID?~~ → **StandScore** by **BackingScore**; `com.backingscore.scoreapp` (ADR 0009). Domain/trademark checks still advised before store submit.
2. ~~Ship order PDF-first vs Smart-first?~~ → **Decided: PDF / ScorePDF first (ADR 0008)**
3. Must offline work with zero network always? (PDF phase: default yes)
4. OMR: commercial API vs self-host? (post-parity)
5. Monetization model (if any) before public release?
6. Backing v1: stereo only or stems? (post-parity)
7. BackingTrack armed: lock tempo vs time-stretch? (post-parity)
8. Which ScorePDF rows are acceptable `wont` for v1 gig (e.g. accordion symbols)?

---

## Gate G0

**Accepted** by Human Orchestrator (2026-07-22), together with ADR 0005 (Flutter) and Spec 0001 (PDF annotate spike).
