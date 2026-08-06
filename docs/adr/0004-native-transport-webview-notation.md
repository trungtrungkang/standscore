# Native Transport owns timing and audio on iOS/Android

On iOS and Android, Transport (playback clock, multi-lane audio including MIDI, click, and future BackingTrack) runs in a native audio layer. The WebView owns notation display and Playhead drawing. The bridge carries coarse anchors and control messages — not audio-rate MIDI events. See also ADR 0007 (multi-lane Transport).

**Status:** proposed — **scope narrowed by ADR 0019 (accepted 2026-08-05)**

## Scope: this ADR governs the SmartMode / WebView / MIDI branch only

ADR 0019 opens H5 (BackingTrack + SyncMap) on PdfMode without opening H3/H4, and its decision 4 narrows this ADR rather than overturning it. The reasoning above — Web Audio in a WebView cannot be trusted for background/lock, session and latency, and Web MIDI has gaps — still holds **for the branch it was written about**: SmartMode, notation in a WebView, MIDI realization. That branch remains closed under ADR 0008.

It does **not** govern the PdfMode branch, because that branch has no WebView and no MIDI, and because `flutter_soloud` 4.1.0 added the two primitives this ADR assumed only native code could supply: `getEngineTime()` (mixer clock published at each buffer boundary) and `playScheduled()` (sample-accurate scheduling), plus `createMixingBus()` for per-lane gain and mute. That is the shared clock with independent lanes ADR 0007 describes, reachable from Dart.

So: **PdfMode Transport runs in Dart on SoLoud; SmartMode Transport, if it is ever built, still follows this ADR.** Nothing here is rejected. ADR 0007 is unaffected — it says what the lanes are, this ADR and ADR 0019 only say where they run.

## Considered options

- **Web Audio inside WebView for all platforms** — rejected for production iOS: background/lock, session, latency, Web MIDI gaps.
- **Fully native UI + native audio** — valid but expensive; conflicts with Verovio-first web stack unless we abandon web parity.
- **Native Transport + WebView notation** — proposed: correct clock/audio where the OS is strict; keep Verovio where it is strongest.

## Consequences

- Capacitor (or similar) remains viable for UI shell if native plugins implement Transport.
- Playhead uses JS interpolation from native time anchors; Specs for H3 must include latency compensation.
- Web platform may use Web Audio as the Transport adapter behind the same interface.
- Transport must be designed as a multi-lane mixer from the start (ADR 0007), not a MIDI-only player that later grows a second clock for backing audio.
