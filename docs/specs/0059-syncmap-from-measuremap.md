# 0059 — SyncMap tính từ MeasureMap; Playback controls + playhead

- **Status:** done
- **Type:** feature
- **Horizon:** H5 (ADR 0019 quyết định 1 — chỉ cần biết *chỗ nào trên trang, ở giây thứ mấy*; không cần biết *nốt nào*)
- **Owner (human):** Orchestrator
- **Depends on ADRs:** **0019** (`accepted` — quyết định 3 / 3b / 3c đường *tính ra*; G2 câu 3 khoá tempo khi có BackingLane; G2 câu 8 MeasureMap chưa đầy đủ; revision 7–8), 0005, 0007 (SyncMap là chỗ khớp — không mở WaitMode/MidiLane), 0008 (H3/H4 vẫn đóng), 0013 (tier), 0014 (phép dịch ↔ `TimemapEntry`), 0015, 0016
- **Depends on Specs:** **0058** (`done`, **rev. 2** — `beatSplits` = N mốc nội tại; không phải nguồn thời lượng), **0030** (metronome — click đi theo cùng clock khi Play), **0035** / **0043** (ScoreMenu IA — lối show/hide Playback controls), 0052 / 0055 (lớp phủ theo `scoreId`)
- **Tier:** **M** — seam thời gian + UI playback trên PdfMode; không SDK mới, không quyền mới, không byte rời máy, không di trú library. **G3 + G4**; không cần ADR mới; **Security Review không cần** (ADR 0019: cần cho SongPack và thu âm, không cần slice 1–7)
- **G3:** **accepted 2026-08-07** — Orchestrator chấp nhận **mọi** khuyến nghị (câu 1–11b + 2b–2g). Câu 2 đã chốt sớm hơn cùng ngày (Playback controls + playhead).
- **G4:** **pass (2026-08-07)** — Orchestrator chấp nhận sau build + chỉnh UI (Playback settings, docked/float, playhead appearance, badge cố định width)
- **Security Review:** không cần

> **Đóng slice.** Baseline build **596** → **621**; G4 UI/tests sau đó. Slice 6 ADR 0019 xong. Slice kế: **0060** lật trang rảnh tay tinh.

---

## Vấn đề (Problem)

0058 đã cho app biết ô nhịp **nằm ở đâu** trên giấy (kèm tempo / time signature và N mốc `beatSplits`) — nhưng app vẫn **không biết ô ấy vang lên lúc nào**, không có cách **Play** theo bài, và không có playhead chạy trên giấy. Metronome (0030) chạy prefs app-wide, không đọc MeasureMap. Không có SyncMap trong code.

ADR 0019 quyết định 3c: **tính** SyncMap từ MeasureMap (tempo + time sig → timeline). Orchestrator chốt thêm ở G3: slice này phải có **Playback controls** (play / pause / stop, show/hide từ menu) và **vẽ playhead** chạy theo SyncMap — không chỉ “metronome sheet đọc tempo map”.

---

## Kết quả (Outcome)

Nhạc công map bài → mở PdfMode → bật **Playback controls** (ScoreMenu) → **Play**: **count-in** 1–2 ô (tuỳ chọn) bằng click metronome, rồi click + **playhead** chạy trên giấy theo SyncMap × `beatSplits`. **Pause** đóng băng; **Stop** về đầu. Ẩn controls khi không cần. Chưa map: metronome 0030 giữ nguyên. Không BackingTrack, không gõ SyncMap tay.

---

## Trong phạm vi (In scope)

### A. Mô hình SyncMap (tính ra — ADR 0019 quyết định 3c đường 1)

- Kiểu Dart: danh sách entry theo ô nhịp, chi tiết tới **phách**.
- Phép tính thuần từ MeasureMap đã `resolveMeta`:

  | Đầu vào (MeasureMap) | Đầu ra (SyncMap entry) |
  |---|---|
  | `measureNumber` | `measure` |
  | tempo + time signature đã resolve | `tempo`, `timeSignature`, `durationInQuarters` |
  | cộng dồn thời lượng | `timeMs` (downbeat) |
  | số phách từ time signature | `beatTimestamps[]` — `[0] === timeMs` |

- **Thời lượng ô:** `durationInQuarters = numerator × (4 / denominator)`; `msPerQuarter = 60000 / tempo` (BPM **nốt đen**).
- **`beatTimestamps`:** chia **đều theo thời gian** trong ô. **Không** suy từ `beatSplits` (0058 rev. 2: N mốc vị trí trên giấy).
- Chỉ ô có mặt trên map; lỗ số ô → nối các ô có mặt, không bịa im lặng.
- Hễ MeasureMap không rỗng → SyncMap tính ra tồn tại. Không UI đặt tên / nhiều bản SyncMap.

### B. Persistence

- **G3 câu 1:** hàm thuần `MeasureMap → SyncMap` — **không** file `sync_maps/…` trong 0059.
- Pref **show/hide Playback controls** (mặc định **ẩn**) và pref **count-in ô (0/1/2)** (mặc định **0** — G4) — persist.

### C. Phép dịch web (ADR 0019 quyết định 6)

Round-trip subset `TimemapEntry`: `timeMs`, `measure`, `beatTimestamps`, `timeSignature`, `tempo`, `durationInQuarters`. `tempoAtBeat` / `startsAtBeat` không bắt buộc.

### D. Playback controls + clock

- **Lối show/hide:** ScoreMenu (`⋯`) — *Show/Hide playback controls* (nhóm Playing hoặc tương đương 0035). **Không** QuickBar (G3 2c).
- **Khi hiện:** hai kiểu (pref `PlaybackControlsStyle`, mặc định **docked** — G4):
  - **Docked** — một hàng seek + thời gian + Play/Pause/Stop; luôn **trên** PageNav/QuickBar (không bị PerformanceMode chrome đè).
  - **Floating** — pill Play/Pause + Stop kéo được (không seek trên pill); persist vị trí chuẩn hoá.
- **Play** — timeline từ vị trí hiện tại (sau Pause) hoặc từ đầu (sau Stop / lần đầu). **Pause** — đóng băng. **Stop** — về đầu timeline rồi ẩn playhead (G3 2e).
- **Playback settings…** (ScoreMenu, nhóm Playing) — count-in + Bar/Float + **playhead** (màu / độ dày / chiều cao ≥100% MeasureBox / độ đục). **Không** để trong Metronome sheet (G4).
- **Điều kiện:** show/hide + Play khi MeasureMap **không rỗng**; map rỗng → show/hide **disabled** + lý do (G3 2d). Settings vẫn mở được (prefs app-wide).
- Clock PdfMode riêng (chưa Transport / `ClickLane` — **0062**). Click: `MetronomeEngine.playClick` cùng clock (volume/mute/showBeats prefs 0030). **Không** engine audio thứ hai. Click lead nhỏ + warm buffer để playhead không chạy trước tiếng.
- **Count-in:** pref **0 / 1 / 2** ô; mặc định **0** (G4; G3 từng là 1). Badge dạng `measures.beat` 1-based lúc đếm (vàng cam); hết count-in → hiện **`measure.beat` hiện tại** màu primary (Play/Pause). Pref `0` → không count-in. Tempo + meter = ô đích. Trong count-in: playhead **chưa** vẽ trên bài, nhưng **trang đầu map vào tầm nhìn ngay** khi Stop→Play. **Không** count-in sau Pause→Play (G3 11b).
- Đổi MeasureMap lúc đang Play: tính lại SyncMap; tiếp tục từ `measure`+phách gần nhất nếu còn; nếu mất → Stop + snackbar.

### D2. Nhịp lấy đà (pickup / anacrusis)

#### Bất biến (Orchestrator) — đúng cho mọi cách model

1. Playhead **bắt đầu** tại nốt lấy đà (thời điểm ms đầu của đoạn pickup trên SyncMap).
2. Khi hết thời lượng pickup, **cùng một lúc**:
   - metronome gõ **phách 1** (accent) của ô đủ phách kế tiếp;
   - playhead đứng đúng **nốt đầu / mốc phách 1** của ô đó (`beatSplits[0]` của ô đủ phách).
3. Không được “trôi” — hết pickup mà accent ô sau lệch một phách, hoặc playhead còn nằm giữa ô pickup trong khi click đã vào ô sau.

Hai kênh độc lập gặp nhau đúng mốc đó: **thời gian** = cuối entry pickup = `timeMs` downbeat ô sau; **vị trí giấy** = `beatSplits[0]` ô sau.

#### Option A — “Ô pickup ngắn” nghĩa là gì

Trên nhiều bản khắc, lấy đà **không** chiếm cả bề ngang một ô 4/4: chỉ một nốt (hoặc vài nốt) hẹp, rồi mới tới ô đủ phách. Nhạc công vẽ **hai** MeasureBox:

```text
|♪|  |♩ ♩ ♩ ♩|     ← giấy
 ↑      ↑
 ô P    ô 1
 hẹp    đủ 4/4
```

- **Ô P (pickup):** box chỉ phủ chỗ in lấy đà; `timeSignature = 1/4` (một phách nếu lấy đà một nốt đen); một mốc `beatSplits`.
- **Ô 1:** box phủ ô đủ phách; `4/4`; bốn mốc `beatSplits` (kéo khớp bốn nốt/phách).

SyncMap tính (tempo 120 → 500 ms/phách đen):

| Ô | `timeMs` downbeat | Thời lượng | Việc xảy ra |
|---|---|---|---|
| P | `0` | 500 ms | Playhead tại nốt lấy đà; click phách pickup |
| 1 | `500` | 2000 ms | **t = 500:** accent phách 1 **và** playhead → mốc đầu ô 1 |

Đúng bất biến trên — **không cần** `startsAtBeat`. “Ngắn” = thời lượng ô P ngắn vì time signature ngắn + (thường) box hẹp trên giấy; timeline nối đuôi nhau nên ô 1 bắt đầu đúng lúc.

#### Option B — ô đủ rộng trên giấy, nhạc chỉ bắt giữa ô

Đôi khi khắc vẽ **một** khung ô rộng như 4/4 nhưng phía trái trống / nghỉ, lấy đà nằm gần vạch phải. Một MeasureBox full width + `4/4` sẽ khiến SyncMap tưởng đủ bốn phách từ mép trái → playhead và click **sai** so với nốt. Khi đó cần **`startsAtBeat`** (vd. bắt đầu từ phách 4): bỏ thời gian các phách trước; downbeat “nghe được” khớp nốt lấy đà; hết phần còn lại của ô → ô sau vẫn khớp accent phách 1 như bất biến.

- **G3 câu 6 (accepted):** bất biến trên là tiêu chí chấp nhận. **A** dùng ngay (map hai ô). **B** — field **`startsAtBeat`** + UI tối thiểu (*Starts at beat…*) trong 0059; round-trip web.

### E. Playhead trên giấy

- Vẽ playhead (đường / cursor rõ, không che nốt quá mức) tại vị trí suy từ:
  - **Thời gian:** vị trí ms trên SyncMap → ô + phách (+ nội suy trong phách nếu cần).
  - **Chỗ trên trang:** `MeasureBox` + `beatSplits` (N mốc nội tại) — ADR 3b.
- Playhead hiện khi đang Play hoặc Pause; sau Stop → **về đầu rồi ẩn** (G3 2e).
- Nếu ô đang chơi **không** nằm trên trang / viewport hiện tại: **đưa trang đó vào tầm nhìn**. **Không** thuật toán lật trang tinh của 0060.
- Vào *Measure map…* → **Pause** (nếu đang Play) và tạm ẩn playhead đến khi thoát soạn (G3 2f). **Hide Playback controls** lúc đang Play → **Pause** (G3 2g).

### F. `CONTEXT.md` (G1 lúc build)

- Giữ SyncMap đã siết. **PlaybackControls** (docked/floating + Playback settings trên ScoreMenu). **Playhead** — chỉ báo vị trí trên giấy theo SyncMap + MeasureMap; tránh synonym “cursor / scrubber” làm term miền.

---

## Ngoài phạm vi (Out of scope)

- Lật trang rảnh tay tinh (rest ở cuối hệ, Turn amount, …) — **0060** (playhead + đưa trang vào tầm nhìn đã nằm ở 0059)
- Spike SoLoud 4.1 / `getEngineTime` — **0061**
- BackingTrack + Transport (`ClickLane` nuốt metronome) — **0062**
- SyncMap gõ tay — **0063**
- SongPack / Packs / thu âm — 0064+
- OMR, MusicXML, WaitMode, MidiLane — đóng
- UI nhiều SyncMap có tên; seek scrubber phức tạp / kéo playhead tay (trừ khi G3 mở)
- Count-in > 2 ô; count-in theo số phách lẻ (chỉ theo **số ô** 0/1/2)
- Nâng `flutter_soloud` breaking, quyền mic, mạng, tiền; `formatVersion`

---

## Thuật ngữ miền (Domain terms)

| Term | Ghi chú |
|---|---|
| **SyncMap** | Timeline ms ↔ ô/phách; slice này tính từ MeasureMap |
| **SyncMapEntry** | Một mốc ô (~ web `TimemapEntry`) |
| **PlaybackControls** | UI Play / Pause / Stop + show/hide; kiểu **docked** / **floating**; settings riêng trên ScoreMenu |
| **Playhead** | Chỉ báo vị trí trên giấy theo SyncMap × `beatSplits` |
| **MeasureMap** / **beatSplits** | Hình học; N mốc nội tại — vị trí, không thời lượng |
| **Metronome** | Click; khi Play theo cùng clock SyncMap (count-in prefs không sống trong Metronome sheet) |
| **Count-in** | Đếm trước N ô (click) trước timeline bài; badge rồi chuyển sang `measure.beat` đang chơi |
| **Pickup** / **`startsAtBeat`** | Nhịp lấy đà: ô ngắn + time sig **hoặc** ô đủ rộng bắt đầu từ phách k |

---

## Câu hỏi G3 (G3 questions) — **đã trả lời 2026-08-07**

Orchestrator: chấp nhận **mọi** khuyến nghị như bảng dưới.

| # | Câu hỏi | Quyết định |
|---|---|---|
| 1 | **SyncMap tính ra có ghi ra đĩa không?** | **Không** trong 0059 — hàm thuần từ MeasureMap |
| 2 | **UI khi có SyncMap?** | ScoreMenu **show/hide Playback controls**; **Play / Pause / Stop**; **playhead** theo SyncMap × `beatSplits` (bác “chỉ sửa metronome sheet”) |
| 2b | **Mặc định Playback controls?** | **Ẩn**; persist; bật từ `⋯` |
| 2c | **QuickBar?** | **Không** — giữ Draw / Metronome / Bookmarks |
| 2d | **Map rỗng?** | Mục menu **thấy nhưng disabled** + lý do (*Map measures first*) |
| 2e | **Playhead sau Stop?** | **Về đầu rồi ẩn** |
| 2f | **Lúc soạn MeasureMap?** | Vào *Measure map…* → **Pause** + tạm ẩn playhead |
| 2g | **Hide controls lúc đang Play?** | **Pause** |
| 3 | **`tempo` trên MeasureBox?** | **BPM nốt đen (quarter)** |
| 4 | **Map thiếu ô giữa?** | Nối ô có mặt — không bịa im lặng |
| 5 | **`beatTimestamps` bắt buộc?** | **Có** — chia đều theo thời gian |
| 6 | **Pickup / nhịp lấy đà?** | **A** ô ngắn + time sig; **B** `startsAtBeat` + UI tối thiểu trong 0059; bất biến § D2; round-trip web |
| 7 | **Đổi MeasureMap lúc Play?** | Tính lại; tiếp tục gần nhất; mất ô → Stop + snackbar |
| 8 | **Play bắt đầu từ đâu?** | Stop/lần đầu: ô `measureNumber` nhỏ nhất (+ `startsAtBeat`); Pause→Play: tiếp tục |
| 9 | **All-pages gốc?** | Theo MeasureMap của `scoreId` đang mở |
| 10 | **Baseline test?** | Đo đầu chat build; kỳ vọng ~**595+** (sau 0058) |
| 11 | **Count-in?** | Pref **0 / 1 / 2** ô; mặc định **0** (G4; G3 là 1); chỉnh ở **Playback settings…** (G4; G3 metronome sheet); pref `0` = không đếm; lúc Play/Pause badge = `measure.beat`; tempo/meter = ô đích |
| 11b | **Count-in sau Pause?** | **Không** — chỉ sau Stop / Play đầu từ đầu bài |

---

## Ràng buộc kỹ thuật (Technical constraints)

- Module sâu: `lib/sync_map/` (compute + model + web encode); playback clock / playhead mapper tách khỏi `pdf_mode_screen` càng nhiều càng tốt.
- Playhead: overlay cùng hệ 0–1 / `pageRect` như annotation / MeasureMap; map `timeMs → (page, x, y)` thuần, unit-test được.
- Không async nặng trên frame vẽ playhead; ticker/`Listenable` hẹp (tránh rebuild cả PdfMode mỗi tick — tiền lệ BeatStrip 0030).
- Mọi chuỗi mới qua `AppLocalizations`. Domain term SyncMap / Playback / Playhead giữ tiếng Anh trong mọi locale nếu là term.
- Không dependency mới; không quyền mới; `formatVersion` không đổi.
- Không OMR.

---

## Tiêu chí chấp nhận (Acceptance criteria)

**Chưa map**

- [x] Không Play theo bài; metronome 0030 nguyên — *G4*
- [x] Mục Playback controls **disabled** + lý do khi map rỗng (G3 2d) — *UI*

**SyncMap**

- [x] Tính đúng `timeMs` / `beatTimestamps` / tempo đổi giữa bài — *unit*
- [x] `beatSplits` lệch không đổi timeline — *unit*
- [x] Round-trip subset `TimemapEntry` — *unit*

**Playback controls + count-in**

- [x] ScoreMenu show/hide; persist — *UI + prefs*
- [x] ScoreMenu **Playback settings…** (Bar/Float + count-in + playhead màu/độ dày/chiều cao/độ đục); không còn trên Metronome sheet — *UI + G4*
- [x] Docked trên chrome đáy; floating kéo được + persist offset — *UI + prefs*
- [x] Play / Pause / Stop đúng nghĩa Outcome — *G4*
- [x] Play → click theo SyncMap khi metronome không mute — *G4*
- [x] Count-in 0/1/2 ô; mặc định **0**; sau Stop có đếm (nếu >0), sau Pause không (11b) — *unit + G4*
- [x] Badge: count-in vàng cam; đang Play/Pause → `measure.beat` primary; slot width cố định — *G4*
- [x] Trong count-in playhead chưa vẽ trên bài; Stop→Play đưa trang đầu vào tầm nhìn ngay — *G4*

**Pickup**

- [x] Ô ngắn + time sig → timeline ngắn đúng — *unit*
- [x] `startsAtBeat` → bỏ phách trước mốc; playhead + accent khớp bất biến § D2; round-trip web — *unit + UI*

**Playhead**

- [x] Chạy trên giấy khớp ô/phách (SyncMap × `beatSplits`) khi Play — *G4*
- [x] Pause giữ vị trí; Stop về đầu / ẩn theo 2e — *G4*
- [x] Ô ngoài trang hiện tại → đưa trang vào tầm nhìn — *G4*
- [x] Vào Measure map soạn → Pause + tạm ẩn playhead (2f) — *G4*

**Ranh giới**

- [x] Không BackingTrack / Transport / ClickLane rename — *không có*
- [x] Không thuật toán lật trang “phách nghỉ cuối hệ” tinh (0060) — *không có*
- [x] `flutter analyze` sạch; suite xanh; không dependency / quyền mới

---

## Ghi chú UX (UX notes)

- Playback controls gọn, không đè trung tâm khuông. **Hai kiểu** (pref **Playback settings…** trong ScoreMenu — không còn trong Metronome sheet; mặc định docked): **docked** — một hàng seek+transport, luôn **trên** PageNav/QuickBar (không bị PerformanceMode chrome đè); **floating** — pill Play/Pause+Stop kéo được, lưu vị trí, không seek trên pill. Count-in cũng chỉnh ở Playback settings. Badge: lúc count-in màu **vàng cam**; hết count-in → `measure.beat` hiện tại màu primary (Play/Pause).
- Stop→Play (kể cả đang count-in): đưa **trang đầu** của map vào tầm nhìn ngay — không đợi hết count-in (nhạc công cần nhìn nốt để chuẩn bị).
- Playhead: một đường đứng (hoặc tương đương); mặc định đỏ (`#E53935`) độ dày `1.4` / chiều cao `100%` MeasureBox (kéo dài tâm ô tới `200%`) / opacity `1.0`; chỉnh trong Playback settings; không hộp đè cả ô.
- Show/hide: nhãn ScoreMenu phản ánh trạng thái (*Hide…* khi đang hiện).
- Không mục *SyncMap…* soạn tay ở slice này.

---

## Kế hoạch kiểm thử (Test plan)

**Automated**

- `sync_map_from_measure_map_test.dart` — công thức; incomplete; beatSplits ≠ duration; `measureBeatAtTime`
- `sync_map_web_roundtrip_test.dart` — fixture `TimemapEntry`
- `playhead_position_test.dart` — `timeMs` + boxes → page/x (kể cả nội suy / barline jump)
- `playback_prefs_test.dart` — show/hide, count-in, style, float norm
- `sync_map_playback_count_in_test.dart` — count-in / seek / Stop
- `playback_controls_bar_test.dart` / `playback_float_controls_test.dart` — format + pill smoke
- `score_menu_test.dart` — Playback settings entry

**Manual (G4)**

1. Chưa map — metronome cũ; Show Playback disabled; Playback settings vẫn mở được.
2. Map vài trang → show controls → Play — count-in (nếu >0) rồi click + playhead; đổi tempo/meter giữa bài.
3. Pause / Play lại (không count-in) / Stop (Play lại có count-in nếu pref >0) — **trang đầu hiện ngay khi Play**, kể cả đang đếm.
3b. Ô pickup ngắn `1/4`; (nếu có) ô full với *Starts at beat* = 3.
3c. Playback settings: Bar vs Float; kéo float, restart app giữ vị trí; chrome hiện không đè docked.
4. Hide controls lúc đang Play → **Pause** (G3 2g).
5. Playhead sang trang khác — trang vào tầm nhìn.
6. Vào Measure map lúc Play — Pause, không đè soạn; kéo SystemBox L→R trên page ≥2 không thành page turn.
7. (Orchestrator) cảm nhận trước khi mở 0060 / đóng G4.
