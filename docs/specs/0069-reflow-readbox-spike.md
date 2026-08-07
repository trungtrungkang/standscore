# 0069 — ReflowMode / ReadBox (spike)

- **Status:** accepted
- **Type:** spike
- **Horizon:** H5 (chỉ cần *chỗ nào trên trang*; không cần *nốt nào* — ADR 0019 quyết định 1)
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0019, 0014, 0015, 0016, 0005, 0006, 0008
- **Depends on Specs:** **0058** (`done` — MeasureMap / SystemBox), 0059, 0061
- **Tier:** **M**
- **Security Review:** không cần
- **Ngoài bảng Trình tự ADR 0019** — spike này lấy số `0069` để không buộc ADR 0019
  (đã `accepted`, đã 9 revision) phải đánh số lại dải `0062`–`0068` lần thứ tư.

> Orchestrator chốt ngày 2026-08-08: term là **`ReflowMode`**, khái niệm vùng
> hiển thị là **`ReadBox`** bốn tầng, và **spike chạy trước** mọi cam kết.

---

## Vấn đề (Problem)

Tomplay hiển thị **một dải nhạc lớn**, playhead chạy theo nhạc, và phần đã chơi
được thay bằng phần sắp chơi — không bao giờ lật trang. StageScore muốn cảm giác
đó, nhưng **không thể sao chép cách họ làm**: Tomplay sở hữu bản khắc gốc
(100.000+ bài, 26 nhạc cụ, 8 mức độ) nên vẽ vector và **xếp lại layout** theo màn
hình. Ta cầm PDF của nhạc công, không chia lại được số ô trên một dòng.

Thứ ta **làm được** là cắt từng system ra khỏi trang và phóng to — đúng thứ
[forScore Reflow](https://forscore.co/kb/reflow/) đã ship nhiều năm trên PDF của
người dùng, tối đa `3×` trang gốc. Khác biệt của StageScore là **forScore phải dò
vùng từ ảnh trang và cần một trình sửa tay, còn ta đã có `SystemBox` do nhạc công
vẽ, kèm sẵn ô nhịp, phách, tempo và form**. Gọi tên thứ này là *"Reflow có đồng
hồ"*: máy nhắc chữ biết bản nhạc.

Hai ẩn số chặn mọi quyết định tiếp theo **không đọc code ra được** — phải nhìn
bằng mắt trên PDF thật.

---

## Câu hỏi (Question) — spike trả lời đúng hai câu

1. **Một dải cắt từ PDF thật có đọc được không?** Bản scan lệch trang, mực không
   đều, `SystemBox` vẽ tay không đồng đều chiều cao. Phóng to có làm lộ ra thứ
   không chấp nhận được trên sân khấu không?
2. **`ReadBox` mặc định tính ra có bắt đủ thứ nhạc công cần nhìn không** — sắc
   thái, pedal, lời hát, hợp âm, dòng kẻ phụ, khoá nhạc và hoá biểu đầu dòng —
   và **độ phóng đại thật là bao nhiêu** sau khi đã trả giá cho phần đệm đó?

## Chỉ số thành công (Success metric)

- Trên ít nhất **hai** bài thật đã map (một bản khắc sạch, một bản scan), ở
  `contextFraction = 1.0`: **không** dải nào cụt mất thông tin nhạc công cần.
- Độ phóng đại ngang đo được (`1 / ReadBox.width`) ghi lại thành số, so với trần
  `3×` của forScore.
- **Số khuông trong một system quyết định trần lợi ích**, nên ghi kèm: piano hai
  tay có 4–6 system một trang thì phóng to thật, còn tổng phổ orchestra thường
  **một** system chiếm cả trang → `1 / width ≈ 1.0`, ReflowMode không cho thêm
  gì. Đây là ranh giới của tính năng, không phải lỗi hình học.

## Hộp thời gian (Time box)

Một lượt build + một lượt Orchestrator xem trên máy thật. Hai vòng sửa là trần
(`ai-workflow.mdc` § ngắt mạch), sau đó dừng và báo cáo.

---

## Trong phạm vi (In scope)

### A. `ReadBox` — hàm thuần, không mở một tệp PDF nào

`lib/reflow/read_box.dart`. `SystemBox` trả lời *playhead chạy ở đâu*; `ReadBox`
trả lời *nhạc công cần nhìn thấy gì*. **`SystemBox` không đổi một dòng** — nới nó
ra sẽ kéo theo chiều cao playhead (0059), cử chỉ resize (0058 rev. 1), bảng field
round-trip web (ADR 0014) và mọi MeasureMap đang nằm trên máy nhạc công.

- **Dọc:** khe giữa hai `SystemBox` kề nhau *cùng trang* là vùng vô chủ — chia
  đôi. Dòng trên cùng / dưới cùng của trang nới bằng khe trung bình của trang đó;
  trang chỉ có một dòng thì dùng `0.5 ×` chiều cao dòng. Clamp vào `[0, 1]`.
- **Ngang:** `min(left)` và `max(right)` của **mọi** `SystemBox` trên trang. Mọi
  dòng trên một trang in chung một lề, nên phép này tự sửa lỗi — dòng vẽ từ vạch
  nhịp đầu vẫn lấy lại được khoá nhạc và hoá biểu từ dòng nào vẽ rộng hơn.
- **Thứ tự đọc theo `y`, không theo `systemIndex`** — thứ tự vẽ không phải thứ tự
  đọc; ai vẽ sót một dòng rồi vẽ bù sẽ có `systemIndex` không tăng xuôi trang.
- **`contextFraction`** `0.0`–`1.0`: `0` là đúng `SystemBox`, `1` là chia đôi khe.
  Bất biến khoá bằng test: ở `1.0` hai `ReadBox` kề nhau **chạm nhau, không chồng
  nhau** — đó là thứ khiến một cái slider giao cho nhạc công là an toàn.

### B. Màn hình spike — dùng rồi bỏ

`lib/ui/reflow_spike_screen.dart`, vào từ ScoreMenu (nhóm Marks, cạnh
*Measure map…*), tắt khi MeasureMap rỗng.

- Cắt và vẽ **các `ReadBox` của một trang** ở chiều rộng màn hình, xếp dọc; nút
  lùi / tiến trang. Một trang một lượt để bộ nhớ có trần và không cần cache.
- Slider `contextFraction`, vẽ lại khi thả tay (`onChangeEnd`), không mỗi khung.
- Công tắc **Show SystemBox** — vẽ khung `SystemBox` chồng lên dải, để đọc được
  bằng mắt phần đệm đã thêm bao nhiêu và có đủ không.
- **AppBar và bảng điều khiển luôn hiện.** Bản thử chạm-để-ẩn (2026-08-08) bị
  bỏ ngay trong lượt xem: chrome mất đi làm dải nhạc dịch lên/xuống, và với
  người đang đọc nhạc thì một cú chạm nhầm làm nhảy trang giấy tệ hơn hẳn phần
  chiều cao nó đòi lại được.
- Mỗi dải ghi **`×N.NN`** (`1 / width`); chân màn hình ghi số dòng và số dải vừa
  một màn hình — đo theo màn hình **đã ẩn chrome**, vì đó mới là điều kiện đọc
  thật (`fit full-screen`).

---

## Ngoài phạm vi (Out of scope)

- Playhead, playback, đồng hồ, lật dải theo SyncMap — **toàn bộ phần "có đồng
  hồ"**. Spike này chỉ trả lời câu hỏi *hình ảnh*.
- Override `ReadBox` từng dòng (tầng 3) và lưu xuống đĩa. Không trường mới,
  không `formatVersion`, không di trú.
- Tự dò theo mực trên trang raster (tầng 4) — **và nó cần Orchestrator phán một
  ranh giới trước**: đo chỗ mực dừng không nhận dạng gì cả (cùng loại phép tính
  với auto-crop lề trắng), nhưng ADR 0019 / log 0052 có câu *"dò ranh giới bài từ
  ảnh trang là OMR"*, và tôi không tự suy rộng ranh giới do một ADR đã accepted
  vẽ ra. Tầng 1 đã giải gần hết, nên đây là thứ để dành.
- Số dải trên màn hình, cú lộn dòng, xếp nối ngang, annotation trong dải.
- Dependency mới, quyền mới, `formatVersion`.

---

## Thuật ngữ miền (Domain terms)

| Term | Ghi chú |
|---|---|
| **`ReflowMode`** *(đề xuất G1)* | Anh em với `PdfMode` / `SmartMode`. Bỏ chữ "có đồng hồ" khỏi tên vì **trong app không tồn tại reflow không đồng hồ** — chữ ấy phân biệt ta với forScore, nên nó thuộc câu mô tả chứ không thuộc định danh. Trùng tên tính năng forScore là **có ý thức**: `reflow` là từ chung của ngành sắp chữ. |
| **`ReadBox`** *(đề xuất G1)* | Vùng nhạc công cần nhìn cho một dòng. Anh em `SystemBox` / `MeasureBox` / `BeatBox`. **Không có** đối ứng bên web — ADR 0014 ghi là term riêng của StageScore. |
| **`SystemBox`** | Không đổi nghĩa: bám *system* — **mọi khuông nhạc (staff) vang lên cùng lúc**, nên piano hai tay là **một** hộp gồm 2 khuông, tổng phổ là một hộp gồm nhiều khuông. Playhead chạy trong nó. Bản dịch cũ "dòng nhạc" đã bỏ (2026-08-08): tiếng Việt đọc nó thành *staff* được, mà vẽ một hộp mỗi khuông thì `measureNumber` đếm gấp đôi và `ReadBox` coi khe giữa hai tay là khe vô chủ rồi cắt đôi grand staff. Code không phân biệt được hai trường hợp, nên chỉ chữ nghĩa chặn được. |
| **`MeasureBox`** / **`BeatBox`** / **SyncMap** / **FormMap** | Đã khóa 0058–0061. |

`CONTEXT.md` **chưa** nhận hai term mới trong spike này — spike có thể bị vứt, và
`CONTEXT.md` không phải nơi giữ thứ chưa chắc tồn tại. Ghi vào lúc Spec thật.

---

## Tiêu chí chấp nhận (Acceptance criteria)

- [x] `readBoxesForPage` là hàm thuần: không `Directory`, không `PdfDocument`,
      không `BuildContext`; test chạy **không có một PDF nào**
- [x] `contextFraction = 0` → `ReadBox` trùng `SystemBox` theo chiều dọc
- [x] `contextFraction = 1` → hai `ReadBox` kề nhau chạm nhau và **không** chồng
- [x] Thứ tự trả về theo `y` kể cả khi `systemIndex` không tăng xuôi trang
- [x] Dòng hẹp trên trang vẫn nhận mép trái của dòng rộng nhất (lấy lại khoá nhạc)
- [x] `ReadBox` không bao giờ ra ngoài `[0, 1]`
- [x] Trang không có `SystemBox` nào → danh sách rỗng, không ném
- [x] Vào được từ ScoreMenu; tắt khi MeasureMap rỗng
- [x] `flutter analyze` sạch; suite xanh; không dependency / quyền mới;
      `formatVersion` không đổi; không byte nào rời máy

---

## Kế hoạch kiểm thử (Test plan)

- **Automated:** `test/reflow_read_box_test.dart` — toàn bộ tiêu chí hình học ở
  trên, trên `MeasureMapStore` dựng bằng tay.
- **Manual (G4, Orchestrator):** mở màn hình spike trên **hai** bài đã map — một
  bản khắc sạch, một bản scan. Kéo `contextFraction` từ `0` tới `1`, bật *Show
  SystemBox*, đọc số `×N.NN`. Trả lời hai Câu hỏi ở trên.

---

## Ghi chú (Notes)

Chuỗi trong màn hình spike để **tiếng Anh trần**, không qua `AppLocalizations` —
ngoại lệ có ý thức và chỉ áp cho màn hình dùng-rồi-bỏ này; dịch 9 locale cho thứ
có thể bị vứt là lãng phí. Nhãn ScoreMenu thì đi qua ARB như mọi mục khác, và nó
giống hệt nhau ở cả 9 tệp vì nội dung là một domain term.

**Đầu ra (Outputs):** một Spec `feature` cho `ReflowMode` + revision cho ADR 0019
(chèn slice vào bảng Trình tự, và quyết định số phận Spec **0060** đang `hold`) —
hoặc vứt spike, nếu chất lượng ảnh trả lời là không.

---

## Kết quả G4 (2026-08-08)

Orchestrator xem trên thiết bị, cả bản khắc sạch **và** bản scan: dải cắt ra
**đọc được**, `ReadBox` mặc định bắt đủ thứ cần nhìn. Spike trả lời **có** cho cả
hai Câu hỏi → đi tiếp sang Spec `feature` cho `ReflowMode`.

Ba điều học được trên đường, đều thuộc về Spec thật chứ không phải spike:

1. **`SystemBox` vẽ tay không chuẩn là nguồn lỗi thật**, không phải hình học
   `ReadBox`. Lần cụt đầu tiên tưởng là chrome che mất, hoá ra là hộp vẽ lệch —
   nên `ReflowMode` cần một đường sửa, hoặc override `ReadBox` từng dòng (tầng
   3), hoặc siết lại lúc vẽ MeasureMap.
2. **Chrome không được tự ẩn theo cú chạm.** Bản thử chạm-để-ẩn bị bỏ ngay: dải
   nhạc dịch lên xuống khi chrome mất, và với người đang đọc nhạc thì một cú
   chạm nhầm làm nhảy giấy tệ hơn phần chiều cao nó đòi lại được.
3. **Lợi ích tỉ lệ nghịch với số khuông trong một system** — piano 4–6 system một
   trang thì phóng to thật, tổng phổ orchestra thường một system chiếm cả trang
   nên `1 / width ≈ 1.0`. Đây là ranh giới tự nhiên của tính năng.

**Chưa đo:** số `×N.NN` cụ thể chưa được ghi lại thành con số để so với trần `3×`
của forScore. Spec thật cần nó trước khi chốt hình dạng "một dải chiếm trọn màn
hình".
