# 0033 — Pinch / double-tap zoom coexist with PageTurn (P0.7 reopen)

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0031 (done); 0032 (done)
- **Parity IDs:** P0.7 (reopen); Q1
- **G3:** accepted (2026-07-26)
- **G3 notes:** Double-tap toggle fit ↔ ~2×. PageTurn single-finger only; ≥2 pointers pass through for pinch. PerformancePageSlot paths + identity PdfViewer. Build before 0030.
- **G4:** pass (2026-07-26)
- **Tái mở một phần (2026-07-29):** double-tap zoom bị bỏ — xem "Cập nhật sau G4" bên dưới.

## Problem

P0.7 claims pinch + double-tap zoom, but PdfMode’s PageTurn interaction layer often wins the gesture arena, so pinch does not reliably scale the page. Double-tap zoom was never implemented. Zoom lock (0031) is hard to demo or trust when unlocked zoom does not work. Improvement roadmap A1 reopens P0.7 for honesty.

## Outcome

When zoom is **unlocked**, the musician can **pinch** to scale the current page ~~and **double-tap** to toggle a useful zoom level~~ (double-tap cut 2026-07-29 — see "Cập nhật sau G4" below: it forced every PageTurn tap to wait `kDoubleTapTimeout`); pan works when zoomed, and the pinched scale now follows the musician across pages. PageTurn tap/swipe still work for single-finger navigation and do not steal two-finger pinch. When zoom is **locked** (0031), pinch scale stays disabled. Draw mode and JumpLink drag remain usable.

## In scope

- Two-finger pinch scale reaches `InteractiveViewer` (or equivalent) when unlocked
- PageTurn swipe/drag does not claim multi-touch scale gestures
- Double-tap toggles zoom (fit ↔ ~2×)
- Pan when zoomed (existing intent of P0.7)
- Honor 0031 zoom lock (`scaleEnabled` / no double-tap scale when locked)
- Works on Single / Half Page / continuous custom slots using `PerformancePageSlot`
- Identity continuous `PdfViewer` path: scaleEnabled already gated by lock — verify pinch still usable when unlocked

## Out of scope

- Metronome (0030 — next after this Spec)
- Performance mode / menu IA (Phase B)
- Max page DPI
- Peek-then-snap while locked (already cut in 0031)
- Changing Page scale slider semantics (0031)

## Domain terms

**PdfMode**, **PageTurn**, **Score**

## Acceptance criteria

Testable checklist (G4):

- [x] With lock off, pinch-in / pinch-out visibly scales the page
- [x] ~~With lock off, double-tap toggles zoom as documented~~ — cut 2026-07-29
- [x] With lock on, pinch does not change scale
- [x] Single-finger tap / swipe PageTurn still work when not drawing
- [x] Two-finger pinch does not trigger a PageTurn
- [x] When zoomed, pan works (where layout allows)
- [x] Draw mode still draws; JumpLink long-press / drag still work

## UX notes

- Prefer transparent behavior over a new “Zoom mode” toggle
- Keep defaults: unlocked unless user set lock in Page scale sheet

## Technical constraints

- "Zoomed in" is measured against the zoom the layout opens at in the *current* viewport (`pdfFitZoom`), not pdfrx's `minScale`. `minScale` is the scale that fits one whole page, so in landscape a Score sitting at its own fit zoom read as 3× zoomed and swipe PageTurn switched itself off.
- Fix hit-testing / gesture arena between `PageTurnInteractionLayer` and `InteractiveViewer`
- Prefer translucent overlay that does not win scale; or route scale to the viewer under the overlay
- Manual demo on device required (simulator gestures may mislead)

## Test plan

- Automated: toggle-zoom matrix helper
- Manual: lock off → pinch → pan → PageTurn; lock on → pinch ignored; double-tap; draw; Half Page

## Cập nhật sau G4 (tái mở một phần, 2026-07-29)

**Vấn đề phát hiện (musician báo cáo):** tap để turn page phản hồi chậm rõ rệt so với ScorePDF, dù `PageTurnDelayGate` (Spec 0006) mặc định `off`. Root cause: `PageTurnInteractionLayer` gắn cả `onTap` lẫn `onDoubleTap` trên cùng một `GestureDetector` (`onDoubleTapZoom` khi `doubleTapZoomEnabled: !_pageScalePrefs.locked`, tức bật mặc định vì `locked = false`). Khi hai handler này cùng sống trên một `GestureDetector`, Flutter's gesture arena bắt buộc giữ mọi single-tap trong `kDoubleTapTimeout` (~300ms) để chờ xem có tap thứ hai không, trước khi mới bắn `onTap` — đây là cơ chế nội bộ của framework, không phải logic StageScore tự viết và không có cách nào "tắt bớt" nếu vẫn giữ cả hai handler chung. ScorePDF không có double-tap-zoom cạnh tranh với tap-to-turn nên tap của nó không bao giờ phải đợi.

**Quyết định (Orchestrator, cùng ngày):** bỏ hẳn double-tap-to-zoom. Pinch (hai ngón) là cử chỉ zoom duy nhất còn lại — `onTap` trong `PageTurnInteractionLayer` không còn `onDoubleTap` cạnh nó nữa nên turn page tức thì, không còn chờ disambiguation.

**Thêm cùng lúc (yêu cầu mới, không phải hệ quả bắt buộc của việc bỏ double-tap):** một khi zoom chỉ còn qua pinch, view đã dựng trên một trang giờ **được chia sẻ sang các trang khác** trong reading order — trước đây mỗi trang giữ `TransformationController` độc lập, nên turn page luôn trả về fit dù trang trước đang zoom. `SinglePageSlider`, `HalfPageView`, `ContinuousPageOrderView` (ba viewer dùng `Map<int, TransformationController>` theo trang) đều gọi chung ba hàm thuần trong `lib/pdf/shared_zoom.dart` (`nextSharedZoomTransform`, `sharedZoomTransformChanged`, `sharedZoomMatrix`), kích hoạt qua `InteractiveViewer.onInteractionEnd` (một lần khi gesture kết thúc, không phải mỗi frame khi đang pinch) — trang mới mở (kể cả chưa từng ghé) khởi tạo `TransformationController` đã có sẵn transform chia sẻ; pinch trở lại fit trên bất kỳ trang nào cũng lan sang các trang khác.

**Mở rộng cùng ngày (Orchestrator):** ban đầu chỉ chia sẻ **scale**; đổi sang chia sẻ **cả pan** (toàn bộ `Matrix4`, không chỉ độ phóng) vì lý do cụ thể — một bản scan có lề trái rộng, lề phải hẹp thì sau khi zoom, musician còn cần pan để lệch khung nhìn bù cho lề lệch đó, và vị trí pan đó cũng nên áp dụng cho các trang khác chứ không riêng gì độ phóng (các trang trong cùng một tài liệu thường lệch lề giống nhau). `shared_zoom.dart` giữ `Matrix4?` thay vì `double?`; mỗi lần gán cho một trang khác đều `.clone()` để hai trang không bao giờ trỏ chung một `Matrix4` instance (đối tượng mutable). Viewer continuous "identity" (layout mặc định, dùng `PdfViewer` của pdfrx trực tiếp) vốn đã chia sẻ cả zoom lẫn pan tự nhiên vì toàn bộ tài liệu là một canvas cuộn liên tục, không cần sửa.

**Không đụng:** pinch vẫn tắt khi `PageScalePrefs.locked` (Page scale sheet, "Keep this scale") — subtitle sheet đó sửa lại còn "Pinch is off…", bỏ nhắc double-tap. `zoom_toggle.dart` giữ lại `isInteractivelyZoomed` (còn dùng để tính `panEnabled`), bỏ `toggledZoomMatrix`/`toggleTransformationZoom` (chỉ phục vụ cơ chế toggle fit↔2× của double-tap, nay chết).

**Sửa tiếp cùng ngày — vị trí chia sẻ "không chuẩn" (musician báo cáo):** bản đầu đọc `t.value` ngay tại `InteractiveViewer.onInteractionEnd`, callback này bắn ra **ngay khi buông tay**, nhưng chính doc-comment của Flutter cảnh báo "a pan may cause an inertia animation after this is called as well" — `_handleInertiaAnimation` (trong `interactive_viewer.dart` của framework) còn tiếp tục ghi vào cùng `TransformationController` thêm vài frame nữa cho animation quán tính (fling). Vậy transform được chia sẻ là vị trí **giữa lúc đang trôi theo quán tính**, không phải vị trí musician thật sự dừng lại — trang kế tiếp mở ra lệch. Sửa bằng debounce trên listener của `TransformationController` thay vì tin vào thời điểm `onInteractionEnd`: mỗi lần giá trị đổi thì huỷ timer cũ, đặt timer mới (`kZoomSettleDelay`, 150ms — vượt xa khoảng cách một frame ở 60–120fps); chỉ khi timer chạy hết mà không có thay đổi nào thêm mới coi là "đã dừng" và chia sẻ. `onInteractionEnd` bị bỏ hẳn khỏi `PerformancePageSlot` — không còn cần.

**Test:** `test/shared_zoom_test.dart` (mới, test thuần cho ba hàm trong `shared_zoom.dart`, gồm cả trường hợp cùng scale khác pan vẫn phải tính là thay đổi, cộng một test khoá `kZoomSettleDelay` đủ lớn hơn một frame gap — không dựng `PdfDocument` thật vì pdfrx cần native viewer, `flutter test` không chạy được). `test/zoom_toggle_test.dart` viết lại chỉ còn test `isInteractivelyZoomed`. 301 tests xanh, analyze sạch. Chưa demo lại trên thiết bị thật (G4 gốc của 0033 vẫn đứng cho phần pinch/PageTurn coexist chưa đổi; phần double-tap, cross-page zoom và cross-page pan là hành vi mới, chưa qua G4 riêng).

## Cập nhật sau G4 (Scroll identity, 2026-08-07)

**Hai lỗ trên layout Scroll** (`PdfLayoutMode.fitWidth` / Half Page continuous — đường `PdfViewer` identity, không phải `SinglePageSlider`):

1. **Pinch rồi vuốt không cuộn.** Khi đã zoom, `_onInteractionAction` cố ý bỏ swipe PageTurn để dành một ngón cho pan — nhưng `PageTurnInteractionLayer` vẫn gắn `onVerticalDragEnd` / `onHorizontalDragEnd` phủ cả viewer, thắng gesture arena, nên pan của pdfrx cũng không nhận được. Sửa: thêm `swipeGesturesEnabled` (tắt khi `!_atFitZoom`); tap PageTurn vẫn sống.
2. **Prev / next / scrubber làm mất zoom.** `goToPage` với `pageAnchor: top` tính lại zoom fit và chỉ dùng zoom hiện tại làm `zoomMax` (trần), không giữ mức pinch. PageTurn tap trên Scroll vốn dùng `_scrollByViewportFraction` (giữ zoom); nút PageNavBar và scrubber đi `_jumpToPage` → `goToPage` nên bị reset. Sửa: `_goToIdentityPage` — lúc fit thì `goToPage` như cũ; lúc đang pinch thì `calcMatrixFor(pageTopFocus(...), zoom: currentZoom)`.

**Test:** `test/continuous_zoom_nav_test.dart` (hàm thuần `pageTopFocus`). Demo tay: Scroll → pinch → vuốt cuộn được; pinch → next trên thanh trang → zoom còn.

**G4 (2026-08-08):** Orchestrator chấp nhận follow-up Scroll identity. Slice 0033 đóng lại.
