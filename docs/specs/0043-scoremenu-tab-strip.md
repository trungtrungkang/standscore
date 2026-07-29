# 0043 — ScoreMenuQuickBar đo theo màn hình, dưới PageNavBar; `⋯` giữ nguyên

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0034 (done — cơ chế ẩn/hiện chrome, tự ẩn và pin, không đổi); 0035 (done — sheet `⋯` bốn nhóm **Go to / Marks / View / Playing** và thành viên mỗi nhóm giữ nguyên, không đổi); 0036 (done — sở hữu mục stage-preset trong nhóm Playing); 0009 (done — sở hữu `PageNavBar`, cộng thêm layout mới ở Revision 2)
- **Parity IDs:** Q10 (roadmap Phase E, hạng mục E1)
- **G3:** accepted (2026-07-29), **revised ba lần cùng ngày** (Orchestrator) — hình dạng đang có hiệu lực là "Revision 3" ngay dưới; Revision 1 và 2 giữ lại làm lịch sử
- **G3 notes:** Bản duyệt đầu (sáu khuyến nghị) bị đảo lại bởi Revision 1 (i18n), Revision 1 bị thay bởi Revision 2 (tab-strip icon-only trở lại), và Revision 2 bị thay bởi **Revision 3** — lần đầu tiên hàng này có một *luật chọn* cho thành viên và một *phép đo* cho hình dạng, thay vì cả hai đều là khẩu vị. Lịch sử đầy đủ ở cuối file.
- **G4:** pass (2026-07-29, SM X210 / Android 16, 800×1280 dp)
- **G4 notes:** Demo trên tablet dọc. Hai ca mà thiết bị đó *không* chứng minh được, nên chúng dựa vào phép đo trong widget test chứ không phải mắt người: **điện thoại nằm ngang gộp quick-bar vào hàng thanh trượt**, và **nhãn chữ tự rơi về icon-only** khi không vừa — phông của môi trường test vẽ mỗi ký tự rộng đúng một em, nên `quickBarLabelsFit` được khoá bằng số đo chứ không bằng ảnh chụp. Nếu sau này có điện thoại nằm ngang trong tay thì hai dòng đó đáng xem lại bằng mắt.

## Revision 3 — 2026-07-29 (Orchestrator, hình dạng đang có hiệu lực)

Orchestrator xem lại bản Revision 2 trước G4 với hai câu hỏi: các item trên hàng đó vẫn chưa ổn, và các màn hình to nhỏ khác nhau thì thế nào. Đợt audit trả lời cả hai bằng phép đo (harness dùng-một-lần, đã xoá), và tìm thêm một lỗi thật.

**Chẩn đoán 1 — hàng đó chưa từng có luật chọn.** Ba revision trong một ngày đều đổi *danh sách* bằng khẩu vị (bốn nhóm 0035 → chỉ View → View + Bookmarks + Layout + Draw + Metronome), nên revision thứ tư cũng sẽ lại là khẩu vị. Bốn hệ quả cụ thể của việc không có luật:

- **View là một *nhóm* đứng cạnh bốn *action*, và Layout — con của chính nhóm View — cũng nằm trên cùng hàng.** Một sheet có hai lối vào ở hai độ sâu, cạnh nhau.
- **Icon View trùng glyph với "annotations đang hiện"**: `kViewGroupIcon` và `kAnnotationsVisibleIcon` đều là `Icons.visibility_outlined`. Cùng con mắt, hai nghĩa, một màn hình.
- **Metronome hiện/ẩn theo trạng thái làm cả hàng reflow.** Đo trên iPhone 15 dọc: khi metronome bật, Draw nhảy từ x=64 sang x=124 (hơn một bề rộng icon), Bookmarks 152→198, Layout 240→272, View 328→346 — hàng xê dịch đúng lúc đang chơi. Và không thể *bật* metronome từ hàng đó: lối tắt chỉ xuất hiện sau khi đã bật bằng đường khác.
- **Layout là action lúc mở bài, không phải giữa bài.**

**Chẩn đoán 2 — Spec chỉ ràng buộc chiều rộng, nhưng chỗ vỡ là chiều cao.** Số đo, chrome đáy `PageNavBar` + quick-bar xếp chồng:

| Máy | Chrome đáy | Chrome tổng | Viewer còn lại | Khoảng cách tâm icon |
|---|---|---|---|---|
| iPhone SE dọc (375×667) | 128 | 212 (32%) | 455 | 85 |
| iPhone 15 dọc (393×852) | 162 | 273 (32%) | 579 | 88 |
| **iPhone 15 ngang (852×393)** | 149 | **213 (54%)** | **180** | 156 |
| iPad mini dọc (744×1133) | 148 | 236 (21%) | 897 | 158 |
| iPad Pro ngang (1366×1024) | 148 | 236 (23%) | 788 | **283** |

Một hình dạng cố định sai ở cả hai đầu: điện thoại nằm ngang mất hơn nửa chiều cao cho chrome, trong khi iPad ngang rải bốn icon cách nhau 283pt trên một dải gần trống. Kèm 20pt mất trắng — `PageNavBar` vẫn giữ `kPageNavBarGestureGap` dù không còn chạm mép máy, tức khoảng đệm chống-cử-chỉ-OS nằm giữa hai hàng chrome.

**Lỗi thật (không phải chuyện khẩu vị).** `bottomChrome = pageNav == null ? null : …` khiến cả quick-bar biến mất khi `!_prefsReady || _pageCount == 0` — kể cả Draw, thứ mà 0035 quyết định 6 cố ý *không* đưa vào `⋯`, nên Draw mất lối vào duy nhất. Và `_switchToPiece` đặt `_prefsReady = false`, nên **mỗi lần đổi bài trong Setlist là 162pt chrome sụp rồi mọc lại**.

Bốn quyết định chốt trước khi build:

| # | Câu hỏi | Chốt |
|---|----------|------|
| 1 | Luật chọn cho hàng chrome đáy? | **"Tay đang trên nhạc cụ"** — chỉ action cần *giữa bài*: **Bookmarks, Draw, Metronome** (3 slot cố định, theo thứ tự nhóm của `⋯`: Go to → Marks → Playing). Layout và View về lại `⋯` |
| 2 | Hình dạng theo kích thước? | Một **hàm thuần đo được** `QuickBarFit` (cùng idiom `LayoutFit` của 0041): màn hình thấp → icon gộp vào chính hàng `PageNavBar`; màn hình cao → hai hàng; màn hình rộng → slot giới hạn bề rộng và cả nhóm căn giữa |
| 3 | Slot Metronome? | **Luôn hiện**, chạm được cả khi chưa chạy để *bật* nó; trạng thái nói bằng màu (tint `primary` khi chạy, đậm hơn ở phách accent) |
| 4 | Nhãn chữ dưới icon? | **Chỉ hiện khi phép đo thấy vừa** — `quickBarLabelsFit` cân đúng những chữ sắp vẽ ở đúng text scale musician chọn, nên bản dịch dài hay text 200% tự rơi về icon-only thay vì vỡ layout |

Quyết định 4 là cách Spec này thôi tranh luận về nhãn: Revision 1 bỏ nhãn vì *chính sách*, Revision 2 chọn icon-only vì *chính sách*, nhưng cả hai đều là một luật cứng cho một câu hỏi phụ thuộc vào chữ và màn hình cụ thể. Lý lẽ i18n của Revision 1 cũng đã bị code đang ship phản bác: `DrawToolbar` có sáu nhãn tiếng Anh trong một hàng cố định.

**Hình dạng cuối cùng (Revision 3):**

- `⋯` trên AppBar không đổi — vẫn đủ bốn nhóm, 12 action, mỗi dòng một icon.
- `ScoreMenuQuickBar` giờ mang **3 lối tắt**: Bookmarks, Draw, Metronome. `kViewGroupIcon` bị xoá khỏi `score_menu.dart` cùng `_openViewMenu` trong `pdf_mode_screen.dart`.
- File mới `lib/ui/quick_bar_fit.dart`: `QuickBarFit` (`mergeIntoPageNav`, `slotWidth`, `contentWidth`) cộng `quickBarLabelsFit`. Hằng số hình học của bar chuyển sang đây và đổi tên gọn: `kScoreMenuQuickBarHeight` → `kQuickBarHeight`, `kScoreMenuQuickBarGestureGap` → `kQuickBarGestureGap`.
- Ngưỡng gộp là **hai điều kiện, cùng một trade**: chrome xếp chồng không được vượt `kMaxStackedChromeFraction` (25%) chiều cao màn hình, *và* hàng gộp phải còn để lại thanh trượt ít nhất `kMinScrubberWidth` (160pt). Điện thoại ngang thoả cả hai (còn 420pt cho thanh trượt) nên gộp; điện thoại dọc trượt điều kiện thứ hai nên vẫn hai hàng; màn hình vừa thấp vừa hẹp (split-screen) chấp nhận trả giá chiều cao để giữ thanh trượt dùng được.
- `PageNavBar` nhận thêm `trailing` (chỗ cho icon khi gộp) và `bottomGestureGap` (bỏ 20pt mồ côi khi có bar khác nằm dưới). Bar nào chạm đáy thì bar đó giữ inset home-indicator và gesture gap.
- Slot giới hạn ở `kQuickBarMaxSlotWidth` (96pt) và cả nhóm căn giữa, nên khoảng cách icon giống nhau trên điện thoại và tablet.
- Quick-bar **không còn phụ thuộc vào `PageNavBar`**: khi prefs chưa về nó vẫn ở đúng chỗ, chỉ `enabled: false` (xám) giống `⋯`.

Kết quả đo lại trên điện thoại nằm ngang: viewer từ **180pt lên 240pt** (61% chiều cao thay vì 46%), chrome đáy còn một hàng.

## Revision 2 — 2026-07-29 (Orchestrator, tab-strip icon-only trở lại) — bị thay bởi Revision 3

Revision 1 (ngay dưới) đã rút hẳn về một icon `⋯` cộng một icon-tắt **View** không nhãn trên AppBar. Ngay sau khi bản đó build xanh, Orchestrator yêu cầu tiếp: Draw và các menu item khác nên hiện dạng **tab-strip ngay dưới `PageNavBar`**, không gom vào một icon "con mắt" duy nhất — tức quay lại ý tưởng tab-strip ban đầu, nhưng lần này mỗi mục là **icon thuần, không chữ**, nên không còn mang rủi ro dịch-vỡ-layout mà Revision 1 dùng để đảo bản đầu. Ba quyết định chốt trước khi build (hỏi trực tiếp, không đoán):

| # | Câu hỏi | Chốt |
|---|----------|------|
| 1 | Tab-strip gồm gì? | 3 icon cũ (Metronome khi đang chạy, Draw, View) **cộng** Bookmarks và Layout — 5 icon-tắt cho các action hay dùng khi đang chơi |
| 2 | `⋯` còn không, và có ẩn mục đã lên tab-strip? | `⋯` giữ nguyên, vẫn liệt kê đủ cả 4 nhóm/12 action — kể cả những action đã có icon-tắt riêng (giống cách Metronome/View đã làm trước Revision này) |
| 3 | Icon lấy từ đâu? | Material Symbols có sẵn trong Flutter (`Icons.*`) — một trong các bộ opensvg.dev liệt kê, không thêm dependency, không tốn phí |

**Hình dạng cuối cùng** (đã build, thay cho Revision 1):

- AppBar chỉ còn `⋯` — Draw, Metronome, View không còn ở AppBar.
- Widget mới `ScoreMenuQuickBar` (`lib/ui/score_menu_quick_bar.dart`) là một hàng icon-only, cao `kScoreMenuQuickBarHeight` (= `kMinInteractiveDimension`, 48), nằm ngay dưới `PageNavBar` — cả hai đi cùng nhau thành một khối `bottomChrome` (`Column([pageNav, quickBar])`), dùng chung cho cả slot `bottomNavigationBar` của Scaffold và overlay nổi trong PerformanceMode.
- Nội dung `ScoreMenuQuickBar`, theo đúng thứ tự: Metronome (chỉ hiện khi đang chạy, dùng lại `MetronomeIcon`), Draw (dùng lại `DrawIcon`), Bookmarks (`kBookmarksIcon`), Layout (`kLayoutIcon`), View (`kViewGroupIcon`) — Bookmarks/Layout gọi thẳng `_onScoreMenuSelected`, bỏ qua sheet; View vẫn mở sheet nhóm View như trước.
- `PageNavBar.avoidNotches` đổi thành `false` — quick-bar giờ là chrome thấp nhất, nó nhận inset home-indicator thay cho `PageNavBar`.
- Mọi entry của `ScoreMenu` (`ScoreMenuEntry`) giờ có một `icon` bắt buộc, hiện ra như `leading` của `ListTile` trong sheet `⋯` — kể cả những action không có icon-tắt riêng (Jump Links, Page order…, Hide/Show annotations, Export, Display…, Color filter…, Page scale…, Page turn settings, Stage preset). Bảng icon đầy đủ ở "Ghi chú UX" dưới đây.
- `GestureMap`'s `showChrome` không đổi — vẫn mở `⋯` (đủ bốn nhóm) khi chrome đã hiện, như Revision 1 đã chốt.

### Sửa trước G4 (2026-07-29, cùng ngày build Revision 2)

Orchestrator thấy hai vấn đề khi xem lại bản build, cả hai đều sửa tại chỗ, không đổi hình dạng đã chốt ở trên:

1. **Icon Metronome trong sheet `⋯` không hợp lý** — `kMetronomeIcon` (`Icons.speed_outlined`, một glyph Material chung) không giống cây metronome thật. Sửa: dòng Metronome trong `score_menu_sheet.dart` giờ vẽ đúng `MetronomeIcon` (glyph riêng của app, cùng file `assets/icons/metronome.png` mà quick-bar đã dùng) thay vì `entry.icon`. `kMetronomeIcon` vẫn tồn tại trong model — chỉ còn ý nghĩa là một fallback chung, không còn được vẽ ra ở đâu — vì mọi entry vẫn cần một `IconData` hợp lệ để compile.
2. **Vùng `ScoreMenuQuickBar` sát mép quá, đụng vùng điều khiển của OS** — quick-bar chỉ có `SafeArea` (theo inset OS báo qua `MediaQuery.padding`) mà không có khoảng đệm dôi ra, trong khi `PageNavBar` bên trên nó đã luôn có `kPageNavBarGestureGap` (20px) từ Spec 0034 chính vì lý do này: `MediaQuery.padding` báo một inset mỏng hơn vùng ngón tay cần né trên nhiều máy Android cử chỉ. Orchestrator đề xuất bọc SafeArea cho **toàn bộ app** — bị từ chối có lý do: PdfMode có thiết kế edge-to-edge *cố ý* khi PerformanceMode đang hiện (test `PerformanceMode viewer keeps its size when chrome hides` khoá đúng hành vi "runs to the bottom edge so PageTurn taps land there") — bọc SafeArea toàn app sẽ phá chính thiết kế đó. Sửa đúng chỗ: thêm hằng số mới `kScoreMenuQuickBarGestureGap` (12px, không điều kiện — giống cách `kPageNavBarGestureGap` áp dụng bất kể `avoidNotches`) làm đệm dưới hàng icon, bên trong `SafeArea` của `ScoreMenuQuickBar`.

`test/pdf_mode_chrome_layout_test.dart` cập nhật công thức khoảng cách slider–đáy màn hình cho khớp đệm mới. 285 tests vẫn xanh, analyze sạch.

## Revision 2026-07-29 (Orchestrator, trước G4) — bị thay bởi Revision 2

Bản đầu của Spec này (build xong, 285 tests xanh, chưa qua G4) thay hẳn icon `⋯` bằng một tab-strip có nhãn cố định cho cả bốn nhóm — xem lịch sử ở cuối file. Orchestrator xem lại và đảo quyết định **trước khi demo trên thiết bị**, với lý do cụ thể: nhãn tab-strip (`Go to`, `Marks`, `View`, `Playing`) là chữ tiếng Anh cố định trong một hàng phải vừa bốn tab trên chiều rộng điện thoại nhỏ nhất được hỗ trợ; app hiện English-only (0042 đã ghi nhận khoảng cách này), nhưng khi có bản dịch, một từ dài hơn ở ngôn ngữ khác làm vỡ layout ngay — không phải rủi ro giả định, mà là hệ quả trực tiếp của việc đặt chữ cố định vào một hàng có ngân sách chiều rộng cố định.

**Hình dạng bản này** (đã bị Revision 2 thay, giữ lại để biết lý do): `⋯` giữ nguyên trên AppBar; nhóm **View** có thêm một `IconButton` chỉ icon, không nhãn, ngay trên AppBar cạnh Draw; ba nhóm còn lại không có lối tắt riêng.

Tab-strip, enum `ScoreMenuTab`, và widget `ScoreMenuTabStrip` của bản đầu bị xoá khỏi code ở Revision này. Icon-tắt View không nhãn của Revision này, đến lượt nó, bị Revision 2 dời xuống `ScoreMenuQuickBar`.

## Vấn đề (Problem)

Spec 0035 đã biến 11 mục phẳng của `⋯` trong PdfMode thành bốn nhóm có tên (**Go to · Marks · View · Playing**) nằm trong một sheet — một cải tiến thật, và đến nay vẫn `done`, thành viên mỗi nhóm vẫn đúng. Nhưng *lối vào* vẫn chỉ là một icon `⋯` vô danh trên AppBar. Nhạc công chưa từng mở nó thì không có cách nào biết có bốn nhóm, hay chúng tên gì, cho tới khi chạm vào icon duy nhất đó và đọc.

Một buổi so sánh trực tiếp với ScorePDF (`DECISIONS-LOG.md`, 2026-07-28 — ảnh chụp thật từ máy, không phải ảnh marketing) cho thấy ScorePDF giữ đúng cấu trúc phân loại đó **luôn hiển thị**: một tab-strip ở đáy màn hình nằm ngay dưới thanh trượt trang, bất cứ khi nào chrome đang hiện. Bản đầu của Spec này định sao chép bố cục đó bằng chữ có nhãn — Revision 1 đảo lại vì rủi ro dịch-vỡ-layout, Revision 2 đưa tab-strip trở lại dưới dạng icon thuần.

Revision 3 đặt lại vấn đề một lần nữa, ở một tầng khác: hai revision đầu tranh luận *cái gì nằm trên hàng đó* và *có nhãn hay không* như hai câu hỏi khẩu vị, trong khi cả hai đều có câu trả lời đo được. Và câu hỏi mà cả ba bản đều chưa đặt là **màn hình nào** — một hàng cố định 48pt cộng thêm vào ngân sách chrome vừa quá đắt trên điện thoại nằm ngang (chrome chiếm 54% chiều cao) vừa quá thưa trên tablet (icon cách nhau 283pt).

## Kết quả (Outcome)

`⋯` trên AppBar không đổi so với trước Spec này — vẫn mở sheet bốn nhóm của 0035, đủ cả 12 action, giờ mỗi action có thêm một icon riêng đứng trước tên. Trong chrome đáy, một `ScoreMenuQuickBar` mới mang **ba lối tắt** cho đúng những action cần khi tay đang trên nhạc cụ (Bookmarks, Draw, Metronome), mỗi cái gọi thẳng hành động đã có. Hình dạng của hàng đó — xếp chồng hay gộp vào hàng thanh trượt, có nhãn chữ hay không — do `QuickBarFit` đo trên từng màn hình mà quyết định, chứ không phải một hằng số chọn một lần cho mọi máy.

## Trong phạm vi (In scope)

- Widget mới `ScoreMenuQuickBar` (`lib/ui/score_menu_quick_bar.dart`): ba lối tắt trong chrome đáy, hiện khi chrome hiện, ẩn/mờ cùng nhịp với `PageNavBar`
- File mới `lib/ui/quick_bar_fit.dart`: `QuickBarFit` (xếp chồng hay gộp, bề rộng slot) và `quickBarLabelsFit` (nhãn có vừa hay không) — thuần, không state, không lưu gì
- `ScoreMenuEntry` có thêm trường `icon` bắt buộc; `buildScoreMenu` (0035) gán icon cho cả 12 action; `score_menu_sheet.dart` hiện icon đó làm `leading` của mỗi `ListTile`
- Gỡ Draw/Metronome/Bookmarks khỏi AppBar, chuyển xuống `ScoreMenuQuickBar`; AppBar chỉ còn `⋯`
- `PageNavBar` nhận thêm `trailing` và `bottomGestureGap`; bar nào chạm đáy màn hình thì giữ inset home-indicator và gesture gap
- Vòng đời quick-bar tách khỏi `PageNavBar` (sửa lỗi Draw mất lối vào, và chrome sụp khi đổi bài Setlist)
- Cập nhật mục **ScoreMenu** trong `CONTEXT.md` cho khớp — bắt buộc ở G1 theo luật vệ sinh tài liệu của `AGENTS.md`

## Ngoài phạm vi (Out of scope)

- Mọi thay đổi về *nội dung* bốn nhóm — không thêm, bớt, đổi tên, hay sắp lại thứ tự mục nào trong một nhóm (vẫn thuộc về 0035)
- Lối tắt riêng cho mọi action còn lại (Jump Links, Page order…, Hide/Show annotations, Export, Layout, Display…, Color filter…, Page scale…, Page turn settings, Stage preset) — chúng không đạt luật "tay đang trên nhạc cụ" của Revision 3, nên chỉ có icon trong `⋯`; nếu sau này có bằng chứng cần thêm, đó là một Spec khác
- Badge trạng thái (Layout mode, Color filter, khoá Page scale) trên lối tắt — trạng thái vẫn chỉ hiện trong sheet đã mở, như hôm nay
- Cuộn ngang cho `ScoreMenuQuickBar` — ba slot vừa mọi màn hình được hỗ trợ; `QuickBarFit` nhận `slotCount` nên một Spec sau thêm slot thứ tư vẫn được trả lời bằng phép đo, không phải bằng cuộn
- Rail dọc bên mép khi máy nằm ngang (một trong các phương án bị loại ở Revision 3) — gộp vào hàng thanh trượt rẻ hơn và không tạo ra hình dạng thứ ba
- Vendor một bộ SVG cụ thể từ opensvg.dev (Feather/Tabler/Lucide…) — Orchestrator chọn Material Symbols có sẵn trong Flutter, không thêm dependency
- Hiển thị dim-scrim / không-modal cho nội dung một nhóm (**Phase E, hạng mục E3 — Spec 0045**)
- Đợt chỉnh design-token, ngoài việc dùng icon Material có sẵn (**Phase E, hạng mục E2 — Spec 0044**)
- Thay đổi màn hình Library (**Spec 0046**)
- Onboarding / coach mark (**Spec 0039**)
- Bất cứ thứ gì thuộc SmartMode / Transport (ADR 0008)
- Đa ngôn ngữ (localisation) cho chính StageScore — vẫn là một khoảng cách thật (0042 đã ghi), nhưng không phải việc của Spec này

## Thuật ngữ miền (Domain terms)

**PdfMode**, **ScoreMenu**, **PerformanceMode**, **GestureMap**, **PageTurn**, **Bookmark**, **JumpLink**, **PageOrder**, **Stamp**.

Định nghĩa **ScoreMenu** trong `CONTEXT.md` cần một câu nói thêm về `ScoreMenuQuickBar` trong chrome đáy. Không có thuật ngữ mới ngoài tên widget và `QuickBarFit` (song sinh với **LayoutFit** đã có trong CONTEXT, cùng một ý: hỏi viewport thay vì nhớ một câu trả lời).

## Tiêu chí chấp nhận (Acceptance criteria)

Checklist kiểm thử được (G4):

- [x] `⋯` trên AppBar không đổi: vẫn mở sheet bốn nhóm Go to / Marks / View / Playing, đúng nội dung như trước Spec này, mỗi mục giờ có icon đứng trước tên
- [x] AppBar không còn icon nào khác ngoài `⋯` — Draw, Metronome, Bookmarks đã dời xuống `ScoreMenuQuickBar`
- [x] `ScoreMenuQuickBar` mang đúng ba lối tắt (Bookmarks, Draw, Metronome), cùng nhịp ẩn/hiện với `PageNavBar`; **Metronome luôn hiện**, chạm được cả khi chưa chạy, và tint đổi khi chạy
- [x] Bật/tắt metronome **không làm hai icon còn lại xê dịch**
- [x] Chạm Bookmarks mở đúng sheet như chạm cùng mục trong `⋯`; chạm Draw bật/tắt draw mode như trước; Layout và View giờ chỉ có trong `⋯`
- [x] Hành động `showChrome` của `GestureMap`, khi chrome đã hiện, mở `⋯` (đủ bốn nhóm)
- [x] **Điện thoại nằm ngang:** icon nằm trong chính hàng `PageNavBar`, chỉ một hàng chrome đáy, thanh trượt vẫn kéo được bình thường
- [x] **Điện thoại dọc và tablet:** hai hàng, nhóm icon căn giữa với khoảng cách như nhau trên cả hai loại máy — không rải ra hết bề rộng tablet
- [x] **Nhãn chữ:** hiện dưới icon khi vừa (kỳ vọng: điện thoại dọc và tablet), tự mất khi không vừa hoặc khi text scale lớn — không bao giờ tràn hay bị cắt
- [x] Bar nào chạm đáy màn hình thì bar đó giữ khoảng đệm home-indicator và gesture gap; không có 20pt đệm nằm giữa hai hàng chrome
- [x] Đổi bài trong Setlist **không làm chrome đáy sụp rồi mọc lại**; trong lúc prefs đang load các lối tắt xám nhưng vẫn ở đúng chỗ, và Draw không bao giờ mất lối vào
- [x] Hoạt động đúng ở theme sáng và tối (0026), khi ẩn status bar (0032), trên chiều rộng điện thoại nhỏ nhất được hỗ trợ
- [x] Định nghĩa ScoreMenu trong `CONTEXT.md` được cập nhật ở G1 cho khớp hình dạng cuối cùng

## Ghi chú UX (UX notes)

Icon cho từng `ScoreMenuAction`, tất cả từ Material Symbols (đã có sẵn trong Flutter qua `Icons.*`; đây cũng là một trong các bộ opensvg.dev liệt kê, nên chọn mẫu ở đó rồi tra tên tương đương trong Flutter không cần thêm dependency). Tên hằng số nằm trong `score_menu.dart`, dùng chung cho cả sheet `⋯` và quick-bar:

| Action | Icon | Trên quick-bar? |
|---|---|---|
| Draw | `DrawIcon` (glyph riêng của app) | Có |
| Metronome | `kMetronomeIcon` (`Icons.speed_outlined`) trong model; `MetronomeIcon` (glyph riêng) được vẽ ở cả sheet và quick-bar | Có, luôn hiện (Revision 3) |
| Bookmarks | `kBookmarksIcon` (`Icons.bookmarks_outlined`) | Có |
| Jump Links | `kJumpLinksIcon` (`Icons.link_outlined`) | Không |
| Page order… | `kPageOrderIcon` (`Icons.reorder_outlined`) | Không |
| Hide/Show annotations | `kAnnotationsVisibleIcon`/`kAnnotationsHiddenIcon` (`Icons.visibility_outlined`/`_off_outlined`, theo trạng thái hiện tại) | Không |
| Export PDF with annotations | `kExportAnnotatedIcon` (`Icons.ios_share_outlined`) | Không |
| Layout | `kLayoutIcon` (`Icons.view_column_outlined`) | Không (Revision 3: là action lúc mở bài, không phải giữa bài) |
| Display… | `kDisplayIcon` (`Icons.settings_display_outlined`) | Không |
| Color filter… | `kColorFilterIcon` (`Icons.invert_colors_outlined`) | Không |
| Page scale… | `kPageScaleIcon` (`Icons.zoom_in_outlined`) | Không |
| Page turn settings | `kPageTurnSettingsIcon` (`Icons.swipe_outlined`) | Không |
| Stage preset | `kStagePresetIcon` (`Icons.theater_comedy_outlined`) | Không |
| View (nhóm, không phải một action) | *(đã xoá ở Revision 3)* — glyph cũ `Icons.visibility_outlined` trùng đúng icon "annotations đang hiện" | Không |

Icon của Hide/Show annotations đọc theo trạng thái hiện tại (mắt mở khi đang hiện, mắt gạch khi đang ẩn) — nhãn nói hành động sắp làm, icon nói sự thật hiện tại, giống cách nút mute thường vẽ loa-gạch khi đang mute chứ không phải khi sắp mute.

## Ràng buộc kỹ thuật (Technical constraints)

- `ScoreMenuEntry.icon` là `IconData` bắt buộc — thêm một action mới mà quên gán icon là lỗi compile, không phải lỗi runtime
- `ScoreMenuQuickBar` không tự mở sheet cho Bookmarks — gọi thẳng dispatcher đã có của 0035, tránh việc quick-bar phải biết logic của từng action
- `ScoreMenuQuickBar.slotCount` là nguồn duy nhất cho số lối tắt; `QuickBarFit` nhận nó làm tham số, nên hình học tự theo khi danh sách đổi
- `QuickBarFit` và `quickBarLabelsFit` là thuần và không lưu gì — câu trả lời đổi theo mỗi lần rotate, một câu trả lời được nhớ lại sẽ là câu trả lời sai một lần rotate sau (cùng lý do của `LayoutFit`, 0041)
- `PageNavBar` và `ScoreMenuQuickBar` luôn đi cùng nhau thành một `bottomChrome`, dùng chung cho cả slot `bottomNavigationBar` của Scaffold và overlay PerformanceMode — không có hai hình dạng khác nhau cho hai chế độ chrome
- Không vendor SVG hay thêm package icon mới — mọi icon lấy từ `Icons.*` đã có trong Flutter SDK

## Kế hoạch kiểm thử (Test plan)

- Automated: `test/quick_bar_fit_test.dart` (mới — điện thoại dọc xếp chồng, điện thoại ngang gộp, tablet xếp chồng ở cả hai chiều, màn hình vừa thấp vừa hẹp giữ nguyên thanh trượt, slot bị chặn bề rộng, `quickBarLabelsFit` ở cả hai phía cộng ca text scale, và một widget test đo `PageNavBar` thật để hằng số `kPageNavBarControlsWidth` không lệch âm thầm); `test/score_menu_quick_bar_test.dart` (viết lại — đúng ba lối tắt, Metronome chạm được khi chưa chạy, **bật metronome không dịch icon nào**, nhãn hiện/mất theo phép đo, disabled vẫn ở đúng chỗ); `test/pdf_mode_chrome_layout_test.dart` (hình học hai hình dạng, cộng ca điện thoại nằm ngang: một hàng chrome và Score giữ hơn 60% chiều cao); `test/score_menu_test.dart` không đổi
- Manual demo: trên thiết bị thật — ba lối tắt đúng hành động; xoay máy điện thoại để thấy hàng gộp vào thanh trượt rồi tách ra; tablet để thấy nhóm icon căn giữa; **nhãn chữ có thật sự hiện trên máy** (phông thật hẹp hơn phông của môi trường test, nên đây là điều test không chứng minh được); `⋯` vẫn mở đủ bốn nhóm; `showChrome` khi chrome đã hiện mở `⋯`; theme sáng và tối; đổi bài trong Setlist không làm chrome nhảy

## Ghi chú build (Build notes)

`score_menu.dart`: hằng số icon cho 12 action, trường `icon` bắt buộc trong `ScoreMenuEntry`; `kViewGroupIcon` bị xoá ở Revision 3. `score_menu_sheet.dart`: `leading: Icon(entry.icon)`. File mới `quick_bar_fit.dart` (`QuickBarFit`, `quickBarLabelsFit`, và các hằng số hình học chuyển sang đây: `kQuickBarHeight`, `kQuickBarGestureGap`, `kQuickBarMinSlotWidth`/`kQuickBarMaxSlotWidth`, `kMaxStackedChromeFraction`, `kPageNavBarControlsWidth`, `kMinScrubberWidth`). `score_menu_quick_bar.dart` viết lại: ba lối tắt, `slotCount`, `merged`, `enabled`, slot cố định căn giữa, nhãn theo `quickBarLabelsFit` đo cả *những chữ khác* mà một slot có thể vẽ (nên vào draw mode không làm hàng đổi hình). `page_nav_bar.dart`: thêm `trailing` và `bottomGestureGap`. `pdf_mode_screen.dart`: `QuickBarFit` dựng từ `MediaQuery.sizeOf`, `mergeQuickBar` quyết định `trailing`/`bottomGestureGap`/`avoidNotches`, `bottomChrome` không còn nullable, `_openViewMenu` bị xoá. **322 tests xanh** (301 trước Revision 3), `flutter analyze` sạch.

Một điều phép đo dạy lại được, đáng ghi: hằng số `kPageNavBarControlsWidth` khởi đầu ở 200pt theo tính tay, và widget test đo bar thật báo **283pt** với số trang bốn chữ số. Đặt ở 288. Ngưỡng gộp mà không có phép đo đó sẽ là ngưỡng sai theo hướng tệ nhất — gộp trên đúng những màn hình không đủ chỗ.

---

## Lịch sử: bản duyệt G3 đầu tiên (2026-07-29, bị đảo lại cùng ngày)

Phần dưới đây giữ lại nguyên văn quyết định G3 đầu tiên — thay hẳn `⋯` bằng một tab-strip có nhãn cho cả bốn nhóm — làm bằng chứng cho lý do phần "Revision 2026-07-29" tồn tại. Không còn mô tả hành vi hiện tại của app.

**Outcome đã duyệt:** Khi chrome đang hiện, phần chrome đáy của PdfMode trở thành hai hàng xếp chồng: `PageNavBar` giữ nguyên, và một tab-strip mới có nhãn ngay dưới nó — **Go to · Marks · View · Playing**, bốn nút icon-trên-chữ, luôn hiển thị. `⋯` bị bỏ khỏi AppBar hoàn toàn.

**Sáu quyết định chốt ở G3:**

| # | Câu hỏi | Chốt |
|---|----------|------|
| 1 | Sheet riêng mỗi tab hay panel nội tuyến? | Sheet riêng, dùng lại nguyên code dựng nội dung theo nhóm của 0035 làm bốn điểm gọi. |
| 2 | Badge trạng thái trên tab? | Không, cắt khỏi slice. |
| 3 | `showChrome` khi chrome đã hiện làm gì? | Mở tab Go to. |
| 4 | Hàng mới cộng thêm hay thay chỗ `PageNavBar`? | Cộng thêm một hàng mới (~48px). |
| 5 | Ngôn ngữ icon? | Icon Material có sẵn. |
| 6 | Draw thành tab thứ năm? | Không — giữ quyết định 6 của 0035. |

**Vì sao bị đảo lại:** nhãn tiếng Anh cố định ("Go to", "Marks", "View", "Playing") trong một hàng phải vừa bốn tab trên chiều rộng điện thoại nhỏ nhất được hỗ trợ. Đúng cho tiếng Anh hôm nay; một bản dịch với từ dài hơn (nhiều ngôn ngữ có từ tương đương dài hơn tiếng Anh) làm vỡ hàng đó ngay khi app được localise — một rủi ro có thật, không phải giả định, vì chính hàng đó vốn được thiết kế bám sát chiều rộng nhỏ nhất. Orchestrator chọn giữ `⋯` (chữ trong sheet cuộn được, không bị ép vào một hàng cố định) và chỉ nâng đúng một nhóm — **View** — thành icon không nhãn, hình thức duy nhất miễn nhiễm với độ dài chữ dịch.

## Lịch sử: Revision 1 (2026-07-29, bị Revision 2 thay cùng ngày)

Xem "Revision 2026-07-29 (Orchestrator, trước G4) — bị thay bởi Revision 2" ở phần đầu file — giữ nguyên vị trí đó theo thứ tự thời gian gốc thay vì lặp lại ở đây.
