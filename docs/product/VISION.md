# Tầm nhìn sản phẩm (Product Vision)

**Tên sản phẩm:** StageScore
**Nhà phát hành:** Backing & Score ([backingscore.com](https://backingscore.com)) *(cách viết: ADR 0010)*
**Bundle ID:** `com.backingscore.scoreapp` *(ADR 0009)*
**Status:** accepted (G0 — Human Orchestrator 2026-07-22); **sửa ở G0 lần hai ngày 2026-08-05** theo ADR 0019
**Cập nhật lần cuối:** 2026-08-05 — mở H5 (play-along trên PdfMode) mà không mở H3

> Bản này dịch sang tiếng Việt theo ADR 0015, đúng lúc một quyết định được lấy từ nó. Chi tiết của lần sửa nằm ở **ADR 0019**, tài liệu ấy đang `proposed` và còn đúng một chữ ký ở G2.

---

## Một câu (One-liner)

**StageScore** (của **Backing & Score**) là app bản nhạc đa nền tảng. Nó **đã đạt** UX biểu diễn PDF ngang tầm ScorePDF; việc đang làm là **play-along ngay trên PDF** — nhạc công tự dựng MeasureMap và SyncMap cho chính bản nhạc của mình, gắn BackingTrack, rồi đóng gói thành SongPack. **Smart Score** (MusicXML) và OMR để lại sau. Sản phẩm do một người điều phối và AI dựng theo Spec đã khoá.

---

## Dành cho ai (Who it is for)

- **Chính:** nhạc công biểu diễn từ bản nhạc PDF (tablet đặt trên giá)
- **Chính, mới từ 2026-08-05:** nhạc công muốn tập cùng nhạc đệm **trên chính bản nhạc của mình**, không phải trên danh mục của một hãng khác
- **Sau:** người học cần phát theo, wait-mode, nhạc đệm ban nhạc
- **Phụ:** giáo viên dựng setlist cho học trò

---

## Vấn đề (Problem)

1. Trình đọc PDF thông thường hỏng việc trên sân khấu: lật trang không đáng tin, setlist yếu, xử lý đoạn lặp và dấu quay lại vụng.
2. ScorePDF đặt chuẩn cho UX biểu diễn PDF, và **chuẩn đó đã đạt** (P0–P2 `done`).
3. Không trình đọc PDF nào cho nhạc công **tự gắn nhạc đệm và tự khớp thời gian** vào bản nhạc của chính họ. Các app dạng Tomplay làm được việc đó, nhưng chỉ trên danh mục do họ sản xuất — bản nhạc bạn đang tập thì không có trong đó.
4. Về dài hạn: các app dạng ScorePDF không sở hữu đường ảnh chụp → MusicXML → luyện tập có audio khớp.

---

## Trụ cột sản phẩm (Product pillars)

Thứ tự đổi ngày 2026-08-05: **Play along** vượt lên trước **Smart Score**.

| Trụ cột | Lời hứa | Trạng thái |
|---|---|---|
| **Performance PDF** | Lật trang bằng chạm/vuốt/pedal, layout, sắp lại trang, chú thích, setlist | **Xong** — parity ScorePDF P0–P2 |
| **Play along** | MeasureMap + SyncMap do nhạc công dựng, BackingTrack qua Transport nhiều lane, lật trang rảnh tay, SongPack | **Đang làm** — H5, ADR 0019 |
| **Smart Score** | MusicXML + Verovio, AutoPlay, WaitMode | Sau; H3/H4 **vẫn đóng** |
| **Capture path** | OMR + CorrectionSession | Sau; H6 **vẫn đóng** |
| **Multi-platform** | iOS, Android, Web — offline-first khi biểu diễn | Shell theo ADR 0005; iOS và Android trước |

---

## Không làm (Non-goals)

- Trình soạn nhạc đầy đủ cạnh tranh MuseScore desktop
- Mạng xã hội / bảng tin
- **Thay thế DAW hoặc phần mềm thu âm.** App gắn, khớp và trộn BackingTrack; nó không phải nơi *sản xuất* nhạc đệm. Phần thu âm trong app, nếu ship, là **bản ghi nhanh để tham khảo** — nhạc đệm chất lượng vẫn nên làm bằng phần mềm chuyên dụng rồi nhập vào (Orchestrator, 2026-08-05).
- **Dò tự động vạch nhịp hay dòng kẻ nhạc từ ảnh trang.** Đó là OMR, thuộc ADR 0006 và H6, và việc mở H5 **không** mở nó. MeasureMap được vẽ bằng tay, có hỗ trợ chép layout giữa các trang.
- OMR hoàn toàn tự động không cần người sửa
- Nhúng MuseScore làm bộ dựng hình trong app
- **Vẫn ngoài phạm vi:** Feature Spec cho SmartMode và OMR (chỉ có tài liệu kiến trúc — ADR 0008). BackingTrack **đã vào phạm vi** từ ADR 0019.

---

## Thành công (Success)

### Giai đoạn đầu — đã đạt

- Nhạc công chạy được một buổi diễn ngắn từ PDF với pedal, Setlist và PageOrder mà không phải vật lộn với giao diện.
- PdfMode phủ checklist parity (`docs/product/SCOREPDF-PARITY.md`) ở mức Orchestrator chấp nhận. v1.0.0 nộp store ngày 2026-08-04.

### Giai đoạn đang làm (H5)

Nhạc công lấy một cuốn tuyển tập PDF của chính mình và, không rời khỏi app: **tách** ra từng bài, **vẽ** MeasureMap cho bài đang tập, để **metronome đi theo** tempo và loại nhịp của bài, **lật trang rảnh tay**, **gắn** một BackingTrack rồi khớp nó, và **đóng gói** gửi cho học trò hoặc bạn diễn.

### Về sau

- Người học nhập được MusicXML, nghe MIDI, dùng WaitMode.
- Web và mobile dùng chung hành vi Transport của Smart Score.

---

## Chân trời năng lực (Capability horizons)

Không phải kế hoạch sprint. **H0–H2 xong; H5 mở ngày 2026-08-05; H3, H4 và H6 vẫn đóng.**

| Chân trời | Nội dung | Trạng thái |
|---|---|---|
| **H0** | Quy trình, ngôn ngữ, ADR đủ chặt để build | Xong |
| **H1** | ScorePDF **P0**: nhập, thư viện, layout, PageTurn | Xong |
| **H2** | ScorePDF **P1–P2**: pedal, cử chỉ, setlist, PageOrder, bookmark, nửa trang, chú thích, label, xuất, sao lưu, metronome, lọc | Xong |
| **H5** | MeasureMap, SyncMap, BackingTrack, Transport, SongPack | **Mở** (ADR 0019) |
| **H3** | Smart Score core (MusicXML, Verovio) | Đóng |
| **H4** | WaitMode + PracticePolicy | Đóng |
| **H6** | OMR + CorrectionSession | Đóng |
| **H7** | Phần đánh bóng / khác biệt còn lại | Chưa xét |

Việc mở H5 mà không mở H3 là một hình dạng mà bảng trên vốn không diễn đạt được, nên luật phân định nằm ở **ADR 0019 quyết định 1**:

> Một tính năng thuộc **H5** nếu nó chỉ cần biết **chỗ nào trên trang, ở giây thứ mấy**. Nó thuộc **H3/H4** nếu nó cần biết **nốt nào**.

Mã parity và theo dõi: [`SCOREPDF-PARITY.md`](./SCOREPDF-PARITY.md).

---

## Đối chiếu cạnh tranh (Competitive reference)

- **Chuẩn giai đoạn đầu (PDF):** [ScorePDF](https://enoiu.com/en/app/scorepdf/) — đã theo kịp
- **Chuẩn của H5:** các app dạng **Tomplay**. Khác biệt của StageScore không phải chất lượng nhạc đệm mà là **nhạc đệm gắn vào bản nhạc của chính bạn**, dựng bằng công cụ trong app, và chơi được **offline**.
- **Khác biệt về sau:** Smart Score, web client, quy trình AI có người gác cổng

---

## Câu hỏi sản phẩm còn mở (cần Human)

1. ~~Tên sản phẩm / nhà phát hành / bundle ID?~~ → **StageScore** của **Backing & Score**; `com.backingscore.scoreapp`. **Tên đã đăng ký** (R5, 2026-07-31); tiêu đề trên store **`StageScore — Sheet Music`**, tên khi cài **`StageScore`**.
2. ~~Ship PDF trước hay Smart trước?~~ → **PDF trước (ADR 0008)**, rồi **H5 chứ không phải H3 (ADR 0019)**.
3. Có buộc chạy offline hoàn toàn mọi lúc không? → Đường **chơi** một Score: **có**, và ADR 0019 không đổi điều đó.
4. OMR: API thương mại hay tự host? (sau parity)
5. Mô hình kiếm tiền trước khi phát hành công khai? → ADR 0018 (quảng cáo + một lần mua) đang `proposed`, nhắm bản **1.1**.
6. **Backing v1: chỉ stereo hay có stem?** Nay đã tới hạn trả lời. Khuyến nghị: **một tệp stereo** cho slice đầu; ADR 0007 đã mô hình hoá stem như phần mở rộng dưới cùng một SyncMap nên không đóng cửa nào.
7. ~~Khi có BackingTrack thì khoá tempo hay time-stretch?~~ → **Khoá tempo** (Orchestrator, 2026-08-05). Muốn tempo khác thì soạn một SyncMap khác — ADR 0019 quyết định 3 làm việc đó rẻ.
8. ~~Hàng parity nào chấp nhận `wont` cho v1?~~ → **fit height** (0041) và **max page DPI** (0031) giữ `wont` (R9, 2026-07-31).

---

## Gate G0

**Accepted** bởi Human Orchestrator (2026-07-22), cùng ADR 0005 (Flutter) và Spec 0001 (spike chú thích PDF).

**Sửa ở G0 lần hai (2026-08-05):** mở H5 mà không mở H3; thứ tự trụ cột đảo lại; thu âm và MeasureMap tự động nhận thêm ranh giới ở mục Không làm. Lý lẽ và hệ quả nằm ở **ADR 0019**.
