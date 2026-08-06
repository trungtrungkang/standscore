# 0058 — MeasureMap: vẽ SystemBox → MeasureBox → BeatBox; nhảy tới ô nhịp

- **Status:** done
- **Type:** feature
- **Horizon:** H5 (ADR 0019 quyết định 1 — chỉ cần biết *chỗ nào trên trang*; không cần biết *nốt nào*)
- **Owner (human):** Orchestrator
- **Depends on ADRs:** **0019** (`accepted` — quyết định 3, 3a–3e, 6, 11 lớp phủ; revision 7 đổi số), 0005, 0006 (**không mở** OMR), 0008 (H3/H4 vẫn đóng), 0013 (tier), 0014 (phép dịch MeasureBox ↔ web), 0015, 0016
- **Depends on Specs:** **0052** (PageExtent, số trang tuyệt đối), **0055** (Score gốc/con; lớp phủ theo `scoreId`; all-pages không union MeasureMap từ con), 0017–0019 (lớp vẽ + hệ toạ độ 0–1), 0027 (`LibraryBackup` — MeasureMap phải vào backup), 0035 / 0043 (ScoreMenu IA — lối vào soạn)
- **Tier:** **L** — dữ liệu tốn công người nhất app từng lưu; công cụ soạn là trần chất lượng cho mọi SongPack sau này (ADR 0019 quyết định 7b); persistence mới theo `scoreId`; chạm sâu PdfMode. Không SDK mới, không quyền mới, không byte rời máy → **Security Review không cần** (ADR 0019: cần cho slice SongPack và thu âm, không cần 1–7)
- **G3:** **accepted 2026-08-06** — câu **1–10** theo khuyến nghị nguyên bản; câu **11–15** chốt trong chat cùng ngày (dialog số ô, xoá/đổi N + hình học giữ trái, tempo/time sig + phạm vi, BeatBox ẩn + *Edit beats*)
- **Revision 1 (G4 2026-08-07):** câu **16–18** — selection hạng nhất cho SystemBox + tách menu; resize 4 mép / move thân khi system đang chọn
- **Revision 2 (2026-08-07):** câu **1** — `beatSplits` là **N mốc nội tại** (kéo khớp nốt từng phách; **không** tính hai vạch nhịp mép ô). Mặc định tâm từng lát bằng. Wire web vẫn N−1 biên (đổi centres ↔ midpoints).
- **G4:** **pass (2026-08-07)** — gồm rev. 1; rev. 2 chờ xác nhận Edit beats (4 vạch trong ô 4/4)
- **Security Review:** **không cần**

> **Đóng slice:** G3 + build + rev. 1 + G4 pass. Rev. 2 (N vạch phách) đã vào code — xác nhận Edit beats trên máy. Suite measure_map xanh sau rev. 2.

---

## Vấn đề (Problem)

Sau 0052–0055, nhạc công đã tách đúng bài và mở đúng PageExtent — nhưng app **không biết ô nhịp nào nằm ở đâu trên giấy**. Không nhảy được tới ô 47, không có chỗ neo SyncMap, không có hình học để playhead chạy trên đúng dòng. Annotation đã có hệ toạ độ đúng (0–1, trang PDF tuyệt đối) nhưng chỉ lưu nét mực, không lưu cấu trúc bài.

Repo web đã có đúng mô hình này (`MeasureBox` + `beatSplits` trong `packages/shared/src/lib/daw/types.ts`). StageScore chưa có gì tương đương trên đĩa.

---

## Kết quả (Outcome)

Nhạc công mở một bài (Score con, hoặc Score một-bài), vào chế độ soạn MeasureMap, vẽ vài **SystemBox** (dòng nhạc), chia thành **MeasureBox**, kéo vạch chia **BeatBox** khi in không đều. Chép layout từ trang trước khi trang kế cùng bố cục. Map vài trang rồi thoát — app vẫn chịu được lỗ hổng (G2 câu 8).

Từ đó: gõ số ô nhịp → nhảy tới đúng chỗ trên trang. Người chưa map gì **không thấy khác biệt** ngoài một mục menu mới.

---

## Trong phạm vi (In scope)

### A. Mô hình và lưu trữ

- **Một Score ↔ đúng một MeasureMap.** Store theo idiom annotation: `standscore/measure_maps/<scoreId>.json`, payload mang `scoreId`.
- Ba tầng hình học (ADR 0019 quyết định 3a; tên **`SystemBox`** đã chốt G2 câu 7 — **cấm** dùng `RowBox` trong code/docs repo này):

| Tầng | Là gì | Soạn |
|---|---|---|
| **SystemBox** | Một dòng nhạc (*system*) trên trang | Vẽ hộp → dialog hỏi số MeasureBox; hoặc chép từ trang trước; **chọn khung** → resize/move / *Set measure count* / *Delete system* (rev. 1) |
| **MeasureBox** | Một ô nhịp trong SystemBox | Sinh từ dialog lúc tạo SystemBox; chia đều trong hộp; kéo vạch; chọn ô → xoá / tempo·time sig / *Edit beats* |
| **BeatBox** | Một phách trong MeasureBox | N mốc nội tại theo time signature (ẩn); *Edit beats* hiện **N** vạch để kéo khớp nốt (không tính hai vạch nhịp mép) |

- Hệ toạ độ: **0–1**, gốc góc trên-trái trang; **`pageNumber` 1-based tuyệt đối của PdfDocument** — cùng không gian với annotation / `PageOrderEntry.sourcePage`. Không quy ước tương đối theo PageExtent.
- Mỗi MeasureBox mang: `id`, `pageNumber`, `measureNumber` (số ô toàn bài, 1-based liên tục trong Score — G3 câu 2), `systemIndex`, `x/y/width/height`, `timeSignature?`, `tempo?` (mặc định ô đầu `4/4` + `120`, kế thừa ô trước; chỉ ghi khi đổi — câu 3), và **`beatSplits: number[]`** trên đĩa — **N mốc nội tại** vị trí từng phách (câu 1 / rev. 2; UI gọi BeatBox).
- Mỗi phần tử `beatSplits` = **vị trí trên giấy** của một phách (playhead / khớp nốt in), **không** phải thời lượng (ADR 0019 quyết định 3b). Thời lượng thuộc SyncMap (**0059**): tempo + time signature → `beatTimestamps`; kéo mốc không đổi timeline.
- **MeasureMap chưa đầy đủ được phép** (G2 câu 8): thiếu trang / thiếu ô / thiếu phách đều hợp lệ. Mọi đường đọc phải chịu lỗ hổng, không đòi bản đồ trọn vẹn.
- Vào **backup** cùng cây library (cùng loại annotation). Xoá Score → xoá file MeasureMap của `scoreId` ấy. Cascade xoá gốc → xoá MeasureMap mọi con + gốc.
- Doc comment trên mọi trường số trang: thuộc không gian **tờ giấy** (tuyệt đối).

### B. Phép dịch với repo web (ADR 0019 quyết định 6)

Round-trip không mất mát với:

| StageScore | Web |
|---|---|
| `MeasureBox` (trang, measureNumber, systemIndex, 0..1) | `MeasureBox` (`pageIndex`, …) |
| hình học phách | `beatSplits`: StageScore **N mốc nội tại**; web **N−1 biên** — dịch centres ↔ midpoints |
| SystemBox | gom nhóm theo `systemIndex` (web không có type riêng) |

Test thuần: encode → decode → bằng nhau. `noteEvents` / OMR-adjacent bên web **không** nhập slice này.

### C. Soạn trong PdfMode

- Lối vào: **ScoreMenu / `⋯` → *Measure map…*** (G3 câu 5) — không chiếm QuickBar.
- Vẽ chồng lên trang bằng cùng đường overlay annotation — **không** hệ zoom thứ hai.
- Thao tác: vẽ SystemBox → dialog số MeasureBox (câu 11); chỉnh vạch ô; **selection** `none` \| `measure` \| `system` loại trừ lẫn nhau (câu 16); chọn SystemBox (tap khung) → *Set measure count…* / *Delete system* / resize·move (câu 17–18); chọn MeasureBox → xoá ô / tempo·time sig + phạm vi / *Edit beats* (câu 12–15); **chép layout trang liền trước** một tap, chọn trang bất kỳ là lối phụ (câu 4).
- BeatBox mặc định **ẩn**; *Edit beats* chỉ hiện vạch ô đang chọn (câu 15).
- **Loại trừ lẫn nhau** với Draw mực (câu 7).
- All-pages gốc: không union map con; soạn trên gốc được phép nhưng IA nghiêng về piece (câu 8).
- Xoá hết map: có, confirm một lần (câu 9).

### D. Nhảy tới ô nhịp (để slice không phải hình-dạng-tầng)

- **Dialog số + xác nhận** (câu 6) → cuộn/lật tới trang và đưa ô vào tầm nhìn (highlight ngắn).
- Ô chưa map → báo không có, không crash.
- Không cần SyncMap / audio.

### E. `CONTEXT.md` (G1 lúc build, sau accept)

Thêm: **MeasureMap**, **SystemBox**, **MeasureBox**, **BeatBox**. Siết **SyncMap**: cho phép không gắn BackingTrack (chỉ metronome / thời gian nhạc) — chuẩn bị 0059, không implement SyncMap ở đây.

---

## Ngoài phạm vi (Out of scope)

- SyncMap tính từ MeasureMap / metronome theo tempo bài — **0059**
- Lật trang rảnh tay + chỉ báo vị trí — **0060**
- BackingTrack, Transport, gõ SyncMap, SongPack, thu âm — 0061+
- **OMR**: dò vạch nhịp / dòng kẻ từ ảnh trang — ADR 0006 / H6; ADR 0019 quyết định 3d **cấm**. Chỉ chép layout trang trước + map từng bài
- `noteEvents` / In-Score Note Editor bên web
- Union MeasureMap trên all-pages từ các con
- Nâng `flutter_soloud`, quyền mic, mạng, tiền
- Tab Packs / SongPack UI

---

## Thuật ngữ miền (Domain terms)

| Term | Ghi chú |
|---|---|
| **MeasureMap** | Hình học ô nhịp trên trang của **một** Score; không phải thời gian |
| **SystemBox** | Một *system* (dòng nhạc) trên trang — **không** gọi `RowBox` |
| **MeasureBox** | Ô nhịp; trùng tên/nghĩa với web |
| **BeatBox** | Phách trong ô; trên đĩa là `beatSplits` **N mốc nội tại** (rev. 2); UI mặc định ẩn (câu 15) |
| **PageExtent** / **Score** / **PdfDocument** | Đã có — MeasureMap neo theo trang tuyệt đối trong PageExtent của Score đang mở |

`MeasureAnchor` (ADR 0017) **không** dùng — bị rút bởi 0019.

---

## Câu hỏi G3 (G3 questions) — **đã trả lời 2026-08-06**

Orchestrator: câu **1–10** theo khuyến nghị; câu **11–15** chốt trong chat.

| # | Câu hỏi | Quyết định |
|---|---|---|
| 1 | **BeatBox lưu trên đĩa thế nào?** | **Rev. 2:** StageScore lưu **N mốc nội tại** (4/4 → **4** vạch trong ô, không tính hai vạch nhịp mép) để kéo khớp nốt từng phách; mặc định tâm lát bằng. Web wire vẫn N−1 biên. UI vẫn nói BeatBox. *(G3 đầu = N−1 như web — Orchestrator đảo ở G4.)* |
| 2 | **`measureNumber` đánh số thế nào?** | **Liên tục trong Score từ 1**, gán lại khi chèn/xoá ô |
| 3 | **Time signature / tempo mặc định ô đầu?** | **`4/4` và `120`**, kế thừa ô trước; chỉ ghi khi khác ô trước. Không đoán từ PDF. Đổi UI: câu 14 |
| 4 | **Chép layout?** | **Trang liền trước = một tap; chọn trang bất kỳ = lối phụ** |
| 5 | **Lối vào soạn?** | **ScoreMenu *Measure map…*** — không chiếm QuickBar |
| 6 | **Nhảy tới ô nhịp?** | **Dialog số + xác nhận** |
| 7 | **MeasureMap vs Draw mực?** | **Loại trừ lẫn nhau** |
| 8 | **Soạn trên Score gốc?** | **Cho phép; IA nghiêng về piece**; không union từ con |
| 9 | **Xoá hết MeasureMap?** | **Có**, confirm một lần |
| 10 | **Baseline test?** | Đo lại đầu chat build; kỳ vọng ~570 |
| 11 | **Dialog số MeasureBox khi tạo SystemBox?** | **Có.** Default phiên `4`; sticky theo lần xác nhận gần nhất; thoát soạn → về `4`; huỷ → bỏ SystemBox vừa vẽ; N ≥ `1` |
| 12 | **Xoá một MeasureBox?** | Chọn ô → Delete. **Ô liền trước mở rộng** (ô đầu → ô sau mở sang trái); không chia đều cả system; ô cuối system → xoá system |
| 13 | **Đổi số ô (không có hit SystemBox)?** | Ban đầu: từ ô đang chọn. **Rev. 1:** từ **SystemBox đang chọn** → *Set measure count…*. Giảm N: bỏ phải, ô phải mới mở tới mép. Tăng N: cắt đều ô phải nhất. Trái giữ nguyên |
| 14 | **Đổi tempo / time signature?** | Sheet sửa → **dialog phạm vi**: *This measure only* / *This system* / *This page* / *Rest of score* / *Next N…*. Override cả dải; đổi time sig → beatSplits đều từng ô trong dải |
| 15 | **BeatBox mặc định ẩn?** | **Ẩn.** *Edit beats* trên ô chọn → hiện/kéo **chỉ ô đó**; Done / chọn ô khác → ẩn. Không hiện mọi ô cùng lúc |
| 16 | **Select SystemBox?** | **Có** (rev. 1). Selection `none` \| `measure(id)` \| `system(page, systemIndex)`. Tap **khung** SystemBox → chọn system; tap nội thất MeasureBox → chọn measure; tap trống → clear. Long-press measure → select parent system. Không tự promote measure → system |
| 17 | **Menu theo selection?** | **Tách.** System: *Set measure count…*, *Delete system*. Measure: *Delete measure*, tempo/time sig, *Edit beats*. (Câu 13: *Set measure count* từ system đang chọn, không còn từ measure) |
| 18 | **Resize / move SystemBox?** | **Có** khi system đang chọn. 4 mép → resize (ngang scale tỉ lệ ô; dọc cùng y/height). Thân → move, clamp trang 0–1. Min size ~0.02×0.01. Mép khi chưa chọn system → select (không resize) |

---

## Ràng buộc kỹ thuật (Technical constraints)

- Persistence: `MeasureMapPersistence({ root, scoreId })` → `measure_maps/<scoreId>.json` — cùng pattern `AnnotationPersistence`.
- Overlay: Listener + CustomPainter trong page slot; toạ độ local → 0–1 qua `pageRect` như annotation (`page_annotation_overlay.dart`).
- Không async nặng trên đường vẽ một frame; load map lúc mở Score (cùng `_loadCurrentScorePrefs`).
- `systemIndex` bắt buộc trên mọi MeasureBox — SystemBox dựng lại bằng gom nhóm (ADR 0019 quyết định 3e).
- Replace PDF / đổi PageExtent: ô ngoài extent **giữ trên đĩa, không hiển thị** (cùng luật annotation 0052) — thu hẹp rồi nới lại không mất map.
- Mọi chuỗi UI qua `AppLocalizations` (0057). Domain term **MeasureMap / SystemBox / MeasureBox / BeatBox** giữ tiếng Anh trong mọi locale.
- Sticky số MeasureBox (G3 câu 11): state trong bộ nhớ của phiên soạn PdfMode — **không** ghi vào `measure_maps/<scoreId>.json` hay prefs app.

---

## Tiêu chí chấp nhận (Acceptance criteria)

**Người chưa map**

- [x] Không map → không highlight ô, nhảy tới ô báo trống/không có; UI soạn chỉ hiện khi vào mục menu — *code + unit + G4*

**Soạn**

- [x] Vẽ SystemBox → dialog số MeasureBox, default sticky phiên `4` — *logic + UI + G4*
- [x] Sticky default `3` trong phiên; thoát soạn → về `4` — *unit `MeasureMapSessionDefaults`*
- [x] Huỷ dialog lúc tạo → không commit SystemBox — *UI path*
- [x] Xoá MeasureBox: ô liền trước mở rộng / ô đầu → sau mở trái / ô cuối system → xoá system — *unit*
- [x] *Set measure count…* giữ trái, giảm/tăng N theo G3 #13 — *unit*
- [x] Tap khung → chọn SystemBox; bar chỉ *Set measure count* / *Delete system* — *UI + G4* (rev. 1)
- [x] Tap ô → chọn MeasureBox; bar không còn *Delete system* / *Set measure count* — *UI* (rev. 1)
- [x] Resize 4 mép / move thân khi system chọn; tỉ lệ ngang giữ; min size — *unit + UI + G4* (rev. 1)
- [x] BeatBox mặc định ẩn; *Edit beats* chỉ ô chọn — *UI*
- [x] beatSplits theo time signature; kéo khi Edit beats — *unit + UI*
- [x] Chép layout trang trước không dialog số ô — *unit + UI*
- [x] Map dở (thiếu trang) load/save không crash — *unit*
- [x] Tempo / time sig + dialog phạm vi — *store + UI + G4*

**Nhảy tới ô**

- [x] Ô đã map → nhảy trang + highlight ~1s — *UI + G4*
- [x] Ô chưa map → snackbar, không nhảy — *UI*

**Persistence / vòng đời**

- [x] Đóng mở lại Score → map còn — *persistence + load prefs*
- [x] Backup / restore giữ MeasureMap — *whole-tree ZIP + label `measure_maps`*
- [x] Xoá Score / cascade → `measure_maps/<id>.json` biến mất — *`score_overlays`*
- [x] Round-trip web `MeasureBox` + `beatSplits` — *unit*

**Ranh giới**

- [x] All-pages: không union map con; soạn theo Score đang mở — *store per scoreId*
- [x] Không đường OMR — *không có*
- [x] `flutter analyze` sạch; suite xanh (**595**, baseline **570**; +6 từ rev. 1); không dependency / quyền mới

> G4 thủ công: **pass** (Orchestrator 2026-08-07), gồm rev. 1.

---

## Ghi chú UX (UX notes)

- **Tạo SystemBox → dialog số MeasureBox** (G3 câu 11): default sticky trong phiên soạn, khởi điểm `4`. Field số pre-filled và chọn sẵn để sửa bằng bàn phím số ngay. Chia đều trong hộp sau khi xác nhận; kéo vạch là đường sửa chỗ in không đều (ADR 0019 quyết định 3).
- **Select SystemBox** (rev. 1): mọi system vẽ khung mỏng trong edit mode; khung đậm khi đang chọn. Tap khung = chọn dòng (menu system + resize/move). Tap ô = chọn ô (menu measure). Long-press ô = chọn system chứa nó.
- **Resize / move** (rev. 1): chỉ khi system đang chọn — kéo mép hoặc thân. Chưa chọn mà chạm mép → chỉ select.
- **BeatBox** (G3 câu 15 / rev. 2): mặc định ẩn. *Edit beats* trên ô đang chọn → hiện **N** mốc nội tại (4/4 → 4 vạch, không tính hai vạch nhịp mép) để kéo khớp nốt từng phách; thoát thì ẩn.
- Empty state chế độ soạn: một câu (*vẽ dòng nhạc — app sẽ hỏi bao nhiêu ô*) + nút chép trang trước nếu trang trước đã có map.
- Confirm trước khi xoá cả map hoặc xoá system đang chứa nhiều ô (lối *Delete system*, khác với xoá từng ô).
- Nhảy tới ô: highlight tắt sau ~1s hoặc tap — không để khung vĩnh viễn đè nốt.

---

## Kế hoạch kiểm thử (Test plan)

**Automated**

- `measure_map_model_test.dart` — JSON round-trip; `beatSplits` mặc định theo time signature; kế thừa tempo/timeSig; measureNumber gán lại khi chèn/xoá
- `measure_map_web_roundtrip_test.dart` — encode/decode web: N mốc ↔ N−1 biên (centres ↔ midpoints); fixture JSON, không cần repo web trong CI
- `measure_map_persistence_test.dart` — load/save theo scoreId; xoá theo scoreId
- `measure_map_incomplete_test.dart` — thiếu trang giữa vẫn load; jump chỉ tới ô có mặt
- `measure_map_extent_test.dart` — ô ngoài PageExtent không hiển thị, còn trên đĩa
- Widget/logic: chia đều SystemBox → N MeasureBox; kéo vạch cập nhật tỉ lệ; sticky default số ô trong phiên soạn (`4` → user chọn `3` → lần sau `3`; reset khi thoát chế độ soạn)
- `measure_map_selection_test.dart` — hit khung/mép SystemBox; selection helpers
- resize/move SystemBox — tỉ lệ ngang; clamp trang; min size (trong `measure_map_model_test.dart`)

**Manual (G4)**

1. Score chưa map — nhảy tới ô không phá gì.
2. Map 2–3 trang một etude: vẽ system, chia ô, sửa một ô rộng, chép trang sau, nhảy tới ô giữa bài.
3. Map trên piece; mở full score gốc — không thấy map của piece (và ngược lại nếu gốc có map riêng).
4. Backup → xoá app data giả → restore → map còn.
5. (Orchestrator) cảm nhận: có đủ mượt để **người lạ** map một bài bán được, hay còn chỗ thô phải sửa trước SongPack.
