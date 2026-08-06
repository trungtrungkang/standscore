// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get actionCancel => 'Hủy';

  @override
  String get actionSave => 'Lưu';

  @override
  String get actionDone => 'Xong';

  @override
  String get actionDelete => 'Xóa';

  @override
  String get actionOk => 'OK';

  @override
  String get actionClear => 'Xóa';

  @override
  String get actionApply => 'Áp dụng';

  @override
  String get actionAdd => 'Thêm';

  @override
  String get actionEdit => 'Sửa';

  @override
  String get actionRename => 'Đổi tên';

  @override
  String get actionBack => 'Quay lại';

  @override
  String get actionMore => 'Xem thêm';

  @override
  String get actionGo => 'Đi';

  @override
  String get actionUndo => 'Hoàn tác';

  @override
  String get actionContinue => 'Tiếp tục';

  @override
  String get actionReset => 'Đặt lại';

  @override
  String get commonOr => 'hoặc';

  @override
  String get commonTitleLabel => 'Tiêu đề';

  @override
  String get themeModeSystem => 'Hệ thống';

  @override
  String get themeModeLight => 'Sáng';

  @override
  String get themeModeDark => 'Tối';

  @override
  String get pdfLayoutModeAuto => 'Tự động';

  @override
  String get pdfLayoutModeSingle => 'Một trang';

  @override
  String get pdfLayoutModeTwoPages => 'Hai trang';

  @override
  String get pdfLayoutModeScroll => 'Cuộn';

  @override
  String get pdfLayoutModeScrollSideways => 'Cuộn (ngang)';

  @override
  String get pdfLayoutModeHalfPageTopBottom => 'Một trang + hé trang';

  @override
  String get pdfLayoutModeHalfPageLeftRight => 'Một trang + hé bên';

  @override
  String get pageColorFilterOff => 'Tắt';

  @override
  String get pageColorFilterSepia => 'Sepia';

  @override
  String get pageColorFilterGreen => 'Xanh lá';

  @override
  String get pageColorFilterInvert => 'Đảo màu';

  @override
  String get pageScaleScopeFixed => 'Cố định';

  @override
  String get pageScaleScopePerScore => 'Theo Score';

  @override
  String get pageScaleScopePerPage => 'Theo trang';

  @override
  String get stagePresetSetUpToPlay => 'Sẵn sàng biểu diễn';

  @override
  String get stagePresetSetUpToPractise => 'Sẵn sàng luyện tập';

  @override
  String get stagePresetChromeHidden => 'đã ẩn giao diện';

  @override
  String get stagePresetChromeShown => 'đã hiện giao diện';

  @override
  String get stagePresetStatusBarShown => 'đã hiện thanh trạng thái';

  @override
  String get stagePresetStatusBarHidden => 'đã ẩn thanh trạng thái';

  @override
  String get stagePresetScaleKept => 'giữ nguyên tỉ lệ';

  @override
  String get stagePresetPinchFree => 'chụm tự do';

  @override
  String get relativeDayToday => 'hôm nay';

  @override
  String get relativeDayYesterday => 'hôm qua';

  @override
  String relativeDayDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'ngày',
      one: 'ngày',
    );
    return '$days $_temp0 trước';
  }

  @override
  String pageOrderEditorEntryBlank(int index) {
    return '$index. Trống';
  }

  @override
  String pageOrderEditorEntryPdfPage(int index, int sourcePage) {
    return '$index. Trang PDF $sourcePage';
  }

  @override
  String get pageOrderEditorResetTitle => 'Đặt lại về ban đầu?';

  @override
  String get pageOrderEditorResetBody =>
      'Khôi phục thứ tự trang PDF gốc và xóa các trang trống, trang trùng?';

  @override
  String get pageOrderEditorReset => 'Đặt lại';

  @override
  String get pageOrderEditorAppBarTitle => 'Thứ tự trang';

  @override
  String get pageOrderEditorNoPages => 'Không có trang nào';

  @override
  String get pageOrderEditorDuplicate => 'Nhân bản';

  @override
  String get pageOrderEditorInsertBlank => 'Chèn trang trống';

  @override
  String get pageOrderEditorRemove => 'Xóa';

  @override
  String get librarySortTitle => 'Tiêu đề';

  @override
  String get librarySortCreated => 'Ngày tạo';

  @override
  String get librarySortLastViewed => 'Xem gần nhất';

  @override
  String scoreOriginPage(int page) {
    return 'Trang $page';
  }

  @override
  String scoreOriginPages(int first, int last) {
    return 'Trang $first–$last';
  }

  @override
  String scoreOriginPagesOfBook(String pages, String name) {
    return '$pages của $name';
  }

  @override
  String libraryVisibilityInBook(String title) {
    return 'trong $title';
  }

  @override
  String get libraryVisibilityInBookFallback => 'trong sách';

  @override
  String get libraryBackupFileNotFound => 'Không tìm thấy file sao lưu.';

  @override
  String get libraryBackupFailedGeneric => 'Sao lưu thất bại.';

  @override
  String libraryBackupCreateFailed(String error) {
    return 'Không thể tạo bản sao lưu: $error';
  }

  @override
  String libraryBackupRestoreFailed(String error) {
    return 'Không thể khôi phục bản sao lưu: $error';
  }

  @override
  String get libraryBackupMissingMarker =>
      'Không phải bản sao lưu StageScore (thiếu dấu hiệu nhận diện).';

  @override
  String get libraryBackupUnknownFormat =>
      'Không phải bản sao lưu StageScore (định dạng không xác định).';

  @override
  String get libraryBackupUnsupportedVersion =>
      'Phiên bản sao lưu StageScore không được hỗ trợ.';

  @override
  String get libraryBackupCorruptMarker =>
      'Không phải bản sao lưu StageScore (dấu hiệu nhận diện bị hỏng).';

  @override
  String get gestureMapLongPress => 'nhấn giữ';

  @override
  String get gestureMapTapTopEdge => 'chạm mép trên';

  @override
  String get gestureMapTapBottomEdge => 'chạm mép dưới';

  @override
  String get gestureMapEmptyHint =>
      'Đặt một cử chỉ thành Hiện menu / giao diện để gọi lại nó.';

  @override
  String gestureMapRevealHint(String joined) {
    return 'Ẩn thanh công cụ và thanh trang khi bạn chơi. Để hiện lại, $joined.';
  }

  @override
  String get layoutNavigationPedalOrPageBar => 'Pedal hoặc thanh trang';

  @override
  String get layoutNavigationTapLeftRight => 'chạm trái / phải';

  @override
  String get layoutNavigationTapTopBottom => 'chạm trên / dưới';

  @override
  String get layoutNavigationTapAnywhere => 'chạm bất kỳ đâu';

  @override
  String get layoutNavigationTapAnywhereBack => 'chạm bất kỳ đâu để quay lại';

  @override
  String get layoutNavigationSwipe => 'vuốt';

  @override
  String get layoutNavigationSwipeSideways => 'vuốt ngang';

  @override
  String get layoutNavigationSwipeUpDown => 'vuốt lên / xuống';

  @override
  String get scoreMenuSheetTitle => 'Menu';

  @override
  String get appearanceSheetTitle => 'Giao diện';

  @override
  String get appearanceSheetMode => 'Chế độ';

  @override
  String get appearanceSheetThemeColor => 'Màu chủ đề';

  @override
  String get appearanceSheetCustomChip => 'Tùy chỉnh';

  @override
  String get appearanceSheetCustomColorDialog => 'Màu tùy chỉnh';

  @override
  String get appearanceSheetHue => 'Màu';

  @override
  String get appearanceSheetSat => 'Bão hòa';

  @override
  String get appearanceSheetVal => 'Độ sáng';

  @override
  String get scoreMenuGoTo => 'Đi tới';

  @override
  String get scoreMenuBookmarks => 'Bookmarks';

  @override
  String get scoreMenuJumpLinks => 'Jump Links';

  @override
  String get scoreMenuPageOrder => 'Thứ tự trang…';

  @override
  String get scoreMenuGoToMeasure => 'Tới ô nhịp…';

  @override
  String get scoreMenuMeasureMap => 'Measure map…';

  @override
  String get scoreMenuMarks => 'Đánh dấu';

  @override
  String get scoreMenuHideAnnotations => 'Ẩn chú thích';

  @override
  String get scoreMenuShowAnnotations => 'Hiện chú thích';

  @override
  String get scoreMenuExporting => 'Đang xuất…';

  @override
  String get scoreMenuExportAnnotated => 'Xuất PDF kèm chú thích';

  @override
  String get scoreMenuView => 'Xem';

  @override
  String get scoreMenuLayout => 'Bố cục';

  @override
  String get scoreMenuDisplay => 'Hiển thị…';

  @override
  String get scoreMenuColorFilter => 'Bộ lọc màu…';

  @override
  String get scoreMenuPageScale => 'Tỉ lệ trang…';

  @override
  String get scoreMenuLocked => 'Đã khóa';

  @override
  String get scoreMenuPlaying => 'Đang phát';

  @override
  String get scoreMenuMetronomeRunning => 'Metronome (đang chạy)…';

  @override
  String get scoreMenuMetronome => 'Metronome…';

  @override
  String get scoreMenuPageTurnSettings => 'Cài đặt lật trang';

  @override
  String scoreMenuLayoutValueBoth(String stored, String resolved) {
    return '$stored · $resolved';
  }

  @override
  String get languageSheetTitle => 'Ngôn ngữ';

  @override
  String get languageSheetSystem => 'Hệ thống';

  @override
  String get languageSheetSystemSubtitle => 'Theo ngôn ngữ thiết bị';

  @override
  String get stampSheetTitle => 'Stamps';

  @override
  String get stampBox => 'Khung';

  @override
  String get stampCircle => 'Tròn';

  @override
  String get stampArrow => 'Mũi tên';

  @override
  String get stampText => 'Chữ';

  @override
  String get pageScaleSheetTitle => 'Tỉ lệ trang';

  @override
  String get pageScaleSheetExplainer =>
      'Kích thước bản nhạc được vẽ, được ghi nhớ qua các lần mở app. Chụm để phóng chỉ đổi cách xem tạm thời; thiết lập này đổi lâu dài.';

  @override
  String pageScaleSheetCurrent(String value) {
    return 'Trang này hiện đang: $value×';
  }

  @override
  String get pageScaleSheetAppliesTo => 'Áp dụng cho';

  @override
  String get pageScaleSheetScale => 'Tỉ lệ';

  @override
  String pageScaleSheetScaleValue(String value) {
    return '$value×';
  }

  @override
  String get pageScaleSheetKeepScale => 'Giữ tỉ lệ này';

  @override
  String get pageScaleSheetKeepScaleSubtitle =>
      'Đã tắt chụm để phóng, nên một cú chạm lỡ tay giữa bài không thể làm xê dịch bản nhạc';

  @override
  String get pageScaleSheetHintFixed =>
      'Mọi Score, trừ khi Score đó có tỉ lệ riêng';

  @override
  String get pageScaleSheetHintPerScore =>
      'Chỉ Score này, trên mọi trang của nó';

  @override
  String get pageScaleSheetHintPerPage =>
      'Chỉ trang này — một trang dày đặc nốt nhạc có thể phóng to hơn mà không ảnh hưởng các trang khác';

  @override
  String get layoutSettingsSheetTitle => 'Bố cục';

  @override
  String get layoutSettingsSheetPageTurnSettings => 'Cài đặt lật trang';

  @override
  String get layoutSettingsSheetPageTurnSettingsSubtitle =>
      'Vùng chạm, vuốt, pedal, hiệu ứng';

  @override
  String get layoutSettingsSheetFallsBack =>
      'Một trang trên màn hình này — xoay ngang để xem hai trang';

  @override
  String layoutSettingsSheetNow(String mode) {
    return 'Hiện tại: $mode';
  }

  @override
  String get layoutSettingsSheetFitsScreen => 'vừa màn hình này';

  @override
  String get pageTurnSettingsSheetGestureWarning =>
      'Giữ ít nhất một cử chỉ được đặt thành Hiện menu / giao diện.';

  @override
  String get pageTurnSettingsSheetTitle => 'Lật trang';

  @override
  String get pageTurnSettingsSheetTapZones => 'Vùng chạm';

  @override
  String pageTurnSettingsSheetTapZonesHint(
    String layoutMode,
    String navigationHint,
  ) {
    return 'Trong $layoutMode: $navigationHint.';
  }

  @override
  String get pageTurnSettingsSheetSwipe => 'Vuốt';

  @override
  String get pageTurnSettingsSheetMatchLayout => 'Theo bố cục';

  @override
  String get pageTurnSettingsSheetMatchLayoutSubtitle =>
      'Vuốt theo hướng trang di chuyển';

  @override
  String get pageTurnSettingsSheetSwipeLeftNext => 'Vuốt trái → trang sau';

  @override
  String get pageTurnSettingsSheetSwipeRightPrevious =>
      'Vuốt phải → trang trước';

  @override
  String get pageTurnSettingsSheetSwipeUpNext => 'Vuốt lên → trang sau';

  @override
  String get pageTurnSettingsSheetSwipeDownPrevious =>
      'Vuốt xuống → trang trước';

  @override
  String get pageTurnSettingsSheetReverseDirection => 'Đảo hướng lật trang';

  @override
  String get pageTurnSettingsSheetReverseDirectionSubtitle =>
      'Dành cho sách lật theo chiều ngược lại';

  @override
  String get pageTurnSettingsSheetTurnAmount => 'Mức lật';

  @override
  String get pageTurnSettingsSheetTurnAmountHintTwoPage =>
      'Nửa bước sẽ lật một trang trong cặp thay vì cả cặp.';

  @override
  String get pageTurnSettingsSheetTurnAmountHintDefault =>
      'Nửa bước sẽ lật khoảng ½ màn hình thay vì cả màn hình.';

  @override
  String get pageTurnSettingsSheetAnimation => 'Hiệu ứng';

  @override
  String get pageTurnSettingsSheetPageTurnDelay => 'Độ trễ lật trang';

  @override
  String get pageTurnSettingsSheetApplyTo => 'Áp dụng cho';

  @override
  String get pageTurnSettingsSheetGestures => 'Cử chỉ';

  @override
  String get pageTurnSettingsSheetGesturesHint =>
      'Chạm mép là các dải mỏng ở trên và dưới — khác với vùng lật trang Trên/dưới. Phải có ít nhất một cử chỉ là Hiện menu / giao diện; cử chỉ đó cũng gọi lại thanh công cụ trong chế độ biểu diễn. Vẽ chỉ vào được từ thanh công cụ, không bao giờ từ cử chỉ.';

  @override
  String get pageTurnSettingsSheetLongPress => 'Nhấn giữ';

  @override
  String get pageTurnSettingsSheetTopEdge => 'Mép trên';

  @override
  String get pageTurnSettingsSheetBottomEdge => 'Mép dưới';

  @override
  String get pageTurnSettingsSheetPedalKeyboard => 'Pedal / bàn phím';

  @override
  String get pageTurnSettingsSheetPedalKeyboardHint =>
      'Hỗ trợ pedal Bluetooth gửi phím bàn phím:\nTrang trước — PageUp, ←, ↑, Space\nTrang sau — PageDown, →, ↓, Enter';

  @override
  String get pageTurnAnimationOff => 'Tắt';

  @override
  String get pageTurnAnimationFast => 'Nhanh';

  @override
  String get pageTurnAnimationNormal => 'Bình thường';

  @override
  String get pageTurnAnimationSlow => 'Chậm';

  @override
  String get pageTurnDelayOff => 'Tắt';

  @override
  String get pageTurnDelay300ms => '0.3s';

  @override
  String get pageTurnDelay500ms => '0.5s';

  @override
  String get pageTurnDelay1000ms => '1.0s';

  @override
  String get pageTurnDelayScopeAll => 'Tất cả';

  @override
  String get pageTurnDelayScopePedalOnly => 'Chỉ Pedal & bàn phím';

  @override
  String get pageTurnTapModeMatchLayout => 'Theo bố cục';

  @override
  String get pageTurnTapModeLeftRight => 'Trái / phải';

  @override
  String get pageTurnTapModeTopBottom => 'Trên / dưới';

  @override
  String get pageTurnTapModePrevious => 'Bất kỳ đâu → trước';

  @override
  String get pageTurnTapModeNext => 'Bất kỳ đâu → sau';

  @override
  String get pageTurnTapModeDisabled => 'Tắt';

  @override
  String get turnAmountFull => 'Cả trang';

  @override
  String get turnAmountHalf => 'Nửa trang';

  @override
  String get gestureMapActionShowChrome => 'Hiện menu / giao diện';

  @override
  String get gestureMapActionDisabled => 'Tắt';

  @override
  String get drawToolbarColorLabel => 'Màu';

  @override
  String get drawToolbarSizeLabel => 'Kích thước';

  @override
  String get drawToolbarUndo => 'Hoàn tác';

  @override
  String get drawToolbarRedo => 'Làm lại';

  @override
  String get drawToolbarDelete => 'Xóa';

  @override
  String get drawToolbarStamp => 'Stamp';

  @override
  String get drawToolbarPlace => 'Đặt';

  @override
  String get drawToolbarMore => 'Xem thêm';

  @override
  String get drawToolbarTextStampTitle => 'Stamp chữ';

  @override
  String get drawToolbarTextStampHint => 'Nhãn ngắn gọn';

  @override
  String get drawToolbarDrawOptionsTitle => 'Tùy chọn vẽ';

  @override
  String get drawToolbarTool => 'Công cụ';

  @override
  String get drawToolbarWidth => 'Độ dày';

  @override
  String get drawToolbarStraightLine => 'Đường thẳng';

  @override
  String get drawToolPen => 'Bút';

  @override
  String get drawToolMarker => 'Bút dạ';

  @override
  String get drawToolEraser => 'Tẩy';

  @override
  String get drawToolEyedropper => 'Hút màu';

  @override
  String get drawWidthThin => 'Mảnh';

  @override
  String get drawWidthMedium => 'Vừa';

  @override
  String get drawWidthThick => 'Đậm';

  @override
  String get pdfModeScreenTapHint =>
      'Chạm nửa phải để sang trang sau, nửa trái để về trang trước.';

  @override
  String get pdfModeScreenColorFilterTitle => 'Bộ lọc màu';

  @override
  String get scoreMenuQuickBarBookmarks => 'Bookmarks';

  @override
  String get scoreMenuQuickBarDraw => 'Vẽ';

  @override
  String get scoreMenuQuickBarExitDraw => 'Thoát vẽ';

  @override
  String get scoreMenuQuickBarMetronome => 'Metronome';

  @override
  String get scoreMenuQuickBarMetronomeRunning => 'Metronome (đang chạy)';

  @override
  String get pdfModeScreenExporting => 'Đang xuất PDF…';

  @override
  String get pdfModeScreenExportReady => 'Đã xuất xong — đã mở bảng chia sẻ';

  @override
  String pdfModeScreenExportRestartHint(String path) {
    return 'Đã xuất tới $path. Khởi động lại toàn bộ app (stop + flutter run) để bật bảng chia sẻ.';
  }

  @override
  String pdfModeScreenExportFailed(String error) {
    return 'Xuất thất bại: $error';
  }

  @override
  String pdfModeScreenPieceIndex(int index) {
    return '$index.';
  }

  @override
  String get pdfModeScreenHidePieceNotes => 'Ẩn ghi chú bài';

  @override
  String get pdfModeScreenShowPieceNotes => 'Hiện ghi chú bài';

  @override
  String get pdfModeScreenPieceNotes => 'Ghi chú bài';

  @override
  String get libraryScreenSort => 'Sắp xếp';

  @override
  String get libraryScreenFilter => 'Lọc';

  @override
  String get libraryScreenManageLabels => 'Quản lý Labels';

  @override
  String get libraryScreenMore => 'Xem thêm';

  @override
  String get libraryScreenAppearance => 'Giao diện…';

  @override
  String get libraryScreenLanguage => 'Ngôn ngữ…';

  @override
  String get libraryScreenBackup => 'Sao lưu…';

  @override
  String get libraryScreenRestore => 'Khôi phục…';

  @override
  String libraryScreenAbout(String productName) {
    return 'Giới thiệu $productName…';
  }

  @override
  String libraryScreenSplitIntoPiecesSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'bài',
      one: 'bài',
    );
    return 'Đã tách thành $count $_temp0';
  }

  @override
  String get libraryScreenStillReadingPdf =>
      'Vẫn đang đọc PDF này — thử lại sau một lát.';

  @override
  String get libraryScreenEditPiecesAppBarTitle => 'Sửa các bài';

  @override
  String libraryScreenUpdatedPieces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'bài',
      one: 'bài',
    );
    return 'Đã cập nhật thành $count $_temp0.';
  }

  @override
  String get libraryScreenEditPiecesDialogTitle => 'Xóa dữ liệu bài?';

  @override
  String libraryScreenEditPiecesBody(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'chúng',
      one: 'nó',
    );
    return '$names sẽ bị xóa, cùng với chú thích, Bookmark, Jump Link, Label, và tư cách trong Setlist của $_temp0.';
  }

  @override
  String get libraryScreenSplitIntoPiecesDialogTitle => 'Tách thành các bài?';

  @override
  String libraryScreenSplitPageOrderBody(
    int dropping,
    String title,
    int firstPage,
    int lastPage,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      dropping,
      locale: localeName,
      other: 'trang',
      one: 'trang',
    );
    return 'Thu hẹp “$title” về trang $firstPage–$lastPage sẽ bỏ $dropping $_temp0 khỏi thứ tự trang của nó.';
  }

  @override
  String get libraryScreenSplitConfirm => 'Tách';

  @override
  String get libraryScreenChangePagesTitle => 'Đổi trang?';

  @override
  String libraryScreenChangePagesBody(
    int dropping,
    String title,
    int firstPage,
    int lastPage,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      dropping,
      locale: localeName,
      other: 'trang',
      one: 'trang',
    );
    return 'Đổi “$title” sang trang $firstPage–$lastPage sẽ bỏ $dropping $_temp0 khỏi thứ tự trang của nó.';
  }

  @override
  String get libraryScreenChangePagesConfirm => 'Đổi';

  @override
  String get libraryScreenSetlistEmptyAddScores =>
      'Thêm Score vào Setlist này trước đã.';

  @override
  String get libraryScreenNoScoresAvailable =>
      'Không tìm thấy Score nào trong Setlist này.';

  @override
  String libraryScreenSkippedMissingScores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Score',
      one: 'Score',
    );
    return 'Đã bỏ qua $count $_temp0 bị thiếu.';
  }

  @override
  String get libraryScreenNewSetlist => 'Setlist mới';

  @override
  String get libraryScreenDeleteSetlistTitle => 'Xóa Setlist?';

  @override
  String libraryScreenDeleteSetlistBody(String title) {
    return 'Xóa “$title”? Các Score trong đó không bị ảnh hưởng.';
  }

  @override
  String libraryScreenDeleteScoreBody(String title) {
    return 'Xóa “$title”? Không thể hoàn tác.';
  }

  @override
  String libraryScreenDeleteScoreWithPiecesBody(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'bài',
      one: 'bài',
    );
    return 'Xóa “$title” và $count $_temp0 trong đó? Không thể hoàn tác.';
  }

  @override
  String get libraryScreenDeleteScoreTitle => 'Xóa Score?';

  @override
  String get libraryScreenTabScores => 'Scores';

  @override
  String get libraryScreenTabSetlists => 'Setlists';

  @override
  String get libraryScreenSearchHint => 'Tìm Score';

  @override
  String get libraryScreenAddPdf => 'Thêm PDF';

  @override
  String libraryScreenSplitSuggestionWithPages(String name, int pages) {
    return '“$name” ($pages trang) có vẻ như gồm nhiều bài.';
  }

  @override
  String libraryScreenSplitSuggestionGeneric(String name) {
    return '“$name” có vẻ như gồm nhiều bài.';
  }

  @override
  String get libraryScreenNotNow => 'Để sau';

  @override
  String get libraryScreenSplitEllipsis => 'Tách…';

  @override
  String libraryScreenFailedToOpen(String error) {
    return 'Không thể mở thư viện: $error';
  }

  @override
  String get libraryScreenNoScoresYet => 'Chưa có Score nào';

  @override
  String get libraryScreenImportPdfHint => 'Nhập một file PDF để bắt đầu.';

  @override
  String get libraryScreenAddSampleScore => 'Thêm Score mẫu';

  @override
  String libraryScreenNoScoresMatchSearch(String query) {
    return 'Không có Score nào khớp với “$query”.';
  }

  @override
  String libraryScreenNoScoresMatchFilter(String filter) {
    return 'Không có Score nào khớp với $filter.';
  }

  @override
  String get libraryScreenClearSearch => 'Xóa tìm kiếm';

  @override
  String get libraryScreenClearFilter => 'Xóa bộ lọc';

  @override
  String libraryScreenRecencyWithPieces(String when, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'bài',
      one: 'bài',
    );
    return '$when · $count $_temp0';
  }

  @override
  String get libraryScreenPiecesEllipsis => 'Các bài…';

  @override
  String get libraryScreenEditPiecesMenuItem => 'Sửa các bài…';

  @override
  String get libraryScreenOpenFullScore => 'Mở Score đầy đủ';

  @override
  String get libraryScreenRenameEllipsis => 'Đổi tên…';

  @override
  String get libraryScreenLabelsEllipsis => 'Labels…';

  @override
  String get libraryScreenSplitIntoPiecesEllipsis => 'Tách thành các bài…';

  @override
  String get libraryScreenPagesEllipsis => 'Trang…';

  @override
  String get libraryScreenReplacePdfEllipsis => 'Thay PDF…';

  @override
  String get libraryScreenDeleteEllipsis => 'Xóa…';

  @override
  String libraryScreenAddedRelative(String when) {
    return 'Đã thêm $when';
  }

  @override
  String libraryScreenOpenedRelative(String when) {
    return 'Đã mở $when';
  }

  @override
  String libraryScreenRecencyWithPages(String when, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: 'trang',
      one: 'trang',
    );
    return '$when · $pages $_temp0';
  }

  @override
  String get libraryScreenNoSetlistsYet => 'Chưa có Setlist nào';

  @override
  String get libraryScreenSetlistsEmptyHint =>
      'Nhóm các Score lại để biểu diễn liên tục mà không cần mở lại từng bài.';

  @override
  String libraryScreenSetlistScoreCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Score',
      one: 'Score',
    );
    return '$count $_temp0';
  }

  @override
  String get libraryScreenSetlistCountEmpty => 'Trống';

  @override
  String libraryScreenSetlistScoreCountOpened(
    String scoreCount,
    String opened,
  ) {
    return '$scoreCount · $opened';
  }

  @override
  String get metronomeSheetTitle => 'Metronome';

  @override
  String get metronomeSheetTempo => 'Tempo';

  @override
  String get metronomeSheetMeter => 'Nhịp';

  @override
  String get metronomeSheetMeterHint =>
      'Cách các phách được nhóm trong mỗi ô nhịp';

  @override
  String get metronomeSheetEqual => 'Đều';

  @override
  String get metronomeSheetMute => 'Tắt tiếng';

  @override
  String get metronomeSheetShowBeats => 'Hiện phách';

  @override
  String get metronomeSheetShowBeatsHint =>
      'Nháy phách trên Score khi đang phát';

  @override
  String metronomeSheetVolume(int percent) {
    return 'Âm lượng: $percent%';
  }

  @override
  String get metronomeSheetStop => 'Dừng';

  @override
  String get metronomeSheetStart => 'Bắt đầu';

  @override
  String get metronomeSheetEnterNumber => 'Nhập một số';

  @override
  String get metronomeSheetTempoDialogTitle => 'Đặt Tempo';

  @override
  String get pageExtentScreenTitle => 'Trang';

  @override
  String pageExtentScreenFirstPage(int page) {
    return 'Trang đầu: $page';
  }

  @override
  String pageExtentScreenLastPage(int page) {
    return 'Trang cuối: $page';
  }

  @override
  String get pageExtentScreenNoPages => 'Không có trang nào';

  @override
  String get pageExtentScreenBadgeOnly => 'Duy nhất';

  @override
  String get pageExtentScreenBadgeFirst => 'Đầu';

  @override
  String get pageExtentScreenBadgeLast => 'Cuối';

  @override
  String pageExtentScreenSummary(String title, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: 'trang',
      one: 'trang',
    );
    return '$title — $pages $_temp0';
  }

  @override
  String get pageExtentScreenHint =>
      'Chạm vào một trang bên dưới để đặt ranh giới đang chọn.';

  @override
  String get pageNavBarPreviousPageTooltip => 'Trang trước';

  @override
  String get pageNavBarNextPageTooltip => 'Trang sau';

  @override
  String pageNavBarJumpedSnackbar(int page, int count) {
    return 'Đã nhảy tới trang $page/$count';
  }

  @override
  String get pageNavBarGoToPageTitle => 'Đi tới trang';

  @override
  String pageNavBarPageFieldLabel(int count) {
    return 'Trang (1–$count)';
  }

  @override
  String get piecesScreenEditPieces => 'Sửa các bài…';

  @override
  String get piecesScreenNoPieces => 'Chưa có bài nào';

  @override
  String get piecesScreenRename => 'Đổi tên…';

  @override
  String get piecesScreenLabels => 'Labels…';

  @override
  String get piecesScreenSplitIntoPieces => 'Tách thành các bài…';

  @override
  String get piecesScreenPages => 'Trang…';

  @override
  String get piecesScreenReplacePdf => 'Thay PDF…';

  @override
  String get piecesScreenDelete => 'Xóa…';

  @override
  String piecesScreenAdded(String when) {
    return 'Đã thêm $when';
  }

  @override
  String piecesScreenOpened(String when) {
    return 'Đã mở $when';
  }

  @override
  String piecesScreenRecencyWithPages(String when, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: 'trang',
      one: 'trang',
    );
    return '$when · $pages $_temp0';
  }

  @override
  String piecesScreenPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'bài',
      one: 'bài',
    );
    return '$count $_temp0';
  }

  @override
  String piecesScreenPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'trang',
      one: 'trang',
    );
    return '$count $_temp0';
  }

  @override
  String get piecesScreenOpenFullScore => 'Mở Score đầy đủ';

  @override
  String get setlistEditorImportFirst => 'Nhập một Score trước đã.';

  @override
  String get setlistEditorDefaultTitle => 'Setlist mới';

  @override
  String get setlistEditorAppBarTitle => 'Sửa Setlist';

  @override
  String get setlistEditorAddScores => 'Thêm Score';

  @override
  String get setlistEditorTitleFieldLabel => 'Tiêu đề';

  @override
  String get setlistEditorEmpty =>
      'Chưa có Score nào. Chạm Thêm Score để xây dựng Setlist.';

  @override
  String get setlistEditorMissingScore => 'Score bị thiếu';

  @override
  String get setlistEditorRemovedFromLibrary => 'Đã xóa khỏi thư viện';

  @override
  String get setlistEditorRemoveTooltip => 'Xóa';

  @override
  String setlistEditorAddCount(int count) {
    return 'Thêm ($count)';
  }

  @override
  String setlistEditorPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'bài',
      one: 'bài',
    );
    return '$count $_temp0';
  }

  @override
  String get setlistEditorPiecesTooltip => 'Xem các bài';

  @override
  String get splitScoreScreenRenameTitle => 'Đổi tên';

  @override
  String get splitScoreScreenTitle => 'Tách thành các bài';

  @override
  String get splitScoreScreenClearMarks => 'Xóa đánh dấu';

  @override
  String get splitScoreScreenNoPages => 'Không có trang nào';

  @override
  String splitScoreScreenPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bài',
      one: '1 bài',
      zero: 'Chưa có bài nào',
    );
    return '$_temp0';
  }

  @override
  String get splitScoreScreenHint =>
      'Chạm vào một trang để đánh dấu nơi một bài mới bắt đầu. Nhấn giữ một trang đã đánh dấu để đổi tên nó.';

  @override
  String splitScoreScreenFrontMatterPage(int page) {
    return 'Trang $page là phần mở đầu và sẽ không thuộc về bài nào.';
  }

  @override
  String splitScoreScreenFrontMatterPages(int first, int last) {
    return 'Trang $first–$last là phần mở đầu và sẽ không thuộc về bài nào.';
  }

  @override
  String splitScoreScreenUseContents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mục',
      one: 'mục',
    );
    return 'Dùng mục lục ($count $_temp0)';
  }

  @override
  String get libraryScreenNoPdfFiles => 'Không tìm thấy file PDF nào.';

  @override
  String libraryScreenImportedScores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Score',
      one: 'Score',
    );
    return 'Đã nhập $count $_temp0';
  }

  @override
  String get libraryScreenCreateBackupTitle => 'Tạo bản sao lưu?';

  @override
  String get libraryScreenCreateBackupBody =>
      'Thao tác này lưu một bản sao toàn bộ thư viện của bạn — Score, Label, Setlist và cài đặt — thành một file zip mà bạn có thể chia sẻ hoặc cất giữ ở nơi an toàn.';

  @override
  String get libraryScreenCreateBackupConfirm => 'Tạo bản sao lưu';

  @override
  String get libraryScreenCreatingBackup => 'Đang tạo bản sao lưu…';

  @override
  String get libraryScreenBackupShareSubject => 'Bản sao lưu StageScore';

  @override
  String libraryScreenBackupSaved(String path) {
    return 'Đã lưu bản sao lưu vào $path';
  }

  @override
  String get libraryScreenBackupReady =>
      'Bản sao lưu đã sẵn sàng — đã mở bảng chia sẻ';

  @override
  String libraryScreenBackupFailed(String error) {
    return 'Không thể tạo bản sao lưu: $error';
  }

  @override
  String get libraryScreenRestoreBackupTitle => 'Khôi phục bản sao lưu?';

  @override
  String get libraryScreenRestoreBackupBody =>
      'Thao tác này thay thế toàn bộ thư viện của bạn — Score, Label, Setlist và cài đặt — bằng nội dung của bản sao lưu. Không thể hoàn tác.';

  @override
  String get libraryScreenReplaceAll => 'Thay thế tất cả';

  @override
  String get libraryScreenRestoringBackup => 'Đang khôi phục bản sao lưu…';

  @override
  String get libraryScreenLibraryRestored => 'Đã khôi phục thư viện';

  @override
  String libraryScreenRestoreFailed(String error) {
    return 'Không thể khôi phục bản sao lưu: $error';
  }

  @override
  String libraryScreenPercentValue(int percent) {
    return '$percent%';
  }

  @override
  String get libraryScreenUntagged => 'Chưa gắn Label';

  @override
  String get libraryScreenThisFilter => 'bộ lọc này';

  @override
  String get libraryScreenAndConjunction => 'và';

  @override
  String get libraryScreenAllOf => 'Tất cả';

  @override
  String libraryScreenRemoveFilterChip(String label) {
    return 'Xóa bộ lọc $label';
  }

  @override
  String get libraryScreenRenameScoreTitle => 'Đổi tên Score';

  @override
  String get libraryScreenReplacePdfTitle => 'Thay PDF?';

  @override
  String libraryScreenReplacePdfBodyShared(
    int sharing,
    String title,
    int others,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: 'bài',
      one: 'bài',
    );
    return 'File PDF này được dùng chung bởi $sharing bài, gồm cả “$title”. Thay file này cũng sẽ đổi nó cho $others $_temp0 còn lại.';
  }

  @override
  String libraryScreenReplacePdfBodySingle(String title) {
    return 'Thay file PDF đứng sau “$title”? Bạn có thể giữ hoặc đặt lại chú thích của nó bên dưới.';
  }

  @override
  String get libraryScreenKeepOverlays => 'Giữ chú thích';

  @override
  String get libraryScreenResetOverlays => 'Đặt lại chú thích';

  @override
  String get libraryScreenOverlaysReset => 'Đã đặt lại chú thích.';

  @override
  String get libraryScreenOverlaysKept => 'Đã giữ chú thích.';

  @override
  String libraryScreenPdfReplaced(String overlayNote) {
    return 'Đã thay PDF. $overlayNote';
  }

  @override
  String libraryScreenPdfReplacedShortened(String overlayNote, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mục trang',
      one: 'mục trang',
    );
    return 'Đã thay PDF. $overlayNote File mới ngắn hơn, nên $count $_temp0 đã bị bỏ.';
  }

  @override
  String libraryScreenReplaceFailed(String error) {
    return 'Không thể thay PDF: $error';
  }

  @override
  String continuousPageOrderViewOpenFailed(String error) {
    return 'Không thể mở PDF: $error';
  }

  @override
  String get performancePageSlotBlank => 'Trống';

  @override
  String performancePageSlotMissingPage(int page) {
    return 'Thiếu trang $page';
  }

  @override
  String singlePageSliderOpenFailed(String error) {
    return 'Không thể mở PDF: $error';
  }

  @override
  String aboutSheetVersion(String version) {
    return 'Phiên bản $version';
  }

  @override
  String aboutSheetVersionWithBuild(String version, String build) {
    return 'Phiên bản $version ($build)';
  }

  @override
  String aboutSheetLinkOpenFailed(String url) {
    return 'Không thể mở liên kết: $url';
  }

  @override
  String aboutSheetTitle(String productName) {
    return 'Giới thiệu $productName';
  }

  @override
  String get aboutSheetWebsiteLabel => 'Trang web';

  @override
  String get aboutSheetPrivacyLabel => 'Quyền riêng tư';

  @override
  String get aboutSheetSupportLabel => 'Hỗ trợ';

  @override
  String get bookmarksSheetAddTitle => 'Thêm Bookmark';

  @override
  String bookmarksSheetPageLabel(int page) {
    return 'Trang $page';
  }

  @override
  String get bookmarksSheetRenameTitle => 'Đổi tên Bookmark';

  @override
  String get bookmarksSheetTitle => 'Bookmarks';

  @override
  String get bookmarksSheetEmpty => 'Chưa có Bookmark nào';

  @override
  String get displaySheetBorderColorTitle => 'Màu viền';

  @override
  String displaySheetHue(int value) {
    return 'Màu: $value';
  }

  @override
  String displaySheetSaturation(int value) {
    return 'Độ bão hòa: $value';
  }

  @override
  String displaySheetColorValue(int value) {
    return 'Độ sáng: $value';
  }

  @override
  String get displaySheetTitle => 'Hiển thị';

  @override
  String get displaySheetPerformanceMode => 'Chế độ biểu diễn';

  @override
  String get displaySheetPageBorder => 'Viền trang';

  @override
  String displaySheetThickness(String value) {
    return 'Độ dày: $value';
  }

  @override
  String get displaySheetColorLabel => 'Màu';

  @override
  String get displaySheetCustomChip => 'Tùy chỉnh';

  @override
  String get displaySheetShowStatusBar => 'Hiện thanh trạng thái';

  @override
  String get displaySheetShowStatusBarHint =>
      'Giữ đồng hồ và pin hiển thị khi bạn chơi';

  @override
  String get displaySheetAvoidNotches => 'Tránh notch';

  @override
  String get displaySheetAvoidNotchesHint =>
      'Giữ trang tránh xa notch camera và các góc bo tròn';

  @override
  String get jumpLinkEditSheetAddTitle => 'Thêm Jump Link';

  @override
  String get jumpLinkEditSheetEditTitle => 'Sửa Jump Link';

  @override
  String jumpLinkEditSheetOriginLabel(int page) {
    return 'Từ trang $page';
  }

  @override
  String jumpLinkEditSheetDestinationLabel(int page, int pageCount) {
    return 'Đến trang $page/$pageCount';
  }

  @override
  String get jumpLinkEditSheetColorLabel => 'Màu';

  @override
  String get jumpLinkEditSheetSizeLabel => 'Kích thước';

  @override
  String get jumpLinksSheetDragHint =>
      'Đã thêm. Kéo một Jump Link trong danh sách để sắp xếp lại.';

  @override
  String get jumpLinksSheetTitle => 'Jump Links';

  @override
  String get jumpLinksSheetEmpty => 'Chưa có Jump Link nào';

  @override
  String jumpLinksSheetRowTitle(int from, int to) {
    return 'Trang $from → $to';
  }

  @override
  String get jumpLinksSheetRowSubtitle => 'Chạm để nhảy tới link này';

  @override
  String labelSheetsTitle(String title) {
    return 'Labels cho $title';
  }

  @override
  String get labelSheetsManage => 'Quản lý';

  @override
  String get labelSheetsCreateLabel => 'Tạo Label';

  @override
  String get labelSheetsNewLabel => 'Label mới';

  @override
  String get labelSheetsManageTitle => 'Quản lý Labels';

  @override
  String get labelSheetsNoLabelsYet => 'Chưa có Label nào';

  @override
  String labelSheetsUsageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Score',
      one: 'Score',
    );
    return 'Được dùng bởi $count $_temp0';
  }

  @override
  String get labelSheetsDeleteTitle => 'Xóa Label?';

  @override
  String labelSheetsDeleteConfirm(String name) {
    return 'Xóa “$name”?';
  }

  @override
  String labelSheetsDeleteConfirmWithUsage(String name, int usage) {
    String _temp0 = intl.Intl.pluralLogic(
      usage,
      locale: localeName,
      other: 'Score',
      one: 'Score',
    );
    return '“$name” đang được dùng bởi $usage $_temp0. Vẫn muốn xóa?';
  }

  @override
  String get labelSheetsRenameLabelTitle => 'Đổi tên Label';

  @override
  String get labelSheetsNameHint => 'Tên Label';

  @override
  String get libraryFilterSheetTitle => 'Lọc';

  @override
  String get libraryFilterSheetModeAny => 'Bất kỳ';

  @override
  String get libraryFilterSheetModeAll => 'Tất cả';

  @override
  String get libraryFilterSheetModeUntagged => 'Chưa gắn Label';

  @override
  String get libraryFilterSheetUntaggedHint => 'Score chưa gắn Label nào';

  @override
  String get libraryFilterSheetEmptyLabels => 'Chưa có Label nào để lọc';

  @override
  String get measureMapMeasureCountTitle => 'Bao nhiêu MeasureBoxes?';

  @override
  String get measureMapMeasureCountLabel => 'MeasureBoxes';

  @override
  String get measureMapGoToTitle => 'Tới ô nhịp';

  @override
  String get measureMapGoToLabel => 'Số ô nhịp';

  @override
  String measureMapGoToMissing(int number) {
    return 'Ô nhịp $number chưa được map';
  }

  @override
  String get measureMapMetaTitle => 'Tempo & time signature';

  @override
  String get measureMapTimeSignatureLabel => 'Time signature';

  @override
  String get measureMapTempoLabel => 'Tempo';

  @override
  String get measureMapMetaScopeTitle => 'Áp dụng cho';

  @override
  String get measureMapScopeThisMeasure => 'Chỉ ô này';

  @override
  String get measureMapScopeThisSystem => 'System này';

  @override
  String get measureMapScopeThisPage => 'Trang này';

  @override
  String get measureMapScopeRestOfScore => 'Phần còn lại của Score';

  @override
  String get measureMapScopeNextN => 'Next N…';

  @override
  String get measureMapMetaNextNLabel => 'Số ô nhịp';

  @override
  String get measureMapClearTitle => 'Xoá MeasureMap?';

  @override
  String get measureMapClearBody =>
      'Xoá mọi SystemBox và MeasureBox của Score này. Không hoàn tác được.';

  @override
  String get measureMapClearConfirm => 'Xoá';

  @override
  String get measureMapDeleteSystemTitle => 'Xoá system?';

  @override
  String get measureMapDeleteSystemBody =>
      'Xoá SystemBox này và mọi MeasureBox trong đó.';

  @override
  String get measureMapCopyFromPageTitle => 'Chép layout từ trang';

  @override
  String get measureMapCopyFromPageLabel => 'Trang nguồn';

  @override
  String get measureMapCopyPrevious => 'Chép trang trước';

  @override
  String get measureMapEmptyHint => 'Vẽ một dòng nhạc — app sẽ hỏi bao nhiêu ô';

  @override
  String get measureMapDone => 'Xong';

  @override
  String get measureMapEditBeats => 'Edit beats';

  @override
  String get measureMapSetMeasureCount => 'Đặt số ô…';

  @override
  String get measureMapDeleteSystem => 'Xoá system';

  @override
  String get measureMapDeleteMeasure => 'Xoá ô nhịp';

  @override
  String get measureMapEditMeta => 'Tempo & time signature…';

  @override
  String get measureMapClearAll => 'Xoá MeasureMap…';
}
