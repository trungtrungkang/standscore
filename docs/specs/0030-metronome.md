# 0030 — Metronome (tempo, meter, volume)

- **Status:** done
- **Type:** feature
- **Horizon:** H2
- **Owner (human):** Orchestrator
- **Depends on ADRs:** 0005, 0008
- **Depends on Specs:** 0029 (done); 0031–0033 (done)
- **Parity IDs:** P2.13
- **G3:** accepted (2026-07-26)
- **G3 notes:** Persist **app-wide**. Entry = PdfMode ⋯ → **Metronome…**. Sound = tick + accent; include **mute / visual-only**. Meter includes **Equal** (no strong/weak) plus common signatures (`2/2`, `3/8`, `6/8`, `9/8`, `12/8`, …). Denominator is label/grouping only; tempo stays BPM. GestureMap later out of scope.
- **G4:** pass (2026-07-26); **pass lại sau khi tái mở** (2026-07-29, SM X210 / Android 16)
- **Tái mở một phần (2026-07-29):** sheet tràn ở landscape (sửa), và beat indicator giờ ở lại trên Score sau khi chrome ẩn — xem "Cập nhật sau G4" bên dưới.

## Problem

Musicians practice and count off with a metronome while reading PDFs. ScorePDF offers tempo, time signature (accent), and independent volume from PdfMode. StageScore has no click track yet — and ADR 0008 allows a PDF-phase metronome without SmartMode / Transport.

## Outcome

From PdfMode, the user can open a **Metronome**, set **tempo**, **meter** (time signature with accent on beat 1), and **volume**, then start/stop audible clicks (or mute for visual-only). Settings persist app-wide. PageTurn and draw remain usable while the metronome runs.

## In scope

- PdfMode ⋯ → Metronome…
- Tempo: ~40–218 BPM, slider + direct entry
- Meter with accent on beat 1 (**2/2**, **2/4**, **3/4**, **3/8**, **4/4**, **5/4**, **5/8**, **6/4**, **6/8**, **7/4**, **7/8**, **9/8**, **12/8**), or **Equal** (same click every beat)
- Volume control; mute / visual-only
- Start / stop; visual beat indicator (not covering Score center)
- Persist last-used tempo / meter / volume / mute
- Works offline; no SmartMode / MIDI Transport dependency

## Out of scope

- Syncing metronome to SmartMode Playhead / Transport (H3+)
- GestureMap assignment for metronome (later slice)
- Subdivision clicks beyond simple meter accent
- Count-in that auto-starts PageTurn / AutoPlay
- Custom sound packs / tuning pitch

## Domain terms

**PdfMode**, **Score**

## Acceptance criteria

Testable checklist (G4):

- [x] User can open Metronome from PdfMode
- [x] User can set tempo within the allowed range (incl. direct entry)
- [x] User can set meter; accent lands on beat 1 of each bar
- [x] User can adjust metronome volume
- [x] Mute / visual-only: beats advance without sound
- [x] Start/stop produces/stops audible clicks (when not muted)
- [x] Settings survive app restart (app-wide)
- [x] PageTurn / draw still work while the metronome is running

## UX notes

- Compact sheet — not a full settings app
- Beat indicator visible without covering the Score center (e.g. AppBar / edge chip)

## Technical constraints

- Prefer Flutter audio that works in foreground; keep module deep (Metronome engine ≠ PdfMode UI)
- Click algorithm: absolute wall-clock beat schedule; **one** sound per beat (accent *or* tick); low-latency mixer (`flutter_soloud`). Avoid per-beat seek/loop seams and double-layered downbeats.
- iOS: `AVAudioSessionCategory.playback` via `audio_session` so clicks work with the Ring/Silent switch on.
- While running: **wakelock** (no idle dim/lock while practicing); audible clicks from a **looping** sample-timed buffer so sound continues after lock (`UIBackgroundModes: audio`). Visual dots are foreground-only.
- TDD: tempo/meter scheduling math (accent index); prefs round-trip
- Do not start Transport / Verovio work

## Test plan

- Automated: prefs round-trip; accent beat index for common meters
- Manual: start at 60 / 4/4; change tempo live; volume; mute; restart; PageTurn while clicking

## Cập nhật sau G4 (tái mở một phần, 2026-07-29)

### 1. Metronome sheet tràn ở landscape (defect)

**Vấn đề (musician báo cáo):** xoay ngang máy rồi bấm Metronome thì sheet báo `A RenderFlex overflowed by 144 pixels on the bottom`; ở màn hình dọc thì không sao. Hậu quả thật sự nặng hơn cái sọc vàng đen: nút **Start** nằm ở cuối `Column` nên trong landscape nó **không thể chạm tới được** — metronome mở ra mà không bật được.

**Root cause:** `_MetronomeSheet` là `SafeArea > Padding > Column(mainAxisSize: min)`, không có gì cuộn được bên trong. Spec 0035 đã sửa nửa đầu của chuyện này ("sheet kết thúc ở chỗ nội dung kết thúc, không ghim theo % màn hình") nhưng chỉ cho những sheet nó viết lại — Layout và Page turn có `Flexible` + `ListView` nên vẫn cuộn được. Ba sheet phẳng hơn thì không: một phone nằm ngang chỉ cho bottom sheet ~336 pt trong khi nội dung metronome cần ~480.

**Quét ra thêm hai chỗ vỡ y hệt** mà chưa ai báo, do test mới mở từng sheet ở `852×393`: **Display** tràn 31 pt, **Page scale** tràn 63 pt. Cùng một hình dạng sai thì cùng một chỗ sửa, nên cả ba dùng chung `lib/ui/sheet_body.dart` (`SheetBody`): `ConstrainedBox(maxHeight: 90% màn hình)` + `SingleChildScrollView`. Hai tính chất đó ở chung một widget là có chủ ý — cap mà không cuộn thì che nội dung, cuộn mà không cap thì sheet trùm lên Score.

### 2. Dải chấm beat ở lại trên Score (yêu cầu mới)

**Yêu cầu (Orchestrator):** khi metronome đang chạy, cho phép luôn hiện dải chấm beat ở chỗ hợp lý trên màn hình, vì chrome sẽ tự ẩn sau vài giây.

**Lý lẽ mạnh hơn cả sự tiện lợi:** chế độ **Mute (visual only)** trong chính Spec này trở thành vô nghĩa ngay khi chrome ẩn — đã tắt tiếng, mà hình cũng mất, thì metronome không còn output nào cả. UX notes gốc đã nói "beat indicator visible without covering the Score center"; đây là chỗ ghi nốt nửa còn thiếu: sau khi chrome đi rồi thì nó ở đâu.

**Bốn quyết định (Orchestrator chấp nhận cả bốn khuyến nghị, 2026-07-29):**

1. **Vị trí: giữa mép trên.** Trên giá nhạc, đó là dải gần tầm mắt nhất, và là dải duy nhất của trang không có nốt nào (lề trên). Không dùng góc dưới bên phải vì đó vừa là vùng tap PageTurn chính khi PageNavBar đã đi (0034) vừa là chỗ `PagePositionPill` (0036) đang đứng.
2. **Bật/tắt: một switch trong metronome sheet ("Show beats on the Score"), default bật.** Dải chỉ tồn tại khi metronome đang chạy, mà chạy là một hành động có ý — không phải thứ tự dưng xuất hiện. Installs cũ (prefs JSON chưa có key) cũng được bật, giống cách 0034 làm với PerformanceMode.
3. **Nội dung: đúng dãy chấm theo số phách trong nhịp**, dùng lại cùng một widget với sheet (`BeatDots`, tách khỏi `metronome_sheet.dart`) — sheet và Score không bao giờ được vẽ khác nhau về số phách hay chấm nào là accent. Trên Score `scale: 1.6` vì đọc ở khoảng cách giá nhạc, không phải trong tay.
4. **Sửa luôn chuyện rebuild mỗi phách.** `PdfModeScreen` đang `addListener(_onMetronomeChanged)` → `setState(() {})`, tức **cả màn hình kể cả PDF viewer rebuild mỗi phách** — hơn 3 lần/giây ở 200 BPM, ngay trong lúc musician đang chơi. Có từ trước bản này (do tint icon metronome), nhưng thêm một dải nhấp nháy sẽ làm nó nặng thêm, và đúng loại nguyên nhân làm tap-to-turn cảm giác chậm mà 0033 vừa đi chữa. Nay `_onMetronomeChanged` chỉ `setState` khi `isRunning` **đổi**; nhịp đi qua `ListenableBuilder` bọc riêng `BeatStrip` và `ScoreMenuQuickBar`.

**Hành vi:** `BeatStrip` (`lib/ui/beat_strip.dart`) luôn nằm trong `Stack` của PdfMode — một child xuất hiện/biến mất là một child có thể làm viewer bên cạnh nó rebuild — và tự quyết định hiện hay không: `!chromeShown && engine.isRunning && prefs.showBeatsOnScore`. Điều kiện pref và `isRunning` đọc **bên trong** `ListenableBuilder`, nên tắt switch trong sheet có hiệu lực ngay mà không cần màn hình rebuild. Giống `PagePositionPill`: bọc `IgnorePointer` nên tap PageTurn xuyên qua, không có reveal, không đụng vào countdown auto-hide của chrome. Chrome đang hiện thì dải ẩn — AppBar chiếm đúng dải đó, và icon metronome ở quick bar đã tint sẵn. PerformanceMode tắt (chrome luôn hiện) thì dải không bao giờ hiện, đúng theo luật đó.

**Test:** `test/beat_strip_test.dart` (7 test: đứng im khi chưa chạy, hiện khi chạy + chrome ẩn, ẩn khi chrome hiện, switch tắt được mà metronome vẫn chạy, tap xuyên qua tới vùng dưới, số chấm + chấm active + accent theo nhịp, scale lớn hơn bản trong sheet). `test/settings_sheet_height_test.dart` thêm nhóm landscape `852×393` cho cả năm sheet của PdfMode, bắt `takeException()` phải null. `test/metronome_prefs_test.dart` thêm default và round-trip cho `showBeatsOnScore`. 335 tests xanh, analyze sạch.

### 3. G4 trên thiết bị thật — pass, kèm một phát hiện còn mở (2026-07-29)

Demo trên **SM X210** (Android 16, 800×1280 dp). Dải chấm hiện đúng chỗ giữa mép trên sau khi chrome ẩn, switch có tác dụng, tap PageTurn xuyên qua. **Orchestrator: pass.**

**Phát hiện trong lúc demo (chưa sửa):** musician báo tiếng click **đến sau** dải chấm một chút — chấm sáng trước, tiếng theo sau. Gate vẫn pass vì độ lệch nhỏ và dải chấm vẫn làm đúng việc của nó, nhưng nguyên nhân đã chẩn đoán xong nên ghi lại để không phải tìm lại:

Engine chạy **hai đồng hồ không có gì nối với nhau** — chấm hình theo `DateTime` của Dart, tiếng theo sample clock của thiết bị. Trong `start()`, `_anchorTime = DateTime.now()` được đặt **trước** `_emitVisualBeat()` rồi mới `await _startLoopAudio()` (dựng PCM → `loadMem` → `play()`). Mọi thứ xảy ra sau mốc đó là **lệch pha vĩnh viễn**, vì sau đó hai đồng hồ chạy tự do cùng tốc độ nên sai số không bao giờ tự sửa. Ba số hạng, theo thứ tự độ lớn:

1. **Mốc hình đặt trước khi tiếng bắt đầu.** Đo `synthesizeMetronomeLoopWav` trên Mac: 1–10 ms tuỳ nhịp (nặng nhất 40 bpm 12 phách — 9,7 ms, buffer 1,5 MiB), trên máy thì hơn. Cộng `loadMem` (copy qua FFI đúng buffer đó) và `play()`. Đáng chú ý: số hạng này **không phải hằng số** — nó lớn theo kích thước buffer, nên tempo chậm / nhịp nhiều thì lệch nhiều hơn tempo nhanh / nhịp ít.
2. **Độ trễ output của thiết bị**, thứ không có cách đảo thứ tự nào xoá được: `init(bufferSize: 512)` ≈ 11,6 ms ở 44,1 kHz, cộng đường ra của nền tảng.
3. **Trôi chậm giữa hai đồng hồ**, vì sample rate thật của thiết bị không đúng 44 100 Hz danh nghĩa — nên dù mốc có hoàn hảo thì sau một buổi tập dài chấm và tiếng vẫn tách ra.

Orchestrator chọn **sửa ngay trong cùng lượt** thay vì để sang slice sau — xem phần 4.

### 4. Sửa: cho play head của audio làm đồng hồ (2026-07-29, tái mở lần hai)

**Nguyên tắc:** bỏ đồng hồ thứ hai đi, đừng hiệu chỉnh nó. Chấm và tiếng không thể lệch nhau nếu chúng đọc **cùng một** đồng hồ, và đồng hồ duy nhất có thẩm quyền là cái đang phát ra tiếng — play head của loop.

- **`beat_clock.dart` (mới):** một hàm thuần `beatInBarFromLoopPosition(position, beatInterval, beatsPerBar)`. Nó nhận **vị trí**, không nhận số đếm phách, nên **không có trạng thái**: đọc muộn (rớt frame, isolate bận) thì ra phách *đang* kêu, chứ không đẩy lệch số đếm như bộ `Timer` cũ vẫn làm. Nó lấy **modulo theo khuông**, nên đúng bất kể backend báo play head quay vòng hay cộng dồn.
- **Vì sao modulo, chứ không phải phòng xa:** đọc source SoLoud thì hành vi này *không* nhất quán để mà tin — `soloud.cpp:2159` cộng `buffertime` vào `mStreamPosition` mỗi lần mix, còn `WavInstance::rewind()` lại đặt nó về `0` mỗi lần loop. Plugin không hứa gì về điểm này, nên phép ánh xạ không được phụ thuộc vào nó.
- **`start()` đảo thứ tự:** `await _startLoopAudio()` **trước**, rồi mới lập đồng hồ. Đây chính là bản sửa cho số hạng 1 — không còn cái mốc nào đặt trước lúc tiếng bắt đầu để mà lệch.
- **Mute (visual only)** là trường hợp duy nhất không có play head, nên cũng là trường hợp duy nhất còn cần đồng hồ riêng: một `Stopwatch` **monotonic** (không phải `DateTime`, thứ có thể nhảy khi hệ thống chỉnh giờ) đưa vào **cùng** hàm ánh xạ đó. `_silentOffset` mang vị trí cuối của play head sang, nên bấm mute giữa khuông thì nhịp đi tiếp chứ không đếm lại từ đầu.
- **Loop chế độ Equal giờ dài đủ một khuông** thay vì một phách. Nghe y hệt, nhưng khiến play head là vị trí *trong khuông* với mọi nhịp — nên chỉ còn **một** phép ánh xạ phải bảo trì thay vì một cho mỗi chế độ.
- **`metronomeAudioBeatInterval`:** đồng hồ chia theo độ dài phách *thật của buffer đang phát* (đã làm tròn về số sample nguyên), không theo `MetronomePrefs.beatInterval` danh nghĩa. Lệch dưới 10 µs mỗi phách, nhưng một play head cộng dồn sẽ biến nó thành trôi thấy được sau buổi tập dài.
- **Nhịp thông báo không tăng:** poll 16 ms (một frame ở 60 fps) nhưng chỉ `notifyListeners()` khi **số phách đổi** — vẫn đúng bằng số phách/giây như trước, giữ nguyên quyết định 4 ở trên.

**Còn lại, không xoá được bằng software:** độ trễ output của thiết bị (số hạng 2). `getPosition` báo vị trí mixer **đã sản xuất**, còn thiết bị phát bản đó sau đó — nên chấm vẫn sớm hơn tiếng đúng bằng khoảng đệm ra loa (`bufferSize: 512` ≈ 11,6 ms ở 44,1 kHz, cộng phần cứng). Khác biệt so với trước: nó **nhỏ và là hằng số**, không còn lớn dần theo tempo chậm / nhịp nhiều. Cố ý **không** đặt hằng số bù ước lượng vào engine: không đo được từ software thì con số đó là phỏng đoán, và bù quá tay sẽ làm chấm *trễ* hơn tiếng — hướng sai mà tai người nhạy hơn.

**Xác nhận trên thiết bị (2026-07-29, SM X210):** musician nghe lại và chấm khớp tiếng — **pass**. Nghĩa là độ trễ output còn lại (số hạng 2) nằm dưới ngưỡng nghe ra được trên máy này, đúng như kỳ vọng khi nó chỉ còn là hằng số nhỏ; và play head *có* nhích với source `loadMem`, thứ chỉ demo mới trả lời được.

**Test:** `test/beat_clock_test.dart` (13 test: play head → phách đang kêu, quay vòng ở vạch khuông, **play head cộng dồn 50 khuông vẫn đúng**, đọc muộn không đẩy số đếm, vị trí âm vẫn nằm trong khuông, các nhịp khác 4/4, interval vô nghĩa thì về phách đầu, và ở 40/60/100/120/218 BPM thì độ dài khuông của đồng hồ **khớp buffer sinh ra thật**, phách cuối không bao giờ đọc thành phách đầu của khuông sau). `test/click_wav_test.dart` đổi test "equal loop dài một phách" thành "vẫn dài đủ khuông" cộng một test rằng mọi click ở chế độ Equal giống nhau. 349 tests xanh (335 trước), analyze sạch.
