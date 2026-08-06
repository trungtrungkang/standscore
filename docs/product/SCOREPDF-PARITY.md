# ScorePDF parity checklist (early phase)

**Benchmark:** [ScorePDF](https://enoiu.com/en/app/scorepdf/) (enoiu)  
**Rule:** Early Feature Specs map to rows below. Do not start H3+ until Orchestrator marks Phase P2 (or later) complete enough.

**Post-P2 polish sequencing:** [IMPROVEMENT-ROADMAP.md](./IMPROVEMENT-ROADMAP.md)

Status legend: `todo` | `specced` | `done` | `reopen` | `wont` (explicit cut)

---

## P0 — Open and turn pages

| ID | Capability | Status |
|----|------------|--------|
| P0.1 | Import PDF from device (single + multi) | done (0002) |
| P0.2 | Open Score in PdfMode fullscreen-friendly viewer | done (0002) |
| P0.3 | PageTurn via tap zones (prev / next / L-R / T-B / disable) | done (0003) |
| P0.4 | PageTurn via swipe (per-direction toggle) | done (0003) |
| P0.5 | Basic layouts: single page, two-page spread | done (0004) — 0041 added **Auto** and completed 0004's own "facing pages when width allows": a spread the viewport cannot fit falls back to one page and says so, without touching the stored choice. |
| P0.6 | Fit width / fit height (scroll) | done (0004) — fit width kept as **Scroll**; **fit height `wont`** (0041): its result was whatever the screen's aspect produced, including a page wider than a portrait phone. Stored value still loads, and resolves to Scroll. |
| P0.7 | Zoom pinch; optional pan when zoomed | done (0033) — double-tap zoom cut 2026-07-29: it forced `GestureDetector` to hold every PageTurn tap for `kDoubleTapTimeout` (~300ms) to disambiguate. Pinch is now the only zoom gesture, and the whole view — scale *and* pan — carries across pages instead of resetting per page (e.g. a pan set to compensate for a scan's uneven margins follows to the next page). |
| P0.8 | Library list: titles, open recent | done (0002) |
| P0.9 | Delete Score from Library (confirm; remove file + overlays) | done (0028) |

## P1 — Performance navigation

| ID | Capability | Status |
|----|------------|--------|
| P1.1 | Bluetooth / keyboard pedal (PageUp/Down, arrows, Space, Enter) | done (0005) |
| P1.2 | Gesture map (long-press, edge taps → menu / annotate / …) | done (0015) |
| P1.3 | Page turn delay (anti double-turn); optional pedal-only | done (0006) |
| P1.4 | Page turn animation on/off + speed | done (0007) |
| P1.5 | Reverse page-turn direction | done (0008) |
| P1.6 | PageOrder: reorder, duplicate, delete, blank pages | done (0011) |
| P1.7 | Setlist: group Scores, continuous view, jump by title | done (0012) |
| P1.8 | Bookmarks with custom titles + jump | done (0010) |
| P1.9 | Half-page layouts (T/B, L/R), continuous scroll + forced half-step turn | done (0013, reworked by 0056) |
| P1.10 | Jump links (tap target → page) | done (0016 — list sheet UX revision) |
| P1.11 | Page slider + jump to page number | done (0009) |
| P1.12 | Page turn amount (full 1/1 vs half 1/2), esp. continuous scroll | done (0014) |

## P2 — Annotate, organize, export

| ID | Capability | Status |
|----|------------|--------|
| P2.1 | Drawing: pens, marker/highlighter, eraser, undo/redo | done (0017) |
| P2.2 | Stroke width/color, straight line, eyedropper | done (0018) |
| P2.3 | Symbols/shapes/text stamps + tool settings | done (0019) |
| P2.4 | Hide annotations; export PDF with annotations | done (0020) |
| P2.5 | Labels + filter (Any/All, untagged); reorder labels | done (0021) |
| P2.6 | Search by title (+ bookmark search) | done (0022) |
| P2.7 | Sort: title, created, last viewed | done (0023) |
| P2.8 | Replace PDF (keep or reset overlays) | done (0024) |
| P2.9 | Color filter (sepia / green / invert) | done (0025) |
| P2.10 | Dark mode + theme color | done (0026) |
| P2.11 | Backup / restore (ZIP) | done (0027; 0050 — không đơ UI) |
| P2.12 | Share-in PDF from other apps | done (0029) |
| P2.13 | Metronome (tempo, meter, volume) — PDF-phase ok without SmartMode | done (0030) |
| P2.14 | DPI / page scaling / zoom lock (fixed, per score, per page) | done (0031 — scale+lock; **DPI deferred**) |
| P2.15 | Page borders; status bar / notch options | done (0032) |

---

## Post-parity polish (not ScorePDF rows)

Tracked in [IMPROVEMENT-ROADMAP.md](./IMPROVEMENT-ROADMAP.md). Do not treat as blocking ADR 0008 unless Orchestrator says so.

| ID | Capability | Phase |
|----|------------|-------|
| Q1 | Pinch / PageTurn coexist | A1 — done (0033); double-tap zoom cut and pinch scale made cross-page 2026-07-29 (tap latency fix) |
| Q2 | Performance mode (hide AppBar / PageNav) | B1 — done (0034) |
| Q3 | PdfMode overflow menu grouping | B2 — done (0035) |
| Q4 | Page scale vs pinch / stage preset copy | B3 — done (0036) |
| Q5 | Duplicate Score | C1 |
| Q6 | Annotated export/share discoverability | C2 |
| Q7 | First-run / coach tips | C3 |
| Q8 | Library Score row (rename, thumbnail, recency, filter state) | C4 — done (0040) |
| Q9 | Layout modes: honest names, Auto by screen, per-layout turn gesture | unsequenced — done (0041) |
| Q10 | ScoreMenuQuickBar giữ ba lối tắt theo luật "tay đang trên nhạc cụ" (Bookmarks, Draw, Metronome — Metronome **luôn hiện**, trạng thái nói bằng tint); hình dạng hàng do `QuickBarFit` đo, nhãn chữ chỉ vẽ khi đo thấy vừa; `⋯` ScoreMenu giữ nguyên, mỗi mục có icon riêng. Layout và View chỉ có trong `⋯`. (Tab-strip có nhãn bị đảo lại hai lần — xem Spec 0043 Revision 3) | E1 — done (0043) |
| Q11 | Design token & component theme (thang spacing/radius/elevation; nhất quán màu brand) | E2 — proposed (0044) |
| Q12 | Nội dung tab dạng dim-scrim (Bookmarks / Jump Links / hàng đợi Setlist trên nền Score vẫn thấy được) | E3 — proposed (0045) |
| Q13 | Gọn header Library (header 2 hàng, khớp mật độ thật của ScorePDF) | E4 — proposed (0046) |
| Q14 | Một khuôn settings-sheet dùng chung (hàng icon+tiêu đề+mô tả phụ+control chung) | E5 — proposed (0047) |
| Q15 | PageOrder dạng lưới không gian (thẻ số trang, không phải danh sách tuyến tính) | E6 — proposed (0048) |
| Q16 | Toolbar vẽ gọn (bỏ tint, một hàng icon phẳng) | E7 — proposed (0049) |

---

## Explicitly deferred (after parity)

| Area | Why deferred |
|------|----------------|
| SmartMode / Verovio / MusicXML | ADR 0008 |
| AutoPlay / WaitMode / BackingTrack | Needs Transport; after PdfMode |
| OMR / CorrectionSession | After SmartMode path |
| Pro/ads monetization copy of ScorePDF | Product decision later; not required for parity UX |
| Max page DPI | Cut from 0031; reopen only if sharpness blocks gigs |

---

## How to use with SDO

1. Each Feature Spec references parity IDs (`P0.3`, `P1.6`, …) or polish IDs (`Q2`, …).  
2. G4 acceptance = checklist rows for that Spec → `done`.  
3. Orchestrator may mark `wont` or `reopen` with a one-line reason.
