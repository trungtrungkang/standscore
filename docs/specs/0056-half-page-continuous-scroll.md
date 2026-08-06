# 0056 — Half Page thành scroll liên tục ép nửa bước; default Layout về One page

- **Status:** accepted (G3 2026-08-06)
- **Type:** feature
- **Horizon:** không thuộc H5. Sửa một feature PdfMode đã `done` (P0–P2), không chạm audio/OMR/platform.
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008, 0013 (tier)
- **Depends on Specs:** supersede một phần của **0013** (overlay + separator của Half Page) và **0041** (decision 2/3/10 liên quan Half Page + default Auto); không đụng phần còn lại của hai Spec đó (Auto vẫn là mode chọn được, Two pages/fit-height-wont giữ nguyên)
- **Parity IDs:** P1.9 (viết lại cách làm, không đổi mục tiêu)
- **Tier:** **M** (ADR 0013) — đổi hành vi một feature đã `done`, không SDK mới, không quyền mới, không byte nào rời máy. G3 + G4, không cần ADR mới, không cần Security Review.
- **G3:** accepted 2026-08-06 — cả hai câu chốt theo lựa chọn của Orchestrator (xem "Quyết định" bên dưới)
- **G4:** build xong cùng ngày — `flutter analyze` sạch, **544/544** test xanh (bao gồm test mới/sửa cho `resolvePageTurnStep`, `layoutPagesFor`, `LayoutFit.recommendedMode`, `PdfLayoutPrefs` default). Còn lại: xác nhận thủ công trên máy thật (xem Test plan) trước khi coi slice là đóng hẳn.

> **Sinh từ phản hồi thật của Orchestrator sau khi dùng Half Page.** Overlay có separator kéo tay (0013) trông đúng trên giấy nhưng gây giật khi chơi thật: PageTurn đổi vai trò của cùng một trang từ "dải peek nhỏ phía trên" sang "trang hiện tại full-size phía dưới" trong một khung hình, nên nốt nhạc nhạc công đang tập trung nhảy vị trí + kích thước đột ngột đúng lúc họ cần ổn định nhất.

---

## Vấn đề (Problem)

`HalfPageView` (Spec 0013, sửa peek ở 0041 decision 10) vẽ trang hiện tại full-size trong phần "current pane" cộng một dải "peek" clip phần trên của trang kế, ngăn nhau bởi một separator kéo tay cố định tỉ lệ (`halfPageSeparatorRatio`, mặc định 28%). Khi PageTurn next:

1. Trang N+1 — vừa là "peek" nhỏ, clip, nằm ở rìa màn hình — nhảy thành "current", full-size, nằm giữa màn hình.
2. Trang N+2 xuất hiện làm peek mới, ở đúng vị trí rìa màn hình mà trang N+1 vừa rời khỏi.

Với nhạc công đang đọc nốt trong lúc chơi, đây là một cú giật kép: nội dung họ vừa nhìn thấy ở rìa màn hình (nhỏ, cắt) đột ngột phóng to và dịch chuyển vào giữa. Cảm giác "bám theo trang kế" mà Half Page hứa hẹn (xem trước một phần trang sau trong lúc chơi trang hiện tại) bị chính cơ chế hiện thực hoá nó phá hỏng.

Đồng thời, default Layout cho install mới là **Auto** (0041 decision 3), và trên điện thoại đứng — thiết bị phổ biến nhất — Auto giải ra **Half Page (top/bottom)** vì `freePeek` (35% trên iPhone chuẩn) lớn hơn separator mặc định (28%). Musician mở một Score lần đầu thấy ngay layout có vấn đề ở trên, không phải layout đơn giản nhất.

## Kết quả (Outcome)

Hai thay đổi độc lập, cùng một Spec vì chúng chạm cùng một cụm code (`PdfLayoutMode`, `LayoutFit`, `pdf_mode_screen.dart`):

1. **Default Layout cho install mới đổi từ Auto về One page.** Install đã có file `layout_prefs.json` không bị đụng — mode nào đã lưu vẫn được đọc lại nguyên vẹn.
2. **Half Page (top/bottom, left/right) thôi là overlay tĩnh có separator.** Hai mode này giờ là scroll liên tục dọc theo trục của chúng (đúng engine với mode **Scroll**), và mỗi PageTurn (tap/swipe/pedal) luôn lướt **đúng nửa viewport** theo hướng đó, bất kể setting Turn amount (Turn amount vẫn ẩn ở hai mode này — trước vì "không đổi gì", nay vì "đã bị ép cứng"). Không còn separator, không còn slider "How much of the next page peeks in", không còn khái niệm "peek tốn diện tích" (`freePeek`) — nhạc vẽ đúng kích thước One page trong mọi trường hợp, y hệt Scroll.

Nhìn thấy trước nội dung trang sau giờ đến từ việc **đã scroll qua nửa trang một cách liên tục** (như Scroll + Turn amount Half hôm nay đã làm), không phải từ một dải tĩnh bị clip. Không còn cú nhảy vai trò giữa hai vùng màn hình khác kích thước.

## Trong phạm vi (In scope)

- Đổi default constructor của `PdfLayoutPrefs` (`mode: PdfLayoutMode.single` thay vì `.auto`)
- `layoutPagesFor` dùng đúng trục cho hai mode Half Page (top/bottom → vertical, left/right → horizontal — sửa luôn bug hiện tại đang trỏ cả hai về vertical)
- `resolvePageTurnStep` cho hai mode Half Page trả `PageTurnStep.viewport(0.5)` cố định
- `LayoutFit.recommendedMode` bỏ khái niệm `freePeek`/`peekRatio`; Auto vẫn có thể giải ra Half Page (top/bottom) trên điện thoại đứng, nhưng vì lý do khác (có khoảng trống dọc, không phải vì "peek rẻ hơn ngưỡng")
- Xoá `HalfPageView`, `HalfPageController`, separator/peek helpers (`half_page.dart`, `jump_link_geometry.dart`) — pdf_mode_screen route hai mode này qua đúng đường continuous đã có cho Scroll
- Cập nhật `layout_settings_sheet.dart` (bỏ slider), `page_turn_settings_sheet.dart` (câu hint), `CONTEXT.md` (định nghĩa TurnAmount), `SCOREPDF-PARITY.md` (P1.9)

## Ngoài phạm vi (Out of scope)

- Không đổi Single/Two pages/Scroll/Turn amount cho các mode khác
- Không đổi label hiển thị của hai mode Half Page trong picker ("One page + peek" / "One page + side peek") — chỉ đổi cách chúng hoạt động bên trong
- Không migrate file `layout_prefs.json` cũ trên máy thật (app chưa lên store) — `fromJson` chỉ đơn giản bỏ qua field `halfPageSeparatorRatio` không còn tồn tại trong model
- Không đổi Auto cho install cũ (0041 decision 3 phần "install cũ giữ mode đã chọn" vẫn đứng)

## Domain terms

**PdfMode**, **PageTurn**, **PdfLayoutMode**, **LayoutFit**, **TurnAmount** — không thêm term mới; `CONTEXT.md` chỉ sửa một câu ở định nghĩa TurnAmount (xem Technical constraints).

## Quyết định (chốt qua AskQuestion trong chat 2026-08-06, thay cho G3 form dài)

| # | Câu hỏi | Chốt |
|---|---------|------|
| 1 | Half Page nên xử lý thế nào? | **Biến 2 mode Half Page thành scroll liên tục theo đúng trục, ép Turn amount = Half riêng cho 2 mode này, bỏ separator/peek ratio.** (Phương án "bỏ hẳn khỏi picker, chỉ quảng bá Scroll + Turn amount Half" bị từ chối — giữ tên mode vì nó mô tả đúng nhu cầu nhạc công tìm kiếm.) |
| 2 | Default Layout cho new install? | **Đổi về One page**, chỉ áp dụng install mới; install đã có prefs giữ nguyên mode đã chọn (không đổi cơ chế 0041 decision 3 phần "giữ lựa chọn cũ"). |

Hai quyết định này **supersede** 0041 decision 3 (Auto là default cho new install) và phần overlay/separator của 0013 + decision 2/10 của 0041 (peek là một dải tĩnh, tách biệt khỏi Turn Amount). Phần còn lại của hai Spec đó (Auto là một mode chọn được, Two pages fallback, fit-height `wont`, Match layout…) không đổi.

## Acceptance criteria

Testable checklist (G4):

- [ ] Install mới (không có `layout_prefs.json`) mở Score với Layout = **One page**
- [ ] Install cũ (đã có `layout_prefs.json` với `mode: "auto"` hoặc bất kỳ mode nào khác) không bị đổi mode khi mở lại
- [ ] Chọn **One page + peek** (top/bottom): trang scroll dọc liên tục; tap phải/swipe/pedal next lướt đúng ~nửa viewport, không nhảy sang trang kế trọn vẹn; không có separator/handle nào trên màn hình
- [ ] Chọn **One page + side peek** (left/right): trang scroll ngang liên tục; tap/swipe/pedal next lướt đúng ~nửa viewport theo chiều ngang
- [ ] Không còn slider "How much of the next page peeks in" trong Layout sheet khi chọn hai mode này
- [ ] Turn amount vẫn ẩn khi layout là Half Page (setting không hiện, vì đã ép cứng bên trong)
- [ ] Nhạc vẽ ở hai mode Half Page cùng kích thước với One page trên mọi viewport (không còn "peek tốn diện tích")
- [ ] Auto trên điện thoại đứng giải ra Half Page (top/bottom) — kể cả điện thoại nhỏ và tablet đứng có rất ít khoảng trống dọc, vì `recommendedMode` không còn ngưỡng tỉ lệ, chỉ cần `viewAspect < pageAspect`; trên màn ngang rộng vẫn ra Two pages
- [ ] JumpLink vẫn hoạt động đúng vị trí trên hai mode Half Page (dùng `fittedPageRect` chung, không còn pane rect riêng)
- [x] `flutter analyze` sạch, toàn bộ suite test xanh (544/544)

## Technical constraints

- `pdf_mode_screen.dart`: hai mode Half Page đi qua đúng đường `_buildContinuousBody`/`_buildCustomContinuousBody` mà Scroll đang dùng — không dựng widget riêng nữa
- `resolvePageTurnStep`: nhánh half-page tách khỏi nhánh `single` (không còn gộp chung `PageTurnStep.pages(1)`), trả `PageTurnStep.viewport(0.5)` không phụ thuộc `TurnAmount`
- `CONTEXT.md` — định nghĩa **TurnAmount**: bỏ câu "Khác với layout Half Page, thứ chỉ hé trang kế lên trên mà không dùng tới TurnAmount" (không còn đúng); ghi lại rằng Half Page dùng một bước TurnAmount cố định (Half) ở bên trong, không expose ra setting

## Test plan

- Automated: `resolvePageTurnStep` cho half-page trả `viewport(0.5)` với mọi `TurnAmount`; `layoutPagesFor` đúng trục cho từng mode half-page; `LayoutFit.recommendedMode` không còn nhận `peekRatio`; `PdfLayoutPrefs()` default `single`; round-trip prefs không còn field `halfPageSeparatorRatio`
- Manual: mở Score mới trên máy thật ở One page; chọn hai mode Half Page, PageTurn qua vài trang xem không còn giật vị trí; xoay máy kiểm Auto trên điện thoại/tablet
