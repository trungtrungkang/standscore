# Transport & Backing architecture (design note)

Companion to [ADR 0007](../adr/0007-multi-lane-transport-backing.md).  
Explains how PdfMode, SmartMode, MIDI, and BackingTrack share one timing model. Not a Feature Spec.

---

## Goal

User plays their part while hearing a **band BackingTrack**, with optional MIDI guide and Playhead — without drift between ears and eyes.

---

## Core idea

```text
                    ┌─────────────────────────────┐
                    │     Transport (native)      │
                    │  Clock + SyncMap + Mixer   │
                    └──────────────┬──────────────┘
           ┌───────────────┬───────┴───────┬──────────────┐
           ▼               ▼               ▼              ▼
      ClickLane       MidiLane      BackingLane(s)   (future…)
      metronome     MusicXML→MIDI    mp3/wav/stems
           │               │               │
           └───────────────┴───────┬───────┘
                                   ▼
                            mixed audio out
                                   │
                     timeAnchor (coarse, via bridge)
                                   ▼
                          WebView Playhead
                          (SmartMode / Verovio)
```

**Rule:** Audio threads never call the WebView. WebView never owns the clock.

---

## Domain objects

| Object | Role |
|--------|------|
| **Score** | May include PdfDocument, MusicXmlDocument, BackingTrack(s) |
| **BackingTrack** | Audio asset + metadata (duration, sample rate) |
| **SyncMap** | Musical timeline ↔ audio seconds (and optional markers) |
| **TransportLane** | One audible stream under Transport (click / midi / backing) |
| **PracticePolicy** | How WaitMode treats lanes |

---

## SyncMap (the hard seam)

Backing audio does not magically follow MusicXML. Alignment must be explicit:

| Strategy | When | Notes |
|----------|------|-------|
| **Marker align** | User sets “audio t=12.4s = measure 1 beat 1” | Best v1 UX |
| **Identical tempo map** | Backing produced from same MusicXML/export | Ideal if we generate both |
| **Beat grid / click track embedded** | Pro stems | Detect or ship sidecar `.sync.json` |
| **Constant BPM + offset** | Simple pop charts | Fragile for rubato |

Seek must convert: `seek(measure 17)` → set all lanes to `SyncMap.toAudioTime(m17)` and `MidiLane` to the same musical time.

---

## Modes vs backing

| Mode | Backing useful? | Playhead |
|------|-----------------|----------|
| **SmartMode** | Yes — primary | From Transport clock via SyncMap |
| **PdfMode** | Later optional | No MusicXML playhead; optional floating time UI or page cues only |

Do not block H1–H2 PDF work on backing. Do **not** invent a second audio player for PDF “just for now.”

---

## PracticePolicy (WaitMode × band)

Playing “with a band” and “wait until I play the note” conflict if the band keeps going.

Recommended defaults (override per Spec):

| Policy | Behavior | Use |
|--------|----------|-----|
| **PauseAll** | Wait freezes every lane | Safe default for WaitMode |
| **PauseGuide** | Mute/pause MidiLane; Backing continues | Rare — user falls behind band |
| **LoopBar** | On wait, loop current bar of all lanes | Practice riffs with band feel |
| **CountInOnly** | Backing starts after N bars; WaitMode before entry | Stage entry practice |

“Play with band” product moment ≈ **AutoPlay + BackingLane up + MidiLane guide optional/muted + user hears themselves acoustically**.

---

## Tempo

- MidiLane + ClickLane: tempo factor is easy.  
- BackingLane: changing tempo requires **time-stretch** (CPU/quality cost) or **reject tempo change** while backing is armed.

**v1 recommendation:** If any BackingLane is armed, Transport tempo is locked to SyncMap; user practices at recorded band tempo (or we offer offline stretch as a later Spec).

---

## Stems (future)

Model BackingLane as **N stems** under one SyncMap (drums, bass, other, minus-one):

- Same clock, per-stem gain/mute  
- Still one SyncMap — stems are not independent timelines  

---

## What to build in H3 (even before backing ships)

Transport API / native graph should already have:

1. Clock + timeAnchor events  
2. MidiLane + ClickLane  
3. Empty BackingLane interface (attach / gain / seek via SyncMap)  
4. Mixer mute/solo hooks  

So H-backing becomes “fill the lane + SyncMap UI,” not “redesign playback.”

---

## Open questions for Human (later G2/G3)

1. Stem support in v1 backing or single stereo file only?  
2. Tempo lock vs time-stretch when backing is present?  
3. Is PdfMode+backing in scope within first year?  
4. Sidecar sync format (custom JSON) vs markers only in-app?
