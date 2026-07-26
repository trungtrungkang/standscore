# Dual modes: PdfMode and SmartMode on one Score

A Score may have a PdfDocument and/or a MusicXmlDocument. The product exposes two viewing modes — PdfMode (performance PDF) and SmartMode (MusicXML rendering + Transport) — instead of forcing a single renderer for all files.

**Status:** proposed

## Considered options

- **PDF only (ScorePDF clone)** — rejected long-term: blocks AutoPlay/WaitMode/OMR path.
- **MusicXML only** — rejected: most gig charts remain PDF; OMR is imperfect.
- **Dual mode on one Score** — proposed: matches user reality and our roadmap horizons.

## Consequences

- Shared library/setlist concepts; separate viewer pipelines.
- Migration/replace flows (e.g. replace PDF, attach MusicXML) need explicit Specs later.
- **Sequencing:** early phase builds PdfMode only (ADR 0008); SmartMode Specs wait until ScorePDF parity is accepted.