# 0030 — Metronome (tempo, meter, volume)

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0029 (done); 0031–0033 (done)
- **Parity IDs:** P2.13
- **G3:** accepted (2026-07-26)
- **G3 notes:** Persist **app-wide**. Entry = PdfMode ⋯ → **Metronome…**. Sound = tick + accent; include **mute / visual-only**. Meter includes **Equal** (no strong/weak) plus common signatures (`2/2`, `3/8`, `6/8`, `9/8`, `12/8`, …). Denominator is label/grouping only; tempo stays BPM. GestureMap later out of scope.
- **G4:** pass (2026-07-26)

## Problem

Musicians practice and count off with a metronome while reading PDFs. ScorePDF offers tempo, time signature (accent), and independent volume from PdfMode. StandScore has no click track yet — and ADR 0008 allows a PDF-phase metronome without SmartMode / Transport.

## Outcome

From PdfMode, the user can open a **Metronome**, set **tempo**, **meter** (time signature with accent on beat 1), and **volume**, then start/stop audible clicks (or mute for visual-only). Settings persist app-wide. PageTurn and draw remain usable while the metronome runs.

## In scope

- PdfMode ⋯ → Metronome…
- Tempo: ~40–218 BPM, slider + direct entry
- Meter with accent on beat 1 (**2/2**, **2/4**, **3/4**, **3/8**, **4/4**, **5/4**, **5/8**, **6/4**, **6/8**, **7/4**, **7/8**, **9/8**, **12/8**), or **Equal** (same click every beat)
- Volume control; mute / visual-only
- Start / stop; visual beat indicator (not covering Score center)
- Persist last-used tempo / meter / volume / mute
- Works offline; no SmartMode / MIDI Transport dependency

## Out of scope

- Syncing metronome to SmartMode Playhead / Transport (H3+)
- GestureMap assignment for metronome (later slice)
- Subdivision clicks beyond simple meter accent
- Count-in that auto-starts PageTurn / AutoPlay
- Custom sound packs / tuning pitch

## Domain terms

**PdfMode**, **Score**

## Acceptance criteria

Testable checklist (G4):

- [x] User can open Metronome from PdfMode
- [x] User can set tempo within the allowed range (incl. direct entry)
- [x] User can set meter; accent lands on beat 1 of each bar
- [x] User can adjust metronome volume
- [x] Mute / visual-only: beats advance without sound
- [x] Start/stop produces/stops audible clicks (when not muted)
- [x] Settings survive app restart (app-wide)
- [x] PageTurn / draw still work while the metronome is running

## UX notes

- Compact sheet — not a full settings app
- Beat indicator visible without covering the Score center (e.g. AppBar / edge chip)

## Technical constraints

- Prefer Flutter audio that works in foreground; keep module deep (Metronome engine ≠ PdfMode UI)
- Click algorithm: absolute wall-clock beat schedule; **one** sound per beat (accent *or* tick); low-latency mixer (`flutter_soloud`). Avoid per-beat seek/loop seams and double-layered downbeats.
- iOS: `AVAudioSessionCategory.playback` via `audio_session` so clicks work with the Ring/Silent switch on.
- While running: **wakelock** (no idle dim/lock while practicing); audible clicks from a **looping** sample-timed buffer so sound continues after lock (`UIBackgroundModes: audio`). Visual dots are foreground-only.
- TDD: tempo/meter scheduling math (accent index); prefs round-trip
- Do not start Transport / Verovio work

## Test plan

- Automated: prefs round-trip; accent beat index for common meters
- Manual: start at 60 / 4/4; change tempo live; volume; mute; restart; PageTurn while clicking
