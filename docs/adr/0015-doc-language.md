# Ngôn ngữ tài liệu đi theo người đọc, không theo thư mục

Tài liệu tồn tại để **con người quyết định** thì viết **tiếng Việt**. Tài liệu tồn tại để **agent hoặc máy thực thi** thì viết **tiếng Anh**. Thuật ngữ miền và identifier **không bao giờ được dịch**, ở cả hai thứ tiếng. Và không bao giờ có hai bản ngôn ngữ cho cùng một tài liệu.

**Status:** accepted
**Decided by:** Human Orchestrator (2026-07-28)
**Relates to:** ADR 0013 (SDO với tier triage — nguồn của lý lẽ về gate), ADR 0014 (hai bounded context), và trong repo web là `docs/README.md`

## Bối cảnh (Context)

Repo này viết toàn bộ bằng tiếng Anh. Orchestrator đọc tiếng Việt tốt hơn. Câu hỏi đặt ra là chuyển sang tiếng Việt sẽ mất gì.

**Repo web đã trả lời một phần câu hỏi này rồi.** `docs/README.md` bên đó ghi thành chính sách: `product/` là **vi-first**, `engineering/` là **en**. Và trên thực tế nó đi xa hơn chính sách — bốn spec (`interactive_playback_spec.md`, `audio_engine_spec.md`, `core_library_spec.md`, `sheet_music_reader_spec.md`) đã là tiếng Việt, dù spec nằm gần code hơn là gần sản phẩm.

Quan trọng hơn: **những spec đó đã tìm ra mẫu viết đúng.** `interactive_playback_spec.md` dùng văn xuôi tiếng Việt, heading song ngữ (`## 3. Acceptance Criteria (Tiêu chí Chấp nhận)`), giữ nguyên tiếng Anh mọi thuật ngữ kỹ thuật — `Tempo`, `Loop A-B`, `Count-in`, `Metronome`, `Stepper`, `PlayShell.tsx`, `FluidSynth` — và đặt mọi giá trị kiểm thử vào backtick (`5%`, từ `20%` đến `200%`) nên phần đo đếm được không phụ thuộc ngôn ngữ. Đây không phải vấn đề mới cần giải, mà là mẫu sẵn có cần ghi thành luật.

**Lý lẽ quyết định nằm ở gate.** ADR 0013 vừa dựng toàn bộ mô hình lên trên G0–G4, và ba trong năm gate đó là hành vi của con người: G2 accept một ADR, G3 accept một Spec, G4 verify theo Spec. Nếu Orchestrator không hấp thụ trọn vẹn tài liệu thì **gate biến thành hình thức**, và cùng với nó là toàn bộ kết cấu chịu lực của mô hình. Một ADR bị đọc lướt còn tệ hơn một ADR đọc chậm, bởi ý nghĩa duy nhất của dòng `Status: accepted / Decided by: Human Orchestrator` là *đã có một con người thực sự quyết*.

Thất bại đó không phải giả thuyết, và nó đã tự chứng minh trong cùng buổi làm việc. ADR 0014 được soạn bằng tiếng Anh và nằm ở trạng thái `proposed`, chờ G1 cùng G2 từ một người đọc tiếng Anh chậm hơn. Nó được dịch sang tiếng Việt trước khi ADR này được viết — và ngay sau khi đọc được bản dịch, Orchestrator bác gần hết nội dung của nó, vì biết một điều mà bản nháp không biết: hai sản phẩm có hai nguồn cảm hứng khác nhau. **Một ADR sai đã suýt được accept vì nó viết bằng thứ tiếng người quyết đọc chậm.** Đó chính là lý lẽ của ADR này, không cần thêm ví dụ nào khác.

**Cái giá thật, và nó tránh được.** Nhân bản tài liệu là chi phí duy nhất thực sự đắt: hai bản của một sự thật thì sẽ lệch. Repo web đã có một cặp như vậy — `market-and-segments.md` (240 dòng) và `market-and-segments-vi.md` (212 dòng), cùng `last_verified`, cùng 13 heading, lệch 28 dòng. Và chính `docs/README.md` bên đó đặt luật *"One topic = one canonical file"*, mà cặp file ấy đang vi phạm. Bài học: chuyển ngôn ngữ thì được, nhân đôi thì không.

Chi phí còn lại nhỏ hơn nhiều so với lời truyền miệng. Agent đọc tiếng Việt bình thường; phần đắt là mọi thứ agent phải tham chiếu chéo — docs thư viện, error message, quy ước framework, và bản thân code — đều tiếng Anh, nên một tài liệu tiếng Việt *lập luận về* hành vi framework tiếng Anh có thêm một bước dịch để sai lệch tinh vi lẩn vào. Thấp, nhưng thật, và nó là lý do phần "máy thực thi" ở lại tiếng Anh.

## Các lựa chọn đã cân nhắc (Considered options)

- **Giữ toàn bộ tiếng Anh** — bị bác. Nó tối ưu cho agent, vốn không phải bên gặp khó, và trả giá đúng ở chỗ đắt nhất: chất lượng quyết định của con người tại gate.
- **Chuyển toàn bộ sang tiếng Việt** — bị bác. `AGENTS.md`, `repo-map`, comment trong code và commit message tồn tại để định hướng thực thi, nằm sát code tiếng Anh, và không ai *quyết định* điều gì từ chúng.
- **Song ngữ mọi tài liệu** — bị bác dứt khoát. Đây là phương án duy nhất sinh ra nợ bảo trì vĩnh viễn, và cặp `market-and-segments` đã cho thấy nó bắt đầu lệch nhanh đến mức nào.
- **Chia theo người đọc** — được chọn. Nó mở rộng chính sách `vi-first` / `en` mà repo web đã có, nhưng thay tiêu chí *thư mục* bằng tiêu chí *ai đọc để làm gì*.

## Quyết định (Decision)

| Thể loại tài liệu | Ngôn ngữ | Vì sao |
|---|---|---|
| ADR | **Tiếng Việt** | Con người accept ở G2 |
| Feature Spec | **Tiếng Việt** | Con người accept ở G3, verify ở G4 |
| VISION, RELEASE-CHECKLIST, DECISIONS-LOG, `product/` | **Tiếng Việt** | Đọc để quyết định và để cắt scope |
| `CONTEXT.md` | **Tên thuật ngữ tiếng Anh, định nghĩa tiếng Việt** | Orchestrator duy trì nó ở G1; agent chỉ cần cái tên |
| `AGENTS.md`, `engineering/`, `repo-map` | **Tiếng Anh** | Chỉ dẫn thực thi, nằm cạnh code |
| Comment trong code, commit message | **Tiếng Anh** | Quy tắc thường trực của Orchestrator |
| Store listing, privacy policy, mọi thứ đối ngoại | **Theo yêu cầu bên ngoài** | Privacy policy đang phục vụ 9 locale |

Ba bất biến, áp cho cả hai thứ tiếng:

1. **Thuật ngữ và identifier không dịch.** `Score`, `Setlist`, `Overlay`, `SyncMap`, `Transport`, `MatchScore`, `Tag`, `PageOrder` giữ nguyên dạng trong văn xuôi tiếng Việt. Chúng là tên trong code; dịch chúng là nhân đôi glossary và nhân đôi diện tích của gate G1.
2. **Một tài liệu, một ngôn ngữ.** Không có bản `-vi` song song. Đổi ngôn ngữ của tài liệu thì đổi tại chỗ.
3. **Heading song ngữ** theo dạng `## Bối cảnh (Context)`, và **giá trị kiểm thử đặt trong backtick**. Cái thứ nhất giữ cho grep còn tìm được bằng cả hai thứ tiếng; cái thứ hai giữ cho tiêu chí chấp nhận không phụ thuộc ngôn ngữ.

## Hệ quả (Consequences)

- **Không dịch hồi tố.** 12 ADR và hơn 40 Spec đang là tiếng Anh vẫn để nguyên. Một tài liệu chỉ được dịch khi cần quyết định điều gì từ nó — cùng nguyên tắc mà ADR 0013 dùng cho việc đánh số lại Spec ("renumbered when next touched").
- ADR 0014 được dịch vì lúc đó nó còn `proposed` — và việc dịch đã kịp thay đổi kết quả của nó. **ADR 0013 được dịch ngay sau đó**, và đúng theo luật chứ không phải ngoại lệ: hệ quả đầu tiên của nó, số phận của `constitution.md`, vẫn đang chờ Orchestrator quyết. `Status: accepted` không có nghĩa là không còn gì phải quyết từ tài liệu đó.
- Dãy ADR sẽ trông chắp vá một thời gian — 0001–0012 tiếng Anh, 0013 trở đi tiếng Việt. Đây là cái giá đã chấp nhận của việc chuyển giữa dòng thay vì dịch một lượt.
- **Tên file luôn dùng slug tiếng Anh**, kể cả khi nội dung là tiếng Việt, vì đường dẫn và link là thứ máy với agent đọc — tức thuộc phía "thực thi" của chính luật này. Đó là lý do `0015-doc-language.md` chứ không phải `0015-ngon-ngu-tai-lieu.md`.
- Việc `CONTEXT.md` chuyển sang định nghĩa tiếng Việt **cần một G1 riêng của nó**. Bản nháp trước của ADR 0014 định cấu trúc lại file đó nên việc đổi ngôn ngữ có thể đi kèm; ADR 0014 hiện tại không sửa `CONTEXT.md` nữa, nên đây là một thay đổi độc lập: viết lại phần định nghĩa tại chỗ, giữ nguyên toàn bộ **tên** thuật ngữ và các dòng `_Avoid_`.
- Ranh giới sẽ có ca mập mờ. Khi không rõ một tài liệu thuộc bên nào, câu hỏi để phân xử là: *có ai accept hay reject điều gì dựa trên tài liệu này không?* Có thì tiếng Việt.
