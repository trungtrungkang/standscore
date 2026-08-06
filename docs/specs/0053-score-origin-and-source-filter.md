# 0053 — Nguồn gốc trên hàng Library, và lọc theo tệp nguồn

- **Status:** accepted (G3 2026-08-05)
- **Type:** feature
- **Horizon:** không thuộc H5. Slice này là **hệ quả** của 0052: tách một cuốn sách thành 28 bài xong thì Library có 28 hàng mà không gì nói chúng đến với nhau. Không chạm audio, không chạm mạng, không chạm tiền
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0019 (`accepted` G2 2026-08-05 — **quyết định 11** là ràng buộc chính của slice này), 0017 (phương án "kệ riêng" đã bị bác), 0005, 0008, 0013 (tier), 0015 (ngôn ngữ), 0016 (mô hình)
- **Depends on Specs:** **0052** (`PdfDocument`, `PageExtent`, `scoreOriginLine`), 0021 (Label filter — **hình dạng được dùng lại**), 0023 (sort), 0040 (Library row, `pageCount`, thumbnail)
- **Tier:** **M** — không đổi lược đồ dữ liệu, không di trú, không đường mất dữ liệu, không dependency, không quyền. Bộ lọc là một **phép đọc**; dòng nguồn gốc là **hiển thị**. G3 và G4, không cần ADR mới
- **G3:** **accepted 2026-08-05** — 11/11 câu đã trả lời (8 câu gốc theo khuyến nghị, 3 câu mới sinh ra từ đợt đọc code), Orchestrator ký accept nguyên bản
- **Security Review:** **không cần**. Không byte nào rời máy, không SDK mới, không quyền mới, không đọc thêm gì từ tệp

> **Slice này sinh ra từ manual test G4 của 0052, không từ bảng Trình tự của ADR 0019.** Orchestrator tách 148 trang thành nhiều bài rồi nói đúng một câu: *"nhìn vào đây không biết score này đến từ đâu."* Câu ấy đúng theo nghĩa hẹp nhất có thể — nguồn gốc **đã** là dữ liệu, **đã** có hàm dựng câu, **đã** hiện ở hai màn hình khác, và **không** hiện ở đúng màn hình người ta nhìn.
>
> Nó chen vào **trước** MeasureMap: xem bảng Trình tự của ADR 0019 (revision 4).

---

## Vấn đề (Problem)

Tách xong một tuyển tập, Library có thêm 27 hàng. Mỗi hàng đúng là một bài — tên của nó, số trang của nó, thumbnail của nó, đúng như 0052 đã hứa. Nhưng **không hàng nào nói nó ra từ đâu**, và ba chế độ sort đều làm chúng tản ra giữa thư viện.

Đề nghị đầu tiên của Orchestrator là **nhóm chúng vào Score gốc**. Đề nghị ấy bị bác, không vì thủ tục mà vì bốn câu hỏi một hàng đại diện cho cuốn sách bắt phải trả lời — xem Ngoài phạm vi. Thứ được chọn thay vào là hình dạng ADR 0019 revision 1 đã chốt cho SongPack và dùng lại nguyên vẹn ở đây: **cuốn sách không phải nơi *chứa* Score, nó là *thuộc tính* của Score.** Bày theo thuộc tính thì được; một thực thể để quản lý thì không.

### Tám thứ đọc từ repo, và cả tám đổi thiết kế của slice

| # | Điều đọc được | Bằng chứng | Hệ quả |
|---|---|---|---|
| 1 | **`scoreOriginLine` đã tồn tại và đã được hai màn hình dùng — Library row là chỗ duy nhất chưa gọi nó** | `library/score_origin.dart:9-26`; gọi từ `PdfModeScreen` (`library_screen.dart:1036-1040`) và `SetlistSession` (`setlist_session.dart:63-67`); còn `subtitle` của hàng là `Text(_recencyLine(score))` cộng chip Label (`library_screen.dart:1558-1568`) | Nửa đầu slice này là **một chỗ gọi hàm**, không phải một tính năng. Đó cũng là lý do nó rẻ, và là lý do nó phải đi trước phần lọc |
| 2 | **`_recencyLine` đã gộp hai dữ kiện bằng `·`** — *"Opened yesterday · 8 pages"* | `library_screen.dart:1613-1620` | Nối nguồn gốc vào đó cho một câu dài và trộn hai loại thông tin khác hẳn nhau (thời gian và nguồn gốc). Dòng riêng thì đổi `isThreeLine`, mà `isThreeLine` hôm nay bật theo **Label** (`library_screen.dart:1557`) — nên hàng có cả Label và nguồn gốc là **bốn dòng** trong một `ListTile` vốn tính cho ba. Đây là câu G3 số 1 |
| 3 | **Không chế độ sort nào giữ các bài của một cuốn cạnh nhau, và `Created` tách cuốn sách thành 1 + 27** | `library/library_sort.dart:19-47`; `splitScore` giữ `createdAt` của Score gốc cho bài đầu và cấp `now` cho các bài sau (`score_library.dart:229-246`) | `Title` chỉ dính khi tên là mặc định `Book — n`, và tên lấy từ mục lục thì tản; `Last viewed` tản dần theo thứ tự chơi; `Created` dính 27 bài lại nhưng **bài đầu nằm riêng**. Nên sort không phải câu trả lời cho câu hỏi này, và đó là căn cứ chọn bộ lọc |
| 4 | **Bộ lọc Label là một hàm thuần trên `List<Score>`**, nhận sẵn bảng gán nhãn | `label/label_filter.dart:5-31` | Lọc theo nguồn **đơn giản hơn một bậc**: thuộc tính đã nằm trên chính `Score` (`pdfDocumentId`), không cần bảng gán nào. Nên thứ được dùng lại là **hình dạng** (hàm thuần, test không cần `Directory`), không phải bản thân hàm |
| 5 | **Bộ lọc hôm nay không persist** — mở lại app là bộ lọc trắng | `_filterLabelIds` / `_filterMode` là State thuần (`library_screen.dart:98-99`), **không store nào ghi chúng**; `library_screen.dart:460-463` chỉ là đường restore backup, không phải đường khởi động — bản nháp trích nhầm chỗ cho một kết luận đúng | Lọc theo nguồn cũng **không được** persist, nếu không thì hai chiều của cùng một hộp lọc có hai tuổi thọ khác nhau — loại chi tiết không ai giải thích được sau sáu tháng. Kèm một việc nhỏ dễ quên: khối reset ở `460-463` phải học thêm chiều nguồn, nếu không thì restore xong bộ lọc còn nửa bên |
| 6 | **Cả UI lọc được viết cho *một* chiều** | `_filterActive` (`library_screen.dart:555-556`), `_filterDescription()` (`570-578`), hàng chip (`1353`), câu rỗng *"No scores match …"* (`1517`) | Đây là **chi phí thật của slice**, không phải phép lọc. Bốn chỗ ấy phải học được rằng có hai chiều, và câu rỗng phải nói **chiều nào** đã làm danh sách trống — nếu không, người lọc theo cuốn sách rồi lọc theo Label sẽ thấy danh sách trắng mà không biết bỏ cái nào |
| 7 | **Chỉ tệp có ≥ 2 Score mới có "nguồn" đáng lọc** — nhưng **phép đếm có sẵn không dùng được** | `scoreOriginLine` trả `null` cho Score trọn tệp (`score_origin.dart:14-19`); `scoresSharingDocument` (`score_library.dart:275-282`) là **`Future<int>` và đọc lại manifest mỗi lần gọi** — bản nháp ghi "đã đếm sẵn", không đúng | Danh sách nguồn **không** liệt kê mọi tệp trong thư viện — làm thế là dựng đúng danh sách tệp mà ADR 0019 quyết định 11 cấm. Nó liệt kê **những cuốn đã tách**, và với thư viện chưa tách gì thì nó **rỗng, nên không có gì hiện ra**. Phép đếm lấy từ `_scores` đang nằm trong State (G3 số 11) |
| 8 | **`documentFor` đọc từ map đã cache, đồng bộ** | `_documentsById` (`score_library.dart:64-66`) | Hàng lấy được nguồn gốc **ngay trong `itemBuilder`**, không cần async, không cần `FutureBuilder`. Nếu chỗ nào phải `await` để vẽ một hàng thì thiết kế đã đi sai |

---

## Kết quả (Outcome)

Nhạc công tách `Chopin Etudes.pdf` thành 24 bài. Mỗi hàng trong Library nay có thêm một dòng: *"Pages 12–19 of Chopin Etudes.pdf"*. Câu hỏi "bài này ở đâu ra" trả lời được bằng cách **nhìn**, không phải bằng hai lần bấm.

Khi cần làm việc với cả cuốn — soát lại sau khi tách, xếp cả cuốn vào một Setlist, đổi nhãn hàng loạt — họ mở `⋯` của một bài và chọn *"Show all pieces of Chopin Etudes.pdf"*. Danh sách thu về đúng 24 hàng ấy, một chip ở đầu nói đang lọc theo cái gì, bấm `×` là ra.

**Thứ không đổi, và đây là tiêu chí G4 quan trọng nhất — cùng câu với 0052:** người chưa bao giờ tách gì cả mở app lên và **không thấy một khác biệt nào**. Không dòng thêm trên hàng nào, không chip nào, không mục nào trong `⋯`, không danh sách nguồn nào — vì cả bốn thứ đó đều mọc ra từ `pageExtent`, và họ không có cái nào.

---

## Trong phạm vi (In scope)

**Nguồn gốc trên hàng Library**

- Hàng Library gọi `scoreOriginLine` — **hàm đã có, không viết mới** — và chỉ vẽ dòng ấy khi nó trả về khác `null`
- Bố cục hàng chịu được **cả** Label lẫn nguồn gốc cùng lúc (G3 số 1)

**Lọc theo tệp nguồn**

- `lib/library/source_filter.dart` — hàm **thuần**: `List<Score>` + `pdfDocumentId?` → `List<Score>`. Không nhận `Directory`, không nhận `ScoreLibrary`
- Kết hợp với bộ lọc Label bằng **giao** (G3 số 4)
- Hai lối vào: một mục trong `⋯` của một bài (*"Show all pieces of …"*), và danh sách nguồn trong hộp lọc. Cả hai dùng **một** vị từ "tệp này có ≥ 2 Score", dựng từ `_scores` trong State (G3 số 5 và 11)
- Danh sách nguồn chỉ gồm `PdfDocument` có **≥ 2** Score, sắp theo `originalFileName` A–Z (dữ kiện 7, G3 số 6)
- `showLabelFilterSheet` tách sang `lib/ui/library_filter_sheet.dart` thành `showLibraryFilterSheet`, tiêu đề *"Filter"*; mục nguồn hiện cả khi mode là `Untagged` (G3 số 9)
- Chip đang-lọc mang **loại** tường minh thay cho quy ước `id: null` (G3 số 10), phân biệt được với chip Label bằng icon
- `_filterDescription()` nói được cả hai chiều, và câu rỗng nói **chiều nào** đang làm danh sách trống (dữ kiện 6, G3 số 4)

**Không lưu gì**

- Bộ lọc nguồn **không persist**, đúng như bộ lọc Label hôm nay (dữ kiện 5). Không khoá mới trong prefs, không trường mới trong `library.json`, `formatVersion` **không đổi**

---

## Ngoài phạm vi (Out of scope)

- **Một hàng đại diện cho cuốn sách trong Library**, tab "Files", hay thư mục — ADR 0019 quyết định 11, và ADR 0017 đã bác phương án "kệ riêng" vì nó tạo **hai vòng đời cho một khái niệm**. Bốn câu hỏi làm nó tốn kém, ghi lại để không ai đề nghị lại mà không trả lời chúng: bấm vào hàng ấy thì **mở gì** (mở cả tệp 148 trang chính là thứ việc tách ra để chấm dứt; xổ ra danh sách con thì nó là một thư mục); **xoá** nó là xoá 24 Score kể cả những bài đang nằm trong Setlist, tức nút nguy hiểm nhất của app tự xuất hiện mà không ai xin; nó cần thumbnail, số trang, `lastOpenedAt`, Label — tức một thứ **hình dạng Score mà không phải Score**; và nó có vào Setlist, search, backup không — có thì hai vòng đời, không thì một công dân hạng hai không nhất quán
- **Sort mode "Source" và dòng tiêu đề nhóm.** Đây là **cắt có ý thức**, không phải bỏ sót: Orchestrator chọn chip lọc, và lọc giải bài toán bằng cách **thu hẹp** thay vì **gom**. Nếu G4 cho thấy vẫn cần thấy các bài cạnh nhau *mà không* thu hẹp danh sách, đó là một Spec sau
- **Search theo tên tệp** — search hôm nay tìm title và Label; thêm chiều thứ ba là câu hỏi riêng (G3 số 8)
- **Gán Label tự động tên cuốn sách lúc tách** — phương án này đã cân và bị bỏ: nó **giả một Label ra từ một dữ kiện đã có sẵn**, làm bảng Label của nhạc công đầy tên tệp, và Label thì persist trong khi nguồn gốc thì suy ra được
- **Gộp hai Score, chuyển một Score sang `PdfDocument` khác** — 0052 đã để ngoài, vẫn ngoài
- **Gom nhóm theo SongPack** — slice 8 (Spec 0060) **thừa hưởng** cơ chế của slice này; làm ngược lại là dựng hai lần
- **MeasureMap và mọi thứ của H5** — Spec 0054 trở đi

---

## Câu hỏi G3 (G3 questions) — **đã trả lời 2026-08-05**

Tám câu đầu chốt **theo khuyến nghị của bản nháp**. Ba câu cuối không có trong bản nháp: chúng sinh ra từ đợt đọc code để kiểm chính những khuyến nghị ấy, và cả ba đều là chỗ mà cách làm hiển nhiên nhất sẽ hỏng.

| # | Câu hỏi | Quyết định |
|---|---|---|
| 1 | **Nguồn gốc là dòng thứ ba riêng, hay nối vào `_recencyLine` bằng `·`? Và hàng có cả Label lẫn nguồn gốc thì cao bao nhiêu?** | **Dòng riêng, đứng *trên* chip Label, và hàng được phép cao thêm.** Nối vào `_recencyLine` cho ra *"Opened yesterday · 8 pages · Pages 12–19 of Chopin Etudes.pdf"* — một câu dài trộn thời gian với nguồn gốc, và trên máy hẹp nó bị cắt đúng chỗ quan trọng nhất. Đứng trên chip Label vì nguồn gốc là **tính chất của bản nhạc** còn Label là **thứ nhạc công gán vào**; đọc từ trong ra ngoài là thứ tự đúng. Thứ tự trong `subtitle`: `_recencyLine` → nguồn gốc → chip Label. `isThreeLine` chuyển thành `labelNames.isNotEmpty \|\| originLine != null`. **Dòng nguồn gốc dùng đúng style của `subtitle`, không đẻ style thứ tư** — vị trí đã đủ phân biệt nó với dòng recency, và một hàng bốn dòng với hai cỡ chữ là nhiễu chứ không phải thông tin |
| 2 | **Dòng ấy gọi tệp bằng tên tệp (`Chopin Etudes.pdf`) hay tên cuốn sách?** | **Tên tệp, tức đúng thứ `scoreOriginLine` đã làm.** Không phải vì đẹp hơn mà vì **tên cuốn sách không còn tồn tại một cách đáng tin**: 0052 G3 số 7 cho Score gốc **thành bài thứ nhất**, nên "tên cuốn sách" đã bị đổi thành tên của bài đầu ngay lúc tách. `PdfDocument.originalFileName` là dữ kiện không trôi. Cái giá là nhạc công thấy `.pdf` trong Library, thứ mà phần còn lại của app cố ý không cho thấy — chấp nhận được vì đây đúng là chỗ duy nhất mà **tệp** là câu trả lời |
| 3 | **Chip lọc nguồn đứng cùng hàng với chip Label hay tách riêng?** | **Cùng hàng, khác icon** (`Icons.picture_as_pdf_outlined` trên `avatar` của `InputChip`). Hàng chip là chỗ trả lời câu *"tại sao danh sách chỉ có bấy nhiêu"*, và câu đó không chia theo chiều. Tách riêng là hai chỗ phải cùng nhìn mới hiểu vì sao danh sách ngắn. Cách mã hoá chip phải đổi trước — xem câu 10 |
| 4 | **Hai chiều lọc kết hợp bằng giao hay hợp?** | **Giao.** Hai chiều **khác loại** thì giao là nghĩa duy nhất người ta mong: lọc `Chopin Etudes.pdf` rồi lọc `Gig` nghĩa là *"những bài của cuốn này mà tôi đánh dấu cho buổi diễn"*. Hợp cho ra một danh sách không ai hỏi. Trong một chiều thì giữ nguyên `any`/`all` của 0021. Câu rỗng ghép **cùng một chỗ** (`_filterDescription()`): chỉ Label thì như hôm nay, chỉ nguồn thì *"No scores match `Chopin Etudes.pdf`"*, cả hai thì *"No scores match Gig in `Chopin Etudes.pdf`"* — chữ **`in`** là thứ nói ra rằng có hai chiều đang bật |
| 5 | **Lối vào nào là chính — `⋯` của một bài, hay danh sách trong hộp lọc?** | **`⋯` của một bài là lối chính**, danh sách trong hộp lọc là lối phụ. Câu hỏi "cuốn này còn bài nào nữa" phát sinh **lúc đang nhìn một bài**, không phải lúc mở hộp lọc; và lối `⋯` không đòi nhạc công nhớ tên tệp. Câu chữ: *"Show all pieces of `Chopin Etudes.pdf`"*. **Điều kiện hiện mục ấy không phải `scoreOriginLine != null`, mà là "tệp này có ≥ 2 Score"** — cùng vị từ với danh sách nguồn (câu 6). Hai điều kiện gần trùng nhau nhưng lệch đúng một ca: một bài mà các bài anh em đã bị xoá hết vẫn **có** dòng nguồn gốc (đó là một dữ kiện về chính nó) mà **không** có mục `⋯` (một lối vào hứa "all pieces" rồi trả về đúng một hàng là một lời hứa sai). Ghi lại một dữ kiện để không ai viết lại vị từ: `_isPiece` (`library_screen.dart:857-862`) hôm nay đúng bằng điều kiện `scoreOriginLine != null`, nên nó là vị từ của **dòng**, không phải của **mục menu** |
| 6 | **Danh sách nguồn liệt kê gì, và sắp theo gì?** | **Chỉ `PdfDocument` có ≥ 2 Score, sắp theo `originalFileName` A–Z không phân biệt hoa thường, tie-break theo `id` cho thứ tự ổn định.** Liệt kê mọi tệp là dựng đúng danh sách tệp mà ADR 0019 quyết định 11 cấm, chỉ dán nhãn "bộ lọc". Ngưỡng `2` cũng là thứ làm mục này **tự biến mất** với thư viện chưa tách gì — không cần một nhánh riêng để ẩn nó. Hai tệp **trùng tên** (nhập cùng một tên hai lần) vẫn là **hai mục trùng chữ**, và đó là đúng: chúng là hai tệp, gộp lại mới là nói dối |
| 7 | **Lọc nguồn có sống qua lần mở app không?** | **Không**, y như bộ lọc Label hôm nay (dữ kiện 5). Một bộ lọc còn sống sau khi app khởi động lại là cách chắc nhất để nhạc công tin rằng bản nhạc của mình đã mất. Kèm hệ quả nhỏ: khối reset sau restore backup (`library_screen.dart:460-463`) phải xoá cả chiều nguồn |
| 8 | **Search có tìm theo tên tệp không?** | **Không ở slice này.** Search hôm nay tìm title và Label; thêm chiều thứ ba đổi ý nghĩa của mọi kết quả trong khi bộ lọc đã trả lời đúng câu hỏi này. Mở lại nếu G4 cho thấy người ta gõ tên tệp vào ô search theo phản xạ |
| 9 | **Danh sách nguồn đặt vào `showLabelFilterSheet` đang có, hay một hộp lọc khác?** | **Tách hàm ấy ra `lib/ui/library_filter_sheet.dart` thành `showLibraryFilterSheet`, tiêu đề đổi từ *"Filter by Label"* thành *"Filter"*.** Hai sheet còn lại **không đụng tới**, ở nguyên `label_sheets.dart`. Lý do không phải gọn gàng: sheet ấy sống trong tệp Label và chỉ import Label, nên nhét `PdfDocument` vào là để một tên hàm nói sai về việc nó làm — và tên sai ở đây rẻ hôm nay, đắt ở slice SongPack khi có chiều lọc thứ ba. Hai ràng buộc đi kèm: `SegmentedButton` `Any`/`All`/`Untagged` **vẫn chỉ nói về Label**, và mục nguồn phải hiện **cả khi** mode là `Untagged` — *"những bài chưa gán nhãn của cuốn này"* là câu hỏi có nghĩa, mà nhánh `Untagged` hôm nay thay chỗ toàn bộ danh sách bằng một câu |
| 10 | **Chip nguồn mã hoá thế nào trong hàng chip?** | **Phải bỏ quy ước `id: null` = `Untagged` trước.** Hàng chip hôm nay là `({String? id, String name})` và `_removeFilterChip(null)` **xoá cả bộ lọc** (`library_screen.dart:591-642`) — thêm chip nguồn theo hình dạng đó thì bấm `×` trên tên tệp sẽ xoá luôn bộ lọc Label, đúng loại lỗi không lộ ra ở review vì code đọc vẫn hợp lý. Chip mang một **loại** tường minh (`label` / `untagged` / `source`) và `_removeFilterChip` nhận loại ấy |
| 11 | **Đếm "tệp này có mấy Score" bằng gì?** | **Bằng `_scores` đang nằm trong State, không gọi `ScoreLibrary.scoresSharingDocument`.** Hàm ấy là `Future<int>` và **đọc lại manifest mỗi lần gọi** (`score_library.dart:275-282`), nên dùng nó ở `itemBuilder` của `⋯` là đưa `await` vào đường vẽ một hàng — đúng thứ Ràng buộc kỹ thuật cấm. `_scores` đã là danh sách đầy đủ và đồng bộ; một `Map<String, int>` dựng lại trong `_reload()` là đủ cho cả hai lối vào, và nó đảm bảo hai lối vào **không thể** bất đồng về việc cái gì là một "nguồn" |

---

## Thuật ngữ miền (Domain terms)

**Không term mới, và điều đó là có chủ ý.** Slice này chỉ làm hiện ra một quan hệ đã có tên: `Score` thuộc một `PdfDocument`, và `PageExtent` nói phần nào. `CONTEXT.md` **không cần sửa một dòng**.

Nhãn hiển thị thì không phải term: dòng trên hàng dùng đúng câu `scoreOriginLine` đã sinh (*"Pages 12–19 of Chopin Etudes.pdf"*), và mục trong `⋯` nói *"Show all pieces of …"*. Nếu một lúc nào đó cần một từ chung cho chiều lọc này thì nó là **`Source`** — nhưng chỉ trên UI, cùng hình dạng mà `Packs`/`SongPack` đã đặt tiền lệ (ADR 0019, G2 câu 5).

Term đã có mà Spec này dùng: **Score**, **PdfDocument**, **PageExtent**, **Label**, **Setlist**, **Library**, **ScoreMenu**.

---

## Tiêu chí chấp nhận (Acceptance criteria)

**Người chưa tách gì không thấy gì đổi**

- [x] Thư viện toàn Score trọn tệp: **không hàng nào** có dòng thêm, `⋯` **không** có mục mới, hộp lọc **không** có mục nguồn nào — `library_screen_test` ("a Score that is a whole file gains no line") và `library_source_filter_test` ("a library nobody has split shows no source at all")
- [x] Hàng của một Score trọn tệp có `pageExtent` phủ cả tệp cũng **không** hiện dòng nguồn gốc — cùng luật mà `scoreOriginLine` đã có, và `score_origin_test.dart` **không phải sửa một dòng**

**Nguồn gốc trên hàng**

- [x] Bài trang 12–19 của một cuốn 200 trang: hàng hiện *"Pages 12–19 of Chopin Etudes.pdf"*
- [x] Bài một trang nói *"Page 7 of …"*, không phải *"Pages 7–7"*
- [x] Tệp chưa đếm được số trang, hoặc thiếu `originalFileName`: hàng hiện phần trang, **không** hiện `null` và **không** biến mất — cùng hàm, đã khoá ở `score_origin_test.dart`
- [x] Hàng có **cả** Label và nguồn gốc: cả hai đọc được, không cái nào bị cắt — bốn dòng tràn khỏi `ListTile` thì widget test đỏ mà không cần assert thêm
- [ ] **G4:** đọc trên máy hẹp nhất có sẵn, một bài có Label dài

**Lọc theo tệp nguồn**

- [x] `⋯` của một bài → *"Show all pieces of …"* → danh sách còn đúng các bài của cuốn đó, không thiếu không thừa
- [x] Chip đang-lọc nói tên tệp, bấm `×` là về danh sách đầy đủ; đang bật cả hai chiều thì bấm `×` trên chip nguồn **chỉ** bỏ chiều nguồn
- [x] Bài duy nhất còn lại của một tệp: hàng **vẫn** có dòng nguồn gốc, `⋯` **không** có mục *"Show all pieces of …"*
- [x] Lọc nguồn **và** lọc Label cùng lúc cho **giao** của hai tập
- [x] Giao rỗng thì câu rỗng nói **cả hai** chiều đang bật, không chỉ một
- [x] Danh sách nguồn: cuốn đã tách **có**, tệp một Score **không**; sắp A–Z theo tên tệp
- [x] Mở lại app: bộ lọc **trắng** — test dựng lại `LibraryScreen` từ đầu; **G4 xác nhận trên máy thật**, vì test không tắt được process

**Bản dựng**

- [x] `flutter analyze` sạch; toàn bộ test xanh — **`502`** (trước slice `483`: +5 `source_filter_test`, +10 `library_source_filter_test`, +4 `library_screen_test`)
- [x] Không dependency mới, không quyền mới, `formatVersion` **không đổi**, không khoá prefs mới
- [x] Không hàng nào, không tab nào được thêm vào Library (ADR 0019 quyết định 11)

---

## Ghi chú UX (UX notes)

**Câu quan trọng nhất của slice này là câu của 0052 nhắc lại:** người không có cuốn sách nào trong thư viện đi hết slice này mà không biết nó đã xảy ra. Bốn thứ mới đều mọc từ `pageExtent`, nên với họ cả bốn đều không tồn tại — không phải bị ẩn, mà là **không có gì để hiện**.

**Lọc là thu hẹp, không phải gom.** Sau khi bấm *"Show all pieces of …"* thì thư viện **ngắn đi**, và điều đó phải rõ ngay — chip ở đầu danh sách là thứ duy nhất giữ nhạc công khỏi tưởng mình vừa mất phần còn lại của thư viện. Đây cũng là lý do bộ lọc không được persist.

**Dòng nguồn gốc là một dữ kiện, không phải một liên kết.** Nó không bấm được. Cho nó bấm được là mở đúng con đường tới hàng-đại-diện-cho-cuốn-sách mà slice này cố ý không đi.

**`.pdf` hiện ra trong Library là ngoại lệ, và nó cố ý.** Phần còn lại của app nói về **bản nhạc**, không nói về **tệp**. Chỗ này là ngoại lệ duy nhất vì tệp đúng là câu trả lời cho đúng câu hỏi này — nên nó xuất hiện ở một dòng phụ, không bao giờ ở tiêu đề hàng.

---

## Ràng buộc kỹ thuật (Technical constraints)

- **Bộ lọc nguồn là hàm thuần trên `List<Score>`**, cùng idiom `filterScoresByLabels` (`label/label_filter.dart:5-31`): không `Directory`, không `ScoreLibrary`, test được không cần một PDF nào
- **Không async trong `itemBuilder`.** `documentFor` đọc từ map đã cache và đồng bộ (`score_library.dart:118`); nếu vẽ một hàng cần `await` thì thiết kế đã sai. Cụ thể: **không gọi `scoresSharingDocument`** ở đường vẽ — nó là `Future` và đọc lại manifest (G3 số 11)
- **Một vị từ cho "nguồn", không hai.** Mục `⋯` và danh sách trong hộp lọc phải đọc cùng một `Map<String, int>` số Score theo `pdfDocumentId`; hai phép đếm song song sẽ lệch nhau ở lần sửa thứ nhất, và triệu chứng là một mục menu mở ra một danh sách rỗng
- **Chip không được mã hoá loại bằng `null`.** `_removeFilterChip(null)` hôm nay nghĩa là "xoá cả bộ lọc" (`library_screen.dart:636-642`); chip nguồn dùng lại chỗ ấy là một nút `×` làm nhiều hơn thứ nó nói
- **`scoreOriginLine` không được viết lại, không được nhân bản.** Nó đã là nơi duy nhất định nghĩa câu ấy và đã có test riêng (`test/score_origin_test.dart`); hàng Library là **chỗ gọi thứ ba**, không phải bản thứ hai
- **Hai chiều lọc, một chỗ mô tả.** `_filterActive` và `_filterDescription()` phải là nơi duy nhất trả lời "đang lọc gì" — hai hàm song song cho hai chiều sẽ lệch nhau ở lần sửa thứ nhất
- **Không thêm hàng, không thêm tab, không thêm thư mục vào Library** — ADR 0019 quyết định 11. Chip lọc là một **vị từ trên Score**, không phải một thực thể: nó không mở được, không xoá được, không tồn tại trong `library.json`
- **Không đụng `formatVersion`, không đụng `library.json`.** Slice này không lưu một byte mới nào. Nếu nó cần lưu gì thì nó đã đi lạc khỏi phạm vi
- **Không SDK, không quyền, không byte nào rời máy**

---

## Kế hoạch kiểm thử (Test plan)

**Automated**

- `test/source_filter_test.dart` (mới) — hàm thuần: lọc theo một `pdfDocumentId` cho đúng các Score của tệp ấy; `null` cho cả danh sách; id không tồn tại cho danh sách rỗng; Score không có `pageExtent` vẫn thuộc tệp của nó
- `test/library_source_filter_test.dart` (mới) — qua `LibraryScreen` với `ScoreLibrary` inject: `⋯` → *"Show all pieces of …"* thu hẹp danh sách; **`⋯` của một bài không còn anh em nào thì không có mục ấy** dù hàng vẫn có dòng nguồn gốc (G3 số 5); chip hiện tên tệp và bỏ được; **bỏ chip nguồn không xoá chip Label** (G3 số 10); **giao** với bộ lọc Label; câu rỗng nói cả hai chiều; danh sách nguồn bỏ tệp một Score và hiện cả khi mode là `Untagged` (G3 số 9)
- `test/library_screen_test.dart` (sửa) — hàng của một bài hiện dòng nguồn gốc; hàng của Score trọn tệp **không** hiện thêm dòng nào; hàng có cả Label và nguồn gốc
- `test/score_origin_test.dart` (**không sửa**) — nếu slice này phải sửa nó thì tức là câu chữ đã bị nhân bản, và đó là lỗi
- **Không** test nào cần một PDF thật

**Manual demo (G4)**

- Mở app trên thư viện **chưa tách gì**: xác nhận không một hàng nào, không một mục `⋯` nào, không một mục lọc nào khác trước
- Tách cuốn 148 trang của lượt trước → đọc dòng nguồn gốc trên vài hàng ở ba chỗ khác nhau trong cuốn
- `⋯` một bài → *"Show all pieces of …"* → đếm số hàng, xác nhận đúng bằng số bài đã tách
- Bật thêm một Label filter lên trên bộ lọc nguồn → xác nhận giao, rồi chọn một Label không bài nào có → đọc câu rỗng
- Đóng app, mở lại → bộ lọc trắng
- Một bài có Label dài trên máy hẹp nhất có sẵn → xác nhận cả nguồn gốc lẫn chip đều đọc được
