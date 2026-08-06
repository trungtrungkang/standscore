# Hai bounded context, một bảng đối chiếu, không đổi tên gì

StageScore và Backing & Score web **giữ nguyên từ vựng của riêng mình**. Hai bộ từ vựng khác nhau vì hai sản phẩm được lấy cảm hứng từ hai nguồn khác nhau, không phải vì chúng trôi dạt. Ở biên giới giữa hai bên, ta duy trì **một bảng đối chiếu** để agent không bịa ra cái tên thứ ba.

**Status:** accepted
**Decided by:** Human Orchestrator (2026-07-28)
**Relates to:** ADR 0012 (code nằm ở đâu), ADR 0013 (SDO với tier triage), ADR 0008 (parity trước, cổng H3), `CONTEXT.md`

## Bối cảnh (Context)

### Lineage — mảnh thông tin bị thiếu

**Backing & Score web ra đời trước, lấy cảm hứng từ Tomplay và FollowKeys.** Đó là dòng sản phẩm luyện tập tương tác: người học đi theo bản nhạc, nền nhạc chạy cùng, hệ thống chấm xem chơi đúng hay sai.

**StageScore ra đời sau, lấy cảm hứng từ ScorePDF.** Đó là dòng khác hẳn: người biểu diễn mang bản nhạc PDF lên sân khấu, cần lật trang không rời tay khỏi đàn, cần xếp lại thứ tự trang để xử lý đoạn lặp.

Hai dòng đó có hai bộ từ vựng đã được thiết lập sẵn trong thế giới của chúng, và mỗi sản phẩm thừa hưởng bộ của mình. Đây là điều mà bản nháp trước của ADR này không biết, nên đã đọc sự khác biệt thành tai nạn lịch sử. **Nó không phải tai nạn — nó là thông tin.** `PageOrder` mang theo bài toán của người biểu diễn với bản nhạc giấy; `NavigationSequence` mang theo bài toán của nền tảng luyện tập điều hướng qua các đoạn. Hợp nhất chúng thành một từ sẽ xoá mất chính thông tin đó.

Trong ngôn ngữ của DDD: đây là **hai bounded context**, và hai context có hai ubiquitous language riêng là hình mẫu đúng, không phải lỗi cần sửa. Cách xử lý đúng không phải hợp nhất từ vựng, mà là giữ mỗi context thuần khiết và dịch một cách tường minh ở biên.

### Cuộc rà soát vẫn có giá trị — nhưng như bằng chứng, không phải như bản án

Cả 30 thuật ngữ trong `CONTEXT.md` đã được tra trong `apps/web/src`, `docs/specs/` và schema Turso. **Mười từ xuất hiện bên đó, hai mươi từ không** — và con số thứ hai mới là con số đáng chú ý: phần lớn miền của StageScore thực sự là của riêng nó.

Phát hiện lớn nhất không phải từ vựng. `apps/web/src/components/pdf/` là **4.463 dòng** — riêng `PdfViewer.tsx` 2.229 dòng — chứa `performanceMode`, `toggleBookmark`, `pedalEnabled` với `pedalNextKeys` / `pedalPrevKeys`, `navMap` cùng `jumpToNextSequenceIndex`, và `PdfDrawingLayer`. Một phần đáng kể bộ ScorePDF parity mà repo này dựng qua Spec 0001–0041 đã tồn tại bên web, viết độc lập. Lineage giải thích được vì sao *từ vựng* khác nhau; nó không giải thích được vì sao *tính năng* trùng nhau. Đó vẫn là câu hỏi mở.

## Các lựa chọn đã cân nhắc (Considered options)

- **Hợp nhất glossary, đổi tên cho khớp** (bản nháp trước của ADR này) — bị bác. Không có compiler nào bắt hai bên phải đồng thuận: hai codebase không dùng chung một dòng code, nên việc đổi tên chỉ mua sự thống nhất thẩm mỹ bằng công sức thật, và trả giá bằng việc xoá thông tin mà lineage mã hoá. Đây là tối ưu hoá đầu cơ.
- **Hai context, không có bảng đối chiếu** — bị bác. Một agent làm việc bắc ngang hai bên mà không có bảng tra sẽ không dùng lại từ của bên nào cả; nó sẽ nghĩ ra cái tên thứ ba, và khi đó ta có ba từ vựng thay vì hai.
- **Hai context, một bảng đối chiếu ở biên** — được chọn. Không tốn gì, không đổi tên gì, và chặn đúng cái hại duy nhất mà việc để nguyên có thể gây ra.

## Quyết định (Decision)

1. **`CONTEXT.md` của StageScore không bị sửa.** `Label` vẫn là `Label`. `Score`, `PageOrder`, `Stamp`, `SyncMap`, `Transport`, `BackingTrack` giữ nguyên nghĩa hiện tại.
2. **Không đổi tên ở đâu cả.** Bản nháp trước đề xuất `MatchScore`, `ReadingPosition` và `Tag`; cả ba bị rút. Những từ trùng mà nó nêu đều được ngữ cảnh phân định rõ trong context của chúng — `score: number` là một field trên `AssessmentMeasureResult`, `last_read_chapter_id` là một cột trong bảng sách — và không có tình huống nào chúng gặp nhau.
3. **`CONTEXT.md` vẫn phẳng và vẫn chỉ của StageScore.** Web app có glossary riêng khi nào nó cần, ở file riêng, không phải một mục trong file này.
4. **Duy trì bảng đối chiếu dưới đây** như tài liệu tra cứu cho agent làm việc bắc ngang hai bên. Nó **không phải** lệnh đổi tên.

| Khái niệm | StageScore | Backing & Score web |
|---|---|---|
| Một bản nhạc | `Score` | `projects` với `projectType='sheet_music'` |
| Nhạc đệm để chơi cùng | `BackingTrack` | `projects` với `projectType='backing_track'` |
| Khớp thời gian nhạc với thời gian audio | `SyncMap` | `timemap` (trong `projects.payload`) |
| Engine điều phối thời gian | `Transport` | `AudioManager` |
| Xử lý đoạn lặp / nhảy trang | `PageOrder` — chuỗi **trang**, kể cả trang lặp và trang trắng | `NavigationSequence` — `string[]` chứa **id của Bookmark** |
| Vết vẽ tay | nét ink | `DrawingStroke` với tool `pen` / `highlighter` |
| Ký hiệu đặt lên trang | `Stamp` | *không có* |
| Bó bookmark + chuỗi + chú thích, công bố được | *không có* | `SheetOverlay` |

Hai dòng cuối là chênh lệch năng lực, không phải chênh lệch tên gọi, và đáng để ý: web **chia sẻ được** bộ chú thích, StageScore thì không.

### Sáu hàng ở mức trường, thêm bởi ADR 0019 (accepted 2026-08-05)

Trigger *"Mở cổng H3 … khi StageScore bắt đầu Transport / BackingTrack"* đã kích hoạt: ADR 0019 mở H5 (BackingTrack + SyncMap trên PdfMode) và giữ H3/H4 đóng. Sáu hàng dưới đây khác các hàng trên ở một điểm quan trọng — **chúng là mức trường, không phải mức khái niệm**, và hai bên **trùng đúng tên đúng nghĩa** thay vì cần dịch:

| Khái niệm | StageScore | Backing & Score web |
|---|---|---|
| Một ô nhịp được định vị trên trang | `MeasureBox` — trang, số ô nhịp, chỉ số dòng, toạ độ `0..1` | `MeasureBox` — `pageIndex`, `measureNumber`, `systemIndex`, toạ độ `0..1` |
| Một phách trong một ô nhịp | `BeatBox` / `beatSplits`: **N mốc nội tại** (Spec 0058 rev. 2) | `beatSplits`: **N−1 biên** giữa phách |
| Một dòng nhạc trên trang | `SystemBox` | suy ra từ `systemIndex` trên `MeasureBox` |
| Thời điểm của một ô nhịp / một phách | thời điểm trong `SyncMap` | `timeMs`, `beatTimestamps` trên `TimemapEntry` |
| Chỉ số ô trên timeline phát | `SyncMapEntry.measure` = **latent** (sau bung FormMap); `physicalMeasure` runtime cho playhead | `TimemapEntry.measure` = latent |
| Ánh xạ latent → physical (thưa) | derive lúc bung FormMap — không ghi SyncMap ra đĩa | `notationData.measureMap` (sparse latent→physical); **không** cùng nghĩa MeasureMap hình học StageScore |
| Cấu trúc lặp / volta / nhảy | `FormMap` (overlay PDF; Spec 0061) | parse MusicXML → `unrollMeasures` (không soạn form trên MeasureBox PDF) |
| Tempo tại một phách | tempo trên `MeasureBox` | `tempoAtBeat` |
| Ô nhịp lấy đà | ô nhịp lấy đà | `startsAtBeat` |

**Trùng tên ở đây không phải vi phạm quyết định 2** — `MeasureBox` vẫn cùng khái niệm hai bên. **Ngoại lệ hình dạng field đã biết (2026-08-07):** cùng tên `beatSplits`, nhưng StageScore lưu N mốc vị trí phách còn web lưu N−1 biên; phép dịch centres ↔ midpoints (và migrate map cũ) nằm ở Spec 0058 rev. 2. Không bịa tên thứ ba; không ép web đổi store. Đó vẫn là lý do ADR 0019 quyết định 3e **rút** `MeasureAnchor` và dùng `MeasureBox`.

**Cái giá thì đi kèm, và nó cộng vào câu hỏi sản phẩm mà ADR này để mở.** ADR 0019 quyết định 6 đặt công cụ soạn MeasureMap **trong app**, tức nhân đôi `useTappingSystem` và `SyncWorkspaceClient` bên web — thêm một lớp trùng lặp nữa bên cạnh 4.463 dòng `PdfViewer`. Điều kiện để chấp nhận được, và nó kiểm được bằng một test round-trip trên sáu hàng trên: **trùng giao diện thì được, trùng dữ liệu thì không.** Nếu hai công cụ đẻ ra hai định dạng không dịch được cho nhau thì thứ bị nhân đôi không còn là một màn hình mà là cả kho nội dung. Câu hỏi lớn hơn — hai công cụ soạn, hai `PdfViewer` — **vẫn mở**.

## Xem lại khi nào (Triggers)

"Nếu sau này có phát sinh gì thì hẵng tính tiếp" — đây là danh sách "phát sinh" được viết ra để nó không phụ thuộc vào việc ai đó tình cờ nhớ:

- **Có code dùng chung** giữa hai sản phẩm — một package mà cả hai import. Khi đó compiler bắt đầu quan tâm, và đây là trigger mạnh nhất.
- **StageScore có đồng bộ hoặc chia sẻ**, vì nó sẽ cần đúng mô hình `SheetOverlay` mà web đã có.
- **Một giao diện hiển thị dữ liệu của cả hai** sản phẩm cùng lúc.
- **Mở cổng H3** theo ADR 0008 — khi StageScore bắt đầu SmartMode / Transport / BackingTrack, nó bước vào đúng miền playback mà web đã ở trong đó nhiều năm, và đó là lúc từ vựng thực sự gặp nhau.

## Hệ quả (Consequences)

- Gate G1 vẫn chỉ coi `CONTEXT.md` của StageScore là phạm vi của nó. ADR 0013 nói G1 có hiệu lực toàn repo; điều đó vẫn đúng, nhưng "toàn repo" nghĩa là **mỗi context một glossary**, không phải một glossary cho tất cả.
- Bảng đối chiếu ở trên là ảnh chụp `apps/web` tại `44df1b7f`. Nó sẽ cũ đi. Nó có ích cho việc tra cứu và không nên được tin như một hợp đồng.
- Việc gộp repo theo ADR 0012 **không bị chặn** bởi bất cứ điều gì ở đây. Một repo chứa hai bounded context là bình thường; đó là điều mà thư mục `apps/` vốn dĩ dùng để làm.
- 4.463 dòng trùng lặp về tính năng vẫn là câu hỏi sản phẩm chưa trả lời, và không glossary nào trả lời được nó.
- Lineage giờ đã được ghi lại trong repo. Đó là mảnh thiếu khiến bản nháp trước đọc sai vấn đề, và là thứ đáng giá nhất trong ADR này.
