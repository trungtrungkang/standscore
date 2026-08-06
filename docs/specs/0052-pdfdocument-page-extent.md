# 0052 — Một PDF, nhiều Score: `PdfDocument` tách khỏi `Score`

- **Status:** accepted
- **Type:** feature
- **Horizon:** không thuộc H5. Slice này là **điều kiện** của cả nhóm H5 (ADR 0019, slice 1) nhưng bản thân nó không chạm audio, không chạm mạng, không chạm tiền — nó chỉ sửa chỗ code đã trôi khỏi glossary
- **Owner (human):** Orchestrator
- **Depends on ADRs:** **0019 (**`accepted` **G2 2026-08-05)**, 0005 (Flutter shell), 0008 (không mở SmartMode/Transport/BackingTrack/OMR), 0010 (chính tả brand), 0013 (tier), 0014 (hai bounded context), 0015 (ngôn ngữ), 0016 (mô hình)
- **Depends on Specs:** 0002 (import / open), 0010 (Bookmark), 0011 (PageOrder), 0016 (JumpLink), 0017–0019 (lớp annotation và hệ toạ độ), 0021 (Label filter), 0023 (sort), 0024 (**Replace PDF — phải đổi**), 0027 + 0050 (`LibraryBackup`), 0028 (**Delete — phải đổi**), 0029 (share-in), 0031 (page scale — **phải đổi**), 0040 (Library row, `pageCount`, thumbnail — **phải đổi**), 0048 (`hold` — lưới trang, đọc lại trước khi vẽ)
- **Tier:** **L** — di trú dữ liệu trên thư viện thật của nhạc công, `formatVersion` bump, và **bốn** đường đã ship có thể mất dữ liệu bị sửa cùng lúc
- **G3:** **accepted 2026-08-05** (Orchestrator), **cả 10 câu theo khuyến nghị như bản nháp**; **revision 1 cùng ngày** — hai câu **11–12** mở thêm sau manual test G4 và chốt ngay trong lượt, cả hai theo khuyến nghị
- **Security Review:** **không cần** cho slice này (ADR 0019, Hệ quả: cần cho slice 8 và 11, không cần 1–4). Không byte nào rời máy, không SDK mới, không quyền mới

> **Được build: ADR 0019 accepted ở G2 ngày 2026-08-05 (9/9 câu chốt), Spec này accepted ở G3 cùng ngày.** Không còn cổng nào chặn. Security Review không cần cho slice này.
>
> Câu hỏi G3 số 1 được accept **thu hẹp lời của quyết định 2 trong ADR 0019** — ADR đã nhận sửa ở **revision 3** cùng ngày, nên hai tài liệu không còn nói khác nhau. Nếu đọc bản ADR chưa có revision 3, tin Spec này.
>
> Slice này **chạy song song được với việc chờ v1 qua review** — nó không đổi gì mà store nhìn thấy (ADR 0019, Hệ quả 1).

> **Trạng thái build (2026-08-05):** đã build xong, `flutter analyze` sạch, **477** test xanh (`365` trước slice). Tiêu chí chấp nhận đã tick phần tự động kiểm được; **ba ô còn lại là việc của G4 trên thư viện thật của Orchestrator**, và lý do từng ô để lại được ghi ngay tại ô đó.
>
> **Manual test G4 (2026-08-05) tìm ra một chỗ thiết kế sai, và nó sinh ra revision 1 của Spec này.** Một tuyển tập thật, **148** trang, khoảng **28** bài, mang đúng **2** bookmark trong tệp. App gieo 2 dấu ấy lên lưới và khoe *"has a contents list of 2 entries"* — tức nó **trình bày một đề xuất rác bằng đúng giọng tin cậy** của một đề xuất tốt, và bắt nhạc công tự nhận ra điều đó rồi đi tìm `Clear marks`. Câu **11** đảo đề xuất thành **opt-in**; câu **12** cho **đoạn đầu sách không thành bài**, vì dấu ở trang 1 bắt buộc biến bìa + mục lục thành một hàng rác trong Library. Cả hai đã build cùng ngày: `flutter analyze` sạch, **483** test xanh, và **tầng dữ liệu không đổi một dòng** — `splitScore` vốn đã tính extent thứ nhất từ `marks.first.startPage` chứ không từ `1`.

---



## Vấn đề (Problem)

`CONTEXT.md` định nghĩa **PdfDocument** là *"phần byte PDF và các ảnh trang gắn với khung xem biểu diễn của một Score"* — tức một thứ **thuộc về** Score. Code thì gộp hai khái niệm: `Score.relativePath` trỏ thẳng `scores/<id>.pdf` (`lib/library/score.dart:14-15`), một Score đúng một file, và không có chỗ nào diễn đạt được *"bản nhạc này là trang 12–19 của cuốn kia"*. Không có `class PdfDocument` nào trong `lib/`.

Hệ quả cho nhạc công là thứ họ đang sống chung mỗi ngày: một fake book 300 trang, một tuyển tập etude, một cuốn giáo trình — mỗi cuốn nằm trong Library như **một** hàng. Không tìm được một bài trong đó, không xếp một bài vào Setlist, không gán Label cho một bài, không đặt PageOrder cho riêng một bài. Thumbnail của cả cuốn là trang bìa.

Đây **không phải một tính năng mới; đây là sửa một chỗ code đã trôi khỏi glossary từ Spec 0002.** Đó cũng là lý do nó rẻ để qua cổng, và là lý do ADR 0019 quyết định 2 bắt nó đi trước mọi thứ khác: MeasureMap neo ô nhịp vào trang, còn annotation, Bookmark, JumpLink và PageOrder đã neo theo trang từ lâu — **đổi cái neo sau khi MeasureMap tồn tại là làm hỏng thứ tốn công người nhất mà app này từng lưu.**

### Sáu thứ đọc từ repo hôm nay, và cả sáu đổi thiết kế của slice

Không cái nào lộ ra từ ADR, và **dòng đầu tiên mâu thuẫn trực tiếp với một câu của ADR**.


| #   | Điều đọc được                                                                                                                                                                          | Bằng chứng                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | Hệ quả                                                                                                                                                                                                                                                                                                                                          |
| --- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | **Ba quy ước số trang đang cùng tồn tại trên đĩa, không phải một.** Annotation và PageOrder neo theo **trang PDF tuyệt đối**; Bookmark và JumpLink neo theo **vị trí trong PageOrder** | annotation: `/// 1-based PDF source page number (pdfrx convention).` — `annotation/annotation_store.dart:24`; PageOrder: `/// 1-based PDF page when [isBlank] is false.` — `pageorder/page_order.dart:32`; JumpLink: `/// 1-based PageOrder page where the button is drawn.` — `jumplink/jump_link.dart:16,19`; Bookmark ghi từ `currentPage: _pageNumber` (`ui/bookmarks_sheet.dart:67`) mà `_pageNumber` là `_navPage.clamp(1, _pageOrder.length)` — `ui/pdf_mode_screen.dart:1153-1157` | Quyết định 2 của ADR viết *"mọi thứ lưu xuống đĩa … giữ số trang tuyệt đối của PdfDocument"* bằng giọng **mô tả hiện trạng**. Nó không mô tả hiện trạng — nó là **một luật mới**, và áp nó lên Bookmark/JumpLink là một **di trú có mất mát**. Đây là câu hỏi G3 số 1 và là câu nặng nhất của cả Spec                                           |
| 2   | **Một kho thứ năm cũng neo theo trang mà ADR không liệt kê:** page scale theo trang                                                                                                    | `PageScalePrefs.pageScales` khoá bằng `"$scoreId:$sourcePage"` — `layout/page_scale.dart:34,40-41`; và nó nằm trong file **app-level** `page_scale_prefs.json`, không phải file theo Score — `layout/page_scale_prefs_store.dart:10`                                                                                                                                                                                                                                                       | Tách một Score thành mười hai thì mọi override scale theo trang vẫn mang `scoreId` của **cuốn sách**, tức mồ côi ngay lúc tách. ADR liệt kê **ba** hành vi đã ship phải đổi (xoá, Replace PDF, thumbnail); đây là cái **thứ tư**, và nó là cái duy nhất nằm trong một file dùng chung                                                           |
| 3   | **Thumbnail khoá theo** `scoreId` **+ mtime của PDF**, và luôn dựng **trang đầu của file**                                                                                             | khoá `'$scoreId-${stat.modified.millisecondsSinceEpoch}'` — `library/score_thumbnails.dart:85-89`; `doc.pages.first` — `pdf/pdf_first_page.dart:35`                                                                                                                                                                                                                                                                                                                                        | Mười hai Score chung một PDF cho mười hai **khoá** khác nhau (tốt) nhưng **cùng một ảnh** (xấu — đúng thứ ADR cảnh báo). Thứ ADR chưa nói: **mtime không đổi khi PageExtent đổi**, nên sửa một extent sẽ *không* làm mới thumbnail. PageExtent phải vào **khoá**, không chỉ vào tham số render                                                  |
| 4   | `pdfrx` **có thật** `loadOutline()`**, và** `PdfDest` **cho thẳng số trang 1-based** — nhưng nó nullable và cây thì đệ quy                                                             | `Future<List<PdfOutlineNode>> loadOutline();` — `pdfrx_engine-0.4.6/lib/src/pdf_document.dart:246-247`; `final PdfDest? dest;` + `final List<PdfOutlineNode> children;` — `pdf_outline_node.dart:8-18`; `final int pageNumber;` — `pdf_dest.dart:4-15`; dựng từ `pageIndex + 1`, và trả `null` khi `FPDFDest_GetView` cho `type == 0` — `native/pdfrx_pdfium.dart:1978-1987`                                                                                                               | Đề xuất ranh giới từ mục lục rẻ đúng như ADR nói, và **số trang không phải suy ra** — nó là một trường. Hai thứ phải chịu được mà ADR không nhắc: nút mục lục **không có trang đích** (`dest == null`), và cây **nhiều tầng** — một tuyển tập chia chương cho cây hai tầng chứ không phải danh sách phẳng. App chưa dùng `loadOutline` ở đâu cả |
| 5   | `library.json` **không có số phiên bản nào**                                                                                                                                           | payload đúng một khoá: `{'scores': …}` — `library/score_library.dart:234-238`                                                                                                                                                                                                                                                                                                                                                                                                              | Di trú phải nhận ra "manifest cũ" bằng **sự vắng mặt của một trường**, không bằng một con số. Đây là lần đầu repo phải di trú `library.json`, và nó không có chỗ nào để ghi rằng mình đã di trú xong                                                                                                                                            |
| 6   | `formatVersion` **chỉ được kiểm ở một chỗ, và luật là *mới hơn thì từ chối*, không phải *khác thì từ chối***                                                                           | `if (version is! int || version < 1 || version > LibraryBackup.formatVersion)` — `library/library_backup.dart:529-535`                                                                                                                                                                                                                                                                                                                                                                     | Bump lên `2` làm bản app **cũ** từ chối file mới — đúng việc cần. Nhưng **chiều ngược lại chưa có ai viết**: bản mới đọc backup `version: 1` sẽ **qua cửa** và đổ một `library.json` đời cũ vào chỗ code đang mong đợi `PdfDocument`. Di trú phải chạy **sau mỗi lần restore**, không chỉ lúc mở library                                        |


---



## Kết quả (Outcome)

Nhạc công nhập `Chopin Etudes.pdf`, 200 trang, 24 bài. App nhận ra nó có mục lục và gợi ý tách. Một lưới thumbnail hiện ra với **ranh giới và tên bài đã điền sẵn**; soát, sửa vài chỗ, bấm đồng ý. Library có thêm 24 hàng — mỗi hàng tên bài của nó, **số trang của nó**, **thumbnail trang đầu của nó**. Mở một bài thì thấy đúng bài đó, không phải cả cuốn.

Từ đó trở đi mỗi bài là một Score bình thường: xếp vào Setlist cạnh PDF tự nhập, gán Label, tìm bằng ô search, sắp xếp, vẽ lên, đặt Bookmark, dựng PageOrder, sao lưu.

Với thư viện **đã có**: cuốn sách đang nằm dưới dạng một Score tách được từ `⋯`, **không phải nhập lại**, và không mất một nét vẽ nào.

Với người viết slice sau, kết quả là ba thứ: một thực thể `PdfDocument` sở hữu file, một `PageExtent` nói trang nào thuộc bài nào, và — quan trọng nhất cho 0053 — **mỗi con số trang lưu xuống đĩa có đúng một nghĩa đã được viết thành lời**.

**Thứ không đổi, và đây là tiêu chí G4 quan trọng nhất:** người chưa bao giờ tách gì cả mở app lên và **không thấy một khác biệt nào**.

---



## Trong phạm vi (In scope)

**Mô hình và lưu trữ**

- `lib/library/pdf_document.dart` — thực thể `PdfDocument`: `id`, `relativePath`, `pageCount`, `originalFileName`, `importedAt`
- `lib/library/page_extent.dart` — `PageExtent { firstPage, lastPage }`, 1-based, hai đầu **đóng**; hàm thuần: độ dài, chứa-trang, quy đổi trang tuyệt đối ↔ trang thứ mấy của bài
- `Score` bỏ `relativePath`, nhận `pdfDocumentId` + `PageExtent`; `pageCount` **tính ra** từ extent (xem G3 số 4)
- Di trú `library.json`: mỗi Score hôm nay thành **một** `PdfDocument` với extent trọn vẹn. **Không di chuyển một file nào trên đĩa** (G3 số 3). Idempotent, chạy lúc mở library **và sau mỗi lần restore thành công**
- `LibraryBackup.formatVersion` → `2`; backup `version: 1` vẫn phục hồi được rồi được di trú

**Tách một PDF thành nhiều Score**

- Màn hình tách: **lưới thumbnail các trang**, đánh dấu "bài mới bắt đầu ở đây"; mỗi dấu sinh một Score chạy tới dấu kế tiếp. Đọc lại Spec **0048** trước khi vẽ. **Đoạn trước dấu đầu tiên không thành bài** (G3 số 12) — trang vẫn ở trong `PdfDocument`, chỉ không có `Score` nào trỏ tới
- **Đề xuất từ mục lục:** `loadOutline()` → làm phẳng cây → **một hành động opt-in mang số đếm** (`Use contents list (N entries)`), không gieo sẵn (G3 số 11); áp rồi thì sửa được từng dấu, bỏ được cả đề xuất
- Hai lối vào: gợi ý **sau khi nhập** (G3 số 6) và một mục trong `⋯` của một Score đã có
- Sửa PageExtent sau khi đã tách (G3 số 5)

**Bốn hành vi đã ship phải đổi — cả bốn là chỗ dễ mất dữ liệu**

- **Delete** (0028): đếm tham chiếu. Xoá Score cuối cùng dùng một `PdfDocument` thì mới xoá file; hỏng theo chiều ngược lại là một tệp mồ côi nằm lại vĩnh viễn
- **Replace PDF** (0024): nay ảnh hưởng **mọi** Score dùng chung tệp — phải nói rõ trong hộp thoại, và số trang của tệp mới có thể làm một PageExtent trở nên vô nghĩa
- **Thumbnail** (0040): dựng **trang đầu của PageExtent**; PageExtent vào khoá cache
- **Page scale theo trang** (0031): khoá `"$scoreId:$sourcePage"` phải theo Score mới sau khi tách

**Nguồn gốc hiện ra, nhưng không thành công dân hạng nhất**

- Một dòng trong ScoreMenu / màn hình thông tin: *"Trang 12–19 của* `Chopin Etudes.pdf`*"*
- **Không** tab "Files", **không** hàng nào đại diện cho cuốn sách trong Library

---



## Ngoài phạm vi (Out of scope)

- **MeasureMap, SystemBox, MeasureBox, BeatBox** — Spec 0053. Slice này chỉ dựng cái neo mà chúng sẽ đứng lên
- **Mọi thứ chạm audio**: SyncMap, BackingTrack, Transport, nâng `flutter_soloud` (đang pin `^4.0.13`, `pubspec.yaml:22`). Nhóm này bắt đầu ở slice 5
- **SongPack** — Spec 0059. Slice này không xuất, không nhập, không đóng gói gì
- **Sao lưu chọn lọc** — nợ của 0050, đi cùng slice 6 (0057). Ở đây chỉ **bump** `formatVersion` để cả ba việc đang chờ nó dùng chung một lần bump (ADR 0019 quyết định 10)
- **Discover lưu tham chiếu thay vì nuốt asset** (ADR 0017 `hold`) — cũng dùng chung lần bump này, nhưng không có payload nào của nó ship ở đây
- `PdfDocument` **thành công dân hạng nhất của Library** — không tab Files, không màn hình quản lý tệp. Cho tệp một chỗ đứng là dựng lại đúng mô hình trình duyệt tệp mà app cố ý không có (ADR 0019 quyết định 11)
- **Gộp hai Score thành một**, hoặc chuyển một Score sang `PdfDocument` khác — không có bằng chứng ai cần
- **Dò tự động vạch nhịp, dòng kẻ nhạc, hay ranh giới bài từ *ảnh* trang** — đó là **OMR**, thuộc ADR 0006 và H6, và ADR 0019 quyết định 3d **không mở nó**. Đọc mục lục là đọc **siêu dữ liệu có cấu trúc của tệp**, không phải nhìn vào trang giấy; ranh giới này phải được giữ bằng phản xạ
- **Bookmark/JumpLink trôi khi PageOrder đổi** — tính chất đã có sẵn của code đang ship, slice này không tạo ra nó và không sửa nó
- **Dọn dẹp** `library_screen.dart` (1406 dòng) hay `pdf_mode_screen.dart` (1910 dòng) — 0046 và 0047 đang `hold`

---



## Câu hỏi G3 (G3 questions) — **đã trả lời 2026-08-05**

Cả mười câu chốt trong một lượt, **tất cả theo khuyến nghị đã ghi**, không câu nào bị đảo. Cột dưới đây giữ nguyên lời khuyến nghị vì nó nay là lời quyết định — lập luận là thứ người build cần, không chỉ kết luận.

Hai câu có hệ quả ra ngoài Spec này và đã được mang đi: **số 1** sửa lời quyết định 2 của ADR 0019 (revision 3), và **số 6** sửa lời quyết định 11 của cùng ADR.


| #   | Câu hỏi                                                                                                                                         | Chốt                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | **Bookmark và JumpLink đang neo theo PageOrder chứ không theo trang PDF. Di trú chúng sang trang tuyệt đối theo quyết định 2, hay giữ nguyên?** | **Giữ nguyên, và *thu hẹp luật của ADR* thay vì di trú — vì di trú ở đây là mất dữ liệu, không phải dọn dẹp.** Hai lý do cụ thể, cả hai đọc từ code đang ship. **(a) JumpLink không diễn đạt được bằng trang tuyệt đối, và đó chính là lý do nó tồn tại.** `PageOrder.duplicate()` (`page_order.dart:96-105`) cho phép **một trang PDF xuất hiện nhiều lần** trong chuỗi biểu diễn — đó là cách app giải D.C. và đoạn lặp. Một JumpLink nói *"tới ô này trong chuỗi thì nhảy sang ô kia"*; hai ô có thể là **cùng một tờ giấy**. Chuyển sang trang tuyệt đối là làm nhoè đúng phân biệt mà tính năng này sống nhờ. **(b) Chuyển đổi không phải song ánh:** `PageOrderEntry.blank()` (`page_order.dart:22-28`) là một ô **không có trang PDF nào** — một Bookmark trên trang trắng chèn thêm sẽ không có gì để trỏ tới. Nên luật đúng không phải *"mọi thứ giữ số tuyệt đối"* mà là: **thứ neo vào tờ giấy** (annotation, page scale, `PageOrder.sourcePage`, và MeasureBox sắp tới) giữ **trang tuyệt đối của** `PdfDocument`; **thứ neo vào chuỗi biểu diễn** (Bookmark, JumpLink) giữ **vị trí trong PageOrder**, y như hôm nay. Không di trú, không mất mát, và tinh thần của quyết định 2 vẫn được giữ trọn — điều nó thật sự cấm là **quy ước thứ ba**, tức "số trang tương đối trong PageExtent", và luật này cấm đúng thứ đó. **Việc phải làm là viết cả hai nghĩa vào doc comment của bốn model** — `Bookmark.pageNumber` hôm nay **không có comment nào** (`bookmark/bookmark.dart:12`), và đó chính là lý do dữ kiện này suýt lọt |
| 2   | `PdfDocument` **lưu ở đâu — thêm khoá vào** `library.json` **hay một file riêng?**                                                              | **Thêm một khoá** `pdfDocuments` **vào** `library.json`**.** Lý do không phải gọn mà là **nguyên tử**: đếm tham chiếu lúc xoá phải đọc *cả hai* danh sách rồi ghi *cả hai*, và hai file nghĩa là hai lần ghi với một khe hở ở giữa — một lần crash đúng chỗ đó để lại hoặc một PDF mồ côi, hoặc tệ hơn, một Score trỏ vào `PdfDocument` không tồn tại. `_writeScores` hôm nay đã ghi cả manifest trong một lần (`score_library.dart:234-238`); giữ đúng tính chất đó                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| 3   | **Di trú có di chuyển file PDF trên đĩa không?** (`scores/<scoreId>.pdf` → `documents/<docId>.pdf`)                                             | **Không. Không đổi một byte nào trên đĩa lúc di trú.** `PdfDocument.id` nhận đúng `scoreId` cũ, `relativePath` giữ nguyên `scores/<id>.pdf`; **import mới** ghi vào `documents/<docId>.pdf`. Hai layout sống chung vĩnh viễn và điều đó hoàn toàn ổn **vì đường dẫn là dữ liệu, không phải quy ước** — `absoluteFile` đã luôn đọc `relativePath` chứ không tự dựng đường dẫn (`score_library.dart:91-92`). Đổi lại nếu di chuyển: đó là bước **duy nhất** trong cả slice có thể hỏng giữa chừng trên một thư viện vài GB và để lại một library mở ra không thấy gì. Cái giá là một layout hơi lẫn lộn mà chỉ người đọc code nhìn thấy — rẻ hơn nhiều                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| 4   | `Score.pageCount` **giữ lại hay tính ra?**                                                                                                      | **Tách làm hai, và đây là chỗ giết được một nguồn trôi lệch.** `PdfDocument.pageCount` **lưu lại** — nó là tính chất của tệp, biết nó phải mở PDF, và 0040 đã dựng sẵn cả đường backfill cho việc đó (`backfillPageCounts`, `score_library.dart:160-185`, đổi tên theo). `Score.pageCount` **tính ra** từ extent — `lastPage - firstPage + 1`, số học thuần, không mở tệp nào, không bao giờ lệch. Giữ cả hai dưới dạng lưu trữ là mời một cặp giá trị mâu thuẫn vào đúng thứ Library hiển thị trên mọi hàng                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| 5   | **Sửa PageExtent sau khi đã tách — trong hay ngoài phạm vi? Và annotation nằm ngoài extent mới thì sao?**                                       | **Trong phạm vi, và annotation ngoài extent thì *giữ trên đĩa, không hiển thị*.** Phải trong phạm vi vì đề xuất từ mục lục **chắc chắn sai vài chỗ** (mục lục có thể thô hoặc lệch một trang), và nếu không sửa được thì đường duy nhất là xoá rồi nhập lại — tức mất annotation, đúng thứ đắt nhất. Về dữ liệu: vì annotation neo theo **trang tuyệt đối** (câu 1), thu hẹp extent **không làm lệch** gì cả, nét vẽ chỉ đơn giản nằm ngoài tầm nhìn — và nới rộng lại thì nó hiện lại nguyên vẹn. Đó là hành vi không mất mát và có thể lùi, nên chọn nó. `PageOrder` thì ngược lại, nó phải nhất quán: ô nào trỏ ra ngoài extent mới bị **bỏ**, và người dùng được báo **số lượng** trước khi xác nhận, không bị báo sau                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| 6   | **Hỏi "một bài hay một tuyển tập" lúc nhập — hỏi mỗi file à?**                                                                                  | **Không hỏi trong luồng nhập. Nhập y như hôm nay, rồi gợi ý *sau*.** Đây là chỗ ADR quyết định 11 va phải một dữ kiện nó không biết: **import nhận nhiều file một lượt** (`allowMultiple: true`, `library_screen.dart:741-746` → `importPdfs`, `score_library.dart:79-89`), nên "hỏi một câu nếu PDF nhiều trang" thành **mười hai hộp thoại liên tiếp** cho một lần nhập mười hai bài. Đường giữ đúng ý định của ADR mà không chặn luồng nhập: nhập xong, nếu có file nào **trông như tuyển tập** — có mục lục với ≥ `2` đích, hoặc dài hơn `30` trang — thì **một** thanh gợi ý duy nhất ở đầu danh sách (*"*`Chopin Etudes.pdf` *có mục lục 24 mục — tách thành từng bài?"*), bỏ qua được. Giữ trọn lời hứa của ADR: người chỉ nhập một bài **không thấy thêm một bước nào**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| 7   | **Tách một Score đã có thành 12 — Score gốc còn tồn tại không?**                                                                                | **Còn, và nó thành bài thứ nhất.** Nó giữ `id`, giữ annotation, giữ Label, giữ **chỗ của nó trong mọi Setlist**, và nhận extent của bài đầu; 11 bài kia là Score mới. Phương án kia — xoá Score gốc rồi tạo 12 cái mới — làm bản nhạc **im lặng rơi khỏi mọi Setlist nó đang nằm trong**, mà Setlist là thứ nhạc công dựng cho một buổi diễn cụ thể. Cái giá của khuyến nghị này phải nói thẳng: annotation của cuốn sách **ở lại hết với bài thứ nhất**, kể cả nét vẽ trên trang thuộc bài thứ bảy. Chấp nhận được vì nó **không mất** (câu 5: ngoài extent thì ẩn, không xoá), và một cuốn sách chưa tách thì hiếm khi được vẽ lên nhiều                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| 8   | **Tên các Score mới khi PDF không có mục lục?**                                                                                                 | `<tên cuốn> — <n>`, sửa được ngay trên màn hình tách trước khi xác nhận. Không dùng "Untitled": một Library có mười hai hàng "Untitled" thì tệ hơn hẳn mười hai hàng có tiền tố đúng. Không đoán tên từ nội dung trang — đó là OMR                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| 9   | **Thumbnail cho 50 Score chung một PDF: mở tài liệu 50 lần?**                                                                                   | **Có, và đừng tối ưu ở slice này.** `renderPdfFirstPagePng` mở rồi dispose mỗi lần gọi (`pdf/pdf_first_page.dart:31-57`), nên 50 bài là 50 lần mở cùng một tệp. Chấp nhận vì: thumbnail sinh **lười** và **cache vào đĩa**, nên đó là chi phí một lần cho mỗi bài chứ không phải mỗi lần cuộn; và một pool tài liệu dùng chung là đúng loại tối ưu cần đo trước khi làm. Việc bắt buộc ở đây chỉ là đổi chữ ký thành nhận **số trang** thay vì luôn `pages.first`, và đưa PageExtent vào khoá cache (dữ kiện 3). **Nếu G4 thấy lưới giật thì đó là một Spec sau, không phải một dòng thêm vào đây**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| 10  | **Backup** `version: 1` **phục hồi trên bản app mới — cho hay từ chối?**                                                                        | **Cho, rồi di trú ngay sau khi restore xong.** Từ chối là mất dữ liệu với đúng những người cẩn thận nhất — người có backup. Ràng buộc đi kèm là dữ kiện 6: `_validateMarkerAt` cho `version: 1` **qua cửa** (`library_backup.dart:529-535`), nên nếu di trú chỉ chạy lúc khởi động thì một lần restore giữa phiên sẽ đổ manifest đời cũ vào code đang mong đợi `PdfDocument`. Di trú phải là **một hàm của library root**, idempotent, gọi ở **cả hai** chỗ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |




### Hai câu mở thêm ở revision 1, sau manual test G4

Cả hai sinh ra từ **một** quan sát trên tệp thật: 148 trang, ~28 bài, **2** bookmark. Không câu nào đổi hướng của slice — chúng sửa chỗ code **trình bày** một đề xuất yếu như thể nó mạnh.


| #   | Câu hỏi                                                                         | Chốt                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| --- | ------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 11  | **Đề xuất từ mục lục nên gieo sẵn dấu lên lưới, hay phải được nhạc công chọn?** | **Opt-in: lưới mở ra trắng, mục lục là một hành động có số đếm —** `Use contents list (2 entries)`**.** Lý do không phải khẩu vị mà là **ai gánh việc đánh giá độ tin**. Gieo sẵn thì một outline 2 mục trông y hệt một outline 24 mục — cùng badge, cùng caption, cùng con số ở đáy màn hình — nên nhạc công phải tự phát hiện đề xuất là rác *rồi* mới đi tìm `Clear marks`; app bắt họ làm phần khó nhất mà không cho họ dữ kiện nào để làm. Đặt con số vào **nhãn của nút** thì `2` tự nó là lời cảnh báo trước khi có gì bị gieo, và `24` tự nó là lời mời. Đây cũng đúng câu Spec này đã viết ở Ghi chú UX (*"một màn hình áp đặt kết quả của mục lục sẽ tệ hơn hẳn màn hình không có đề xuất nào"*) — bản build đầu chưa đi tới đó. Giá phải trả: với cuốn có mục lục tốt thì **thêm đúng một tap**. Hai phương án bị bác: **ngưỡng hợp lý** (chỉ gieo khi trung bình ≤ `20` trang/mục) vì nó là một hằng số đoán và **vẫn quyết định hộ**, chỉ là đúng thường xuyên hơn; và **bỏ hẳn outline** vì cuốn có mục lục theo bài là đúng ca `loadOutline()` tồn tại để phục vụ. **Câu chữ của thanh gợi ý sau khi nhập cũng đổi theo:** nó thôi khai *"has a contents list of N entries"* — con số ấy nay thuộc màn hình tách, còn thanh gợi ý chỉ nói **độ dài tệp**, thứ nó biết chắc |
| 12  | **Trang 1 có buộc là ranh giới không? Bìa và mục lục thành bài thứ nhất?**      | **Không buộc. Cho phép đoạn đầu sách không thành bài.** Luật cũ (*"trang 1 luôn là ranh giới, vì trang trước dấu đầu tiên sẽ không thuộc Score nào"*) bảo vệ đúng thứ cần bảo vệ — **không mất trang** — nhưng nó nhầm *không thuộc Score nào* với *bị mất*. Trang sống trong `PdfDocument`, không sống trong `Score`; một trang không có `Score` nào trỏ tới thì vẫn nằm nguyên trong tệp, vẫn hiện trên lưới, vẫn nhận lại một dấu bất cứ lúc nào. Thứ luật cũ thật sự tạo ra là **một hàng rác trong Library** — "Book — 1" gồm bìa cộng trang mục lục — trên đúng loại tệp mà slice này tồn tại để xử lý. Tầng dữ liệu **không cần đổi một dòng**: `splitScore` đã tính extent thứ nhất từ `marks.first.startPage` chứ không từ `1`. Ràng buộc giữ nguyên: **Save vẫn đòi ≥ 2 bài**, nên "bỏ bìa rồi để cả cuốn thành một bài" không đi qua đường này được — đó là đổi PageExtent, không phải tách, và một Score trọn tệp hôm nay chưa có lối vào màn hình `Pages…`. Ghi lại như một **giới hạn đã biết**, không mở phạm vi để chữa                                                                                                                                                                                                                                                   |


---



## Thuật ngữ miền (Domain terms)

**Một term mới vào** `CONTEXT.md` **ở G1 lúc build:**

- **PageExtent** — Khoảng trang liên tục của một PdfDocument thuộc về một Score. Nó là **phạm vi**: đặt lúc tách bài, sửa được, nhưng hiếm khi đổi. Nó **không phải PageOrder** — PageOrder là **trình tự** (chơi các trang ấy theo thứ tự nào, lặp chỗ nào, chèn trang trắng chỗ nào) và PageOrder chạy **bên trong** PageExtent. Trộn hai khái niệm này là lỗi thiết kế đắt nhất có thể mắc ở đây (ADR 0019 quyết định 2).

`PdfDocument` **đã có định nghĩa đúng trong** `CONTEXT.md` **và không cần sửa** — chỉ code phải đuổi kịp nó. Đây là điểm nên nói ở G1: glossary đúng từ đầu, code trôi.

**Năm term còn lại của ADR 0019 —** `MeasureMap`**,** `SystemBox`**,** `MeasureBox`**,** `BeatBox`**,** `SongPack` **— không thuộc slice này.** Chúng vào `CONTEXT.md` ở G1 của Spec đẻ ra chúng, không phải ở đây.

Term đã có mà Spec này dùng: **Score**, **Setlist**, **Label**, **PdfDocument**, **PageOrder**, **PdfMode**, **ScoreMenu**, **Library**.

---



## Tiêu chí chấp nhận (Acceptance criteria)

**Di trú — người chưa tách gì không thấy gì đổi**

- [ ] Mở app trên thư viện đã có: **mọi Score y nguyên** — tên, số trang, thumbnail, annotation, Bookmark, JumpLink, PageOrder, Label, Setlist, page scale — **G4, thư viện thật**
- [x] Di trú **idempotent**: chạy lại lần hai không đổi một byte nào trong `library.json`
- [x] Không một file PDF nào bị di chuyển, đổi tên hay ghi lại — mạnh hơn phép so mtime: di trú là **hàm thuần trên nội dung** `library.json`, không nhận `Directory` nào nên không có đường chạm tới một tệp
- [x] Thư viện **rỗng** và thư viện **một Score** đều di trú sạch
- [x] Di trú chạy **cả sau khi restore**, không chỉ lúc mở library

**Một PDF, nhiều Score**

- [x] Tách một PDF `200` trang thành `24` Score: mỗi hàng Library có **tên riêng**, **số trang riêng**, **thumbnail trang đầu của nó** — không hàng nào dùng lại ảnh của hàng khác
- [x] Mở một bài: thấy đúng trang của nó, số trang chạy từ `1` tới độ dài extent — **G4**; `PdfModeScreen` không pump được (pdfrx cần native viewer), nên hai nửa logic được test rời: `Score.extentIn` và `PageOrder.forExtent` + `PageOrderStore`
- [x] Mỗi bài xếp được vào Setlist, gán được Label, tìm được bằng search, sắp xếp được — không đường nào phân biệt nó với một Score nhập thẳng — **G4**; ở tầng dữ liệu một bài là một hàng `Score` bình thường, không có nhánh nào rẽ theo `pageExtent`
- [x] ScoreMenu hiện *"Trang 12–19 của* `Chopin Etudes.pdf`*"*
- [x] PDF **có mục lục**: lưới mở ra **trắng**, một hành động `Use contents list (N entries)` áp ranh giới và tên bài, sửa được từng dấu, bỏ được cả đề xuất; PDF **không có mục lục**: lưới trắng, không có hành động nào để bấm (G3 số 11)
- [x] Mục lục **thô** (2 mục cho một cuốn dài): không dấu nào bị gieo, và **con số nằm trong nhãn nút** nên nhạc công đọc được độ tin trước khi áp
- [x] **Đoạn đầu sách không thành bài**: dấu đầu tiên đặt ở trang `3` thì trang `1–2` không thuộc `Score` nào, màn hình **nói ra điều đó**, và không hàng rác nào vào Library (G3 số 12)
- [x] Nút mục lục **không có trang đích** (`dest == null`) và mục lục **nhiều tầng**: không crash, không bỏ mất mục nào có trang
- [x] Tách một Score **đã có**: Score gốc giữ `id`, giữ chỗ trong mọi Setlist nó đang nằm trong (G3 số 7)
- [x] Thu hẹp rồi nới lại một PageExtent: annotation trên trang đã ra ngoài **hiện lại nguyên vẹn** (G3 số 5)

**Bốn hành vi đã ship**

- [x] **Delete**: xoá một trong 24 bài → file PDF **còn**; xoá bài cuối cùng → file **bị dọn**. Cả hai chiều đều có test — mồ côi và xoá nhầm đều là hỏng
- [x] **Replace PDF**: hộp thoại nói rõ **bao nhiêu Score** dùng chung tệp này; tệp mới ngắn hơn làm một PageExtent vô nghĩa thì được **xử lý và báo**, không im lặng
- [x] **Thumbnail**: đổi PageExtent → thumbnail **làm mới** (PageExtent nằm trong khoá cache, không chỉ mtime)
- [x] **Page scale theo trang**: override của cuốn sách theo đúng bài sau khi tách, không mồ côi

**Backup**

- [x] `LibraryBackup.formatVersion` == `2`; `formatId` và `markerFileName` **không đổi một ký tự** (`'standscore-backup'`, `standscore-backup.json`)
- [x] Bản app **cũ** từ chối backup mới với đúng câu `'Unsupported StageScore backup version.'`
- [x] Backup `version: 1` phục hồi được trên bản mới, rồi được di trú (G3 số 10)
- [x] Hai test của 0027 và bốn test của 0050 xanh; test nào phải sửa thì **chỉ vì** `formatVersion`, không vì cấu trúc

**Bản dựng**

- [x] `flutter analyze` sạch; toàn bộ test xanh (trước slice `365`, sau slice `477`, sau revision 1 `483`)
- [x] Không dependency mới, không quyền mới, không đổi `pubspec.yaml` ngoài chỗ nào thật sự cần
- [x] G4 chạy trên **thư viện thật của Orchestrator**, không phải một thư viện dựng cho test — đây là slice mà một lỗi di trú chỉ lộ ra trên dữ liệu thật

---



## Ghi chú UX (UX notes)

**Nhạc công nên thấy khác:** một thanh gợi ý sau khi nhập một cuốn sách; một mục tách trong `⋯`; màn hình lưới trang; và sau đó, Library có nhiều hàng hơn — mỗi hàng là một **bài**, không phải một **tệp**.

**Nhạc công không nên thấy khác:** bất cứ thứ gì khác. Người không có cuốn sách nào trong thư viện đi hết slice này mà không biết nó đã xảy ra.

**Màn hình tách là lưới trang, không phải hộp nhập số trang.** Người ta nhận ra chỗ bắt đầu một bài bằng cách **nhìn thấy tiêu đề trên trang**, không bằng cách nhớ số trang. Spec **0048** đã nghĩ sẵn phần lớn hình dạng này.

**Đề xuất là đề xuất, và nó phải được *chọn* mới thành dấu** (G3 số 11). Mục lục có thể thô, lệch một trang, hoặc chia theo chương chứ không theo bài — một tuyển tập 148 trang với 28 bài mang đúng 2 bookmark là ca thật, không phải ca biên. Nên lưới mở ra trắng, mục lục đứng sau **một nút mang số đếm của chính nó**, và sau khi áp thì mọi dấu sửa được, bỏ được, cả đề xuất bỏ được trong một thao tác. Con số trong nhãn nút là toàn bộ thứ nhạc công cần để biết có nên tin nó: `2` trên một cuốn dày tự nó là lời cảnh báo. Một màn hình *áp đặt* kết quả của mục lục tệ hơn hẳn màn hình không có đề xuất nào.

**Không phải trang nào cũng thuộc một bài** (G3 số 12). Bìa, trang mục lục, lời tựa — nhạc công không muốn chúng thành một hàng trong Library. Đoạn trước dấu đầu tiên đơn giản là không thuộc bài nào, và màn hình phải **nói ra** bằng một câu (*"Pages 1–2 are not in any piece."*) chứ không để người ta suy ra từ chỗ thiếu một badge. Đây **không phải mất trang**: trang thuộc `PdfDocument`, và nó nhận lại một dấu bất cứ lúc nào.

**Chỗ dễ trượt nhất là câu chữ của Replace PDF.** Hôm nay nó nói về một bản nhạc. Sau slice này nó có thể đang thay tệp dùng chung của **hai mươi bốn** bản nhạc, và người bấm nút chỉ đang nghĩ tới bài họ vừa mở. Con số phải nằm trong câu, không nằm trong một dòng phụ.

**Tách không phải là xoá.** Ở mọi bước, nếu phải chọn giữa một thư viện gọn và một thư viện không mất gì, chọn vế sau.

---



## Ràng buộc kỹ thuật (Technical constraints)

- **PageExtent không phải PageOrder.** Đây là ràng buộc quan trọng nhất của slice và cũng là chỗ dễ trộn nhất, vì cả hai đều là "trang" và cả hai đều 1-based. Hai kiểu **không được** thay thế nhau ở bất kỳ chữ ký hàm nào; nếu một hàm nhận `int page` mà không nói rõ trong tên hay comment là trang nào, đó là một lỗi đang chờ
- **Ba không gian số trang, ba tên gọi, không có cái thứ tư.** `sourcePage` = trang tuyệt đối của `PdfDocument` (1-based). Vị trí trong PageOrder = ô thứ mấy của chuỗi biểu diễn (1-based). "Trang thứ mấy của bài" chỉ tồn tại ở **tầng hiển thị**, không bao giờ ghi xuống đĩa — đó chính là quy ước thứ ba mà quyết định 2 cấm
- **Mọi model có số trang phải có doc comment nói nó là loại nào.** `Bookmark.pageNumber` hôm nay không có (`bookmark/bookmark.dart:12`) và đó là lý do dữ kiện 1 suýt lọt
- **Di trú là một hàm thuần trên nội dung** `library.json`, không phải một hiệu ứng phụ rải trong `ScoreLibrary`. Nó phải test được mà không cần một PDF nào, không cần một thư mục nào — cùng idiom mà `PdfPageCounter` đã dùng để giữ tầng library không dính pdfrx (`score_library.dart:12-18`)
- **Đếm tham chiếu là một phép đọc trên** `library.json`**, không phải một trường đếm.** Một số đếm lưu sẵn sẽ lệch sau lần đầu tiên có gì đó hỏng giữa chừng; đếm lại thì không bao giờ lệch
- `loadOutline()` **chạy được trên tệp hỏng và tệp không có mục lục** — cùng nguyên tắc mà `pdf_first_page.dart` đã đặt: cả hai hàm ở đó trả `null` thay vì ném, và tầng trên nhận hàm được inject nên test được mà không có engine PDF. Đường đọc outline **phải theo đúng idiom đó**, không được là chỗ đầu tiên trong repo mà một PDF hỏng làm sập màn hình
- **Không đụng** `formatId` **và** `markerFileName`**.** Cách viết `standscore` ở đó là **cố ý** (README của `stagescore/`, `AGENTS.md`) vì nó đã ghi ra đĩa của người dùng. Chỉ `formatVersion` đổi
- `libraryRootDirName` **giữ** `'standscore'` (`library/library_root.dart:12`) — cùng lý do
- **Không SDK, không quyền, không byte nào rời máy.** Nếu slice này cần bất cứ thứ gì trong ba thứ đó thì nó đã đi lạc khỏi phạm vi

---



## Kế hoạch kiểm thử (Test plan)

**Automated**

- `test/library_migration_test.dart` (mới) — hàm thuần trên nội dung `library.json`: manifest cũ (không có khoá `pdfDocuments`) → mỗi Score một `PdfDocument` extent trọn vẹn; chạy lần hai **không đổi gì**; manifest rỗng; manifest đã di trú rồi; `relativePath` giữ nguyên từng ký tự
- `test/page_extent_test.dart` (mới) — hàm thuần: độ dài, chứa-trang, quy đổi hai chiều tuyệt đối ↔ trang thứ mấy của bài, extent một trang, extent không hợp lệ khi tệp ngắn đi
- `test/pdf_document_refcount_test.dart` (mới) — xoá một trong nhiều Score **giữ** tệp; xoá cái cuối **dọn** tệp; Score trỏ tới `PdfDocument` không tồn tại không làm sập việc đọc manifest
- `test/pdf_outline_split_test.dart` (mới) — làm phẳng cây outline thành đề xuất ranh giới: cây một tầng, cây hai tầng, nút `dest == null` bị bỏ qua mà không mất nút khác, outline rỗng cho danh sách rỗng. Chạy trên **cấu trúc dữ liệu**, không trên một PDF thật
- `test/split_score_screen_test.dart` (sửa ở revision 1) — mục lục **không** gieo dấu nào cho tới khi nút được bấm, và nhãn nút mang số đếm; lưới trắng là **không bài nào**, `Save` tắt; dấu đầu tiên ở trang `3` thì màn hình nói `1–2` không thuộc bài nào và `SplitMark` đầu tiên mang `startPage: 3`
- `test/library_split_test.dart` (sửa ở revision 1) — thanh gợi ý và màn hình tách không còn dựa vào việc dấu tự hiện ra; `Score` sinh từ đường opt-in phải giống hệt đường gieo sẵn cũ
- `test/score_thumbnail_extent_test.dart` (mới) — khoá cache đổi khi PageExtent đổi dù mtime không đổi
- `test/page_scale_test.dart` (sửa) — khoá theo Score mới sau khi tách
- `test/library_backup_test.dart` + `test/library_backup_progress_test.dart` (sửa **chỉ** phần `formatVersion`) — cộng hai ca mới: backup `version: 1` restore được rồi di trú; backup `version: 3` bị từ chối
- **Không** test nào cần một PDF thật ngoài những chỗ hôm nay đã cần

**Manual demo (G4) — trên thư viện thật của Orchestrator, và đây là điều kiện chứ không phải lời khuyên**

- Mở app **trước khi** tách bất cứ thứ gì: đi qua mười Score bất kỳ, xác nhận annotation, Bookmark, JumpLink, PageOrder, page scale còn nguyên. **Đây là phép kiểm quan trọng nhất của cả slice**
- Nhập một fake book hay tuyển tập thật có mục lục → tách → đếm số bài, soát vài tên, mở ba bài ở ba chỗ khác nhau trong cuốn
- Nhập một tuyển tập có mục lục **thô** (ít mục hơn số bài rất nhiều) → xác nhận lưới mở ra **trắng**, nút mục lục hiện đúng số mục, và tự đánh dấu 20+ bài đi hết được mà không phải bỏ đề xuất nào
- Tách một cuốn có bìa và trang mục lục → đặt dấu đầu tiên ở bài thật → xác nhận Library **không** có hàng nào là bìa
- Tách một cuốn **đã nằm sẵn** trong thư viện và **đang ở trong một Setlist** → mở Setlist, xác nhận nó còn ở đó
- Nhập một PDF **không có mục lục** → lưới trang, tự đánh dấu
- Xoá một bài trong cuốn → mở bài khác cùng cuốn, vẫn đọc được
- Replace PDF trên một bài của cuốn sách → đọc kỹ câu chữ hộp thoại, xác nhận nó nói đúng số Score bị ảnh hưởng
- Backup → xoá app → cài lại → restore → toàn bộ cấu trúc bài quay lại đúng
- Restore một backup **cũ** (`version: 1`, tạo trước slice này) → di trú chạy, thư viện mở đúng

