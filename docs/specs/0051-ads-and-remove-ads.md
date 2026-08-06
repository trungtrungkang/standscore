# 0051 — Một banner ở Library, và một lần mua để nó biến mất

- **Status:** proposed
- **Type:** feature
- **Phát hành:** **1.1, không phải v1** (ADR 0018 quyết định 10, chốt lại 2026-07-30). v1 ra mắt miễn phí, không quảng cáo, không IAP — đúng thứ `STORE-LISTING.md` đang mô tả. Slice này **không chặn v1** và không được để nó chặn
- **Horizon:** không thuộc horizon parity — slice này nằm trên đường release (`RELEASE-CHECKLIST.md` R7 / R11 / R12 / R18 / R25 / R26 / R27)
- **Owner (human):** Orchestrator
- **Depends on ADRs:** **0018 (`proposed` — chặn)**, 0005 (Flutter shell), 0008 (không đụng SmartMode/Transport/BackingTrack/OMR), 0009 (`com.backingscore.scoreapp`), 0010 (chính tả brand), 0012 (hai repo, không CI nối), 0015 (ngôn ngữ tài liệu), 0016 (mô hình)
- **Depends on Specs:** 0027 + 0050 (`done` — sở hữu `LibraryBackup` và cây library); 0042 (`done` — About sheet, và idiom guard của `brand_reach_test.dart`); 0044 (`done` — token + idiom guard nguồn); 0002 / 0040 (`done` — màn hình Library)
- **Tier:** **L** — hai SDK bên thứ ba gửi dữ liệu rời máy, cộng thanh toán
- **G3:** **13 câu hỏi đã trả lời 2026-07-30** (Orchestrator uỷ quyền agent), tất cả theo khuyến nghị; chữ ký `accepted` còn chờ Orchestrator
- **Security Review:** [`docs/security/0051-ads-and-remove-ads.md`](../security/0051-ads-and-remove-ads.md) — **pass có điều kiện** 2026-07-30. Ba điều kiện chặn build (S1 khởi tạo lười, S4 restore không chạm cache, S5 `canRequestAds()` là cổng duy nhất) **đã áp vào Spec này**. Review **chưa đóng**: hạng mục "hai SDK gửi gì đi" không kiểm được trước `pub get` (S10)

> **Không được build slice này khi ADR 0018 còn `proposed`, và không được build nó trước khi v1 lên store.** Tier L cần **G2 accept + Security Review trước khi build** (`AGENTS.md`, ADR 0013) — Security Review đã chạy, ADR còn chờ chữ ký. G3 accept cho Spec này là **chưa đủ**. R25 và R27 là điều kiện để *bán* được, không phải để *code* được; **R26 thì không thể hoàn tất trước khi v1 publish**, đó là lý do slice này là 1.1.

## Vấn đề (Problem)

ADR 0018 chốt mô hình kiếm tiền: app **miễn phí, đầy đủ tính năng**, một **banner tĩnh ở Library**, và một **lần mua `remove_ads`** để tắt nó vĩnh viễn. Hôm nay app không có cả hai thứ đó. Slice này là chỗ mười một quyết định của ADR trở thành code — và cùng với nó, chỗ **tính chất kiểm được từ bên ngoài "app không thể gọi mạng" chết vĩnh viễn** (manifest `main` của Android hôm nay không khai quyền nào; sau slice này nó có `INTERNET` và `AD_ID`).

Vì thế slice này không phải "thêm một widget vào Library". Nó là slice đầu tiên trong lịch sử app đưa **hai** SDK bên thứ ba vào một sản phẩm mà lời hứa bán hàng của nó là *bản nhạc của bạn ở lại trên máy bạn*. Phần lớn công việc dưới đây tồn tại để lời hứa đó vẫn đúng sau khi banner xuất hiện.

**Bốn thứ đọc từ repo hôm nay, và cả bốn đều đổi thiết kế của slice — không cái nào lộ ra từ ADR:**

| # | Điều đọc được | Bằng chứng | Hệ quả |
|---|---|---|---|
| 1 | **Mọi prefs của app đều ghi vào trong `libraryRoot`**, và `LibraryBackup` đi cả cây từ `libraryRoot` | `library/page_color_filter_prefs_store.dart:10` ghi `standscore/page_color_filter_prefs.json`; 0050 tự đi cây từ `libraryRoot` | Ghi cờ `no_ads` theo đúng thói quen của app sẽ **đưa nó vào file backup**, tức phá quyết định 6 của ADR — và **không test nào hôm nay đỏ vì chuyện đó**. Cache entitlement phải nằm **ngoài** `libraryRoot` |
| 2 | **`PdfModeScreen` không pump được** — pdfrx cần native viewer | `brand_reach_test.dart` và `design_token_guard_test.dart` đều nói thẳng lý do này, và cả hai vì thế là test **nguồn** | Quyết định 1 của ADR đòi "một widget test mở Score rồi khẳng định không có ad widget trong cây". Test đó **không viết được**. Guard phải đổi hình: test nguồn theo idiom 0042, cộng widget test trên Library (thứ *pump được*) |
| 3 | **Library vẫn mounted bên dưới khi nhạc công đang chơi** — `PdfMode` là một route đẩy chồng lên | `library_screen.dart:1102` (`Expanded(child: _buildBody(context))`), route push | Một banner có **auto-refresh** (mặc định bật được ở console AdMob) sẽ tiếp tục gọi mạng **trong lúc đang diễn**, dù nó không hiển thị. Đó là vi phạm quyết định 3 mà không màn hình nào cho thấy |
| 4 | Library có **FAB** neo góc dưới phải | `library_screen.dart:1105` | Banner đặt ở đáy sẽ nằm dưới FAB. Đây là quyết định bố cục, không phải chi tiết |

## Kết quả (Outcome)

Nhạc công mở app và thấy Library **y như hôm nay** — cùng danh sách, cùng tốc độ, cùng thao tác — rồi một dải banner xuất hiện ở đáy *sau khi* danh sách đã vẽ xong. Cạnh banner là một đường "Remove ads". Trả tiền một lần, banner biến mất và không bao giờ quay lại, kể cả khi máy không có mạng, kể cả sau khi cài lại (qua Restore Purchases).

Mở một bản nhạc thì không có gì của tầng quảng cáo đi theo: không widget, không request, không chờ.

Với người viết slice sau, kết quả là **hai cổng và một guard**: một `Entitlement` port trả lời "có `no_ads` không", một `AdSlot` port mà bản mặc định là *không có quảng cáo*, và một test nguồn khoá danh sách file được phép biết hai SDK này tồn tại.

## Trong phạm vi (In scope)

**Tầng entitlement (xây trước — xem G3 số 1)**

- `lib/monetization/entitlement.dart` — port `Entitlement` (`bool get noAds`, một `Stream` đổi trạng thái) cộng `EntitlementCache` ghi file **ngoài `libraryRoot`**
- `lib/monetization/purchases.dart` — adapter RevenueCat (`purchases_flutter`), **file duy nhất** được import SDK đó; anonymous app user ID, entitlement tên `no_ads`
- **Khởi tạo lười (Security Review S1):** `Purchases.configure` chỉ chạy khi cache nói **đã mua**, hoặc khi người dùng **chủ động** chạm "Remove ads" / "Restore purchases". Người không mua thì không một byte nào đi tới RevenueCat, suốt đời cài đặt
- Mua: một đường "Remove ads" cạnh banner, cộng một hàng trong About sheet
- **Restore Purchases** trong About sheet (0042), theo Apple 3.1.1

**Tầng quảng cáo (xây sau)**

- `lib/ads/ad_slot.dart` — port `AdSlot` + `NoAdSlot` (dựng ra `SizedBox.shrink()`, không biết SDK nào tồn tại)
- `lib/ads/admob_ad_slot.dart` — banner AdMob (`google_mobile_ads`), **file duy nhất** được import SDK đó; nạp sau first paint; cao **0** khi chưa có fill
- UMP consent cho EEA/UK, chạy **sau** khi Library vẽ xong, **trước** request đầu tiên
- `lib/ui/library_screen.dart` — chỗ ngồi của slot

**Guard và cấu hình**

- `test/ads_reach_test.dart` — test nguồn: allowlist file được nhắc `google_mobile_ads` / `purchases_flutter` / `BannerAd` / `AdWidget`; `Purchases.logIn` **cấm ở mọi nơi**
- AdMob app id trong `AndroidManifest.xml` và `Info.plist`; `SKAdNetworkItems`; hai dependency mới trong `pubspec.yaml`
- **Hai `PrivacyInfo.xcprivacy` trong repo này** — `Runner` khai đúng thứ hai SDK thu thập, `ShareExtension` **giữ rỗng** kèm chú thích lý do

## Ngoài phạm vi (Out of scope)

- **Bốn trong bảy tuyên bố của quyết định 8 nằm ở repo khác hoặc ở console:** `privacy/page.tsx`, `support/page.tsx`, `app-ads.txt` (repo web, ADR 0012), cộng hai form App Privacy / Data safety. Chúng thuộc **R11 / R26 và checklist submit**, không thuộc Spec này — nhưng Spec này **không được G4** trước khi chúng đúng, vì cả bảy phải đúng cùng một ngày
- `STORE-LISTING.md` viết lại (R12, câu hỏi 10 của ADR) — copy đã qua gate, cần Orchestrator, không phải việc của slice
- **Ảnh chụp store** (R12, câu hỏi 9 của ADR) — cần phần cứng và logo chốt
- **Bốn định dạng bị cấm đích danh** ở quyết định 2 (app-open, interstitial, rewarded, native trộn danh sách): không cài, không để sau một cờ, không có đường quay lại trong code
- **Mediation, nhiều ad network, tối ưu eCPM** — ADR đã tính banner là *lý do để mua*, không phải nguồn thu
- **Subscription, nhiều SKU, nâng cấp** — một non-consumable, một entitlement
- **Discover / BackingTrack** (ADR 0017 `hold`), và **quan hệ của `remove_ads` với thứ bán sau này** — câu hỏi 7 của ADR, phải trả lời **trước khi tạo SKU trên store**, nhưng nó không đổi một dòng code nào ở đây
- **Cờ đã mua đi theo backup** — cấm; `formatVersion` giữ **1**, không thêm field, không đụng `LibraryBackup`

## Câu hỏi G3 (G3 questions) — **đã trả lời 2026-07-30**

Cả mười hai câu chốt trong một lượt, Orchestrator uỷ quyền agent, **tất cả theo khuyến nghị đã ghi**. Bốn câu đổi nội dung sau đợt tra cứu tài liệu AdMob và RevenueCat cùng ngày và được đánh dấu **⟳** — chúng không đổi hướng, chúng đổi *lý do* hoặc thêm một ràng buộc mà bản nháp chưa biết.

| # | Câu hỏi | Chốt |
|---|---|---|
| 1 | Một Spec hay tách đôi (tiền / quảng cáo)? | **Một Spec, hai giai đoạn build.** Không nửa nào G4 được một mình: "quảng cáo tắt được" cần có thứ để tắt, "mua rồi hết quảng cáo" cần quảng cáo tồn tại. Thứ tự **entitlement trước, quảng cáo sau** vì `noAds` là **đầu vào** của việc có khởi tạo SDK quảng cáo hay không — làm ngược lại thì sẽ có một khoảng thời gian tầng quảng cáo chạy vô điều kiện, và đó đúng là hình dạng bug sẽ sống sót tới production. Nếu Orchestrator muốn tách, chỗ cắt sạch duy nhất là ranh giới `AdSlot` port |
| 2 | Cờ `no_ads` cache ở đâu? | **`<documents>/entitlements.json`, chị em với `standscore/`, không nằm trong nó.** Ba nơi bị loại có lý do: trong `libraryRoot` thì **đi theo backup** (phá quyết định 6, và không test nào hôm nay bắt được — phát hiện 1 ở trên); `<cache>` thì **OS xoá được**, và người đã trả tiền thấy quảng cáo quay lại sau một lần máy dọn cache là lỗi tệ nhất của slice này; `SharedPreferences` thì đúng về kỹ thuật nhưng thêm một dependency và một mô hình lưu trữ thứ hai vào app đang chỉ dùng JSON file. Khoá bằng test: một ZIP backup **không bao giờ** chứa tên file đó |
| 3 | Lúc chưa biết thì mặc định là gì? | **Cache là nguồn sự thật lúc khởi động; mạng chỉ *cập nhật* cache, không bao giờ là điều kiện để trả lời.** Đây là chỗ dễ hỏng nhất của cả slice vì cả hai mặc định đều sai: mặc định "chưa mua" thì người đã trả tiền thấy banner **nháy** mỗi lần mở app offline — mà offline là trạng thái bình thường của app này; mặc định "đã mua" thì offline không ai thấy quảng cáo bao giờ. Cụ thể: không có file cache → chưa mua. Có cache `true` → **đã mua, ngay lập tức, không chờ ai**. Một lần gọi RevenueCat **thất bại** không bao giờ hạ cờ xuống; chỉ một câu trả lời **thành công** nói entitlement không còn mới ghi lại cache |
| 4 | Guard hình dạng nào, khi quyết định 1 đòi một test không viết được? | **Test nguồn cộng widget test trên Library** (phát hiện 2). Test nguồn theo đúng idiom `brand_reach_test.dart`: một allowlist gồm `lib/ads/admob_ad_slot.dart`, `lib/monetization/purchases.dart` và `lib/ui/library_screen.dart`; mọi file khác trong `lib/` nhắc `google_mobile_ads`, `purchases_flutter`, `BannerAd` hay `AdWidget` là đỏ. Cộng thêm hai thứ rẻ mà đắt nếu thiếu: `Purchases.logIn` **cấm ở mọi file** (ràng buộc 1 của quyết định 11), và chuỗi `'premium'` cấm trong `lib/monetization/` (entitlement phải là `no_ads`). Widget test pump `LibraryScreen` với entitlement bật để khẳng định cây **không có** `AdSlot` nào |
| 5 | Auto-refresh của banner? | **Tắt, và tắt ở cả hai chỗ.** Ở console AdMob (nó là **thiết lập console**, không phải tham số code — nên nó không nằm trong diff và sẽ không ai thấy nó sai), và trong code bằng cách **dispose banner khi một route được đẩy chồng lên Library**. Lý do là phát hiện 3: Library còn mounted trong suốt buổi diễn, nên một banner tự làm mới sẽ gọi mạng đều đặn trong lúc nhạc công đang chơi — đúng thứ quyết định 3 cấm, mà không màn hình nào cho thấy nó đang xảy ra |
| 6 ⟳ | Consent hiện trước hay sau Library? Và người EEA **từ chối** thì sao? | **Sau, và từ chối không phải là hết chuyện.** Hệ quả của ADR viết "màn hình consent đứng trước Library", nhưng quyết định 3 cấm mọi thứ của tầng quảng cáo đi trước first paint, và UMP chỉ đòi consent **trước một ad request** chứ không đòi trước nội dung app. Nên: Library vẽ → `requestConsentInfoUpdate` → nếu cần form thì hiện → rồi mới request. Người đã mua **không thấy gì cả**, không cả lời gọi đầu tiên. **Phần bổ sung sau đợt tra cứu:** AdMob có bốn ad serving mode, và đường đúng cho người từ chối là **limited ads (LTD)** — phục vụ không dùng định danh nào — chứ **không** phải tắt quảng cáo hẳn và cũng không phải hỏi lại. Bản nháp không biết chế độ này tồn tại và sẽ mặc định vào một trong hai đường sai đó |
| 7 | Nút mua nằm ở đâu? | ADR đặt tên SKU và đặt Restore vào About, nhưng **không nói mua ở đâu** — đây là lỗ hổng thật, không phải chi tiết. Khuyến nghị: **một đường "Remove ads" gắn liền với banner**, chỉ tồn tại khi banner đang hiển thị. Ưu điểm là nó tự biến mất đúng lúc: offline, không fill, slot cao 0 → không có gì mời chào, vì không có gì để phàn nàn. Cộng một hàng trong About sheet cạnh Restore cho người đi tìm. **Không hộp thoại, không nag theo lần mở app, không đếm ngược** |
| 8 | Library trống thì có banner không? | **Không.** Ấn tượng đầu tiên của app là màn hình Scores rỗng cộng một dòng `Brand.publisherLine` (0042); thêm quảng cáo của bên thứ ba vào đó là bán inventory trước khi đưa được giá trị nào. Điều kiện: banner chỉ dựng khi tab `scores` có ít nhất một Score — cùng điều kiện mà ô tìm kiếm đang dùng (`library_screen.dart:1072`). Tab **Setlists**: cũng có banner, vì nó vẫn là Library |
| 9 ⟳ | Ad unit id lấy từ đâu? | **Một `AdIds` duy nhất, `kDebugMode` chọn giữa unit thật và unit test của Google.** Hai lỗi đối xứng đều thật: ship nhầm unit test thì doanh thu bằng **0** và không có gì báo; chạy unit thật trong debug là **invalid traffic**, thứ AdMob khoá tài khoản chứ không nhắc nhở. **Và đợt tra cứu đổi ý nghĩa của câu này: unit test không phải công cụ tiện tay, nó là cách *duy nhất* để nhìn thấy một banner trước ngày phát hành.** AdMob không phục vụ đầy đủ cho app chưa xác minh `app-ads.txt`, mà xác minh đòi app đã lên store (ADR 0018 quyết định 13). Nên **G4 không được lấy "banner thật hiện ra" làm tiêu chí** — nó sẽ trượt vì một lý do không liên quan gì tới code |
| 10 | `maxAdContentRating`? | **`'G'`.** App này nằm trên giá nhạc của học sinh trong giờ học. Đổi lấy eCPM thấp hơn nữa — mà phần doanh thu đã được ADR định giá là gần bằng không, nên đây là đánh đổi rẻ nhất trong cả slice. Nó cũng phải khớp với age rating khai ở R12 |
| 11 ⟳ | `NSPrivacyTracking` giữ `false` được không? | **`false` — và câu này tự giải bằng một suy luận, không phải một phép tra.** Khai `true` thì **bắt buộc** phải có ATT prompt trước mọi request quảng cáo (App Review 5.1.2: khai tracking mà không hỏi là lỗi bị từ chối); ADR quyết định 5 đã cấm ATT; nên `false` là ô duy nhất điền được. Đổi lại, `false` **chỉ trung thực nếu app khoá cứng non-personalized** — đó là một ràng buộc lên code, không phải một ô trong plist: **không nhánh nào bật personalization**, và Security Review kiểm đúng điều đó. Việc tra vẫn phải làm nhưng nó là việc khác: đọc `PrivacyInfo.xcprivacy` **bên trong** `GoogleMobileAds.xcframework` và của RevenueCat *sau khi* thêm dependency, sinh Privacy Report từ bản archive, rồi điền `NSPrivacyCollectedDataTypes` của app theo báo cáo. Google Mobile Ads phải từ **`11.2.0`** trở lên mới mang manifest — dưới mức đó là lỗi phát hành `ITMS-91061`, và cách chữa là nâng version chứ không phải sửa code |
| 12 | Có nên nhân dịp này dọn gì trong Library không? | **Không.** `library_screen.dart` đã 1407 dòng và đang là file đông người sửa nhất; slice này thêm **một** widget ở đáy và **một** hàng trong About. Header hai hàng là 0046, `_Chip` là 0046 — cả hai đang `hold`, và chạm vào chúng ở đây làm Security Review phải đọc một diff to hơn phần cần đọc |
| 13 ⟳ | Data safety khai gì, khi "non-personalized" nghe như "không thu gì"? | **Khai là có dùng advertising ID.** Câu "không cá nhân hoá" của ADR đúng nhưng dễ đọc thành sai: tài liệu Google viết rõ non-personalized ads **vẫn dùng** cookies hoặc mobile ad identifier cho frequency capping và báo cáo tổng hợp. Trên iOS không có ATT thì IDFA không lấy được nên vế đó tự đúng; trên **Android thì advertising ID vẫn được dùng**, và đó chính là lý do `AD_ID` có mặt trong manifest release. Cộng thêm **purchase history** của RevenueCat. Khai đủ ba thứ đó ở cả hai form (R11) |

## Thuật ngữ miền (Domain terms)

**Một thuật ngữ mới, và nó thuộc về `CONTEXT.md`:**

- **Entitlement** — quyền đã mua, gắn với **store account** chứ không gắn với thiết bị và không gắn với tài khoản của Backing & Score. StageScore có đúng **một** entitlement, tên `no_ads`. Nó không mở tính năng nào; nó chỉ làm quảng cáo không tồn tại.

Cố ý **không** định nghĩa: banner, consent, CMP, ad unit — đó là chi tiết thực thi, thứ `AGENTS.md` cấm đưa vào `CONTEXT.md`.

Cảnh báo đặt sẵn cho người đọc sau: **`no_ads` của StageScore và `premium` của repo web là hai thứ khác nhau** (ADR 0014 — hai bounded context, hai từ vựng; ADR 0018 quyết định 11). `premium` bên kia nghĩa là mở toàn danh mục. Không dùng lại tên, không gộp project RevenueCat.

Thuật ngữ đã có mà Spec này dùng: **Score**, **Setlist**, **Library**, **PdfMode**, **PerformanceMode**.

## Tiêu chí chấp nhận (Acceptance criteria)

**Bất biến — quảng cáo không đi xa hơn Library**

- [ ] Mở một Score: không có widget quảng cáo nào trong cây, và **không request mạng nào** phát ra trong suốt lúc mở, lật trang, hay chạy Setlist
- [ ] `test/ads_reach_test.dart` xanh, và đã được thử **đỏ có chủ ý** một lần (thêm một import `google_mobile_ads` vào `pdf_mode_screen.dart`, xác nhận đỏ, revert) — cùng cách 0044 đã chứng minh guard của nó còn sống
- [ ] `Purchases.logIn` không xuất hiện ở bất kỳ file nào trong `lib/`; chuỗi `'premium'` không xuất hiện trong `lib/monetization/`

**Người đã mua**

- [ ] Với `no_ads` bật: **không SDK nào được khởi tạo** — không `MobileAds.instance.initialize`, không `requestConsentInfoUpdate`, không request banner. Khoá bằng một fake đếm mọi lời gọi và khẳng định con số là `0`
- [ ] Cắt mạng hoàn toàn, kill app, mở lại: **không có banner, không nháy một khung hình nào**
- [ ] Xoá app, cài lại, Restore Purchases: banner biến mất trở lại
- [ ] Restore khi không có mạng: một thông báo nói rõ cần mạng, **không** phải một spinner treo và không phải im lặng

**Backup không mang theo quyền đã mua**

- [ ] Backup một library ở trạng thái **đã mua**, giải nén ZIP: không entry nào chứa cờ `no_ads`; tên file cache không xuất hiện trong archive
- [ ] Restore bản backup đó trên một máy **chưa mua**: vẫn còn quảng cáo, và file cache entitlement **không được tạo ra** bởi đường restore (Security Review S4)
- [ ] Một người **chưa từng chạm nút mua**: không lời gọi nào tới RevenueCat trong suốt vòng đời cài đặt (Security Review S1) — khoá bằng fake đếm lời gọi, con số là `0`
- [ ] `formatVersion` vẫn `1`; `formatId` và `markerFileName` không đổi một ký tự; hai test của 0027 và test của 0050 xanh **không sửa một dòng**

**Banner cư xử đúng**

- [ ] Danh sách Score vẽ xong **trước** request quảng cáo đầu tiên; không frame nào của Library chờ tầng quảng cáo
- [ ] Không có fill (offline, hoặc mạng trả rỗng): slot chiếm đúng **0 pixel** — không placeholder, không skeleton, bố cục Library không nhảy khi đang cuộn
- [ ] Library trống: không banner
- [ ] Đẩy một Score lên rồi quay lại: không có banner nào được request trong lúc Score đang mở
- [ ] Banner không che FAB và không bị FAB che

**Bản dựng**

- [ ] `aapt dump permissions` trên AAB release liệt kê đúng `INTERNET` và `AD_ID` — **và không quyền nào khác**. Đây là con số cần được nhìn tận mắt, không suy ra từ việc "chỉ thêm hai SDK"
- [ ] App khởi động được trên cả hai nền tảng với AdMob app id đã khai (thiếu id là **crash lúc khởi động**, không phải "không có quảng cáo")
- [ ] Bản release gọi ad unit **thật**, debug build gọi unit **test** của Google
- [ ] **Không nhánh code nào bật personalized ads được** — grep cả `lib/` và xác nhận request luôn mang non-personalized; đây là điều kiện để `NSPrivacyTracking = false` không phải một lời khai sai
- [ ] Người EEA **từ chối** ở form consent: app chuyển sang **limited ads**, không tắt quảng cáo hẳn và không hỏi lại
- [ ] Hai `PrivacyInfo.xcprivacy` khớp với privacy manifest mà Google và RevenueCat công bố; bản của `ShareExtension` vẫn rỗng, kèm chú thích lý do
- [ ] Đo lại kích thước AAB và ghi vào R18 (hôm nay **71 MB**)
- [ ] `flutter analyze` sạch; toàn bộ test xanh (hôm nay **365**)

## Ghi chú UX (UX notes)

**Nhạc công nên thấy khác:** một dải banner ở đáy Library, xuất hiện sau khi danh sách đã ở đó; một đường "Remove ads" cạnh nó; một hàng "Remove ads" và một hàng "Restore purchases" trong About sheet. Người ở EEA/UK thấy thêm một form consent — **sau** khi thấy bản nhạc của mình.

**Nhạc công không nên thấy khác:** thời gian từ chạm icon tới thấy danh sách Score; đường Library → Score; bất cứ thứ gì bên trong một bản nhạc đang mở; hành vi offline của mọi tính năng đang có. Nếu mở app **chậm đi thấy được**, slice đã sai ở thứ tự khởi tạo, không phải ở việc tinh chỉnh.

**Giọng của đường mua.** Thứ bán ra là *"đừng làm phiền tôi nữa"* — cả ADR đứng vững trên câu đó. Nên copy nói đúng việc nó làm ("Remove ads · một lần, vĩnh viễn") và không hứa gì thêm: không "Pro", không "Premium", không "Unlock", không danh sách tính năng — vì **không tính năng nào bị khoá**, và một chữ gợi ý ngược lại là thứ ADR nói **không sửa được sau khi ship**.

**Chỗ dễ trượt nhất.** Banner đứng ngay trên hàng Score cuối cùng, mà hàng Score là thứ được chạm nhiều nhất trong app. Phải có khoảng cách đủ để một ngón tay vội không chạm nhầm vào quảng cáo — và nếu phải chọn giữa "banner sát viền dưới" và "hàng cuối không bị chạm nhầm", chọn vế sau.

## Ràng buộc kỹ thuật (Technical constraints)

- **Cache entitlement nằm ngoài `libraryRoot`.** Đây là ràng buộc chính xác nhất của slice và cũng là ràng buộc dễ vi phạm nhất, vì mọi prefs store đang có đều ghi *vào trong* đó (`page_color_filter_prefs_store.dart:10`) — làm theo thói quen của codebase ở đây là làm sai
- **`AdWidget` chỉ được dựng sau `onAdLoaded`.** Dựng trước để "giữ chỗ" chính là thứ quyết định 3 cấm; kích thước banner biết trước không phải lý do để chiếm chỗ trước
- **Đúng một `BannerAd` cho một lần mount Library.** Không tạo lại theo `setState` — Library `setState` khi lọc, khi tìm, khi đổi tab, và một request quảng cáo trên mỗi ký tự gõ vào ô tìm kiếm là invalid traffic
- **`PdfModeScreen` không pump được**, nên mọi bất biến "quảng cáo không tới được đây" là **test nguồn**. Đó không phải sự lười; đó là cùng lý do 0042 và 0044 là test nguồn
- **Hai SDK bị bao bởi đúng hai file**, và guard là thứ giữ điều đó đúng. Không import trực tiếp ở `lib/ui/`
- **Anonymous app user ID tuyệt đối.** Không `Purchases.logIn`, không truyền một định danh nào của mình vào RevenueCat, project RevenueCat tách khỏi project của repo web (R27)
- **Không đụng `LibraryBackup`.** Không field mới, không bump `formatVersion`, không đổi `formatId`
- Dependency mới: đúng **hai** — `google_mobile_ads` (**tối thiểu `11.2.0`**, dưới mức đó không mang privacy manifest và bị `ITMS-91061`) và `purchases_flutter` (SDK **Flutter**; prototype Ionic dùng `@revenuecat/purchases-capacitor`, không liên quan)
- **Ba điều kiện dự án đã sẵn, kiểm rồi chứ không giả định:** `minSdk 24` ≥ mức 21 của RevenueCat; iOS deployment target `14.0` ≥ mức 13.0; và `android:launchMode="singleTop"` (`AndroidManifest.xml:9`) đúng thứ RevenueCat đòi — `launchMode` khác `standard`/`singleTop` làm giao dịch bị huỷ khi người dùng rời app sang app ngân hàng để xác thực. **Không được đổi ba giá trị này**, và lý do phải nằm trong comment cạnh `launchMode`
- **Thiếu một thứ không có trong Dart:** iOS cần bật capability **In-App Purchase** trên target `Runner` trong Xcode. Nó không sinh ra từ `pubspec.yaml`, nên nó là một dòng `.pbxproj` — cùng loại diff mà R2 đã làm cho `PrivacyInfo.xcprivacy`
- **Cổng duy nhất trước mọi ad request là `canRequestAds()` của UMP** (Security Review S5), hỏi lại mỗi lần. App **không lưu** trạng thái consent ở bất cứ đâu — trạng thái đó thuộc về UMP, mình chỉ đọc. Đường từ chối đi sang **limited ads**
- **`restoreBackup` không bao giờ tạo hay sửa cache entitlement** (Security Review S4). Quyết định 6 lo chiều đi; đây là chiều về, và nó là con đường giả mạo *không* cần root nếu bỏ sót
- **App khoá cứng non-personalized.** Không nhánh nào, không cờ debug nào, không remote config nào bật personalization lên được. Đây là điều kiện để `NSPrivacyTracking = false` là một lời khai trung thực (G3 số 11), nên nó là ràng buộc kiến trúc chứ không phải một tham số

## Kế hoạch kiểm thử (Test plan)

- **Automated:**
  - `test/ads_reach_test.dart` (mới) — allowlist nguồn cho hai SDK; `Purchases.logIn` cấm mọi nơi; `'premium'` cấm trong `lib/monetization/`. Idiom copy từ `brand_reach_test.dart`
  - `test/entitlement_test.dart` (mới) — cache là nguồn sự thật lúc khởi động; gọi mạng thất bại **không** hạ cờ; một câu trả lời thành công nói entitlement đã mất **thì** hạ; không có cache = chưa mua
  - `test/ads_gate_test.dart` (mới) — với `no_ads` bật, một fake `AdSlot` đếm mọi lời gọi phải dừng ở `0`: không init, không consent, không request. Đây là test giữ lời hứa "người đã trả tiền thì app không chạm mạng"
  - `test/library_ad_slot_test.dart` (mới) — widget test pump `LibraryScreen`: chưa fill thì slot cao `0`; library trống thì không có slot; đã mua thì không có slot; hàng Score cuối vẫn chạm được
  - `test/library_backup_test.dart` (thêm một case) — backup ở trạng thái đã mua, giải nén, khẳng định archive **không** chứa cache entitlement. Hai test cũ của 0027 và test của 0050 phải xanh **không sửa**
  - `test/about_sheet_test.dart` (sửa) — hai hàng mới; Restore khi offline hiện thông báo, không treo
  - Không test nào chạm SDK thật, không test nào cần mạng
- **Manual demo (G4), và nó cần *hai* thiết bị cùng một store account.** Mọi banner thấy được ở G4 đều là **unit test của Google** — AdMob chưa phục vụ unit thật cho một app chưa lên store (ADR 0018 quyết định 13), nên "banner thật hiện ra" **không phải** tiêu chí và đừng chờ nó:
  - Máy A, tài khoản test IAP: mở app → **đếm xem danh sách Score có ở đó trước banner không** → mua `remove_ads` trong sandbox → banner biến mất → kill app, bật chế độ máy bay, mở lại → **vẫn sạch, không nháy**
  - Máy A: mở một Score, chơi 5 phút, quay lại Library — dùng một proxy hoặc network log để xác nhận **không request quảng cáo nào** phát ra trong 5 phút đó (đây là phép kiểm cho phát hiện 3, và nó không nhìn thấy được bằng mắt)
  - Máy B, cùng store account, chưa mua gì: cài → có banner → Restore Purchases → sạch
  - Máy B: backup ở máy A (đã mua) → chuyển sang máy B (chưa mua) → restore → **vẫn còn quảng cáo**
  - Bật VPN EEA trên máy chưa mua: form consent hiện **sau** Library, không phải trước
  - Offline hoàn toàn trên máy chưa mua: slot cao 0, bố cục Library không nhảy khi cuộn
  - `aapt dump permissions` trên AAB release, đọc từng dòng
