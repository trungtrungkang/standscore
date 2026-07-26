# Decisions log (soft)

Informal notes that are **not** ADRs. Use for weekly sequencing, naming ideas, and reversible choices.

| Date | Note |
|------|------|
| 2026-07-22 | Chose Spec-Driven Orchestration (SDO) as process; see ADR 0001. Product docs bootstrapped under `sheet-app/`. |
| 2026-07-22 | Research baseline: ScorePDF feature parity for PdfMode; SmartMode via MusicXML + Verovio; native Transport on iOS. Tech ADRs still `proposed`. |
| 2026-07-22 | Future BackingTrack (play with band) → ADR 0007 multi-lane Transport + SyncMap; design note `TRANSPORT-ARCHITECTURE.md`. Horizons renumbered (backing before OMR). |
| 2026-07-22 | **Early phase = ScorePDF parity first** (ADR 0008 accepted). Checklist `SCOREPDF-PARITY.md`. SmartMode/Transport/OMR deferred until P0–P2 accepted. |
| 2026-07-22 | Provisional product name **StandScore** (lean lock). No obvious iOS/Android sheet-music collision found; nearby concepts: Planning Center “Music Stand”, digitalScore marketing. Confirm domain/trademark before store submit. |
| 2026-07-22 | **Publisher:** BackingScore (backingscore.com). **Bundle ID:** `com.backingscore.scoreapp` (ADR 0009 accepted). |
| 2026-07-22 | Draft logo mark: `docs/brand/standscore-logo.png` (music stand + score). Iterate before store lock. |
| 2026-07-22 | Logo revised to **flat minimal** stand silhouette (no wordmark on icon). Replaced `docs/brand/standscore-logo.png`. |
| 2026-07-22 | Logo simplified further: **score page only** (no music stand). |
| 2026-07-22 | Logo color: warm **teal** on cream (avoid black). |
| 2026-07-22 | Logo: yellowed paper background; tighter crop (less top/bottom padding). |
| 2026-07-22 | Logo: **teal full-bleed background**; only staff + notes in yellow (no paper border). |
| 2026-07-22 | **G0 + G2 locked:** VISION accepted; ADR 0005 Flutter-first accepted. Spec **0001** PDF+annotate spike accepted — next build. |
| 2026-07-23 | Spike **0001 go**. H1 open. Spec **0002** library import/open drafted (`proposed`). |
| 2026-07-23 | Spec **0002** accepted (G3). Library + import + PdfMode open implemented — awaiting G4. |
| 2026-07-23 | Spec **0002 G4 pass**. Spec **0003** PageTurn tap/swipe drafted (`proposed`). |
| 2026-07-23 | Spec **0003** accepted (G3). PageTurn tap/swipe implemented — awaiting G4. |
| 2026-07-23 | Spec **0003 G4 pass**. Spec **0004** page layouts drafted (`proposed`). |
| 2026-07-23 | Spec **0004** accepted (G3). Layout modes implemented — awaiting G4. |
| 2026-07-23 | Spec **0004 G4 pass**. **P0 complete.** Spec **0005** pedal/keyboard drafted (`proposed`). |
| 2026-07-23 | Spec **0005** accepted (G3). Pedal/keyboard PageTurn implemented — awaiting G4. |
| 2026-07-24 | Spec **0004** amendment: **Single page** = horizontal one-page slider (ScorePDF), not vertical continuous. Fit width/height remain scroll modes. |
| 2026-07-25 | Orchestrator verified Single-page slider OK. Spec **0006** (page turn delay / P1.3) drafted `proposed`. Spec **0005** still needs G4. |
| 2026-07-26 | Spec **0006** accepted (G3). Default delay Off. Build anti-double-turn lockout. |
| 2026-07-26 | Spec **0006 G4 pass**. P1.3 done. Spec **0007** (page-turn animation / P1.4) drafted `proposed`. |
| 2026-07-26 | Spec **0007** accepted (G3). Animation presets Off/Fast/Normal/Slow; default Normal. |
| 2026-07-26 | Spec **0007 G4 pass**. P1.4 done. Spec **0008** (reverse PageTurn / P1.5) drafted `proposed`. |
| 2026-07-26 | Spec **0008** accepted (G3). Reverse flips slide + horizontal gestures; pedal keys stay document-order. |
| 2026-07-26 | Spec **0008 G4 pass**. P1.5 done. Spec **0009** (page slider + jump / P1.11) drafted `proposed`. |
| 2026-07-26 | Spec **0009** accepted (G3). Bottom page chrome; scrub + jump; draw mode keeps nav; jump skips delay. |
| 2026-07-26 | Spec **0009 G4 pass**. P1.11 done. Spec **0010** (bookmarks / P1.8) drafted `proposed`. |
| 2026-07-26 | Spec **0010** accepted (G3). Bookmark in CONTEXT; per-Score JSON; out-of-range jump clamps. |
| 2026-07-26 | Spec **0010 G4 pass** (after TextEditingController dispose fix). P1.8 done. Spec **0011** (PageOrder / P1.6) drafted `proposed`. |
| 2026-07-26 | Spec **0011** UX: entry via PdfMode **⋯** menu; include **Reset to original**. Still `proposed` until G3 Accept. |
| 2026-07-26 | Spec **0011** accepted (G3). PageOrder editor + PdfMode mapping; custom continuous when non-identity. |
| 2026-07-26 | Spec **0011 G4 pass**. PdfMode app bar: keep Draw (+ Undo while drawing); rest in ⋯ menu. |
| 2026-07-26 | Spec **0005 G4 pass** (confirmed). P1.1 done. Red-screen on device open was dual `xcode`+`flutter run`, not app logic. |
| 2026-07-26 | Spec **0012** (Setlist / P1.7) drafted `proposed`. Remaining P1: gesture map, half-page, jump links. |
| 2026-07-26 | Spec **0012** accepted (G3). Segmented Scores/Setlists; skip missing Scores on open + snackbar. |
| 2026-07-26 | Spec **0012** built: Setlist model/store/nav, library tab, editor, PdfMode boundary PageTurn + title jump. Awaiting G4. |
| 2026-07-26 | Spec **0012 G4 pass**. P1.7 done. Spec **0013** (half-page layouts / P1.9) drafted `proposed`. |
| 2026-07-26 | Spec **0013** accepted (G3). Setlist last-page peek = next Score title; separator Fixed app-wide. |
| 2026-07-26 | Spec **0013** built: HalfPageView + layout prefs ratio; Setlist peek title. Awaiting G4. |
| 2026-07-26 | Clarified ScorePDF: **Half Page layout** (P1.9/0013) ≠ **Turn Amount 1/2** (continuous half-step). Orchestrator wants both. Spec **0014** (P1.12) drafted `proposed`. |
| 2026-07-26 | Spec **0014** accepted (G3) + built: Turn amount Full/Half in PageTurn settings; Fit width/height half = ½ viewport scroll. Awaiting G4. |
| 2026-07-26 | Spec **0014 G4 pass**. P1.12 done. Spec **0015** (gesture map / P1.2) drafted `proposed`. Spec **0013** still G4 pending. |
| 2026-07-26 | Spec **0015** accepted (G3): keep always-visible chrome (no immersive). Show menu opens ⋯. Built — awaiting G4. |
| 2026-07-26 | Spec **0015 G4 pass** (Page turn settings Done button). P1.2 done. Spec **0016** (jump links / P1.10) drafted `proposed`. Spec **0013** still G4 pending. |
| 2026-07-26 | Spec **0016** accepted (G3): JumpLink on-page → PageOrder page; distinct from Bookmark. Building. |
| 2026-07-26 | Spec **0016** built: JumpLink store/overlay; ⋯ Add jump link; tap jump / long-press edit. Awaiting G4. |
| 2026-07-26 | JumpLink: drag button to reposition (avoid covering notes); position persists. |
| 2026-07-26 | Spec **0016 G4 pass**. P1.10 done. Spec **0013** Half Page layout still G4 pending (last open P1 item). |
| 2026-07-26 | Spec **0013 G4 pass**. P1.9 done. **P1 complete.** Spec **0017** (draw tools / P2.1) drafted `proposed`. |
| 2026-07-26 | Spec **0017** accepted (G3): stroke-level eraser; fixed pen/marker presets; persist per Score. Building. |
| 2026-07-26 | Spec **0017** built: Pen/Marker/Eraser toolbar; undo/redo; per-Score annotation JSON. Awaiting G4. |
| 2026-07-26 | Spec **0017 G4 pass** (draw scroll lock). P2.1 done. Spec **0018** (stroke style / P2.2) drafted `proposed`. |
| 2026-07-26 | Spec **0018** accepted (G3): eyedropper = sample ink; palette + widths; straight-line chip. Building. |
| 2026-07-26 | Spec **0018** built: color/width toolbar, Line chip, Dropper (ink sample). Awaiting G4. |
| 2026-07-26 | Draw toolbar compact: icon tools + color dots + S/M/L segmented (fix Wrap chip wall). |
| 2026-07-26 | Draw chrome: one row — color + tool + ⋯; full options in bottom sheet. |
| 2026-07-26 | Spec **0018 G4 pass**. P2.2 done. Spec **0019** (symbols/stamps / P2.3) drafted `proposed`. |
| 2026-07-26 | Spec **0019** accepted (G3): stamp catalog p/f/♯/♭/♮/box/circle/arrow/text; tap place; select delete/move. Building. |
| 2026-07-26 | Stamp size: 0019 keeps pen Width→new stamp only; dedicated size UI + resize selected deferred to later slice. |
| 2026-07-26 | Spec **0019 G4 pass**. P2.3 done. Spec **0020** (hide/export annotations / P2.4) drafted `proposed`. |
| 2026-07-26 | Spec **0020** accepted (G3): hide ink+stamps (session); export flattened PDF via share; source page order; no JumpLinks in export. Building. |
| 2026-07-26 | Spec **0020 G4 pass**. P2.4 done. Spec **0021** (labels/filter / P2.5) drafted `proposed`. |
| 2026-07-26 | Spec **0021** accepted (G3): Labels on Scores only; confirm delete; Any/All/Untagged; no colors. Building. |
| 2026-07-26 | Spec **0021 G4 pass** (Label dialog dispose fix). P2.5 done. Spec **0022** (search / P2.6) drafted `proposed`. |
| 2026-07-26 | Spec **0022** accepted (G3): live title OR Bookmark search; Label filter then search; Scores only. Building. |
| 2026-07-26 | Spec **0022 G4 pass**. P2.6 done. Spec **0023** (library sort / P2.7) drafted `proposed`. |
| 2026-07-26 | Spec **0023** accepted (G3): title A–Z; created/last-viewed newest-first; never-opened last; persist. Building. |
| 2026-07-26 | Brand: applied `standscore-logo.png` to Library app bar, launcher icons (iOS/Android), and native splash (#0D8B86). Still draft before store lock. |
| 2026-07-26 | Spec **0023 G4 pass**. P2.7 done. Spec **0024** (replace PDF / P2.8) drafted `proposed`. |
| 2026-07-26 | Spec **0024** accepted (G3): Library replace PDF; keep/reset annotations+bookmarks+jumplinks+page order; Labels/Setlists kept. Building. |
| 2026-07-26 | Spec **0024 G4 pass**. P2.8 done. Spec **0025** (color filter / P2.9) drafted `proposed`. |
| 2026-07-26 | Spec **0025** accepted (G3): Off/Sepia/Green/Invert; app-level persist; PdfMode ⋯; ColorFiltered. Building. |
| 2026-07-26 | Spec **0025 G4 pass**. P2.9 done. Spec **0026** (dark mode + theme color / P2.10) drafted `proposed`. |
| 2026-07-26 | Spec **0026** accepted (G3): Light/Dark/System; brand teal + presets + custom; Library ⋯ Appearance; no match-gutter. Building. |
| 2026-07-26 | Spec **0026 G4 pass**. P2.10 done. Spec **0027** (backup/restore ZIP / P2.11) drafted `proposed`. |
| 2026-07-26 | Spec **0027** accepted (G3): full `standscore/` tree + prefs; full-replace restore; `standscore-backup.json` marker; Library ⋯. Building. |
| 2026-07-26 | Gap: Library has no Delete Score (Setlist delete exists). Spec **0028** (P0.9) drafted `proposed`; queue after 0027 G4. |
| 2026-07-26 | Spec **0028** accepted (G3): Library Score ⋯ Delete; hard-delete PDF+overlays+Labels; strip from Setlists (keep empty); Library-only. Building. |
| 2026-07-26 | Spec **0028 G4 pass**. P0.9 done. Spec **0027** still G4 pending. |
| 2026-07-26 | Spec **0027 G4 pass**. P2.11 done. Spec **0029** (share-in PDF / P2.12) drafted `proposed`. |
| 2026-07-26 | Spec **0029** accepted (G3): Library+snackbar; iOS+Android; multi-file; `share_handler`; no auto-open. Building. |
| 2026-07-26 | Spec **0029 G4 pass** (ShareExtension CFBundleVersion fix). P2.12 done. Spec **0030** (metronome / P2.13) drafted `proposed`. |
| 2026-07-26 | Spec **0030 deferred** (finish P2.14–P2.15 first). Spec **0031** (zoom lock / page scale / P2.14) drafted `proposed`. |
| 2026-07-26 | Spec **0031** accepted (G3): scale+lock only (no DPI); lock disables pinch; PdfMode ⋯ Page scale…; Fixed/PerScore/PerPage. Building. |
| 2026-07-26 | Spec **0031 G4 pass**. P2.14 done (scale+lock; DPI deferred). Spec **0032** (page borders / status bar / notch / P2.15) drafted `proposed`. |
| 2026-07-26 | Spec **0032** accepted (G3): Display… sheet; border off by default; separator shares style; status bar hidden; avoid notches on; app-wide. Building. |
| 2026-07-26 | Spec **0032 G4 pass**. P2.15 done. Spec **0030** metronome re-opened `proposed` (last open P2 row). |
| 2026-07-26 | Spec **0032 G4 reopened**: page border invisible (drawn under PdfPageView image). Overlay border fix; G4 pending again. |
| 2026-07-26 | Spec **0032 G4 pass** (border overlay). P2.15 done. Spec **0030** metronome awaiting G3. |
| 2026-07-26 | Jump Links UX (0016 revision, Orchestrator pass): PdfMode ⋯ → **Jump Links** list sheet (like Bookmarks); Add/Edit in-sheet (no stacked modal); long-press on-page edit kept. Spec 0016 updated. |
| 2026-07-26 | Quality review → [IMPROVEMENT-ROADMAP.md](./IMPROVEMENT-ROADMAP.md) drafted. P0.7 marked **reopen** (pinch/PageTurn). Polish Q1–Q7 appendix. Recommend A1 (0033) then A2 (0030). |
| 2026-07-26 | Improvement roadmap **accepted**. Sequence A1→A2→B→C→D. Spec **0033** (P0.7 reopen) drafted `proposed`; **0030** waits for 0033. |
| 2026-07-26 | Spec **0033** accepted (G3): multi-touch IgnorePointer pass-through; double-tap fit↔2×; PageTurn single-finger. Building. |
| 2026-07-26 | Spec **0033 G4 pass**. P0.7 / Q1 done. Spec **0030** metronome awaiting G3 (roadmap A2). |
| 2026-07-26 | Spec **0030** accepted (G3): app-wide persist; ⋯ Metronome…; tick+accent; mute/visual-only. Building. |
| 2026-07-26 | Spec **0030 G4 pass**. P2.13 done. Phase A complete. Next: Phase B — Spec **0034** Performance mode (then 0035 menu IA). |
| 2026-07-26 | Spec **0034** accepted (G3): reopens 0015 “chrome always visible”; Display… toggle, app-wide, default off; `showChrome` reveals then opens ⋯; auto-hide 5 s fixed; overlay chrome over constant-size viewer; no page indicator while hidden (B3). **PerformanceMode** added to CONTEXT (G1). Building. |
| 2026-07-26 | Spec **0034** default flipped to Performance mode **on** (Orchestrator) — including installs whose prefs predate the key. Build fix: PageNavBar stretched full-screen in `Scaffold.bottomNavigationBar` (Slider fills bounded height); slider height pinned + layout regression tests. |
| 2026-07-26 | Spec **0034** first-open rule (Orchestrator): first Score on an install opens with chrome up + reveal-gesture snackbar (one-shot `performanceHintShown`), then Scores open hidden. Full onboarding still C3 / 0039. |
| 2026-07-26 | Score surface unified for 0034: gutters / margins / safe-area bands use `pdfSurfaceColor` = `surfaceContainerLowest` (paper white in light, dark in dark) instead of `surfaceContainerHighest`. Page edges now rely on the 0032 page border, not a grey gutter. |
| 2026-07-26 | Color filter (0025) now tints the Score surround too: `applyPageColorFilter(Color, mode)` applies the same matrix to gutter / bands / blank pages, which sit outside the `PageColorFiltered` subtree. |
| 2026-07-26 | Spec **0034** chrome moved out of the Scaffold `appBar` / `bottomNavigationBar` slots into a `Stack`: those slots inflate the body's `MediaQuery.padding` by the chrome height, so the viewer's `SafeArea` was clearing an invisible AppBar (103 px, not the 47 px notch). Viewer now also drops the bottom inset while hidden, so the bottom-right PageTurn tap zone reaches the screen edge. |
| 2026-07-26 | GestureMap **bottom edge default → Off** (was Draw, 0015): stray bottom-edge taps entering Draw confused users, worse now the PageNavBar hides there. Superseded same day: **Draw removed from GestureMap altogether** (Orchestrator) — bad UX in and out of Performance mode, so `GestureMapAction` is now Show menu / Off only and Draw is entered from the toolbar. Saved `enterDraw` reads back as Off, so no migration step is needed. |
| 2026-07-26 | PdfMode chrome heights (Orchestrator): AppBar **64 px** (was 56), PageNavBar **48 px** (was 64). The footer holds one scrubber; the header holds the title and every action. |
| 2026-07-26 | Spec **0034 G4 pass** (device run: first-open hint, reveal / auto-hide / pin, pedal with chrome hidden, Draw, zoom + Half Page + Jump Links, 0032 prefs, restart). Q2 / B1 done. Phase B continues with **0035** (⋯ menu IA) then **0036** (stage preset + Page scale copy). |
| 2026-07-26 | Spec **0035** drafted (B2 / Q3), awaiting G3: group the eleven flat ⋯ entries, show layout / filter / zoom-lock state inline. Five G3 questions, the load-bearing one being popup-with-headers vs bottom sheet. `CONTEXT.md` GestureMap definition corrected — it still listed “enter draw”. |
| 2026-07-26 | Spec **0035** accepted (G3) with the drafted recommendations: bottom-sheet **ScoreMenu** replaces the ⋯ popup; groups Go to / Marks / View / Playing; Page order… under *Go to*; inline state on Layout / Color filter / Page scale; nothing promoted to the AppBar this slice. **ScoreMenu** added to CONTEXT (G1). Built; awaiting G4 on device. |
| 2026-07-26 | Settings sheets size to content (0035 follow-up): Layout and Page turn were `SizedBox(height: 90% of screen)`, so Layout's six chips opened a near-full-screen panel that read as a pushed route. Now `ConstrainedBox(maxHeight: 90%)` + `shrinkWrap`; Layout drops from 588 px to 349 px on an 800×600 surface. List sheets (Bookmarks, Jump Links) keep fixed heights on purpose — they must not jump as rows are added or deleted. |
| 2026-07-26 | Post-G4 fix on **0035**: the ScoreMenu's eleven entries filled the phone screen, so no barrier was left to tap and the only way out was choosing an entry. Fixed by giving it the Layout / Page turn header — title + **Done** — with a 90% cap, so the list keeps the height and the exit does not depend on a barrier strip (Orchestrator's call). Test covers leaving via Done. |
| 2026-07-26 | Draw stays on the AppBar, not in the ScoreMenu (Orchestrator): it is a mode, so the icon must double as indicator and exit. **Undo / Redo / Delete stamp moved from the AppBar into the DrawToolbar** instead — they were Draw-only actions one divider away from the bar holding every other Draw control, and the AppBar no longer changes shape on entering Draw. |
| 2026-07-26 | DrawToolbar gains a **Size** button showing the active width as a dot at that width, with a three-step picker anchored like the Tool button (0018 widths were only reachable through More…). Pen and marker keep their own width, as they always have. |
| 2026-07-26 | Spec **0035 G4 pass**. Q3 / B2 done. Phase B has one slice left: **0036** (B3 — stage preset + Page scale vs pinch copy), which also owns the page-indicator question 0034 deferred. |
| 2026-07-26 | Library UI/UX review (Orchestrator asked). Findings, worst first: **a Score cannot be renamed** — Spec 0002 wrote "rename can wait" and nothing collected it, so share-in (0029) PDFs keep names like `doc_2024-11-03_18-22` while Bookmarks and Labels both got rename; rows carry a generic glyph and no page count; date and labels are joined with the same `·` into one run-on; an active label filter shows only as a filled icon while sort next to it prints its value. Noted but **cut from the slice**: the Scores AppBar carries four flat controls, Library's ⋯ is still a popup while PdfMode's is now a ScoreMenu sheet (0035), no multi-select, Setlists has no search. Spec **0040** drafted `proposed` (roadmap C4 / parity Q8), recommended to run before C1 duplicate Score. Numbering: 0036–0039 are reserved by the accepted roadmap, so 0040 is the next free number. |
| 2026-07-26 | Spec **0040** accepted (G3) with all seven recommendations, and built. Rename lives on `ScoreLibrary.renameScore` (metadata only — the PDF keeps its path, so annotations / Bookmarks / Setlists are untouched) and the bookmark rename dialog was extracted to `promptForTitle` so both share one. `Score.pageCount` is written at import, recounted on Replace PDF, and backfilled after the list is drawn. Rows now carry a first-page thumbnail, "Opened today · 4 pages", and label chips capped at `+N`; the active filter is spelled out in removable chips under the search field. Setlists lost its duplicate AppBar "New setlist". |
| 2026-07-26 | 0040 build deviation from the G3 note: thumbnails cache in the **OS cache directory**, not `<libraryRoot>/thumbs`. Excluding a subfolder from the backup ZIP (0027) would mean walking the tree instead of `addDirectory`, and derived data belongs somewhere the system can reclaim. Cache file is `<scoreId>-<pdf mtime>.png`, so Replace PDF (0024) and Restore both miss by construction rather than needing an invalidation call. |
| 2026-07-26 | Widget-testing LibraryScreen: `dart:io` futures never complete inside a `testWidgets` fake-async zone, so awaiting a file there **hangs** the run rather than failing it — the first attempt sat for minutes with no output and no timeout. The test now alternates `runAsync` windows with `pump` (each round advances the screen's load by one `await`) and wraps every fixture write. Worth remembering: this is the first widget test in the repo that drives a file-backed screen. |
| 2026-07-26 | Spec **0040 G4 pass**. Q8 / C4 done. Phase C has three slices left: **C1 — 0037** (duplicate Score), **C2 — 0038** (annotated export/share discoverability), **C3 — 0039** (first-run tips). Phase B still owes **B3 — 0036** (stage preset + Page scale vs pinch copy, and the page indicator 0034 deferred). |
| 2026-07-26 | Spec **0036** drafted (B3 / Q4), awaiting G3 — the last Phase B slice. Bundles three loose ends that are all the same complaint: a **preset** for getting into and out of playing shape, rewritten **Page scale** copy (scope, and what pinch does to a kept scale), and the **transient page indicator** 0034 deferred. Eight G3 questions; the load-bearing ones are preset-as-action-with-Undo vs preset-as-mode, and two presets (play / practise) rather than one, since 0034's defaults already made the app stage-shaped and what is missing is the way back. |
| 2026-07-26 | Spec **0036** accepted (G3) with one revision to the draft: the stage preset is **one ScoreMenu entry whose label flips with the current state**, sitting in **Playing**, rather than two sibling entries in View. Two entries would have pushed View past 0035's four-entry ceiling and ignored the Show/Hide annotations idiom already in the menu; "get ready to play" is also a Playing verb. Still an action with Undo, not a mode — no second source of truth over the five switches it sets. Zoom lock stays in the bundle, flagged as the first thing to cut if device testing dislikes it. Building. |
| 2026-07-26 | Spec **0036** built. **StagePreset** added to CONTEXT (G1): one Playing entry, label derived from the prefs, Undo snackbar naming what moved ("chrome hidden · status bar hidden · scale kept") and staying silent when the preset was a no-op. **PagePositionPill** shows "12 / 56" for 1.5 s on a page change while chrome is hidden — its own timer, never touching `PerformanceChrome`'s countdown, and wrapped in `IgnorePointer` so the bottom-right PageTurn zone still takes the tap (test taps *through* it rather than asserting the widget flag). Page scale sheet rewritten: "Applies to" with a per-scope sentence, lock relabelled **Keep this scale** with the mechanism demoted to the subtitle. 215 tests green. Awaiting G4 on device. |
| 2026-07-26 | Device fix on **0036**: the Undo snackbar never went away. `SnackBar.persist` defaults to `action != null` in Flutter 3.44, so *any* actionable snackbar stays until something replaces it — on a stand that means a bar parked over the Score and over the bottom PageTurn zone 0034 kept live. Extracted `undoSnackBar()` with `persist: false` (4 s, Undo still tappable) and a `hideCurrentSnackBar()` before showing so two presets in a row do not queue. Bisected with a throwaway harness: the action, not the preset's Scaffold reshuffle, was the whole cause. |
| 2026-07-26 | Three device findings from the 0036 run, all older than 0036. (1) **Scrubber drag lost to the OS**: 0034 shortened the PageNavBar to 48 px with no padding, leaving it flush on the home-indicator inset, and a horizontal drag there switches apps. The 8 px it used to have is now the explicit `kPageNavBarGestureGap`. (2) **Landscape switched off swipe PageTurn**: `_atFitZoom` (0033) compared the zoom against pdfrx's `minScale`, which is the scale that fits one whole page — in landscape that is a third of the fit-width zoom the viewer opens at, so an untouched Score read as zoomed in and swipes went to pan instead. (3) **Two pages cut the bottom off in landscape**: pdfrx fits document *width*, and a spread is then taller than a phone on its side. Both zoom bugs now go through one pure `pdfFitZoom(mode, viewSize, documentSize, spreadHeight)`, used for the reading check, for the viewer's initial zoom, and to re-fit after rotation when the musician had not pinched. |
