# Verovio for SmartMode rendering

SmartMode renders MusicXmlDocument with Verovio (WASM/C++), not an embedded MuseScore instance and not PDF rasterization of MusicXML.

**Status:** proposed

## Considered options

- **Embedded MuseScore** — rejected: heavy, poor embed story, slow iteration for agents.
- **OpenSheetMusicDisplay / VexFlow only** — possible later for simpler scores; Verovio preferred as primary for MusicXML fidelity and MIDI tooling adjacency.
- **Verovio** — proposed: mature MusicXML → SVG, fit for webview-based UI.

## Consequences

- SmartMode UI stack should host Verovio comfortably (web or webview).
- Playhead sync is against Verovio’s timing/IDs — Specs must define ID mapping to MidiRealization.
