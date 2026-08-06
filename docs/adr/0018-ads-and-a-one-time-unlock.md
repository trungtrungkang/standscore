# Quảng cáo sống ở Library và không đi xa hơn; một lần mua để tắt nó

StageScore vẫn **miễn phí và đầy đủ tính năng**. Tiền đến từ hai chỗ: một **banner trong Library**, và một **lần mua duy nhất để tắt banner đó vĩnh viễn**. Không tính năng nào bị khoá — thứ được bán là **sự vắng mặt của quảng cáo**, không phải một năng lực. Đường đang chơi (`PdfMode`, PerformanceMode, Setlist đang chạy) **không bao giờ** có quảng cáo, và không bao giờ chạm mạng vì quảng cáo. **Discover (ADR 0017) chuyển `hold`.**

**Status:** proposed
**Đề xuất bởi:** Agent (2026-07-30), viết theo quyết định Orchestrator chốt cùng ngày
**Đã trả lời ở G2 (2026-07-30):** **cả mười câu.** App **miễn phí có quảng cáo + một IAP** (1), **không cá nhân hoá, không ATT** (3), **AdMob** (6), **RevenueCat** (5, ngược khuyến nghị của agent), **giá hạng ~4,99 USD** (4), và **quảng cáo đi trong 1.1** (2). Câu 2 đổi ba lần trong ngày — 1.1, v1, rồi 1.1 — và chốt cuối đứng trên **dữ kiện mới** chứ không phải đổi ý: quyết định 13 cho thấy ship quảng cáo trong v1 mua về **doanh thu bằng không trong ngày phát hành**. Toàn bộ tier L vì thế **không** nằm trên đường tới hạn của lần phát hành đầu tiên. Bốn câu cuối (7, 8, 9, 10) **Orchestrator uỷ quyền agent trả lời ngày 2026-07-30**, tất cả theo khuyến nghị đã ghi, thành **quyết định 12**; đợt tra cứu đi kèm tìm ra một ràng buộc vòng của AdMob mà không ai biết lúc chốt câu 2, thành **quyết định 13**.
**Tier:** L — có dữ liệu rời máy, có thanh toán → cần G2 accept + **Security Review** trước khi build
**Relates to:** ADR 0008 (parity trước), ADR 0009 (bundle id), ADR 0012 (hai repo), ADR 0017 (Discover — nay `hold`), `RELEASE-CHECKLIST.md` R2 / R7 / R11 / R12 / R22 / R23, `STORE-LISTING.md`, `VISION.md` câu 5

## Bối cảnh (Context)

Log ngày 2026-07-29 để lại monetization ở trạng thái mở với một khuyến nghị **không quảng cáo**, và lý lẽ khi đó là ba thứ đã ký: tuyên bố không thu thập gì, nguy cơ một banner rơi vào giữa buổi diễn, và doanh thu gần bằng không. Orchestrator chốt ngược lại ngày 2026-07-30: **có quảng cáo, và ai không muốn thấy thì mua**. ADR này viết quyết định đó thành ràng buộc thi hành được, và ghi thẳng cái giá thay vì giấu — vì cái giá không nằm ở code mà nằm ở sáu tài liệu và hai form của store.

Một điều phải nói trước, vì nó là lý do quyết định này **đứng vững** dưới chính bộ lọc mà Orchestrator đã dùng để bác bản Pro. Câu bác hôm 2026-07-29 là: một tính năng ngách không đỡ nổi paywall, còn một tính năng ai cũng cần thì khoá nó lại làm app tệ đi cho phần lớn người dùng — đúng hình dạng ScorePDF đang có với Label / Sort / Search / Metronome. Quảng cáo **thoát được cả hai vế**: không tính năng nào bị khoá, nên không có ai bị làm cho tệ đi vì thiếu năng lực, và thứ bán ra — "đừng làm phiền tôi nữa" — thì **mọi** người đều hiểu ngay, không cần là người có nhu cầu ngách. Đó là ưu điểm thật của hướng này và nó không nhỏ.

### Bốn phép đo định giá quyết định này

Không phải cảm nhận, đọc từ repo hôm nay:

| Thứ | Trạng thái hôm nay | File |
|-----|--------------------|------|
| Quyền mạng của bản **release** Android | **Không có.** `INTERNET` chỉ nằm trong `src/debug/AndroidManifest.xml`; manifest `main` không khai quyền nào | `android/app/src/main/AndroidManifest.xml` |
| Manifest privacy iOS | `NSPrivacyTracking` = `false`, `NSPrivacyCollectedDataTypes` = mảng **rỗng** | `ios/Runner/PrivacyInfo.xcprivacy` (+ bản của ShareExtension) |
| Listing đã accepted | "no account, no sign-in, **no ads**, and nothing collected about you or your music"; dòng giá ghi "free, **no in-app purchase** in v1" | `docs/product/STORE-LISTING.md` dòng 5 và 55 |
| Tuyên bố ở repo web | "The app makes **no network requests of its own**"; `/support`: "StageScore collects nothing about you or your music" | `apps/web/src/app/[locale]/privacy/page.tsx:102`, `support/page.tsx:52` |

Dòng đầu là dòng nặng nhất và nó thường bị bỏ qua: **bản release hiện tại không có khả năng gọi mạng.** Đó không phải một lời hứa trên giấy mà là một tính chất của artefact — kiểm được bằng `aapt dump permissions`. Thêm SDK quảng cáo là thêm `android.permission.INTERNET` và `com.google.android.gms.permission.AD_ID` vào bản release, tức lời hứa đổi loại: từ *app không thể* sang *app hứa là không*.

Ba dòng còn lại là công việc phải làm ở **sáu** nơi, không nơi nào có CI bắt giùm (ADR 0012): listing, hai `PrivacyInfo.xcprivacy`, `/privacy` và `/support` bên repo web, và hai form App Privacy / Data safety (R11). R22 vừa tốn nguyên một vòng để làm cho ba thứ đó nói cùng một câu, và R24 để lại đúng cảnh báo cho tình huống này: *đăng lại một privacy policy đã public thì tệ hơn là viết đúng một lần*. Chính sách lên production ngày 2026-07-28.

### Doanh thu quảng cáo ở đây là một con số nhỏ, và điều đó đổi thiết kế chứ không bác quyết định

Bề mặt duy nhất an toàn là Library (quyết định 1), mà Library là **màn hình quá cảnh** — nhạc công mở app để vào một bản nhạc, không để ở lại. Ước lượng bậc độ lớn, không phải phép đo: cỡ 1–3 impression mỗi người mỗi ngày, với eCPM banner non-personalized hạng Music thường nằm trong khoảng vài xu đến dưới một đô cho mỗi nghìn impression. Nghĩa là **một nghìn người dùng hoạt động hằng ngày cho ra chừng một bữa cà phê mỗi tháng**, và một app mới thì chưa có một nghìn người.

Hệ quả **không** phải "vậy thì đừng làm" — Orchestrator đã quyết. Hệ quả là biết đúng banner đang làm việc gì: nó là **lý do để mua**, không phải nguồn thu. Điều đó chốt luôn mọi lựa chọn thiết kế phía dưới. Một banner chỉ cần đủ hiện diện để người ta muốn trả tiền cho nó biến mất; nó không cần tối ưu hoá impression, không cần định dạng hung hãn, không cần quảng cáo cá nhân hoá. Mọi lần đánh đổi trong ADR này đều nghiêng về phía **giữ app tử tế**, vì phía bên kia của cán cân gần như không có gì.

## Các lựa chọn đã cân nhắc (Considered options)

- **Miễn phí toàn bộ, không quảng cáo không mua bán** (trạng thái hôm nay) — bị bác bởi Orchestrator ngày 2026-07-30. Đây là phương án duy nhất giữ nguyên được cả sáu tuyên bố ở trên.
- **Bản Pro khoá tính năng** — đã bị bác 2026-07-29, lý lẽ giữ nguyên giá trị: khoá thứ ai cũng cần thì làm app tệ đi, khoá thứ ngách thì không ai mua.
- **Không SDK quảng cáo; một thẻ "Mở khoá StageScore" tự chạy trong Library** — thẻ do mình vẽ, không mạng, không SDK bên thứ ba, không đổi một chữ nào trong sáu tuyên bố, và làm **đúng công việc mà phần trên vừa nói banner đang làm**: nhắc người ta rằng có thứ để mua. Mất đi phần doanh thu quảng cáo — tức mất một con số nhỏ như đã ước lượng. Đây là phương án rẻ nhất về mọi mặt trừ một mặt: nó không phải thứ Orchestrator chốt. Ghi lại ở đây để bị bác một cách có ý thức chứ không phải vì bỏ sót, và vì nó là chỗ lùi có sẵn nếu câu hỏi 8 đi theo hướng ngược lại — mọi thứ trong ADR này trừ tầng quảng cáo vẫn dùng lại được nguyên vẹn.
- **Subscription** — bác, cùng lý do 2026-07-29: cần chỗ trả lời "còn hạn không", tức cần account, tức phá lời hứa offline.
- **Quảng cáo ở Library + một lần mua để tắt** — **được chọn.**

## Quyết định (Decision)

### 1. Quảng cáo chỉ tồn tại ở Library, và đây là bất biến có test giữ

Bề mặt duy nhất được phép là **màn hình Library**. Không quảng cáo ở: `PdfMode`, PerformanceMode, Setlist đang chạy, bất kỳ sheet nào mở trên một Score, màn hình import, và màn hình chờ khi mở PDF.

Viết thành một bất biến kiểm được, theo đúng idiom test brand của 0042 và test guard token của 0044: **không widget quảng cáo nào được dựng trong cây widget của `PdfModeScreen`**, kiểm ở tầng source cộng một widget test mở Score rồi khẳng định không có ad widget nào trong cây. Lý do nó phải là test chứ không phải kỷ luật: bề mặt Library và bề mặt Score dùng chung `Scaffold`, `AppAppearance` và một số sheet; một slice sau này thêm banner vào một component dùng chung sẽ **không** lộ ra ở review.

### 2. Một định dạng duy nhất: banner tĩnh neo ở đáy Library

Và bốn định dạng bị **cấm đích danh**, vì đây là những thứ mạng quảng cáo sẽ chủ động gợi ý:

- **App-open ad** — nguy hiểm nhất, và nó là định dạng doanh thu cao nhất nên sẽ được chào mời. Nó bắn khi khởi động lạnh **và mỗi lần app quay lại foreground**, tức bao gồm lần quay lại sau khi màn hình khoá giữa buổi diễn. Cấm tuyệt đối.
- **Interstitial** — bất kỳ dạng toàn màn hình nào giữa Library và Score rơi đúng vào đường mà nhạc công đi 30 giây trước khi vào bài.
- **Rewarded** — không có gì để thưởng khi không tính năng nào bị khoá; và nó dựng một nền kinh tế nhỏ mà quyết định 4 vừa cố tránh.
- **Native ad trộn vào danh sách Score** — một hàng trông giống một bản nhạc mà không phải bản nhạc là loại nhầm lẫn tệ nhất ở đây, và nó là hàng bị chạm nhầm nhiều nhất.

### 3. Quảng cáo không được chặn, làm chậm, hay làm nhảy đường Library → Score

Ba ràng buộc cụ thể. **Nạp sau first paint** — danh sách Score vẽ xong rồi banner mới xin quảng cáo, không bao giờ ngược lại. **Cao 0 khi không có fill** — offline là trạng thái bình thường của app này, không phải ca lỗi; slot rỗng phải chiếm đúng 0 pixel, không chỗ giữ chỗ, không skeleton, để bố cục Library không nhảy khi đang cuộn. **Không request nào nằm trên đường mở Score** — mở một bản nhạc không được chờ, huỷ, hay dọn dẹp bất cứ thứ gì của tầng quảng cáo.

### 4. Thứ bán ra tên là "Remove ads", không phải "Pro" — và cái tên là phần không đảo được

Non-consumable, mua một lần, không hạn, không account, không server của mình. Trạng thái đã mua được cache trên máy nên **hoạt động offline vĩnh viễn sau khi mua**; chỉ lúc mua và lúc Restore mới cần mạng. Giá và đường thanh toán ở quyết định 11.

Cái tên quan trọng hơn nó trông có vẻ, và đây là chỗ duy nhất trong ADR này thật sự **không sửa được sau khi ship**. Một SKU tên "Pro" hay "Premium" tạo ra một kỳ vọng mà không văn bản nào rút lại được: người đã mua sẽ tin rằng mọi thứ tính tiền về sau — kể cả BackingTrack nếu ADR 0017 sống lại — đã nằm trong đó. Giá và mô tả thì sửa được, còn *thứ người ta tin mình đã mua* thì không. Nên SKU được đặt tên đúng bằng việc nó làm: **`remove_ads`**, hiển thị là "Remove ads". Câu hỏi 7 phải trả lời **trước khi** SKU được tạo trên store, không phải trước khi build.

### 5. Chỉ quảng cáo không cá nhân hoá; không prompt ATT (chốt ở G2)

Không IDFA, không ATT prompt, chỉ non-personalized ads. Đổi lại eCPM thấp hơn đáng kể — nhưng phần trên đã tính rằng phía doanh thu gần như không có gì để mất, còn phía bên kia mất ba thứ cụ thể: một prompt hệ thống ngay lần đầu mở app, một trường mới trong `PrivacyInfo.xcprivacy` (`NSPrivacyTracking` phải thành `true`), và một mục "Tracking" trong App Privacy — thứ hiển thị công khai trên trang App Store.

Vẫn phải làm consent cho EEA/UK: AdMob yêu cầu một CMP theo chuẩn TCF (Google UMP là bản có sẵn), **kể cả** khi chỉ phục vụ quảng cáo không cá nhân hoá. Đây là một màn hình mới trong app, không phải một dòng config.

**Đính chính một chữ trong đoạn trên, đọc từ tài liệu AdMob ngày 2026-07-30.** "Không IDFA" đúng **trên iOS** và đúng vì một lý do khác với lý do người ta hay nghĩ: không có ATT authorization thì IDFA không lấy được, chứ không phải vì SDK tự kiêng. Nhưng non-personalized ads **vẫn dùng mobile ad identifier** cho frequency capping và báo cáo tổng hợp — chính Google viết vậy. Nên **trên Android, advertising ID vẫn được dùng**, và đó đúng là lý do `AD_ID` xuất hiện trong manifest release. Data safety phải khai theo sự thật đó, không khai theo câu "không cá nhân hoá nên không thu gì".

Còn một chế độ thứ ba đáng biết vì nó là lối thoát đúng cho người EEA **từ chối** ở màn hình consent: **limited ads (LTD)**, phục vụ không dùng định danh nào. Đường xử lý từ chối là chuyển sang LTD, không phải tắt quảng cáo hẳn và cũng không phải hỏi lại.

**Câu `NSPrivacyTracking` tự giải, và lời giải là một suy luận chứ không phải một phép tra.** Hai nguồn thứ cấp nói ngược nhau, nhưng chỉ một tổ hợp đứng vững: khai `NSPrivacyTracking = true` thì **bắt buộc phải có ATT prompt** trước mọi request quảng cáo (App Review 5.1.2 — khai tracking mà không hỏi là lỗi bị từ chối). Quyết định 5 đã cấm ATT. Vậy manifest của **app** phải là `false`, và điều kiện để `false` đó trung thực là app **thật sự khoá cứng non-personalized** — không có nhánh code nào bật personalization lên được. Đó là ràng buộc thi hành được cho Spec, không phải một ô cần điền.

Điều đó **không** miễn cho việc đọc: SDK của Google mang privacy manifest **của riêng nó**, khai tracking và liệt kê `NSPrivacyTrackingDomains`, và Apple gộp nó vào privacy report của bản archive. Nên vẫn phải làm đúng một việc, sau khi thêm dependency chứ không phải trước: đọc `PrivacyInfo.xcprivacy` **bên trong** `GoogleMobileAds.xcframework` và của RevenueCat, rồi sinh Privacy Report từ bản archive trong Xcode và điền `NSPrivacyCollectedDataTypes` của app theo báo cáo đó. Hai lỗi phát hành hay gặp ở đúng chỗ này là `ITMS-91053` và `ITMS-91061`, và cách chữa `ITMS-91061` không nằm trong code mình mà là **nâng version SDK** lên bản có mang manifest (Google Mobile Ads từ `11.2.0` trở lên).

### 6. Cờ đã mua không đi theo backup

`LibraryBackup` (0027 / 0050) **không** ghi cờ `remove_ads`, và `restoreBackup` không đọc nó. Lý do đơn giản: một file backup được gửi qua lại giữa các nhạc công sẽ mang theo quyền đã mua. Đường đúng để lấy lại trên máy mới là Restore Purchases (quyết định 7), không phải backup. Không cần bump `formatVersion` — đây là chuyện *không thêm* một field, không phải đổi format.

### 7. Restore Purchases là bắt buộc, và nó sống trong About sheet

Apple guideline 3.1.1 buộc phải có đường khôi phục cho non-consumable. Đặt trong About sheet (0042) cạnh version và các link, cộng một lối vào từ Library ⋯ nơi đã có `appearance` / `backup` / `restore` / `about`. Phạm vi lấy lại là **store account**, nên đổi máy cùng Apple ID hoặc Google account thì được, còn **đổi nền tảng iOS ↔ Android thì không** — cùng ranh giới mà ADR 0017 quyết định 5 đã ghi.

### 8. Bảy tuyên bố phải đổi trong cùng một đợt, và **không được đổi trước** bản build có quảng cáo

Không được để bản build có SDK quảng cáo đi trước tài liệu, dù chỉ một vòng TestFlight. Và sau khi quyết định 10 chốt lại là **1.1**, ràng buộc thứ hai quay lại và nó nghiêm hơn: **cũng không được để tài liệu đi trước bản build.** Kể từ ngày v1 lên store, bảy dòng dưới đây đang mô tả **một app đang được phát hành**; sửa chúng sớm là làm cho chúng nói sai về chính bản app người ta đang tải về. Cả bảy đi **một lần duy nhất, trọn gói, ngay trước khi submit 1.1**. Danh sách đầy đủ, cả hai repo:

| # | Nơi | Đổi gì |
|---|-----|--------|
| 1 | `STORE-LISTING.md` | Viết lại khối "Yours, on the device" và dòng giá. Đây là **copy đã được Orchestrator accept ngày 2026-07-28**, nên bản mới cần accept lại — xem câu hỏi 10 |
| 2 | `ios/Runner/PrivacyInfo.xcprivacy` | Khai các loại dữ liệu SDK quảng cáo thu thập; `NSPrivacyTrackingDomains` nếu áp dụng |
| 3 | `ios/ShareExtension/PrivacyInfo.xcprivacy` | Giữ rỗng — extension không có quảng cáo; ghi chú lý do để lần sau không ai "đồng bộ" nhầm |
| 4 | `apps/web/.../privacy/page.tsx:102` | Câu "makes no network requests of its own" nay **sai** |
| 5 | `apps/web/.../support/page.tsx:52` | "collects nothing about you or your music" nay **sai** |
| 6 | R11 — App Privacy + Data safety | Cả hai form; Play thêm nhãn **"Contains ads"** hiển thị trên trang store |
| 7 | `app-ads.txt` ở gốc `backingscore.com` | Mới, sinh ra từ quyết định 10: khai `com.backingscore.scoreapp` được phép bán inventory dưới tên miền này. Cũng ở repo web |

Mục 4, 5 và 7 nằm ở repo khác và không có CI nào nối hai bên (ADR 0012), nên chúng phải được kiểm bằng tay ở checklist submit chứ không phải nhớ.

### 9. Discover (ADR 0017) chuyển `hold`

Không cắt, không bác — giữ nguyên số, giữ nguyên mười quyết định và bộ câu hỏi G2 đã trả lời được năm. Lý do nó dừng đúng lúc này: đường tới hạn của Discover là **tốc độ sản xuất bản nhạc**, không phải tốc độ build, và danh mục hiện là con số không. Quảng cáo cộng một lần mua không cần một bản nhạc nào cả.

Một hệ quả phải ghi để lần mở lại không bị vấp: nếu Discover sống lại thì lúc đó app có **hai** thứ bán, và câu hỏi "người đã mua remove-ads có được gì ở đó không" phải được trả lời **ngay lúc đặt tên SKU hôm nay** (quyết định 4), không phải lúc đó.

### 10. Quảng cáo và `remove_ads` đi trong **1.1**, không đi trong `1.0.0` (chốt lại lần cuối 2026-07-30)

Câu này đổi ba lần trong một ngày — 1.1, rồi v1, rồi 1.1 — nên phải ghi rõ **vì sao lần thứ ba khác hai lần đầu**: hai lần đầu là cân nhắc trên cùng một bộ dữ kiện, lần thứ ba là **dữ kiện mới**. Quyết định 13 (AdMob không phục vụ quảng cáo cho app chưa lên store) chỉ được phát hiện *sau* khi chọn v1, và nó rút cạn phần lợi của lựa chọn đó.

**Lập luận đóng lại gọn thế này.** Ship quảng cáo trong v1 mua về **doanh thu bằng không trong ngày phát hành** — không phải "ít", mà bằng không, vì AdMob không phục vụ cho tới khi app đã publish, `app-ads.txt` đã được crawl và xác minh, và app readiness review đã xong. Đổi lại, nó đặt lên trước ngày phát hành: toàn bộ chuỗi tuần tự G2 → Security Review → build → G4, hai SDK bên thứ ba, một màn hình consent, quyền `INTERNET`, và **hồ sơ thuế cộng ngân hàng có thể mất tới 90 ngày** (R25). Trả một chuỗi tuần tự dài vài tuần tới vài tháng để đổi lấy không đồng nào là một trao đổi không có vế được.

**Cái mất khi lùi lại, ghi thẳng vì nó có thật.** Bảy tuyên bố của quyết định 8 nay phải đúng **hai lần**: đúng cho v1 (miễn phí, không quảng cáo, không IAP — tức đúng như hôm nay) rồi viết lại cho 1.1. Đó chính là lý do đã dùng để chọn v1 ở lượt trước, và nó không biến mất. Nhưng nó là **công việc soạn thảo**, còn thứ vừa tránh được là **thời gian chờ của bên thứ ba** — hai loại chi phí không cùng hạng.

**Hệ quả: cảnh báo "đừng sửa sớm" quay lại, và lần này nó nghiêm hơn.** Kể từ lúc v1 lên store, sáu tuyên bố đó **mô tả một app đang được phát hành**. Sửa chúng trước 1.1 là làm cho tài liệu nói sai về chính bản app người ta đang tải. Không đụng vào chúng cho tới khi build 1.1 sẵn sàng submit. Khối cảnh báo ở đầu `STORE-LISTING.md` được khôi phục.

**Và cả tier L rời khỏi lần ra mắt.** v1 không SDK bên thứ ba, không thanh toán, không consent, không byte nào rời máy — nó quay về đúng app mà `PrivacyInfo.xcprivacy` và listing đang mô tả. Security Review của ADR này canh **1.1**; một lần từ chối của Apple, nếu có, rơi vào bản cập nhật thay vì bản ra mắt.

**Hai việc vẫn nên khởi động ngay dù không còn chặn v1**, vì chúng chờ bên thứ ba chứ không chờ mình và hồ sơ làm sớm thì vẫn dùng được: **R25** (thuế + ngân hàng, lead time dài nhất, có thể tới 90 ngày) và **R27** (project RevenueCat dưới `com.backingscore.scoreapp`). **R26** (AdMob + `app-ads.txt`) thì ngược lại — quyết định 13 nói nó *không thể* hoàn tất trước khi app lên store, nên nó tự nhiên thuộc về sau v1.

**Một ràng buộc rẻ cho R12, và bây giờ nó rẻ thật:** ảnh chụp store không được có quảng cáo của bên thứ ba trong khung. v1 chưa có quảng cáo nên không ảnh nào vi phạm; việc duy nhất cần làm là **đóng khung ảnh Library sao cho khi banner xuất hiện ở 1.1 thì chỉ phải chụp lại một ảnh, không phải cả bộ sáu**.

### 11. AdMob cho quảng cáo, RevenueCat cho thanh toán, giá hạng ~4,99 USD (chốt ở G2)

**Quảng cáo: AdMob** qua `google_mobile_ads`, plugin Flutter chính chủ duy nhất còn được bảo trì; Google UMP làm CMP cho EEA/UK như quyết định 5 đã đòi.

**Thanh toán: RevenueCat**, ngược khuyến nghị `in_app_purchase` trần của agent. Ghi lại cái được và cái mất, vì cả hai đều thật. Được: nếu Discover mở lại thì ADR 0017 quyết định 5 đã chọn đúng RevenueCat với anonymous app user ID, nên không có hạ tầng thanh toán thứ hai phải dựng, và Restore Purchases cùng việc thẩm định receipt không phải tự viết. Mất: **một SDK bên thứ ba nữa gửi dữ liệu ra khỏi máy**, tức thêm một mục trong cả hai form privacy và thêm một hạng mục cho Security Review — quyết định này không đứng một mình với AdMob, nó cộng vào.

Ba ràng buộc cụ thể, và cả ba sinh ra từ việc repo web **đã dùng RevenueCat theo một mô hình danh tính khác hẳn**:

- **Không đăng nhập.** StageScore dùng **anonymous app user ID**; tuyệt đối không gọi `Purchases.logIn`. Prototype Ionic gọi `Purchases.logIn({ appUserID: String(data.user.id) })` (`SubscriptionProvider.tsx:46`) vì bên đó quyền gắn với account — đó là mô hình của web, không phải của app này.
- **Entitlement tên riêng, không dùng lại `premium`.** Prototype đọc `customerInfo.entitlements.active['premium']` (dòng 122), và `premium` bên web nghĩa là mở toàn danh mục. StageScore đặt **`no_ads`**. Dùng chung một cái tên cho hai nghĩa là loại lỗi không bao giờ lộ ra lúc build và lộ ra khi có người mua.
- **Project RevenueCat riêng cho StageScore.** Hai mô hình danh tính không sống chung sạch sẽ trong một project: một bên là customer gắn `users.id`, bên kia là customer ẩn danh không bao giờ được gộp. Webhook `/api/webhooks/revenuecat` bên web hiện inert vì thiếu `REVENUECAT_WEBHOOK_SECRET`, nhưng khi nó được bật thì event từ StageScore sẽ về **không có `userId`** — tách project là cách rẻ nhất để chuyện đó không bao giờ xảy ra.

**Giá: hạng ~4,99 USD**, đặt riêng cho VN ở mức tương đương ~119.000₫ thay vì để store tự quy đổi. Một lần, vĩnh viễn.

### 12. Bốn câu cuối của G2, trả lời cùng một lượt (Orchestrator uỷ quyền agent, 2026-07-30)

**Câu 7 — người mua `remove_ads` hôm nay không được gì thêm nếu BackingTrack được bán sau này.** SKU mua đúng thứ nó tên: sự vắng mặt của quảng cáo, vĩnh viễn, không hạn. Nội dung tính tiền về sau — nếu ADR 0017 sống lại — có **entitlement riêng**, và `no_ads` không mở nó.

Một hệ quả suy ra được mà không ai viết, và nó phải được viết vì nó đi *ngược* hướng người ta hay đọc: lời hứa là **"không quảng cáo"**, không phải "không quảng cáo ở Library". Nếu Discover sống lại và các màn hình của nó có quảng cáo cho người chưa mua, thì `no_ads` **cũng phải tắt luôn ở đó**. Cái tên là ranh giới theo cả hai chiều — nó không mở nội dung, và nó cũng không co lại về một màn hình.

**Câu 8 và 10 — chấp nhận mất câu "no ads", và duyệt bản copy mới.** Khối "Yours, on the device" viết lại đúng như bản nháp ở câu hỏi 10, cộng dòng giá ở đầu file. Cả hai đã vào `STORE-LISTING.md`; trạng thái "copy accepted" của file phục hồi với ngày mới.

Lý lẽ để chấp nhận, chứ không phải chỉ ghi nhận thiệt hại: khối đó mạnh vì nó **cụ thể**, không vì nó dài. Ba vế cũ có một vế nay sai; giữ lại hai vế còn đúng ("no account, no sign-in", "nothing about your music leaves the device") rồi **nói thẳng vế mới ngay tại chỗ** thì khối vẫn cụ thể. Thứ làm nó yếu đi sẽ là giấu quảng cáo xuống cuối mô tả — đó mới là chỗ người đọc thấy mình bị gài.

**Câu 9 — ảnh Library chụp ở trạng thái đã mua.** Đóng khung để banner ra ngoài bị loại vì ảnh Library vốn đã dày nhất bộ sáu. Quyết định 13 làm câu này gần như không còn răng — lúc submit sẽ **không có quảng cáo nào để mà lọt vào khung** — nhưng giữ nguyên câu trả lời, vì một quy tắc chụp ảnh không nên phụ thuộc vào một trạng thái tạm thời của tài khoản AdMob.

### 13. AdMob không phục vụ quảng cáo cho một app chưa lên store, nên **v1 ra mắt với tầng quảng cáo không phục vụ gì** (phát hiện 2026-07-30)

Đây là ràng buộc **vòng**, và nó không lộ ra từ phía codebase lẫn từ phía ADR:

1. Từ **tháng 1/2025**, mọi app mới tạo trong AdMob **bắt buộc phải được xác minh bằng `app-ads.txt`**, và app chưa xác minh thì *"won't be able to fully serve ads"*.
2. Xác minh `app-ads.txt` đòi AdMob **crawl được developer website từ listing trên store** — nên nó đòi app **đã publish**. Tài liệu AdMob trả lời thẳng: *"to allow the Google crawler to successfully crawl your developer website from your Google Play or App store listing, you need to first publish your app"*.
3. Sau khi `app-ads.txt` xác minh xong còn một bước nữa, **app readiness review** của AdMob.

Nghĩa là **không có thứ tự nào cho phép v1 lên store mà đã phục vụ quảng cáo**. Doanh thu bắt đầu sau ngày phát hành, không phải vào ngày phát hành — sớm nhất là 24 giờ sau khi listing live, thực tế lâu hơn vì còn app readiness review.

Ba hệ quả, và phần lớn là tin tốt:

- **Trạng thái ra mắt của app là "slot cao 0".** Quyết định 3 viết ràng buộc *không có fill thì chiếm đúng 0 pixel* như một ca biên; nó **không phải ca biên, nó là ngày ra mắt**. Đây là tiêu chí G4 quan trọng nhất của Spec 0051, không phải một mục phụ.
- **Rủi ro "bị từ chối vì quảng cáo" của quyết định 10 nhẹ đi thật.** Cả Apple lẫn Google review một bản build **không hiển thị quảng cáo nào**. Vẫn phải khai "Contains ads" và vẫn phải có consent EEA — khai theo **năng lực** của app, không theo thứ reviewer nhìn thấy — nhưng ba loại từ chối hay gặp mà quyết định 10 lo thì hai loại mất đất.
- **Marketing URL không còn là chuyện trình bày.** AdMob crawl theo **hostname** của developer website trong listing. `https://backingscore.com/stagescore` (ADR 0011) có hostname đúng, nên `app-ads.txt` ở `https://backingscore.com/app-ads.txt` là đúng chỗ — nhưng trường đó **phải được điền**, và bên Apple nó là *Marketing URL*, bên Play là *App support*. Bỏ trống là mất doanh thu quảng cáo vĩnh viễn mà không có thông báo nào.

## Hệ quả (Consequences)

- **Bản release Android nhận quyền mạng lần đầu.** `INTERNET` cộng `AD_ID` vào manifest `main`. Tính chất "app không thể gọi mạng" — thứ kiểm được từ bên ngoài bằng `aapt dump permissions` — mất vĩnh viễn, đổi thành một lời hứa phải tin. Đây là mất mát lớn nhất của quyết định này và nó không mua lại được bằng cách gỡ SDK sau.
- **AAB phình thêm, nay từ hai SDK.** Đang 71 MB với cảnh báo strip symbol chưa xử lý (R18). Google Mobile Ads kéo theo một phần Play Services, RevenueCat cộng thêm phần của nó; chưa đo, nhưng R18 chuyển từ "không chặn" sang "nên đo lại".
- **Một màn hình consent mới là bề mặt UI đầu tiên nhiều người dùng EEA nhìn thấy.** Nó đứng trước Library, tức trước bản nhạc.
- **Cần một đường kiểm thử "người đã mua".** Khi `no_ads` đang hiệu lực, mọi thứ thuộc tầng quảng cáo phải **không được khởi tạo** — không SDK init, không consent, không request. Không phải chỉ ẩn banner: người đã trả tiền thì app quay lại đúng trạng thái không-chạm-mạng của hôm nay, và đó là thứ đáng được một test.
- **Đăng lại privacy policy lần thứ hai trong ba ngày** (R22 lên production 2026-07-28). R24 đã cảnh báo đúng tình huống này. Không tránh được, nhưng nên gộp một lần cùng phần R24 còn treo.
- **Tier L → Security Review trước khi build, và nó canh 1.1 chứ không canh ngày ra mắt** (quyết định 10). Đã chạy 2026-07-30 — `docs/security/0051-ads-and-remove-ads.md`, **pass có điều kiện**, cố ý chưa đóng. Tối thiểu năm hạng mục sau quyết định 11: **hai** SDK thật sự gửi gì đi (đọc manifest privacy Google và RevenueCat công bố, không đọc trang marketing), đường consent có đúng chuẩn EEA/UK không, trạng thái `no_ads` cache ở đâu và giả mạo được dễ đến đâu, xác nhận không có lời gọi mạng nào trên đường mở Score, và xác nhận project RevenueCat của StageScore tách khỏi project của web.
- **Câu hỏi 6 của ADR 0017 nhảy từ "việc dọn dẹp về sau" thành blocker của v1.** Cấu hình RevenueCat, sản phẩm IAP và entitlement `premium` đang gắn với bundle `com.backingscore.app` của prototype Ionic. Chừng nào 0018 còn chọn `in_app_purchase` trần thì chuyện đó không liên quan; chọn RevenueCat thì nó nằm chắn đường — phải có project và sản phẩm dưới `com.backingscore.scoreapp` trước khi bán được đồng nào. Đây là chi phí của quyết định 11 mà không hiện ra lúc chọn.
- **Đường tới hạn của v1 giữ nguyên chủ.** Blocker còn lại của v1 vẫn toàn là việc người và vẫn chạy song song được (R5 trademark, R6 logo, R12 screenshot, R16 smoke test). Chuỗi tuần tự mà ADR này sinh ra — G2 accept → Security Review → build → G4 → bảy tài liệu → submit — nằm trọn trong **1.1**.
- **Hai việc giấy tờ vẫn nên khởi động ngay dù không còn chặn v1**, vì chúng chờ bên thứ ba chứ không chờ mình: hồ sơ thuế + ngân hàng (R25, lead time dài nhất, xử lý form thuế có thể tới **90 ngày**, và chưa active thì **không tạo được** sản phẩm IAP) và project RevenueCat dưới `com.backingscore.scoreapp` (R27). **R26 thì không** — quyết định 13 nói nó không thể hoàn tất trước khi app lên store, nên nó thuộc về sau v1 một cách tự nhiên.
- **Doanh thu quảng cáo bắt đầu *sau* ngày phát hành 1.1, không phải vào ngày đó** (quyết định 13). Ước lượng "một bữa cà phê mỗi tháng ở mức nghìn DAU" vì thế còn lùi thêm một quãng ở giai đoạn đầu — không đổi kết luận, nhưng đổi kỳ vọng: thứ kiếm được tiền trong tuần đầu của 1.1 là `remove_ads`, mua bởi những người **chưa từng thấy một quảng cáo nào**. Một lý do nữa để đường mua đứng vững bằng chữ chứ không chỉ bằng sự khó chịu của banner.
- **R7 và `VISION.md` câu 5 đóng thành hai nhịp:** v1 là app **miễn phí, không quảng cáo, không IAP** — đúng thứ `STORE-LISTING.md` đang mô tả, nên không một chi tiết nào của lần submit đầu tiên phải đổi. ADR này là câu trả lời cho **1.1**.
- **`STORE-LISTING.md` mất trạng thái "copy đã accepted".** Khối "Yours, on the device" hôm nay đúng ba vế — không account, không quảng cáo, không thu thập gì — và quyết định này làm sai hai trong ba. Bản viết lại phải qua tay Orchestrator lần nữa (câu hỏi 10), nên nó là một hạng mục có gate chứ không phải một lần sửa chữ.
- **Không đụng ADR 0008.** Không có gì ở đây chạm SmartMode, Transport, BackingTrack hay OMR.

## Câu hỏi cho Orchestrator ở G2

1. ~~**"Mua app" nghĩa là gì?**~~ **Đã trả lời (2026-07-30): app miễn phí có quảng cáo, cộng một IAP để tắt quảng cáo.** Hai cách đọc kia bị loại: app trả tiền trước (mất hoàn toàn kênh cài đặt tự nhiên) và hai SKU rời (hai listing, hai build, không có đường nâng cấp từ bản free).
2. ~~**Quảng cáo vào v1 hay 1.1?**~~ **Đã trả lời: v1** — Orchestrator xét lại trong ngày, ngược với khuyến nghị 1.1 của agent. Thành quyết định 10. Hệ quả hai chiều: sáu tuyên bố được sửa **một lần** thay vì hai (vì chưa có bản nào trên store để mà nói sai), đổi lại cả khối tier L cộng ba việc giấy tờ có lead time dài rơi vào đường tới hạn của lần phát hành đầu tiên.
3. ~~**Cá nhân hoá hay không?**~~ **Đã trả lời: không** — không ATT, chỉ non-personalized. **Phần còn mở của nó đã đóng ngày 2026-07-30** bằng một suy luận chứ không phải một phép tra: khai `NSPrivacyTracking = true` thì bắt buộc phải có ATT prompt (App Review 5.1.2), mà ATT đã bị cấm — nên manifest của app là **`false`**, và điều kiện để nó trung thực là app khoá cứng non-personalized. Xem đính chính trong quyết định 5, gồm cả việc NPA **vẫn dùng** advertising ID trên Android.
4. ~~**Giá bao nhiêu?**~~ **Đã trả lời: hạng ~4,99 USD**, VN đặt riêng ~119.000₫ chứ không để store tự quy đổi. Quyết định 11.
5. ~~**Đường thanh toán?**~~ **Đã trả lời: RevenueCat**, ngược khuyến nghị `in_app_purchase` trần của agent. Quyết định 11 ghi cả cái được (không phải dựng hạ tầng thứ hai nếu Discover mở lại) lẫn cái mất (một SDK bên thứ ba nữa gửi dữ liệu ra ngoài, cộng vào cùng chỗ với AdMob trong form privacy và Security Review), cộng ba ràng buộc để không đụng vào mô hình danh tính của repo web.
6. ~~**Mạng quảng cáo nào?**~~ **Đã trả lời: AdMob** (`google_mobile_ads`), UMP làm CMP. Quyết định 11.
7. ~~**Người mua "Remove ads" hôm nay có được gì nếu BackingTrack được bán sau này?**~~ **Đã trả lời: không** (2026-07-30, Orchestrator uỷ quyền agent) — quyết định 12. Kèm một ràng buộc suy ra được theo chiều ngược lại: lời hứa là "không quảng cáo", không phải "không quảng cáo ở Library", nên `no_ads` phải có hiệu lực ở **mọi** bề mặt sau này có quảng cáo.
8. ~~**Chấp nhận mất câu "no ads" trong listing?**~~ **Đã trả lời: chấp nhận** — quyết định 12, gộp với câu 10. Khối copy mạnh vì **cụ thể**, không vì dài: giữ hai vế còn đúng và nói thẳng vế mới ngay tại chỗ thì nó vẫn cụ thể; thứ làm nó yếu đi sẽ là giấu quảng cáo xuống cuối mô tả.
9. ~~**Ảnh Library của R12 chụp ở trạng thái nào?**~~ **Đã trả lời: trạng thái đã mua** — quyết định 12. Quyết định 13 làm câu này gần như không còn răng (lúc submit chưa có quảng cáo nào để lọt vào khung), nhưng câu trả lời giữ nguyên: một quy tắc chụp ảnh không nên phụ thuộc vào trạng thái tạm thời của một tài khoản AdMob.
10. ~~**Duyệt lại copy của `STORE-LISTING.md`.**~~ **Đã trả lời: bản nháp được duyệt** — quyết định 12. Khối "Yours, on the device" và dòng giá đã viết lại trong file; `STORE-LISTING.md` phục hồi trạng thái *copy accepted* với ngày 2026-07-30.

**Không còn câu hỏi mở ở G2.** Việc còn lại của gate này là một chữ ký: Orchestrator chuyển ADR sang `accepted`, rồi Security Review chạy — năm hạng mục ở Hệ quả, cộng hai hạng mục mới sinh ra hôm nay: **`no_ads` phải tắt quảng cáo ở mọi bề mặt tương lai** (quyết định 12) và **app khoá cứng non-personalized, không có nhánh nào bật personalization** (điều kiện để `NSPrivacyTracking = false` là trung thực).
