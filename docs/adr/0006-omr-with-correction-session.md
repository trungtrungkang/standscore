# OMR runs out-of-process with mandatory CorrectionSession

Photograph/scan to MusicXML is modeled as an OmrJob whose output is always a draft until a CorrectionSession accepts a MusicXmlDocument. OMR does not write directly into trusted SmartMode data.

**Status:** proposed

## Considered options

- **On-device only, fully automatic** — rejected for v1 accuracy and CPU/battery cost.
- **Server/API OMR + CorrectionSession** — proposed: realistic quality bar; privacy implications must be Spec’d (consent, retention).
- **No OMR; MusicXML import only** — valid MVP cut; keep as scope option in VISION horizons (H5 deferrable).

## Consequences

- H5 Specs must include privacy, failure UX, and edit affordances.
- AutoPlay/WaitMode must not depend on uncorrected OMR output.
