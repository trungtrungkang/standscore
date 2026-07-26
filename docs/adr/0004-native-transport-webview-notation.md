# Native Transport owns timing and audio on iOS/Android

On iOS and Android, Transport (playback clock, multi-lane audio including MIDI, click, and future BackingTrack) runs in a native audio layer. The WebView owns notation display and Playhead drawing. The bridge carries coarse anchors and control messages — not audio-rate MIDI events. See also ADR 0007 (multi-lane Transport).

**Status:** proposed

## Considered options

- **Web Audio inside WebView for all platforms** — rejected for production iOS: background/lock, session, latency, Web MIDI gaps.
- **Fully native UI + native audio** — valid but expensive; conflicts with Verovio-first web stack unless we abandon web parity.
- **Native Transport + WebView notation** — proposed: correct clock/audio where the OS is strict; keep Verovio where it is strongest.

## Consequences

- Capacitor (or similar) remains viable for UI shell if native plugins implement Transport.
- Playhead uses JS interpolation from native time anchors; Specs for H3 must include latency compensation.
- Web platform may use Web Audio as the Transport adapter behind the same interface.
- Transport must be designed as a multi-lane mixer from the start (ADR 0007), not a MIDI-only player that later grows a second clock for backing audio.
