# StageScore improvement roadmap (post–P2.15)

**Status:** accepted (Orchestrator 2026-07-26)  
**Date:** 2026-07-26  
**Basis:** Quality / UX review after ScorePDF PdfMode rows through P2.15; Phase A (0033 + 0030) done  

**Goal:** Make PdfMode honestly gig-ready before opening H3+ (ADR 0008), without inventing a second product.  
**Sequencing locked:** **A1 (0033) → A2 (0030) → B → C ∥ E → D**.

**Phase E được thêm ngày 2026-07-28** (trạng thái: **proposed**, chưa được accept như A–D) — xem bên dưới. Phase A–D giữ nguyên `accepted` như bản gốc (tiếng Anh, không dịch hồi tố theo ADR 0015 — Phase A–D được viết trước ADR đó). Phase E được viết bằng tiếng Việt vì được soạn sau khi ADR 0015 accepted.

---

## Principles

1. **Honesty over checklist green** — if a parity row is not usable on stage, reopen or annotate it.
2. **Artist first** — learners/teachers get polish that does not block SmartMode sequencing.
3. **One Spec = one vertical slice** — keep SDO gates (G3 → build → G4).
4. **Do not start SmartMode / Transport / OMR** until Orchestrator exits ADR 0008.

---

## Phase A — Honesty & last ScorePDF row (now)

| Order | Work | Parity / Spec | Outcome |
|------:|------|---------------|---------|
| A1 | **Gesture coexist:** pinch + double-tap when unlocked; PageTurn does not steal two-finger scale | **P0.7** / Spec **0033** — **done** | Musicians can zoom mid-piece; lock (0031) meaningful |
| A2 | **Metronome** tempo / meter / volume / mute-visual | **P2.13** / Spec **0030** — **done** | Last ScorePDF P2 row |
| A3 | Checklist hygiene: P0.7 note; P2.14 “no DPI”; P1.10 Jump Links list note | Docs only | Parity matches reality |

**Exit A:** Orchestrator would trust page turns + zoom + click track for a short practice/gig set.

**Suggested G3 for A1 (0033):**

- When unlocked: 2-finger pinch reaches scale; PageTurn swipe ignores multi-touch scale.
- Double-tap zoom: include this slice **or** cut explicitly and remove from P0.7 wording.
- Draw mode / JumpLink drag unchanged.
- No peek-then-snap while zoom-locked (keep 0031).

**Suggested G3 for A2 (0030)** — already drafted:

- Persist app-wide; entry ⋯ → Metronome…; tick + accent; mute / visual-only.

---

## Phase B — Stage chrome (after A)

| Order | Work | Suggested Spec | Outcome |
|------:|------|----------------|---------|
| B1 | **Performance mode:** hide AppBar + PageNav while viewing; one GestureMap / edge action to reveal | **0034** — **done** | Less “settings app” on stand |
| B2 | **PdfMode ⋯ IA:** group Navigate / Mark / Display / Advanced (or equivalent) | **0035** — **done** | Faster mid-gig settings |
| B3 | **Scale story copy:** Page scale vs pinch; “stage preset”; the page indicator 0034 deferred | **0036** — **done** | Lock/scale understandable; one action to get ready to play |

**Exit B:** First viewport in PdfMode feels performance-first; settings are findable without a wall of peers.

Phase B is complete (2026-07-26). **0041** ran unsequenced right after it — parity Q9, a UI/UX review of the six layout modes that the B3 device run made unavoidable: `pdfFitZoom` had just proved that which layout suits a screen is arithmetic, and the picker was still six equal chips. Phase C is next, starting at C1.

---

## Phase C — Teacher / library polish (parallel-safe after A2)

| Order | Work | Suggested Spec | Outcome |
|------:|------|----------------|---------|
| C1 | Duplicate Score (copy PDF + overlays option) | **0037** | Per-student copies |
| C2 | Share / export annotated PDF discoverability (Library + PdfMode) | Extend **0020** or **0038** | Teachers send marked parts easily |
| C3 | Light onboarding: first-run tips for pedal, half-page, Jump Links | **0039** | Hand tablet to student without a lecture |
| C4 | **Library Score row:** rename Score, first-page thumbnail + page count, relative dates, labels as chips, active filter visible | **0040** — **done** | Library readable before a session; share-in PDFs stop being `doc_2024-11-03` |

C4 ran first in this phase — rename was a debt from Spec 0002 ("rename can wait") that share-in (0029) made sharp, and C1 duplicate Score would have been unpleasant while no copy could be renamed.

**Exit C:** Teacher can prep a setlist + annotated PDF without workarounds.

---

## Phase D — ADR 0008 exit decision

Orchestrator gate (not a Spec):

- [x] A1 + A2 G4 pass  
- [x] Optional: B1 G4 if chrome still feels wrong on device — done (0034)  
- [ ] Explicit **go / hold** on opening H3 (SmartMode)

If **go** → first H3 Spec (Smart Score import / Verovio shell) per VISION.  
If **hold** → more Phase B/C only.

---

## Phase E — Nhân dạng thị giác & IA panel đọc (ScorePDF benchmark v2)

**Status:** proposed (drafted 2026-07-28, chưa có slice nào được G3-accept)
**Căn cứ:** Orchestrator review — "StageScore vẫn cảm thấy basic so với ScorePDF" — đối chiếu với ảnh chụp thật từ máy màn hình Home và ScoreDetail của ScorePDF (không phải ảnh marketing App Store, thứ hoá ra lại là một drawer phụ chứ không phải IA chính) cộng một đợt audit code `lib/ui/*`.
**Phát hiện định hình cả phase:** checklist parity P0–P2 vẫn `done` dưới đợt audit — ScorePDF khoá Label / Sort / Search / Metronome sau một gói Pro trả phí, trong khi StageScore cho miễn phí. Vậy khoảng cách nằm ở **cách trình bày và kiến trúc thông tin, không phải năng lực**. Hai khoảng cách cụ thể, có bằng chứng: (1) mọi công cụ PdfMode trừ Draw đều nằm sau một icon `⋯` **ScoreMenu** duy nhất (`score_menu.dart:74-143`), trong khi ScoreDetail của ScorePDF giữ một **tab-strip có nhãn cố định ở đáy** (Bookmark · Page · Gesture · Tools · Annotation) luôn hiển thị ngay dưới thanh trượt trang; (2) các sheet cài đặt của StageScore hiện ra ở năm kiểu trọng lượng thị giác khác nhau, không có lớp design-token dùng chung, trong khi ScorePDF dùng lại một hàng icon+tiêu đề+mô tả phụ+switch cho mọi nơi.

**Đánh số:** 0037–0039 vẫn dành riêng cho Phase C; 0040–0042 đã `done`. Phase E lấy khối số trống kế tiếp, **0043–0049**, cộng dùng lại **0039** (xếp lại thứ tự, không đổi số) cho onboarding.

**Thứ tự chạy:** song song an toàn với Phase C — không đụng chạm file của nhau. E1 chạy trước vì vừa là chiến thắng cấu trúc rẻ nhất vừa là điều Orchestrator chỉ ra hai lần; E2 (token) chạy thứ hai vì E3–E7 đều hiển thị đẹp hơn một khi nó tồn tại.

| Thứ tự | Việc | Parity / Spec | Kết quả |
|------:|------|----------------|---------|
| E1 ✅ | **ScoreMenuQuickBar icon-only dưới PageNavBar, `⋯` giữ nguyên:** bản đầu định thay hẳn `⋯` bằng một tab-strip có nhãn cho cả bốn nhóm (**Go to · Marks · View · Playing**) — đảo lại cùng ngày vì rủi ro i18n (nhãn cố định trong hàng bốn tab vỡ layout khi dịch). Revision 1 rút về chỉ một icon-tắt View không nhãn trên AppBar. Revision 2 (hình dạng cuối) đưa tab-strip trở lại đúng vị trí ban đầu — ngay dưới `PageNavBar` — nhưng mọi mục là **icon thuần, không chữ**: Metronome (khi chạy), Draw, Bookmarks, Layout, View. `⋯` không đổi, vẫn mở đủ bốn nhóm/12 action, mỗi action giờ có icon riêng đứng trước tên | Mở lại lựa chọn IA của 0035 — Spec **0043** | Thứ Orchestrator hỏi ba lần, giải quyết mà không thêm rủi ro i18n mới |
| E2 ✅ | **Design token & component theme:** một thang khoảng cách (4/8/12/16/24 nội tuyến hôm nay trở thành hằng số có tên), một thang bo góc, `ChipThemeData` / `BottomSheetThemeData` để mọi sheet dùng chung một "chất liệu"; sửa lệch màu brand teal (`draw_toolbar.dart:63-65` dùng `0xFF0D9488`, theme dùng `0xFF0D8B86`). Vòng G3 cắt `PopupMenuThemeData` và thang đổ bóng — không site nào đang phân kỳ ở hai chỗ đó | Polish, không có parity ID — Spec **0044** | Mọi slice E sau này thừa hưởng một ngôn ngữ thị giác thay vì thêm kiểu thứ sáu |
| E3 | **Nội dung tab dim-scrim:** nội dung Bookmarks / Jump Links / hàng đợi Setlist của tab **Go to** hiển thị trên nền bản nhạc bị làm mờ nhưng vẫn thấy được, thay cho sheet cố định 55% chiều cao, che kín hôm nay | Mở lại cách trình bày của 0010 / 0012 / 0016 — Spec **0045** | Nhạc công giữ được ngữ cảnh không gian ("mình đang ở đâu") khi tra cứu, khớp drawer của ScorePDF |
| E4 | **Gọn header Library:** gộp ba hàng riêng biệt hôm nay (logo AppBar, `SegmentedButton`, ô tìm kiếm) thành hai — nav/search/view-toggle, rồi filter-chip/sort/hướng sắp xếp — khớp mật độ Home screen thật (không phải marketing) của ScorePDF. **Cắt khỏi phạm vi:** grid thumbnail — ảnh Home thật của ScorePDF cho thấy hàng chỉ có title, không có bằng chứng cho ý này | Chỉ đổi cách trình bày — Spec **0046** | Header ít hàng hơn, gọn hơn; nội dung hàng vốn đã dày hơn của StageScore (thumbnail, ngày, số trang, label) được giữ nguyên, không bị cắt bớt |
| E5 | **Một khuôn settings-sheet dùng chung:** một `SettingsRow` chung (icon + tiêu đề + mô tả phụ + control bên phải) áp lại cho Display, Page turn, Color filter, Metronome, Page scale, và Layout, thay năm kiểu chrome sheet khác nhau hôm nay | Mở lại cách trình bày của 0025 / 0026 / 0030 / 0031 / 0032 / 0036 — Spec **0047** | Mọi đích cài đặt đọc giống nhau; mô tả phụ đồng thời là copy onboarding thụ động cho E8 |
| E6 | **PageOrder dạng lưới không gian:** thay danh sách kéo-thả toàn `Scaffold` bằng lưới 2 cột các thẻ số trang (badge bookmark trên thẻ), và một hộp thoại Single/Multiple gọn để thêm trang | Mở lại **P1.6** (0011) — Spec **0048** | Sắp trang cho repeat/D.S. al Coda đọc như đang lật một xấp trang thật |
| E7 | **Toolbar vẽ gọn:** bỏ nền tint (sửa xong khi màu brand của E2 đúng), một hàng icon phẳng, gộp hai nơi chọn width/màu (hàng vs "More…") thành một | Chỉ đổi cách trình bày trên **P2.1–P2.3** — Spec **0049** | Toolbar bớt "ồn" giữa lúc chơi |
| E8 | **Đẩy sớm onboarding:** chạy Spec đã dành sẵn **0039** sau E5, vì copy mô tả phụ của E5 giảm một nửa công viết copy onboarding | Parity **Q7** — Spec **0039** (dùng lại) | Không viết copy coach-mark hai lần |

**Exit E:** Orchestrator nhìn StageScore và ScorePDF cạnh nhau, không còn đọc StageScore là "một app Material chưa hoàn thiện" — có cấu trúc phân loại công cụ nhìn thấy được trong PdfMode, một ngữ pháp sheet nhất quán, và một header Library gọn như của ScorePDF.

**Exit E đạt sớm, sau E1 + E2 (Orchestrator, 2026-07-29):** "UI như hiện tại tôi thấy OK rồi." **E3–E7 chuyển sang `hold`** — không cắt, chỉ không chạy: 0045, 0046, 0047, 0048, 0049 giữ số và giữ lý lẽ, mở lại nếu một đợt review sau này thấy cần. E8 (onboarding, Spec **0039**) không còn phụ thuộc E5 nữa nên nó quay về Phase C như thứ tự gốc.

Lý do dừng nằm ở chính phát hiện định hình phase này: khoảng cách với ScorePDF là **cách trình bày**, và hai slice đã đóng đúng hai khoảng cách có bằng chứng (IA của PdfMode, và ngôn ngữ thị giác dùng chung). Phần còn lại của E là làm cho *giống ScorePDF hơn* — mà đó không phải chỗ StageScore thắng. Hướng tiếp theo Orchestrator chọn là **những thứ nghệ sỹ / teacher / student cần mà ScorePDF không có**, trong giới hạn v1: offline, không thu thập dữ liệu, và không đụng SmartMode / Transport / OMR (ADR 0008). Các ứng viên đang được cân — xem `DECISIONS-LOG.md` 2026-07-29 — chưa có Spec nào; mỗi cái vẫn phải qua G3.

---

## Explicitly out of this roadmap

| Item | Where it lives |
|------|----------------|
| Max page DPI | Deferred with 0031; reopen only if sharpness blocks gigs |
| Cloud sync / multi-device | Later product decision |
| WaitMode / BackingTrack / OMR | H4–H6 after SmartMode |
| Monetization / ads parity | Not required for UX |

---

## Recommended next actions (Orchestrator)

**Phase A–D:** đã xong / đã qua gate như mô tả ở trên; không cần hành động gì thêm.

**Phase E (mới, 2026-07-28):**

1. Accept Phase E (hoặc cắt/xếp lại thứ tự slice) — mọi thứ ở trên đang `proposed`.
2. **Spec 0043 `done`** — G4 pass 2026-07-29 trên SM X210. Hình dạng cuối là Revision 3, sau ba lần đảo trong một ngày: `⋯` giữ nguyên với icon trên từng dòng; `ScoreMenuQuickBar` giữ đúng ba lối tắt theo luật "tay đang trên nhạc cụ" (Bookmarks, Draw, Metronome), và hình dạng của hàng đó do `QuickBarFit` **đo** chứ không do bảng breakpoint.
3. **Spec 0044 `done`** — G3 pass và G4 pass cùng ngày 2026-07-29. Vòng grilling trước G3 sửa lại chính đợt kiểm kê sinh ra Spec (drag handle hoá ra đã ship từ trước; `ChipThemeData` không diễn đạt được mật độ) và cắt `PopupMenuThemeData` cùng thang đổ bóng.
4. **E3–E7 `hold`** theo quyết định 2026-07-29 — xem "Exit E đạt sớm" ở trên. Việc kế tiếp **không** nằm trong roadmap này: chọn một hai tính năng khác biệt (nghệ sỹ / teacher / student) đủ nhỏ cho v1, rồi draft Spec cho nó.
5. Chỉ build sau khi mỗi Spec qua G3.

---

## Tracking

| Doc | Role |
|-----|------|
| [SCOREPDF-PARITY.md](./SCOREPDF-PARITY.md) | Checklist + polish appendix (nay có thêm Q10–Q16 cho Phase E) |
| [RELEASE-CHECKLIST.md](./RELEASE-CHECKLIST.md) | What stands between the build and a store submission — a separate track from this roadmap, opened when `1.0.0+1` was tagged |
| [DECISIONS-LOG.md](./DECISIONS-LOG.md) | Soft choices / weekly notes |
| Specs `0043`–`0049`, rồi `0039` | Các slice thực thi của Phase E |
