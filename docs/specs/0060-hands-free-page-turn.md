# 0060 — Lật trang rảnh tay tinh (MeasureMap + SyncMap)

- **Status:** hold
- **Type:** feature
- **Horizon:** H5 (ADR 0019 quyết định 1 — chỉ cần biết *chỗ nào trên trang, ở giây thứ mấy*; không cần biết *nốt nào*)
- **Owner (human):** Orchestrator
- **Depends on ADRs:** **0019** (`accepted` — bảng Trình tự; quyết định 3 / 3b), 0005, 0007, 0008, 0013, 0014, 0015, 0016
- **Depends on Specs:** **0059** (`done`), **0061** (FormMap — SyncMap bung theo form; **chặn cảm nhận** trước khi lật tinh đáng tin), **0058**, **0014**, **0006** / **0007** / **0008**, **0004** / **0056**
- **Tier:** **M**
- **G3:** chưa mở lại — Orchestrator **skip tạm** (2026-08-07) để ưu tiên **0061** (lặp / nhảy / coda)
- **Security Review:** không cần

> **Hold.** Draft G3 đã viết; không build. Slice đứng **sau** FormMap (0061): lật tinh trên SyncMap tuyến tính sẽ sai ngay khi bài có volta / D.C. / coda.

---

## Vấn đề (Problem)

Với 0059, nhạc công Play một bài đã map thì playhead chạy đúng, nhưng viewport chỉ **đuổi theo trang tuyệt đối** khi `pageNumber` của playhead đổi — nhảy muộn (đã sang trang mới mới kéo), **không** đọc TurnAmount, và trên layout scroll **không** theo playhead xuống hệ dưới cùng một trang. Trên sân khấu, người ta cần trang / nửa trang kế **đã sẵn** trong lúc còn đang chơi phách cuối của hệ cuối — đúng câu ADR: *“lật vào đúng phách có dấu lặng ở cuối dòng cuối”*, không phải *“hết trang thì lật”*.

App **không** có dữ liệu nốt / dấu lặng từ PDF (H5 đóng OMR). “Phách nghỉ” phải là **proxy thời gian + hình học** từ MeasureMap + SyncMap, không phải nhận dạng ảnh.

---

## Kết quả (Outcome)

Nhạc công map bài → Play: trong lúc đang chơi, app **tự đưa nội dung kế vào tầm nhìn** đủ sớm để đọc được khi còn trên cửa sổ lật (phách cuối của MeasureBox cuối trên SystemBox cuối của trang / bước sắp rời), tôn trọng **TurnAmount** trên layout liên tục, và vẫn cho phép PageTurn tay / pedal xen giữa. Pause đóng băng; Stop về hành vi 0059 (trang đầu map khi Play lại). Không BackingTrack, không Transport, không phát hiện rest từ ảnh trang.

---

## Trong phạm vi (In scope)

### A. Thuật toán lật tinh (thay / nâng bước nhảy trang thô của 0059 lúc Play)

- Trong lúc **Play** (sau count-in; playhead đang chạy): navigation theo SyncMap × MeasureMap, không chỉ `if (pageChanged) jump`.
- **Cửa sổ lật (turn opportunity)** — khuyến nghị G3 câu 1–2: thời điểm playhead vào **phách cuối** của **MeasureBox cuối** trên **SystemBox cuối** thuộc trang / bước sắp rời khỏi viewport (xác định bằng `systemIndex` + thứ tự ô trên trang + PageOrder). Look-ahead: lên lịch lật **đầu** phách đó (hoặc sớm một lượng nhỏ cố định — G3), để trang kế đọc được trong lúc nhạc công còn trên phách nghỉ / phách cuối.
- **Proxy “dấu lặng”:** không OMR, không bắt buộc nhạc công gắn cờ. Proxy = cửa sổ trên. Tuỳ chọn sau (ngoài slice trừ G3 mở): cờ “turn beat” theo trang.
- **Map lỗ (ADR G2 câu 8):** chỉ lật qua vùng đã map; thiếu map → fallback nhảy trang kiểu 0059 khi `pageNumber` playhead đổi, hoặc không nhảy xuyên lỗ (G3 câu 9).

### B. Bước tiến = PageTurn đã ship, không invent bước thứ hai

- **TurnAmount (0014):** tái sử dụng cho bước auto trên layout liên tục (viewport fraction `full` / `half`); Half Page layout giữ bước ½ cứng như manual (0056). Single / Two-page: theo cùng luật `resolvePageTurnStep` như PageTurn tay (G3 câu 3–4).
- **Animation (0007):** tái sử dụng preset Off / Fast / Normal / Slow cho bước auto (G3 câu 5).
- **Page-turn delay (0006):** **không** áp cho auto — delay là chống double-pedal, không phải “lật sớm”.
- **Reverse (0008):** **không** đảo chiều auto — timeline luôn tiến “next” theo PageOrder.

### C. Theo playhead trong cùng trang (scroll / Half Page)

- Khi playhead còn trên **cùng** trang tuyệt đối nhưng hệ đang chơi **ra ngoài** viewport (fit-width đang xem hệ trên, playhead đã xuống hệ dưới): auto scroll / bước TurnAmount để giữ hệ (hoặc playhead Y) trong tầm nhìn — không chờ đổi trang (G3 câu 6). Đây là nửa còn lại của lời hứa ADR “playhead trên đúng dòng đang chơi” mà nhảy-theo-trang không đủ.

### D. Prefs + UI

- Pref bật/tắt lật rảnh tay lúc Play (khuyến nghị: **bật mặc định** khi đang Play; G3 câu 7). Persist app-level (cùng họ `playback_prefs.json` hoặc PageTurn prefs — G3 câu 7b).
- Lối chỉnh: **Playback settings…** (nhóm Playing, cạnh count-in / Bar·Float / playhead) — không nhân bản sang PageTurn settings trừ khi G3 chọn khác.
- Manual PageTurn / pedal lúc Play: vẫn được; gesture thắng trong một cửa sổ ngắn rồi auto tiếp tục (G3 câu 8) — tránh giằng co.

### E. Ranh giới phiên Playback (giữ 0059)

- **Pause** — đóng băng cả timeline và auto-turn.
- **Stop** — về đầu; lần Play sau: count-in + đưa trang đầu map vào tầm nhìn như 0059; auto-turn chỉ sau khi playhead chạy.
- Vào Measure map / hide controls lúc Play → Pause (đã khóa 0059) — không auto-turn khi đang soạn.
- **Setlist:** hết trang cuối Score hiện tại → **không** auto sang Score kế (0012) trừ khi G3 mở (khuyến nghị: không).

### F. `CONTEXT.md` (G1 lúc build)

- Thêm hoặc siết một term cho hành vi này (khuyến nghị tên miền: **HandsFreePageTurn** — PageTurn do SyncMap lên lịch lúc Play; tránh “AutoPlay” vì SCOREPDF-PARITY / Transport dùng nghĩa khác). Không synonym “auto scroll / smart turn” làm term miền.

---

## Ngoài phạm vi (Out of scope)

- Phát hiện rest / nốt từ ảnh trang (OMR) — đóng
- Spike SoLoud 4.1 / `getEngineTime` — **0061**
- BackingTrack + Transport / `ClickLane` — **0062**
- SyncMap gõ tay — **0063**
- SongPack / Packs / thu âm — 0064+
- MusicXML, WaitMode, MidiLane — đóng
- Auto chuyển Score trong Setlist
- Pref TurnAmount / animation riêng chỉ cho auto (trừ G3 mở)
- Seek kéo playhead tay phức tạp; nhiều SyncMap có tên
- Nâng `flutter_soloud`, quyền mic, mạng, tiền; `formatVersion`

---

## Thuật ngữ miền (Domain terms)

| Term | Ghi chú |
|---|---|
| **PageTurn** | Tiến / lùi khung xem theo luật layout + cử chỉ; slice này **lên lịch** cùng bước đó từ SyncMap |
| **TurnAmount** | Độ dài một bước (`full` \| `half`) — tái dùng cho auto trên scroll |
| **Playhead** / **PlaybackControls** / **SyncMap** / **MeasureMap** | Đã khóa 0058–0059; nguồn thời gian + hình học |
| **SystemBox** / **MeasureBox** / **beatSplits** | Xác định “hệ cuối / ô cuối / phách cuối” trên trang sắp rời |
| **HandsFreePageTurn** *(đề xuất G1)* | Auto PageTurn lúc Play theo cửa sổ lật; không phải AutoPlay của SmartMode |

---

## Câu hỏi G3 (G3 questions) — chờ Orchestrator

Mỗi câu kèm **khuyến nghị**. Chấp nhận cả bảng = Spec → `accepted` và được build.

| # | Câu hỏi | Khuyến nghị |
|---|---|---|
| 1 | **Cửa sổ lật là gì?** | Playhead vào **phách cuối** của MeasureBox cuối trên SystemBox cuối của trang/bước sắp rời. Look-ahead: lên lịch lật **đầu** phách đó. |
| 2 | **“Dấu lặng” không có OMR — proxy thế nào?** | Proxy = cửa sổ câu 1. **Không** nhận dạng rest từ PDF. Không bắt buộc cờ tay trong 0060. |
| 3 | **TurnAmount?** | **Có** — cùng `resolvePageTurnStep` như PageTurn tay (scroll: ½/1 viewport; two-page half→1 / full→2; single: 1 trang; Half Page: ½ cứng). Không control trùng. |
| 4 | **Two-page: một trang hay cả spread?** | Theo TurnAmount như manual. |
| 5 | **Animation / delay / reverse?** | Animation **có** (preset 0007). Delay **không**. Reverse **không** (luôn next theo PageOrder). |
| 6 | **Theo hệ trong cùng trang (scroll)?** | **Có trong 0060** — giữ hệ/playhead trong viewport; không chỉ nhảy khi đổi `pageNumber`. |
| 7 | **Mặc định bật/tắt?** | **Bật** lúc Play; Pause đóng băng; pref persist tắt được. |
| 7b | **Lối UI prefs?** | Hàng trong **Playback settings…** (ScoreMenu). Không nhét vào PageTurn settings. |
| 8 | **PageTurn tay lúc đang Play?** | Cho phép; gesture thắng ~1–2 s rồi auto tiếp tục (debounce), tránh giằng. |
| 9 | **Map lỗ / vùng chưa map?** | Không nhảy xuyên lỗ; fallback nhảy trang 0059 chỉ khi playhead đã đổi trang sang vùng có map. |
| 10 | **Quan hệ với nhảy trang thô 0059?** | **Thay** trong lúc Play bằng thuật toán tinh; giữ count-in → mở trang đầu map. |
| 11 | **Hết Score / Setlist?** | **Không** auto sang Score kế. |
| 12 | **Baseline test?** | Đo đầu chat build (sau 0059 G4 ~**635**); kỳ vọng tăng unit/widget cho scheduler + TurnAmount path. |

---

## Ràng buộc kỹ thuật (Technical constraints)

- Module sâu: scheduler / “turn opportunity” thuần từ MeasureMap + SyncMap + viewport snapshot — unit-test được; `pdf_mode_screen` chỉ gọi bước PageTurn đã có (`resolvePageTurnStep` / `_jumpToPage` / scroll fraction).
- Không đọc pixel PDF; không OMR.
- Listenable hẹp — không rebuild cả PdfMode mỗi tick chỉ vì quyết định lật (tiền lệ playhead / BeatStrip).
- Mọi chuỗi mới qua `AppLocalizations`. Domain term giữ tiếng Anh trong mọi locale.
- Không dependency mới; không quyền mới; `formatVersion` không đổi.

---

## Tiêu chí chấp nhận (Acceptance criteria)

**Lúc Play — cửa sổ lật**

- [ ] Trên bài ≥2 trang đã map: trước khi playhead sang trang kế, viewport đã tiến (không đợi tới ô đầu trang mới rồi mới nhảy như 0059 thuần)
- [ ] Cửa sổ khớp câu G3 1–2 (phách cuối hệ cuối / proxy; không OMR)

**TurnAmount + layout**

- [ ] Scroll + TurnAmount half/full: bước auto ≈ bước PageTurn tay
- [ ] Half Page: bước ½ viewport như manual
- [ ] Single / Two-page: theo G3 3–4
- [ ] Animation theo preset; delay/reverse không đảo auto (G3 5)

**Cùng trang**

- [ ] Fit-width (và Half Page nếu áp dụng): playhead xuống hệ dưới → viewport theo, không cần đổi trang (G3 6)

**Phiên + prefs**

- [ ] Pref bật/tắt trong Playback settings; mặc định theo G3 7; persist
- [ ] Pause đóng băng; Stop rồi Play lại: hành vi đầu bài 0059 + auto sau khi chạy
- [ ] Manual PageTurn lúc Play không giằng vô hạn với auto (G3 8)
- [ ] Map lỗ: không nhảy xuyên (G3 9)
- [ ] Không auto sang Score Setlist kế (G3 11)

**Ranh giới**

- [ ] Không OMR / BackingTrack / Transport / SoLoud bump
- [ ] `flutter analyze` sạch; suite xanh; không dependency / quyền mới; `formatVersion` không đổi

---

## Kế hoạch kiểm thử (Test plan)

- **Automated:** unit cho “turn opportunity” (system/measure/beat cuối trên trang giả); path TurnAmount continuous; fallback map lỗ; không schedule khi Pause/Stop/count-in.
- **Widget / integration nhẹ:** Play trên fixture 2 trang → navigation fire trước page-boundary thô; pref off → không auto (chỉ fallback 0059 nếu còn).
- **Manual (G4):** etude ≥2 trang đã map; Single + Scroll (+ Half Page nếu có); TurnAmount half; pedal xen lúc Play; tắt pref; Pause giữa cửa sổ lật; piece vs full score.

---

## Ghi chú UX (UX notes)

- Nhạc công **không** phải gắn “turn mark” để slice đứng (trừ G3 mở cờ tay).
- Cảm giác sân khấu: trang kế đọc được **trong** phách cuối, không giật sau downbeat trang mới.
- Chuỗi settings ngắn, tiếng địa phương; term HandsFreePageTurn / PageTurn / TurnAmount giữ tiếng Anh nếu là term miền.
