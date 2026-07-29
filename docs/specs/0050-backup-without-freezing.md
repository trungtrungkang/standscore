# 0050 — Sao lưu không làm đơ app: nén đúng thứ, chạy đúng chỗ, và nói còn bao lâu

- **Status:** proposed
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005 (Flutter shell), 0008 (slice này không đụng SmartMode/OMR), 0015 (ngôn ngữ tài liệu), 0016 (mô hình đọc/ghi)
- **Depends on Specs:** 0027 (done — sở hữu `LibraryBackup`, `formatId` và ngữ nghĩa restore thay-thế); 0002 / 0040 (done — sở hữu cây thư mục library và cache thumbnail); 0029 (done — share sheet nhận file ZIP)
- **Parity IDs:** P2.11 (backup / restore)
- **G3:** pending — tám câu ở mục "Câu hỏi G3", mỗi câu có khuyến nghị kèm bằng chứng đọc từ source
- **G4:** pending

## Vấn đề (Problem)

Orchestrator báo cáo: thư viện nhiều Score, mỗi Score có thể là một cuốn sách 100 trang, bấm Backup thì **app đơ một lúc**.

Đọc code thì nguyên nhân không phải "library lớn" mà là **nén sai thứ, ở sai chỗ**. Toàn bộ việc sao lưu là ba dòng:

```dart
// lib/library/library_backup.dart:38-43
final encoder = ZipFileEncoder()..create(zipFile.path);
try {
  await encoder.addDirectory(libraryRoot, includeDirName: false);
} finally {
  await encoder.close();
}
```

Bốn phát hiện, mỗi cái đọc được từ source của `archive 4.0.9`:

| # | Điều gì đang xảy ra | Bằng chứng |
|---|---|---|
| 1 | **Mọi file bị deflate**, kể cả PDF. `create()` không truyền `level`, `addFile` cũng vậy, và `ZipEncoder.add` mặc định `CompressionType.deflate` | `zip_encoder.dart:213` — `var compressionType = entry.compression ?? CompressionType.deflate` |
| 2 | PDF là **dữ liệu đã nén sẵn**, nên deflate lại tốn gần hết CPU của tác vụ mà đổi lại gần như không giảm byte. Với thư viện thật, PDF chiếm phần áp đảo số byte — annotation và prefs chỉ là JSON nhỏ | Cây library: `scores/` (PDF), `annotations/*.json`, `page_orders/*.json`, các `*_prefs.json` |
| 3 | Việc nén chạy **trên isolate của UI**. `await` ở dòng trên chỉ chờ đọc/ghi file; nén là CPU đồng bộ. Cộng thêm `addDirectory` mở đầu bằng `dir.listSync(recursive: true)` — quét toàn cây, đồng bộ | `zip_file_encoder.dart:145` |
| 4 | Người dùng đang được xem một **spinner vô định** (`_showBusyDialog('Creating backup…')`), mà chính spinner đó cũng đứng vì UI bị chặn. Không có phần trăm, không có nút huỷ | `library_screen.dart:311` |

Nói cách khác, triệu chứng "đơ" có một dấu hiệu chẩn đoán rất rõ để kiểm ở G4: **vòng xoay ngừng xoay**. Nếu sau slice này nó vẫn quay đều trong suốt quá trình, việc đã đúng.

Hai điều đáng nói thêm. Thứ nhất, `restoreBackup` có **đúng cùng một lỗi** ở chiều ngược lại (`extractFileToDisk` trên isolate UI), và đó là đường phá huỷ dữ liệu nên đơ ở đó đáng lo hơn. Thứ hai, `archive` **đã có sẵn** `onProgress` và một `filter` trả về `include / skip / cancel` (`zip_file_progress.dart`), nên tiến trình và huỷ không phải viết từ đầu.

## Kết quả (Outcome)

Nhạc công bấm Backup với thư viện thật và thấy một thanh tiến trình **chạy**, có phần trăm, có nút Cancel, app vẫn cuộn được — rồi share sheet mở ra. Bấm Cancel thì không để lại file nào nửa vời. Phục hồi cũng vậy.

Với người viết slice sau, kết quả là `LibraryBackup` nhận được ba thứ nó đang thiếu: một tham số tiến trình, một đường huỷ, và một chỗ để hỏi "file này có được đưa vào không" — chính là cái móc mà slice **sao lưu chọn lọc** sẽ dùng, không phải viết lại.

## Trong phạm vi (In scope)

- `createBackup` tự đi cây bằng `list()` **async** thay vì dựa vào `addDirectory`, để mỗi file được chọn mức nén riêng và để có tên file cho tiến trình
- **Mức nén theo loại file:** `store` cho `.pdf` và `.png`, `deflate` cho `.json` và phần còn lại (câu hỏi G3 số 1)
- Toàn bộ việc nặng chạy **ngoài isolate UI** (`Isolate.run`), tiến trình gửi về qua port (câu hỏi G3 số 2)
- Tiến trình **theo byte**, không theo số file (câu hỏi G3 số 3)
- Huỷ được, và huỷ **không** để lại artefact: ghi ra `*.zip.part` rồi mới `rename` (câu hỏi G3 số 4)
- `restoreBackup` cũng ra khỏi isolate UI, cũng có tiến trình (câu hỏi G3 số 5)
- `library_screen.dart`: hộp thoại busy vô định thay bằng tiến trình xác định + Cancel, cho cả hai chiều
- **Không đổi format:** `formatId`, `markerFileName`, `formatVersion` = 1 giữ nguyên; backup cũ (deflate) vẫn phục hồi được (câu hỏi G3 số 6)

## Ngoài phạm vi (Out of scope)

- **Chọn Score nào để sao lưu** — đúng thứ Orchestrator hỏi, và cố ý để lại **slice sau**, vì nó không phải việc UI mà là một quyết định phá huỷ dữ liệu: `restoreBackup` hôm nay **thay thế** cả library (`library_backup.dart:77-84`, và hộp thoại xác nhận nói thẳng "This replaces all Scores… cannot be undone"). Phục hồi một bản chọn lọc bằng ngữ nghĩa đó sẽ **xoá những Score không được chọn**. Nên slice sau phải chốt trước: phục hồi là **trộn** hay bản chọn lọc chỉ để **gửi đi**; marker phải ghi rõ đây là bản một phần và gồm những Score nào; và `formatVersion` lên **2** để bản app cũ *từ chối* file mới thay vì phá library — đó chính là việc mà kiểm tra version ở `library_backup.dart:113` tồn tại để làm. Việc đó cần **ADR ở G2 và một Security Review**, tức tier **L**; slice này giữ tier **M** và ship được một mình
- **Lesson pack** — cùng cơ chế với sao lưu chọn lọc nếu chọn ngữ nghĩa trộn; bàn cùng slice đó, không phải ở đây
- **Cache thumbnail** — nó nằm ở `<cache>/score-thumbs` (`library_screen.dart:179`), **ngoài** library root, nên nó vốn đã không có trong backup. Không có gì để loại bỏ
- **Đích lưu và cách đưa file ra** — vẫn `<documents>/exports/StageScore-backup-<stamp>.zip` cộng share sheet; đổi thành "Save to Files" là câu hỏi khác
- **File marker nằm lại trong library** sau lần backup đầu (`library_backup.dart:31`) — một cái wart, nhưng đụng vào nó là đụng format
- Cloud sync, multi-device, mã hoá backup, tự động sao lưu định kỳ
- Dependency mới: không. `archive` đã có, `Isolate.run` là `dart:isolate`

## Câu hỏi G3 (G3 questions)

| # | Câu hỏi | Khuyến nghị |
|---|---|---|
| 1 | Nén hay lưu, và theo tiêu chí nào? | **Theo phần mở rộng, không phải một mức cho cả archive:** `store` (`ZipFileEncoder.store`) cho `.pdf` và `.png`, `deflate` cho phần còn lại. Lý do đúng cả hai chiều: PDF đã nén nên deflate chỉ đốt CPU, còn annotation JSON là **text**, để `store` sẽ làm file backup phình ra thật. `addDirectory` chỉ nhận một `level` cho tất cả, nên đây là lý do slice này tự đi cây bằng `addFile(file, name, level)` — và vòng lặp đó đồng thời cho luôn tên file cho tiến trình cùng cái móc cho slice chọn lọc |
| 2 | `Isolate.run` cho cả job hay chỉ cho phần nén? | **Cả job.** `addDirectory` bắt đầu bằng `listSync(recursive: true)` nên chỉ bọc phần nén vẫn để lại một lần quét cây đồng bộ trên UI. Chỉ truyền **đường dẫn** qua ranh giới isolate (String, không phải `File`/`Directory`), tiến trình về qua `SendPort`. Lưu ý khi build: `onProgress`/`filter` của `archive` là callback **đồng bộ chạy trên isolate nén**, nên chúng không gọi trực tiếp vào UI được — chúng chỉ được `send` |
| 3 | Tiến trình đếm gì? | **Byte, không phải số file.** Một PDF 100 trang nặng hơn 200 file JSON cộng lại, nên đếm file sẽ nhảy tới 90% rồi đứng im ở file lớn — đúng cảm giác "đơ" mà slice này định chữa. Tổng byte biết trước bằng `stat()` lúc đi cây. Nhãn nên nói cả tên Score đang xử lý: người ta tha thứ cho một tác vụ chậm khi nó nói nó đang làm gì |
| 4 | Huỷ giữa đường để lại gì? | **Không gì cả.** Ghi ra `<đích>.zip.part`, `rename` sang `.zip` chỉ khi đã `close()` xong; huỷ hoặc lỗi thì xoá `.part`. Hôm nay code xoá file đích *trước khi* ghi (`library_backup.dart:26-28`), nên một lần crash giữa đường vừa mất file cũ vừa để lại một ZIP cụt — mà ZIP cụt là thứ tệ nhất trong một tính năng sao lưu: nó trông như một bản backup |
| 5 | Restore có cần cùng cách chữa? | **Có, và ưu tiên không kém.** `extractFileToDisk` cũng chặn UI, mà đây là đường **phá huỷ**: người dùng vừa bấm "Replace all" và đang xem một spinner đứng im, không có cách nào biết nó còn sống. Tiến trình ở đây có giá trị khác backup: nó là thứ ngăn người ta tắt app giữa lúc library đã bị đổi tên sang chỗ khác |
| 6 | Backup cũ còn phục hồi được không? | **Bắt buộc còn**, và đây là ràng buộc chứ không phải lựa chọn: ZIP là ZIP, mỗi entry mang mức nén của riêng nó, nên một archive deflate cũ đọc bình thường. Khoá bằng test: dựng một ZIP deflate trong test rồi restore và so byte. `formatVersion` **không** tăng — bản backup mới vẫn là format 1, vì cấu trúc không đổi, chỉ cách nén đổi |
| 7 | Lấy gì chứng minh "không đơ"? | Test tự động khoá **cấu trúc**, không khoá thời gian: entry `.pdf` phải là `CompressionType.none`, entry `.json` phải là `deflate`, tiến trình phải đơn điệu tăng và kết ở 1.0, huỷ phải không để lại file ở đích. Còn "vòng xoay vẫn quay" là việc của **G4 trên máy thật** — cùng lý do 0043 phải đo bằng widget test thay vì ảnh chụp: một test đo thời gian trên CI máy khác sẽ flaky, và flaky tệ hơn không có |
| 8 | Có nên nhân dịp này dọn cái gì khác trong `LibraryBackup`? | **Không.** File marker nằm lại trong library, `formatId` giữ chính tả `standscore` (chủ ý, ADR ở README `stagescore/`), ngữ nghĩa thay-thế của restore — cả ba đều đúng chỗ để nguyên. Slice này chỉ đổi **cách** sao lưu, không đổi **cái gì được** sao lưu hay **nó có nghĩa gì**; giữ vậy thì slice chọn lọc sau mới có một mặt phẳng sạch để bump format |

## Thuật ngữ miền (Domain terms)

**Không có thuật ngữ miền mới, `CONTEXT.md` không đổi.** Tiến trình, isolate và mức nén đều là chi tiết thực thi, thứ `AGENTS.md` cấm đưa vào `CONTEXT.md`. Nếu slice **sau** chốt ngữ nghĩa trộn thì lúc đó mới có một từ miền thật để định nghĩa (một bản sao lưu *một phần* là gì), và nó sẽ đi kèm ADR của slice đó.

Thuật ngữ đã có mà Spec này dùng: **Score**, **Setlist**, **Label**, **Bookmark**, **JumpLink**, **PageOrder**.

## Tiêu chí chấp nhận (Acceptance criteria)

- [ ] Bấm Backup với thư viện thật: **vòng xoay không ngừng xoay**, app còn cuộn được, thanh tiến trình chạy và có phần trăm
- [ ] Trong archive mới: mọi entry `.pdf` và `.png` là `CompressionType.none`, mọi entry `.json` là `deflate`
- [ ] Backup rồi restore vẫn ra **đúng byte cũ** cho PDF và cho annotation JSON (test 0027 hiện có vẫn xanh, không sửa)
- [ ] Một ZIP **deflate cũ** (dựng trong test, hoặc một file backup thật lấy trước bản này) restore được bình thường
- [ ] Bấm Cancel giữa lúc backup: không có file `.zip` nào ở `<documents>/exports/`, cũng không có `.part` sót lại
- [ ] Bấm Cancel giữa lúc restore: library **nguyên vẹn như trước** — không mất Score nào, không còn thư mục `.standscore_aside_*` hay `.standscore_restore_*`
- [ ] Restore có tiến trình chạy, và hộp thoại xác nhận "Replace all" giữ nguyên chữ như hôm nay
- [ ] `formatVersion` vẫn là 1; `formatId` và `markerFileName` không đổi một ký tự
- [ ] Không thêm dependency; `flutter analyze` sạch; toàn bộ test xanh
- [ ] Kích thước file backup không tăng quá **10%** so với bản cũ trên cùng một thư viện (nếu tăng hơn, luật nén theo loại file đã sai chỗ nào đó)

## Ghi chú UX (UX notes)

**Nhạc công nên thấy khác:** một thanh tiến trình có phần trăm và tên Score đang xử lý, một nút Cancel, và app không đứng. Sao lưu một thư viện lớn vẫn lâu — slice này không hứa nhanh tức thì, nó hứa **app còn sống và nói cho bạn biết còn bao lâu**.

**Nhạc công không nên thấy khác:** đích lưu và share sheet y như cũ; chữ trong hộp thoại xác nhận restore y như cũ (nó đang đúng và đang đáng sợ vừa đủ); file backup cũ vẫn dùng được; không có lựa chọn mới nào xuất hiện trong màn hình Backup — **chọn lọc là slice sau**, và nếu nó xuất hiện ở đây thì Spec đã bị nong ra.

## Ràng buộc kỹ thuật (Technical constraints)

- Qua ranh giới isolate chỉ truyền **String đường dẫn** và số; `File`, `Directory`, `ZipFileEncoder` không đi qua được
- `onProgress` và `filter` của `archive` là callback **đồng bộ trên isolate nén** — chúng chỉ `send`, không được gọi `setState` hay chạm `BuildContext`
- ZIP đích **không được** nằm trong `libraryRoot` (ràng buộc đã có của 0027; `zipDirectory` của `archive` cũng ném `FormatException` cho ca đó). `<documents>/exports/` là thư mục chị em, giữ nguyên
- Huỷ phải để hệ thống file ở đúng một trong hai trạng thái: chưa có gì, hoặc xong hẳn. Với restore, điều đó nghĩa là **không huỷ được sau khi đã `rename` library đi** — nút Cancel phải tự vô hiệu ở bước đó, chứ không phải hứa một thứ không giữ được
- Tiến trình theo byte cần `stat()` cả cây trước khi nén; lần quét đó cũng nằm trong isolate
- `LibraryBackup` vẫn là `const` constructor không state; tiến trình và huỷ đi qua **tham số**, không qua field — nếu không thì hai lần backup song song sẽ chia nhau một biến

## Kế hoạch kiểm thử (Test plan)

- **Automated:**
  - `test/library_backup_test.dart` (sửa) — hai test hiện có (backup→restore giữ nguyên PDF + annotation JSON; restore không bỏ sót file lạ) phải xanh **không sửa một dòng**: chúng là hợp đồng của 0027, và nếu đỏ thì slice này đã đổi thứ nó hứa không đổi
  - `test/library_backup_progress_test.dart` (mới) — dựng library giả nhiều file: mức nén đúng theo loại file (đọc lại bằng `ZipDecoder`), tiến trình đơn điệu và kết ở 1.0, huỷ giữa đường không để lại `.zip` lẫn `.part`, và một ZIP deflate dựng tay restore được
  - Không có test đo thời gian: nó flaky trên máy khác, và câu "không đơ" thuộc về G4
- **Manual demo (G4):** trên thiết bị thật, với thư viện nhiều Score và ít nhất một Score cỡ một cuốn sách — bấm Backup và **vừa nhìn vòng xoay vừa cuộn danh sách**; bấm Cancel giữa đường rồi kiểm `exports/` trống; sao lưu xong so kích thước file với một bản backup cũ; restore một backup **cũ (deflate)** lấy trước bản này; restore và bấm Cancel ở giai đoạn đầu rồi xác nhận library còn nguyên
