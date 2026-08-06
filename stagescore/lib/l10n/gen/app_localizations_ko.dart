// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get actionCancel => '취소';

  @override
  String get actionSave => '저장';

  @override
  String get actionDone => '완료';

  @override
  String get actionDelete => '삭제';

  @override
  String get actionOk => '확인';

  @override
  String get actionClear => '지우기';

  @override
  String get actionApply => '적용';

  @override
  String get actionAdd => '추가';

  @override
  String get actionEdit => '편집';

  @override
  String get actionRename => '이름 변경';

  @override
  String get actionBack => '뒤로';

  @override
  String get actionMore => '더보기';

  @override
  String get actionGo => '이동';

  @override
  String get actionUndo => '실행 취소';

  @override
  String get actionContinue => '계속';

  @override
  String get actionReset => '초기화';

  @override
  String get commonOr => '또는';

  @override
  String get commonTitleLabel => '제목';

  @override
  String get themeModeSystem => '시스템';

  @override
  String get themeModeLight => '라이트';

  @override
  String get themeModeDark => '다크';

  @override
  String get pdfLayoutModeAuto => '자동';

  @override
  String get pdfLayoutModeSingle => '한 페이지';

  @override
  String get pdfLayoutModeTwoPages => '두 페이지';

  @override
  String get pdfLayoutModeScroll => '스크롤';

  @override
  String get pdfLayoutModeScrollSideways => '스크롤 (가로)';

  @override
  String get pdfLayoutModeHalfPageTopBottom => '한 페이지 + 살짝 보기';

  @override
  String get pdfLayoutModeHalfPageLeftRight => '한 페이지 + 옆으로 살짝 보기';

  @override
  String get pageColorFilterOff => '끄기';

  @override
  String get pageColorFilterSepia => '세피아';

  @override
  String get pageColorFilterGreen => '그린';

  @override
  String get pageColorFilterInvert => '반전';

  @override
  String get pageScaleScopeFixed => '고정';

  @override
  String get pageScaleScopePerScore => '악보별';

  @override
  String get pageScaleScopePerPage => '페이지별';

  @override
  String get stagePresetSetUpToPlay => '연주 준비';

  @override
  String get stagePresetSetUpToPractise => '연습 준비';

  @override
  String get stagePresetChromeHidden => '도구 모음 숨김';

  @override
  String get stagePresetChromeShown => '도구 모음 표시';

  @override
  String get stagePresetStatusBarShown => '상태 표시줄 표시';

  @override
  String get stagePresetStatusBarHidden => '상태 표시줄 숨김';

  @override
  String get stagePresetScaleKept => '배율 고정';

  @override
  String get stagePresetPinchFree => '핀치 가능';

  @override
  String get relativeDayToday => '오늘';

  @override
  String get relativeDayYesterday => '어제';

  @override
  String relativeDayDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '일 전',
      one: '일 전',
    );
    return '$days$_temp0';
  }

  @override
  String pageOrderEditorEntryBlank(int index) {
    return '$index. 빈 페이지';
  }

  @override
  String pageOrderEditorEntryPdfPage(int index, int sourcePage) {
    return '$index. PDF $sourcePage페이지';
  }

  @override
  String get pageOrderEditorResetTitle => '원래대로 되돌릴까요?';

  @override
  String get pageOrderEditorResetBody =>
      'PDF 페이지 순서를 복원하고 빈 페이지와 중복 페이지를 제거할까요?';

  @override
  String get pageOrderEditorReset => '초기화';

  @override
  String get pageOrderEditorAppBarTitle => '페이지 순서';

  @override
  String get pageOrderEditorNoPages => '페이지 없음';

  @override
  String get pageOrderEditorDuplicate => '복제';

  @override
  String get pageOrderEditorInsertBlank => '빈 페이지 삽입';

  @override
  String get pageOrderEditorRemove => '제거';

  @override
  String get librarySortTitle => '제목';

  @override
  String get librarySortCreated => '생성일';

  @override
  String get librarySortLastViewed => '최근 열람';

  @override
  String scoreOriginPage(int page) {
    return '$page페이지';
  }

  @override
  String scoreOriginPages(int first, int last) {
    return '$first–$last페이지';
  }

  @override
  String scoreOriginPagesOfBook(String pages, String name) {
    return '$name의 $pages';
  }

  @override
  String libraryVisibilityInBook(String title) {
    return '$title 안에';
  }

  @override
  String get libraryVisibilityInBookFallback => '책 안에';

  @override
  String get libraryBackupFileNotFound => '백업 파일을 찾을 수 없어요.';

  @override
  String get libraryBackupFailedGeneric => '백업에 실패했어요.';

  @override
  String libraryBackupCreateFailed(String error) {
    return '백업을 만들지 못했어요: $error';
  }

  @override
  String libraryBackupRestoreFailed(String error) {
    return '백업을 복원하지 못했어요: $error';
  }

  @override
  String get libraryBackupMissingMarker => 'StageScore 백업 파일이 아니에요 (마커 없음).';

  @override
  String get libraryBackupUnknownFormat =>
      'StageScore 백업 파일이 아니에요 (알 수 없는 형식).';

  @override
  String get libraryBackupUnsupportedVersion => '지원하지 않는 StageScore 백업 버전이에요.';

  @override
  String get libraryBackupCorruptMarker => 'StageScore 백업 파일이 아니에요 (손상된 마커).';

  @override
  String get gestureMapLongPress => '길게 누르기';

  @override
  String get gestureMapTapTopEdge => '위쪽 가장자리 탭하기';

  @override
  String get gestureMapTapBottomEdge => '아래쪽 가장자리 탭하기';

  @override
  String get gestureMapEmptyHint =>
      '제스처를 \'메뉴 / 도구 모음 표시\'로 설정하면 다시 불러올 수 있어요.';

  @override
  String gestureMapRevealHint(String joined) {
    return '연주하는 동안 도구 모음과 페이지 바를 숨겨요. 다시 표시하려면 $joined.';
  }

  @override
  String get layoutNavigationPedalOrPageBar => '페달 또는 페이지 바';

  @override
  String get layoutNavigationTapLeftRight => '왼쪽 / 오른쪽 탭';

  @override
  String get layoutNavigationTapTopBottom => '위 / 아래 탭';

  @override
  String get layoutNavigationTapAnywhere => '아무 곳이나 탭';

  @override
  String get layoutNavigationTapAnywhereBack => '아무 곳이나 탭하여 뒤로 가기';

  @override
  String get layoutNavigationSwipe => '스와이프';

  @override
  String get layoutNavigationSwipeSideways => '옆으로 스와이프';

  @override
  String get layoutNavigationSwipeUpDown => '위 / 아래로 스와이프';

  @override
  String get scoreMenuSheetTitle => '메뉴';

  @override
  String get appearanceSheetTitle => '테마';

  @override
  String get appearanceSheetMode => '모드';

  @override
  String get appearanceSheetThemeColor => '테마 색상';

  @override
  String get appearanceSheetCustomChip => '사용자 지정';

  @override
  String get appearanceSheetCustomColorDialog => '사용자 지정 색상';

  @override
  String get appearanceSheetHue => '색상';

  @override
  String get appearanceSheetSat => '채도';

  @override
  String get appearanceSheetVal => '명도';

  @override
  String get scoreMenuGoTo => '이동';

  @override
  String get scoreMenuBookmarks => '북마크';

  @override
  String get scoreMenuJumpLinks => '점프 링크';

  @override
  String get scoreMenuPageOrder => '페이지 순서…';

  @override
  String get scoreMenuGoToMeasure => '마디로 이동…';

  @override
  String get scoreMenuMeasureMap => 'Measure map…';

  @override
  String get scoreMenuMarks => '마크';

  @override
  String get scoreMenuHideAnnotations => '주석 숨기기';

  @override
  String get scoreMenuShowAnnotations => '주석 표시';

  @override
  String get scoreMenuExporting => '내보내는 중…';

  @override
  String get scoreMenuExportAnnotated => '주석 포함 PDF 내보내기';

  @override
  String get scoreMenuView => '보기';

  @override
  String get scoreMenuLayout => '레이아웃';

  @override
  String get scoreMenuDisplay => '화면…';

  @override
  String get scoreMenuColorFilter => '색상 필터…';

  @override
  String get scoreMenuPageScale => '페이지 배율…';

  @override
  String get scoreMenuLocked => '잠김';

  @override
  String get scoreMenuPlaying => '재생 중';

  @override
  String get scoreMenuMetronomeRunning => '메트로놈 (작동 중)…';

  @override
  String get scoreMenuMetronome => '메트로놈…';

  @override
  String get scoreMenuPageTurnSettings => '페이지 넘김 설정';

  @override
  String scoreMenuLayoutValueBoth(String stored, String resolved) {
    return '$stored · $resolved';
  }

  @override
  String get languageSheetTitle => '언어';

  @override
  String get languageSheetSystem => '시스템';

  @override
  String get languageSheetSystemSubtitle => '기기 언어와 동일하게 설정';

  @override
  String get stampSheetTitle => '스탬프';

  @override
  String get stampBox => '사각형';

  @override
  String get stampCircle => '원';

  @override
  String get stampArrow => '화살표';

  @override
  String get stampText => '텍스트';

  @override
  String get pageScaleSheetTitle => '페이지 배율';

  @override
  String get pageScaleSheetExplainer =>
      '악보가 얼마나 크게 표시되는지를 정하며, 앱을 다시 열어도 유지돼요. 핀치 확대/축소는 지금 화면만 바꾸지만, 이 설정은 계속 적용돼요.';

  @override
  String pageScaleSheetCurrent(String value) {
    return '현재 이 페이지: $value×';
  }

  @override
  String get pageScaleSheetAppliesTo => '적용 대상';

  @override
  String get pageScaleSheetScale => '배율';

  @override
  String pageScaleSheetScaleValue(String value) {
    return '$value×';
  }

  @override
  String get pageScaleSheetKeepScale => '이 배율 유지';

  @override
  String get pageScaleSheetKeepScaleSubtitle =>
      '핀치가 꺼져 있어 연주 중 실수로 화면을 건드려도 악보가 움직이지 않아요';

  @override
  String get pageScaleSheetHintFixed => '다른 배율이 지정되지 않은 모든 악보에 적용돼요';

  @override
  String get pageScaleSheetHintPerScore => '이 악보에만, 모든 페이지에 적용돼요';

  @override
  String get pageScaleSheetHintPerPage =>
      '이 페이지에만 적용돼요 — 빽빽한 페이지만 다른 페이지를 바꾸지 않고 크게 볼 수 있어요';

  @override
  String get layoutSettingsSheetTitle => '레이아웃';

  @override
  String get layoutSettingsSheetPageTurnSettings => '페이지 넘김 설정';

  @override
  String get layoutSettingsSheetPageTurnSettingsSubtitle =>
      '탭 영역, 스와이프, 페달, 애니메이션';

  @override
  String get layoutSettingsSheetFallsBack =>
      '이 화면에서는 한 페이지만 표시돼요 — 화면을 돌리면 두 페이지가 보여요';

  @override
  String layoutSettingsSheetNow(String mode) {
    return '현재: $mode';
  }

  @override
  String get layoutSettingsSheetFitsScreen => '이 화면에 맞음';

  @override
  String get pageTurnSettingsSheetGestureWarning =>
      '적어도 하나의 제스처는 \'메뉴 / 도구 모음 표시\'로 설정해야 해요.';

  @override
  String get pageTurnSettingsSheetTitle => '페이지 넘김';

  @override
  String get pageTurnSettingsSheetTapZones => '탭 영역';

  @override
  String pageTurnSettingsSheetTapZonesHint(
    String layoutMode,
    String navigationHint,
  ) {
    return '$layoutMode에서는 $navigationHint.';
  }

  @override
  String get pageTurnSettingsSheetSwipe => '스와이프';

  @override
  String get pageTurnSettingsSheetMatchLayout => '레이아웃에 맞추기';

  @override
  String get pageTurnSettingsSheetMatchLayoutSubtitle =>
      '페이지가 넘어가는 방향으로 스와이프해요';

  @override
  String get pageTurnSettingsSheetSwipeLeftNext => '왼쪽으로 스와이프 → 다음';

  @override
  String get pageTurnSettingsSheetSwipeRightPrevious => '오른쪽으로 스와이프 → 이전';

  @override
  String get pageTurnSettingsSheetSwipeUpNext => '위로 스와이프 → 다음';

  @override
  String get pageTurnSettingsSheetSwipeDownPrevious => '아래로 스와이프 → 이전';

  @override
  String get pageTurnSettingsSheetReverseDirection => '페이지 넘김 방향 반대로';

  @override
  String get pageTurnSettingsSheetReverseDirectionSubtitle =>
      '반대 방향으로 넘기는 책에 맞게';

  @override
  String get pageTurnSettingsSheetTurnAmount => '넘김 양';

  @override
  String get pageTurnSettingsSheetTurnAmountHintTwoPage =>
      '절반으로 설정하면 두 페이지 전체가 아니라 한 페이지씩 넘어가요.';

  @override
  String get pageTurnSettingsSheetTurnAmountHintDefault =>
      '절반으로 설정하면 화면 전체가 아니라 약 절반만 넘어가요.';

  @override
  String get pageTurnSettingsSheetAnimation => '애니메이션';

  @override
  String get pageTurnSettingsSheetPageTurnDelay => '페이지 넘김 지연';

  @override
  String get pageTurnSettingsSheetApplyTo => '적용 대상';

  @override
  String get pageTurnSettingsSheetGestures => '제스처';

  @override
  String get pageTurnSettingsSheetGesturesHint =>
      '가장자리 탭은 위/아래에 있는 얇은 영역으로, 위/아래 페이지 넘김 영역과는 달라요. 적어도 하나는 반드시 \'메뉴 / 도구 모음 표시\'로 설정해야 하며, 이 제스처는 연주 모드에서 도구 모음을 다시 표시하는 역할도 해요. 그리기는 항상 도구 모음에서 시작하며, 제스처로는 들어갈 수 없어요.';

  @override
  String get pageTurnSettingsSheetLongPress => '길게 누르기';

  @override
  String get pageTurnSettingsSheetTopEdge => '위쪽 가장자리';

  @override
  String get pageTurnSettingsSheetBottomEdge => '아래쪽 가장자리';

  @override
  String get pageTurnSettingsSheetPedalKeyboard => '페달 / 키보드';

  @override
  String get pageTurnSettingsSheetPedalKeyboardHint =>
      '키보드 입력을 보내는 블루투스 페달을 지원해요:\n이전 — PageUp, ←, ↑, Space\n다음 — PageDown, →, ↓, Enter';

  @override
  String get pageTurnAnimationOff => '끄기';

  @override
  String get pageTurnAnimationFast => '빠르게';

  @override
  String get pageTurnAnimationNormal => '보통';

  @override
  String get pageTurnAnimationSlow => '느리게';

  @override
  String get pageTurnDelayOff => '끄기';

  @override
  String get pageTurnDelay300ms => '0.3초';

  @override
  String get pageTurnDelay500ms => '0.5초';

  @override
  String get pageTurnDelay1000ms => '1.0초';

  @override
  String get pageTurnDelayScopeAll => '전체';

  @override
  String get pageTurnDelayScopePedalOnly => '페달 및 키보드만';

  @override
  String get pageTurnTapModeMatchLayout => '레이아웃에 맞추기';

  @override
  String get pageTurnTapModeLeftRight => '왼쪽 / 오른쪽';

  @override
  String get pageTurnTapModeTopBottom => '위 / 아래';

  @override
  String get pageTurnTapModePrevious => '아무 곳 → 이전';

  @override
  String get pageTurnTapModeNext => '아무 곳 → 다음';

  @override
  String get pageTurnTapModeDisabled => '사용 안 함';

  @override
  String get turnAmountFull => '전체 페이지';

  @override
  String get turnAmountHalf => '절반 페이지';

  @override
  String get gestureMapActionShowChrome => '메뉴 / 도구 모음 표시';

  @override
  String get gestureMapActionDisabled => '끄기';

  @override
  String get drawToolbarColorLabel => '색상';

  @override
  String get drawToolbarSizeLabel => '크기';

  @override
  String get drawToolbarUndo => '실행 취소';

  @override
  String get drawToolbarRedo => '다시 실행';

  @override
  String get drawToolbarDelete => '삭제';

  @override
  String get drawToolbarStamp => '스탬프';

  @override
  String get drawToolbarPlace => '배치';

  @override
  String get drawToolbarMore => '더보기';

  @override
  String get drawToolbarTextStampTitle => '텍스트 스탬프';

  @override
  String get drawToolbarTextStampHint => '짧은 문구';

  @override
  String get drawToolbarDrawOptionsTitle => '그리기 옵션';

  @override
  String get drawToolbarTool => '도구';

  @override
  String get drawToolbarWidth => '굵기';

  @override
  String get drawToolbarStraightLine => '직선';

  @override
  String get drawToolPen => '펜';

  @override
  String get drawToolMarker => '마커';

  @override
  String get drawToolEraser => '지우개';

  @override
  String get drawToolEyedropper => '스포이트';

  @override
  String get drawWidthThin => '얇게';

  @override
  String get drawWidthMedium => '보통';

  @override
  String get drawWidthThick => '굵게';

  @override
  String get pdfModeScreenTapHint => '오른쪽을 탭하면 다음 페이지, 왼쪽을 탭하면 이전 페이지로 이동해요.';

  @override
  String get pdfModeScreenColorFilterTitle => '색상 필터';

  @override
  String get scoreMenuQuickBarBookmarks => '북마크';

  @override
  String get scoreMenuQuickBarDraw => '그리기';

  @override
  String get scoreMenuQuickBarExitDraw => '그리기 종료';

  @override
  String get scoreMenuQuickBarMetronome => '메트로놈';

  @override
  String get scoreMenuQuickBarMetronomeRunning => '메트로놈 (작동 중)';

  @override
  String get pdfModeScreenExporting => 'PDF 내보내는 중…';

  @override
  String get pdfModeScreenExportReady => '내보내기 완료 — 공유 시트가 열렸어요';

  @override
  String pdfModeScreenExportRestartHint(String path) {
    return '$path에 내보냈어요. 공유 시트를 사용하려면 앱을 완전히 재시작하세요 (stop + flutter run).';
  }

  @override
  String pdfModeScreenExportFailed(String error) {
    return '내보내기에 실패했어요: $error';
  }

  @override
  String pdfModeScreenPieceIndex(int index) {
    return '$index.';
  }

  @override
  String get pdfModeScreenHidePieceNotes => '곡 메모 숨기기';

  @override
  String get pdfModeScreenShowPieceNotes => '곡 메모 표시';

  @override
  String get pdfModeScreenPieceNotes => '곡 메모';

  @override
  String get libraryScreenSort => '정렬';

  @override
  String get libraryScreenFilter => '필터';

  @override
  String get libraryScreenManageLabels => '라벨 관리';

  @override
  String get libraryScreenMore => '더보기';

  @override
  String get libraryScreenAppearance => '테마…';

  @override
  String get libraryScreenLanguage => '언어…';

  @override
  String get libraryScreenBackup => '백업…';

  @override
  String get libraryScreenRestore => '복원…';

  @override
  String libraryScreenAbout(String productName) {
    return '$productName 정보…';
  }

  @override
  String libraryScreenSplitIntoPiecesSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '곡으로 나눴어요',
      one: '곡으로 나눴어요',
    );
    return '$count$_temp0';
  }

  @override
  String get libraryScreenStillReadingPdf =>
      '아직 이 PDF를 읽는 중이에요 — 잠시 후 다시 시도해 주세요.';

  @override
  String get libraryScreenEditPiecesAppBarTitle => '곡 편집';

  @override
  String libraryScreenUpdatedPieces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '곡으로 업데이트했어요.',
      one: '곡으로 업데이트했어요.',
    );
    return '$count$_temp0';
  }

  @override
  String get libraryScreenEditPiecesDialogTitle => '곡 데이터를 삭제할까요?';

  @override
  String libraryScreenEditPiecesBody(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '해당',
      one: '해당',
    );
    return '$names을(를) 삭제하면 $_temp0 주석, 북마크, 점프 링크, 라벨, 세트리스트 소속 정보도 함께 삭제돼요.';
  }

  @override
  String get libraryScreenSplitIntoPiecesDialogTitle => '곡으로 나눌까요?';

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
      other: '페이지가',
      one: '페이지가',
    );
    return '“$title”의 범위를 $firstPage–$lastPage페이지로 좁히면 페이지 순서에서 $dropping$_temp0 빠져요.';
  }

  @override
  String get libraryScreenSplitConfirm => '나누기';

  @override
  String get libraryScreenChangePagesTitle => '페이지를 변경할까요?';

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
      other: '페이지가',
      one: '페이지가',
    );
    return '“$title”의 페이지를 $firstPage–$lastPage페이지로 바꾸면 페이지 순서에서 $dropping$_temp0 빠져요.';
  }

  @override
  String get libraryScreenChangePagesConfirm => '변경';

  @override
  String get libraryScreenSetlistEmptyAddScores => '먼저 이 세트리스트에 악보를 추가하세요.';

  @override
  String get libraryScreenNoScoresAvailable => '이 세트리스트에 있는 악보를 찾을 수 없어요.';

  @override
  String libraryScreenSkippedMissingScores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '개 악보를 건너뛰었어요.',
      one: '개 악보를 건너뛰었어요.',
    );
    return '찾을 수 없는 $count$_temp0';
  }

  @override
  String get libraryScreenNewSetlist => '새 세트리스트';

  @override
  String get libraryScreenDeleteSetlistTitle => '세트리스트를 삭제할까요?';

  @override
  String libraryScreenDeleteSetlistBody(String title) {
    return '“$title”을(를) 삭제할까요? 안에 있는 악보는 영향을 받지 않아요.';
  }

  @override
  String libraryScreenDeleteScoreBody(String title) {
    return '“$title”을(를) 삭제할까요? 되돌릴 수 없어요.';
  }

  @override
  String libraryScreenDeleteScoreWithPiecesBody(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '개 곡을',
      one: '개 곡을',
    );
    return '“$title”과(와) 그 안의 $count$_temp0 모두 삭제할까요? 되돌릴 수 없어요.';
  }

  @override
  String get libraryScreenDeleteScoreTitle => '악보를 삭제할까요?';

  @override
  String get libraryScreenTabScores => '악보';

  @override
  String get libraryScreenTabSetlists => '세트리스트';

  @override
  String get libraryScreenSearchHint => '악보 검색';

  @override
  String get libraryScreenAddPdf => 'PDF 추가';

  @override
  String libraryScreenSplitSuggestionWithPages(String name, int pages) {
    return '“$name”($pages페이지)은(는) 여러 곡으로 나뉠 수 있어 보여요.';
  }

  @override
  String libraryScreenSplitSuggestionGeneric(String name) {
    return '“$name”은(는) 여러 곡으로 나뉠 수 있어 보여요.';
  }

  @override
  String get libraryScreenNotNow => '나중에';

  @override
  String get libraryScreenSplitEllipsis => '나누기…';

  @override
  String libraryScreenFailedToOpen(String error) {
    return '라이브러리를 열지 못했어요: $error';
  }

  @override
  String get libraryScreenNoScoresYet => '아직 악보가 없어요';

  @override
  String get libraryScreenImportPdfHint => 'PDF를 가져와서 시작하세요.';

  @override
  String get libraryScreenAddSampleScore => '샘플 악보 추가';

  @override
  String libraryScreenNoScoresMatchSearch(String query) {
    return '“$query”와(과) 일치하는 악보가 없어요.';
  }

  @override
  String libraryScreenNoScoresMatchFilter(String filter) {
    return '$filter와(과) 일치하는 악보가 없어요.';
  }

  @override
  String get libraryScreenClearSearch => '검색어 지우기';

  @override
  String get libraryScreenClearFilter => '필터 지우기';

  @override
  String libraryScreenRecencyWithPieces(String when, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '곡',
      one: '곡',
    );
    return '$when · $count$_temp0';
  }

  @override
  String get libraryScreenPiecesEllipsis => '곡…';

  @override
  String get libraryScreenEditPiecesMenuItem => '곡 편집…';

  @override
  String get libraryScreenOpenFullScore => '전체 악보 열기';

  @override
  String get libraryScreenRenameEllipsis => '이름 변경…';

  @override
  String get libraryScreenLabelsEllipsis => '라벨…';

  @override
  String get libraryScreenSplitIntoPiecesEllipsis => '곡으로 나누기…';

  @override
  String get libraryScreenPagesEllipsis => '페이지…';

  @override
  String get libraryScreenReplacePdfEllipsis => 'PDF 교체…';

  @override
  String get libraryScreenDeleteEllipsis => '삭제…';

  @override
  String libraryScreenAddedRelative(String when) {
    return '$when 추가됨';
  }

  @override
  String libraryScreenOpenedRelative(String when) {
    return '$when 열람';
  }

  @override
  String libraryScreenRecencyWithPages(String when, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '페이지',
      one: '페이지',
    );
    return '$when · $pages$_temp0';
  }

  @override
  String get libraryScreenNoSetlistsYet => '아직 세트리스트가 없어요';

  @override
  String get libraryScreenSetlistsEmptyHint =>
      '악보를 묶어두면 하나씩 다시 열지 않고 이어서 연주할 수 있어요.';

  @override
  String libraryScreenSetlistScoreCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '개 악보',
      one: '개 악보',
    );
    return '$count$_temp0';
  }

  @override
  String get libraryScreenSetlistCountEmpty => '비어 있음';

  @override
  String libraryScreenSetlistScoreCountOpened(
    String scoreCount,
    String opened,
  ) {
    return '$scoreCount · $opened';
  }

  @override
  String get metronomeSheetTitle => '메트로놈';

  @override
  String get metronomeSheetTempo => '템포';

  @override
  String get metronomeSheetMeter => '박자';

  @override
  String get metronomeSheetMeterHint => '마디마다 박이 어떻게 묶이는지 설정해요';

  @override
  String get metronomeSheetEqual => '균등';

  @override
  String get metronomeSheetMute => '음소거';

  @override
  String get metronomeSheetShowBeats => '박자 표시';

  @override
  String get metronomeSheetShowBeatsHint => '재생 중 악보에 박자를 깜빡여 표시해요';

  @override
  String metronomeSheetVolume(int percent) {
    return '음량: $percent%';
  }

  @override
  String get metronomeSheetStop => '정지';

  @override
  String get metronomeSheetStart => '시작';

  @override
  String get metronomeSheetEnterNumber => '숫자를 입력하세요';

  @override
  String get metronomeSheetTempoDialogTitle => '템포 설정';

  @override
  String get pageExtentScreenTitle => '페이지';

  @override
  String pageExtentScreenFirstPage(int page) {
    return '첫 페이지: $page';
  }

  @override
  String pageExtentScreenLastPage(int page) {
    return '마지막 페이지: $page';
  }

  @override
  String get pageExtentScreenNoPages => '페이지 없음';

  @override
  String get pageExtentScreenBadgeOnly => '단일';

  @override
  String get pageExtentScreenBadgeFirst => '첫 페이지';

  @override
  String get pageExtentScreenBadgeLast => '마지막 페이지';

  @override
  String pageExtentScreenSummary(String title, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '페이지',
      one: '페이지',
    );
    return '$title — $pages$_temp0';
  }

  @override
  String get pageExtentScreenHint => '아래에서 페이지를 탭하여 선택한 경계를 설정하세요.';

  @override
  String get pageNavBarPreviousPageTooltip => '이전 페이지';

  @override
  String get pageNavBarNextPageTooltip => '다음 페이지';

  @override
  String pageNavBarJumpedSnackbar(int page, int count) {
    return '$count페이지 중 $page페이지로 이동했어요';
  }

  @override
  String get pageNavBarGoToPageTitle => '페이지로 이동';

  @override
  String pageNavBarPageFieldLabel(int count) {
    return '페이지 (1–$count)';
  }

  @override
  String get piecesScreenEditPieces => '곡 편집…';

  @override
  String get piecesScreenNoPieces => '곡 없음';

  @override
  String get piecesScreenRename => '이름 변경…';

  @override
  String get piecesScreenLabels => '라벨…';

  @override
  String get piecesScreenSplitIntoPieces => '곡으로 나누기…';

  @override
  String get piecesScreenPages => '페이지…';

  @override
  String get piecesScreenReplacePdf => 'PDF 교체…';

  @override
  String get piecesScreenDelete => '삭제…';

  @override
  String piecesScreenAdded(String when) {
    return '$when 추가됨';
  }

  @override
  String piecesScreenOpened(String when) {
    return '$when 열람';
  }

  @override
  String piecesScreenRecencyWithPages(String when, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '페이지',
      one: '페이지',
    );
    return '$when · $pages$_temp0';
  }

  @override
  String piecesScreenPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '곡',
      one: '곡',
    );
    return '$count$_temp0';
  }

  @override
  String piecesScreenPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '페이지',
      one: '페이지',
    );
    return '$count$_temp0';
  }

  @override
  String get piecesScreenOpenFullScore => '전체 악보 열기';

  @override
  String get setlistEditorImportFirst => '먼저 악보를 가져오세요.';

  @override
  String get setlistEditorDefaultTitle => '새 세트리스트';

  @override
  String get setlistEditorAppBarTitle => '세트리스트 편집';

  @override
  String get setlistEditorAddScores => '악보 추가';

  @override
  String get setlistEditorTitleFieldLabel => '제목';

  @override
  String get setlistEditorEmpty => '아직 악보가 없어요. 악보 추가를 탭하여 세트리스트를 만들어 보세요.';

  @override
  String get setlistEditorMissingScore => '찾을 수 없는 악보';

  @override
  String get setlistEditorRemovedFromLibrary => '라이브러리에서 제거됨';

  @override
  String get setlistEditorRemoveTooltip => '제거';

  @override
  String setlistEditorAddCount(int count) {
    return '추가 ($count)';
  }

  @override
  String setlistEditorPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '곡',
      one: '곡',
    );
    return '$count$_temp0';
  }

  @override
  String get setlistEditorPiecesTooltip => '곡 보기';

  @override
  String get splitScoreScreenRenameTitle => '이름 변경';

  @override
  String get splitScoreScreenTitle => '곡으로 나누기';

  @override
  String get splitScoreScreenClearMarks => '표시 지우기';

  @override
  String get splitScoreScreenNoPages => '페이지 없음';

  @override
  String splitScoreScreenPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count곡',
      one: '1곡',
      zero: '아직 곡 없음',
    );
    return '$_temp0';
  }

  @override
  String get splitScoreScreenHint =>
      '페이지를 탭하여 새 곡이 시작되는 위치를 표시하세요. 표시된 페이지를 길게 누르면 이름을 바꿀 수 있어요.';

  @override
  String splitScoreScreenFrontMatterPage(int page) {
    return '$page페이지는 표지·목차 같은 페이지라 어떤 곡에도 속하지 않아요.';
  }

  @override
  String splitScoreScreenFrontMatterPages(int first, int last) {
    return '$first–$last페이지는 표지·목차 같은 페이지라 어떤 곡에도 속하지 않아요.';
  }

  @override
  String splitScoreScreenUseContents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '개 항목',
      one: '개 항목',
    );
    return '목차 사용 ($count$_temp0)';
  }

  @override
  String get libraryScreenNoPdfFiles => 'PDF 파일을 찾을 수 없어요.';

  @override
  String libraryScreenImportedScores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '개 악보를 가져왔어요',
      one: '개 악보를 가져왔어요',
    );
    return '$count$_temp0';
  }

  @override
  String get libraryScreenCreateBackupTitle => '백업을 만들까요?';

  @override
  String get libraryScreenCreateBackupBody =>
      '라이브러리 전체 — 악보, 라벨, 세트리스트, 설정 — 를 zip 파일로 저장해 공유하거나 안전한 곳에 보관할 수 있어요.';

  @override
  String get libraryScreenCreateBackupConfirm => '백업 만들기';

  @override
  String get libraryScreenCreatingBackup => '백업 만드는 중…';

  @override
  String get libraryScreenBackupShareSubject => 'StageScore 백업';

  @override
  String libraryScreenBackupSaved(String path) {
    return '백업을 $path에 저장했어요';
  }

  @override
  String get libraryScreenBackupReady => '백업 완료 — 공유 시트가 열렸어요';

  @override
  String libraryScreenBackupFailed(String error) {
    return '백업을 만들지 못했어요: $error';
  }

  @override
  String get libraryScreenRestoreBackupTitle => '백업을 복원할까요?';

  @override
  String get libraryScreenRestoreBackupBody =>
      '라이브러리 전체 — 악보, 라벨, 세트리스트, 설정 — 를 백업 내용으로 교체해요. 되돌릴 수 없어요.';

  @override
  String get libraryScreenReplaceAll => '모두 교체';

  @override
  String get libraryScreenRestoringBackup => '백업 복원 중…';

  @override
  String get libraryScreenLibraryRestored => '라이브러리를 복원했어요';

  @override
  String libraryScreenRestoreFailed(String error) {
    return '백업을 복원하지 못했어요: $error';
  }

  @override
  String libraryScreenPercentValue(int percent) {
    return '$percent%';
  }

  @override
  String get libraryScreenUntagged => '라벨 없음';

  @override
  String get libraryScreenThisFilter => '이 필터';

  @override
  String get libraryScreenAndConjunction => '그리고';

  @override
  String get libraryScreenAllOf => '모두 포함';

  @override
  String libraryScreenRemoveFilterChip(String label) {
    return '$label 필터 제거';
  }

  @override
  String get libraryScreenRenameScoreTitle => '악보 이름 변경';

  @override
  String get libraryScreenReplacePdfTitle => 'PDF를 교체할까요?';

  @override
  String libraryScreenReplacePdfBodyShared(
    int sharing,
    String title,
    int others,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '곡에도',
      one: '곡에도',
    );
    return '이 PDF는 “$title”을(를) 포함해 $sharing개 곡이 함께 사용하고 있어요. 교체하면 나머지 $others$_temp0 함께 적용돼요.';
  }

  @override
  String libraryScreenReplacePdfBodySingle(String title) {
    return '“$title”의 PDF를 교체할까요? 아래에서 주석을 유지하거나 초기화할 수 있어요.';
  }

  @override
  String get libraryScreenKeepOverlays => '주석 유지';

  @override
  String get libraryScreenResetOverlays => '주석 초기화';

  @override
  String get libraryScreenOverlaysReset => '주석을 초기화했어요.';

  @override
  String get libraryScreenOverlaysKept => '주석을 유지했어요.';

  @override
  String libraryScreenPdfReplaced(String overlayNote) {
    return 'PDF를 교체했어요. $overlayNote';
  }

  @override
  String libraryScreenPdfReplacedShortened(String overlayNote, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '개 항목이',
      one: '개 항목이',
    );
    return 'PDF를 교체했어요. $overlayNote 새 파일이 더 짧아서 페이지 순서에서 $count$_temp0 제외됐어요.';
  }

  @override
  String libraryScreenReplaceFailed(String error) {
    return 'PDF를 교체하지 못했어요: $error';
  }

  @override
  String continuousPageOrderViewOpenFailed(String error) {
    return 'PDF를 열지 못했어요: $error';
  }

  @override
  String get performancePageSlotBlank => '빈 페이지';

  @override
  String performancePageSlotMissingPage(int page) {
    return '$page페이지 없음';
  }

  @override
  String singlePageSliderOpenFailed(String error) {
    return 'PDF를 열지 못했어요: $error';
  }

  @override
  String aboutSheetVersion(String version) {
    return '버전 $version';
  }

  @override
  String aboutSheetVersionWithBuild(String version, String build) {
    return '버전 $version ($build)';
  }

  @override
  String aboutSheetLinkOpenFailed(String url) {
    return '링크를 열지 못했어요: $url';
  }

  @override
  String aboutSheetTitle(String productName) {
    return '$productName 정보';
  }

  @override
  String get aboutSheetWebsiteLabel => '웹사이트';

  @override
  String get aboutSheetPrivacyLabel => '개인정보 처리방침';

  @override
  String get aboutSheetSupportLabel => '지원';

  @override
  String get bookmarksSheetAddTitle => '북마크 추가';

  @override
  String bookmarksSheetPageLabel(int page) {
    return '$page페이지';
  }

  @override
  String get bookmarksSheetRenameTitle => '북마크 이름 변경';

  @override
  String get bookmarksSheetTitle => '북마크';

  @override
  String get bookmarksSheetEmpty => '아직 북마크가 없어요';

  @override
  String get displaySheetBorderColorTitle => '테두리 색상';

  @override
  String displaySheetHue(int value) {
    return '색상: $value';
  }

  @override
  String displaySheetSaturation(int value) {
    return '채도: $value';
  }

  @override
  String displaySheetColorValue(int value) {
    return '명도: $value';
  }

  @override
  String get displaySheetTitle => '화면';

  @override
  String get displaySheetPerformanceMode => '연주 모드';

  @override
  String get displaySheetPageBorder => '페이지 테두리';

  @override
  String displaySheetThickness(String value) {
    return '두께: $value';
  }

  @override
  String get displaySheetColorLabel => '색상';

  @override
  String get displaySheetCustomChip => '사용자 지정';

  @override
  String get displaySheetShowStatusBar => '상태 표시줄 표시';

  @override
  String get displaySheetShowStatusBarHint => '연주하는 동안 시계와 배터리를 계속 표시해요';

  @override
  String get displaySheetAvoidNotches => '노치 피하기';

  @override
  String get displaySheetAvoidNotchesHint => '카메라 노치와 둥근 모서리를 피해 페이지를 표시해요';

  @override
  String get jumpLinkEditSheetAddTitle => '점프 링크 추가';

  @override
  String get jumpLinkEditSheetEditTitle => '점프 링크 편집';

  @override
  String jumpLinkEditSheetOriginLabel(int page) {
    return '$page페이지에서';
  }

  @override
  String jumpLinkEditSheetDestinationLabel(int page, int pageCount) {
    return '$pageCount페이지 중 $page페이지로';
  }

  @override
  String get jumpLinkEditSheetColorLabel => '색상';

  @override
  String get jumpLinkEditSheetSizeLabel => '크기';

  @override
  String get jumpLinksSheetDragHint => '추가했어요. 목록에서 점프 링크를 드래그하면 순서를 바꿀 수 있어요.';

  @override
  String get jumpLinksSheetTitle => '점프 링크';

  @override
  String get jumpLinksSheetEmpty => '아직 점프 링크가 없어요';

  @override
  String jumpLinksSheetRowTitle(int from, int to) {
    return '$from페이지 → $to페이지';
  }

  @override
  String get jumpLinksSheetRowSubtitle => '탭하면 이 링크로 이동해요';

  @override
  String labelSheetsTitle(String title) {
    return '$title의 라벨';
  }

  @override
  String get labelSheetsManage => '관리';

  @override
  String get labelSheetsCreateLabel => '라벨 만들기';

  @override
  String get labelSheetsNewLabel => '새 라벨';

  @override
  String get labelSheetsManageTitle => '라벨 관리';

  @override
  String get labelSheetsNoLabelsYet => '아직 라벨이 없어요';

  @override
  String labelSheetsUsageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '개 악보에서 사용',
      one: '개 악보에서 사용',
    );
    return '$count$_temp0';
  }

  @override
  String get labelSheetsDeleteTitle => '라벨을 삭제할까요?';

  @override
  String labelSheetsDeleteConfirm(String name) {
    return '“$name”을(를) 삭제할까요?';
  }

  @override
  String labelSheetsDeleteConfirmWithUsage(String name, int usage) {
    String _temp0 = intl.Intl.pluralLogic(
      usage,
      locale: localeName,
      other: '개 악보에서 사용되고 있어요.',
      one: '개 악보에서 사용되고 있어요.',
    );
    return '“$name”은(는) $usage$_temp0 그래도 삭제할까요?';
  }

  @override
  String get labelSheetsRenameLabelTitle => '라벨 이름 변경';

  @override
  String get labelSheetsNameHint => '라벨 이름';

  @override
  String get libraryFilterSheetTitle => '필터';

  @override
  String get libraryFilterSheetModeAny => '하나 이상';

  @override
  String get libraryFilterSheetModeAll => '모두';

  @override
  String get libraryFilterSheetModeUntagged => '라벨 없음';

  @override
  String get libraryFilterSheetUntaggedHint => '라벨이 없는 악보';

  @override
  String get libraryFilterSheetEmptyLabels => '필터링할 라벨이 아직 없어요';

  @override
  String get measureMapMeasureCountTitle => 'MeasureBox는 몇 개?';

  @override
  String get measureMapMeasureCountLabel => 'MeasureBoxes';

  @override
  String get measureMapGoToTitle => '마디로 이동';

  @override
  String get measureMapGoToLabel => '마디 번호';

  @override
  String measureMapGoToMissing(int number) {
    return '$number번 마디가 아직 맵되지 않았습니다';
  }

  @override
  String get measureMapMetaTitle => '템포 및 박자';

  @override
  String get measureMapTimeSignatureLabel => '박자';

  @override
  String get measureMapTempoLabel => '템포';

  @override
  String get measureMapMetaScopeTitle => '적용 범위';

  @override
  String get measureMapScopeThisMeasure => '이 마디만';

  @override
  String get measureMapScopeThisSystem => '이 System';

  @override
  String get measureMapScopeThisPage => '이 페이지';

  @override
  String get measureMapScopeRestOfScore => 'Score 나머지';

  @override
  String get measureMapScopeNextN => 'Next N…';

  @override
  String get measureMapMetaNextNLabel => '마디 수';

  @override
  String get measureMapClearTitle => 'MeasureMap을 지울까요?';

  @override
  String get measureMapClearBody =>
      '이 Score의 모든 SystemBox와 MeasureBox를 삭제합니다. 되돌릴 수 없습니다.';

  @override
  String get measureMapClearConfirm => '지우기';

  @override
  String get measureMapDeleteSystemTitle => 'System을 삭제할까요?';

  @override
  String get measureMapDeleteSystemBody => '이 SystemBox와 모든 MeasureBox를 삭제합니다.';

  @override
  String get measureMapCopyFromPageTitle => '페이지에서 레이아웃 복사';

  @override
  String get measureMapCopyFromPageLabel => '원본 페이지';

  @override
  String get measureMapCopyPrevious => '이전 페이지 복사';

  @override
  String get measureMapEmptyHint => 'System을 그리면 마디 수를 묻습니다';

  @override
  String get measureMapDone => '완료';

  @override
  String get measureMapEditBeats => 'Edit beats';

  @override
  String get measureMapSetMeasureCount => '마디 수 설정…';

  @override
  String get measureMapDeleteSystem => 'System 삭제';

  @override
  String get measureMapDeleteMeasure => '마디 삭제';

  @override
  String get measureMapEditMeta => '템포 및 박자…';

  @override
  String get measureMapClearAll => 'MeasureMap 지우기…';
}
