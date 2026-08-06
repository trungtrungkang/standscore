# 0057 — Localization cho UI trong app (9 ngôn ngữ, khớp web)

- **Status:** accepted (G3 2026-08-06)
- **Type:** feature
- **Horizon:** không thuộc H5. Hạ tầng UI, không chạm audio/OMR/platform shell.
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005 (Flutter shell), 0008 (parity first — không chạm), 0013 (tier), 0015 (ngôn ngữ tài liệu), 0016 (mô hình)
- **Depends on Specs:** không — greenfield, không supersede Spec nào
- **Tier:** **M** (ADR 0013) — một tính năng trong một app, không SDK mới ngoài `intl`/`flutter_localizations` (cả hai đến từ chính Flutter SDK), không quyền mới, không byte nào rời máy, không đổi ADR đã accepted. G3 + G4, không cần ADR mới, không cần Security Review.
- **G3:** accepted 2026-08-06 — chốt qua `AskQuestion` trong chat (xem "Quyết định" bên dưới), thay cho form G3 dài
- **G4:** build xong 2026-08-06 — `flutter analyze` sạch, **570/570** test xanh (559 trước slice; thêm `app_locale_prefs_test.dart` và `locale_override_test.dart` — Spec liệt kê cả hai loại test này ở mục Test plan nhưng bản build đầu chỉ sửa test cũ qua `testL10n()`, chưa có test riêng cho `AppLocalePrefsStore` hay widget test ép locale). Còn lại: xác nhận thủ công trên máy thật qua các locale — xem Test plan

> **Sinh từ việc chuẩn bị build thay thế bản đang review trên App Store & Google Play.** Spec 0042 đã ghi nhận StageScore "English-only" là một khoảng cách thật so với web (9 locale) và hẹn "một slice riêng, không phải rider". Đây là slice đó.

---

## Vấn đề (Problem)

`stagescore/` chưa có bất kỳ hạ tầng i18n nào: không `intl`/`flutter_localizations` trong `pubspec.yaml`, không `l10n.yaml`, không file `.arb`, `MaterialApp` không khai `localizationsDelegates`/`supportedLocales`. Toàn bộ ~520–560 chuỗi tiếng Anh nằm hardcode rải trong ~47 file (nặng nhất `library_screen.dart`, `page_turn_settings_sheet.dart`, `pdf_mode_screen.dart`, và các sheet/dialog khác), kể cả một số hàm/extension thuần không có `BuildContext` (`AppThemeModeX.label`, `PdfLayoutModeX.label`, `PageColorFilterModeX.label`, `PageScaleScopeX.label`, `relative_day.dart`, `library_sort.dart`, `score_origin.dart`, `gesture_map.dart`, `layout_navigation.dart`, `stage_preset.dart`).

Web product (`apps/web`) đã có 9 locale (`en`, `vi`, `zh-CN`, `zh-TW`, `es`, `fr`, `de`, `ja`, `ko`). Nhạc công dùng cả hai sản phẩm thấy StageScore là app duy nhất chỉ có tiếng Anh.

## Kết quả (Outcome)

App hiển thị đúng ngôn ngữ hệ thống nếu nằm trong 9 locale trên (fallback `en`), và có thêm một setting **Language** trong menu `⋯` của Library để tự chọn ngôn ngữ khác hệ thống. Toàn bộ chuỗi UI trong `lib/` (trừ `Brand.*`) đi qua `AppLocalizations`, nguồn tiếng Anh là chân lý (ARB), 8 ngôn ngữ còn lại dịch bằng AI — tiếng Việt được review kỹ vì đây là ngôn ngữ Orchestrator đọc được, các ngôn ngữ khác chấp nhận rủi ro sai sót nhỏ ở bản đầu.

## Trong phạm vi (In scope)

**A. Hạ tầng**

- `pubspec.yaml`: thêm `flutter_localizations` (`sdk: flutter`), `intl` (version khớp Flutter SDK), `generate: true` dưới mục `flutter:`.
- `l10n.yaml` ở root `stagescore/`: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-localization-file: app_localizations.dart`.
- 9 file ARB: `app_en.arb` (template, chân lý), `app_vi.arb`, `app_es.arb`, `app_fr.arb`, `app_de.arb`, `app_ja.arb`, `app_ko.arb`, `app_zh.arb` (Simplified, khớp `zh-CN`), `app_zh_TW.arb` (Traditional, khớp `zh-TW`).
- `MaterialApp`: `localizationsDelegates: AppLocalizations.localizationsDelegates`, `supportedLocales: AppLocalizations.supportedLocales`, `locale:` đọc từ setting Language (null = theo hệ thống).

**B. Setting Language (in-app, theo hệ thống + chọn tay)**

- `AppLocalePref` (tương tự hình dạng `AppAppearance`): một giá trị `String? languageCode` (+ `String? countryCode` cho hai biến thể `zh`), `null` nghĩa là "System".
- `AppLocalePrefsStore` ghi `standscore/app_locale_prefs.json` — cùng thư mục root, cùng cơ chế ghi nguyên tử với `AppAppearancePrefsStore`.
- Một sheet chọn ngôn ngữ (`language_sheet.dart`), mở từ mục **"Language…"** trong menu `⋯` của Library, cạnh "Appearance…". Danh sách: "System" + tên bản ngữ của 9 locale (ví dụ "Tiếng Việt", "日本語", "한국어", "简体中文", "繁體中文" — không dịch tên ngôn ngữ, đây là *endonym*, không phải chuỗi ARB).

**C. Dịch toàn bộ chuỗi UI**

- Mọi chuỗi liệt kê trong inventory (trừ `Brand.*` và separator/glyph đơn ký tự như `·`, `—`, `⋯`) chuyển thành key ARB, gọi qua `AppLocalizations.of(context)!.<key>`.
- Các hàm/extension không có `BuildContext` (label getters, `relative_day.dart`, `score_origin.dart`, `gesture_map.dart`, `layout_navigation.dart`, `stage_preset.dart`, `library_sort.dart`, `stamp.dart`) nhận thêm tham số `AppLocalizations` (hoặc `BuildContext`) tại **mọi call site** — không còn getter `.label` không tham số cho các enum có nhãn hiển thị.
- Chuỗi có số đếm (pieces/pages/scores/…) dùng ICU `plural` trong ARB đúng cách `intl` hỗ trợ; chuỗi ghép câu (ví dụ *"Pages 41–46"*, filter description "and"/"or", gesture reveal hint) dùng placeholder ARB, không nối chuỗi tay.
- Domain term (Score, Setlist, Label, PageTurn, PdfMode, Bookmark, JumpLink, Stamp…) **giữ nguyên tiếng Anh trong mọi bản dịch** — đây là danh từ riêng của sản phẩm, không phải từ chung, đúng `CONTEXT.md`/ADR 0015 (áp dụng logic doc-language sang UI-language: tên miền có một định nghĩa, không dịch).
- 9 bản ARB dịch đầy đủ (không để thiếu key nào — `flutter gen-l10n` sẽ cảnh báo/lỗi nếu thiếu, và một placeholder-fallback-về-English cho tất cả các key nghĩa là "chưa dịch" trôi qua không ai biết).

## Ngoài phạm vi (Out of scope)

- **Store listing** (`STORE-LISTING.md`, App Store Connect / Play Console metadata, screenshot theo ngôn ngữ) — vẫn tiếng Anh. Đây là quyết định đã chốt qua `AskQuestion`, giữ scope gọn đúng luật `AGENTS.md` "không mở rộng scope nhân lúc đang sửa". Có thể là slice riêng sau.
- **RTL** — không locale nào trong 9 locale trên là RTL; không đổi `Directionality` nào.
- **Ngôn ngữ theo từng Score/BackingTrack** (ví dụ lời bài hát, MusicXML text) — ngoài phạm vi, đây là UI chrome, không phải nội dung nhạc.
- **Đảm bảo chất lượng dịch cho 7/9 ngôn ngữ ngoài `en`/`vi`** — dịch bằng AI, không có native speaker review ở slice này; chấp nhận rủi ro sai sót nhỏ, sửa dần khi có phản hồi thật (xem "Quyết định" #4).
- **Test file (`test/`)** không đổi mục tiêu: literal tiếng Anh trong test (`find.text('Cancel')` …) vẫn phải pass, vì locale mặc định của test là `en` và giá trị `en` trong ARB giữ **đúng nguyên văn** chuỗi cũ. Nếu một test cần sửa vì thiếu `localizationsDelegates` trong `MaterialApp` test harness, đó là sửa hạ tầng test, không phải đổi kỳ vọng.

## Quyết định (chốt qua AskQuestion trong chat 2026-08-06)

| # | Câu hỏi | Chốt |
|---|---------|------|
| 1 | Tier? | **M** — Feature Spec (G3) + G4, không ADR |
| 2 | Bộ ngôn ngữ? | **Khớp 9 locale của web**: `en`, `vi`, `zh-CN`, `zh-TW`, `es`, `fr`, `de`, `ja`, `ko` (mặc định `en`) |
| 3 | Cách tiếp cận kỹ thuật? | **Flutter chính thức**: `flutter_localizations` + `intl` + ARB + `gen-l10n` codegen — không thêm dependency ngoài |
| 4 | Nguồn dịch? | **AI dịch nháp toàn bộ**; Orchestrator review kỹ tiếng Việt; các ngôn ngữ khác chấp nhận rủi ro sai sót nhỏ ở bản đầu |
| 5 | Phạm vi store listing? | **Không** — chỉ UI trong app, store listing giữ tiếng Anh, làm slice riêng nếu cần |
| 6 | Cách chọn ngôn ngữ hiển thị? | **Theo hệ thống + có setting trong app để override** — không chỉ đơn thuần theo system locale |

## Domain terms

**Không term mới trong `CONTEXT.md`.** `AppLocalePref`/`AppLocalePrefsStore`/"Language" là hạ tầng UI chung (cùng loại với `AppAppearance`, hiện cũng không có trong `CONTEXT.md`), không phải từ vựng miền nhạc cụ. Domain term hiện có (Score, Setlist, Label, PdfMode, SmartMode, PageTurn, TurnAmount, Bookmark, JumpLink, Stamp, …) giữ nguyên tiếng Anh trong **mọi** bản dịch — quy tắc này được ghi lại trong chính Spec này (mục "Trong phạm vi" C) vì nó áp cho toàn bộ 8 file ARB không phải `en`, không riêng một chỗ.

## Acceptance criteria

- [x] `flutter pub get` + `flutter gen-l10n` chạy sạch, không key nào thiếu ở bất kỳ 1 trong 9 file ARB
- [ ] Đổi ngôn ngữ hệ thống thiết bị sang mỗi locale trong 9 locale (giả lập được ít nhất vài locale) → UI hiển thị đúng bản dịch, không sót chuỗi tiếng Anh nào ngoài domain term và `Brand.*` — **G4 trên máy thật, chưa làm**
- [x] Locale hệ thống không thuộc 9 locale (ví dụ Thái) → app hiển thị tiếng Anh (fallback), không crash — `locale_override_test.dart`
- [x] Setting **Language** trong menu `⋯`: chọn "System" theo đúng hệ thống; chọn một ngôn ngữ cụ thể → toàn app đổi ngay không cần khởi động lại — wiring + `AppLocalePrefsStore` round-trip test; **khởi động lại app giữ lựa chọn cần xác nhận trên máy thật (G4)**
- [x] Chuỗi có số đếm (ví dụ "1 piece" / "N pieces") đúng ngữ pháp số nhiều/số ít cho từng ngôn ngữ theo luật ICU của `intl` (tiếng Việt/Trung/Nhật/Hàn không phân biệt số nhiều — luật `other` áp dụng đúng, không sinh câu ngô nghê kiểu "1 pieces") — `locale_override_test.dart` tải cả 9 locale và gọi `piecesScreenPieceCount(1)`/`(2)`
- [x] Domain term (Score, Setlist, Bookmark, JumpLink, PageTurn…) xuất hiện y nguyên tiếng Anh trong mọi bản dịch
- [x] `flutter analyze` sạch, toàn bộ suite test hiện có xanh không cần đổi kỳ vọng chuỗi (chỉ đổi test harness nếu thiếu `localizationsDelegates`) — **570/570**
- [x] Không chuỗi tiếng Anh nào còn hardcode trong `lib/` ngoài `Brand.*`, endonym tên ngôn ngữ trong sheet Language, và separator/glyph đơn ký tự

## Technical constraints

- **`AppLocalizations.of(context)!`** — không dùng `?` rồi fallback tay; mọi widget cây con của `MaterialApp` đảm bảo có `Localizations` ancestor.
- **Hàm/extension thuần không `BuildContext`** (label getters, `relative_day.dart`, `score_origin.dart`, `gesture_map.dart`, `layout_navigation.dart`, `stage_preset.dart`, `library_sort.dart`, `stamp.dart`) nhận thêm tham số `AppLocalizations` — cập nhật **mọi** call site, không giữ overload cũ song song (tránh một nhánh code vẫn tiếng Anh cứng).
- **`zh` mapping:** `zh-CN` (web) ↔ `Locale('zh')` (`app_zh.arb`, Simplified); `zh-TW` (web) ↔ `Locale('zh', 'TW')` (`app_zh_TW.arb`, Traditional) — theo đúng cách Flutter phân giải `Locale` bằng `languageCode`+`countryCode`, không dùng script subtag.
- **`AppLocalePrefsStore`** dùng cùng file writer nguyên tử mà `AppAppearancePrefsStore` đang dùng (ghi qua file tạm rồi rename, nếu có sẵn helper chung — nếu chưa có helper chung thì viết trực tiếp `writeAsString` giống `AppAppearancePrefsStore` hiện tại, không tạo cơ chế ghi mới).
- **Không đổi `formatVersion` của `library.json`** — pref ngôn ngữ là file riêng (`app_locale_prefs.json`), không phải trường trong thư viện.
- **Comment code bằng tiếng Anh** theo user rule, không phụ thuộc ngôn ngữ Spec.

## Test plan

- **Automated:** test cho `AppLocalePrefsStore` (load/save/round-trip, default null = System, giá trị hỏng → fallback null); test cho các hàm nhận `AppLocalizations` (label getters trả đúng chuỗi theo locale truyền vào, không phụ thuộc `Localizations.of` context thật); widget test dựng `MaterialApp` với `locale:` ép cứng từng locale, xác nhận vài điểm chốt (ví dụ nút "Cancel"/"Save" trong `title_prompt.dart`, plural "N pieces") hiển thị đúng bản dịch.
- **Manual (G4):** đổi ngôn ngữ hệ thống thiết bị qua vài locale trong 9 locale, lướt qua Library, Score menu, các sheet chính (Appearance, Display, Layout, Page turn, Metronome, Bookmarks, Labels) xem không sót chuỗi tiếng Anh nào ngoài domain term; test riêng setting Language override hệ thống; khởi động lại app xác nhận pref còn giữ.
