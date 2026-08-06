# Định tuyến model theo pha, với sàn không được hạ ở vùng nhạy cảm

Main session mặc định chạy **Sonnet 5**. **Opus 5** dành cho pha quyết định và làm **sàn không bao giờ được hạ** ở vùng nhạy cảm. Việc khám phá được đẩy sang **subagent rẻ**, để token của nó không bao giờ vào context chính.

**Status:** accepted
**Decided by:** Human Orchestrator (2026-07-28)
**Amended:** 2026-08-05 — thêm số đo thực tế và luật cắt chat tại G3 (xem *Đo lường*)
**Relates to:** ADR 0013 (tier triage — cơ chế định tuyến mà ADR này dùng lại), `.cursor/rules/ai-workflow.mdc`, `.cursor/rules/session-hygiene.mdc`

## Bối cảnh (Context)

Mặc định hiện tại là Opus 5 cho mọi việc. Nó rất tốt và nó không bền về chi phí.

Chính sách duy nhất đang có nằm trong `ai-workflow.mdc` và **chỉ quản subagent**: "default: same-tier hoặc rẻ hơn main session; Opus-class cho subagent cần xin phép kèm lý do". Main session — nơi phần lớn token thực sự được tiêu — không có luật nào.

### Token và phán đoán là hai trục khác nhau

Thứ đốt tiền không phải tác vụ *khó*, mà là tác vụ *dài*. `session-hygiene.mdc` đã ghi đúng cơ chế: *"Every turn carries the whole chat with it, so a chat that outlives its slice costs more each turn"*, và *"a fresh chat is only cheaper if it starts from the documents instead of re-deriving the context by reading the codebase"*.

Buổi làm việc ngày 2026-07-28 là ví dụ sống. Việc kiểm kê hai repo cho ADR 0014 tốn vài chục lệnh `rg` cùng nhiều lượt đọc file — token rất cao, phán đoán gần bằng không — và toàn bộ số token đó được gửi lại ở mỗi lượt về sau. Đó là trả giá Opus cho công việc mà model rẻ nhất làm ngang bằng.

### Ràng buộc thường là ngữ cảnh, không phải năng lực

Bản nháp đầu của ADR 0014 được viết bằng model đắt nhất và **sai khung hoàn toàn**: nó đọc sự khác biệt từ vựng giữa hai sản phẩm thành trôi dạt lịch sử. Nó sai không vì thiếu năng lực mà vì thiếu **một dữ kiện** — StageScore thừa hưởng từ ScorePDF, web thừa hưởng từ Tomplay và FollowKeys. Một model đắt hơn nữa sẽ sai y như vậy. Một model rẻ *biết* dữ kiện đó thì viết đúng ngay lần đầu.

Suy ra nguyên tắc chi tiêu: **tiêu vào ngữ cảnh, đừng tiêu vào model.** Và ngữ cảnh chính là thứ `CONTEXT.md`, ADR, Spec và decisions log sinh ra để cấp.

### SDO vốn đã là kiến trúc kiểm soát chi phí

Cột sống của ADR 0013 dồn phán đoán đắt về phía trước: ADR ở G2, Spec ở G3. Sau khi G3 chốt, việc hiện thực đã bị ràng buộc đủ chặt để một model rẻ hơn làm được — đó là ý nghĩa của "Spec is law".

Từ đó có một chẩn đoán đáng giá: **nếu phải leo lên Opus để hiện thực một Spec đã locked, thì lỗi nằm ở Spec, không nằm ở model.** Hoá đơn model trở thành thước đo chất lượng spec thay vì một khoản cố định.

### Gate tự động là thứ làm model rẻ trở nên an toàn

"Chạy model rẻ trước, leo thang khi thất bại" chỉ rẻ hơn về kỳ vọng **nếu thất bại bị phát hiện**. Với code thì husky pre-commit typecheck, pre-push build và `web-ci.yml` chính là bộ phát hiện đó, và git làm cho việc hoàn tác gần như miễn phí. Đây là lý do ADR 0013 giữ lại các hook, và giờ chúng gánh thêm một vai nữa.

**Nhưng với văn xuôi thì không có bộ phát hiện nào.** Một ADR sai, một Spec mơ hồ, một dòng store listing lệch — không test nào bắt được; người bắt là Orchestrator, và bằng chứng ADR 0014 cho thấy điều đó xảy ra chậm. Đây là lý do pha quyết định ở lại Opus, và nó không phải lựa chọn tuỳ ý.

## Các lựa chọn đã cân nhắc (Considered options)

- **Giữ Opus 5 cho mọi việc** — bị bác. Nó trả giá cao nhất cho pha khám phá, vốn là pha tiêu nhiều token nhất và cần phán đoán ít nhất.
- **Dùng model rẻ nhất cho mọi việc** — bị bác. Nó áp mức rủi ro của tier S lên vùng auth, billing và timing JNI, nơi chi phí một sự cố không có giới hạn trên.
- **Chỉ định tuyến theo tier** — chưa đủ. Tier đo bán kính ảnh hưởng, không đo khối lượng token. Một việc tier S có thể ngốn hàng chục nghìn token chỉ để tìm chỗ cần sửa, và tier không thấy được điều đó.
- **Định tuyến theo pha, cộng sàn theo tier** — được chọn. Hai trục cho hai vấn đề khác nhau: pha quản khối lượng, tier quản rủi ro.

## Quyết định (Decision)

### Theo pha

| Pha | Phán đoán | Token | Model |
|-----|-----------|-------|-------|
| Khám phá, kiểm kê, tìm kiếm, đọc để hiểu | thấp | rất cao | Rẻ nhất, **bắt buộc qua subagent** |
| Quyết định — ADR, Spec, grilling, thiết kế interface | rất cao | thấp | **Opus 5** |
| Hiện thực theo Spec đã locked | trung bình | trung bình | **Sonnet 5** |
| Review | cao, và cần góc khác | trung bình | **Khác họ model** với bên đã viết |
| Máy móc — đổi tên, format, dịch, boilerplate | thấp | trung bình | Rẻ nhất |

**Mặc định của main session là Sonnet 5.** Việc khám phá luôn đi qua subagent, vì như vậy vừa rẻ vừa giữ context chính sạch — hai lợi ích từ một hành động.

**Review phải dùng họ model khác với bên đã viết.** Một model có xu hướng không bắt được đúng loại lỗi nó vừa gây ra, nên đa dạng góc nhìn ăn điểm hơn là thêm năng lực thô — và tình cờ là rẻ hơn.

### Sàn không được hạ

Dùng lại **nguyên danh sách never-downgrade của tier L** trong `ai-workflow.mdc` làm sàn model: auth và session, billing cùng webhook, LiveKit token, `packages/core-audio/` ở mọi đường dẫn, env và secret, presigned R2 URL, và mọi migration phá huỷ dữ liệu. Ở những chỗ đó **luôn là Opus 5, không bao giờ hạ, không cần lý do gì thêm.**

Lý do là sự bất đối xứng: chi phí một model là hữu hạn và biết trước; chi phí một sự cố auth hoặc billing thì không.

### Một chat, một pha (bổ sung 2026-08-05)

Định tuyến theo pha chỉ có tác dụng nếu **mỗi pha ngồi trong một chat riêng**. Nếu pha quyết định và pha hiện thực dùng chung một chat thì pha rẻ nhất chạy trên đống context đắt nhất, và việc chọn model không cứu được gì — số đo bên dưới cho thấy đúng như vậy.

- **G3 accept là ranh giới chat bắt buộc.** Chat vừa chốt Spec không build Spec đó. Chat build là chat mới, mở đầu bằng con trỏ tài liệu theo `session-hygiene.mdc`.
- **"continue" trên một chat đã dài là tín hiệu cắt chat, không phải lệnh làm tiếp.** Đo được: hai chữ "continue" ở cuối phiên 2026-08-05 tốn 42% chi phí cả chat.
- Một chat mang tối đa **một** Spec đi hết vòng. Bug report giữa chừng và thảo luận thiết kế cho Spec kế tiếp đều mở chat riêng.

### Leo thang theo tín hiệu, không theo mặc định

Bắt đầu ở model mặc định của pha. Chỉ nâng khi có tín hiệu thật:

- Lần thử thứ hai vẫn thất bại ở cùng một vấn đề
- Test hoặc typecheck không xanh sau một lần sửa có chủ đích
- Phát hiện Spec mơ hồ giữa lúc build — đây là tín hiệu **quay lại G3**, không phải tín hiệu nâng model
- Agent tự đánh giá là không chắc, và nói ra

Việc leo thang được ghi một dòng vào worklog, để **mẫu hình lộ ra**: nếu một Spec liên tục cần leo thang, khuyết điểm nằm ở Spec đó.

## Đo lường (Measurement) — 2026-08-05

ADR này tự hẹn một lần xem lại sau khi có số thực. Đây là số đó, lấy từ transcript của ngày 2026-08-05 (ba lần bị charge, mỗi lần trên 100 USD).

Chat đắt nhất chạy 13:34–17:42: **270 lượt agent, 11 tin nhắn của người, ~23 triệu token đầu vào**, context cuối phiên ~145 nghìn token. Nó gánh ba việc: build 0053, quyết định 0054, build 0054.

| Pha trong chat đó | Lượt | % chi phí |
|---|---|---|
| Trả lời G3 spec 0053 | 20 | 1.2% |
| Accept + build 0053 | 54 | 7.9% |
| Bug report | 3 | 0.6% |
| Thảo luận thiết kế 0054 | 5 | 1.2% |
| Build 0054 | 114 | 47.1% |
| Hai lần "continue" | 74 | 42.1% |

**Giả thuyết ban đầu sai chỗ.** ADR này đoán tiền tập trung ở pha khám phá; thực tế khám phá gần như không xuất hiện, còn **89% nằm ở pha hiện thực chạy trong một chat dài**. Phần phán đoán đắt tiền mà ADR này cố ý trả giá Opus — G3, thảo luận thiết kế — chỉ chiếm **2.4%**. Kết luận: **giữ Opus cho pha quyết định là quyết định rẻ**, và nó không phải chỗ cần tối ưu.

Luật subagent thì đúng nhưng chưa được thi hành: cả ngày có **250 lượt `Read`/`Grep`/`Shell` nằm thẳng trong context chính và 4 lượt gọi subagent**. Mỗi file đọc vào ở lượt 30 vẫn bị gửi lại ở lượt 270.

Tính ngược trên chính khối lượng công việc đó: nếu build 0054 khởi động bằng chat mới đọc từ Spec thì tốn **53%** số token; cộng thêm việc hạ pha build về Sonnet theo đúng bảng trên thì còn khoảng **10%**. Không dòng code nào phải đổi để có mức đó.

Còn một tín hiệu nữa cần đọc đúng: ngay cả khi tách chat, riêng build 0054 vẫn tự sinh 10.8 triệu token qua 193 lượt với 124 lần sửa file. Đó không phải vấn đề model mà là **Spec quá to** — 0054 gộp đặt tên book, resplit và grouping. Cắt Spec nhỏ hơn ở G3 là đòn bẩy rẻ nhất vì nó tác động lên cả ba nguồn chi phí cùng lúc.

## Hệ quả (Consequences)

- `ai-workflow.mdc` nhận bảng cụ thể ở trên. Chính sách subagent cũ được giữ và mạnh thêm: khám phá **luôn** dùng model rẻ, không phải "cùng tier hoặc rẻ hơn".
- Dòng công bố tier của ADR 0013 nay mang thêm model: *"Task M (apps/web, ~6 file, không vùng nhạy cảm) → Sonnet 5, viết spec trước."* Model được nói to cũng là một quyết định người khác thấy được.
- ~~**Chính sách này là một giả thuyết, chưa phải kết luận.**~~ Đã đo ngày 2026-08-05, xem *Đo lường*. Giả thuyết "tiền tập trung ở khám phá" **sai**; tiền tập trung ở context tích luỹ của pha hiện thực trong chat dài. Bảng định tuyến theo pha vẫn đúng, nhưng nó chỉ phát huy tác dụng khi đi kèm luật *Một chat, một pha* — thiếu luật đó thì việc chọn model gần như vô nghĩa.
- Thước đo cần nhìn từ nay là **số lượt agent trong một chat**, không phải tên model. Một chat vượt khoảng 100 lượt đã tự nó thành khoản chi lớn nhất trong ngày, bất kể chạy model nào.
- Tên model cụ thể sẽ cũ đi nhanh hơn phần còn lại của ADR. Phần bền là **cấu trúc** — pha, sàn, tín hiệu leo thang; còn "Sonnet 5" hay "Opus 5" chỉ là tên của hạng model tại 2026-07. Đổi tên trong `ai-workflow.mdc` là việc tier S.
- Rủi ro cần nói thẳng: cách này chuyển một phần gánh nặng sang Orchestrator, vì với văn xuôi thì con người là bộ phát hiện duy nhất. Nếu thấy chất lượng ADR hay Spec tụt, hãy đọc đó là tín hiệu sàn của pha quyết định bị hạ quá thấp, không phải tín hiệu SDO thất bại.
