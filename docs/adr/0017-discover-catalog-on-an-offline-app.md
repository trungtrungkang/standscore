# Discover là lối nhập nội dung, không phải một chế độ mạng

StageScore giữ nguyên bản chất **offline độc lập**. **Discover** thêm một lối để nhạc công tìm và tải nội dung do Backing & Score sản xuất — PDF, BackingTrack, và dữ liệu khớp thời gian. Nội dung tải về **trở thành một Score bình thường** trong library. Mạng chỉ được chạm ở ba việc: đồng bộ danh mục, tải một bản nhạc, và kiểm quyền truy cập. **Không bao giờ chạm mạng để mở một Score.** Và Discover **chỉ đi nhánh PDF** — MusicXML không thuộc phạm vi (quyết định 9). Nhánh PDF ấy **miễn phí vĩnh viễn**: tiền chỉ bắt đầu ở BackingTrack (quyết định 10), và quyền mua **không đi qua tài khoản** (quyết định 5).

**Status:** hold — **Orchestrator hoãn ngày 2026-07-30** (ADR 0018). Không bác và không cắt: mười quyết định, năm câu trả lời G2 và toàn bộ đợt kiểm kê hai repo giữ nguyên giá trị cho lần mở lại. Lý do dừng đúng lúc này là đường tới hạn của Discover là **tốc độ sản xuất bản nhạc** chứ không phải tốc độ build, và danh mục hiện là con số không — trong khi hướng monetization vừa chốt (quảng cáo + một lần mua, ADR 0018) không cần một bản nhạc nào. **Đọc ADR 0018 quyết định 9 trước khi mở lại:** lúc đó app sẽ có hai thứ bán, và ranh giới giữa chúng đã bị SKU `remove_ads` ràng buộc từ trước.
**Đề xuất bởi:** Agent (2026-07-29), theo hướng Orchestrator chốt cùng ngày
**Grilled ở G2:** 2026-07-30 — kiểm kê dựng lại bằng code ở cả hai repo. Hai chốt mới của Orchestrator: app Ionic là **nguyên mẫu tham khảo**, và Discover **chỉ đi nhánh PDF** (quyết định 9). Một lỗ hổng phân quyền mới tìm thấy, ghi ở Hệ quả. Vòng sau cùng ngày chốt thêm hai câu nặng nhất: **PDF miễn phí vĩnh viễn, bán từ BackingTrack trở đi** (quyết định 10, trả lời câu 9) và **quyền ẩn danh theo receipt, không tài khoản** (quyết định 5 viết lại, trả lời câu 1).
**Relates to:** ADR 0002 (dual modes), ADR 0007 (multi-lane Transport + SyncMap), ADR 0008 (parity trước), ADR 0012 (hai repo), ADR 0014 (hai bounded context), `RELEASE-CHECKLIST.md` R2 / R11 / R22

## Bối cảnh (Context)

Sau khi Phase E dừng sớm (2026-07-29), câu hỏi đang mở là *thứ gì nghệ sỹ / teacher / student cần mà ScorePDF không có*. Danh sách ứng viên trước đó — practice trainer, lesson pack — bị bác đúng chỗ: chúng là tính năng ngách, và một tính năng ngách không đỡ nổi một paywall.

Discover khác về loại. Nó không bán **tính năng**, nó bán **nội dung**. Mọi thứ PdfMode làm hôm nay vẫn miễn phí; thứ trả tiền là kho tác phẩm đã được dựng sẵn PDF + BackingTrack + dữ liệu khớp. Điều đó tháo được đúng thế bí mà log ngày 2026-07-29 mô tả, vì nó không lặp lại hình dạng ScorePDF (khoá Label / Sort / Search / Metronome sau gói Pro).

### Đã có một nguyên mẫu của luồng này, và nó là tài liệu tham khảo chứ không phải tiền lệ

Vòng grilling G2 tìm ra thứ bản nháp bỏ sót hoàn toàn: repo web không chỉ có backend, nó có **một app mobile đã dựng thử đúng luồng này**. `apps/mobile` là app Ionic + Capacitor tên "Backing Score", `appId: com.backingscore.app`, có project iOS và Android thật, dùng `@revenuecat/purchases-capacitor`; commit `2026-05-13` ghi "Finalize iOS TestFlight deployment and IAP integration". PRD của nó (`docs/v11/01_mobile_architecture.md`) liệt kê Khám phá (Discover), Interactive Player, Thư viện cá nhân, Chế độ Ngoại tuyến, Cửa hàng — và `src/pages` đã có `Library.tsx` cùng `Setlists.tsx`. Commit cuối chạm vào nó là `2026-05-28`.

**Orchestrator chốt ở G2: đó là app giai đoạn thử nghiệm, tính năng chưa hề được chốt.** Nên nó **không** đặt ra tiền lệ nào cho Discover của StageScore: không phải một feature set để bê sang, không phải một quyết định UX đã có hiệu lực, và không phải một sản phẩm đang có người dùng để mà phải di cư. Cách đọc đúng là đọc nó như một **spike đã chạy được**: chỗ nào kiến trúc tốt thì tham khảo, còn phạm vi và hình dạng của Discover thì quyết lại từ đầu ở các Spec sau ADR này.

Hai hệ quả cụ thể của cách đọc đó. Thứ nhất, phần đáng tham khảo hẹp và xác định được: `OfflineStorageService` (`packages/shared/src/lib/score/offlineStorage.ts`, 175 dòng — `resolveFileUrl` / `downloadAndCacheFile` / `downloadProjectAssets` / `isProjectDownloaded` / `deleteCachedFile`) đúng là hình dạng StageScore cần. Thứ hai, phần **không** đáng tham khảo cũng xác định được, và đó là phần lớn nhất: Interactive Player của nguyên mẫu xoay quanh MusicXML với cursor sync, tức đúng thứ quyết định 9 dưới đây loại ra.

### Phần lớn hạ tầng đã tồn tại ở repo web

Đợt kiểm tra `backing-and-score` cho thấy đây không phải việc dựng từ đầu:

| Thứ cần | Đã có ở đâu |
|---------|-------------|
| Danh mục nội dung công ty | `projects` (`db/schema/drive.ts`) với `isOfficial`, `isPublished`, `isFeatured`, `instrument`, `difficulty`, `workId` |
| Nhánh PDF của nội dung | `projects.notationType`, cộng `pdfMeasureMap: MeasureBox[]` trong `NotationData` |
| Khớp ô nhịp ↔ trang PDF | `MeasureBox` — `pageIndex`, `measureNumber`, `systemIndex`, toạ độ **tỉ lệ 0..1**, `beatSplits` |
| Khớp thời gian nhạc ↔ audio | `TimemapEntry` — `timeMs` ↔ `measure`, `beatTimestamps`, `tempoAtBeat`, `startsAtBeat` cho nhịp lấy đà |
| Công cụ sản xuất | `useTappingSystem.ts`, `components/editor/sync/SyncWorkspaceClient.tsx`, `admin-arrangements.updateTimemap` |
| Phân phối phần nặng | `heavyDataR2Key` — mảng nặng tách khỏi DB, nằm trên R2 |
| Bản thân tệp PDF | `NotationData.fileId`, tải qua `/api/r2/download/<fileId>` → 302 sang presigned URL. Chú thích trong type nói "Appwrite storage file ID" nhưng **đã cũ**: `offlineStorage.ts` gọi nó là R2 fileId và tải từ R2 |
| API cho mobile | `/api/mobile/v1/*` — **chín** route chạy edge, có CORS riêng: `storefront`, `products`, `projects`, `books`, `overlays`, `me`, `favorites`, `setlists`, `session-handoff` |
| Kiểm quyền + trả nội dung một mục | `projects/[id]` — `computeHasProjectAccess` đã làm đúng việc này cho app Capacitor |
| Bó bookmark + chuỗi + chú thích | `sheetOverlays` (`db/schema/collections.ts`) với `bookmarks` và `sequence`, phục vụ qua `overlays` |
| Danh mục dạng sách chia chapter | `books` — một mục danh mục không phải lúc nào cũng là một bản nhạc rời |
| Ranh giới free / trả tiền | Premium **suy ra**: một project là premium khi có `products` row `targetType='project'`, `status='active'`, `priceCents > 0` |
| Mở khoá cho subscriber | `entitlements` với `targetType='global_catalog_vip'`, `targetId='*'` |
| Đường IAP | `products.rcStoreProductId` — "App Store / Play product id for IAP fetch", cộng webhook RevenueCat đã viết |

Ba điều chỉnh với những gì từng ghi trong chat, để ADR này không đứng trên số liệu sai. Bảng `arrangements` ở `db/schema/catalog.ts` **không phải bảng đang chạy** — `admin-arrangements.ts` làm `import { projects as arrangements }`, và `drive.ts` ghi rõ "Các cột được gộp từ bảng `arrangements` cũ". Và `/api/mobile/v1/storefront` hiện phục vụ `projects`. Bản nháp kết luận từ đó rằng "pattern API đã có nhưng chưa có endpoint nào cho đúng luồng Discover" — **vòng grilling bác câu này**: `projects/[id]` đã kiểm quyền rồi trả nội dung, `overlays` đã trả bó bookmark + sequence, và app Capacitor đang dùng cả hai. Thứ thật sự chưa có không phải endpoint mà là **một gói tải hình dạng StageScore**: PDF, audio, SyncMap và overlay về trong một lần tải, kiểm quyền một lần, để đường mở Score sau đó không còn chạm mạng.

### Danh mục chưa tồn tại, và đó là dữ kiện quan trọng nhất của ADR này

Orchestrator xác nhận ở G2: **hiện chưa có PDF nào được public**. Nếu StageScore làm tính năng này thì nội dung sẽ được **đầu tư sản xuất mới** — trước mắt là nhạc cổ điển và etude luyện tập, soạn bằng MuseScore rồi export ra PDF. **BackingTrack và SyncMap tạo sau.**

Điều đó lật ngược chỗ khó của cả ADR. Bản nháp đọc như một bài toán kỹ thuật: hạ tầng bên kia đã có, việc còn lại là nối dây. Thực tế thì hạ tầng đúng là đã có, nhưng **thứ hiếm không phải code mà là bản nhạc** — và bản nhạc thì không sinh ra bằng một Spec. Đường tới hạn của Discover là tốc độ sản xuất, không phải tốc độ build; một Discover hoàn hảo mở ra một danh mục mười bài thì vẫn là một danh mục mười bài.

Ba hệ quả tức thì. **Thứ nhất, "BackingTrack và SyncMap tạo sau" xoá đáy của trình tự bản nháp đang đề xuất** — xem mục Hệ quả, chỗ đó đã viết lại. **Thứ hai, phiên bản Discover đầu tiên nhỏ hơn hẳn ADR mô tả:** một danh mục PDF tải về được, không Transport, không playhead, không `MeasureAnchor`, và — nay đã chốt ở quyết định 10 — không tài khoản, không thanh toán, không cần chờ câu hỏi 7. **Thứ ba, nguồn là file MuseScore chứ không phải bản scan**, nên trang in do mình kiểm soát: khổ giấy, lề, cỡ nốt đều đặt được cho màn hình tablet — một lợi thế thật so với PDF chụp từ sách, và là thứ đáng đưa vào listing hơn là số lượng bài.

Một khuyến nghị đi kèm, rẻ bây giờ và đắt về sau: **giữ file `.mscz` làm bản gốc lưu trữ, không chỉ giữ PDF đã export.** Lý do không phải "để dành cho chắc" mà rất cụ thể — sửa một nốt sai thì re-export chứ không sửa PDF; đổi khổ trang khi biết thêm về máy của nhạc công thì re-export cả kho; và đến lúc làm SyncMap, công cụ hiện có của repo bên kia (`useTappingSystem`) là **gõ tay từng ô nhịp trên PDF**, trong khi MuseScore có đường xuất vị trí ô nhịp bằng CLI (`mposXML` / `sposXML`, thứ musescore.com dùng cho cursor của nó) — cần kiểm trước khi dựa vào, nhưng nếu đúng thì nó là khác biệt giữa gõ tay vài trăm bài và chạy một script. Nếu chỉ giữ PDF thì lựa chọn đó đóng lại vĩnh viễn.

### Cái căng thật nằm giữa "offline độc lập" và "subscription"

Subscription cần trả lời lặp lại câu "người này còn hạn không", và câu đó cần mạng. App này thì được dùng trên sân khấu, nơi không có tín hiệu là chuyện bình thường và một bản nhạc không mở được là hỏng buổi diễn. Log ngày 2026-07-29 đã bác subscription đúng vì lý do đó.

Chỗ thoát không nằm ở việc chọn một trong hai, mà ở việc **kiểm quyền lúc tải chứ không phải lúc chơi**. Một khi tệp đã nằm trên máy, nó không khác gì một PDF nhạc công tự import — và app vốn đã biết mở loại đó mà không cần mạng.

## Các lựa chọn đã cân nhắc (Considered options)

- **Nhúng webview trỏ về trang web** — bị bác. Nội dung sẽ không đi qua PdfMode, nên mất PageTurn, PageOrder, Bookmark, annotation, Setlist, PerformanceMode — tức mất toàn bộ lý do StageScore tồn tại. Và nó không offline.
- **StageScore thành client online của platform, bắt buộc đăng nhập** — bị bác. Phá lời hứa offline, và Orchestrator đã chốt ngược lại.
- **Nội dung Discover sống ở một kệ riêng, tách khỏi library** — bị bác. Hai vòng đời cho cùng một khái niệm; nhạc công không xếp được nội dung tải về vào Setlist cùng bản nhạc của mình, đúng lúc cần nhất là dựng chương trình biểu diễn.
- **Discover là lối nhập, nội dung hoà vào library, offline sau khi tải** — được chọn.

## Quyết định (Decision)

### 1. Ba chỗ duy nhất được chạm mạng

Đồng bộ danh mục, tải một bản nhạc, kiểm quyền. Mở một Score **không bao giờ** là một trong ba. Đây là bất biến, và nó nên có một test giữ — cùng idiom với test brand của 0042: không lời gọi mạng nào được xuất hiện trên đường mở Score.

### 2. Tải về là trở thành Score

Một mục Discover tải xong sinh ra một `Score` bình thường, mang thêm một dấu nguồn gốc để biết đường tải lại và để hiển thị. Nó thừa hưởng nguyên Setlist, Bookmark, JumpLink, annotation, PageOrder, backup. Đây là chỗ lấy được nhiều đòn bẩy nhất từ code đã có.

`Score` (`lib/library/score.dart`) hôm nay có đúng sáu trường và không có chỗ nào cho dấu nguồn gốc. Thêm một trường nullable là tương thích ngược với `library.json` đã ghi, nhưng nó không đứng một mình — xem quyết định 8, vì backup phân biệt được asset theo nguồn gốc *chỉ khi* layout trên đĩa tách chúng ra.

### 3. Search chạy trên máy

Danh mục về dưới dạng một manifest đã cache; tìm kiếm chạy cục bộ trên manifest đó. Hệ quả: Discover **duyệt và tìm được cả khi offline**, chỉ việc tải mới cần mạng — và không một truy vấn tìm kiếm nào rời khỏi máy, nên tuyên bố privacy không phải nhận thêm một mục "search queries".

### 4. Quyền kiểm lúc tải, không kiểm lúc chơi

Đã tải là chơi được, offline, không hỏi lại. Hết hạn subscription thì **không tải được bản mới**; bản đã tải thì không tắt giữa buổi diễn.

Phạm vi của lời hứa này là **một thiết bị**, và ADR phải nói thẳng ra vì quyết định 8 làm nó hẹp lại. Backup chỉ lưu tham chiếu, nên khôi phục trên máy mới cần mạng *và* cần quyền còn hiệu lực: người hết hạn subscription khôi phục backup sẽ thấy Score còn đó, annotation còn nguyên, mà bản nhạc không mở được. Đó đúng là tình huống đổi máy trước một buổi diễn — cùng loại hỏng mà quyết định này tồn tại để tránh, chỉ dịch sang một thời điểm khác.

Hai chốt ở G2 rút nỗi lo đó xuống gần hết. PDF miễn phí vĩnh viễn (quyết định 10) nên khôi phục trên máy mới chỉ cần **mạng**, không cần quyền — bản nhạc luôn tải lại được. Phần còn lại chỉ áp cho BackingTrack đã mua, và ở đó quyền nằm trên receipt của store (quyết định 5), nên Restore Purchases lấy lại được trên máy mới **cùng store account**. Ca mất thật không phải đổi máy mà là **đổi nền tảng**: mua trên iOS không dùng được trên Android.

### 5. Quyền của StageScore ẩn danh theo receipt — hai mô hình quyền song song, có chủ ý

Bản nháp viết "không phát minh mô hình quyền thứ hai", và vòng grilling đã chỉ ra rằng khuyến nghị ẩn danh của câu hỏi 1 chính là mô hình thứ hai. **Orchestrator chốt ở G2 (2026-07-30): subscription bên StageScore không cần tài khoản.** Nên ADR này cố ý nuôi hai mô hình, và việc của mục này là ghi rõ cái giá thay vì giấu nó.

Web giữ nguyên **account-based tuyệt đối**: `computeHasProjectAccess` trả `false` ngay khi không có `session.user` rồi mới tra `entitlements` theo `userId`; `mobileHasBookAccess` cũng vậy, sau khi cho qua nhánh `priceCents === 0`; và `SubscriptionProvider.tsx` buộc RevenueCat vào account bằng `Purchases.logIn({ appUserID: user.id })`. Quyền ở đó sống dưới hai tên — `premium` phía RevenueCat, `global_catalog_vip` phía DB (cộng `b2b_educator_vip`, và `targetType='book'` cho sách mua đứt) — và webhook là chỗ nối hai tên đó.

StageScore đi đường khác: **RevenueCat anonymous app user ID**, quyền nằm trên receipt của store, không đăng nhập, không `session-handoff`, không tầng account.

Bốn hệ quả phải viết thành lời, vì không cái nào tự lộ ra lúc build:

- **Mua bên này không dùng được bên kia.** Không có khoá nào nối một receipt ẩn danh với một `users.id`. Đây là mất mát thật, và nó được chấp nhận có ý thức.
- **Quyền theo store account, không theo thiết bị.** Restore Purchases lấy lại được trên máy mới cùng Apple ID / Google account, nên "phạm vi một thiết bị" ở quyết định 4 thực ra rộng hơn bản nháp lo; chỗ mất là đổi nền tảng.
- **Phía server không tra DB được.** Webhook RevenueCat không có `userId` để ghi một `entitlements` row, nên đường kiểm quyền của StageScore phải hỏi RevenueCat hoặc thẩm định receipt, chứ không phải `SELECT` từ `entitlements`. Đây là đầu vào bắt buộc của câu hỏi 7 và nó loại bớt hình dạng ở đó.
- **Câu hỏi 2 tự tan.** Nội dung free không cần tài khoản, vì không chỗ nào trong app có tài khoản.

### 6. Từ vựng: không hợp nhất hai bên

ADR 0014 vẫn áp dụng. Web nói `projects` / `Timemap` / `MeasureBox` / `DAWPayload`; StageScore giữ Score / SyncMap / BackingTrack. Việc đúng là **thêm hàng vào bảng dịch của ADR 0014**. StageScore còn thiếu một term cho khái niệm "một ô nhịp được định vị trên trang" — đề xuất **MeasureAnchor**, chốt ở G1 lúc build chứ không phải ở đây.

> **Đề xuất `MeasureAnchor` đã bị rút. ADR 0019 (accepted 2026-08-05) dùng `MeasureBox`** — đúng tên và đúng nghĩa với repo web, nên nó làm việc này tốt hơn: phép dịch ở bảng của ADR 0014 gần như không tốn gì thay vì phải bảo trì một cặp tên. Một tên là đủ. Mọi chỗ trong ADR này còn viết `MeasureAnchor` (xem mục Hệ quả) đọc là `MeasureBox`.

### 7. PageOrder là ràng buộc, không phải chi tiết

`MeasureBox.pageIndex` giả định thứ tự trang in. PageOrder cho phép nhạc công lặp và sắp lại trang, nên playhead phải chạy theo **trình tự biểu diễn**, không theo trang PDF. Payload web đã có `measureMap` ("latent playback measure index → physical printed measure index") sinh ra đúng cho bài toán này — dùng lại, đừng viết lại.

Đó mới là một nửa. Nửa còn lại đã nằm sẵn ở dòng `PageOrder` trong bảng dịch của ADR 0014 và bản nháp không nối vào: `NavigationSequence` của web là chuỗi **id của Bookmark**, còn `PageOrder` của StageScore là chuỗi **trang**, kể cả trang lặp và trang trắng. Nếu nội dung Discover mang theo `sheetOverlays` thì phép dịch giữa hai thứ đó là một quyết định thật, không phải chi tiết cài đặt — và nó phải chốt trước khi có Spec nào nhập overlay.

### 8. Backup không nuốt nội dung có bản quyền

ZIP của 0027/0050 lưu **tham chiếu cộng annotation của nhạc công**, không lưu PDF và audio tải từ Discover — chúng tải lại được, và chúng không phải của người dùng. Sau quyết định 10 thì lý lẽ "bản quyền" chỉ còn áp cho audio: PDF là bản khắc của team và miễn phí vĩnh viễn, nên nó bị loại khỏi ZIP vì **tải lại được**, không vì bị khoá. Việc này bump `formatVersion` lên 2, nên nó nên đi **chung một lần** với slice backup chọn lọc mà 0050 đã để lại, chứ không bump hai lần.

Bump format là điều kiện cần chứ chưa đủ. `LibraryBackup` hôm nay đi cả cây từ `libraryRoot` xuống, nên muốn loại asset có bản quyền thì **layout trên đĩa phải tách theo nguồn gốc trước** — một trường trên `Score` không đủ, vì bộ zip làm việc với đường dẫn chứ không với model. Nói cách khác quyết định 2 và quyết định 8 là một việc, không phải hai.

### 9. Discover chỉ đi nhánh PDF (mới ở G2)

Thêm ở G2 theo chốt của Orchestrator, và nó **chi phối tám quyết định trên** chứ không đứng cạnh chúng: StageScore tập trung vào PDF, không vào MusicXML. Một mục danh mục chỉ vào được Discover khi nó có nhánh PDF — `notationType = 'pdf'` với `fileId` trỏ tới một PDF thật. Mục chỉ có MusicXML **không hiện trong Discover**, chứ không phải hiện rồi báo lỗi lúc tải.

Ràng buộc này không phải khẩu vị, nó là hệ quả bắt buộc của ba thứ đã ký. `Score` của StageScore *là* một PDF (`relativePath` trỏ tới `.pdf`), nên quyết định 2 chỉ thực hiện được với nội dung PDF. Verovio và MusicXML thuộc ADR 0003 và bị ADR 0008 chặn tới H3+. Và bản thân dữ liệu khớp mà ADR này dựa vào — `MeasureBox` với toạ độ tỉ lệ trên trang — chỉ có nghĩa trên một trang in.

Lúc mới viết, quyết định này trông như một phép cắt đau: nhánh PDF là đường thiểu số theo thiết kế của repo bên kia (`defaultDAWPayload()` đặt `music-xml` cho mọi project mới), nên lọc theo PDF nghe như vứt đi phần lớn danh mục. Câu trả lời của Orchestrator cho câu hỏi 4 xoá hẳn cái giá đó: **danh mục hiện là con số không**, và nội dung sắp sản xuất là PDF export từ MuseScore. Không có gì để mất, vì không có gì đang tồn tại. Cái giá duy nhất còn lại chuyển sang phía sản xuất — pipeline phải đặt `notationType = 'pdf'` chủ động, xem mục Hệ quả.

### 10. Nhánh PDF miễn phí vĩnh viễn; tiền bắt đầu ở BackingTrack (mới ở G2)

Trả lời câu hỏi 9, chốt bởi Orchestrator ngày 2026-07-30: **bước 1 miễn phí hoàn toàn, bán từ bước 3 trở đi.**

Câu "nhạc cổ điển và etude vốn miễn phí ở khắp nơi thì người ta trả tiền cho cái gì" được quyết bằng một phép thử: *thứ này có tái tạo được bằng cách ghép một nguồn miễn phí với chính StageScore — vốn cũng miễn phí — hay không?* App này **là** trình đọc PDF cho nội dung IMSLP, nên nó tự cấp phần phân phối cho đối thủ của mình. Ba trong bốn điểm khác biệt trượt phép thử đó:

- **Bản khắc sạch, dàn trang cho tablet.** Tái tạo được một phần — Mutopia và các bản typeset (không phải scan) trên IMSLP đã sạch và miễn phí. Bản khắc *có* bán được tiền, nhưng Henle và nkoda bán **thẩm quyền biên tập** tích luỹ hàng chục năm, thứ một brand mới chưa có và không mua được bằng một slice.
- **Danh mục chọn lọc xếp thành lộ trình.** Yếu hơn bản nháp nghĩ, vì hai lý do đo được ở repo web. Bên đó **đã sở hữu** khái niệm này và đã tính tiền cho nó: `courses` / `lessons` / `enrollments` / `progress` với `difficulty` và `priceCents`, cộng `books` chia chapter và cả `TeacherHub`. Và nội dung dạy của một lesson là **TipTap JSON** (`contentRaw`), thứ StageScore không render được và không nên render. Rơi vào app, một lộ trình chỉ còn lại **thứ tự** — mà thứ tự thì StageScore đã cho không qua Setlist, Label và Sort, đúng ba thứ ScorePDF khoá sau gói Pro.
- **Nội dung vừa khít app** — điểm bản nháp bỏ sót, và là điểm mạnh nhất có ngay ở bước 1. Ngắt trang đặt vào chỗ có dấu lặng để không phải lật giữa câu nhạc; PageOrder giải sẵn cho D.C. và các dấu quay lại; Bookmark theo chương; JumpLink đặt sẵn chỗ nhảy. Bản scan không thể có, vì trang in của nó đã cố định từ một cuốn sách giấy — nguồn `.mscz` là thứ làm việc này rẻ. Nó cũng **chụp ảnh được** cho store listing, khác hẳn "được chọn lọc". Nhưng nó vẫn không phải hàng bán: nó là lý do chọn kho của mình thay vì IMSLP.

Chỉ **BackingTrack + SyncMap** qua được phép thử: không tổ hợp miễn phí nào tái tạo được, và Tomplay là bằng chứng tồn tại rằng người ta trả tiền cho đúng nó, trên đúng repertoire đã hết bảo hộ.

Nên ranh giới tính tiền không nằm giữa hai nhóm bản nhạc, nó nằm giữa **bản nhạc và phần đệm**: mọi PDF trong Discover miễn phí vĩnh viễn, paywall đầu tiên khoá BackingTrack. Ba điểm trượt phép thử không vô ích — việc của chúng là làm cho thư viện luyện tập của nhạc công dọn vào sống trong StageScore, để đến bước bán thì BackingTrack được chào trên một bản nhạc người đó **đang tập rồi**. Bước 1 miễn phí không phải hoãn doanh thu, nó dựng mặt phẳng để doanh thu bám vào; và nó hạ hẳn ngưỡng "bao nhiêu bài thì đủ để mở", vì một kho miễn phí mỏng thì tha thứ được còn một kho tính tiền mỏng thì không.

Phản chứng đã cân nhắc và bác: MuseScore.com **có** tính tiền để truy cập nhạc do cộng đồng đăng, phần lớn là nội dung miễn phí, và nó chạy được — nhưng bằng khối lượng cực lớn cộng công cụ phát và luyện tập, tức đúng những tài sản không có ở bước 1.

Hệ quả cho quyết định 5: đơn vị tính tiền của StageScore **không phải một mục danh mục** như phía web (`products` row với `targetType='project'`), mà là phần đệm của mục đó. Cách đọc mặc định của chữ "subscription" ở đây là **một gói mở toàn bộ BackingTrack**, không bán lẻ từng bài — xem câu hỏi 10.

## Hệ quả (Consequences)

- **Quyền tải hiện *không* được thực thi ở mức byte, nên quyết định 4 chưa có gì chống lưng.** `/api/r2/download/[...fileId]` lấy session ra rồi không dùng: nó đặt thẳng `let isAuthorized = true` với một chú thích "R2 Download Access is mostly capabilities-based via fileId token", trả 302 tới một presigned URL sống 3600 giây, và mở `Access-Control-Allow-Origin: *`. Lập luận "fileId là capability" không đứng được, vì chính ADR này trích một ví dụ key có cấu trúc — `projects/123/annotations.json` — tức key suy ra được từ một project id mà `storefront` phát công khai. Hệ quả cho ADR: entitlement ở `projects/[id]` đang canh **metadata**, không canh **bytes**, nên chừng nào chưa sửa thì paywall của Discover là trang trí. Đây là hạng mục số một của Security Review, và nó cũng sửa lại một câu của bản nháp: hạ tầng "phần lớn đã tồn tại" đúng với phân phối và danh mục, **không** đúng với thực thi quyền. Quyết định 10 đổi **đối tượng** phải canh chứ không xoá lỗ hổng: PDF miễn phí thì bước 1 không có gì để canh, nhưng file audio ở bước 2 thì có, và nó đi qua đúng endpoint này.
- **Nguyên mẫu Ionic không kéo theo việc di cư nào.** Vì nó là app thử nghiệm chưa chốt tính năng, ADR này không nợ nó một đường nâng cấp, một cam kết tương thích, hay một cuộc chuyển người dùng. Việc duy nhất còn lại là dọn: quyết định số phận `com.backingscore.app` và cấu hình RevenueCat đang trỏ vào bundle đó trước khi StageScore mở IAP dưới `com.backingscore.scoreapp` (câu hỏi 6). Quyết định 5 làm việc dọn này nhẹ hẳn — quyền ẩn danh nên không phải ánh xạ người dùng nào sang, chỉ phải tạo lại sản phẩm IAP và entitlement dưới bundle mới.
- **Đây không phải v1.** v1 đang ở cửa store với blocker toàn là việc người. Discover đổi app từ công cụ thành sản phẩm có nội dung, kéo theo một vòng screenshot và một vòng review khác hẳn.
- **Tuyên bố privacy phải đổi ở cả hai repo, cùng lúc.** `PrivacyInfo.xcprivacy` đang khai không thu thập gì; `/privacy` mục 7 nói y vậy. R22 đã cho thấy cái giá của việc để policy, manifest và form của store nói ba điều khác nhau. Theo ADR 0012 đây là thay đổi hai bên, không có CI nào bắt giùm.
- **"Không tài khoản" không có nghĩa là "không thu thập gì".** Quyết định 5 xoá được tầng account, nhưng SDK RevenueCat vẫn gửi một anonymous app user ID cùng metadata thiết bị lên server bên thứ ba, và lịch sử mua hàng phải khai trong App Privacy của App Store lẫn Data safety của Play. Nên tuyên bố privacy vẫn phải đổi ở cả hai repo — chỉ là từ **bước 2** chứ không phải bước 1.
- **Tín hiệu duy nhất để biết nên sản xuất bài nào là số lượt tải tổng hợp phía server.** Không tài khoản và app không thu thập gì (R11/R22), nên không có cách nào biết *ai* tải *gì* — đúng ý đồ. Còn lại là đếm theo mục danh mục ở phía server: không phải dữ liệu cá nhân, nhưng vẫn cần một dòng ở `/privacy` và nhất quán với `PrivacyInfo.xcprivacy`. Nên chốt **trước** bước 1, vì bước 1 chính là lúc sinh ra tín hiệu, và nó là la bàn duy nhất cho câu "bao nhiêu bài thì đủ".
- **Tier L.** Cần ADR này accept ở G2, cộng **Security Review** trước khi build — có dữ liệu rời máy, có thanh toán, có entitlement.
- **Trình tự đảo lại ở G2, vì bản nháp xếp thứ không có nội dung để chạy lên đầu.** Bản nháp mở bằng Transport + `BackingLane` để "chứng minh phần UX đắt nhất trước" — nhưng BackingTrack và SyncMap tạo sau, nên bước đó sẽ chạy trên dữ liệu tự bịa và chứng minh được đúng bằng không. Trình tự đúng theo nội dung có thật, mỗi bước một Spec — và sau quyết định 10 nó còn **ba** bước, vì bước subscription cũ không còn đứng riêng mà nhập vào bước có phần đệm: **(1)** manifest + search cục bộ + tải PDF **free**, không tài khoản không tiền — bước duy nhất có nội dung ngay khi kho đầu tiên xong, và nó tự đứng được như một sản phẩm; **(2)** Transport nhận `BackingLane` trên một Score cục bộ, khi BackingTrack đầu tiên tồn tại — **đây là paywall đầu tiên**, nên nó mang theo cả IAP lẫn đường kiểm quyền, và là bước cần câu hỏi 7 trả lời xong; **(3)** `MeasureAnchor` + playhead theo PageOrder, khi có SyncMap. Lợi ích phụ đáng kể: bước 1 không chạm Transport, không chạm tiền, không chạm tài khoản — nên gần như toàn bộ thứ mà tier L và Security Review của ADR này tồn tại để canh đều nằm ở bước 2, không ở bước 1.
- **Đường tới hạn là sản xuất, không phải code — và không có Spec nào đẩy nhanh được nó.** Kho nội dung phải tồn tại trước khi Discover có nghĩa, nên lịch của tính năng này bị chặn bởi tốc độ soạn nhạc. Điều cần quyết kèm theo là **bao nhiêu bài thì đủ để mở**: con số đó nên chốt trước khi build, vì mở Discover với một danh mục mỏng là một ấn tượng đầu tiên chỉ có một lần.
- **Pipeline sản xuất phải đặt `notationType = 'pdf'` một cách chủ động.** `defaultDAWPayload()` đặt `notationData.type = "music-xml"` cho mọi project mới và cột `projects.notation_type` mặc định `'none'`, nên một mục nhập theo đường mặc định sẽ **không** lọt qua bộ lọc của quyết định 9 dù PDF của nó hoàn toàn ổn. Đây là loại lỗi im lặng: nội dung có thật, sản xuất xong, mà Discover không thấy.
- `TRANSPORT-ARCHITECTURE.md` có một câu chặn thẳng bước có audio — nay là bước 2, không còn là bước 1: *"Do not invent a second audio player for PDF 'just for now.'"* ADR này **không** xin miễn trừ nó. Bước 1 không phát gì nên không đụng tới câu này; đến bước 2 thì `BackingLane` phải đi qua Transport thật. Câu hỏi mở số 3 của tài liệu đó ("Is PdfMode+backing in scope within first year?") coi như được trả lời là **có**.
- ADR 0007 quyết định 6 nói BackingTrack "dùng chủ yếu ở SmartMode; PdfMode+backing là Spec sau **nếu SyncMap thiết lập được mà không cần MusicXML**". Điều kiện đó nay đã có bằng chứng: `MeasureBox` + `TimemapEntry` là một SyncMap dựng bằng tay trên PDF, đang chạy ở repo bên kia. Quyết định 6 cần sửa lại lời khi ADR này được accept.

## Câu hỏi cho Orchestrator ở G2

**Đã trả lời (2026-07-30).** *App Ionic đang có nghĩa là gì với ADR này?* → Nó là **nguyên mẫu giai đoạn thử nghiệm, tính năng chưa chốt**; tham khảo kiến trúc chỗ nào tốt, không kế thừa phạm vi. Và *Discover đi nhánh nào?* → **PDF, không MusicXML** — thành quyết định 9. Xem mục Bối cảnh; phần dọn dẹp còn lại thành câu 6 và 8 dưới đây.

1. ~~**Subscription có tài khoản hay không tài khoản?**~~ **Đã trả lời: không tài khoản.** Quyền nằm trên receipt của store qua RevenueCat anonymous app user ID. Quyết định 5 đã viết lại theo đó, kèm bốn cái giá — nặng nhất là mua trong app không dùng được trên web, và server không `SELECT` từ `entitlements` được nên câu hỏi 7 đổi hình dạng.
2. ~~**Nội dung free có cần tài khoản không?**~~ **Đã tan cùng câu 1: không** — không chỗ nào trong app có tài khoản. Sau quyết định 10 thì câu này còn nhẹ hơn nữa, vì toàn bộ nhánh PDF là free.
3. **Hết hạn subscription thì nội dung đã tải ra sao?** Quyết định 10 thu hẹp câu này xuống chỉ còn **BackingTrack** — PDF miễn phí vĩnh viễn nên không bao giờ bị thu hồi. Quyết định 4 đang chọn "giữ vĩnh viễn", nghĩa là subscription trên thực tế hoạt động gần như mua đứt. Nếu điều đó sai về mặt kinh doanh thì phương án thay thế là một cửa sổ tái kiểm khi online (ví dụ hết hạn quá N ngày thì ẩn nội dung subscriber) — nhưng **không bao giờ chặn khi đang offline**.
4. ~~**Danh mục hiện có bao nhiêu mục dùng được?**~~ **Đã trả lời: không có mục nào.** Chưa PDF nào được public; nội dung sẽ được đầu tư sản xuất nếu tính năng này được duyệt. Câu hỏi thay thế nó nằm ở mục Hệ quả và nhỏ hơn nhưng vẫn phải chốt trước khi build: **bao nhiêu bài thì đủ để mở Discover.**
5. ~~**Bản khắc nhạc là của ai?**~~ **Đã trả lời: của team.** Nhạc cổ điển và etude hết hạn bảo hộ, soạn lại bằng MuseScore nên bản khắc là của mình — sạch về quyền, và không phải đi xin phép ai. Phần còn lại của câu này chỉ là kỷ luật sản xuất: đừng nhập bản scan của ấn bản hiện đại vào cùng kho, vì tác phẩm hết bảo hộ không có nghĩa là mọi ấn bản của nó hết bảo hộ.

6. **`com.backingscore.app` xử lý thế nào?** Nguyên mẫu không cần di cư, nhưng bundle thì cần một kết cục: gỡ khỏi App Store Connect, hay để im. Câu thật sự chặn nằm ở tầng thanh toán — cấu hình RevenueCat, sản phẩm IAP và entitlement `premium` đang gắn với bundle đó, nên phải tạo lại dưới `com.backingscore.scoreapp` hay ánh xạ sang trước khi StageScore mở bán, và cách làm khác nhau tuỳ câu 1.

7. **Ai enforce quyền tải, và ở đâu?** Câu này sinh ra từ lỗ hổng ghi ở mục Hệ quả, và nó phải có câu trả lời **trước** Security Review chứ không phải trong đó. Ba hình dạng: presigned URL phát ra sau khi endpoint đã kiểm entitlement (sửa tại chỗ, giữ nguyên client); một endpoint tải riêng cho StageScore tự kiểm rồi stream (đắt hơn, nhưng gộp được với "gói tải hình dạng StageScore" đã nói ở Bối cảnh); hoặc chấp nhận nội dung free không canh gì và chỉ canh nhánh trả tiền. Lựa chọn này đổi cả hình dạng API mà các Spec sau phải gọi, nên nó thuộc G2.

8. **Nguyên mẫu còn gì đáng đọc trước khi archive?** Phần đã xác định được thì ghi ở Bối cảnh rồi (`OfflineStorageService`). Câu còn lại là những chỗ nó đã va phải mà tài liệu không ghi — hình dạng manifest offline, cách nối RevenueCat với entitlement phía DB. Đọc trước khi viết Spec là rẻ, đào git sau khi archive thì không. Không chặn G2, nhưng nên chốt cùng lúc để khỏi mất.

9. ~~**Nhạc cổ điển và etude là thứ đã miễn phí ở khắp nơi — người ta trả tiền cho cái gì?**~~ **Đã trả lời: bước 1 miễn phí hoàn toàn, bán từ bước 3 trở đi.** Thành quyết định 10, cùng phép thử đã dùng để quyết và điểm khác biệt thứ tư mà bản nháp bỏ sót (nội dung vừa khít app).

10. **Bán lẻ từng BackingTrack hay một gói mở tất cả?** Sinh ra từ quyết định 10 và cần trả lời trước Spec bước 2, vì nó đổi cả hình dạng sản phẩm IAP lẫn đường kiểm quyền. Chữ "subscription" đọc mặc định là **một gói mở toàn bộ**, và đó là hình dạng rẻ nhất: một `rcStoreProductId`, một entitlement, không cần biết mục nào. Bán lẻ thì hợp hơn với người chỉ tập vài bài, nhưng phải có một `targetType` mới ở phía web (`products` hôm nay gắn `targetType='project'`, tức gắn vào **mục danh mục** chứ không vào phần đệm của nó) — mà quyết định 5 vừa nói StageScore không tra `entitlements` được, nên bán lẻ ẩn danh nghĩa là tự dựng chỗ nhớ "receipt này đã mở những bài nào". Khuyến nghị: **một gói**, và để dành bán lẻ tới khi có bằng chứng cần.
