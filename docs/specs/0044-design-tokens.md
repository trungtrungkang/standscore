# 0044 — Design token & component theme: một ngôn ngữ thị giác cho sheet và chip

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005 (Flutter shell), 0008 (early-phase constraint — slice này không đụng SmartMode/OMR), 0015 (ngôn ngữ tài liệu)
- **Depends on Specs:** 0026 (done — sở hữu `AppAppearance` và seed accent do musician chọn; Spec này mở rộng đúng hàm `themeData` đó); 0035 (done — sở hữu ngữ pháp sheet và `SheetBody`); 0030 (done — `SheetBody` ra đời ở phần "Cập nhật sau G4" của nó); 0043 (done — sở hữu các **hằng số đo được** của `PageNavBar` / `ScoreMenuQuickBar`, thứ Spec này cố ý **không** biến thành token); 0041 (done — idiom "hỏi viewport, đừng nhớ câu trả lời"); 0042 (done — idiom test guard ở tầng source)
- **Parity IDs:** Q11 (roadmap Phase E, hạng mục E2)
- **G3:** passed 2026-07-29 (Orchestrator) — chín câu ở mục "Câu hỏi G3" dưới đây (tám câu của bản draft, cộng 4b tách ra từ câu 4), mỗi câu có khuyến nghị kèm bằng chứng. Bản này đã qua một vòng đối chiếu source ngày 2026-07-29: khuyến nghị cho câu **1, 5, 6** đã đổi và phạm vi hẹp lại — `PopupMenuThemeData` cùng thang đổ bóng bị cắt
- **G4:** passed 2026-07-29 (Orchestrator — chạy thử trên thiết bị, "thấy tốt rồi"). Ba lệch ở mục Build notes được chấp nhận **như đang có**: `ChipThemeData` giữ dạng ghim vào thang, `clipBehavior` giữ, và JumpLink mới lệch 9/255 xanh so với link cũ là chấp nhận được

## Vấn đề (Problem)

Đợt audit sinh ra Phase E (`DECISIONS-LOG.md`, 2026-07-28) kết luận khoảng cách với ScorePDF nằm ở **cách trình bày**, không ở năng lực. Chỗ sâu nhất của khoảng cách đó là app **không có tầng thị giác dùng chung nào cả**: toàn bộ phần cấu hình hình thức của StageScore là bảy dòng trong `AppAppearance.themeData` (`lib/theme/app_appearance.dart:50-57`) — một `ColorScheme.fromSeed` cộng `useMaterial3: true`. Không một component theme nào. Mọi quyết định thị giác khác đều được viết lại tại chỗ, mỗi lần một chút khác.

Bảng dưới đây là số liệu **đã đếm lại từ source ở vòng grilling G3 (2026-07-29)**; bản draft đầu tiên dựa vào một đợt kiểm kê subagent và ba dòng của nó sai — sai theo hướng phóng đại việc cần làm. Xem "Câu hỏi G3" để biết mỗi chỗ sai đổi khuyến nghị nào.

| Trục | Trạng thái hôm nay |
|---|---|
| **Màu brand teal** | **Hai giá trị**: `0xFF0D8B86` (theme, launcher, splash, seed mặc định, cộng ba resource Android) và `0xFF0D9488` (`draw_toolbar.dart:64,137`, `stamp_painter.dart:42`, `jump_link.dart:76` dạng `0xCC0D9488`). Cộng `display_sheet.dart:8` viết `Color(0xFF0D8B86)` bằng tay trong danh sách preset màu viền trang |
| **Bo góc** | **Sáu giá trị** `BorderRadius.circular` trên **13 site**: 4, 6, 8, 10, 12, 14 |
| **Đổ bóng** | Bốn giá trị nhưng chỉ **4 site trong toàn `lib/`**: `score_menu_quick_bar.dart:117` (2), `page_nav_bar.dart:72` (2), `draw_toolbar.dart:254` (8), `jump_link_overlay.dart:131` (4 khi kéo / 1 khi không). Ba cái đầu là chrome **đo được** của 0043 / 0034 |
| **Khoảng cách** | Mười ba trị số rời rạc trong `EdgeInsets` / `SizedBox`: 0, 2, 4, 6, 8, 10, 12, 16, 20, 24, 32, 36, 88. Phân bố: 8 xuất hiện 60 lần, 16 là 52, 4 là 22, 12 là 21, 24 là 13, `0` là 20; phần **lệch thang vô danh chỉ 11 site** (2 ba chỗ, 6 một, 10 hai, 20 ba, 32 một, 36 một) và `88` ba chỗ |
| **Chrome của sheet** | 19 lối vào `showModalBottomSheet`, **không một cái nào** truyền `shape`, `backgroundColor` hay `clipBehavior`; **17 trong 19 đã truyền `showDragHandle: true`** tại chỗ, chỉ hai cái thiếu (`pdf_mode_screen.dart:703` setlist jump, `setlist_editor_screen.dart:52` add-scores); tiêu đề chia **8 `titleLarge` / 14 `titleMedium`**; **7 sheet có Done**; **5 dùng `SheetBody`** (bookmarks, jump_links, display, page_scale, metronome) |
| **Chip** | **Một** chip override mật độ: `library_screen.dart:499` `InputChip` với `visualDensity: compact` + `materialTapTargetSize: shrinkWrap`. Chênh chiều cao thật trên Library là chip đó đứng cạnh `_Chip` (`library_screen.dart:1272`) — một `Container` tự viết, không phải widget Material. `draw_toolbar.dart:483` là `SegmentedButton`, không phải chip: trong 5 site `SegmentedButton` đúng một site đặt compact |

Hai điều đáng nói về danh sách này. Thứ nhất, **không có cái nào là bug** — mỗi con số đều hợp lý ở chỗ nó được viết ra, và chính vì thế nó tự sinh sôi: người viết sheet thứ hai đọc sheet thứ nhất rồi đổi một chút. Thứ hai, đây là slice **ít musician-visible nhất của cả Phase E**, và rủi ro thật của nó không phải làm sai mà là **mục ruỗng**: một file hằng số không ai bắt buộc phải dùng sẽ có một `SizedBox(height: 10)` mới ngay ở slice sau. Câu hỏi G3 số 8 là câu hỏi quyết định slice này có đáng một Spec hay không.

Roadmap đặt 0044 ngay sau 0043 vì đúng lý do đó theo hướng tích cực: E3–E7 (0045–0049) đều là slice trình bày, và mỗi cái sẽ tự phát minh lại thang khoảng cách của riêng nó nếu token chưa tồn tại.

## Kết quả (Outcome)

Musician mở hai settings sheet liền nhau và thấy **cùng một chất liệu**: cùng bo góc, cùng nền, cùng cách thoát ra, cùng nhịp khoảng trắng — kể cả hai sheet hôm nay chưa có drag handle. Màu teal trong toolbar vẽ không còn là một teal thứ hai — và nếu musician đã chọn accent màu khác ở 0026 thì toolbar vẽ **và viền chọn quanh Stamp** tôn trọng lựa chọn đó thay vì cứ teal.

Với người viết slice sau, kết quả là: thêm một hàng vào một sheet có nghĩa là **chọn một bậc có tên** (`AppSpacing.md`), không phải gõ một con số; và có một test đỏ lên nếu ai đó gõ con số.

## Trong phạm vi (In scope)

- File mới `lib/theme/app_tokens.dart`: thang khoảng cách và thang bo góc — `static const`, có tên theo bậc, không theo con số. **Không** có thang đổ bóng (câu hỏi G3 số 4b)
- `AppAppearance.themeData` (0026) nhận thêm `BottomSheetThemeData` và `ChipThemeData` — áp cho **cả** light và dark, dựng từ `ColorScheme` đã có chứ không từ màu literal
- `showDragHandle` chuyển từ 19 lối gọi vào **một** dòng theme; 17 flag cục bộ dư bị xoá, hai sheet còn thiếu handle nhận được nó (câu hỏi G3 số 5)
- **Một** màu brand teal; bốn site literal được xử lý theo đúng ý nghĩa của từng chỗ (câu hỏi G3 số 1), không phải đổi hàng loạt thành hằng số brand
- Sweep các trị số "khẩu vị" trong `lib/ui/` sang token; các trị số **đo được** giữ nguyên giá trị và được đặt tên nếu chưa có
- Một test guard ở tầng source giữ cho tầng token không mục ruỗng (câu hỏi G3 số 8)
- Cập nhật các test hiện có đang khoá hình học/màu (7 file — xem "Kế hoạch kiểm thử")

## Ngoài phạm vi (Out of scope)

- **`PopupMenuThemeData`** — bản draft có nó, vòng G3 cắt. Tám site `PopupMenuButton` và **không site nào** style cục bộ, nên không có gì đang phân kỳ để hội tụ; mặc định M3 là bán kính 4 (`popup_menu.dart:1867`), nên ghi đè thành bậc `md` là **sinh ra** kiểu thứ bảy chứ không bớt kiểu nào
- **Thang đổ bóng** — cũng bị cắt ở G3: bốn site trong toàn `lib/`, ba trong đó là phép đo của 0043 / 0034, và cái thứ tư (`jump_link_overlay.dart:131`) là 4-khi-kéo / 1-khi-không, tức đổ bóng mang **nghĩa trạng thái**. Một thang ba bậc để trị một site là thang không có việc làm
- **Mật độ chip và `SegmentedButton`, và `_Chip` tự viết** — `ChipThemeData` không có field `visualDensity` lẫn `materialTapTargetSize` nên theme không nói được câu đó (G3 số 6); bỏ override compact hoặc thay `_Chip` bằng `Chip` thật là quyết định **bố cục**, thuộc 0046 (header Library) / 0049
- **Ngữ pháp header của sheet** — Done hay không, `titleLarge` hay `titleMedium`, hàng icon+tiêu đề+mô tả phụ+control: đó là **Spec 0047 (E5)**. Spec này chỉ chốt những gì `ThemeData` diễn đạt được; header là câu hỏi widget, không phải câu hỏi theme
- **Bố cục toolbar vẽ và việc bỏ nền tint** — **Spec 0049 (E7)**. Spec này chỉ sửa *màu* mà toolbar đang tint sai, không sửa việc nó tint
- **Header Library hai hàng** — **Spec 0046 (E4)**; token vẫn được thay vào file đó, nhưng không dời hàng nào
- **Dim-scrim cho nội dung nhóm** — **Spec 0045 (E3)**
- **Thang typography** — không đụng `textTheme`. M3 đã có một thang, và sự lệch `titleLarge`/`titleMedium` hôm nay là lệch *cách dùng*, thuộc 0047
- **Bảng màu nội dung** — mực vẽ (`draw_style.dart:88-93`), màu JumpLink (`jump_link_edit_sheet.dart:19-22`), màu viền trang `0xFF424242` (0032): là dữ liệu musician chọn và đã lưu, không phải token chrome. Chỉ được **đặt tên đúng chỗ**, không đổi giá trị
- **Mọi hằng số đo được của 0043 / 0034 / 0041** — `kQuickBarGestureGap` (12), `kPageNavBarGestureGap` (20), `kQuickBarLabelGap` (2), `kPdfAppBarHeight` (64), `kQuickBarMaxSlotWidth` (96), `kPageNavBarControlsWidth` (288), `kMinScrubberWidth` (160), `kMaxStackedChromeFraction` (0.25), `kSheetMaxHeightFraction` (0.9). Một token là *khẩu vị*; những con số này là *phép đo*. 0043 đã dạy đúng bài đó khi tính tay ra 200pt và đo được 283pt
- Ghi đè những chỗ Material 3 đã có ý kiến và ý kiến đó đang đúng (bo góc 28 của bottom sheet, màu `surfaceContainer*`)
- Dependency mới, package icon mới, vendor SVG
- Localisation, SmartMode / Transport / OMR (ADR 0008)

## Câu hỏi G3 (G3 questions)

Tám câu này đã qua một vòng grilling đối chiếu source (2026-07-29). Ba câu — 1, 5, 6 — đổi khuyến nghị so với bản draft, vì tiền đề của chúng không khớp code.

| # | Câu hỏi | Khuyến nghị |
|---|---|---|
| 1 | Teal nào thắng, và literal còn sống ở đâu? | `0xFF0D8B86` là **teal brand duy nhất** (launcher, splash, adaptive icon đã ship ở giá trị đó; đổi nghĩa là làm lại asset). Bốn site literal chia làm ba loại, không phải hai: **(a) chrome** — `draw_toolbar.dart:64,137` đọc `colorScheme.primary` (`scheme` đã có sẵn ở dòng 60, nên là hai dòng sửa), và `stamp_painter.dart:42` **cũng là chrome**: nó nằm trong `if (stamp.id == selectedId)`, vẽ `rect.inflate(3)` stroke 2, tức là **viền chọn**, không phải mực — mực thật của Stamp là `stamp.color` (dòng 57, 92). Nên nó nhận màu qua constructor `StampPainter` từ `page_annotation_overlay.dart:105`, **không** đặt tên `kDefaultStampInk` (một cái tên nói sai bản chất). **(b) dữ liệu đã lưu** — `jump_link.dart:76` đã tên là `defaultJumpLinkColorValue` và đã ở ngoài brandhood; chỉ đổi literal cho khỏi trùng brand, đổi tên là churn. **(c) preset nội dung** — `display_sheet.dart:8` là swatch màu viền trang đứng cạnh đen và amber, tức đúng loại mà mục Ngoài phạm vi tự loại ra; cho nó đọc `AppAppearance.brandTealValue` là **phá ranh giới của chính Spec** và khiến brand đổi màu sẽ âm thầm đổi một preset. Giữ giá trị, đặt tên cạnh `DisplayPrefs.defaultBorderColorValue`. Chênh lệch hai giá trị là G +9, B +2 trên 255 — **không ai nhìn ra được**, đó vừa là lý do nó sống sót vừa là lý do stamp cũ vẽ lại không mất gì của musician |
| 2 | Hình thức của token? | Class `abstract final` với `static const` và **tên theo bậc** (`AppSpacing.md`), không phải `kSpace12`. Lý do: mục đích của slice là slice sau *chọn một bậc*, mà `kSpace12` vẫn là con số đội một cái tên. **Không** thêm widget `Gap` — `SizedBox(height: AppSpacing.sm)` đọc đủ rõ, thêm widget làm diff to hơn ý tưởng |
| 3 | Mấy bậc khoảng cách, và trị số lệch thang thì sao? | **Năm bậc, đúng như roadmap viết:** `xs 4 · sm 8 · md 12 · lg 16 · xl 24`. Trị số lệch thang **snap về bậc gần nhất** — nhưng theo một **luật**, không theo bảng: snap nếu nó là khẩu vị, giữ nguyên **và đặt tên** nếu một phép đo hay một metric nền tảng sinh ra nó. Ví dụ cụ thể của loại thứ hai: `88` ở ba chỗ (`setlist_editor_screen.dart:102`, `library_screen.dart:1112` và `:1212`) là khoảng chừa cho FAB (56 + 16×2) → thành `kFabScrollClearance`, không thành `AppSpacing`. Biết trước hình dạng của diff khi chốt: phần **lệch thang chỉ 11 site**, nhưng phần **đúng thang là ~180 lần thay** — nó không sửa lỗi nào, nó tồn tại để guard ở câu 8 xanh được. `0` (20 chỗ) nằm trong allowlist, không snap |
| 4 | Mấy bậc bo góc? | **Ba:** `xs 4` (clip ảnh trong tile nhỏ), `sm 8` (control, swatch, ô nhỏ), `md 12` (card, pill, toolbar nổi). Sáu giá trị hôm nay về ba: 6→8, 10→12, 14→12. **Không** ghi đè bo góc bottom sheet của M3 (28) — Material đã có ý kiến ở đó, ghi đè là cách sinh ra kiểu thứ bảy. Hai site quyết ở lúc build chứ không phải bây giờ: `beat_strip.dart:60` (14) và `page_position_pill.dart:127` (12) có thể là hình pill **đo được** của 0030 / 0041 — nếu đúng thì vào allowlist, không vào thang |
| 4b | Có thang đổ bóng không? | **Không** — cắt ở G3. Bốn site trong toàn `lib/`, ba là phép đo của 0043 / 0034, site thứ tư là 4-khi-kéo / 1-khi-không tức đổ bóng mang **nghĩa trạng thái**. Không có gì đang phân kỳ để hội tụ |
| 5 | `BottomSheetThemeData` có bật drag handle cho cả 19 sheet? | **Có, nhưng đây không còn là câu tải trọng.** Tiền đề của bản draft sai: **17 trong 19 sheet đã có handle** từ trước (committed trước cả lần rename StandScore→StageScore), nên "11 sheet không có đường ra nào ngoài một cú swipe chưa quảng cáo" là mô tả một app khác. Việc thật: đưa `showDragHandle: true` vào theme (`bottom_sheet.dart:362` resolve `widget.showDragHandle ?? (enableDrag && theme.showDragHandle ?? false)`), **xoá 17 flag cục bộ dư**, và hai sheet còn thiếu nhận được handle. Cả hai để `enableDrag` mặc định nên không vướng assert. Rủi ro "dôi khoảng trắng thứ hai" cũng biến mất: năm sheet `SheetBody` đã sống chung với handle từ lâu |
| 6 | `ChipThemeData` chốt cái gì? | Chốt **hình, không chốt được mật độ**: `chip_theme.dart` trong SDK có 26 field và **không có** `visualDensity` lẫn `materialTapTargetSize` — chúng là tham số widget. Nên khuyến nghị draft ("ba nơi bỏ được override") không thực thi được, và cũng chỉ có **một** chip override (`library_screen.dart:499`) chứ không phải ba: `draw_toolbar.dart:483` là `SegmentedButton`. Chênh chiều cao thật trên Library là `InputChip` compact đứng cạnh `_Chip` — một `Container` tự viết ở dòng 1272 mà **không theme nào chạm tới**. Vậy: theme chốt `shape` bậc `sm` + `padding`/`labelPadding`; việc một-chiều-cao là quyết định bố cục, để 0046 / 0049. **Không** chốt `showCheckmark` / `avatar` — hai thứ đó mang nghĩa riêng của từng chỗ (swatch màu của JumpLink, icon tool của Draw). Nếu muốn một component theme thứ ba đúng nghĩa "chỗ đang phân kỳ", ứng viên là `SegmentedButtonThemeData`: 5 site, đúng một site compact |
| 7 | Sweep rộng tới đâu? | **Chỉ `lib/ui/`** (17 file) cộng bốn màu literal ở câu 1. `lib/pdf/`, `lib/annotation/`, `lib/layout/` giữ nguyên: số của chúng là hình học trang và mực vẽ, không phải chrome, và trộn hai loại vào một thang là cách token mất nghĩa ngay ở slice đầu. Ngoại lệ duy nhất là `stamp_painter.dart:42` — nó ở `lib/annotation/` nhưng là chrome, và câu 1 đã nêu tên nó |
| 8 | **Lấy gì giữ cho tầng token không mục ruỗng?** | Một **test guard ở tầng source**, đúng idiom test brand của 0042 (`test/brand_reach_test.dart`): quét `lib/ui/*.dart` tìm literal số trong `EdgeInsets.*`, `SizedBox(width:/height:)`, `BorderRadius.circular(` và đỏ lên với bất cứ giá trị nào không thuộc tập token hoặc allowlist hằng-số-đo-được. Đây vẫn là câu tải trọng nhất: **không có nó, 0044 là một file hằng số không ai bắt buộc dùng**. Nhưng gọi nó đúng tên — nó là một **ratchet, không phải bằng chứng**: bốn pattern trong một thư mục không chặn `Positioned(left: 10)`, `Container(margin:)`, `SizedBox.square(dimension:)`, hay `EdgeInsets.only(bottom: 88 + inset)`. Ba điều kiện để nó không thành nguồn nhiễu: allowlist chứa `0`; regex chịu được `EdgeInsets` nhiều dòng; mỗi entry allowlist ghi tên Spec sinh ra nó. Repo không có CI nên nó chỉ chạy khi ai đó chạy `flutter test` — chấp nhận được, nhưng đừng gọi là "bắt buộc" |

## Thuật ngữ miền (Domain terms)

**Không có thuật ngữ miền mới, và `CONTEXT.md` không đổi.** Design token là chi tiết thực thi, mà `AGENTS.md` cấm đưa chi tiết thực thi vào `CONTEXT.md`. Nếu cần một chỗ ghi lại thang bậc cho người viết code đọc, chỗ đó là `docs/engineering/` (tiếng Anh, theo ADR 0015), không phải `CONTEXT.md`.

Thuật ngữ đã có mà Spec này dùng: **PdfMode**, **ScoreMenu**, **Stamp**, **JumpLink**, **PageTurn**, **PerformanceMode**.

## Tiêu chí chấp nhận (Acceptance criteria)

Checklist kiểm thử được (G4):

- [ ] `grep 0D9488` trong `stagescore/lib/` không còn kết quả nào
- [ ] Teal brand chỉ định nghĩa **một lần trong Dart** (`AppAppearance.brandTealValue`); ba resource Android (`values/colors.xml`, `values-v31/styles.xml`, `values-night-v31/styles.xml`) không đọc được Dart nên chúng được **ghi chú là bản sao phải sửa cùng lúc**, không phải bị xoá
- [ ] Chọn accent **không phải teal** ở Appearance rồi vào draw mode: toolbar vẽ theo accent đã chọn, và viền chọn quanh một Stamp cũng vậy — không còn teal cứng
- [ ] Stamp và JumpLink cũ (đã lưu trước bản này) vẫn vẽ ra đúng như trước, không mất màu, không đổi vị trí; preset màu viền trang trong Display giữ **đúng bốn** swatch với đúng giá trị cũ
- [ ] Mở lần lượt Metronome → Display → Page scale → Bookmarks → Layout → Page turn trong **một** lần chạy: cùng bo góc, cùng nền, cùng drag handle, cùng nhịp khoảng trắng
- [ ] Không lối gọi `showModalBottomSheet` nào còn truyền `showDragHandle` tại chỗ (theme sở hữu nó), và hai sheet trước đây thiếu handle — setlist jump, add-scores — giờ có; năm sheet `SheetBody` không dôi ra khoảng trắng thứ hai ở đỉnh
- [ ] `lib/ui/` không còn literal số trong `EdgeInsets` / `SizedBox` / `BorderRadius.circular` ngoài allowlist hằng-số-đo-được; test guard đỏ lên khi cố tình thêm một cái
- [ ] Mọi hằng số đo được của 0043 / 0034 / 0041 giữ **đúng giá trị cũ**; `quick_bar_fit_test.dart`, `pdf_mode_chrome_layout_test.dart`, `score_menu_quick_bar_test.dart` xanh mà **không phải sửa con số nào**
- [ ] Đúng ở cả theme sáng và tối (0026), và ở text scale 200% — không widget nào nhận một chiều cao cố định mà trước đây nó không có
- [ ] Không thêm dependency; `flutter analyze` sạch; toàn bộ test xanh
- [ ] Không có hàng, nút, hay sheet nào **dời chỗ** quá một bậc thang so với bản trước — slice này đổi chất liệu, không đổi bố cục

## Ghi chú UX (UX notes)

Ranh giới của slice này dễ vượt qua mà không nhận ra, nên nói thẳng theo hai hướng:

**Musician nên thấy khác:** một handle để kéo xuống ở hai sheet trước đây không có; một teal duy nhất; accent mình chọn được tôn trọng cả trong draw mode và ở viền chọn quanh Stamp. Danh sách này ngắn hơn bản draft đúng một mục (chiều cao chip) vì `ThemeData` không nói được câu đó — xem câu hỏi G3 số 6.

**Musician không nên thấy khác:** không sheet nào cao hơn hay thấp hơn trước; không nút nào dời chỗ đáng kể; không hàng nào biến mất hay xuất hiện; PageTurn vẫn tap đúng vùng cũ; chrome đáy của 0043 giữ nguyên hình học đã đo. Nếu một thay đổi token làm bố cục đổi rõ, đó là dấu hiệu đã lấn vào 0046 / 0047 / 0049 — dừng lại và hỏi.

## Ràng buộc kỹ thuật (Technical constraints)

- Token là `static const` trong một file, không `InheritedWidget`, không lookup runtime — `ThemeData` đã là thứ được thừa hưởng qua cây widget rồi; thêm một cơ chế thừa hưởng thứ hai là hai nguồn chân lý
- Component theme dựng từ `ColorScheme` của chính brightness đang chạy, **không** từ màu literal — nếu không thì dark mode (0026) lại trở thành một tập màu viết tay thứ hai
- Không ghi đè mặc định M3 khi mặc định đó đang đúng; danh sách ghi đè phải ngắn và mỗi dòng phải trả lời được "hôm nay nó lệch ở đâu". Ràng buộc này đã tự cắt bớt phạm vi một lần ở G3: `PopupMenuThemeData` bị bỏ vì tám site popup menu **không site nào** style cục bộ, nên chẳng có gì lệch để hội tụ — thêm nó vào chỉ là dời tất cả ra khỏi mặc định M3 cùng một lúc
- Một component theme chỉ được thêm khi có bằng chứng đếm được rằng các site đang phân kỳ, **và** khi `ThemeData` thật sự có field diễn đạt được điều đó — `ChipThemeData` không có `visualDensity` là ví dụ cho nửa sau
- Hằng số đo được **không** bị token hấp thụ, kể cả khi trị số trùng một bậc: `kQuickBarGestureGap` bằng 12 là ngẫu nhiên, và biến nó thành `AppSpacing.md` sẽ khiến một lần chỉnh thang khoảng cách âm thầm đổi khoảng đệm chống-cử-chỉ-OS
- Test guard đọc source ở tầng chuỗi, đúng vì sao 0042 phải làm vậy: `PdfModeScreen` không pump được (pdfrx), nên một invariant toàn `lib/ui/` không thể diễn đạt bằng widget test
- `SheetBody` (0030/0035) vẫn là chủ của cap 90% và việc cuộn — Spec này không dời trách nhiệm đó vào theme, vì `BottomSheetThemeData.constraints` không biết gì về `viewInsets` của bàn phím

## Kế hoạch kiểm thử (Test plan)

- **Automated:**
  - `test/app_tokens_test.dart` (mới) — hai thang tăng đơn điệu, không bậc trùng; `themeData` ở **cả hai** brightness có mặt `BottomSheetThemeData` (với `showDragHandle: true`) và `ChipThemeData`, màu lấy từ `ColorScheme` (khoá bằng cách dựng theme với một seed **không** phải teal rồi khẳng định không có màu teal nào trong đó)
  - `test/design_token_guard_test.dart` (mới) — quét source `lib/ui/`, allowlist hằng-số-đo-được nêu tên từng cái kèm Spec sinh ra nó, nên thêm một ngoại lệ mới là một hành động có chủ ý và đọc được trong diff. Test này cũng khẳng định không lối gọi `showModalBottomSheet` nào truyền `showDragHandle` tại chỗ
  - `test/app_appearance_prefs_test.dart` (sửa) — thêm khẳng định teal brand có **một** nguồn trong Dart
  - Chạy lại và sửa nếu cần **7** file đang khoá hình học/màu: `annotation_export_test.dart`, `annotation_store_test.dart`, `draw_style_test.dart`, `page_color_filter_test.dart`, `pdf_mode_chrome_layout_test.dart`, `pdf_surface_test.dart`, `quick_bar_fit_test.dart`. Luật cho chúng: test khoá một **phép đo** thì giữ nguyên con số (nếu nó đỏ, slice này đã sai); test khoá một con số **khẩu vị** thì đổi sang tên token, và nếu giá trị dịch một bậc thì đổi có chủ ý, ghi vào Build notes
- **Manual demo:** trên thiết bị thật — mở sáu sheet liền nhau ở theme sáng rồi theme tối; kéo một sheet xuống bằng handle; chọn accent tím rồi vào draw mode; mở một Score có Stamp và JumpLink cũ; đặt text scale 200% và mở lại ba sheet; xoay máy để xác nhận chrome đáy của 0043 không nhúc nhích

## Ghi chú build (Build notes)

**361 test xanh** (349 trước + 12 mới: 8 cho thang và component theme, 3 cho guard, 1 cho một nguồn teal), `flutter analyze` sạch, và **không một file test cũ nào phải sửa** — kể cả `pdf_mode_chrome_layout_test.dart` và `quick_bar_fit_test.dart`, đúng tiêu chí "xanh mà không phải sửa con số nào". Hệ quả đáng ghi: bảy file "khoá hình học/màu" trong Kế hoạch kiểm thử hoá ra không khoá con số nào mà slice này chạm tới, nên phần "sửa nếu cần" của kế hoạch đó không dùng đến.

**Guard đỏ ngay ở chính slice sinh ra nó, và đó là bằng chứng sớm nhất cho việc nó đáng có.** Nó tìm ra **ba** site mà cả kiểm kê subagent lẫn vòng grilling G3 đều bỏ sót, vì cả hai dùng grep một dòng còn `EdgeInsets` thật thì trải nhiều dòng: `page_position_pill.dart` (`vertical: 6`), và trong `draw_toolbar.dart` một `SizedBox(width: 196)` cùng một `SizedBox(width: 22, height: 22)`. Xử lý theo đúng luật của câu 3: cái đầu là khẩu vị nên snap; hai cái sau là **phép đo** nên được đặt tên — `_colorPaletteWidth` (bảng màu rộng vừa đủ số swatch mỗi hàng) và `_widthDotExtent` (ô vuông chứa dot lớn nhất mà hàng đó vẽ). Đặt tên `_colorPaletteWidth` cũng lộ ra một bản sao ngầm: `clamp(12.0, size.width - 220)` cách đó 20 dòng chính là `196 + 12 × 2` viết lại bằng tay, nay tính từ hằng số.

**Luật snap khi hai bậc cách đều: snap xuống**, để không hàng nào nở ra và không sheet nào cao thêm (10→8 ở draw toolbar và Metronome, 20→16 ở Appearance và Page scale, 6→4 ở Page turn và pill vị trí trang). Bo góc thì theo đúng bảng Spec đã chốt (6→8, 10→12, 14→12), nên có chỗ số 6 của *khoảng cách* xuống 4 trong khi số 6 của *bo góc* lên 8 — khác nhau có chủ ý, vì một cái là bảng Spec, một cái là luật.

**Ba lệch so với Spec, cần Orchestrator biết ở G4:**

1. **`ChipThemeData` hoá ra trùng đúng mặc định Material 3** — `_ChipDefaultsM3` đã là `shape` bán kính 8 và `padding: EdgeInsets.all(8)`. Nên nó được viết dưới dạng **ghim vào thang** (đọc `AppRadius.sm` / `AppSpacing.sm`) chứ không phải ghi đè một ý kiến khác: chip không đổi hình hôm nay, nhưng theo thang nếu thang được chỉnh. Nếu Orchestrator muốn giữ luật "không ghi đè M3 khi mặc định đang đúng" một cách tuyệt đối thì hai dòng đó xoá được mà không mất gì ngoài mối liên kết ấy — cùng lý do đã cắt `PopupMenuThemeData` ở G3.
2. **Thêm `clipBehavior: Clip.antiAlias` vào `BottomSheetThemeData`** — không có trong Spec. Lý do nó thuộc về đây: mục Vấn đề đếm "19 lối vào, không cái nào truyền `shape`, `backgroundColor` **hay `clipBehavior`**", và không có nó thì một danh sách cuộn vẫn vẽ tràn qua đúng góc bo 28 mà slice này vừa quyết định không đụng tới. Đây là nửa còn lại của "cùng một chất liệu", không phải một tính năng mới.
3. **`defaultJumpLinkColorValue` đổi `0xCC0D9488` → `0xCC0D8B86`** — JumpLink **mới** tạo sau bản này lệch 9/255 xanh so với link cũ; link cũ giữ nguyên màu đã lưu, đúng tiêu chí chấp nhận. Nếu muốn dữ liệu tuyệt đối không còn hai giá trị thì đó là một migration trên dữ liệu musician, không phải việc của một slice token.

**Hai chỗ số được allowlist trong guard**, mỗi chỗ kèm lý do và Spec sở hữu nó: `library_screen.dart` giá trị 2 (đệm dọc giữ nhãn cao ngang `InputChip` compact — `_Chip` thuộc 0046) và `draw_toolbar.dart` giá trị 2 (khe icon–nhãn, cùng phép đo với `kQuickBarLabelGap` của 0043 — bố cục toolbar thuộc 0049). Guard cũng đã được thử đỏ có chủ ý: thêm `SizedBox(height: 10)` vào `about_sheet.dart` làm nó đỏ đúng dòng đó, rồi revert.

**Phần guard không che, cố ý:** `Wrap(spacing:)`, `Icon(size:)`, `Positioned`, `Container(margin:)` — ví dụ còn literal thật là `Wrap(spacing: 10)` trong draw toolbar và `Wrap(spacing: 6, runSpacing: 4)` ở Library. `elevation:` cũng bị bỏ khỏi bốn spelling của guard, vì câu 4b đã cắt thang đổ bóng nên không có tập giá trị nào để so. Đây đúng là "ratchet, không phải bằng chứng" mà câu 8 đã nói trước.

**`docs/engineering/` không được tạo:** thang bậc đã có doc comment ngay trong `app_tokens.dart`, và hai bản của một tài liệu là điều `AGENTS.md` cấm. `CONTEXT.md` không đổi, đúng như mục Thuật ngữ miền.
