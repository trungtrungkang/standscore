# 0058 — MeasureMap: vẽ SystemBox → MeasureBox → BeatBox; nhảy tới ô nhịp

- **Status:** proposed
- **Type:** feature
- **Horizon:** H5 (ADR 0019 quyết định 1 — chỉ cần biết *chỗ nào trên trang*; không cần biết *nốt nào*)
- **Owner (human):** Orchestrator
- **Depends on ADRs:** **0019** (`accepted` — quyết định 3, 3a–3e, 6, 11 lớp phủ; revision 7 đổi số), 0005, 0006 (**không mở** OMR), 0008 (H3/H4 vẫn đóng), 0013 (tier), 0014 (phép dịch MeasureBox ↔ web), 0015, 0016
- **Depends on Specs:** **0052** (PageExtent, số trang tuyệt đối), **0055** (Score gốc/con; lớp phủ theo `scoreId`; all-pages không union MeasureMap từ con), 0017–0019 (lớp vẽ + hệ toạ độ 0–1), 0027 (`LibraryBackup` — MeasureMap phải vào backup), 0035 / 0043 (ScoreMenu IA — lối vào soạn)
- **Tier:** **L** — dữ liệu tốn công người nhất app từng lưu; công cụ soạn là trần chất lượng cho mọi SongPack sau này (ADR 0019 quyết định 7b); persistence mới theo `scoreId`; chạm sâu PdfMode. Không SDK mới, không quyền mới, không byte rời máy → **Security Review không cần** (ADR 0019: cần cho slice SongPack và thu âm, không cần 1–7)
- **G3:** chờ Orchestrator
- **Security Review:** **không cần**

> **Slice 5 của ADR 0019.** Số Spec là `0058` sau revision 7 (0056/0057 bị tiêu thụ bởi Half Page và localization, ngoài ADR). Không mở SyncMap tính ra, không mở metronome theo bài, không mở Transport — những thứ ấy là 0059+. Slice này **tự đứng** trước mắt nhạc công nhờ **nhảy tới ô nhịp**: soạn xong vài trang là dùng được ngay, không phải chờ slice kế.

> **Chuẩn chất lượng:** đây không còn là "đủ để nhạc công map bài của mình" — tác giả bên thứ ba dựng pack **bằng chính công cụ này** (ADR 0019 quyết định 7b + G2 câu 6). Spec phải đặt trần đó từ đầu.

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
| **SystemBox** | Một dòng nhạc (*system*) trên trang | Vẽ hộp; hoặc chép từ trang trước |
| **MeasureBox** | Một ô nhịp trong SystemBox | Chia SystemBox; chia đều mặc định; kéo vạch |
| **BeatBox** | Một phách trong MeasureBox | Chia đều theo time signature; kéo khi in lệch |

- Hệ toạ độ: **0–1**, gốc góc trên-trái trang; **`pageNumber` 1-based tuyệt đối của PdfDocument** — cùng không gian với annotation / `PageOrderEntry.sourcePage`. Không quy ước tương đối theo PageExtent.
- Mỗi MeasureBox mang: `id`, `pageNumber`, `measureNumber` (số ô toàn bài, 1-based liên tục trong Score), `systemIndex`, `x/y/width/height`, `timeSignature?`, `tempo?` (kế thừa ô trước; chỉ ghi khi đổi), và hình học phách (xem G3 câu 1).
- Chiều rộng BeatBox / vị trí vạch chia = **vị trí playhead trên giấy**, **không** phải thời lượng (ADR 0019 quyết định 3b). Thời lượng thuộc SyncMap (slice sau).
- **MeasureMap chưa đầy đủ được phép** (G2 câu 8): thiếu trang / thiếu ô / thiếu phách đều hợp lệ. Mọi đường đọc phải chịu lỗ hổng, không đòi bản đồ trọn vẹn.
- Vào **backup** cùng cây library (cùng loại annotation). Xoá Score → xoá file MeasureMap của `scoreId` ấy. Cascade xoá gốc → xoá MeasureMap mọi con + gốc.
- Doc comment trên mọi trường số trang: thuộc không gian **tờ giấy** (tuyệt đối).

### B. Phép dịch với repo web (ADR 0019 quyết định 6)

Round-trip không mất mát với:

| StageScore | Web |
|---|---|
| `MeasureBox` (trang, measureNumber, systemIndex, 0..1) | `MeasureBox` (`pageIndex`, …) |
| hình học phách | `beatSplits` (`number[]`, N−1 tỉ lệ nội tại hộp cho N phách) |
| SystemBox | gom nhóm theo `systemIndex` (web không có type riêng) |

Test thuần: encode → decode → bằng nhau. `noteEvents` / OMR-adjacent bên web **không** nhập slice này.

### C. Soạn trong PdfMode

- Lối vào: mục trong ScoreMenu / `⋯` (không chiếm slot QuickBar Draw/Metronome/Bookmarks trừ khi G3 quyết khác).
- Vẽ chồng lên trang bằng cùng đường overlay annotation (`PageAnnotationOverlay` / page slot) — **không** hệ zoom thứ hai.
- Thao tác tối thiểu: vẽ SystemBox; chia đều thành N MeasureBox; chỉnh vạch; chia BeatBox theo time signature; kéo vạch phách; xoá hộp; **chép layout từ trang trước** (cùng số system, cùng vị trí tương đối; sửa sau).
- Mutual exclusion với Draw mực (G3 câu 7).
- Trên **all-pages gốc**: **không** soạn MeasureMap của con; không union MeasureMap con (0055). Soạn trên gốc = MeasureMap của chính gốc (tuỳ chọn; không bắt buộc — ADR 0019: luyện + SyncMap sống ở con).

### D. Nhảy tới ô nhịp (để slice không phải hình-dạng-tầng)

- UI: nhập / chọn `measureNumber` đã có trong map → PdfMode cuộn/lật tới trang và đưa ô đó vào tầm nhìn (highlight ngắn).
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
| **BeatBox** | Phách trong ô; trên đĩa có thể là `beatSplits` (G3 câu 1) |
| **PageExtent** / **Score** / **PdfDocument** | Đã có — MeasureMap neo theo trang tuyệt đối trong PageExtent của Score đang mở |

`MeasureAnchor` (ADR 0017) **không** dùng — bị rút bởi 0019.

---

## Câu hỏi G3 (G3 questions)

| # | Câu hỏi | Khuyến nghị |
|---|---|---|
| 1 | **BeatBox lưu trên đĩa thế nào?** Object riêng, hay `beatSplits: number[]` như web (N−1 tỉ lệ trong hộp)? | **`beatSplits` như web.** UI vẫn nói BeatBox. Trùng dữ liệu với web = round-trip gần như miễn phí; object riêng buộc phép dịch và hai nguồn sự thật |
| 2 | **`measureNumber` đánh số thế nào?** Liên tục trong Score từ 1; theo trang; hay cho sửa tay từng ô? | **Liên tục trong Score từ 1**, gán lại khi chèn/xoá ô. Sửa tay từng ô = nguồn lệch với SyncMap sau này |
| 3 | **Time signature / tempo mặc định khi tạo MeasureBox đầu?** | **`4/4` và `120`**, kế thừa ô trước; sheet nhỏ để đổi tại ô đang chọn. Không đoán từ PDF (OMR) |
| 4 | **Chép layout: chỉ trang liền trước, hay chọn trang bất kỳ trong bài?** | **Trang liền trước là một tap; chọn trang bất kỳ là lối phụ** (lưới/`PdfPageGrid` đã có). Ca phổ biến là trang kế cùng bố cục |
| 5 | **Lối vào soạn MeasureMap?** | **Mục ScoreMenu** (*Measure map…*), bật chế độ soạn trong PdfMode — không chiếm QuickBar slot 3 trừ khi G4 thấy thiếu |
| 6 | **Nhảy tới ô nhịp: UI nào?** | **Dialog số + xác nhận**; nếu map có tên/danh sách ngắn có thể thêm list sau. Không dựng màn hình thứ hai trong slice này |
| 7 | **MeasureMap mode vs Draw mực?** | **Loại trừ lẫn nhau** — bật cái này tắt cái kia. Hai lớp pointer trên cùng trang là nguồn lỗi đã biết |
| 8 | **Score gốc (all-pages) có soạn MeasureMap không?** | **Cho phép nhưng không khuyến khích trong IA** — mục soạn hiện bình thường trên mọi Score; copy/empty state nói rõ luyện từng bài nên map trên **piece**. Không union từ con |
| 9 | **Xoá hết MeasureMap của một Score?** | **Có**, trong chế độ soạn, confirm một lần — dữ liệu tốn buổi chiều |
| 10 | **Baseline test trước build?** | Đo lại đầu chat build; kỳ vọng ~570 trước slice |

---

## Ràng buộc kỹ thuật (Technical constraints)

- Persistence: `MeasureMapPersistence({ root, scoreId })` → `measure_maps/<scoreId>.json` — cùng pattern `AnnotationPersistence`.
- Overlay: Listener + CustomPainter trong page slot; toạ độ local → 0–1 qua `pageRect` như annotation (`page_annotation_overlay.dart`).
- Không async nặng trên đường vẽ một frame; load map lúc mở Score (cùng `_loadCurrentScorePrefs`).
- `systemIndex` bắt buộc trên mọi MeasureBox — SystemBox dựng lại bằng gom nhóm (ADR 0019 quyết định 3e).
- Replace PDF / đổi PageExtent: ô ngoài extent **giữ trên đĩa, không hiển thị** (cùng luật annotation 0052) — thu hẹp rồi nới lại không mất map.
- Mọi chuỗi UI qua `AppLocalizations` (0057). Domain term **MeasureMap / SystemBox / MeasureBox / BeatBox** giữ tiếng Anh trong mọi locale.
- Comment code tiếng Anh.

---

## Tiêu chí chấp nhận (Acceptance criteria)

**Người chưa map**

- [ ] Không map → không highlight ô, nhảy tới ô báo trống/không có; UI soạn chỉ hiện khi vào mục menu

**Soạn**

- [ ] Vẽ SystemBox trên trang thuộc PageExtent; chia thành MeasureBox đều; kéo vạch đổi tỉ lệ
- [ ] Chia BeatBox theo time signature; kéo vạch phách; width = vị trí, không đổi “thời lượng” nào trên đĩa thời gian (chưa có SyncMap)
- [ ] Chép layout trang trước → trang hiện tại có cùng số system/ô (sửa được)
- [ ] Map dở (thiếu trang giữa) lưu và mở lại không mất, không crash
- [ ] Time signature / tempo đổi tại một ô và kế thừa các ô sau cho tới lần đổi kế

**Nhảy tới ô**

- [ ] Nhập `measureNumber` đã map → tới đúng trang và ô trong tầm nhìn
- [ ] Ô chưa map → thông báo rõ, không nhảy lung tung

**Persistence / vòng đời**

- [ ] Đóng mở lại Score → map còn
- [ ] Backup / restore giữ MeasureMap
- [ ] Xoá Score / cascade gốc → file `measure_maps/<id>.json` biến mất
- [ ] Round-trip test với hình dạng web `MeasureBox` + `beatSplits` xanh

**Ranh giới**

- [ ] All-pages: không hiện/union MeasureMap của con; soạn chỉ ghi map của Score đang mở
- [ ] Không có đường nào dò vạch từ ảnh trang
- [ ] `flutter analyze` sạch; suite xanh; không dependency / quyền mới

---

## Ghi chú UX (UX notes)

- Chia đều là mặc định; kéo vạch là đường sửa — đúng chỗ “không đều” mới tốn công (ADR 0019 quyết định 3).
- Empty state chế độ soạn: một câu (*vẽ dòng nhạc, rồi chia ô*) + nút chép trang trước nếu trang trước đã có map.
- Confirm trước khi xoá cả map hoặc xoá system đang chứa nhiều ô.
- Nhảy tới ô: highlight tắt sau ~1s hoặc tap — không để khung vĩnh viễn đè nốt.

---

## Kế hoạch kiểm thử (Test plan)

**Automated**

- `measure_map_model_test.dart` — JSON round-trip; `beatSplits` mặc định theo time signature; kế thừa tempo/timeSig; measureNumber gán lại khi chèn/xoá
- `measure_map_web_roundtrip_test.dart` — encode/decode khớp field web (không cần repo web trong CI — fixture JSON)
- `measure_map_persistence_test.dart` — load/save theo scoreId; xoá theo scoreId
- `measure_map_incomplete_test.dart` — thiếu trang giữa vẫn load; jump chỉ tới ô có mặt
- `measure_map_extent_test.dart` — ô ngoài PageExtent không hiển thị, còn trên đĩa
- Widget/logic: chia đều SystemBox → N MeasureBox; kéo vạch cập nhật tỉ lệ

**Manual (G4)**

1. Score chưa map — nhảy tới ô không phá gì.
2. Map 2–3 trang một etude: vẽ system, chia ô, sửa một ô rộng, chép trang sau, nhảy tới ô giữa bài.
3. Map trên piece; mở full score gốc — không thấy map của piece (và ngược lại nếu gốc có map riêng).
4. Backup → xoá app data giả → restore → map còn.
5. (Orchestrator) cảm nhận: có đủ mượt để **người lạ** map một bài bán được, hay còn chỗ thô phải sửa trước SongPack.
