# 0054 — Cuốn sách có tên, tách được tiếp, và các bài của nó đứng cạnh nhau

- **Status:** accepted (G3 2026-08-05)
- **Type:** feature
- **Horizon:** không thuộc H5. Slice này là **hệ quả thứ hai** của 0052, sinh ra từ manual test G4 của 0053. Không chạm audio, không chạm mạng, không chạm tiền
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0019 (`accepted` G2 — **quyết định 11, viết lại ở revision 5 riêng cho slice này**), 0005, 0008, 0013 (tier), 0015 (ngôn ngữ), 0016 (mô hình)
- **Depends on Specs:** **0052** (`PdfDocument`, `PageExtent`, `splitScore`, `SplitScoreScreen`, `PdfPageGrid`, handover), **0053** (`scoreOriginLine` trên hàng Library, lọc theo tệp nguồn), 0023 (sort), 0028 (xoá + đếm tham chiếu), 0024 (Replace PDF), 0040 (hàng Library)
- **Tier:** **M** — thêm **một trường nullable** vào `PdfDocument` (không di trú, `formatVersion` giữ `2`), một tham số cho `splitScore`, và phần còn lại là hiển thị. Đường mất dữ liệu duy nhất — tách một bài làm PageOrder của nó hẹp lại — **đã có sẵn cơ chế và test từ 0052**, dùng lại nguyên vẹn. G3 và G4, không cần ADR mới
- **G3:** **accepted 2026-08-05** — 11/11 câu theo khuyến nghị, gồm hai câu Orchestrator được cảnh báo là đi ngược một điều đã chốt (#2 đảo một ghi chú UX của 0053; #5 lệch khỏi "sort áp cho node cùng cấp") và #10 giữ bộ lọc của 0053 để hỏi lại ở G4
- **Security Review:** **không cần**. Không byte nào rời máy, không SDK mới, không quyền mới

> **Slice này sinh ra từ manual test G4 của 0053.** Orchestrator tách một PDF thành nhiều bài, rồi nói đúng hai câu: *"file PDF gốc lại không hiển thị, nên không có cách nào vào tạo score tiếp"*, và *"tên này có thể hiển thị trong tất cả các score con thay vì hiển thị tên file với đuôi `.pdf`"*.
>
> Đề nghị đầu tiên là **tạo một Score gốc ứng với cả file PDF**, không xoá được khi còn bài con tham chiếu. Đề nghị ấy giải đúng cả hai chỗ hỏng, và **bị bác một nửa**: cuốn sách được cái tên và được một hàng, nhưng **không được là một `Score`** — xem Vấn đề. ADR 0019 quyết định 11 đã được viết lại (revision 5) để nói ranh giới mới, vì nó không lách qua được.

---

## Vấn đề (Problem)

Hai chỗ hỏng, và cả hai đều đang ở trên máy nhạc công ngay hôm nay.

**Một: tách một lần rồi là đường cụt.** Lối vào màn hình tách yêu cầu Score phủ **cả tệp** (`_canSplit`, `library_screen.dart:972-978`). Tách xong thì không Score nào còn phủ cả tệp, nên mục *"Split into pieces…"* biến mất khỏi mọi hàng của cuốn sách đó — vĩnh viễn. Nhạc công tách 148 trang thành 4 phần, rồi nhận ra phần 3 gồm 6 bài cần tách nhỏ tiếp, thì đường duy nhất là **xoá cả 4 bài và nhập lại tệp**, mất mọi ghi chú, mọi Label, mọi PageOrder. Mục *"Pages…"* không giải được việc này: nó **đổi** phạm vi của một bài, không **chia** nó ra.

**Hai: cuốn sách không có tên nào ngoài tên tệp.** Thứ duy nhất đặt tên cho nó là `PdfDocument.originalFileName`, và tên tệp thật thường là `chopin-etudes-complete-ed-paderewski.pdf`. Dòng nguồn gốc 0053 vừa đưa lên hàng Library, nên **28 hàng** cùng đọc lên cái tên ấy, và không có chỗ nào sửa được — vì không có gì để sửa.

**Vì sao cuốn sách không được là một `Score`.** Không phải vì thủ tục, mà vì `Score` là **đơn vị chơi được** — đó là toàn bộ nội dung của quyết định 2 trong ADR 0019. Một `Score` 148 trang tồn tại song song với 28 bài của chính nó sẽ phải trả lời: nó vào Setlist thì nhạc công đang mang gì lên sân khấu; MeasureMap của nó là gì (slice 4 sắp dựng MeasureMap cho **mỗi** Score); SyncMap của nó là bài nào; nó đi vào SongPack dưới dạng gì. Bốn câu ấy không có câu trả lời nào dùng được, và chúng không hiện ra ở slice này — chúng hiện ra ở slice 4 và slice 10, lúc đã quá muộn.

Nên ranh giới dịch **đúng một bước**: `PdfDocument` được **một cái tên** và **một hàng tiêu đề nhóm các bài của nó lại**; nó không được một `Score`, không thumbnail, không mở ra được, không vào Setlist được, không xoá cả cuốn được. Hàng tiêu đề không mang dữ liệu nào của riêng nó ngoài cái tên — nó là **cách danh sách trông ra khi nhiều bài thuộc về nhau**, không phải một thực thể để quản lý.

### Mười thứ đọc từ repo, và cả mười đổi thiết kế của slice

1. **`_canSplit` và `_isPiece` là phần bù chính xác của nhau** (`library_screen.dart:972-986`), nên `⋯` luôn cho đúng một trong hai, không bao giờ cả hai — comment ở dòng 1748 nói thẳng "mutually exclusive". Đó chính là chỗ sinh ra đường cụt, và nó phải thôi là phần bù.
2. **`splitScore` kẹp mọi mốc vào `1..pageCount` và cho extent cuối kết thúc ở `pageCount`** (`score_library.dart:218-226`). Nên "tách trong phạm vi một bài" là **một tham số** ở đây, không phải viết lại — thay `pageCount` bằng biên của phạm vi.
3. **`PdfDocument.copyWith` chỉ mang `pageCount` và `relativePath`** (`pdf_document.dart:44-50`), và **`replacePdf` dựng lại `PdfDocument(...)` từng trường một** (`score_library.dart:308-314`). Thêm một trường mà bỏ sót chỗ thứ hai thì **tên cuốn sách mất im lặng khi Replace PDF** — không lỗi, không test đỏ, chỉ là cái tên biến mất. Đây là cái bẫy đắt nhất của slice.
4. **`PdfPageGrid` là 1-based trên cả tệp** (`itemCount: pageCount`, `page = index + 1`, `pdf_page_grid.dart:72-74`). Nó cần một trang bắt đầu, và trang ấy phải **tuỳ chọn**: `PageExtentScreen` bắt buộc vẫn thấy cả tệp, vì dời biên của một extent nghĩa là đi ra ngoài extent đó.
5. **`SplitScoreScreen._frontMatterCount = _starts.first - 1`** và câu *"Pages 1–N are not in any piece."* (`split_score_screen.dart:82, 203-211`) giả định trang đầu của khung lưới là trang 1 của tệp. Trong một lần tách con, câu ấy **sai**, và việc nó mô tả — bỏ rơi mấy trang đầu — là một hành vi khác hẳn: bỏ bìa của một cuốn sách là bỏ thứ không phải nhạc, còn bỏ mấy trang đầu của **một bài** là bỏ nhạc mà nhạc công đã chọn giữ, có thể đã ghi chú lên.
6. **`_titleFor` trả `'<bookTitle> — <chỉ số trong lần tách này>'`** (`split_score_screen.dart:84-90`). Nếu lần tách con truyền tên **cuốn sách** vào thì tên mặc định **đụng với tên của lần tách trước**: cuốn sách đã có "Book — 1/2/3", tách con sinh ra "Book — 1/2/3" lần nữa. Truyền tên **của bài đang bị tách** thì hết đụng.
7. **`splitScore` gán tiêu đề của mốc đầu cho chính Score gốc** (`score_library.dart:229-234`). Trong một lần tách con, nếu mốc đầu không có tên thì bài đang bị tách **bị đổi tên** thành "Part Two — 1". Phải mồi sẵn mốc đầu bằng tên hiện tại của nó.
8. **`handOverPageScales` và `restrictPageOrderTo` đã làm việc theo quyền-sở-hữu-trang, không theo "cuốn sách"** (`split_handover.dart:21-41, 67-86`): chúng nhận `originalScoreId` cộng danh sách Score của tệp và hỏi extent nào chứa trang nào. Một lần tách con **dùng lại cả hai không sửa một dòng**. Đây là lý do slice này là tier M chứ không phải L.
9. **`scoreOriginLine` đã trả về đúng `"Pages 12–19"` khi `documentName == null`** (`score_origin.dart:23-25`). Nên làm dòng nguồn gốc ngắn lại bên trong một nhóm là **truyền `null` ở chỗ gọi**, không phải đẻ thêm một hàm dựng câu — luật "câu chữ có đúng một định nghĩa" của 0052 giữ nguyên.
10. **Thân danh sách Library là `ListView.separated` trên một `List<Score>` phẳng** (`library_screen.dart:1664-1667`), và **`sortScores` là hàm thuần trên `List<Score>`** với ba chế độ (`library_sort.dart:19-47`). Nhóm vì thế là: **làm phẳng thành một danh sách hàng** (tiêu đề | bài) rồi vẫn `ListView.separated`. Không widget danh sách mới, không cây.

---

## Kết quả (Outcome)

Nhạc công nhập `chopin-etudes-complete-ed-paderewski.pdf`, tách thành 4 phần, đổi tên cuốn sách thành *Chopin Etudes*, rồi tách phần 3 thành 6 bài — không xoá gì, không nhập lại gì. Library cho thấy 9 bài ấy nằm dưới **một** tiêu đề *Chopin Etudes · 9 pieces*, theo thứ tự trang, và mỗi bài đọc lên *"Pages 41–46"* thay vì lặp lại tên cuốn sách chín lần.

**Thứ không đổi, và đây là tiêu chí G4 quan trọng nhất — cùng câu với 0052 và 0053:** người chưa bao giờ tách gì cả mở app lên và **không thấy một khác biệt nào**. Không tiêu đề nhóm nào (nhóm chỉ mọc khi một tệp có từ `2` Score trở lên), không mục `⋯` nào mới trên hàng của họ ngoài *"Split into pieces…"* — mục vốn **đã có** ở đó.

---

## Trong phạm vi (In scope)

**A. Cuốn sách có tên**

- `PdfDocument.title` — `String?`, mặc định `null`, ghi vào `library.json` như một trường bình thường. `formatVersion` giữ `2`, không di trú, backup cũ đọc lên cho `null`.
- Một hàm hiển thị duy nhất — `PdfDocument.displayName` — trả `title` nếu có, ngược lại `originalFileName` **đã bỏ phần mở rộng**, ngược lại một câu cuối cùng cho tệp không có tên.
- `ScoreLibrary.renameDocument(documentId, title)` — ghi qua đúng cái writer nguyên tử đã có; `title` rỗng sau `trim()` nghĩa là **về mặc định**, không phải một cái tên rỗng.
- **Ba chỗ đang đọc `originalFileName` chuyển sang `displayName`**: dòng nguồn gốc trên hàng Library, danh sách nguồn trong sheet lọc và chip lọc (0053), thanh gợi ý tách (0052).
- `copyWith` mang `title`, **và `replacePdf` dùng `copyWith`** thay vì dựng lại từng trường — xem dữ kiện 3.

**B. Tách lặp lại được, trong phạm vi của chính Score bị tách**

- `⋯` của một bài có **cả** *"Split into pieces…"* **và** *"Pages…"*; hai mục thôi loại trừ nhau. Điều kiện mở màn hình tách trở thành: **phạm vi của bài có từ `2` trang trở lên**.
- Màn hình tách nhận một phạm vi trang; `PdfPageGrid` nhận `firstPage` tuỳ chọn.
- Trong một lần tách con: trang đầu của bài là **mốc cố định**, mồi sẵn bằng **tên hiện tại của bài**, không bỏ dấu được; không có câu "front matter"; `Save` mở khi có **thêm** ít nhất một mốc.
- `splitScore` nhận phạm vi và tính extent trong đó; handover page scale và PageOrder dùng lại y nguyên (dữ kiện 8), gồm cả việc **nói trước con số slot PageOrder sẽ mất** như 0052 G3 #5 đã đặt.
- **Chốt chặn:** lần tách phủ cả tệp chỉ mở khi tệp đang có **đúng một** Score. Không có nó, một người mở rộng `PageExtent` của một bài về phủ cả tệp qua *"Pages…"* rồi tách lần nữa sẽ sinh ra các Score **chồng trang lên nhau**, và không có gì trong mô hình dữ liệu chặn việc đó.

**C. Các bài của một cuốn sách đứng cạnh nhau**

- Sau lọc / tìm / sort, các Score cùng `pdfDocumentId` **mà tệp đó có từ `2` Score trở lên** được gom dưới một hàng tiêu đề: `displayName`, số bài, và `⋯` với đúng một mục — *"Rename book…"*.
- Sort áp cho **hàng cùng cấp**: tiêu đề nhóm và bài lẻ xếp cùng nhau theo khoá của chế độ đang chọn; bên trong một nhóm, các bài xếp theo **thứ tự trang**.
- Bên trong một nhóm, dòng nguồn gốc rút còn `"Pages 41–46"` (dữ kiện 9). Bài lẻ giữ nguyên câu đầy đủ của 0053.
- Tên cuốn sách vào **được** phạm vi tìm kiếm, nên gõ `Chopin` tìm ra cả những bài mà tiêu đề của chúng không có chữ đó.

---

## Ngoài phạm vi (Out of scope)

- **Thu gọn / mở ra nhóm.** Bản đầu không ẩn bài nào. Một danh sách có kết quả nằm sau một mũi tên đóng là một danh sách nói dối về việc nó đang cho xem gì, và cái giá của nó là trạng thái phải lưu, phải khôi phục, phải hoà giải với tìm kiếm và với lọc. Quyết định lại sau một tuần dùng thật — xem Ghi chú UX.
- **Xoá cả cuốn.** Xoá vẫn đi từng bài với đếm tham chiếu như 0028 và 0052 đã đặt. Một nút xoá 12 bài cùng lúc là bề mặt phá dữ liệu mới.
- **Một hàng, một tab, hay một màn hình danh sách tệp**, và mọi đường làm tiêu đề nhóm mở ra được, thumbnail được, hay vào Setlist được. ADR 0019 quyết định 11.
- **`PdfDocument` thành `Score`** — lý do ở phần Vấn đề.
- **Gộp hai cuốn sách, hay dời một bài sang cuốn khác.**
- **Bỏ bộ lọc theo tệp nguồn của 0053** — xem G3 #10.

---

## Câu hỏi G3 (G3 questions) — **đã trả lời 2026-08-05, cả 11 câu theo khuyến nghị**

| # | Câu hỏi | Khuyến nghị |
|---|---|---|
| 1 | **Nhãn cho `PdfDocument` khi người đọc thấy nó: `book`, `file`, hay `source`?** | **`book`.** Code đã gọi là `bookTitle`; *"Pages 12–19 of Chopin Etudes"* đọc lên tự nhiên; và `file` là chính cái từ kéo theo mô hình trình duyệt tệp mà quyết định 11 vừa từ chối lần thứ hai. Cái giá: một PDF gồm 3 bài rời thì gọi "book" hơi rộng — chịu được, vì nhãn chỉ xuất hiện ở **một** chỗ (*"Rename book…"*), còn hàng tiêu đề chỉ hiện **cái tên**, không hiện chữ "book". `PdfDocument` vẫn là term duy nhất trong `CONTEXT.md` và trong code, đúng hình dạng luật `SongPack`/`Packs` |
| 2 | **Tên mặc định có bỏ `.pdf` không? 0053 đã ghi rằng `.pdf` hiện ra là *cố ý*** | **Bỏ, và đây là chỗ đảo một ghi chú UX của 0053 — nên nói thẳng ra.** Lập luận cũ: tệp đúng là câu trả lời cho câu "bài này ở đâu ra". Lập luận ấy đúng khi thứ duy nhất app biết là một tên tệp. Nay cuốn sách **có tên riêng**, nên hàng tiêu đề nói về **một cuốn sách**, không nói về một tệp, và `.pdf` ở đó chỉ còn là rác kỹ thuật. `originalFileName` **vẫn nguyên** trong dữ liệu cho màn hình thông tin về sau |
| 3 | **Nhóm bật luôn, hay là một chế độ xem bật/tắt được?** | **Bật luôn, khi và chỉ khi một tệp có từ `2` Score trở lên.** Một hàng tiêu đề không phải một chế độ — nó là **cách danh sách trông ra khi nhiều bài thuộc về nhau**. Thêm một công tắc là thêm một tuỳ chọn phải lưu, phải giải thích, và phải test cả hai nhánh, để đổi lấy một cách xem mà lý do duy nhất để chọn là "tôi chưa quen cách kia". Cùng vị từ `2` với bộ lọc của 0053 (`isFilterableSource`), nên hai nơi không thể bất đồng về thế nào là một cuốn sách |
| 4 | **Khoá sort của hàng tiêu đề, cho từng chế độ?** | **`Title` → tên cuốn sách; `Created` → `PdfDocument.importedAt`; `Last viewed` → `max` của các bài, chưa mở bao giờ thì xuống cuối.** Chỗ đáng chú ý là `Created`: dùng `max(createdAt)` của các bài thì **`splitScore` gán `now` cho các bài mới**, nên cuốn sách **nhảy lên đầu mỗi lần tách tiếp** — một cuốn sách nhập từ tháng trước đứng cạnh cuốn nhập hôm nay. `importedAt` là ngày cuốn sách thật sự đến, và nó không nhảy |
| 5 | **Bên trong một nhóm, các bài xếp theo chế độ sort đang chọn, hay luôn theo thứ tự trang?** | **Luôn theo thứ tự trang** — và đây là chỗ khuyến nghị **đi lệch** khỏi câu "sort áp cho node cùng cấp" của Orchestrator, nên nó cần một câu trả lời rõ. Các bài của một cuốn sách có **một thứ tự tự nhiên duy nhất**, và đó là thứ tự trang; xếp chúng A–Z bên trong nhóm là bỏ thông tin để lấy về một thứ tự không ai cần. Cái mất: ở chế độ `Last viewed`, bài vừa chơi đưa **cả nhóm** lên đầu nhưng bên trong nhóm nó vẫn nằm ở đúng chỗ theo trang, nên có thể phải nhìn xuống vài hàng. Chịu được, và bù lại là nhóm luôn đọc được như một mục lục |
| 6 | **Hàng tiêu đề hiện những gì?** | **Tên, số bài, `⋯` với đúng một mục `Rename book…`.** Không thumbnail (đó là cái làm nó trông như một Score mở được), không tổng số trang (không trả lời câu hỏi nào ai đang hỏi), không ngày nhập. Cụ thể: *Chopin Etudes* và *`9 pieces`*, đơn số là *`1 piece`* — nhưng một nhóm 1 bài chỉ xuất hiện khi **tìm kiếm** thu hẹp nó, xem #7 |
| 7 | **Tìm kiếm khớp 1 bài trong cuốn 9 bài: vẫn hiện hàng tiêu đề (với `1 piece`), hay để bài đó đứng trơ?** | **Vẫn hiện tiêu đề.** Cùng lý do slice 0053 tồn tại: một hàng không nói nó ra từ đâu là một hàng nửa câu. Số đếm nói về **những gì đang thấy**, không về cả cuốn sách — nên nó là `1 piece`, và điều đó đúng theo nghĩa hẹp nhất: danh sách đang cho xem 1 bài của cuốn ấy. Vị từ để **có** nhóm vẫn tính trên cả thư viện (`2` Score), không trên phần đang thấy |
| 8 | **Tách con: trang đầu của bài là mốc cố định không bỏ được, hay bỏ được như trang 1 của cuốn sách?** | **Cố định.** 0052 revision 1 cho bỏ trang đầu của **cuốn sách** vì bìa và mục lục không phải nhạc, và vì bắt buộc đánh dấu trang 1 sinh ra một hàng rác cho mỗi cuốn. Cả hai lý do đều **không** áp cho một bài: mấy trang đầu của nó là nhạc nhạc công đã chọn giữ, có thể đã ghi chú lên, và đã có **đúng một** màn hình để đổi phạm vi một bài — *"Pages…"*. Hai đường bỏ trang mà khác nhau ở chỗ có cảnh báo hay không là loại chuyện cắn người về sau |
| 9 | **Tách con: tên mặc định của các bài mới?** | **Mốc đầu mồi sẵn bằng tên hiện tại của bài; các mốc sau là `<tên bài> — 2`, `— 3`.** Hai cái bẫy ở dữ kiện 6 và 7: truyền tên cuốn sách vào thì tên mới **đụng** với tên lần tách trước, còn bỏ trống mốc đầu thì bài đang bị tách **bị đổi tên**. Cách này chặn cả hai mà không sửa `_titleFor` một dòng |
| 10 | **Bộ lọc theo tệp nguồn của 0053 có còn lý do tồn tại sau khi có nhóm?** | **Giữ, và hỏi lại ở G4 — đừng quyết bây giờ.** Nhóm và lọc trả lời hai câu khác nhau: nhóm nói *"những bài này thuộc về nhau"*, lọc nói *"cho tôi xem **chỉ** cuốn này"* — với một thư viện 300 bài thì câu thứ hai vẫn có giá. Thứ **thật sự** thành thừa là mục *"Show all pieces of …"* trong `⋯` của một bài, vì bên trong một nhóm nó chỉ ẩn đi phần còn lại của danh sách mà không cho thêm gì. Khuyến nghị: giữ cả hai đúng một bản, rồi ở G4 xem có ai bấm không. Ngược lại — bỏ ngay bây giờ — cũng chấp nhận được và **rẻ hơn**, chỉ cần Orchestrator nói |
| 11 | **Đổi tên cuốn sách chỉ ở `⋯` của hàng tiêu đề, hay cả ở `⋯` của một bài?** | **Chỉ ở hàng tiêu đề.** Một bài đứng lẻ (phủ cả tệp) thì tên cuốn sách của nó **không hiện ở đâu cả** — dòng nguồn gốc của nó là `null` theo đúng thiết kế 0052 — nên cho đổi tên ở đó là cho sửa một thứ không nhìn thấy được. Kèm một câu ràng buộc: **đổi tên cuốn sách không bao giờ đổi tiêu đề của bài nào**, kể cả những bài mang tên mặc định `<cuốn sách> — 3` |

---

## Thuật ngữ miền (Domain terms)

**Không term mới.** `PdfDocument` đã có trong `CONTEXT.md` từ 0052. Thứ slice này thêm là một **nhãn cho người đọc** — `book` — và một luật đi kèm, cùng hình dạng với `SongPack`/`Packs` ở ADR 0019 quyết định 9: **`PdfDocument` trong `CONTEXT.md`, trong code, trong tài liệu; `book` chỉ ở chỗ người dùng đọc.**

`CONTEXT.md` sửa **một dòng**: mục `PdfDocument` ghi thêm rằng nó có `title` sửa được và người dùng thấy nó dưới nhãn *book*. Hàng tiêu đề **không** là một term — nó không có định nghĩa nào ngoài "các Score cùng một `PdfDocument`".

---

## Tiêu chí chấp nhận (Acceptance criteria)

**Người chưa tách gì không thấy gì đổi**

- Thư viện chỉ có Score phủ cả tệp: **không hàng tiêu đề nào**, `⋯` không thêm mục nào so với hôm nay, dòng nguồn gốc vẫn không xuất hiện.
- `library.json` của họ đọc được nguyên vẹn sau khi nâng bản; `formatVersion` vẫn là `2`; backup tạo trước slice này restore được và không mất gì.

**Cuốn sách có tên**

- Đổi tên cuốn sách → **mọi** bài của nó đọc tên mới ở dòng nguồn gốc và ở danh sách nguồn; **không** bài nào bị đổi tiêu đề.
- Tên rỗng sau `trim()` → về mặc định (tên tệp đã bỏ phần mở rộng), không phải một tên rỗng.
- **Replace PDF không làm mất tên cuốn sách** — dữ kiện 3, và đây là một test, không phải một ghi chú.
- Khởi động lại app: tên còn đó.

**Tách lặp lại được**

- Bài 4 trang: `⋯` có **cả** *"Split into pieces…"* và *"Pages…"*.
- Bài 1 trang: **không** có *"Split into pieces…"*.
- Tách bài `Pages 41-60` ở trang `47`: sinh ra `41-46` và `47-60`; bài đầu **giữ tên cũ**; không trang nào của cuốn sách đổi chủ ngoài `47-60`; các bài **khác** của cuốn sách không đổi một trường nào.
- Màn hình tách của một bài **chỉ bày các trang của bài đó**, và **không** có câu "not in any piece".
- Override page scale ở trang `52` theo bài mới sau khi tách; PageOrder của bài gốc bị thu hẹp và **số slot mất được nói ra trước khi xác nhận**.
- Tách con **hai lần liên tiếp** trên cùng cuốn sách vẫn cho các extent **không chồng nhau và không hở** trong phạm vi từng lần tách.
- **Không có đường nào sinh ra hai Score chồng trang:** mở rộng một bài về phủ cả tệp qua *"Pages…"* rồi thử tách phủ cả tệp lần nữa — bị chặn vì tệp có nhiều hơn một Score.

**Các bài đứng cạnh nhau**

- Tệp có `2` Score trở lên: một hàng tiêu đề mang `displayName` và số bài; các bài của nó **liền nhau** và **theo thứ tự trang** ở cả ba chế độ sort.
- Đổi chế độ sort: **vị trí của nhóm** đổi theo khoá ở G3 #4; thứ tự bên trong nhóm **không** đổi.
- Bên trong nhóm, dòng nguồn gốc là `Pages 41–46` — **không** có `of …`.
- Tìm `Chopin` khi không bài nào có chữ đó trong tiêu đề nhưng cuốn sách tên *Chopin Etudes*: các bài hiện ra, dưới tiêu đề của cuốn, với số đếm bằng số bài **đang thấy**.
- Lọc theo Label thu về 1 bài của cuốn 9 bài: tiêu đề vẫn hiện, `1 piece`.
- Xoá dần từng bài đến khi còn `1`: hàng tiêu đề **biến mất**, bài cuối đứng lẻ như mọi Score phủ một phần tệp.

**Bản dựng**

- `flutter analyze` sạch; toàn bộ suite xanh; không test cũ nào phải sửa vì hành vi đổi ngoài những chỗ Spec này nói.

---

## Ghi chú UX (UX notes)

**Nhóm không phải cây, và khoảng cách giữa hai thứ đó là chỗ dễ trượt nhất của slice.** Một cây có node đóng được, có trạng thái mở/đóng phải lưu, và có câu hỏi "tìm kiếm khớp một bài trong nhóm đang đóng thì sao" — không có câu trả lời nào tốt cho câu ấy. Một nhóm chỉ có hàng tiêu đề: **mọi kết quả luôn nhìn thấy được**. Điều giữ đường mở cho tương lai là nhóm đúng là **tiền tố** của cây — nếu sau một tuần dùng thật hoá ra thư viện dài quá thì thêm thu gọn là thêm một trạng thái vào thứ đã dựng, không phải dựng lại.

**Hàng tiêu đề phải trông như một tiêu đề, không như một Score.** Không thumbnail, không mũi tên `>`, không bấm vào cả hàng được — chỉ tên, số bài, và `⋯`. Bấm được vào hàng là lời hứa "có gì đó mở ra", và không có gì mở ra.

**Tách một bài và đổi phạm vi một bài phải phân biệt được ngay từ nhãn.** Hai mục nay đứng cạnh nhau trong `⋯`: *"Split into pieces…"* là **chia bài này ra**, *"Pages…"* là **đổi bài này gồm những trang nào**. Nhãn ngắn thế đủ vì cả hai mở ra một lưới trang có nhãn riêng ở AppBar.

**Câu của 0052 và 0053 nhắc lại lần thứ ba:** người không có cuốn sách nào trong thư viện đi hết slice này mà **không biết nó đã xảy ra**.

---

## Ràng buộc kỹ thuật (Technical constraints)

- **Một trường nullable, ba chỗ ghi.** `title` phải đi qua `toJson`, `fromJson`, `copyWith` **và** chỗ dựng lại `PdfDocument` trong `replacePdf` — chỗ thứ tư này là chỗ bỏ sót sẽ không kêu. Sửa `replacePdf` sang dùng `copyWith` để không còn chỗ thứ tư.
- **Nhóm là hàm thuần, tách khỏi widget.** Vào: `List<Score>` đã lọc/tìm/sort, `Map<String, PdfDocument>`, chế độ sort. Ra: một `List` hàng phẳng gồm tiêu đề và bài. Cùng hình dạng `filterScoresBySource` của 0053 và test được không cần `WidgetTester`.
- **Vị từ "có phải một cuốn sách" chỉ có một định nghĩa:** `countScoresByDocument` + ngưỡng `2` của 0053, dùng lại. Hai định nghĩa là hai nơi bất đồng.
- **`PdfPageGrid` nhận `firstPage` mặc định `1`.** `PageExtentScreen` **không** truyền — nó phải thấy cả tệp.
- **Không hàm dựng câu thứ hai cho nguồn gốc.** Bên trong nhóm truyền `documentName: null` (dữ kiện 9).
- **`splitScore` nhận phạm vi tuỳ chọn, mặc định cả tệp.** Trường hợp cuốn sách nguyên vẹn phải đi qua **đúng cùng một** nhánh code, không phải một nhánh song song.
- **Không đổi `formatVersion`, không di trú, không dời byte nào trên đĩa.**
- **Doc comment của `PdfDocument` phải sửa cùng lượt.** Nó đang viết *"nothing in the UI lists PdfDocuments"* (`pdf_document.dart:7-9`) — câu ấy thành sai ở slice này, và một comment nói sai về màn hình là cách rẻ nhất để người sau dựng lại đúng thứ ADR 0019 vừa từ chối. Câu mới phải nói **cả hai vế**: có tên và có hàng tiêu đề; không bao giờ là một `Score`.

---

## Kế hoạch kiểm thử (Test plan)

**Automated**

- `pdf_document_title_test.dart` — `displayName` với `title` / chỉ `originalFileName` / không gì; bỏ phần mở rộng; `copyWith` mang `title`; round-trip JSON, và JSON **không** có `title` đọc lên `null`.
- `library_grouping_test.dart` — hàm nhóm thuần: ngưỡng `2`; thứ tự trang bên trong nhóm ở cả ba chế độ; khoá sort của nhóm (gồm cả `importedAt` cho `Created`); nhóm chỉ còn 1 bài sau lọc; thư viện không có nhóm nào.
- `resplit_test.dart` — tách trong phạm vi: extent sinh ra nằm gọn trong phạm vi; bài gốc giữ tên; các bài khác của tệp không đổi; hai lần tách con liên tiếp; chốt chặn tách phủ cả tệp khi tệp có nhiều hơn một Score.
- `resplit_handover_test.dart` — page scale theo trang đổi chủ đúng; PageOrder của bài gốc bị thu hẹp và trả về số slot mất.
- `rename_document_test.dart` — đổi tên rồi đọc lại; tên rỗng về mặc định; **Replace PDF giữ tên**; tiêu đề Score không đổi.
- `library_book_test.dart` (widget) — tiêu đề hiện/không hiện; số đếm; `Rename book…` đổi mọi dòng nguồn gốc của nhóm; dòng nguồn gốc rút gọn bên trong nhóm; tìm theo tên cuốn sách; `⋯` của một bài có cả hai mục; tách con trọn vòng từ hàng của một bài.
- `library_screen_test.dart`, `library_source_filter_test.dart` — chạy lại, và **không được phải sửa** ngoài chỗ dòng nguồn gốc rút gọn bên trong nhóm.

**Đã viết xong (2026-08-05)** — bảy file trên, `flutter analyze` sạch, toàn bộ suite xanh. Hai chỗ phải sửa ngoài dự kiến, và cả hai đều là **hành vi**, không phải kỳ vọng test:

1. `displayName` bỏ phần mở rộng bằng "dấu chấm cuối cùng", nên một cuốn tên `Vol. 2` đọc lên thành `Vol`. Nay chỉ bỏ đúng hậu tố `.pdf`.
2. `splitScore` tính điểm cuối của mỗi bài từ mốc **chưa kẹp** của bài sau. Với một mốc nằm ngoài phạm vi, hai bài cùng nhận một trang — đúng thứ dữ kiện 11 nói là không có gì trong mô hình dữ liệu ngăn được. Nay kẹp trước rồi mới cắt, và hai mốc rơi vào cùng một trang là một mốc.

Ngoài ra `library_split_test.dart` phải sửa một nhóm test: `⋯` của một bài nay có **cả hai** mục, và đường tách nay hỏi trước khi bỏ slot PageOrder ở **mọi** trường hợp, kể cả tách cả cuốn sách — chỗ 0052 làm im lặng.

Một chỗ đi khác Ràng buộc kỹ thuật và đi theo hướng chặt hơn: `splitScore` **không** nhận thêm tham số phạm vi, nó đọc `original.extentIn(pageCount)` của chính Score đang bị tách. Cùng một nhánh code cho cả hai ca như Spec đòi, nhưng **không chỗ gọi nào truyền được một phạm vi sai** — một tham số thì có.

**Manual demo (G4)**

1. Thư viện chỉ có bản nhạc một-bài-một-tệp → mở app, **không thấy gì mới**.
2. Nhập một tệp tên xấu, tách thành 4 phần → thấy nhóm với tên tệp đã bỏ `.pdf`.
3. `Rename book…` thành *Chopin Etudes* → cả 4 hàng đọc tên mới, tiêu đề bài không đổi.
4. Tách phần 3 thành 6 bài → nhóm thành 9 bài, thứ tự trang đúng, không mất ghi chú của các phần khác.
5. Đổi qua cả ba chế độ sort → nhóm dời chỗ, bên trong không đổi.
6. Tìm `Chopin` → 9 bài dưới một tiêu đề. Tìm tên một bài → 1 bài dưới tiêu đề `1 piece`.
7. Ghi chú lên một trang của phần 3, đặt PageOrder, rồi tách phần 3 lần nữa → ghi chú còn đúng trang, và app **nói trước** số slot PageOrder sẽ mất.
8. `Replace PDF…` trên một bài → tên cuốn sách còn nguyên.
9. Xoá dần đến khi còn 1 bài → tiêu đề biến mất.
10. Khởi động lại app → tên, nhóm, phạm vi các bài đều còn.
