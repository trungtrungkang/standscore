# StageScore

Ngôn ngữ miền của **StageScore**, một sản phẩm thuộc Backing & Score (https://backingscore.com).  
Chi tiết hiện thực không thuộc về file này — chỉ có thuật ngữ và ý nghĩa.

Tên thuật ngữ giữ tiếng Anh, định nghĩa viết tiếng Việt (ADR 0015). Các dòng `_Avoid_` giữ nguyên tiếng Anh, vì đó là những từ có thể lọt vào code hoặc UI.

## Ngôn ngữ (Language)

### Library (Thư viện)

**Score**:
Đơn vị chơi được trong library — dựa trên một PDF và/hoặc MusicXML, tuỳ chọn kèm BackingTrack. Một Score có thể **chứa Score con** (cùng một PdfDocument, mỗi con một PageExtent); Score không có con là trường hợp thường. Library mặc định chỉ hiện Score gốc (`parentId` null); chữ *piece* trên UI chỉ là Score con, không phải loại riêng (ADR 0019 quyết định 11 revision 6).
_Avoid_: Song, file, track (ambiguous), Piece (as a domain type — use Score; ok in UI copy only as "piece"/"pieces")

**Setlist**:
Một nhóm Score có thứ tự, để xem hoặc biểu diễn liên tiếp mà không phải mở lại từng Score bằng tay.
_Avoid_: Playlist, album, folder

**Label**:
Một nhãn do người dùng tự định nghĩa, gán lên Score hoặc Setlist để lọc.
_Avoid_: Tag (ok as UI synonym), category, genre (too narrow)

### Documents (Tài liệu)

**PdfDocument**:
Phần byte PDF và các ảnh trang. Một PdfDocument phục vụ **nhiều** Score được (gốc + các con, mỗi con một PageExtent). Có **tên riêng** (`title`) làm fallback; tên người dùng thấy trên Library của một cuốn đã tách là **title của Score gốc**, không phải một hàng PdfDocument. PdfDocument **không bao giờ** tự là một hàng Library hay vào Setlist — đơn vị đó là Score (ADR 0019 quyết định 11 revision 6).
_Avoid_: PDF score (use Score + PdfDocument), file, book (ok in UI copy only)

**PageExtent**:
Khoảng trang liên tục của một PdfDocument thuộc về một Score. Nó là **phạm vi** — trang nào là của bản nhạc này — đặt lúc tách bài và sửa được, nhưng hiếm khi đổi. Nó **không phải** PageOrder: PageOrder là *trình tự*, và PageOrder chạy bên trong PageExtent.
_Avoid_: page range (ok in UI copy only), page span, section, slice

**MusicXmlDocument**:
Nguồn MusicXML gắn với khung xem Smart Score của một Score.
_Avoid_: XML score, digital score (vague)

**PageOrder**:
Chuỗi trang PDF do người dùng tự sắp cho lúc biểu diễn (kể cả trang lặp lại và trang trắng), dùng để xử lý đoạn lặp và bước nhảy mà không phải điều hướng trực tiếp.
_Avoid_: Page sort, rearrange list

### Viewing (Xem)

**PdfMode**:
Chế độ xem Score dựng PdfDocument, kèm cách điều hướng hướng tới biểu diễn.
_Avoid_: Classic mode, ScorePDF mode

**SmartMode**:
Chế độ xem Score dựng MusicXmlDocument (ví dụ qua Verovio), kèm các tính năng phát nhạc và luyện tập.
_Avoid_: MusicXML mode, Verovio mode (engine name ≠ product mode)

**MeasureMap**:
Hình học ô nhịp trên trang của **một** Score — SystemBox → MeasureBox → BeatBox. Biết *chỗ nào trên giấy*, không phải *khi nào trong thời gian*. Một Score ↔ đúng một MeasureMap; bản đồ chưa đầy đủ vẫn hợp lệ. Neo theo số trang tuyệt đối của PdfDocument (cùng không gian với annotation).
_Avoid_: MeasureAnchor (rút bởi ADR 0019), RowBox (dùng SystemBox), sync file, bar map

**SystemBox**:
Một *system* (dòng nhạc) trên trang trong MeasureMap. Không lưu riêng trên đĩa — dựng lại bằng cách gom MeasureBox theo `systemIndex`.
_Avoid_: RowBox, staff system box, line box

**MeasureBox**:
Một ô nhịp trên trang: hình chữ nhật chuẩn hoá 0–1, `measureNumber` liên tục trong Score, tuỳ chọn time signature / tempo (kế thừa), và `beatSplits`. Trùng **tên** với repo web; hình học phách trên đĩa **khác hình dạng wire** — xem BeatBox.
_Avoid_: bar box, measure rect, MeasureAnchor

**BeatBox**:
Một phách trong MeasureBox. Trên đĩa StageScore: `beatSplits` = **N mốc nội tại** (một tỉ lệ 0..1 cho mỗi phách, không tính hai vạch nhịp mép ô; mặc định tâm lát `(i+0.5)/N`) — kéo khớp nốt in. Wire web: cùng tên field nhưng **N−1 biên** giữa phách; dịch centres ↔ midpoints lúc encode/decode (Spec 0058 rev. 2). UI mặc định ẩn đến *Edit beats*. **Vị trí trên giấy ≠ thời lượng** — thời lượng thuộc SyncMap (tempo + time signature).
_Avoid_: beat rect, subdivision box, N−1 interior dividers (đó là hình dạng web, không phải store StageScore)

**PerformanceMode**:
Một trạng thái xem của PdfMode, trong đó chrome của app bị ẩn cho tới khi một GestureMap gọi nó ra, chỉ để lại Score.
_Avoid_: Immersive mode, fullscreen (system-level), presentation mode

**ScoreMenu**:
Điểm vào được gom nhóm cho mọi thứ PdfMode có thể làm với Score đang xem, mở từ dấu ⋯ trên AppBar hoặc từ một GestureMap. Ngoài `⋯`, một **ScoreMenuQuickBar** nằm trong chrome đáy khi chrome hiện, giữ lối tắt cho đúng ba action mà nhạc công cần *khi tay đang trên nhạc cụ*: Bookmarks, Draw, Metronome. Mỗi lối tắt gọi thẳng hành động đã có trong `⋯`, không phải một lối vào nội dung mới; mọi thứ khác (kể cả Layout và nhóm View) chỉ có trong `⋯`, vì chúng là việc làm lúc dựng bài chứ không phải lúc đang chơi. Hình dạng của hàng đó không cố định: nó xếp chồng dưới PageNavBar khi màn hình đủ cao, gộp vào chính hàng thanh trượt khi không, và chỉ vẽ nhãn chữ khi chữ đo được là vừa — xem **QuickBarFit**.
_Avoid_: Overflow menu, kebab menu, settings (it holds actions as well as settings)

**StagePreset**:
Một entry trong ScoreMenu, đưa app vào trạng thái sẵn sàng biểu diễn (ẩn chrome, ẩn status bar, giữ nguyên scale) hoặc quay về trạng thái luyện tập. Đây là một hành động, không phải một chế độ: nó ghi đúng những pref mà các sheet Display và Page scale ghi, và nhãn của nó được đọc ngược lại từ chính những pref đó. *Avoid*: stage mode, gig mode, performance mode (that is the 0034 setting it flips).

**LayoutFit**:
Những gì viewport hiện tại cho phép một Score: liệu có vừa hai trang cạnh nhau, còn dư bao nhiêu để hé trang kế, và layout nào phù hợp với màn hình. Được tính từ viewport và tỷ lệ trang ở mỗi lần build, không bao giờ lưu lại.
_Avoid_: Auto layout (that is the user-facing mode that reads this), fit zoom (that is `pdfFitZoom`, the scale), responsive layout

**QuickBarFit**:
Những gì màn hình hiện tại cho phép chrome đáy: xếp chồng được hai hàng hay phải gộp lối tắt vào hàng thanh trượt, một slot lối tắt rộng bao nhiêu, và nhãn chữ có vừa dưới icon hay không. Cùng ý với LayoutFit nhưng hỏi cho chrome thay vì cho Score, và cũng không bao giờ lưu lại — điện thoại nằm ngang và tablet trả lời khác nhau, nên câu trả lời thuộc về từng lần build.
_Avoid_: breakpoint, responsive rule (there is no threshold table — it is measured), tab strip (that was the shape Spec 0043 tried twice and dropped)

**PageTurn**:
Việc đưa khung xem biểu diễn tiến lên hay lùi lại theo luật layout và luật cử chỉ (bao gồm cả tương đương từ pedal và bàn phím).
_Avoid_: Scroll (only when layout is continuous scroll), swipe (a gesture, not the action)

**TurnAmount**:
Một PageTurn đi được bao xa — trọn trang (1/1) hay nửa trang (1/2). *Layout* Half Page (Spec 0056) dùng một bước TurnAmount cố định (nửa trang) ở bên trong để scroll liên tục, nhưng không để nhạc công chỉnh setting này — chỉnh sửa được sẽ chỉ gây nhầm vì bước đã bị ép cứng.
_Avoid_: Half page (ambiguous with layout mode), scroll step (implementation)

**GestureMap**:
Việc người dùng gán các hành động không phải PageTurn (hiện chrome, hoặc tắt) cho thao tác nhấn giữ và chạm vào rìa màn hình.
_Avoid_: Shortcut map, hotkeys (keyboard), PageTurn tap zones (prev/next halves)

**Bookmark**:
Một mốc trang có tên trên một Score, để nhảy nhanh khi biểu diễn hoặc luyện tập.
_Avoid_: Favorite, pin, TOC entry (PDF outline ≠ user Bookmark)

**JumpLink**:
Một vùng chạm thấy được ngay trên trang, dẫn tới một trang biểu diễn khác của cùng Score (khác với việc nhảy từ danh sách Bookmark, và khác với link trong outline của PDF).
_Avoid_: Hyperlink (web), bookmark button, page jump (UI copy ok)

**Stamp**:
Một ký hiệu, hình khối, hoặc đoạn chữ ngắn được đặt lên trang của một Score (khác với nét vẽ tay tự do).
_Avoid_: Sticker, emoji (too casual), annotation (broader)

**Playhead**:
Chỉ báo vị trí phát trên giấy theo SyncMap × MeasureMap (`beatSplits`) — trên PdfMode khi Playback controls đang Play/Pause (Spec 0059). Cũng dùng trong SmartMode khi Transport chạy.
_Avoid_: Cursor (ambiguous with text caret), progress bar, scrubber

**PlaybackControls**:
UI Play / Pause / Stop trên PdfMode (show/hide từ ScoreMenu). Chạy timeline SyncMap + click metronome; không phải Transport đầy đủ (0062).
_Avoid_: Transport bar, media controls (generic)

### Playback & practice (Phát nhạc và luyện tập)

**Transport**:
Engine giữ quyền quyết định về thời gian và điều khiển cho việc phát nhạc và luyện tập (play, pause, seek, tempo). Nó trộn nhiều TransportLane dưới cùng một clock. Trên mobile, nó thuộc quyền của tầng audio native.
_Avoid_: Player, sequencer (implementation), Web Audio clock

**TransportLane**:
Một luồng âm thanh nghe được do Transport điều khiển (tiếng click, MIDI dẫn, hoặc audio nền), có gain/mute/solo riêng.
_Avoid_: Track (ambiguous), channel (audio engineering jargon in product language)

**BackingTrack**:
Một bản thu âm (bản mix đầy đủ hoặc một stem) mà người dùng chơi cùng, gắn vào một Score và được khớp thời gian qua một SyncMap.
_Avoid_: Soundtrack, accompaniment file, band track (UI copy ok), MP3 (format ≠ concept)

**SyncMap**:
Sự khớp giữa thời gian âm nhạc (ô nhịp/phách, hoặc thời gian theo MusicXML) và một dòng thời gian phát — có thể gắn một hay nhiều BackingTrack, hoặc chỉ metronome / thời gian nhạc thuần (không bắt buộc có audio). Trên PdfMode (Spec 0059) được **tính** từ MeasureMap (tempo + time signature → `timeMs` / `beatTimestamps`); không ghi đĩa riêng trong slice đó.
_Avoid_: Offset alone, BPM (too narrow), sync file (may be a serialization of SyncMap)

**AutoPlay**:
Việc Transport phát các TransportLane đang được arm, đồng thời đẩy Playhead tiến lên.
_Avoid_: MIDI play (too low-level alone)

**WaitMode**:
Một chế độ luyện tập, trong đó Transport chờ người dùng phát ra đúng nốt được mong đợi (qua MIDI hoặc qua cao độ) rồi mới đi tiếp, theo một PracticePolicy.
_Avoid_: Follow mode, practice mode (generic), call-and-response

**PracticePolicy**:
Luật quy định WaitMode đối xử với các TransportLane thế nào (ví dụ dừng toàn bộ các lane, hay lặp lại một ô nhịp).
_Avoid_: Wait settings (vague)

**MidiRealization**:
Các sự kiện MIDI đã có mốc thời gian, dẫn xuất từ một MusicXmlDocument, dùng cho MidiLane và để đối chiếu khi luyện tập.
_Avoid_: MIDI file (may be an export artifact), soundtrack

### Capture (Thu nhận)

**OmrJob**:
Một tiến trình biến ảnh chụp hoặc bản scan của bản nhạc thành một MusicXmlDocument ở dạng nháp.
_Avoid_: Scan (the capture act), OCR (wrong domain), recognition (vague)

**CorrectionSession**:
Bước con người soát và sửa, biến bản MusicXML nháp do OMR sinh ra thành một MusicXmlDocument đã được chấp nhận.
_Avoid_: Edit mode (too broad), proofreading

### Monetization (Kiếm tiền — tuỳ chọn về sau)

**ProEntitlement**:
Một lần mở khoá đã trả tiền cho các tính năng bị chặn; chi tiết chưa xác định, và không được rò rỉ vào miền cốt lõi cho tới khi có quyết định.
_Avoid_: Subscription (unless that model is chosen)
