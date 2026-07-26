# 0040 — Library Score row: rename, recognise, filter state

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0002 (done — it deferred rename and this Spec collects the debt); 0021, 0022, 0023, 0024, 0027, 0029 (all done — they own labels, search, sort, replace, backup and share-in)
- **Parity IDs:** Q8 (roadmap C4)
- **Number note:** 0036–0039 are reserved by the accepted roadmap (B3, C1, C2, C3), so this is the next free number, not a gap.
- **G3:** accepted (2026-07-26)
- **G3 notes:** All seven recommendations taken as-is. One thing moved during the build: thumbnails live in the **OS cache directory**, not `<libraryRoot>/thumbs` — see decision 2.
- **G4:** pass (2026-07-26)

## Problem

The Library is the first screen of the app and the one a musician uses before every session, but a Score row tells them almost nothing and lets them change almost nothing.

**A Score cannot be renamed.** Spec 0002 wrote the rule — *"Titles default from file name (strip `.pdf`); rename can wait"* — and nothing has picked it up since. `Score.copyWith({String? title})` exists in the model with no caller. Meanwhile Bookmarks (0010) and Labels (0021) both got rename. The gap became sharper with share-in (0029): a part arriving from a messaging app lands in the Library as `doc_2024-11-03_18-22` and stays that way forever. Replace PDF (0024) does not help — it swaps the file under the existing title.

**A row is not recognisable.** Every Score shows the same generic PDF glyph, so the list is a column of text. Musicians recognise a chart by the look of its first page long before they finish reading a title, and nothing in the row says how long the piece is either.

**The subtitle is a run-on.** The date and the labels are joined with the same separator:

```dart
[ if (score.lastOpenedAt == null) 'Added ${_formatDay(score.createdAt)}'
  else 'Opened ${_formatDay(score.lastOpenedAt!)}',
  if (labelNames.isNotEmpty) labelNames.join(' · '),
].join(' · ')          // → "Opened 2026-07-26 · Jazz · Gig"
```

The reader cannot tell where the date ends and the labels begin, and the date is an ISO day when the default sort is *Last viewed* — the question being asked is "did I play this recently", which `2026-07-26` answers slowly.

**An active filter is invisible.** `_filterActive` only swaps `filter_alt_outlined` for `filter_alt`. Which labels are on, and whether the mode is any or all, is not on screen anywhere — not even in the empty state, which says "No scores match this filter" without naming it. Sort, one icon to the left, shows its current value as text in the AppBar; filter should not be quieter than sort.

## Outcome

A musician opening the Library can name their own Scores, recognise a chart by looking at it, tell at a glance when they last played it and what it is labelled, and see what is currently being filtered out.

## Screen geometry (mental model)

```text
today                                    proposed
┌────────────────────────────────────┐   ┌────────────────────────────────────┐
│ [search…                        ]  │   │ [search…                        ]  │
│                                    │   │ (Jazz ×) (Gig ×)  Clear            │ ← filter visible
├────────────────────────────────────┤   ├────────────────────────────────────┤
│ 📄  Autumn Leaves                  │   │ ┌────┐ Autumn Leaves            ⋯ │
│     Opened 2026-07-26 · Jazz · Gig ⋯│   │ │page│ Opened today · 4 pages     │
│ 📄  doc_2024-11-03_18-22           │   │ │ 1  │ (Jazz) (Gig)               │ ← labels as chips
│     Added 2024-11-03               ⋯│   │ └────┘                           │
└────────────────────────────────────┘   └────────────────────────────────────┘
```

## In scope

- **Rename a Score** from the row's ⋯ menu; title is metadata, the PDF file on disk is untouched
- **Thumbnail** of the Score's first page in place of the generic PDF glyph, cached so scrolling stays smooth
- **Page count** in the subtitle
- **Relative recency** — "today" / "yesterday" / "3 days ago" instead of an ISO day, falling back to a date once relative stops being useful
- **Labels as chips** on their own line, not appended to the date string
- **Active filter shown as chips** under the search field, each removable, with a way to clear all
- The same empty state and "no matches" copy updated to name what is filtering

## Out of scope

- Library AppBar information architecture — the four flat controls (Sort, Filter, Manage Labels, ⋯) and the fact that Library's ⋯ is still a `PopupMenuButton` while PdfMode's is now a ScoreMenu sheet (0035). Real, and deliberately a separate slice.
- Multi-select / batch delete / batch labelling
- Duplicate Score (**C1 — 0037**)
- Search over Setlists, and any change to the Setlists tab beyond the duplicated "New setlist" button if G3 takes it
- Grid / cover-flow view, custom cover images, sort by anything new (0023 owns sort modes)
- Editing Score metadata beyond the title (composer, key, tempo — no such fields exist)
- Onboarding or coach marks (**C3 — 0039**)

## Domain terms

**Score**, **Label**, **Setlist**, **PdfDocument**, **PdfMode**

No new term expected. A thumbnail is a rendering of the Score's first page, not a new entity — if it needs a name in `CONTEXT.md` at G1, that is a signal the slice grew.

## Decisions locked at G3

| # | Question | Locked |
|---|----------|--------|
| 1 | Thumbnails at all this slice, given the cost? | **Yes.** The biggest scan-speed win available, and pdfrx already renders pages. The cost is a cache to invalidate — decision 2. |
| 2 | When is a thumbnail rendered, and where does it live? | **Lazily on first display.** Location changed during the build: the **OS cache directory** (`<appCache>/score-thumbs/`), not the library root. Excluding a subfolder from the backup ZIP would have meant walking the tree by hand instead of `addDirectory`, and derived data belongs in a cache the system may reclaim. Staleness is handled by the key rather than by callers remembering to invalidate: the file is `<scoreId>-<pdf mtime>.png`, so Replace PDF (0024) and Restore (0027) miss the cache by construction. Delete (0028) still evicts explicitly. |
| 3 | Store `pageCount` in the manifest, or count on demand? | **Store it**, written at import, recounted on Replace PDF, and backfilled after the list is on screen for Scores that predate this Spec. Counting on demand means opening every PDF to draw a list. |
| 4 | Rename UI | **Dialog from the row ⋯**, pre-filled. The bookmark prompt was extracted to `promptForTitle` and both now share it, so renaming feels the same everywhere. Blank input keeps the old title — refused in `ScoreLibrary.renameScore` as well as in the screen, so the rule does not depend on the caller. |
| 5 | How far back does relative dating go? | **Today / Yesterday / N days ago up to 6**, then the date. Counted between calendar days, not elapsed hours. |
| 6 | How many label chips fit on a row? | **Two, then `+N`.** |
| 7 | Does the Setlists tab lose its duplicate "New setlist" AppBar icon? | **Yes** — it called the same method as the FAB directly below it. |

## Acceptance criteria

Testable checklist (G4):

- [x] A Score can be renamed from the Library; the new title survives an app restart
- [x] Renaming changes nothing on disk — the PDF opens, annotations, bookmarks and setlist membership are intact
- [x] Renaming a Score re-sorts it correctly under sort-by-title (0023) and is findable by the new title under search (0022)
- [x] A rename dialog left empty leaves the title unchanged
- [x] Each Score row shows a thumbnail of its own first page; a Score whose thumbnail is not ready yet shows a placeholder and never a broken row
- [x] Replace PDF (0024) updates the thumbnail; Delete (0028) leaves no orphan thumbnail behind
- [x] Rows show the page count once known, and a Score imported before this Spec fills it in without a manual step
- [x] "Opened today" / "yesterday" / "N days ago" reads correctly across a local midnight, and older Scores fall back to a date
- [x] Labels appear as chips distinct from the date line, capped with `+N`
- [x] With a label filter on, the active labels are named on screen and each can be removed from there
- [x] The "no matches" state names what is filtering and offers to clear it
- [x] Scrolling a library of ~100 Scores stays smooth (thumbnails do not render on every build)
- [x] Works in light and dark themes (0026); rows do not clip on the smallest supported phone width

## UX notes

- The thumbnail is a recognition aid, not a preview: small, fixed aspect box, cropped to the top of the page where the title and first system live. A full-page fit at this size is unreadable and wastes the row.
- A row now carries four things (thumbnail, title, recency + pages, labels). If it starts feeling like a card, cut label chips to the count instead of growing the row.
- Rename is a rename, not a "details" screen. Resist adding fields; there are none to add.
- Filter chips sit below the search field so the two "what am I not seeing" controls read as one block. They are not a second way to *set* a filter — tapping a chip removes it; adding still goes through the filter sheet (0021).
- Keep the generic-glyph fallback for anything that fails to render, and never block the list on rendering.

## Technical constraints

- `Score.title` is manifest metadata and `Score.copyWith(title:)` already exists; rename must not touch `relativePath` or the file on disk. This is the whole reason the slice is small.
- The row currently recomputes `labelStore.labelsForScore(score.id)` inside `itemBuilder` for every label; adding per-row rendering work on top of that is what would make a large library scroll badly. Precompute per-Score display data once per reload.
- Thumbnail generation must be off the build path — request on first display, cache in memory and on disk, and never render synchronously in `itemBuilder`.
- `_formatDay` is hand-rolled in `library_screen.dart`; the relative formatter belongs beside it as a pure function so it is testable without a widget.
- Backup/Restore (0027) copies the library root wholesale — whatever decision 2 does about thumbnails has to be stated there, not discovered by a user with a 400 MB backup.
- Widget-testing this screen means letting real disk work run: `dart:io` futures do not complete inside a widget test's fake-async zone, so the test alternates `runAsync` windows with `pump`, each round advancing the load by one `await`. Awaiting a file directly in a `testWidgets` body hangs the run instead of failing it.

## Test plan

- Automated: rename round-trip through the store and a restart; rename with empty input; rename then sort-by-title and search; relative date formatter across today / yesterday / 6 days / 7 days and a local-midnight boundary; label chips capped at the `+N` rule; filter chips render one per active label and removing one re-runs the filter; thumbnail cache invalidated by Replace PDF and Delete
- Manual demo: on device — share a PDF in from another app, rename it to something musical, find it by the new name, and recognise it by its thumbnail in a list of a dozen; turn on two labels and see both named above the list
