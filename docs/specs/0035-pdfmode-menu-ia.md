# 0035 — PdfMode ⋯ information architecture

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0034 (done — ⋯ is now the only way back to settings while playing); 0009, 0025, 0030, 0031, 0032 (all done — they own the entries being grouped)
- **Parity IDs:** Q3 (roadmap B2)
- **G3:** accepted (2026-07-26)
- **G3 notes:** Recommendations taken as-is. Grouped **bottom sheet** replaces the popup (ScoreMenu); groups **Go to / Marks / View / Playing**; Page order… sits in *Go to*; nothing promoted out of the menu this slice; inline state on Layout / Color filter / Page scale; sheet is a route so 0034 chrome pinning keeps working. **ScoreMenu** added to `CONTEXT.md` (G1).
- **G4:** pass (2026-07-26)

## Problem

The PdfMode ⋯ menu has grown one row per Spec and is now **eleven flat items** in the order they happened to be added:

```text
Bookmarks · Jump Links · Metronome… · Hide annotations · Export PDF with annotations ·
Color filter… · Page scale… · Display… · Layout · Page turn settings · Page order…
```

Nothing tells the musician that Layout, Display…, Color filter… and Page scale… are four doors into "how the page looks", or that Bookmarks and Jump Links are both "get me somewhere else in this Score". Three problems follow:

- **Mid-gig cost.** Finding one row means reading all eleven labels. On a phone the list is a wall of text at the top-right corner, and each row is a small target.
- **No state at a glance.** The menu hides the answers the musician actually wants — which layout is on, whether zoom is locked, whether a colour filter is active. Two of the rows smuggle state into the label (`Page scale (locked)…`, `Color filter (Sepia)…`) precisely because there is nowhere better to put it.
- **0034 raised the stakes.** With Performance mode on, chrome is hidden; reveal → ⋯ is now the *only* route to every setting in PdfMode. The menu went from a convenience to the front door, so its shape matters more than it did when it was drafted.

## Outcome

Opening ⋯ shows a small number of **named groups**, not eleven peers. The musician can find "the layout thing" by picking the group whose name matches what they want to change, and can see the current state of the important settings without opening anything.

Grouping is presentational only: every action that exists today still exists, does the same thing, and is reachable — no capability is added or removed by this Spec.

## Screen geometry (mental model)

```text
today                                  proposed
┌──────────────────────────────┐       ┌──────────────────────────────┐
│ Bookmarks                    │       │  Go to                       │  ← group header
│ Jump Links                   │       │   Bookmarks                  │
│ Metronome…                   │       │   Jump Links                 │
│ Hide annotations             │       │   Page order…                │
│ Export PDF with annotations  │       ├──────────────────────────────┤
│ Color filter…                │       │  Marks                       │
│ Page scale…                  │       │   Hide annotations           │
│ Display…                     │       │   Export PDF with annotations│
│ Layout                       │       ├──────────────────────────────┤
│ Page turn settings           │       │  View            Single page │  ← state visible
│ Page order…                  │       │   Layout                     │
└──────────────────────────────┘       │   Display…                   │
                                       │   Color filter…       Sepia  │
                                       │   Page scale…        Locked  │
                                       ├──────────────────────────────┤
                                       │  Playing                     │
                                       │   Metronome…                 │
                                       │   Page turn settings         │
                                       └──────────────────────────────┘
```

Group names above are a **starting proposal, not locked** — see G3 decision 2.

## In scope

- Group every existing ⋯ entry under a small set of headers; no entry disappears, no new destination is invented
- Show current state next to the entries that have a meaningful one (layout mode, colour filter, zoom lock)
- One presentation for the whole menu — this Spec picks between the Material popup and a bottom sheet (G3 decision 1) rather than shipping both
- Keep the ⋯ button where it is, keep `showChrome` opening it (0015 / 0034), and keep it reachable in one tap after a reveal
- Keep every destination's own sheet unchanged (Display…, Layout, Page turn settings, Metronome… etc. are not redesigned here)
- Update the 0034 first-open snackbar copy only if the reveal → ⋯ wording stops matching

## Out of scope

- Redesigning any destination sheet's contents
- "Stage preset" bundle and Page scale vs pinch copy (**B3 — 0036**)
- Promoting anything into the AppBar as a new icon, or removing the Draw icon
- A search field over settings
- Library screen menus, Setlist menus
- Per-Score menu customisation or reordering by the user
- Onboarding / coach marks for the new grouping (**C3 — 0039**)
- Anything SmartMode / Transport (ADR 0008)

## Domain terms

**PdfMode**, **PerformanceMode**, **Score**, **Bookmark**, **JumpLink**, **PageOrder**, **Stamp**, **GestureMap**

No new term is expected. If the grouped surface becomes a sheet rather than a menu, it needs a name in `CONTEXT.md` at G1 — proposal: **ScoreMenu** (the grouped entry point to everything PdfMode can do to the current Score), *avoid*: overflow menu, kebab menu, settings.

## Decisions locked at G3

| # | Question | Locked |
|---|----------|--------|
| 1 | Popup menu or bottom sheet? | **Bottom sheet** of grouped `ListTile`s, replacing `PopupMenuButton`. Targets are finger-sized, trailing state text fits, and it matches every other settings surface in the app instead of squeezing eleven rows into a phone corner. Accepted cost: one extra tap to dismiss, and `showChrome`-opens-⋯ (0034) now means "opens the sheet". |
| 2 | Group names and membership | **Go to** (Bookmarks, Jump Links, Page order…) · **Marks** (Show/Hide annotations, Export PDF with annotations) · **View** (Layout, Display…, Color filter…, Page scale…) · **Playing** (Metronome…, Page turn settings). Verbs the musician would say out loud, not IA vocabulary; no "Advanced", which would become the junk drawer for whatever the next Spec adds. **Page order…** sits in *Go to* because it changes what "next page" means. |
| 3 | Does anything get promoted out of the menu? | **Nothing this slice** — pure regrouping, so the change stays reversible and the diff honest. Revisit a Bookmarks AppBar icon after the grouping is on device. |
| 6 | Should Draw move into the menu? | **No** (Orchestrator, after the G4 run). Draw is the only mode in PdfMode: its AppBar icon is the switch, the on/off indicator and the way out, none of which a hidden menu entry can be. Under Performance mode it also stays two steps away (reveal, tap) instead of four. The genuine misplacement was the reverse — **Undo / Redo / Delete stamp moved off the AppBar onto the DrawToolbar**, so Draw controls sit on one bar and the AppBar keeps the same shape in and out of Draw. |
| 4 | Show state inline? | **Yes**, trailing state on Layout / Color filter / Page scale. Cheapest half of the value, and it retires the two ad-hoc parentheses already in the code (`Page scale (locked)…`, `Color filter (Sepia)…`). |
| 5 | Does the grouped surface pin the 0034 chrome? | **Yes**, same rule as the popup: chrome stays up while the sheet is open, countdown restarts on close. Free if the sheet is a route — `PerformanceChrome`'s pinned predicate already asks whether the screen's route is still current. |

## Acceptance criteria

Testable checklist (G4):

- [x] Every action available in the ⋯ menu before this Spec is still available after it
- [x] Entries are grouped under headers; no group has more than ~4 entries
- [x] Layout, Color filter and Page scale show their current value without opening them
- [x] Opening the grouped surface, then dismissing it, changes nothing about the Score (page, zoom, scroll)
- [x] With Performance mode on, reveal → ⋯ opens the grouped surface in one tap
- [x] Chrome does not auto-hide while the grouped surface is open, and the countdown restarts when it closes
- [x] A `showChrome` gesture with chrome already visible still opens it (0015 / 0034)
- [x] Each entry lands on exactly the same destination as before
- [x] Works in light and dark themes (0026) and with the status bar hidden (0032)
- [x] Reachable and readable on the smallest supported phone width without clipping labels
- [x] The ScoreMenu can be left without choosing anything — **Done** row plus a cap that keeps a barrier (added after the G4 run, which found the eleven entries filling the screen with no way out)

## UX notes

- A settings sheet is sized by its content with a cap, never pinned to a fraction of the screen. Layout and Page turn both forced `height: 90%`, so six chips opened something the size of a pushed screen — which is what made the ⋯ destinations feel inconsistent, not the choice of surface.
- The ScoreMenu wears the same header as the Layout / Page turn sheets — title plus **Done** — so leaving it never depends on hitting a barrier strip, and the list can use the height
- Group headers are labels, not tappable rows
- Destructive or slow actions keep their current feedback (Export PDF with annotations already shows `Exporting…` and must stay disabled while running)
- The running-metronome indicator stays in the AppBar; the menu entry keeps saying **Metronome (running)…**
- Do not reorder entries *within* a group for aesthetics — keep the order a musician has already learned where it does not fight the grouping

## Technical constraints

- The grouped surface is built from one data structure (group → entries), not eleven hand-placed widgets, so a later Spec adds an entry in one place. This is the whole point of the slice; a copy-pasted second menu would be a regression.
- Entry state (label, trailing value, enabled) is derived from the same prefs the destinations already own — no new persisted state in this Spec.
- If the surface becomes a sheet, it must be a route so `PerformanceChrome`'s pinned predicate keeps working unchanged (0034).
- `_overflowMenuKey.currentState?.showButtonMenu()` is the current programmatic open path from `showChrome`; whatever replaces it must be equally callable from `_onGestureMapAction`.

## Test plan

- Automated: a test that asserts the set of entries in the grouped surface equals the set of actions the screen can dispatch (catches an entry lost in the regroup); trailing-state text for layout / filter / zoom lock; grouped surface pins the chrome and releases it on close
- Manual demo: on device — reveal chrome, ⋯, reach Layout and Color filter without reading every row; confirm state text matches what the Score is doing; phone and tablet, light and dark
