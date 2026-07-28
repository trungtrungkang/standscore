# Repo chạy SDO, với S/M/L làm tầng phân loại

Mô hình phát triển của repo sau khi gộp là **Spec-Driven Orchestration**. Ba tier **S/M/L của Backing & Score được giữ lại như bộ định tuyến** quyết định một thay đổi phải đi qua bao nhiêu phần của cột sống SDO — không phải như một mô hình thứ hai đứng cạnh cạnh tranh.

**Status:** accepted
**Decided by:** Human Orchestrator (2026-07-28)
**Relates to:** ADR 0001 (spec-driven orchestration), ADR 0012 (code nằm ở đâu), `docs/process/DEVELOPMENT-MODEL.md`, và trong repo web là `.cursor/rules/ai-workflow.mdc` cùng `docs/specs/constitution.md`

## Bối cảnh (Context)

Mỗi nửa của Backing & Score tự mọc ra cách làm việc riêng, và ADR 0012 nghĩa là hai nửa đó sắp dùng chung một repo.

Repo này chạy **SDO**: một cột sống artifact (VISION → `CONTEXT.md` → ADR → Feature Spec → code), ADR được đánh số và chỉ thêm không sửa, có `Status` và `Decided by`, Spec được đánh số với vòng đời `proposed → accepted → done`, năm gate của con người G0–G4 mà agent được phép chuẩn bị nhưng không được phép bỏ, và một luật giữ tất cả lại với nhau — *không có trong VISION, CONTEXT, một ADR hay một Spec thì agent không được tự nghĩ ra hành vi sản phẩm*.

Repo web chạy **phân loại theo tier**: mỗi việc được xếp S, M hay L theo bán kính ảnh hưởng, tier được công bố trong một dòng, và tier quyết định quy trình. Tier S là sửa lỗi không cần spec; M là spec cộng Bugbot; L là bắc ngang nhiều app hoặc chạm vùng nhạy cảm, và thêm Security Review. Nó mang theo một danh sách vùng không bao giờ được hạ khỏi L — auth, billing, LiveKit token, `core-audio`, env và secret, presigned R2 URL — cộng husky pre-commit typecheck, pre-push build, và `web-ci.yml`.

Đặt cạnh nhau thì hai cái này không phải đối thủ. **S/M/L vốn đã là mặt tiền của chính những gate mà SDO định nghĩa**, và SDO nói điều đó mà không dùng chữ "tier": mục "AI proposes + implements after accept" của nó cho phép agent tự làm "bugfixes inside accepted behavior" và "refactors that do not change ADR/Spec", không qua gate nào. Đó chính là tier S, mô tả từ phía ngược lại.

Phần đáng chú ý là mỗi bên đang thiếu gì.

**SDO không có khái niệm bán kính ảnh hưởng, và không có cơ chế cưỡng chế tự động.** Nó chưa từng cần: StageScore là offline-first, không thu thập gì, không có auth, không có billing, không có token của bên thứ ba. Cơ chế cưỡng chế của nó là sự chú ý của Orchestrator. Web app có đủ tất cả những thứ đó, và sự chú ý thì không co giãn theo được.

**Mô hình bên web không có cột sống, và nó đã trả giá hai lần rồi.** `docs/specs/constitution.md` vẫn mang tiêu đề *"Project Constitution: Lotusa Android"* và ban luật về JNI, FluidSynth, `redoLayout` của Verovio, và các key trong `LaunchedEffect` của Jetpack Compose — luật bất khả thương lượng cho một app giờ đã là experimental, trong khi sản phẩm GA là Next.js. Và R22: privacy policy tuyên bố Backing & Score chạy Mixpanel, thu tiền qua Paddle, và báo cáo lịch sử chơi cho Hal Leonard. Một cuộc audit phát hiện gần như không thứ nào tồn tại. Cả hai đều là tài liệu trôi khỏi code mà không có gate nào chặn — đúng thất bại mà luật "không được tự nghĩ ra hành vi sản phẩm" sinh ra để ngăn.

Vậy lý lẽ cho SDO không phải là Orchestrator thích nó. Lý lẽ là **nửa bên web đã hai lần sản xuất ra chính loại artifact mà SDO cấm.**

## Các lựa chọn đã cân nhắc (Considered options)

- **SDO thuần, bỏ tier** — bị bác. Nó sẽ dựng một gate G3 trước một lần sửa lỗi chính tả hai dòng, và nó ném đi danh sách vùng nhạy cảm cùng các gate husky/CI — thứ cưỡng chế *tự động* duy nhất mà cả hai nửa có. Điểm yếu của SDO là không có gì chặn agent bỏ qua nó; chính mấy cái hook mới chặn được.
- **Mỗi sản phẩm một mô hình** — bị bác. Hai quy trình trong một repo nghĩa là mọi thay đổi bắc ngang (R20 là một ví dụ) phải chọn quy trình trước khi làm. Nó cũng để nửa bên web tiếp tục không có cột sống, tức là không sửa được vấn đề.
- **SDO làm cột sống, tier làm bộ định tuyến** — được chọn. Không bỏ gì của bên nào, và mỗi bên cấp cho bên kia đúng thứ đang thiếu.

## Quyết định (Decision)

Tier là bộ định tuyến; gate là điểm đến.

| Tier | Khi nào | Phải qua gate nào |
|------|---------|-------------------|
| **S** | Sửa trong hành vi đã accepted, một app, phạm vi nhỏ | Không gate nào. Vẫn bị ràng buộc bởi "không tự nghĩ ra hành vi sản phẩm" |
| **M** | Một tính năng trong một app, hoặc một bug phức tạp | Feature Spec accepted ở **G3**, verify ở **G4** |
| **L** | Bắc ngang sản phẩm, package dùng chung, hoặc vùng nhạy cảm | **G2** ADR + **G3** Spec + **G4**, cộng Security Review |

Giữ lại từ SDO: cột sống artifact, ADR đánh số chỉ-thêm, Spec đánh số có vòng đời, G0–G4, kỷ luật spike (giới hạn thời gian và một tiêu chí thành công đo được, không cam kết tính năng), cập nhật `CONTEXT.md` trong cùng session, và danh sách anti-pattern.

Giữ lại từ mô hình web: phân loại theo bán kính ảnh hưởng kèm một dòng công bố, danh sách vùng nhạy cảm không được hạ tier, husky pre-commit và pre-push, `web-ci.yml`, incidents log, chính sách chi phí model cho subagent, và luật "chỉ commit khi người dùng yêu cầu".

Cơ chế leo thang giữ nguyên như bên web đang làm: một việc tier S mà phình ra khỏi phạm vi thì **dừng lại**, công bố tier mới, rồi tiếp tục dưới các gate của tier đó.

## Hệ quả (Consequences)

- **`constitution.md` không thể tồn tại như hiện tại.** Nó đang là luật cho một app experimental, nghĩa là hoặc gây hiểu sai hoặc bị phớt lờ, và cả hai đều tệ hơn là không có gì. Nó hoặc được viết lại thành guardrail cho sản phẩm GA, hoặc bị hạ xuống `docs/experimental/`. **Đã xử lý 2026-07-28:** Orchestrator chọn hạ xuống. File giờ là `docs/experimental/constitution.md`, thu phạm vi về `apps/android/`, `apps/ios/` và `packages/core-audio/`, và không còn ràng buộc `apps/web/`. Mục 4 của nó vốn viết lại quy trình spec-và-duyệt-plan nên giờ trỏ về ADR này thay vì nhắc lại — chính việc nhân bản đó là cách hai bên trôi xa nhau. Tham chiếu đã sửa ở `AGENTS.md`, `.cursor/rules/ai-workflow.mdc`, `sdd-workflow.md`, `repo-map.md` và `docs/experimental/README.md`.
- Spec được đánh số và có trạng thái. Các spec hiện có bên web (`wait_mode_spec.md`, `audio_engine_spec.md`, và những cái còn lại) được **đánh số lại khi nào chạm tới lần tiếp theo**, không phải trong một lượt quét — đổi tên đồng loạt sẽ phá mọi link trỏ vào mà không đổi được hành vi nào.
- Một dãy ADR duy nhất cho cả repo. ADR này là số 0013 trong dãy đó. File `docs/engineering/ai-memory/decisions.md` bên web trở thành log mềm, đúng vai mà `docs/product/DECISIONS-LOG.md` đang giữ ở đây; hai file nhập lại chứ không cạnh tranh nhau.
- **Gate G1 áp theo từng bounded context, không áp lên một glossary gộp.** Đây là điểm mà ADR 0014 đã sửa lại sau khi ADR này được viết: hai sản phẩm giữ hai bộ từ vựng riêng, nên "G1 toàn repo" nghĩa là *mỗi context một glossary*, chứ không phải một glossary cho tất cả.
- Các gate của SDO vẫn không cưỡng chế được bằng máy. Hook bắt được lỗi type; không gì bắt được một G3 bị bỏ, ngoài việc Orchestrator nhận ra. Sự bất đối xứng đó được chấp nhận, và nó chính là lý do phải giữ bước công bố tier: một tier đã nói to là một gate mà người khác thấy được là đã bị bỏ.
- Tier giờ phải có nghĩa cho cả một app Flutter. `apps/stagescore/` là offline và không thu thập gì, nên nó không có vùng nhạy cảm của riêng nó; các trigger tier L của nó là những cái SDO đã nêu sẵn — quyền sở hữu audio, OMR, dữ liệu rời khỏi thiết bị, và mọi thay đổi lên một ADR đã accepted.
