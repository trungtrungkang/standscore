# StandScore

Domain language for **StandScore**, a BackingScore product (https://backingscore.com).  
Implementation details do not belong here — only terms and meanings.

## Language

### Library

**Score**:
A single piece of sheet music the user stores in the library, backed by a PDF and/or a MusicXML document, and optionally one or more BackingTracks.
_Avoid_: Song, file, track (ambiguous), piece (ok in UI copy only)

**Setlist**:
An ordered group of Scores meant to be viewed or performed in sequence without reopening each Score manually.
_Avoid_: Playlist, album, folder

**Label**:
A user-defined tag applied to Scores or Setlists for filtering.
_Avoid_: Tag (ok as UI synonym), category, genre (too narrow)

### Documents

**PdfDocument**:
The PDF bytes and page images associated with a Score’s performance view.
_Avoid_: PDF score (use Score + PdfDocument)

**MusicXmlDocument**:
The MusicXML source associated with a Score’s Smart Score view.
_Avoid_: XML score, digital score (vague)

**PageOrder**:
The user-defined sequence of PDF pages for performance (including duplicates and blanks) used to handle repeats and jumps without live navigation.
_Avoid_: Page sort, rearrange list

### Viewing

**PdfMode**:
The Score viewing mode that renders PdfDocument with performance-oriented navigation.
_Avoid_: Classic mode, ScorePDF mode

**SmartMode**:
The Score viewing mode that renders MusicXmlDocument (e.g. via Verovio) with playback and practice features.
_Avoid_: MusicXML mode, Verovio mode (engine name ≠ product mode)

**PerformanceMode**:
A PdfMode viewing state in which app chrome is hidden until a GestureMap reveal, leaving only the Score.
_Avoid_: Immersive mode, fullscreen (system-level), presentation mode

**ScoreMenu**:
The grouped entry point to everything PdfMode can do to the Score being viewed, opened from the AppBar ⋯ or a GestureMap reveal.
_Avoid_: Overflow menu, kebab menu, settings (it holds actions as well as settings)

**StagePreset**:
One ScoreMenu entry that sets the app up to play (chrome hidden, status bar hidden, scale kept) or back to practise. An action, not a mode: it writes the same prefs the Display and Page scale sheets write, and its label is read back off those prefs. *Avoid*: stage mode, gig mode, performance mode (that is the 0034 setting it flips).

**LayoutFit**:
What the current viewport can afford a Score: whether a two-page spread fits, how much next-page peek is free, and which layout suits the screen. Computed from viewport and page aspect on every build, never stored.
_Avoid_: Auto layout (that is the user-facing mode that reads this), fit zoom (that is `pdfFitZoom`, the scale), responsive layout

**PageTurn**:
Moving the performance view forward or backward according to layout and gesture rules (including pedal/keyboard equivalents).
_Avoid_: Scroll (only when layout is continuous scroll), swipe (a gesture, not the action)

**TurnAmount**:
How far one PageTurn advances — full page (1/1) or half (1/2). Distinct from Half Page *layout*, which overlays a peek of the next page without using TurnAmount.
_Avoid_: Half page (ambiguous with layout mode), scroll step (implementation)

**GestureMap**:
User assignment of non–PageTurn actions (show chrome, disabled) to long-press and screen-edge taps.
_Avoid_: Shortcut map, hotkeys (keyboard), PageTurn tap zones (prev/next halves)

**Bookmark**:
A named page marker on a Score for quick jump during performance or practice.
_Avoid_: Favorite, pin, TOC entry (PDF outline ≠ user Bookmark)

**JumpLink**:
A visible on-page tap target that navigates to another performance page of the same Score (distinct from Bookmark list jump and from PDF outline links).
_Avoid_: Hyperlink (web), bookmark button, page jump (UI copy ok)

**Stamp**:
A placed symbol, shape, or short text mark on a Score page (distinct from freehand ink strokes).
_Avoid_: Sticker, emoji (too casual), annotation (broader)

**Playhead**:
The visual indicator of the current playback or practice position on the rendered SmartMode score.
_Avoid_: Cursor (ambiguous with text caret), progress bar

### Playback & practice

**Transport**:
The authoritative timing and control engine for playback and practice (play, pause, seek, tempo). It mixes multiple TransportLanes under one clock. Owned by the native audio layer on mobile.
_Avoid_: Player, sequencer (implementation), Web Audio clock

**TransportLane**:
One audible stream controlled by Transport (click, MIDI guide, or backing audio), with its own gain/mute/solo.
_Avoid_: Track (ambiguous), channel (audio engineering jargon in product language)

**BackingTrack**:
An audio recording (full mix or stem) the user plays along with, attached to a Score and aligned through a SyncMap.
_Avoid_: Soundtrack, accompaniment file, band track (UI copy ok), MP3 (format ≠ concept)

**SyncMap**:
The alignment between musical time (measures/beats or MusicXML time) and audio time on BackingTrack(s).
_Avoid_: Offset alone, BPM (too narrow), sync file (may be a serialization of SyncMap)

**AutoPlay**:
Transport-driven playback of armed TransportLanes while advancing the Playhead.
_Avoid_: MIDI play (too low-level alone)

**WaitMode**:
A practice mode where Transport waits for the user to produce the expected note (MIDI or pitch) before advancing, according to a PracticePolicy.
_Avoid_: Follow mode, practice mode (generic), call-and-response

**PracticePolicy**:
Rules for how WaitMode treats TransportLanes (for example pause all lanes vs loop a bar).
_Avoid_: Wait settings (vague)

**MidiRealization**:
The timed MIDI events derived from a MusicXmlDocument for the MidiLane and for practice comparison.
_Avoid_: MIDI file (may be an export artifact), soundtrack

### Capture

**OmrJob**:
A process that turns a photograph or scan of sheet music into a draft MusicXmlDocument.
_Avoid_: Scan (the capture act), OCR (wrong domain), recognition (vague)

**CorrectionSession**:
The human review/edit step that turns OMR draft MusicXML into an accepted MusicXmlDocument.
_Avoid_: Edit mode (too broad), proofreading

### Monetization (optional later)

**ProEntitlement**:
A purchased unlock for gated features; details TBD and must not leak into core domain until decided.
_Avoid_: Subscription (unless that model is chosen)
