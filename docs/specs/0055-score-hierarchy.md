# 0055 — Score gốc chứa Score con; Library một hàng / một tệp

- **Status:** accepted (G3 2026-08-05; **revision 1** 2026-08-06 — Edit pieces)
- **Type:** feature
- **Horizon:** không thuộc H5 trực tiếp. Slice này là **hệ quả G4 của 0054** (Library bí bách khi hàng tiêu đề + mọi bài luôn mở) và viết lại UI Library theo ADR 0019 quyết định 11 **revision 6**. Không chạm audio, không chạm mạng, không chạm tiền
- **Owner (human):** Orchestrator
- **Depends on ADRs:** **0019** (`accepted` G2 — **quyết định 11, viết lại ở revision 6**), 0005, 0008, 0013 (tier), 0015 (ngôn ngữ), 0016 (mô hình — **chat build riêng sau G3**)
- **Depends on Specs:** **0052** (`PdfDocument`, `PageExtent`, `splitScore`, annotation theo `scoreId`), **0053** (search/filter hình dạng; chiều nguồn **gỡ UI**), **0054** (tên sách, resplit, nhóm phẳng — **UI nhóm bị thay**), 0021 (Label filter), 0023 (sort), 0028 (xoá), 0024 (Replace PDF)
- **Tier:** **M** — thêm `Score.parentId` nullable, di trú idempotent nhẹ (`formatVersion` giữ `2`), đổi Library + một màn hình drill-in + luật annotation all-pages. Không SDK, không quyền, không mạng. G3 và G4; không cần ADR mới (revision 6 đã ghi)
- **G3:** **accepted 2026-08-05** — 12/12 câu theo khuyến nghị nguyên bản. **Revision 1 (2026-08-06)** thêm **Edit pieces** (phạm vi **G**) và ba câu G3 mới (13–15)
- **Security Review:** **không cần**

> **Sinh từ G4 cảm nhận của 0054.** Nhóm phẳng luôn mở đúng về dữ liệu nhưng bí bách trên máy thật. Orchestrator chốt: Library một hàng ứng với một tệp (Score gốc); bấm vào mới thấy Score con; vẫn mở được cả PDF trên gốc; Setlist nhận gốc hoặc con. **Không đẻ term miền `Piece`** — con là Score; *piece* chỉ UI copy.

> **Revision 1 — Edit pieces.** Bản gốc chốt resplit chạy trên **con** (câu 10) và không nói gì về việc vẽ lại ranh giới của **cả cuốn** sau khi đã tách. Hệ quả là một ngõ cụt: `_canSplit` giấu *Split into pieces…* ngay khi gốc có con, nên tách sai một lần là không có đường quay lại — chỉ còn cách sửa từng bài một. Revision này mở đường ấy. Nó **không** đảo câu 10: Edit pieces vẫn sinh ra anh em dưới cùng một gốc, cây vẫn một tầng.

---

## Vấn đề (Problem)

Sau 0054, một tuyển tập 28 bài là một hàng tiêu đề + 28 `ListTile` đầy đủ luôn hiện. Nhạc công không muốn cuộn hết tường hàng để tìm một tệp khác. Đồng thời họ muốn **một hàng trông như Score** (thumbnail trang 1, mở được cả cuốn, vào Setlist được) — đúng đề nghị từng bị bác một nửa ở 0054, nay nhận đủ vì đã có luật lớp phủ (mực gốc ≠ mực con) để không nợ MeasureMap/SongPack một cách mù quáng.

### Dữ kiện repo ràng buộc thiết kế

1. Annotation / PageOrder / Bookmark đã **theo `scoreId`** (`annotations/<scoreId>.json`). Gốc và con = hai store — luật all-pages phải nói rõ, không giả định gộp.
2. `splitScore` hôm nay biến Score bị tách thành bài đầu (giữ `id`) — **đảo**: giữ gốc `pageExtent: null`, con mới mang `parentId`.
3. `buildLibraryRows` / `BookHeaderRow` (0054) là UI bị thay; logic sort key của nhóm vẫn hữu ích cho **gốc có con**.
4. Chiều lọc nguồn 0053 trùng drill-in — **gỡ UI**, không giữ hai lối.

---

## Kết quả (Outcome)

Nhạc công mở Library thấy **một hàng / một PDF** (hoặc một hàng / một Score một-bài). Bấm *Chopin Etudes* → danh sách 28 bài; *Open full score* → PdfMode cả tệp. Vẽ trên all-pages (mặc định) chỉ vào mực gốc; bật *Show piece notes* thì thấy mực các bài và **không vẽ được**. Setlist thêm được cả cuốn hoặc một bài. Người chưa tách gì **không thấy khác biệt**.

---

## Trong phạm vi (In scope)

**A. Model**

- `Score.parentId` (`String?`); JSON; helpers gốc / con của gốc.
- Một tầng: con không có con. Resplit con → N anh em dưới cùng gốc.
- `splitScore` giữ/tạo gốc (`pageExtent: null`, `title` = tên sách); con mới.
- Migration idempotent: ≥ 2 Score cùng `pdfDocumentId` không `parentId` → tạo gốc (`title` = `displayName`, `createdAt` từ `importedAt` hoặc `min` con), gán `parentId`. Chạy lúc mở library + sau restore.
- Đổi tên sách trên UI = rename **Score gốc** (đồng bộ `PdfDocument.title` nếu còn dùng làm fallback).

**B. Library**

- Mặc định list chỉ `parentId == null`. Bỏ hàng tiêu đề nhóm phẳng 0054 trên đường vẽ chính.
- Gốc có con: tap → màn hình danh sách con (thứ tự trang); `⋯` / nút *Open full score*.
- Gốc không con / Score một-bài: tap → PdfMode như hôm nay.
- Thumbnail gốc = trang 1; con = `firstAbsolutePage`.
- Xoá gốc: confirm số con → cascade. Xoá con: như 0052; gốc không con vẫn hợp lệ.

**C. Search / sort / Label filter** — xem luật đã chốt ở plan / G3.

**D. Source filter UI** — gỡ chip, mục sheet, *Show all pieces of…*.

**E. All-pages annotation**

| *Show piece notes* | Hiện | Draw |
|---|---|---|
| Tắt (mặc định) | Chỉ mực gốc | Bật → ghi gốc |
| Bật | Gốc + union mực con theo trang tuyệt đối | Tắt |

Không ghi store con từ all-pages. Toggle **không persist** (session; mỗi lần mở về tắt).

**F. Setlist**

- Schema id không đổi. Picker: chọn gốc hoặc duyệt vào chọn con.

**G. Edit pieces** *(revision 1, 2026-08-06)*

- Lối vào: `⋯` của hàng gốc **có con**, và menu app bar của màn hình Pieces — nơi các bài thật sự sống. Cùng lượt, `⋯` nhận thêm mục *Pieces…* cho khớp với cử chỉ tap (tap gốc có con đã vào Pieces từ phạm vi B, menu thì chưa có lối nào ngoài *Open full score*).
- Dùng lại `SplitScoreScreen` chứ không dựng màn hình thứ hai: thêm `initialMarks` (một mark / một bài hiện tại, `firstAbsolutePage` + tên) và `appBarTitle`. Lưới mở ra với ranh giới **hôm nay** đã đánh dấu; nhạc công bỏ dấu, thêm dấu, đổi tên tự do.
- `ScoreLibrary.editPieces` **thay** cả bộ con bằng một con / một mark — ngược với `splitScore`, thứ chỉ biết **thêm**. Score gốc (`pageExtent: null`) không bị đụng.
- `planPieceResplit` khớp con cũ với extent mới theo **đúng cặp `(firstPage, lastPage)`** — không theo tên, không theo vị trí — nên phạm vi trang còn nguyên thì `id` còn nguyên, và cùng với nó là annotation, bookmark, jump link, Label, chỗ trong mọi Setlist.
- Bài không còn phạm vi nào khớp thì **bị xoá**, và được hỏi trước nếu nó **không rỗng** (có mực, bookmark, jump link, Label, hoặc đang nằm trong Setlist). Rỗng thì xoá im lặng — không có gì để mất thì không có gì để hỏi.
- Dọn dẹp chia đúng như `deleteScore` đang chia: `editPieces` xoá overlay theo `scoreId`; page scale handover, Label, Setlist, thumbnail cache là việc của caller.
- Vẫn **một tầng**: kết quả là anh em dưới cùng gốc.

---

## Ngoài phạm vi (Out of scope)

- Cây sâu hơn một tầng.
- MeasureMap / SyncMap / BackingTrack / SongPack (neo theo Score đang mở — ADR 0019).
- Union MeasureMap trên all-pages.
- Quảng cáo 0051.
- `formatVersion` → 3.

---

## Thuật ngữ miền (Domain terms)

**Không term mới `Piece`.** Mở rộng **Score** trong `CONTEXT.md`: có thể chứa Score con; *piece* chỉ UI / `_Avoid_`. `PdfDocument` vẫn không phải Score; hàng Library của cuốn đã tách là **Score gốc**, không phải hàng `PdfDocument`.

---

## Câu hỏi G3 (G3 questions) — **đã trả lời 2026-08-05**

Orchestrator accept nguyên bản — cả 12 câu theo khuyến nghị.

| # | Câu hỏi | Quyết định |
|---|---|---|
| 1 | **Tap gốc có con: luôn vào danh sách con, hay hỏi / nhớ lần mở trước?** | **Luôn danh sách con.** *Open full score* là lối thứ hai tường minh |
| 2 | **Toggle *Show piece notes*: persist theo Score gốc?** | **Không** — session only, mặc định tắt mỗi lần mở all-pages |
| 3 | **Khi hiện cả mực gốc và mực con: phân biệt màu?** | **Không** — một lớp nhìn; phân biệt bằng chỗ Draw bị tắt |
| 4 | **Search khớp con: hiện hàng con (`in <gốc>`), hay chỉ gốc?** | **Hàng con** — tap mở PdfMode con. Khớp cả hai thì hiện cả hai |
| 5 | **Label filter: gốc không khớp nhưng có con khớp?** | **Chỉ hiện các con khớp**, không hàng gốc trống |
| 6 | **`Last viewed` của gốc có con?** | **`max(root, children)`** |
| 7 | **`Created` của gốc sau migration?** | **`PdfDocument.importedAt`** |
| 8 | **Gỡ hết UI lọc nguồn 0053 trong slice này?** | **Có** |
| 9 | **Xoá hết con: tự xoá gốc hay giữ gốc cả tệp?** | **Giữ gốc** |
| 10 | **Resplit: vẫn một tầng (anh em), hay cho phép con có con?** | **Một tầng** |
| 11 | **Nhãn UI cho danh sách con và toggle?** | ***Pieces*** / ***Show piece notes*** |
| 12 | **Baseline test trước build?** | Đo lại đầu chat build; kỳ vọng ~545 trước slice |

### Revision 1 — ba câu của Edit pieces (**chốt 2026-08-06 trong lúc build, ghi lại sau**)

| # | Câu hỏi | Quyết định |
|---|---|---|
| 13 | **Edit pieces đi qua *Split into pieces…* (nới `_canSplit`), hay là lối riêng?** | **Lối riêng.** `_canSplit` giữ nguyên. Một nút làm hai việc thì không viết được lời xác nhận cho nó: tách lần đầu **không xoá gì**, còn vẽ lại **xoá được cả một bài đầy mực** |
| 14 | **Khớp bài cũ với mark mới theo gì?** | **Đúng cặp `(firstPage, lastPage)`** — không theo tên, không theo vị trí. Khớp theo tên thì đổi tên là mất dữ liệu; khớp theo vị trí thì chèn một dấu ở đầu sách làm **mọi** bài trượt một bậc và mọi `id` đổi chủ |
| 15 | **Bài không còn phạm vi nào khớp thì sao?** | **Xoá**, có hỏi trước nếu bài ấy không rỗng; rỗng thì xoá im lặng. File annotation đọc không được **tính là có dữ liệu** — cảnh báo thừa rẻ hơn xoá nhầm |

---

## Ràng buộc kỹ thuật (Technical constraints)

- Một định nghĩa gốc: `parentId == null`. Hai định nghĩa là hai nơi bất đồng.
- Migration thuần trên manifest (+ tạo Score), không move file PDF.
- All-pages: đọc thêm store con chỉ khi toggle bật; đường vẽ chỉ gọi persistence của gốc.
- `buildLibraryRows` nhóm phẳng: ngừng dùng trên Library chính (có thể xoá hoặc giữ cho test migration tạm).
- Doc comment `Score` / `PdfDocument` sửa cùng lượt với `CONTEXT.md`.

---

## Tiêu chí chấp nhận (Acceptance criteria)

**Người chưa tách**

- [x] Thư viện toàn Score một-bài: không drill-in, không toggle, UI như trước 0054 grouping (một hàng / một Score)

**Hierarchy + Library**

- [x] Tách → một hàng gốc; không 28 hàng trên tab Scores
- [x] Tap gốc → đúng N con theo thứ tự trang
- [x] *Open full score* → PdfMode đủ trang tệp trên id gốc
- [x] Tap con → PdfMode đúng PageExtent
- [x] Migration thư viện 0054 phẳng → một gốc + con; `formatVersion` vẫn `2`
- [x] Xoá gốc confirm số con; PDF theo refcount

**Search / filter / sort**

- [x] Search tên bài → hàng con `in <gốc>`
- [x] Label trên một con → filter hiện con đó, không gốc trống
- [x] Không còn chip/mục lọc nguồn / *Show all pieces of…*

**All-pages annotation**

- [x] Mặc định: không thấy mực con; Draw ghi gốc; mở con không thấy mực gốc vừa vẽ — logic + wiring; G4 trên máy thật
- [x] Bật toggle: thấy mực con; Draw tắt; tắt toggle → Draw lại được — logic + wiring; G4 trên máy thật
- [x] Đóng PdfMode mở lại: toggle về tắt (session-only, không persist)

**Setlist**

- [x] Thêm gốc và thêm một con — picker drill-in; phát đúng phạm vi từng cái (SetlistSession đã theo scoreId)

**Edit pieces** *(revision 1)*

- [x] `⋯` của gốc có con hiện *Pieces…* và *Edit pieces…*; gốc không con hiện *Split into pieces…* như cũ
- [x] Lưới mở ra với ranh giới hiện tại đã đánh dấu, tên bài giữ nguyên
- [x] Bài giữ đúng phạm vi trang → giữ `id`, giữ annotation / bookmark / jump link / Label / chỗ trong Setlist
- [x] Đổi tên hoặc đảo thứ tự mark không làm bài nào mất dữ liệu
- [x] Bài biến mất mà không rỗng → hỏi, gọi tên nó, huỷ được; rỗng → không hỏi
- [x] Bài bị xoá: overlay, page scale, Label, Setlist, thumbnail cache đều được dọn
- [ ] G4 trên máy thật: tách sai một cuốn rồi vẽ lại, kiểm mực của bài giữ nguyên vẫn còn

**Bản dựng**

- [x] `flutter analyze` sạch; suite xanh (**554**; **559** sau revision 1); không dependency / quyền mới

---

## Kế hoạch kiểm thử (Test plan)

**Automated**

- `score_parent_test.dart` — JSON `parentId`; helpers
- `library_hierarchy_migration_test.dart` — gom phẳng → gốc+con; idempotent
- `split_keeps_root_test.dart` — id gốc ổn định; con có `parentId`
- `library_roots_only_test.dart` — list mặc định; search/filter widen
- `all_pages_annotation_toggle_test.dart` — (logic thuần hoặc widget) mặc định / bật / không ghi con
- `setlist_root_or_child_test.dart` — nếu picker test được
- Sửa / gỡ test phụ thuộc `BookHeaderRow` và source filter UI
- `piece_resplit_test.dart` — khớp theo phạm vi trang; giữ `id`; đổi tên / đảo thứ tự không mất dữ liệu; `removedIds` đúng; < 2 mark là no-op *(revision 1)*
- `library_edit_pieces_test.dart` — lưới gieo sẵn ranh giới hiện tại; hỏi trước khi xoá bài không rỗng, huỷ được; dọn Label / Setlist / thumbnail cho bài bị xoá *(revision 1)*

**Manual (G4)**

1. Thư viện chưa tách — không khác.
2. Tuyển tập 28 bài — một hàng; drill-in; mở full; vẽ gốc; mở con không thấy; bật toggle thấy mực con, không vẽ được.
3. Search một tên bài; Label một bài; Setlist gốc + một con; xoá gốc có confirm; khởi động lại tên/cây còn.
4. *(revision 1)* Vẽ một bài, rồi *Edit pieces*: bỏ một ranh giới → hỏi đúng tên bài sắp mất; huỷ thì không mất gì; tiếp tục thì bài giữ nguyên phạm vi vẫn còn mực.
