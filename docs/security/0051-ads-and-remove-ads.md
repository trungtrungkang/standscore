# Security Review — ADR 0018 / Spec 0051 (quảng cáo + `remove_ads`)

- **Đối tượng:** ADR 0018 (11+2 quyết định) và Spec 0051 (`proposed`)
- **Tier:** L — hai SDK bên thứ ba gửi dữ liệu rời máy, cộng thanh toán
- **Ngày:** 2026-07-30 · **Người review:** Agent (Opus-class, ADR 0016 — "dữ liệu rời máy" là sàn không hạ)
- **Kết luận:** **pass có điều kiện** — 3 điều kiện chặn build, 5 điều kiện chặn submit, và **review này cố ý chưa đóng** (xem S10)
- **Loại review:** đây là review **thiết kế**, không phải review diff. Chưa có dòng code nào; thứ được soi là ADR, Spec và trạng thái repo hôm nay
- **Áp cho bản nào:** **1.1.** Quảng cáo lùi khỏi v1 cùng ngày review này chạy (ADR 0018 quyết định 10). Không một finding nào dưới đây chạm tới v1 — v1 không SDK bên thứ ba, không thanh toán, không consent, không byte nào rời máy. Review giữ nguyên giá trị vì thiết kế không đổi, chỉ lùi lịch

Đây là Security Review đầu tiên của repo (ADR 0013 mượn khái niệm từ mô hình repo web mà chưa có tiền lệ ở đây), nên định dạng này là đề xuất chứ không phải chuẩn đã có.

## Phạm vi (Scope)

Bảy hạng mục bắt buộc: năm ở phần Hệ quả của ADR 0018, cộng hai sinh ra từ quyết định 12 và 13. Ngoài bảy hạng mục đó tôi soi thêm bốn bề mặt mà không văn bản nào chỉ định — S1, S2, S3 và S9 đều đến từ đó, và ba trong bốn cái nặng hơn phần lớn danh sách bắt buộc.

## Phát hiện (Findings)

### S1 · Cao · RevenueCat được khởi tạo cho cả người **không bao giờ** mua gì

ADR viết một nguyên tắc rất đúng ở phần Hệ quả — *người đã mua thì tầng quảng cáo không được khởi tạo chút nào* — nhưng không ai viết **vế soi gương của nó**, và vế đó mới là vế ảnh hưởng tới đa số người dùng: theo Spec 0051 như đang viết, `Purchases.configure` chạy lúc khởi động cho **mọi** người, kể cả người sẽ không bao giờ chạm vào nút mua.

Điều đó có nghĩa mở app là gửi anonymous app user ID cộng metadata thiết bị cho một bên thứ ba, **trước khi có bất kỳ giao dịch nào**, và với người ngoài EEA thì không có cổng consent nào đứng trước (UMP canh quảng cáo, không canh RevenueCat). Với người trong EEA thì cơ sở pháp lý cho một người chưa bao giờ mua gì là chỗ yếu nhất có thể chọn.

**Khuyến nghị — khởi tạo lười, và nó gần như không tốn gì.** Chỉ `configure` RevenueCat khi một trong hai điều xảy ra: cache nói **đã mua** (cần làm tươi), hoặc người dùng **chủ động** chạm "Remove ads" / "Restore purchases". Người không mua thì không có một byte nào đi tới RevenueCat, suốt đời cài đặt.

Cái giá đúng bằng **không**, và đó là lý do tôi để nó ở mức Cao thay vì "đáng cân nhắc": ca duy nhất bị ảnh hưởng — mua ở máy A, cài lên máy B — **đã** cần Restore Purchases theo quyết định 7 rồi. Khởi tạo sớm không cứu được ca đó, nó chỉ đánh đổi quyền riêng tư của tất cả mọi người lấy không gì cả.

→ **Chặn build.** Spec 0051 phải sửa: phần "Trong phạm vi" và "Ràng buộc kỹ thuật".

### S2 · Cao · "Age rating 4+/Everyone" và "target audience" là **hai** form khác nhau, và nhầm chúng làm hỏng toàn bộ thiết lập quảng cáo

`STORE-LISTING.md` ghi *Age rating: 4+ / Everyone*. Play còn hỏi một câu **riêng** là **Target audience and content**. Nếu khai nhóm tuổi dưới 13, app rơi vào **Families policy**: `AD_ID` phải bị **gỡ khỏi manifest**, chỉ được dùng ad SDK đã chứng nhận, và không được phục vụ quảng cáo theo cách đang thiết kế.

Đây là loại bẫy tệ nhất trong cả hồ sơ: một app nhạc, rating "Everyone", người điền form đang nghĩ tới học sinh — cú click sai hoàn toàn tự nhiên, và hệ quả của nó không hiện ra cho tới khi quảng cáo không phục vụ hoặc app bị gỡ.

**Khuyến nghị:** khai target audience là **13+**, có chủ đích, và ghi câu đó vào R12 cạnh dòng age rating để lần điền form không phải nhớ. Content rating "Everyone" **không** mâu thuẫn với target audience 13+ — chúng đo hai thứ khác nhau.

→ **Chặn submit** (R11 + R12), không chặn build.

### S3 · Trung bình · Quyền mạng mới không có ai canh sau lần kiểm đầu tiên

Sau slice này manifest release có `INTERNET`. Rủi ro thật không phải hai SDK hôm nay — chúng đã được soi — mà là **dependency thứ ba của một năm sau**: quyền đã có sẵn, nên một plugin mới gọi mạng sẽ không làm đỏ bất cứ thứ gì và sẽ không hiện ra ở review nào.

Spec 0051 để việc kiểm ở `aapt dump permissions` như một bước **thủ công** ở G4. Một bước thủ công chạy đúng một lần rồi mục.

**Khuyến nghị:** một script trong `tool/` đọc AAB đã build và so bộ quyền với một danh sách kỳ vọng ghi trong chính script, chạy như một dòng của quy trình phát hành. Cộng một luật: **allowlist trong `ads_reach_test.dart` không được thêm file nào nếu không có ADR** — allowlist là nơi rào chắn này sẽ bị nới, và nới nó phải là một dòng đọc được trong diff.

### S4 · Trung bình → thấp sau khi kiểm · Cache entitlement giả mạo được, và chấp nhận được

Hạng mục bắt buộc số 3. Cờ `no_ads` là một file JSON ở `<documents>/`, sửa được nếu người dùng với tới được thư mục đó.

Kiểm thực tế hạ mức nghiêm trọng: `UIFileSharingEnabled` **không có mặt** trong `Info.plist` và `LSSupportsOpeningDocumentsInPlace` là `false`, nên thư mục Documents **không duyệt được** từ Finder trên iOS; trên Android nó nằm trong vùng riêng của app. Nên đường giả mạo đòi máy đã jailbreak/root hoặc thao tác trên file backup của thiết bị.

**Chấp nhận, và ghi lý do vào Spec chứ không im lặng:** thứ được bảo vệ trị giá ~5 USD, còn mọi biện pháp bảo vệ thật (kiểm quyền phía server, ký cờ bằng khoá thiết bị) đều đắt hơn giá trị đó và cái đầu tiên **phá lời hứa offline** — thứ đắt hơn nhiều lần toàn bộ doanh thu đang bàn.

Một điều kiện đi kèm và nó **không** được bỏ: đường `restoreBackup` **không bao giờ** được tạo hay sửa file cache. Quyết định 6 đã đòi cờ không đi theo backup; điều này là mặt còn lại của cùng một yêu cầu, vì phục hồi một backup do người khác gửi mà ghi được cờ thì đó là con đường giả mạo *không* cần root. Spec 0051 đã có test cho chiều thứ nhất; thêm khẳng định cho chiều thứ hai.

### S5 · Trung bình · Consent phải do UMP quyết, không do mình cache

Hạng mục bắt buộc số 2. Rủi ro không phải kỹ thuật mà là pháp lý, và hình dạng hỏng thường gặp là tự nuôi một `bool hasConsent` để "khỏi hỏi lại".

**Khuyến nghị, viết thành ràng buộc kiến trúc:** cổng duy nhất trước mọi ad request là **`canRequestAds()` của UMP**, hỏi lại mỗi lần; app **không lưu** trạng thái consent ở bất cứ đâu; và đường từ chối đi sang **limited ads** như G3 số 6 đã chốt, không phải tắt hẳn. Trạng thái consent thuộc về UMP — mình chỉ đọc.

### S6 · Trung bình · Hai credential không bao giờ được vào repo, và hai key khác thì được

Bốn thứ sinh ra từ track C của runbook, dễ nhầm lẫn theo cả hai chiều:

| Thứ | Đi đâu |
|---|---|
| App Store Connect **In-App Purchase key** (`.p8`) | **Chỉ** dashboard RevenueCat. Apple cho tải **một lần** |
| Google Cloud **service account JSON** | **Chỉ** dashboard RevenueCat |
| Hai **public SDK API key** của RevenueCat | Vào source, có tên nói rõ là public |
| **AdMob App ID** | Vào `AndroidManifest.xml` / `Info.plist`, công khai theo thiết kế |

Hai chiều nhầm đều thật: đưa `.p8` vào repo là rò credential nghiêm trọng; còn "bảo vệ" hai public key bằng cách giấu chúng vào một file gitignored sẽ làm **bản clone mới không build được** — đúng hình dạng cái bẫy mà `android/key.properties` đã đặt ra một lần rồi (R1). Nên đặt tên chúng là `publicSdkKey` chứ không phải `apiKey`.

### S7 · Thấp · Thất bại của SDK không được chặn Library

Nếu `configure` hay `initialize` ném lỗi (mạng lạ, store lỗi, thiết bị không có Play Services), Library vẫn phải mở bình thường. Quy tắc: mọi lời gọi tới hai SDK đều bọc, thất bại nghĩa là **coi như chưa mua** và **không** có hộp thoại nào — trừ đúng một chỗ, Restore Purchases do người dùng chủ động bấm, nơi im lặng mới là hành vi sai.

### S8 · Thấp · Project RevenueCat của StageScore không được trỏ vào webhook của repo web

Hạng mục bắt buộc số 5. Quyết định đã đúng (project tách rời); phần cần kiểm là **cấu hình**, lúc dựng: xác nhận project StageScore **không** có webhook nào trỏ tới `/api/webhooks/revenuecat`. Hôm nay webhook bên kia inert vì thiếu `REVENUECAT_WEBHOOK_SECRET`, nên lỗi này sẽ **không lộ ra** cho tới ngày ai đó bật nó lên — và lúc đó nó gửi event không có `userId` vào một handler giả định luôn có.

### S9 · Quan sát, không phải lỗi · Cờ đã mua đi theo backup **của thiết bị**, và đó là điều tốt

`<documents>` nằm trong iCloud/iTunes backup của iOS, nên `entitlements.json` sống sót qua một lần khôi phục thiết bị — người đã trả tiền đổi máy mà không cần Restore. Đó là hành vi **đúng**.

Ghi lại vì nó dễ bị đọc nhầm thành mâu thuẫn với quyết định 6 và bị "sửa": quyết định 6 nói về `LibraryBackup` — file ZIP mà **nhạc công gửi cho nhau** — hoàn toàn khác backup của hệ điều hành. Đừng loại file này khỏi iCloud backup.

### S10 · Hạng mục bắt buộc **chưa kiểm được**, nên review này chưa đóng

Hạng mục số 1 — *hai SDK thật sự gửi gì đi, đọc privacy manifest chúng công bố* — **không thể kiểm hôm nay**: manifest nằm bên trong framework, và framework chỉ tồn tại sau `flutter pub get`. Không có cách nào trung thực để đóng nó ở đây.

**Điều kiện:** mở lại review này ở một mốc, đúng một lần, **sau khi thêm dependency và trước khi archive** — đọc `PrivacyInfo.xcprivacy` trong `GoogleMobileAds.xcframework` và của RevenueCat, sinh Privacy Report từ bản archive, rồi điền `NSPrivacyCollectedDataTypes` và hai form R11 **theo báo cáo đó**, không theo tóm tắt của ai. Bất kỳ ai đọc review này mà tưởng hạng mục 1 đã xong là đang đọc sai.

## Đã kiểm và không có vấn đề

- **Hạng mục 4 — không có lời gọi mạng nào trên đường mở Score.** Thiết kế đủ: guard nguồn, dispose banner khi route đẩy lên, auto-refresh tắt ở console. Với điều kiện S3 biến phép kiểm thủ công thành phép kiểm chạy được.
- **Hạng mục 6 — `no_ads` phải tắt quảng cáo ở mọi bề mặt tương lai.** Kiến trúc đã đảm bảo: `AdSlot` là đường duy nhất dựng được một quảng cáo, và allowlist của guard là thứ giữ điều đó đúng.
- **Hạng mục 7 — khoá cứng non-personalized.** Ràng buộc đã có trong Spec, và tiêu chí G4 đã có. Đây là điều kiện để `NSPrivacyTracking = false` trung thực, không phải một tuỳ chọn.
- **Không có PII nào của nhạc công đi đâu cả.** Không account, không `Purchases.logIn`, không định danh của mình gửi cho ai. Lời hứa "không có gì về bản nhạc của bạn rời khỏi máy" vẫn đúng nguyên vẹn sau slice này — thứ chết là "app không thể gọi mạng", và ADR đã ghi nhận đúng mất mát đó.

## Điều kiện (Conditions)

**Chặn build — sửa Spec 0051 trước khi viết dòng code đầu tiên:**

1. **S1** — RevenueCat khởi tạo lười.
2. **S4** — `restoreBackup` không bao giờ tạo hay sửa cache entitlement; thêm khẳng định vào test.
3. **S5** — `canRequestAds()` là cổng duy nhất; app không lưu trạng thái consent.

**Chặn submit:**

4. **S2** — target audience khai **13+**, ghi vào R12.
5. **S10** — mở lại review sau `pub get`, trước archive.
6. **S6** — kiểm bằng mắt rằng `.p8` và service-account JSON không nằm trong repo.
7. **S8** — xác nhận project RevenueCat của StageScore không có webhook.
8. **S3** — script kiểm quyền chạy trên AAB release.

**Khuyến nghị, không chặn:** S7 (bọc lỗi SDK), S9 (đừng "sửa" thứ đang đúng).
