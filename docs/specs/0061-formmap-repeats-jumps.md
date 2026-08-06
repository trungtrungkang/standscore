# 0061 — FormMap: lặp / volta / nhảy (D.C., D.S., coda) → SyncMap bung

- **Status:** done
- **Type:** feature
- **Horizon:** H5 (ADR 0019 quyết định 1 — chỗ trên trang + giây thứ mấy; **không** mở MusicXML / OMR / SmartMode)
- **Owner (human):** Orchestrator
- **Depends on ADRs:** **0019** (`accepted` — quyết định 3 / 3b / 3c đường *tính ra*; revision **9** chèn slice này trước 0060), **0014** (hai bounded context — web `measureMap` latent→physical ≠ StageScore MeasureMap), 0005, 0006 (**không** OMR), 0007, 0008, 0013, 0015, 0016
- **Depends on Specs:** **0059** (`done` — SyncMap tuyến tính MeasureBox nối đuôi), **0058** (`done` — MeasureMap hình học, `measureNumber` vật lý), 0011 (PageOrder — lặp **trang**, không thay FormMap), 0016 (JumpLink — nhảy **trang** tay, khác form)
- **Tier:** **L** — mô hình dữ liệu khó đảo (timeline latent + lớp form bền); trần chất lượng Play trước BackingTrack / SongPack; chạm sâu `syncMapFromMeasureMap` + playhead. Không SDK mới, không quyền mới, không byte rời máy → **Security Review không cần**. **G2:** ADR 0019 rev. 9 (đã viết cùng lượt draft). **G3 + G4**.
- **G3:** **accepted 2026-08-07** — Orchestrator chấp nhận **mọi** khuyến nghị (câu 1–12).
- **G4:** **passed 2026-08-07** — Orchestrator chấp nhận sau build + chỉnh UX G4 (volta trong Add repeat, mô tả Marker/Jump, palette FormMap).
- **Security Review:** không cần

> **Đóng.** 0060 vẫn `hold`.

---

## Vấn đề (Problem)

0059 tính SyncMap bằng cách **sắp MeasureBox theo `measureNumber` rồi nối thời lượng**. Playhead và click đi một đường thẳng qua từng ô in **một lần**. Bản nhạc thật có:

- đoạn **lặp** (`|: … :|`, có khi >2 lần);
- **volta** (kết 1 / kết 2 — lần một đi nhánh A, lần hai bỏ A lấy B);
- **D.C. / D.S.** quay về đầu hoặc segno;
- **To Coda / Coda / Fine** — nhảy cóc một đoạn dài, hoặc dừng sớm.

Không có lớp form, app sẽ: chơi xuyên qua kết 1 lẫn kết 2; không quay lại; không nhảy vào coda; BackingTrack / SongPack sau này (0063+) không khớp timeline đã bung trên web.

**PageOrder** (0011) và **JumpLink** (0016) chỉ giải bài toán **đọc trang** (nhân bản trang, nút nhảy tay) — không bung timeline ô nhịp, không điều khiển Play.

Repo web (MusicXML path) đã có mô hình đích: Timemap **latent** (mỗi lần thăm ô = một entry) + `notationData.measureMap` thưa latent→physical. PDF path trên web **không** soạn form trên MeasureBox — StageScore phải cho nhạc công **gắn form trên PDF** vì không có MusicXML (H3 đóng).

---

## Kết quả (Outcome)

Nhạc công map hình học (0058) → mở soạn **FormMap** → gắn lặp / volta / mốc nhảy (segno, coda, …) trên các ô đã có → Play: SyncMap **bung** đúng thứ tự nghe (ô vật lý có thể xuất hiện nhiều lần; đoạn bị nhảy cóc không có trên timeline). Playhead vẫn vẽ trên **ô vật lý** đúng lần thăm. Không FormMap → hành vi 0059 giữ nguyên (form đồng nhất). Không OMR, không MusicXML.

---

## Trong phạm vi (In scope)

### A. Tách hai không gian số ô (ADR 0014 — bắt buộc nói rõ)

| Không gian | Nghĩa | Ai sở hữu |
|---|---|---|
| **Physical measure** | Số ô in trên giấy = `MeasureBox.measureNumber` | MeasureMap (0058) — **không đổi** |
| **Latent measure** | Chỉ số lần thăm trên timeline phát (0…N−1 hoặc 1…N) | SyncMap sau khi bung |

- Playhead / click / seek đọc **latent** trên SyncMap, rồi map → physical → hình học MeasureMap.
- `SyncMapEntry` cần mang đủ để round-trip web: `measure` = **latent** (như web `TimemapEntry.measure`) + neo physical (field riêng hoặc bảng thưa — G3 câu 3).
- **Cấm** nhồi `repeatForward` / `coda` vào geometry MeasureBox như nguồn thời lượng — ADR 0019 quyết định 3b: hình học ≠ thời gian; form là tầng thứ ba.

### B. FormMap (lớp form — tên miền đề xuất)

Một Score **một** FormMap (cùng `scoreId` với MeasureMap), mặc định **rỗng** = “chơi tuần tự mọi ô physical một lần” (0059).

Nội dung tối thiểu (khuyến nghị G3 — có thể cắt):

| Thành phần | Việc nhạc công làm | Hiệu ứng khi bung |
|---|---|---|
| **Repeat region** | Đánh dấu ô bắt đầu / kết thúc lặp + `times` (mặc định 2) | Phát lại đoạn đó `times` lần |
| **Ending (volta)** | Gắn vùng “kết *n*” trong / sát repeat | Chỉ đi vùng có `endingNumber == pass` hiện tại; bỏ qua các kết khác |
| **Markers** | Gắn trên một ô: Segno / Coda / Fine (và tùy To Coda) | Điểm neo cho nhảy |
| **Jumps** | D.C. / D.S. / To Coda (từ ô mang chỉ thị) | Đổi con trỏ duyệt form; sau nhảy tôn trọng To Coda / Fine như web `unrollMeasures` |

Khuyến nghị thuật toán bung: port tinh thần `unrollMeasures` (web `musicxml-analyzer.ts`) — duyệt physical với state (pass, jumped, repeat stack), emit một SyncMapEntry mỗi lần thăm; ghi sparse latent→physical khi lệch. Trần vòng lặp (vd. `physicalCount * 10`) chống form hỏng.

### C. Persistence + backup

- File theo `scoreId` (idiom `measure_maps/` — vd. `form_maps/<scoreId>.json`).
- Vào backup / `clearScoreOverlays` / label backup như MeasureMap.
- `formatVersion` library: **không** tăng nếu FormMap chỉ là overlay mới (giống measure_maps) — G3 xác nhận.
- Map cũ không FormMap: load = rỗng → SyncMap = 0059.

### D. Phép tính SyncMap (thay thân 0059 khi FormMap ≠ rỗng)

```
MeasureMap + FormMap → (unroll) → SyncMap (latent entries + physical anchors)
```

- Thời lượng mỗi lần thăm: vẫn tempo + time sig + `startsAtBeat` của **MeasureBox physical** (0059).
- `beatSplits` vẫn chỉ vị trí playhead trên giấy.
- Đổi MeasureMap hoặc FormMap lúc Play: tính lại; tiếp tục gần latent/physical nếu còn; mất → Stop + snackbar (cùng họ 0059 câu 7).

### E. UI soạn (tối thiểu để slice đứng)

- Lối ScoreMenu: *Form map…* (hoặc *Repeats & jumps…*) cạnh *Measure map…* — **disabled** khi MeasureMap rỗng + lý do.
- Soạn trên PdfMode: chọn ô / vùng ô đã có trên MeasureMap (không vẽ hộp hình học mới).
- Loại trừ Draw; vào soạn lúc Play → Pause (như Measure map).
- Empty state: giải thích “không gắn form = chơi thẳng một lần”.
- Không OCR dấu lặp trên PDF.

### F. Playback / playhead (0059 giữ contract, đổi nguồn map)

- Playback controls không đổi IA.
- Playhead: `timeMs` → entry latent → **physical** `measureNumber` → box + `beatSplits`.
- Đưa trang vào tầm nhìn: theo trang của ô **physical** đang chơi (vẫn thô như 0059; lật tinh = 0060 hold).
- Badge `measure.beat`: G3 câu 8 — hiện **physical** (nhạc công đọc số trên giấy) hay latent?

### G. `CONTEXT.md` + ADR 0014 (G1 / revision lúc build)

- Thêm **FormMap**, **Physical measure**, **Latent measure** (và tránh nhầm web `measureMap`).
- Siết **SyncMap**: timeline sau bung form, không còn giả định 1:1 với ô in.
- Bảng ADR 0014: hàng `TimemapEntry.measure` / `notationData.measureMap` ↔ StageScore.

### H. G2 nhẹ — ADR 0019 revision 9

- Chèn slice FormMap vào Trình tự (Spec **0061**); **0060** hold; spike SoLoud và các số sau **+1**.
- Siết quyết định 3c: đường *tính ra* = MeasureMap **+ FormMap** (FormMap rỗng ⇒ 0059).

---

## Ngoài phạm vi (Out of scope)

- MusicXML import / `unrollMeasures` từ XML — H3 đóng
- OMR đọc dấu lặp / volta in trên trang
- Lật trang rảnh tay tinh — **0060** (hold; làm sau FormMap)
- Spike SoLoud / BackingTrack / SyncMap gõ tay / SongPack / thu âm — số mới sau revision 9
- Sửa PageOrder thành form (giữ page-grain)
- Nhiều FormMap có tên / nhiều SyncMap có tên (ADR 0019 tương lai)
- `tempoAtBeat` đầy đủ trên mọi entry (trừ khi G3 mở)

---

## Thuật ngữ miền (Domain terms)

| Term | Ghi chú |
|---|---|
| **MeasureMap** | Hình học ô trên giấy — physical only |
| **FormMap** | Cấu trúc phát: lặp, volta, marker, nhảy |
| **Physical measure** / **Latent measure** | Ô in vs lần thăm trên timeline |
| **SyncMap** / **SyncMapEntry** | Timeline ms; `measure` sau slice này = latent (web-compatible) |
| **PageOrder** / **JumpLink** | Không gian trang — không bung ô nhịp |
| **Volta** / **Segno** / **Coda** / **D.C.** / **D.S.** / **Fine** | Thành phần form; giữ tên Ý/Anh quen thuộc trong UI nếu là term |

---

## Câu hỏi G3 (G3 questions) — **đã trả lời 2026-08-07**

Orchestrator: chấp nhận **mọi** khuyến nghị như bảng dưới.

| # | Câu hỏi | Quyết định |
|---|---|---|
| 1 | **Form sống ở đâu?** | **Lớp riêng FormMap.** MeasureMap = hình học; PageOrder = trang; FormMap = thứ tự nghe. |
| 2 | **Từ vựng form trong slice?** | Repeat + `times`, volta (kết 1/2+), Segno, Coda, To Coda, D.C., D.S., Fine. |
| 3 | **Latent / physical trên SyncMap?** | `measure` = **latent** (web); physical **derive** từ FormMap lúc bung (không ghi SyncMap ra đĩa); runtime entry mang `physicalMeasure` cho playhead. |
| 4 | **FormMap rỗng?** | = hành vi **0059** (một lần thăm mỗi ô physical theo số tăng). |
| 5 | **UI soạn?** | ScoreMenu *Form map…*; soạn trên ô MeasureMap đã có; không vẽ box mới. |
| 6 | **Volta?** | Vùng ô physical + số kết (`1`, `2`, …) trong repeat. |
| 7 | **D.C./D.S./coda?** | **Marker + jump** (không chỉ dán subsequence). |
| 8 | **Badge `measure.beat`?** | **Physical** (số trên giấy). Latent nội bộ. |
| 9 | **vs PageOrder?** | Play / playhead chỉ FormMap→SyncMap; không tự sinh FormMap từ PageOrder. |
| 10 | **`formatVersion`?** | **Không tăng** — overlay `form_maps/<scoreId>.json`. |
| 11 | **Baseline test?** | Đo đầu chat build (~635); unit nặng unroll. |
| 12 | **ADR?** | Chỉ **0019 rev. 9** — không ADR mới. |

---

## Ràng buộc kỹ thuật (Technical constraints)

- Module sâu: `lib/form_map/` (model + persist) + `unroll` thuần `MeasureMap × FormMap → SyncMap` (thay/bọc `syncMapFromMeasureMap`); unit-test không cần widget.
- Playhead mapper: nhận physical measure từ entry, không giả định `entry.measure == box.measureNumber`.
- Không đọc pixel PDF; không dependency mới; không quyền mới.
- Chuỗi UI qua `AppLocalizations`; term Form / Coda / Segno / D.C. giữ dạng nhạc công nhận ra (không dịch thành câu dài trừ nhãn nút).
- Trần unroll bắt buộc + Form invalid → **từ chối Play** + lý do (không treo; không im lặng fallback tuyến tính sai form).

---

## Tiêu chí chấp nhận (Acceptance criteria)

**Tương thích 0059**

- [ ] FormMap rỗng → SyncMap byte-hành vi khớp 0059 trên cùng MeasureMap
- [ ] Playback controls / count-in / pickup / `startsAtBeat` vẫn đúng trên đường bung

**Unroll**

- [ ] Repeat `times=2`: đoạn được chơi hai lần; playhead về đúng ô physical lần hai
- [ ] Volta: lần 1 đi kết 1, lần 2 bỏ kết 1 đi kết 2
- [ ] D.C. / D.S. + To Coda / Coda: nhảy cóc — đoạn bị bỏ **không** có trên timeline
- [ ] Fine: dừng timeline đúng ô
- [ ] Form hỏng / vòng quá trần: không treo; thông báo rõ

**UI + persist**

- [ ] *Form map…* disabled khi chưa có MeasureMap
- [ ] Round-trip file FormMap; có trong backup; xóa Score xóa FormMap
- [ ] Badge hiện physical (nếu G3 câu 8 vậy)

**Ranh giới**

- [ ] Không OMR / MusicXML / BackingTrack / 0060
- [ ] `flutter analyze` sạch; suite xanh; không dependency / quyền mới; `formatVersion` không đổi (nếu G3 câu 10)

---

## Kế hoạch kiểm thử (Test plan)

- **Automated (TDD lõi unroll):** fixture FormMap × MeasureMap nhỏ — lặp đơn; volta 1/2; D.C. al coda; D.S.; Fine; rỗng = 0059; trần vòng; ô physical thiếu trên map.
- **Playhead:** cùng `timeMs` lần thăm 1 vs 2 của một physical measure → cùng hình học box, khác vị trí timeline.
- **Manual (G4):** một bài thật có lặp + coda (hoặc etude giả lập bằng FormMap); Play hết bài nghe đúng đường; soạn sai form → thông báo; backup/restore.

---

## Ghi chú UX (UX notes)

- Nhạc công **đọc** dấu trên giấy và **gắn** lên ô đã map — app không đoán.
- Ưu tiên sửa một marker / một vùng lặp, không bắt vẽ lại cả đường chơi.
- Phân biệt rõ với JumpLink (“nhảy trang bằng nút”) trong empty state một câu.
