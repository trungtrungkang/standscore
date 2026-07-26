# Transport is a multi-lane mixer with a single clock

Transport is not “a MIDI player.” It is a **multi-lane audio/practice engine** under one clock: Click, MidiRealization, and future **BackingTrack** (and optional stems) share musical time via a **SyncMap**. Notation Playhead follows that clock; lanes are independently gain/mute/solo’d.

**Status:** proposed  
**Related:** ADR 0004 (native Transport), ADR 0003 (Verovio Playhead)

## Context

Users will play along with a band-style **BackingTrack** (audio), not only hear MidiRealization. Without designing for this now, H3 MIDI-only Transport becomes a dead-end API and forces a rewrite when backing arrives.

## Decision

1. **One Transport clock** owns play / pause / seek / tempo scaling (where allowed).
2. **Lanes** produce sound under that clock:
   - **ClickLane** — metronome
   - **MidiLane** — MidiRealization (guide / practice reference)
   - **BackingLane** — one or more audio BackingTracks (full mix or stems)
3. **SyncMap** maps musical position (measure/beat or MusicXML time) ↔ audio timeline (seconds + sample). Backing is never “hope BPM matches.”
4. **Mixer** exposes per-lane gain, mute, solo — product UI can be simple later; the seam exists from day one.
5. **PracticePolicy** defines WaitMode behavior when a BackingLane is present (pause all vs pause guide only, etc.) — chosen per Spec, not hard-coded into the clock.
6. BackingTrack **belongs to Score** (optional asset), usable primarily in SmartMode; PdfMode+backing is a later Spec if SyncMap can be established without MusicXML.

## Considered options

- **Separate “audio player” beside MIDI Transport** — rejected: two clocks → Playhead drift and WaitMode chaos.
- **Bake backing into exported MIDI / re-synth only** — rejected: real band recordings are audio; users expect stems/mp3.
- **DAW-in-app (full timeline editor)** — rejected as product scope (VISION non-goal); we need attach + align + mix, not a DAW.
- **Multi-lane Transport + SyncMap** — proposed.

## Consequences

- H3 interface for Transport must include lane slots and SyncMap even if only MidiLane+Click ship first (BackingLane can no-op).
- Native audio graph (AVAudioEngine / equivalent) should assume multiple players/samplers from the start.
- Import UX later: attach audio + alignment (count-in, marker at measure 1, or tempo map).
- WaitMode + live band audio is inherently awkward; default recommendation is WaitMode pauses **all** lanes unless a Spec says otherwise.
- Tempo change with stretched BackingTrack needs explicit policy (disable tempo, or time-stretch — expensive); record as Spec constraint when H-backing lands.

## Interface sketch (conceptual — not an SDK yet)

```text
Transport
  .play() .pause() .seek(musicalTime)
  .setTempoFactor(f)?          // may be disabled when BackingLane active
  .mixer.lane(id).setGain()
  .syncMap                     // authoritative alignment
  .setPracticePolicy(policy)
  → events: timeAnchor, waitingFor(noteId), laneEnded
```
