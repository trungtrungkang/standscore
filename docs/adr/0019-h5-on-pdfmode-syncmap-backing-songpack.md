# Mở H5 trên PdfMode: nhạc công tự dựng MeasureMap, SyncMap, BackingTrack và SongPack

StageScore mở **H5** — BackingTrack cộng SyncMap — **mà không mở H3 và H4**. Ranh giới không phải PDF-hay-MusicXML mà là *tính năng có cần biết nốt nào* hay *chỉ cần biết chỗ nào trên trang, ở giây thứ mấy*: WaitMode và MidiLane cần vế đầu và vẫn đóng, còn toàn bộ BackingTrack + SyncMap chỉ cần vế sau. Điều mới so với mọi ADR trước: **nội dung do chính nhạc công dựng trong app**, không phải tải về từ một danh mục.

Việc dựng đó tách làm hai tầng, và tách đúng chỗ là quyết định quan trọng nhất của ADR này: **MeasureMap** là hình học — ô nhịp nằm ở đâu trên trang giấy; **SyncMap** là thời gian — ô nhịp ấy vang lên ở giây thứ mấy. Một Score có **một** MeasureMap và **nhiều** SyncMap. Kèm theo đó, `Score` thôi đồng nhất với một file PDF, và **SongPack** trở thành đơn vị đóng gói dùng chung cho ba đường: nhạc công tự chia sẻ, **tác giả bên thứ ba bán ra ngoài app**, và Discover về sau.

**Status:** accepted (G2, Orchestrator, 2026-08-05)
**Đề xuất bởi:** Agent (2026-08-05), theo bốn chốt của Orchestrator cùng ngày; **revision 1** cùng ngày sau ba câu chất vấn (quyết định 3, 8, 11); **revision 2** cùng ngày sau khi Orchestrator trả lời tám câu G2 và bổ sung **SongPack đến từ tác giả bên thứ ba** — xem quyết định 7, 9, 13 và bảng Trình tự (thứ tự đã đổi); **revision 3** cùng ngày sau khi **Spec 0052 accepted ở G3**, và nó sửa những chỗ ADR này nói sai về code đang ship — **quyết định 2** (luật số trang: hai không gian, không phải một), **quyết định 10** (di trú phải chạy sau restore), **quyết định 11** (ba hành vi đã ship thành **bốn**; câu hỏi lúc nhập đứng sau khi nhập; hai hình dạng của `loadOutline` phải chịu được). **Ba câu G2 cuối chốt cùng ngày, cả ba theo khuyến nghị** — màn hình tên `Packs`, team dựng danh mục bằng công cụ trong app, không chữ ký số; **không còn câu nào mở ở G2**. **Revision 4** cùng ngày, và nó **chỉ đổi thứ tự, không đổi một quyết định nào**: manual test G4 của slice 1 sinh ra một slice mới — **nguồn gốc trên hàng Library và lọc theo tệp nguồn (Spec 0053, tier M)** — chen vào vị trí 2, nên **mọi số Spec từ MeasureMap trở đi dịch một bậc** (MeasureMap là `0054`, SongPack là `0060`, thu âm là `0063`) và số slice trong phần Hệ quả cùng phần Security Review đổi theo. Xem bảng Trình tự. **Revision 5** cùng ngày, sau manual test G4 của slice 2, và nó **viết lại quyết định 11**: PdfDocument **có tên riêng và có một hàng tiêu đề trong Library**, vì thư viện sau khi tách không còn đường vào lại cuốn sách và không có chỗ nào đặt tên cho nó ngoài tên tệp `.pdf`. Kèm một slice mới — **Spec 0054, tier M** — chen vào vị trí 3, nên **số Spec từ MeasureMap trở đi lại dịch một bậc** (MeasureMap là `0055`, SongPack là `0061`, thu âm là `0064`). **Revision 6** cùng ngày, sau G4 cảm nhận Library của 0054 (*bí bách* khi hàng tiêu đề + mọi bài luôn mở): Orchestrator **chốt Score gốc chứa Score con** — quyết định 11 viết lại lần nữa; hàng tiêu đề `PdfDocument` thôi là UI chính. Kèm **Spec 0055, tier M**; MeasureMap thành **`0056`**, SongPack **`0062`**, thu âm **`0065`**. **Revision 7** (2026-08-06), **chỉ đổi số, không đổi quyết định nào**: hai Spec **ngoài ADR này** (0056 — Half Page thành scroll liên tục; 0057 — localization 9 ngôn ngữ) sinh ra từ phản hồi trực tiếp của Orchestrator khi dùng app, và cả hai **rẻ hơn, cấp bách hơn** MeasureMap nên đi trước — đúng cùng lý lẽ đã đẩy Spec 0053 chen hàng ở revision 4. Chúng tiêu thụ đúng hai số mà bảng Trình tự đã dành cho MeasureMap và bước tính-SyncMap-từ-MeasureMap. Nên **mọi số Spec của ADR này từ MeasureMap trở đi dịch thêm hai bậc**: MeasureMap là **`0058`**, tính SyncMap từ MeasureMap là **`0059`**, lật trang rảnh tay là **`0060`**, spike SoLoud là **`0061`**, BackingTrack+Transport là **`0062`**, SyncMap gõ tay là **`0063`**, định dạng SongPack là **`0064`**, màn hình Packs là **`0065`**, spike thu âm là **`0066`**, thu âm là **`0067`**. Đây là **lần thứ ba** một số ngoài ADR chen vào dải số đã dành sẵn (sau 0053 ở revision 4 và 0055 ở revision 6) — bài học lặp lại: dải số trong bảng Trình tự là **dự kiến**, không phải khoá; đọc theo bảng, không theo số ghi trong các dòng log cũ
**Tier:** L — audio ownership, quyền microphone, di trú dữ liệu trên thư viện thật, và một định dạng tệp **do người lạ tạo ra đi vào máy người dùng** → cần G2 accept, cộng **Security Review trước slice SongPack và slice thu âm** (không cần cho bảy slice đầu, xem Hệ quả)
**Relates to:** ADR 0002 (dual modes), ADR 0004 (Transport ở tầng native), ADR 0006 (OMR — ranh giới ở quyết định 3), ADR 0007 (multi-lane Transport + SyncMap), ADR 0008 (parity trước — ADR này là lối ra), ADR 0012 (hai repo), ADR 0014 (hai bounded context — trigger kích hoạt), ADR 0017 (Discover, `hold`), ADR 0018 (quảng cáo, `proposed`), `VISION.md`, `TRANSPORT-ARCHITECTURE.md`, `IMPROVEMENT-ROADMAP.md` Phase D

---

## Bối cảnh (Context)

v1.0.0 đã nộp cho Apple và Google ngày 2026-08-04, và Phase D của roadmap còn đúng một ô chưa tích: *go / hold* cho việc mở H3. Orchestrator mở nó ngày 2026-08-05, nhưng mở sang một hướng mà bảng horizon của `VISION.md` không có sẵn — **bỏ qua H3 và H4, đi thẳng H5**.

### Thứ làm ADR này khác mọi ADR playback trước đó

ADR 0007 và `TRANSPORT-ARCHITECTURE.md` giả định BackingTrack là **một asset có sẵn** mà ai đó gắn vào Score. ADR 0017 giả định nó là **nội dung team sản xuất** rồi nhạc công tải về. Cả hai đều đặt phần sản xuất ở ngoài app.

Hướng của Orchestrator đặt phần sản xuất **vào trong app**: nhạc công vẽ MeasureMap, gõ SyncMap, thu nhạc đệm, đóng gói, chia sẻ. Đó không phải một biến thể của hai giả định trên, nó là giả định thứ ba, và nó lật một kết luận đã ký: **đường tới hạn của ADR 0017 là tốc độ sản xuất bản nhạc, và danh mục hiện là số không** — lý do duy nhất khiến Discover chuyển `hold` ở ADR 0018 quyết định 9. Nếu công cụ sản xuất nằm trong tay người dùng thì tính năng này **không có đường tới hạn nào phụ thuộc vào một danh mục**. Nó chạy được vào ngày ship, với thư viện mà nhạc công đã có.

### Bốn dữ kiện kỹ thuật, tra ngày 2026-08-05, không cái nào lộ ra từ tài liệu trong repo

**Transport không còn cần một plugin native.** `flutter_soloud` **4.1.0** thêm `getEngineTime()` — đồng hồ mixer đẩy lên ở đầu mỗi buffer — cộng `playScheduled()` hẹn phát chính xác tới mẫu, và `createMixingBus()` cho gain/mute theo lane. Đó đúng là "một clock, nhiều lane" mà ADR 0007 mô tả, dựng được bằng Dart. Repo đang pin `^4.0.13` nên chưa có API này; và **4.1.5 đổi `play` / `setPause` / `stop` sang ném lỗi thay vì nuốt**, nên việc nâng phải soi lại `MetronomeEngine`. Giới hạn đi kèm: `getPosition` cập nhật theo buffer, mặc định bước ~42 ms — đủ để lật trang và đếm ô nhịp, phải nội suy nếu muốn vẽ mượt.

**Có một tam giác codec làm thu âm khó hơn vẻ ngoài.** SoLoud giải mã MP3, WAV, OGG, FLAC nhưng **không giải mã AAC/M4A**. `record` — gói thu âm được bảo trì tốt nhất, backend là API gốc của hệ điều hành nên không đụng miniaudio của SoLoud — ghi AAC/M4A tốt trên cả hai nền tảng. Tức **gói ghi tốt nhất tạo ra file engine phát không đọc được**. `flutter_recorder` (cùng tác giả SoLoud) ghi Ogg Opus mà SoLoud phát được, nhưng README của chính nó đánh dấu iOS **"under test"**. Ba lối thoát — WAV nặng ~10,6 MB/phút, đánh cược flutter_recorder trên iOS, hay dựng đường chuyển mã — đều có giá và không lối nào quyết được trên giấy.

**Không gói nào phơi ra độ trễ giữa thu và phát.** `record`, `flutter_recorder` và SoLoud đều không trả về dấu thời gian của luồng vào; `audio_session` có `inputLatency`/`outputLatency` nhưng chính nó đánh dấu `UNTESTED`. Nghĩa là "thu trong lúc nghe click" **không tự khớp**: phải phát một click, thu lại chính nó, đo lệch, và đo lại mỗi khi đổi đường vào. Cùng bài toán ấy, ở dạng nhẹ hơn, áp cho việc **gõ theo nhạc** ở quyết định 3.

**Line-in đã với tới được bằng dependency đang có.** `audio_session` phơi ra `availableInputs` và `setPreferredInput`, với `AVAudioSessionPort` gồm `usbAudio` và `lineIn`. Bên Android thiết bị USB hiện ra như một nguồn thu bình thường từ API 21 và `record` chọn được nó qua `InputDeviceType.usb` — nhưng chỉ **UAC1, tối đa stereo**, nên một interface chỉ hỗ trợ UAC2 có thể không nhận, và việc tự động định tuyến **người dùng tắt được** trong Developer Options.

### Code hôm nay gộp hai khái niệm mà glossary đã tách

`CONTEXT.md` định nghĩa **PdfDocument** là "phần byte PDF và các ảnh trang gắn với khung xem biểu diễn của một Score" — tức luôn coi nó là thứ *thuộc về* Score, không phải *chính là* Score. Code thì gộp: `Score.relativePath` trỏ thẳng `scores/<id>.pdf`, một Score một file, không có chỗ nào diễn đạt "bản nhạc này là trang 12–19 của cuốn kia".

Nên "một PDF nhiều Score" **không phải một tính năng mới, nó là sửa một chỗ code đã trôi khỏi glossary từ Spec 0002**. Đó là lập luận mạnh nhất để nó đi trước, và nó cũng là lập luận rẻ nhất để qua cổng, vì nó không chạm audio, không chạm mạng, không chạm tiền.

### Hai thứ đã có sẵn mà thiết kế dưới đây dựa hẳn vào

**Lớp vẽ của Spec 0017–0019 đã dùng đúng hệ toạ độ mà MeasureMap cần.** `AnnotationStore` lưu nét vẽ bằng **toạ độ chuẩn hoá 0–1 trên số trang PDF gốc 1-based**. Đó cũng chính xác là hệ toạ độ của `MeasureBox` bên repo web (`pageIndex`, toạ độ tỉ lệ `0..1`). Nên MeasureMap không phải phát minh một hệ toạ độ, không phải phát minh một lớp vẽ chồng lên trang, và không phải giải lại bài toán zoom/xoay — cả ba đã ship và đã qua G4.

**`pdfrx` đọc được mục lục của PDF.** `PdfDocument.loadOutline()` trả về cây `PdfOutlineNode`, mỗi nút mang `title` và `dest` (trang đích). Kiểm trực tiếp trong `pdfrx 2.4.7` / `pdfrx_engine 0.4.6`. Điều này đổi hẳn chi phí của việc tách một tuyển tập — xem quyết định 11.

---

## Các lựa chọn đã cân nhắc (Considered options)

- **Mở H3 trước theo đúng thứ tự VISION** (SmartMode + Verovio + MusicXML, rồi mới H5) — bị bác. Nó đặt một khối kiến trúc lớn nhất repo đứng trước thứ nhạc công hỏi, mà không thứ nào trong năm ý tưởng cần biết nốt nào. Và nó bỏ phí điều kiện mà ADR 0007 quyết định 6 đã đặt sẵn.
- **Giữ H5 đóng, chỉ làm "một PDF nhiều Score"** — bị bác bởi Orchestrator. Nó đúng như một bước, nhưng một mình nó không đổi sản phẩm; nó là nền móng cho phần đổi sản phẩm.
- **BackingTrack chỉ đến từ Discover, không tự tạo** — bị bác. Đó là ADR 0017, và nó đang `hold` vì đúng lý do này: không có danh mục thì không có gì để nghe.
- **SyncMap neo theo trang, ô nhịp để sau** (bản nháp đầu của ADR này) — **bị bác bởi Orchestrator ngày 2026-08-05**, và nó bị bác vì một lỗi lập luận thật, không vì khẩu vị. Xem quyết định 3.
- **Thu âm trước, nhập file sau** (thứ tự Orchestrator nêu) — bị bác về *thứ tự*, không về *phạm vi*. Xem quyết định 5.
- **Mở H5 trên PdfMode, nội dung do nhạc công tự dựng, MeasureMap tách khỏi SyncMap, PdfDocument tách khỏi Score** — được chọn.

---

## Quyết định (Decision)

### 1. Mở H5, giữ H3 và H4 đóng — và ranh giới là một câu hỏi, không phải một danh sách

Đây là lối ra của ADR 0008, nhưng chỉ mở đúng một cánh. Luật để phân định về sau, vì bảng horizon của `VISION.md` không diễn đạt được hình dạng này:

> Một tính năng thuộc H5 nếu nó chỉ cần biết **chỗ nào trên trang, ở giây thứ mấy**. Nó thuộc H3/H4 nếu nó cần biết **nốt nào**.

Theo luật đó: MeasureMap, SyncMap, BackingTrack, Transport, lật trang tự động, chỉ báo vị trí theo phách — **mở**. MusicXML, Verovio, MidiRealization, WaitMode, PracticePolicy, OMR — **vẫn đóng**, và hard stop trong `AGENTS.md` giữ nguyên hiệu lực với chúng.

`VISION.md` đảo thứ tự trụ cột theo quyết định này (Play along đứng trước Smart Score), và đó là sửa VISION chứ không phải một slice — xem câu hỏi 1.

### 2. `Score` thôi đồng nhất với một file PDF, và đây là slice đầu tiên, bắt buộc

`PdfDocument` thành một thực thể sở hữu file; `Score` trỏ vào nó kèm một **PageExtent** — khoảng trang thuộc về bản nhạc này. Nhiều Score dùng chung một PdfDocument.

**PageExtent không phải PageOrder, và việc trộn hai thứ đó là lỗi thiết kế đắt nhất có thể mắc ở đây.** PageExtent trả lời *trang nào thuộc về bản nhạc này* — nó là phạm vi, đặt một lần lúc tách bài. PageOrder trả lời *chơi các trang đó theo thứ tự nào, lặp chỗ nào, chèn trang trắng chỗ nào* — nó là trình tự, sửa mỗi lần dựng cách chơi, và nó chạy **bên trong** PageExtent.

Slice này đi trước mọi thứ khác vì **mọi thứ khác neo vào nó**: MeasureMap neo ô nhịp vào trang, còn annotation, Bookmark, JumpLink và PageOrder đã neo theo số trang từ lâu. Đổi cái neo *sau* khi đã có MeasureMap nghĩa là làm hỏng thứ tốn công người nhất trong cả nhóm này.

Di trú: mỗi Score hôm nay thành một PdfDocument với PageExtent trọn vẹn. Không ai thấy gì đổi.

**Số trang lưu ở đâu cũng phải chốt cùng lúc, vì đây là chỗ dễ sai âm thầm nhất.** Thứ bị cấm là **số trang tương đối trong PageExtent**: nó đổi khi PageExtent đổi, nên sửa một PageExtent sẽ âm thầm dịch mọi annotation của bài. Việc quy đổi sang "trang 3 của bài" chỉ xảy ra ở tầng hiển thị, không bao giờ ghi xuống đĩa.

Nhưng thứ được phép thì có **hai** không gian, không phải một — và bản trước của ADR này viết sai chỗ đó:

> **Thứ neo vào tờ giấy** — annotation, page scale theo trang, `PageOrder.sourcePage`, và **MeasureBox** sắp tới — giữ **số trang tuyệt đối của PdfDocument**.
>
> **Thứ neo vào chuỗi biểu diễn** — **Bookmark** và **JumpLink** — giữ **vị trí trong PageOrder**, đúng như hôm nay.

Bản trước viết *"mọi thứ lưu xuống đĩa — annotation, Bookmark, MeasureBox — giữ số trang tuyệt đối"* bằng giọng mô tả hiện trạng, và **nó không mô tả hiện trạng**. Đợt đọc repo của Spec 0052 tìm ra ba quy ước đang cùng tồn tại: annotation (`annotation_store.dart:24`) và `PageOrderEntry.sourcePage` (`page_order.dart:32`) neo theo trang PDF tuyệt đối, còn `JumpLink.originPage`/`destinationPage` neo theo vị trí PageOrder (`jump_link.dart:16,19` nói thẳng ra thế) và `Bookmark.pageNumber` cũng vậy, vì nó ghi từ `_navPage.clamp(1, _pageOrder.length)` (`pdf_mode_screen.dart:1153-1157`).

Nên câu cũ không phải một mô tả mà là **một luật mới**, và áp nó lên hai kho kia là **di trú có mất mát**. Hai lý do, cả hai đọc từ code đang ship:

- **JumpLink không diễn đạt được bằng trang tuyệt đối, và đó chính là lý do nó tồn tại.** `PageOrder.duplicate()` cho phép **một trang PDF xuất hiện nhiều lần** trong chuỗi biểu diễn — đó là cách app giải D.C. và đoạn lặp. Một JumpLink nói *"tới ô này trong chuỗi thì nhảy sang ô kia"*, và hai ô có thể là **cùng một tờ giấy**. Quy về trang tuyệt đối là làm nhoè đúng phân biệt mà tính năng ấy sống nhờ.
- **Phép chuyển không phải song ánh.** `PageOrderEntry.blank()` là một ô **không có trang PDF nào**, nên một Bookmark trên trang trắng chèn thêm không có gì để trỏ tới.

Luật hai không gian vẫn giữ trọn ý định ban đầu, vì thứ nó thật sự cấm — quy ước **thứ ba**, tương đối theo PageExtent — vẫn bị cấm. Điều bắt buộc đi kèm: **mỗi model có số trang phải có doc comment nói nó thuộc không gian nào.** `Bookmark.pageNumber` hôm nay **không có comment nào**, và đó chính là lý do dữ kiện này suýt lọt qua cả ADR lẫn hai vòng chất vấn.

### 3. MeasureMap là hình học, SyncMap là thời gian — và SyncMap chi tiết tới **phách** ngay từ đầu

Bản nháp đầu của ADR này khuyến nghị neo theo trang trước, theo ô nhịp sau, với lý lẽ chi phí: một bài 10 trang tốn 10 lần gõ thay vì vài trăm. Orchestrator bác, và **lý lẽ đó sai chứ không chỉ là bị chọn khác** — nó định giá một cách soạn mà thiết kế này không dùng. Bản nháp giả định mọi thứ đều được **gõ theo thời gian thực**, nên độ mịn nhân thẳng vào số lần gõ. Thiết kế đúng tách làm hai tầng, và ở tầng dưới độ mịn gần như miễn phí:

| Tầng | Là gì | Soạn thế nào | Chi phí theo độ mịn |
|---|---|---|---|
| **MeasureMap** | Ô nhịp **nằm ở đâu** trên trang | **Vẽ** hộp lên trang | Gần như phẳng — chia đều là mặc định |
| **SyncMap** | Ô nhịp **vang lên lúc nào** | Tính ra, hoặc gõ theo nhạc | Tuỳ cách; xem ba nguồn dưới đây |

Chia một RowBox thành 4 ô nhịp là **một** thao tác, không phải bốn; chia một MeasureBox thành 4 phách cũng vậy. Chi phí chỉ phát sinh ở chỗ **không đều** — một ô nhịp rộng bất thường, một phách bị kéo lệch — và đó là thiểu số. Nên mịn tới phách không đắt gấp bốn lần mịn tới ô nhịp; nó đắt hơn đúng phần bất thường.

Và phần thưởng thì lớn hơn bản nháp tưởng. Với hình học tới phách, lật trang không còn là "hết trang thì lật" mà là "lật vào đúng phách có dấu lặng ở cuối dòng cuối"; và chỉ báo vị trí chạy được **trên đúng dòng đang chơi**, thứ mà mốc theo trang không bao giờ cho được.

#### 3a. Ba tầng hình học của MeasureMap

- **RowBox** — một dòng nhạc trên trang. Vẽ bằng tay, hoặc chép từ trang trước (xem dưới).
- **MeasureBox** — một ô nhịp, nằm trong một RowBox. Sinh ra bằng cách chia RowBox; chia đều là mặc định, kéo vạch chia để sửa. Mỗi MeasureBox mang **time signature** và **tempo** riêng — cả hai kế thừa từ ô nhịp trước và chỉ ghi xuống khi đổi.
- **BeatBox** — một phách, nằm trong một MeasureBox. Chia đều theo time signature là mặc định; kéo vạch chia khi khoảng cách in không đều.

Một Score có **đúng một** MeasureMap. Nó thuộc về bản nhạc, không thuộc về một cách chơi — hai nhạc công chơi cùng bản nhạc ấy vẫn thấy ô nhịp 47 ở cùng chỗ trên giấy.

Hệ toạ độ **dùng lại nguyên hệ của lớp annotation đã ship**: tỉ lệ 0–1 trên số trang PDF gốc 1-based. Không hệ thứ hai.

#### 3b. Chiều rộng là **vị trí**, không phải **thời lượng** — và trộn hai thứ này sẽ hỏng ở chỗ khó tìm

Orchestrator viết "mỗi BeatBox kéo dãn được width, thể hiện độ dài của mỗi beat". Câu đó đọc được theo hai nghĩa và chỉ một nghĩa đứng vững, nên ADR ghi rõ nghĩa đúng:

> Chiều rộng của một BeatBox nói **playhead phải nằm ở đâu trên giấy** khi phách ấy vang lên. Nó **không** nói phách ấy dài bao lâu. Thời lượng đến từ tempo và time signature (và từ dấu thời gian đã gõ, nếu có SyncMap gõ tay).

Lý do phải tách: khắc nhạc **không tỉ lệ với thời gian**. Một ô nhịp có một nốt tròn và một ô nhịp có mười sáu nốt móc kép dài bằng nhau nhưng chiếm chiều rộng khác hẳn. Nếu suy thời lượng từ chiều rộng thì mọi bài có mật độ nốt thay đổi sẽ chạy sai nhịp, và triệu chứng — "playhead lúc nhanh lúc chậm ở những chỗ khác nhau tuỳ bài" — là loại lỗi tốn nhiều ngày nhất để lần ra.

Hai kênh độc lập, gặp nhau đúng một chỗ: playhead nội suy **vị trí** theo chiều rộng, trong khoảng **thời gian** mà tempo quy định.

#### 3c. Một SyncMap sinh ra bằng một trong ba đường, và cả ba cùng đổ vào một cấu trúc

**Tính ra từ MeasureMap.** Có tempo và time signature ở mỗi ô nhịp là có thời lượng mỗi ô nhịp, cộng dồn ra được thời điểm mọi ô nhịp và mọi phách. **Không cần gõ một lần nào.** Đây là "default SyncMap tương tự midi syncmap" mà Orchestrator mô tả, và nó là mặc định — hễ MeasureMap tồn tại thì SyncMap này tồn tại. Nó cũng là toàn bộ nội dung của ý tưởng ban đầu "SyncMap không cần BackingTrack, chỉ cần metronome và tempo từng ô nhịp".

**Gõ theo một BackingTrack.** Người dùng nghe, gõ theo, ở **đơn vị họ chọn** — mỗi phách, mỗi ô nhịp, mỗi hai ô nhịp — cộng một phím gõ riêng đánh dấu **vạch nhịp**, đúng như Orchestrator mô tả. Ba ràng buộc mà Spec phải giải chứ không được bỏ qua: gõ tay có **jitter** nên cần làm trơn; sai một nhịp phải **sửa lại một điểm** chứ không phải gõ lại cả bài; và toàn bộ chuỗi gõ **lệch trễ một lượng gần như không đổi** vì cộng cả độ trễ cảm ứng lẫn độ trễ xuất âm — cần một offset hiệu chuẩn, cùng họ với phép đo của spike thu âm nhưng nhẹ hơn nhiều. `useTappingSystem` bên repo web đã va phải cả ba; đọc nó trước khi viết là rẻ (quyết định 6).

**Sinh theo cấu trúc khi thu âm cùng click.** Thu trong lúc nghe metronome thì SyncMap đã biết trước: chính app phát ra cái click ấy. Còn lại đúng một ẩn số là độ lệch thu↔phát, và đó là việc của spike.

Một Score có **nhiều** SyncMap có tên, mỗi cái tuỳ chọn trỏ tới một BackingTrack (`null` nghĩa là chỉ metronome), một cái được đánh dấu đang dùng.

#### 3d. Ranh giới với OMR, viết ra vì đây là con dốc trơn nhất của cả ADR

Vẽ RowBox bằng tay trên trăm trang là việc thật, nên sẽ có lúc ai đó nói "cứ dò vạch nhịp tự động là xong". **Dò tự động vạch nhịp hay dòng kẻ nhạc từ ảnh trang là OMR**, thuộc ADR 0006 và H6, và ADR này **không mở nó**. Hai cách giảm công được phép, và chúng đủ xa OMR:

- **Chép layout từ trang trước.** Trong một bản nhạc, phần lớn trang có cùng số dòng ở cùng vị trí. Chép rồi sửa rẻ hơn vẽ lại cả trang một bậc độ lớn.
- **Mỗi lần chỉ map một bài.** Sau quyết định 2, một Score là một bài chứ không phải cả cuốn sách, nên khối lượng chia theo bài chứ không dồn thành một trăm trang.

Nếu về sau muốn dò tự động thì đó là một ADR mở H6, không phải một dòng thêm vào Spec MeasureMap.

#### 3e. Từ vựng

Đề xuất cho G1 lúc build: **MeasureMap**, **RowBox**, **MeasureBox**, **BeatBox**. Ba điều kèm theo.

`MeasureBox` và `beatSplits` **trùng đúng tên và đúng nghĩa** với repo web. Đó không phải vi phạm ADR 0014 — ADR ấy cấm bịa **tên thứ ba** và cấm ép đổi tên, chứ không cấm hai context gọi cùng một thứ bằng cùng một tên khi nó thật sự là cùng một thứ. Ở đây nó là, và điều đó làm phép dịch ở quyết định 6 gần như không tốn gì. Thêm hàng vào bảng đối chiếu của 0014, đừng đổi tên bên nào.

**`MeasureAnchor` bị rút.** ADR 0017 quyết định 6 đề xuất tên đó cho "một ô nhịp được định vị trên trang"; `MeasureBox` nay làm đúng việc ấy và làm tốt hơn vì nó khớp sẵn với bên kia. Một tên là đủ.

Tên của nó là **`SystemBox`** — Orchestrator chốt ở G2 câu 7. Thuật ngữ khắc nhạc cho khái niệm này là *system*, và repo web đã mã hoá nó thành `systemIndex` trên chính `MeasureBox`. Phần còn lại của ADR này viết `RowBox` ở vài chỗ vì soạn trước lúc chốt; đọc là `SystemBox`, và sửa dứt điểm ở G1 của Spec **0058** (số MeasureMap sau revision 7). Luật cứng: **không được có hai tên cho nó trong cùng repo này**.

Để dịch được cả hai chiều, mỗi MeasureBox phải mang **chỉ số dòng của nó** — đúng vai `systemIndex` bên web. Nhờ vậy RowBox dựng lại được bằng cách gom nhóm, tức nó là một đối tượng của UI và của lưu trữ mà không cần là đối tượng của phép trao đổi.

### 4. Transport chạy bằng Dart trên SoLoud — ADR 0004 phải sửa lời cho nhánh này

ADR 0004 nói Transport chạy ở tầng native vì Web Audio trong WebView không kham nổi. Lập luận đó vẫn đúng **cho nhánh nó nói về** — SmartMode, WebView, MIDI, tức H3/H4, tức phần đang đóng. Nó **không** áp cho nhánh này, vì ở đây không có WebView, không có MIDI, và `getEngineTime()` + `playScheduled()` cho ra đúng một clock chia sẻ mà `ClickLane` và `BackingLane` cùng đứng lên.

ADR 0007 giữ nguyên nguyên vẹn: một clock, nhiều lane, mixer có gain/mute, SyncMap là chỗ khớp. ADR này chỉ nói **lane chạy ở đâu**, không nói lại chúng là gì. Quyết định 6 của ADR 0007 — "BackingTrack dùng chủ yếu ở SmartMode; PdfMode+backing là Spec sau nếu SyncMap thiết lập được mà không cần MusicXML" — **điều kiện đã thoả**, và lời của nó phải sửa khi ADR này accepted.

Câu chặn của `TRANSPORT-ARCHITECTURE.md` — *"Do not invent a second audio player for PDF 'just for now.'"* — ADR này **không xin miễn trừ**. Nó làm ngược lại: metronome hôm nay đã là một player rời, và slice Transport phải **nuốt nó vào làm `ClickLane`**, không để hai đường phát song song. Câu hỏi mở số 3 của tài liệu đó ("Is PdfMode+backing in scope within first year?") coi như trả lời là **có**.

### 5. Nhập BackingTrack trước, thu âm sau — và thu âm phải qua spike trước khi có Spec

Orchestrator nêu thu âm là ý số 1. ADR này giữ nguyên **phạm vi** đó và đảo **thứ tự**, vì ba lý do đo được:

- Phần lớn nhạc công **đã có sẵn** file nhạc đệm; nhập một mp3 rẻ hơn thu âm cả một bậc độ lớn và phủ nhiều tình huống hơn.
- Thu âm sinh ra **đúng cái artefact** mà nhập sinh ra. Làm nhập trước nghĩa là Transport, mixer và SyncMap-gắn-audio đã chạy và đã qua G4 trước khi chạm phần khó nhất.
- Ba dữ kiện ở Bối cảnh nói rằng thu âm **chưa chắc là một tính năng**: tam giác codec chưa có lối thoát nào rẻ, và độ lệch thu↔phát không gói nào cho biết. Cả hai chỉ quyết được bằng một con số đo trên máy thật.

Nên **hai spike đứng trước hai slice audio**, và spike thu âm có quyền kết luận là *chưa làm được* — đó là kết quả hợp lệ của một spike, không phải một thất bại.

### 6. Công cụ soạn sống **trong app**, và cái giá là dữ liệu phải trao đổi được

Orchestrator chốt: soạn trong app, nhạc công tự làm, team cũng dùng chính nó để dựng danh mục.

Cái giá phải ghi thẳng: repo web **đã có** công cụ làm đúng việc này — `useTappingSystem` và `SyncWorkspaceClient`. Xây thêm một cái nữa là nhân đôi đúng chỗ trùng lặp mà ADR 0014 đã ghi là **câu hỏi sản phẩm chưa trả lời** (4.463 dòng PdfViewer bên web trùng với bộ parity repo này dựng qua Spec 0001–0041). Quyết định này không giải câu hỏi đó, nó cộng vào.

**Điều kiện để cái giá đó chấp nhận được: trùng giao diện thì được, trùng dữ liệu thì không.** Sau quyết định 3 thì điều kiện ấy cụ thể tới mức kiểm được bằng một test round-trip:

| StageScore | Backing & Score web |
|---|---|
| `MeasureBox` — trang, số ô nhịp, chỉ số dòng, toạ độ `0..1` | `MeasureBox` — `pageIndex`, `measureNumber`, `systemIndex`, toạ độ `0..1` |
| `BeatBox` trong một `MeasureBox` | `beatSplits` |
| `SyncMap` | `timemap` — `TimemapEntry` |
| thời điểm của một ô nhịp / một phách | `timeMs`, `beatTimestamps` |
| tempo tại một phách | `tempoAtBeat` |
| ô nhịp lấy đà | `startsAtBeat` |

Phép dịch phải chạy **cả hai chiều** và không mất mát. Nếu hai công cụ đẻ ra hai định dạng không dịch được cho nhau thì mọi MeasureMap soạn trong app sẽ vô dụng với danh mục, và ngược lại — và lúc đó thứ bị nhân đôi không còn là một màn hình mà là cả kho nội dung.

### 7. SongPack có hai tầng, và tầng dưới là đơn vị

- **Một SongPack là một Score**, đóng gói cùng mọi thứ cần để chơi được nó: PdfDocument (đúng PageExtent của nó), MeasureMap, các SyncMap, các BackingTrack, annotation, Bookmark, JumpLink, PageOrder.
- **Một gói nhiều bài là một tập hợp các SongPack một bài** — album, tuyển tập etude, giáo trình. Nó không có cấu trúc riêng ngoài thứ tự và siêu dữ liệu; nó **chứa** các gói một bài chứ không phải một định dạng thứ hai.

Một định dạng, dùng ba chỗ. Đây là điểm hội tụ đáng giá nhất của ADR này: phần Bối cảnh của ADR 0017 viết rằng thứ Discover còn thiếu **không phải một endpoint** mà là *"một gói tải hình dạng StageScore: PDF, audio, SyncMap và overlay về trong một lần tải, kiểm quyền một lần"*. Đó chính xác là SongPack.

Hình dạng kỹ thuật dùng lại idiom của `LibraryBackup`: ZIP cộng một tệp marker khai `format` và `version`. Nhưng **format id mới phải mang cách viết hiện tại của thương hiệu**, không kéo theo `standscore` — cái tên cũ được giữ ở backup vì nó đã ghi ra đĩa của người dùng rồi, còn một định dạng chưa từng tồn tại thì không có nợ nào để giữ.

**Nhập là một lựa chọn, không phải một việc tự động.** Mở một pack cho thấy **bên trong có gì trước khi thêm bất cứ thứ gì**: bao nhiêu bài, tên gì, kèm nhạc đệm nào, nặng bao nhiêu. Người dùng chọn lấy cả gói hay lấy vài bài. Không có đường nào mà chạm vào một tệp rồi thư viện tự dày lên. Điều này rẻ để làm, và nó xoá phần lớn nỗi lo ở quyết định 8.

#### 7b. Một pack có **hai nguồn gốc**, và nguồn thứ hai nặng hơn nguồn thứ nhất rất nhiều

Orchestrator bổ sung ngày 2026-08-05: một SongPack có thể do **tác giả khác** làm ra, bán trên nền tảng bên ngoài, người dùng mua rồi nhập vào app; và một pack như thế mang theo **thông tin giới thiệu tác giả và giới thiệu gói**.

Nghe như một trường siêu dữ liệu. Nó không phải. Nó đổi bản chất của định dạng:

> Nếu chỉ nhạc công tự xuất tự nhập thì SongPack là **một tiện ích nội bộ** — hỏng thì sửa ở bản sau, đổi thì đổi, không ai ngoài kia phụ thuộc. Từ lúc một người lạ **bán** một pack thì SongPack là **một hợp đồng công khai**, và mọi bản app về sau phải đọc được thứ họ đã bán hôm nay.

Bốn thứ theo sau, và cả bốn phải nằm trong định dạng **ngay từ phiên bản đầu**, vì thêm sau là phá vỡ tương thích:

- **Siêu dữ liệu tác giả và gói:** tên tác giả, giới thiệu, liên hệ tuỳ chọn, ảnh bìa, mô tả gói, phiên bản gói, giấy phép do tác giả tự khai. Đây là thứ người mua nhìn thấy trước khi nhập, và là thứ phân biệt một sản phẩm với một tệp.
- **Hiển thị là *lời khai của gói*, không phải *lời bảo chứng của app*.** App không xác minh được tác giả có thật hay có quyền với bản nhạc bên trong. Câu chữ trên màn hình nhập phải phản ánh đúng điều đó. Đây là chi tiết nhỏ về từ ngữ với hệ quả pháp lý không nhỏ.
- **Hai số phiên bản, không phải một:** phiên bản *định dạng* và **phiên bản app tối thiểu**. Không có cái thứ hai thì một app cũ gặp pack mới sẽ nhập được một nửa rồi im lặng bỏ qua phần nó không hiểu — mất SyncMap, mất BackingTrack, mà người dùng tưởng đã nhập xong. Có nó thì app nói thẳng *"gói này cần StageScore bản mới hơn"*.
- **Không DRM, không kích hoạt, không gọi về máy chủ.** Tác giả bán hàng sẽ hỏi xin điều ngược lại, nên nó phải được ghi thành lời trước khi bị hỏi. Một lần kiểm giấy phép qua mạng là phá bất biến offline mà cả sản phẩm này đứng trên — và nó biến một tính năng nhập tệp thành một tính năng có tài khoản, có máy chủ, có thời hạn sống. Pack đã mua là tệp của người mua, như một cuốn sách giấy.

Và một thứ đổi trọng số ở chỗ không ai ngờ: **công cụ soạn MeasureMap ở quyết định 4 và 6 vừa thành công cụ sản xuất.** Tác giả bên thứ ba không có công cụ nào khác — họ dựng pack **bằng chính app này**. Nghĩa là tiêu chuẩn của nó không còn là "đủ để một nhạc công map bài của mình" mà là "đủ để một người lạ làm ra thứ bán được". Đó là một mức chất lượng khác, và nó phải được biết từ Spec **0058** (số MeasureMap sau revision 7) chứ không phát hiện ra ở slice SongPack.

### 8. Nội dung nhập vào **hiện trong danh sách Score**, và câu hỏi thật không phải "có lẫn không" mà "có biết nó từ đâu tới không"

Orchestrator hỏi: nhập một pack rồi nó hiện lẫn vào danh sách Score ở tab Library thì người dùng có rối không. Câu trả lời có hai vế, và vế thứ hai mới là vế quan trọng.

**Vế thứ nhất: không cho nó hiện ở đó thì hỏng một thứ nặng hơn nhiều.** Nếu bài nhập về không nằm trong danh sách Score, nhạc công **không xếp được nó vào Setlist cạnh PDF của chính mình** — đúng lúc cần nhất là lúc dựng chương trình biểu diễn. Nó cũng không tìm được bằng ô search, không gán Label được, không lọc chung được, không sắp xếp chung được. Đó chính là lý do ADR 0017 đã **bác** phương án "nội dung sống ở một kệ riêng". Cái giá ấy là vĩnh viễn và nó lớn hơn cái giá của sự bối rối.

**Vế thứ hai: nỗi lo là thật, nhưng nó là lỗi trình bày, và nó có tên chính xác.** Người dùng không rối vì "bài này không phải của tôi". Họ rối vì **mười hai hàng mới hiện ra cùng lúc mà không có gì nói chúng đến với nhau**. Đó là một vấn đề về nguồn gốc và nhóm, không phải về nơi cư trú. Bốn thứ chữa nó, cả bốn đều rẻ:

- **Nhập có xem trước** (quyết định 7) — không có gì hiện ra bất ngờ, vì người dùng vừa nhìn thấy danh sách và bấm đồng ý.
- **Dấu nguồn gốc trên mỗi Score** — nó đến từ pack nào. ADR 0017 quyết định 2 đã đòi đúng trường này cho nội dung Discover; nay nó phục vụ cả hai đường.
- **Gom nhóm và lọc theo pack ngay trong Library** — dùng lại đúng cơ chế của Label filter đã ship ở Spec 0021.
- **Màn hình SongPack là nơi thấy pack như một pack** — quyết định 9.

Nói cách khác: pack không phải một **nơi chứa** Score, nó là một **thuộc tính** của Score. Score sống ở một chỗ duy nhất; pack là một cách nhìn vào chỗ đó.

Một chi tiết phải chốt ở Spec chứ không để implementer đoán: **nhập lại cùng một pack lần thứ hai thì làm gì.** Ba hành vi khả dĩ là nhân đôi, ghi đè, hay bỏ qua; khuyến nghị **hỏi, mặc định bỏ qua bài đã có** — vì ghi đè im lặng sẽ xoá annotation nhạc công đã viết lên bản nhập lần trước, và đó là mất mát không lấy lại được.

Với pack mua từ tác giả bên thứ ba, chi tiết ấy **thôi là trường hợp biên và thành đường đi chính**: tác giả sửa một nốt sai, sửa một điểm SyncMap lệch, rồi phát hành bản 1.1 cho người đã mua. Nên "cập nhật một pack đã cài" phải là một đường có thật, và nó phải giữ lại phần của người dùng — annotation, SyncMap tự gõ, PageOrder đã sửa. Chỗ khó nằm ở chỗ dễ bỏ sót: **nếu tác giả đổi chính file PDF và số trang đổi theo**, mọi annotation neo theo trang đều lệch. Không giải ở đây, nhưng Spec của slice SongPack phải trả lời, và câu trả lời "cứ ghi đè" là không chấp nhận được.

### 9. Màn hình SongPack là **lối vào thứ hai**, không phải **vòng đời thứ hai**

Orchestrator chọn một màn hình tách hẳn khỏi Library. Quyết định này nhận lựa chọn đó và ghi kèm bất biến giữ cho nó không trượt thành thứ ADR 0017 đã bác:

> **Một Score đến từ SongPack là một Score bình thường trong library.** Nó hiện trong tab Scores, tìm được, gán Label được, xếp vào Setlist được, sửa PageOrder được, backup được — y hệt một PDF nhạc công tự nhập. Màn hình SongPack là một **cách nhìn thứ hai** vào cùng những Score đó, không phải một kho thứ hai chứa những Score khác.

Cụ thể: không có bảng "packed scores" riêng, không có thư mục riêng trên đĩa cho nội dung đến từ pack, không có đường nào mở một Score mà chỉ đi qua màn hình SongPack.

Điều đó cho màn hình SongPack một việc mà tab Scores không làm được, và đó là lý do nó tồn tại: nó là nơi thấy **gói như một gói** — bài nào đã có nhạc đệm, SyncMap nào đang dùng, gói nào đã xuất đi rồi, gói nào còn thiếu MeasureMap. Nếu nó chỉ là danh sách Score bày đẹp hơn thì nó không đáng một màn hình.

**Pack của tác giả bên thứ ba làm màn hình này khó hơn, không dễ hơn.** Bản nháp trước ngầm giả định mọi thứ trên đó là **của người dùng và đang dựng dở** — nên nó ngả về hình dạng *bàn làm việc*: còn thiếu gì, làm tới đâu. Một gói vừa mua thì ngược hẳn: nó **xong rồi**, nó là công của người khác, người dùng không dựng gì cả — thứ họ muốn thấy là bìa, tên tác giả, giới thiệu, trong gói có bài nào. Đó là hình dạng *kệ sách*, không phải bàn làm việc.

Hai hình dạng ấy không mâu thuẫn nếu nhìn đúng: **màn hình bày *pack*, và pack có trạng thái.** Pack mua về tới nơi đã đầy đủ; pack đang dựng thì còn lỗ hổng. Cùng một thẻ, khác phần chân thẻ. Cái nó **không** làm là bày lẫn "Score chưa bao giờ định thành pack" — thứ đó thuộc tab Scores, và kéo nó sang đây là dựng lại chính sự trùng lặp mà quyết định 8 vừa tránh.

Hệ quả cho câu hỏi tên: khuyến nghị "bàn làm việc" ở bản trước **yếu đi**, vì phần lớn nội dung màn hình này rồi sẽ là công của người khác chứ không phải việc đang dở của người dùng. **Tên đã chốt ở G2 câu 5: `Packs`** (`Studio` bị bác) — kèm luật nhãn-ngắn ở mục "Hai ràng buộc" phía dưới, vì `Packs` không phải số nhiều của term `SongPack`.

Va chạm phải biết: Library hôm nay có hai tab bằng `SegmentedButton` trong `library_screen.dart` (1.407 dòng); thêm một đích cấp cao nhất nhiều khả năng đổi `home:` sang một nav shell, và việc đó chồng lên Spec **0046** đang `hold`.

### 10. `formatVersion` lên **2** đúng một lần, cho ba việc đang cùng chờ nó

Ba thứ độc lập nhau cùng muốn bump: **sao lưu chọn lọc** (nợ để lại từ Spec 0050), **Discover lưu tham chiếu thay vì nuốt asset có bản quyền** (ADR 0017 quyết định 8), và **layout trên đĩa đổi vì PdfDocument tách khỏi Score** (quyết định 2). Bump ba lần nghĩa là bản app cũ phải từ chối file mới ba lần với ba lý do khác nhau — đúng loại việc mà kiểm tra version ở `library_backup.dart` tồn tại để làm, và đúng loại việc không nên làm ba lần.

Gom vào slice của quyết định 2, vì nó là slice duy nhất trong ba thứ **chắc chắn** chạy.

**Bump chỉ lo được một chiều, và Spec 0052 tìm ra chiều còn lại chưa có ai viết.** `_validateMarkerAt` từ chối theo luật *mới hơn thì từ chối*, không phải *khác thì từ chối* (`version > LibraryBackup.formatVersion`, `library_backup.dart:529-535`). Nên lên `2` chặn được bản app cũ đọc file mới — đúng việc cần. Nhưng bản **mới** đọc backup `version: 1` sẽ **qua cửa** và đổ một `library.json` đời cũ vào chỗ code đang mong đợi `PdfDocument`. Từ chối nó là không được — mất dữ liệu với đúng những người cẩn thận nhất, tức người có backup. Nên di trú phải là **một hàm của library root**, idempotent, gọi ở **cả hai** chỗ: lúc mở library **và ngay sau mỗi lần restore thành công**. Nếu chỉ gọi lúc khởi động thì một lần restore giữa phiên là một library hỏng.

Đi kèm, và đây là chỗ dễ sai âm thầm: `library.json` **không có số phiên bản nào** (payload đúng một khoá `'scores'`), nên di trú phải nhận ra manifest cũ bằng **sự vắng mặt của một trường**, không bằng một con số — và nó không có chỗ nào để ghi rằng mình đã di trú xong.

### 11. Tách một PDF thành nhiều Score: hai lối vào, bốn hành vi đổi

Đây là câu Orchestrator hỏi trực tiếp, và bản nháp đầu chỉ nói mô hình dữ liệu mà không nói người dùng làm thế nào.

**Hai lối vào, vì hai tình huống thật sự khác nhau.** Từ một Score **đã có**, một mục trong `⋯` mở màn hình tách — vì thư viện hiện tại đã đầy những cuốn sách đang nằm dưới dạng một Score, và chúng phải tách được mà không cần nhập lại. Lối thứ hai gắn với việc **nhập**, nhưng **không nằm trong luồng nhập** — xem đoạn dưới.

**Câu hỏi lúc nhập đứng *sau* khi nhập, không phải *trong* lúc nhập.** Bản trước của ADR này nói "nếu PDF nhiều trang thì hỏi một câu: đây là một bản nhạc hay một tuyển tập", và Spec 0052 tìm ra dữ kiện làm câu đó không dùng được: **import nhận nhiều file một lượt** (`allowMultiple: true`, `library_screen.dart:741-746` → `importPdfs`), nên một lần nhập mười hai bài thành **mười hai hộp thoại liên tiếp**. Đường giữ đúng ý định mà không chặn luồng nhập: nhập y như hôm nay, rồi nếu có file nào **trông như tuyển tập** — có mục lục với ≥ `2` đích, hoặc dài hơn `30` trang — thì **một** thanh gợi ý duy nhất ở đầu danh sách, bỏ qua được. Lời hứa cũ vẫn nguyên: người chỉ nhập một bài **không thấy thêm một bước nào**.

**Màn hình tách là lưới trang, không phải hộp nhập số trang.** Bày thumbnail các trang; người dùng đánh dấu "bài mới bắt đầu ở đây". Mỗi dấu sinh một Score chạy tới dấu kế tiếp. Người ta nhận ra chỗ bắt đầu một bài bằng cách **nhìn thấy** tiêu đề trên trang, không bằng cách nhớ số trang. Spec **0048** (PageOrder dạng lưới, đang `hold`) đã nghĩ sẵn phần lớn hình dạng này — đọc lại nó trước khi vẽ.

**Với PDF có mục lục thì gần như không phải làm gì**, và đây là chỗ dữ kiện mới đổi hẳn chi phí. `pdfrx` cho `loadOutline()` trả về cây `PdfOutlineNode` mang cả `title` lẫn trang đích — và trang đích là một **trường** (`PdfDest.pageNumber`, 1-based), không phải thứ phải suy ra. Một tuyển tập hay một fake book gần như luôn có mục lục, nên app **đề xuất sẵn cả ranh giới lẫn tên bài**, người dùng chỉ soát và bấm đồng ý. Năm mươi bài tách xong trong một phút thay vì một buổi. Đây là đề xuất chứ không phải áp đặt: mục lục có thể sai hoặc thô, nên sửa được từng dấu.

Hai hình dạng của API phải chịu được, cả hai do Spec 0052 đọc ra từ source và không cái nào lộ ra từ chữ "cây mang title và trang đích": `dest` là **nullable** và trả `null` khi `FPDFDest_GetView` cho `type == 0`, tức **một nút mục lục có thể không có trang đích nào**; và cây là **đệ quy** (`children`), nên một tuyển tập chia chương cho cây **nhiều tầng** chứ không phải danh sách phẳng. Bỏ sót vế đầu là crash trên một tệp thật; bỏ sót vế sau là mất toàn bộ bài của một tuyển tập có chương.

**Và ranh giới với OMR phải nói lại ở đây, vì đây là chỗ nó dễ mờ nhất:** đọc mục lục là đọc **siêu dữ liệu có cấu trúc của tệp**, không phải nhìn vào trang giấy. Dò ranh giới bài từ **ảnh** trang là OMR, thuộc ADR 0006 và H6, và quyết định 3d không mở nó. Hai việc trông giống nhau ở kết quả và khác nhau hoàn toàn ở đầu vào.

**Score có thể chứa Score con** *(viết lại ở revision 6; revision 5 cho `PdfDocument` một hàng tiêu đề nhưng cấm nó là Score; G4 của 0054 cho thấy hàng tiêu đề + mọi bài luôn mở thì Library bí bách)*. Một Score có `parentId == null` là **gốc** — hàng duy nhất của tệp ấy trên Library. Các Score con (`parentId` trỏ gốc) cùng một `PdfDocument`, mỗi con một `PageExtent`. **Không có term miền `Piece`:** con là Score đủ chức năng; chữ *piece* chỉ trên UI, cùng hình dạng `book` / `Packs`.

**Library mặc định chỉ hiện gốc.** Bấm gốc có con → màn hình danh sách con; *Open full score* mở PdfMode cả tệp trên chính Score gốc (`pageExtent` null). Setlist nhận id gốc **hoặc** id con. Thumbnail gốc = trang 1 PDF; thumbnail con = trang đầu PageExtent. Người chưa tách gì không thấy khác biệt: Score một-bài vẫn là một hàng, tap mở PdfMode.

**Tách giữ gốc, không biến gốc thành bài thứ nhất** (đảo luật Spec 0052 ở điểm này). `id` gốc ổn định qua lần tách; con là Score mới. Tách lại một con = thay nó bằng N anh em dưới **cùng** gốc — **một tầng** trong nhóm slice này, không cây sâu. Di trú: thư viện phẳng đã tách (nhiều Score cùng `pdfDocumentId`, không `parentId`) nhận một gốc tổng hợp.

**Lớp phủ theo `scoreId`, kể cả khi mở gốc all-pages.** Annotation / PageOrder / Bookmark / page scale / MeasureMap / SyncMap / BackingTrack của gốc và của từng con là **các store riêng**. Trên all-pages: mặc định chỉ mực gốc và **vẽ được** (ghi vào gốc); toggle *Show piece notes* hiện thêm union mực mọi con theo trang tuyệt đối và **khoá Draw**. Không bao giờ ghi vào store con từ phiên all-pages. MeasureMap/SyncMap/BackingTrack **không** union từ con trong all-pages ở nhóm slice này.

**Ba thứ vẫn bị từ chối:** không tab danh sách tệp; không biến `PdfDocument` thành Score (gốc mới là Score); không bắt buộc MeasureMap trên gốc — luyện từng bài + SyncMap sống ở Score con; gốc all-pages đủ để duyệt / diễn cả cuốn / Setlist cả sách.

**Phần còn đúng từ revision 5 và không bị đảo:** `PdfDocument` vẫn có `title` (đồng bộ / fallback tên); tách lặp lại được trong phạm vi một Score; đọc outline không phải OMR; đếm tham chiếu khi xoá; Replace PDF ảnh hưởng mọi Score cùng tệp; thumbnail và page scale theo trang phải bàn giao đúng lúc tách. **Hàng tiêu đề nhóm phẳng của Spec 0054** thôi là UI Library chính — Spec **0055** thay bằng hàng Score gốc + drill-in.

**Bốn hành vi đã ship phải đổi, và cả bốn đều là chỗ dễ mất dữ liệu.** Bản trước đếm ba; Spec 0052 tìm ra cái thứ tư.

- **Xoá** (Spec 0028): xoá một Score không được xoá PDF khi còn Score khác dùng chung; xoá cái cuối cùng thì mới dọn tệp. Hỏng theo chiều ngược lại là một tệp mồ côi nằm lại vĩnh viễn, nên đếm tham chiếu phải có test.
- **Replace PDF** (Spec 0024): nay ảnh hưởng **mọi** Score dùng chung tệp đó. Phải nói rõ trong hộp thoại — **kèm con số**, vì người bấm nút chỉ đang nghĩ tới bài họ vừa mở — và số trang của tệp mới có thể làm một PageExtent trở nên vô nghĩa, phải xử lý, không được để im.
- **Thumbnail**: `ScoreThumbnails` khoá theo `scoreId` cộng mtime của PDF và dựng trang 1; nay phải dựng **trang đầu của PageExtent**. Nếu không, mười hai bài trong một cuốn sẽ có mười hai thumbnail giống hệt nhau. Thứ bản trước chưa nói: **mtime không đổi khi PageExtent đổi**, nên sửa một extent sẽ *không* làm mới ảnh — PageExtent phải vào **khoá cache**, không chỉ vào tham số render.
- **Page scale theo trang** (Spec 0031) — **cái thứ tư, và là kho neo theo trang duy nhất nằm trong một file dùng chung.** `PageScalePrefs.pageScales` khoá bằng `"$scoreId:$sourcePage"` (`page_scale.dart:34,40-41`) trong `page_scale_prefs.json` **app-level**, không phải file theo Score. Nên tách một Score thành mười hai làm mọi override scale theo trang của cuốn sách **mồ côi ngay lúc tách**, vì khoá vẫn mang `scoreId` của cuốn sách.

### 12. Audio session có đúng một chủ

Sau nhóm này sẽ có **ba** thứ cùng chạm audio session của iOS: SoLoud, gói thu âm, và `google_mobile_ads` của bản 1.1 (tài liệu SoLoud nói thẳng gói quảng cáo cần `isAudioSessionApplicationManaged = true`). Tài liệu SoLoud cũng nói nó **cố ý không** quản session và ta phải cấu hình `audio_session` **trước** `SoLoud.instance.init()`; `record` thì cần tắt việc nó tự quản qua `AudioRecorder().ios.manageAudioSession(false)`, và bỏ bước đó làm lần thu đầu tiên trễ khoảng một giây.

Nên: **một module trong repo này sở hữu audio session, mọi thứ khác được cấu hình để không đụng vào.** Không phải kỷ luật — nó là một hạng mục G4, vì hỏng ở đây hiện ra dưới dạng "thu âm im lặng trên một số máy" chứ không dưới dạng một test đỏ.

### 13. App là **nơi nhận trung lập**, và ranh giới đó là ranh giới App Review

Người dùng mua pack ở ngoài rồi nhập vào. Chừng nào app chỉ **nhận** thì việc này cùng loại với nhập một bản PDF đã mua — hoàn toàn bình thường, không có nghĩa vụ nào phát sinh. Thứ làm nó đổi loại là app **dẫn người ta đi mua**.

Quy tắc 3.1.1 của Apple nhắm vào việc app đưa người dùng ra ngoài để mua nội dung số dùng trong chính app. Nên bốn thứ nghe rất vô hại đều nằm ngoài phạm vi ADR này, và cả bốn phải bị từ chối bằng phản xạ chứ không bằng tranh luận từng lần:

- một danh mục pack mua được, dù chỉ là danh sách tĩnh
- một nút "tìm thêm gói" dẫn ra web
- một liên kết tới gian hàng của tác giả, kể cả khi nó nằm trong siêu dữ liệu do tác giả tự khai
- bất kỳ chỗ nào trong app nói nơi bán và giá

Trường liên hệ ở quyết định 7b vì thế phải được xử lý **như văn bản, không như liên kết**. Một tác giả điền URL gian hàng vào ô giới thiệu là chuyện chắc chắn xảy ra; app hiển thị nó thành chữ thì đó là lời khai của tác giả, biến nó thành nút bấm được thì đó là app đang dẫn đường.

Đi kèm, và cũng là thứ giữ cho mọi chuyện đơn giản: **StageScore không ăn chia, không có quan hệ thanh toán với tác giả pack, không biết ai bán gì cho ai.** Ngày nào có phần trăm doanh thu thì lập tức có nghĩa vụ IAP, có kiểm duyệt nội dung, có hỗ trợ hoàn tiền — một sản phẩm khác hẳn.

Phải phân biệt rành mạch với ADR 0017, vì hai thứ trông giống nhau mà bản chất ngược nhau:

| | Pack của bên thứ ba (ADR này) | Discover (ADR 0017, `hold`) |
|---|---|---|
| Bán ở đâu | ngoài app, app không biết | trong app |
| Thanh toán | không có trong app | IAP + entitlement |
| Mạng | không | có |
| Ai làm nội dung | bất kỳ ai | team |
| Nghĩa vụ App Review | như nhập một tệp | như một cửa hàng |

Hai mô hình này **không được trộn vào một màn hình**. Và `no_ads` của ADR 0018 quyết định 12 không mở khoá cái nào trong hai — nó vẫn chỉ tắt quảng cáo.

---

## Trình tự (Sequencing)

Mỗi dòng một Spec. Số Spec đề xuất; 0037–0039 vẫn dành cho Phase C, 0045–0049 vẫn `hold`, 0051 là quảng cáo.

| # | Slice | Spec | Tier | Chặn bởi |
|---|---|---|---|---|
| 1 | `PdfDocument` tách khỏi `Score`; PageExtent; tách PDF bằng lưới trang + đề xuất từ outline; `formatVersion` → 2 | 0052 | L | ADR này |
| 2 | Nguồn gốc trên hàng Library; lọc theo tệp nguồn | 0053 | M | 1 |
| 3 | Tên riêng cho `PdfDocument`; tách lặp lại được; nhóm phẳng theo cuốn sách (tiền tố; UI bị 4 thay) | 0054 | M | 1, 2 |
| 4 | Score gốc chứa Score con; Library một hàng / một tệp; drill-in; all-pages + toggle mực con | 0055 | M | 1–3 |
| — | *(ngoài ADR này)* Half Page thành scroll liên tục; default Layout | 0056 | M | — |
| — | *(ngoài ADR này)* Localization — 9 ngôn ngữ | 0057 | M | — |
| 5 | MeasureMap: vẽ SystemBox → MeasureBox → BeatBox, chép layout trang trước; **nhảy tới ô nhịp** | 0058 | L | 1, 4 |
| 6 | SyncMap tính từ MeasureMap; metronome đi theo tempo và loại nhịp của bài | 0059 | M | 5 |
| 7 | Lật trang rảnh tay và chỉ báo vị trí, chạy bằng MeasureMap + SyncMap | 0060 | M | 6 |
| 8 | **Spike:** SoLoud 4.1.x, hai lane trên `getEngineTime`, đo độ trễ xuất âm trên máy thật | 0061 | spike | ADR này |
| 9 | Nhập BackingTrack + Transport (`ClickLane` nuốt metronome, `BackingLane`); sao lưu chọn lọc đi kèm | 0062 | L | 7, 8 |
| 10 | SyncMap gõ theo BackingTrack: chọn đơn vị gõ, làm trơn, sửa một điểm, offset hiệu chuẩn | 0063 | M | 9 |
| 11 | Định dạng SongPack: xuất, nhập có xem trước, siêu dữ liệu tác giả, cập nhật pack đã cài | 0064 | L | 10 |
| 12 | Màn hình SongPack | 0065 | M | 11 |
| 13 | **Spike:** đo độ lệch thu↔phát và chốt codec, một máy Android và một máy iOS | 0066 | spike | 9 |
| 14 | Thu âm từ microphone và line-in; SyncMap sinh theo cấu trúc | 0067 | L | 13 |

**Slice 2 / 3** chen từ G4 (revision 4–5) — giữ nguyên lý do trong log. **Slice 4 chen ở revision 6** từ G4 cảm nhận của 0054: nhóm phẳng luôn mở là bí bách; Orchestrator chốt Score gốc + danh sách con thay hàng tiêu đề `PdfDocument`. Nó đứng trước MeasureMap vì UI Library đang sai trên máy thật, vì `parentId` là neo Setlist/SongPack sẽ dùng, và vì luật lớp phủ all-pages phải có trước khi vẽ MeasureMap trên gốc lẫn con.

**Số Spec từ MeasureMap trở đi đã dịch năm bậc so với bảng gốc.** MeasureMap là **0058**, SongPack là **0064**, thu âm là **0067**. Các dòng cũ trong `DECISIONS-LOG.md` giữ nguyên số lúc viết — đọc theo bảng này.

**Thu âm tụt xuống cuối bảng, và SongPack lên thay chỗ nó.** Đây là thay đổi thực chất của revision 2, không phải xếp lại cho gọn. Bốn dữ kiện cùng chỉ một hướng: Orchestrator đã chốt ở câu 2 rằng nếu spike kết luận chưa làm được thì **chờ**; chính Orchestrator ghi nhận nhạc đệm làm bằng phần mềm chuyên nghiệp cho chất lượng tốt hơn; tam giác codec vẫn chưa có lối thoát nào chắc; và nay tác giả bên thứ ba sẽ mang vào những bản nhạc đệm làm ở phòng thu. Thu âm trong app do đó là slice **yếu nhất và bấp bênh nhất** của cả nhóm — để nó ở giữa chuỗi thì nó chặn SongPack đứng sau; để nó ở cuối thì nó cắt được, hoãn được, hay bỏ hẳn được mà không thứ gì mắc kẹt.

Đổi lại, SongPack — thứ mà thông tin mới vừa biến thành hạng mục đòn bẩy lớn nhất trong cả roadmap — về đích sớm hơn khoảng hai slice.

Slice **1** chạy được song song với việc chờ v1 qua review: nó không chạm audio, không chạm mạng, không chạm tiền, nên nó không đụng gì tới bản đang nằm ở cửa store. Slice **2**–**7** cũng vậy — **bảy slice đầu không có một byte nào rời khỏi máy và không thêm một SDK nào**, và chúng cộng lại đã là một sản phẩm đứng được: bản nhạc tách đúng bài, Library một hàng một tệp với drill-in, nhảy tới ô nhịp, metronome đi theo bài, lật trang rảnh tay. Từ slice 8 trở đi thì không còn chạy song song được.

Mỗi slice từ 1 đến 5 đều tự đứng được trước mắt nhạc công, và đó là điều kiện của `DEVELOPMENT-MODEL.md`. Slice MeasureMap vốn có nguy cơ là một slice hình-dạng-tầng — soạn dữ liệu mà chưa dùng vào đâu — nên **nhảy tới ô nhịp** được kéo vào chính nó: nó biến MeasureMap thành thứ dùng được ngay, và nó kiểm chứng UX vẽ hộp trước khi có bất cứ thứ gì phụ thuộc vào chất lượng của MeasureMap.

---

## Hệ quả (Consequences)

- **Slices 1–4 (0052–0055) đã build.** ADR này đã `accepted` ở G2; revision 6 chỉ viết lại quyết định 11 và bảng Trình tự, revision 7 chỉ đổi số — không mở lại toàn bộ G2 trừ khi Orchestrator muốn. **Slice 5 (MeasureMap) là Spec 0058**, drafted `proposed` cùng ngày revision 7.
- **Bài học chung của revision 3, và nó lặp lại đúng bài học của ADR 0016 nhưng ở tầng ADR:** bốn chỗ trong ADR này nói về code đang ship bằng giọng **mô tả** trong khi thật ra chúng đang **đề xuất một luật mới**, và cả bốn sai theo cùng một hướng — *cho rằng hiện trạng đã sạch hơn thực tế*. Quyết định 2 tưởng một quy ước số trang trong khi có ba; quyết định 11 đếm ba hành vi phải đổi trong khi có bốn, và giả định import một file trong khi nó nhận nhiều file; quyết định 10 chỉ nhìn một chiều của phép kiểm version. Không chỗ nào đổi **hướng** của ADR — nhưng nếu không có đợt đọc repo của một Spec đứng trước, cả bốn sẽ được phát hiện lúc build, và ba trong bốn nằm trên đường mất dữ liệu.
- **Không được bắt đầu phần audio trước khi v1 qua review.** Nếu Apple hoặc Google từ chối, đường sửa là quay lại đúng bản build hiện tại; một nhánh đang dở dang với hai SDK audio mới làm việc đó đắt hơn hẳn. Slice 1–4 là ngoại lệ vì chúng không đổi gì mà store nhìn thấy.
- **ADR 0004 và ADR 0007 quyết định 6 phải sửa lời khi ADR này accepted.** 0004 thu hẹp phạm vi về nhánh WebView/MIDI; 0007 quyết định 6 ghi rằng điều kiện của nó đã thoả. Không ADR nào bị bác.
- **ADR 0017 quyết định 6 mất đề xuất `MeasureAnchor`** — `MeasureBox` thay chỗ nó, và thay tốt hơn vì trùng tên với bên kia.
- **Trigger của ADR 0014 kích hoạt** — nó liệt kê đúng tình huống này: *"Mở cổng H3 theo ADR 0008 — khi StageScore bắt đầu SmartMode / Transport / BackingTrack, nó bước vào đúng miền playback mà web đã ở trong đó nhiều năm, và đó là lúc từ vựng thực sự gặp nhau."* Bảng đối chiếu của 0014 nhận thêm sáu hàng ở mức trường (quyết định 6). Câu hỏi lớn hơn — hai công cụ soạn, hai PdfViewer — vẫn mở.
- **ADR 0017 mở lại được, và ADR này dựng sẵn thứ nó thiếu** — công cụ soạn trong app, cộng SongPack chính là "gói tải hình dạng StageScore" mà 0017 nói chưa có. **Nhưng đừng mở lại trong nhóm slice này** — 0017 mang theo mạng, thanh toán và entitlement, tức toàn bộ thứ mà nhóm này cố ý không chạm. Và nếu có ngày mở lại, phải nhìn thẳng một điều mới: Discover khi đó **cạnh tranh với chính những tác giả bên thứ ba** mà định dạng này mời vào.
- **MeasureMap là dữ liệu tốn công người nhất mà app này từng lưu, và điều đó đổi trọng số của mọi thứ chạm vào nó.** Một annotation vẽ lại mất mười giây; một MeasureMap vẽ lại mất một buổi. Nên nó phải nằm trong backup, phải sống sót qua Replace PDF khi số trang không đổi, và bất cứ đường nào có thể xoá nó đều phải hỏi lại. Đây cũng là lý do quyết định 2 bắt buộc đi trước: PageExtent đổi sau khi MeasureMap tồn tại là làm hỏng đúng thứ này.
- **Thư viện phình theo audio, nên sao lưu chọn lọc thôi là tuỳ chọn.** Một bản thu 4 phút là ~5,8 MB ở AAC 192 kbps nhưng ~42 MB ở WAV; 50 bản nhạc đệm là vài trăm MB. `LibraryBackup` hôm nay zip cả cây — slice sao lưu chọn lọc mà 0050 để lại phải đi cùng slice 8, không để sau.
- **Quyền microphone đổi hồ sơ ở cả hai repo.** `RECORD_AUDIO` vào manifest Android, `NSMicrophoneUsageDescription` vào `Info.plist` (hiện **không có**; ba chuỗi purpose khác đang nằm đó mà không có code Dart nào dùng — nên dọn cùng lượt). Audio **không rời máy**, nên câu "nothing collected about you or your music" vẫn đúng về *thu thập* — nhưng cả hai form của store hỏi riêng, và `/privacy` cùng `/support` bên repo web phải được đọc lại bằng mắt theo ADR 0012, không có CI nào nối hai bên.
- **Bản release Android nhận quyền thứ hai sau `INTERNET`.** Security Review S3 của Spec 0051 đã ghi rằng sau khi `INTERNET` vào manifest thì **không còn ai canh** — script `aapt dump permissions` trong `tool/` mà S3 đề xuất nay có lý do thứ hai để tồn tại, và allowlist của nó phải nhận `RECORD_AUDIO` một cách có chủ ý.
- **Security Review cần cho slice 11 và slice 14, không cần cho 1–7.** Slice 14 mở một đường thu dữ liệu mới. Slice 11 (SongPack) nặng hơn: pack là **ZIP do người lạ soạn**. **G2 câu 9 (không chữ ký số) làm nó nặng thêm một bậc** — phần kiểm tra khi đọc tệp là lớp phòng thủ **duy nhất**; xem mục "Hai ràng buộc" ở cuối.
- **Nhập pack không được dùng lại thẳng cơ chế giải nén của `LibraryBackup`.** `restoreBackup` hôm nay giải nén một tệp mà người dùng tự tạo từ chính máy mình — giả định hoàn toàn hợp lý cho việc nó làm, và hoàn toàn sai cho việc nhập pack. Bốn thứ phải có, và tất cả đều là loại lỗi cổ điển: chặn đường dẫn thoát ra ngoài thư mục đích (**zip-slip**), chặn tỉ lệ nén bất thường và tổng dung lượng sau giải nén, kiểm định dạng và kích thước **ảnh bìa** trước khi decode, và chịu được PDF hay audio hỏng mà không làm sập app. Đây là hạng mục đầu tiên của Security Review slice 11, không phải một ý hay để cân nhắc.
- **SongPack là kênh phân phối, và nay là kênh phân phối *thương mại*.** Trước bổ sung của Orchestrator, đây là hành vi của người dùng trên tệp của người dùng — cùng loại với chia sẻ PDF mà Spec 0029 đã ship. Nay có người bán pack lấy tiền, và không ai xác minh được họ có quyền với bản nhạc bên trong. Điều **giảm** rủi ro cho ta là app không phải nơi bán: giao dịch xảy ra trên nền tảng của người khác, app chỉ mở tệp. Điều **giữ** rủi ro là câu chữ — nếu màn hình nhập trông như app giới thiệu tác giả thay vì thuật lại lời tác giả, ranh giới ấy mờ đi. Xem quyết định 7b và 13.
- **Tác giả bên thứ ba giải đúng bài toán đã làm ADR 0017 phải `hold`, mà không tốn gì.** Lý do `hold` là danh mục bằng không và tốc độ sản xuất là đường tới hạn. Người ngoài sản xuất và tự bán thì danh mục lớn lên mà ta không sản xuất, không dựng cửa hàng, không nhận nghĩa vụ IAP — và app càng có giá khi càng nhiều pack tồn tại. Cái giá của nó là ta không kiểm soát chất lượng và không thu được đồng nào; đổi lại ta cũng không gánh chi phí nào. Điều này khiến **định dạng SongPack là hạng mục đòn bẩy lớn nhất trong cả nhóm slice**, và đó là căn cứ để nó vượt lên trước thu âm trong bảng Trình tự.
- **`VISION.md` đảo thứ tự trụ cột và bảng horizon không diễn đạt được hình dạng "H5 mà không H3".** Đó là sửa VISION, tức G0, không phải một dòng trong roadmap.
- **`CONTEXT.md` nhận sáu term mới ở G1 lúc build, không phải ở đây:** **PageExtent**, **MeasureMap**, **SystemBox** (đã chốt ở G2 câu 7, thay cho `RowBox`), **MeasureBox**, **BeatBox**, **SongPack**. Định nghĩa **SongPack** phải nói cả hai nguồn gốc ở quyết định 7b, không chỉ nguồn "nhạc công tự xuất" — **và phải ghi kèm rằng nhãn trên thanh điều hướng là `Packs`**, để lần sau có người đọc `library_screen.dart` thì họ biết hai cách viết là cố ý (G2 câu 5). **PdfDocument** đã có định nghĩa đúng và không cần sửa — chỉ code phải đuổi kịp nó. **SyncMap** cần định nghĩa **chặt lại**: hôm nay nó viết "sự khớp giữa thời gian âm nhạc và thời gian audio", mà quyết định 3 vừa cho phép một SyncMap **không có audio nào**.
- **`IMPROVEMENT-ROADMAP.md` Phase D đóng** với kết quả *go, có giới hạn*: mở H5, giữ H3/H4 đóng.
- **Nâng `flutter_soloud` 4.0.13 → 4.1.x là một thay đổi có breaking change**, không phải một dòng trong `pubspec.yaml`: 4.1.5 đổi `play` / `setPause` / `stop` sang ném lỗi thay vì nuốt, nên `MetronomeEngine` phải được đọc lại. Việc này thuộc slice 7 (spike), để nó hỏng ở chỗ rẻ.
- **Ước lượng quy mô, nói thẳng:** mười một slice, sáu trong đó tier L hoặc spike, mỗi tier L kéo theo một vòng gate. Với nhịp của repo này đó là **9–15 tháng** — dài hơn ước lượng của bản nháp đầu, vì quyết định 3 biến một slice SyncMap thành ba slice (MeasureMap, tính ra, gõ tay). Nó không nén lại được bằng cách chạy song song, vì chuỗi phụ thuộc là thật.

---

## Trả lời của Orchestrator ở G2 (2026-08-05)

**Cả tám câu, cộng câu chữ ký số mở thêm ở revision 2, đã chốt — không còn câu nào mở ở G2.** Ba câu cuối (5, 6, chữ ký số) chốt **theo khuyến nghị** cùng ngày, sau khi Spec 0052 accepted. Số Spec dưới đây theo bảng Trình tự **sau khi đổi thứ tự ở revision 2**.

1. **`VISION.md` sửa ngay.** Đã sửa cùng ngày: đảo thứ tự trụ cột (*Play along* lên trước *Smart Score*), viết lại bảng horizon để diễn đạt được "H5 mở, H3/H4 đóng", và nói rõ thu âm trong app là ghi nhanh để tham chiếu chứ không thay phòng thu. VISION dịch sang tiếng Việt trong cùng lượt theo ADR 0015, vì đây là lần đầu cần một quyết định từ nó kể từ khi 0015 accepted.

2. **Nếu spike kết luận thu âm chưa làm được thì chờ, không cắt.** Kèm ghi nhận của Orchestrator: nhạc đệm làm bằng phần mềm chuyên nghiệp cho chất lượng tốt hơn. Câu trả lời này là một trong bốn căn cứ đẩy thu âm xuống cuối bảng Trình tự — xem phần dưới bảng.

3. **Khoá tempo khi có BackingLane** (theo khuyến nghị). Muốn tempo khác thì soạn SyncMap khác; quyết định 3 làm việc đó rẻ. Chốt trước Spec 0059 như đã hẹn.

4. **SongPack chia sẻ chỉ qua share sheet của hệ điều hành.** Không danh sách trong app, không mã mời, không truyền trực tiếp giữa hai máy. Ranh giới này nay được củng cố bởi một lý do thứ hai mạnh hơn hẳn lý do ban đầu — xem quyết định 13.

5. **Màn hình thứ ba tên `Packs`** (theo khuyến nghị). Lý do quyết định không phải nghĩa của từ mà là chỗ nó đứng: hai tab hiện có, **Scores** và **Setlists**, đều là term trong `CONTEXT.md`, nên một tab thứ ba không phải term sẽ là ngoại lệ duy nhất và buộc đẻ thêm một từ chỉ sống trên thanh điều hướng. Lời hứa của màn hình, viết thành một câu để Spec 0062 bám vào: *"những gói bạn có — mua về hoặc tự dựng — và trong mỗi gói có gì."* **`Studio` bị bác** vì phần lớn nội dung màn hình rồi sẽ là gói người khác làm xong, mua về để chơi — gọi kệ sách của mình là "Studio" thì sai. Một ràng buộc phải viết ra ngay, xem dưới.

6. **Team dựng danh mục bằng công cụ trong app** (theo khuyến nghị; Orchestrator hỏi ngược *cách nào tốt nhất cho user*). Bổ sung về tác giả bên thứ ba biến khuyến nghị này từ *nên* thành **bắt buộc**: tác giả bên ngoài **không có lựa chọn nào khác**, họ dựng pack bằng chính app này, nên chất lượng công cụ soạn trong app đặt **trần** cho chất lượng của mọi pack từng tồn tại. Nếu team dựng danh mục bằng công cụ web thì team không bao giờ chạm phải những chỗ thô của công cụ trong app, và người duy nhất phát hiện ra chúng sẽ là một tác giả lạ đang cố làm ra thứ bán được — muộn nhất và đắt nhất có thể. **Không** cho phép bỏ phép dịch hai chiều ở quyết định 6: `useTappingSystem` bên web vẫn phục vụ web app, và MeasureMap soạn ở hai nơi vẫn phải gặp nhau không mất mát.

7. **`SystemBox`**, không phải `RowBox`. Đúng thuật ngữ khắc nhạc và khớp `systemIndex` bên repo web. Mọi chỗ trong ADR này còn viết `RowBox` đọc là `SystemBox`; sửa dứt điểm ở G1 của Spec **0058** (số MeasureMap sau revision 7).

8. **Cho phép MeasureMap chưa đầy đủ** (theo khuyến nghị). Map vài trang cũng dùng được; mọi thứ đọc MeasureMap phải chịu được lỗ hổng thay vì đòi bản đồ trọn vẹn.

9. **Không chữ ký số cho siêu dữ liệu tác giả** (theo khuyến nghị; câu này mở thêm ở revision 2). Không có đường phân phối khoá công khai, và lòng tin đã do nền tảng bán hàng gánh — hiển thị đúng như *lời khai của gói* là đủ (quyết định 7b). Mở lại **chỉ khi** có bằng chứng thật về việc mạo danh, không phải trước. Hai hệ quả phải viết ra, xem dưới.

---

## Hai ràng buộc suy ra từ ba câu vừa chốt

Cả hai không đổi lựa chọn nào; chúng chặn hai chỗ mà lựa chọn ấy sẽ bị "sửa cho gọn" về sau.

**Nhãn `Packs` là dạng ngắn của term `SongPack`, và cả hai đều đúng — đừng hợp nhất chúng.** Lập luận chọn `Packs` dựa vào việc **Scores** và **Setlists** là số nhiều của term `Score` và `Setlist`; nhưng term ở đây là **`SongPack`**, nên `Packs` **không** phải số nhiều của nó. Hai đường thoát đều tệ hơn: đổi term thành `Pack` làm mất chữ phân biệt nó với mọi thứ khác gọi là "gói" (và `SongPack` đã nằm trong format id, trong phạm vi Security Review, trong cả bảng Trình tự); còn dán nhãn `Song packs` lên thanh điều hướng thì dài và không ai nói thế. Nên luật là: **`SongPack` trong `CONTEXT.md`, trong code, trong tài liệu; `Packs` chỉ trên thanh điều hướng.** Đây đúng hình dạng mà ADR 0010 đã đặt cho thương hiệu — *Backing & Score* cho người đọc, `backingscore` trong identifier — nên nó là tiền lệ có sẵn, không phải ngoại lệ mới. Ai đọc `library_screen.dart` mà thấy hai cách viết thì đó là **cố ý**.

**Không chữ ký số nghĩa là phần kiểm tra khi đọc tệp thôi là lớp phòng thủ *đầu tiên* và thành lớp *duy nhất*.** Đây là chỗ dễ đọc ngược: "không chữ ký" nghe như bớt việc, nhưng nó **tăng** trọng số của mọi thứ đã ghi ở Hệ quả về nhập pack — zip-slip, tỉ lệ nén và tổng dung lượng sau giải nén, kiểm ảnh bìa trước khi decode, chịu được PDF/audio hỏng. Không có gì chứng minh được pack chưa bị sửa trên đường đi, nên **mọi byte trong pack là dữ liệu không tin được**, và Security Review của slice 11 phải đọc nó bằng giả định đó. Kèm một hệ quả cụ thể cho đường "cập nhật pack đã cài" (quyết định 8): app **không xác minh được** bản 1.1 đúng là của tác giả đã bán bản 1.0. Điều giữ rủi ro trong tầm là cập nhật vẫn là **lựa chọn có xem trước** của người dùng và vẫn giữ lại phần của họ — không phải một đường tự động. Spec 0061 không được biến nó thành đường tự động.
