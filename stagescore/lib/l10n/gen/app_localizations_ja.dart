// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get actionSave => '保存';

  @override
  String get actionDone => '完了';

  @override
  String get actionDelete => '削除';

  @override
  String get actionOk => 'OK';

  @override
  String get actionClear => 'クリア';

  @override
  String get actionApply => '適用';

  @override
  String get actionAdd => '追加';

  @override
  String get actionEdit => '編集';

  @override
  String get actionRename => '名前を変更';

  @override
  String get actionBack => '戻る';

  @override
  String get actionMore => 'その他';

  @override
  String get actionGo => '移動';

  @override
  String get actionUndo => '元に戻す';

  @override
  String get actionContinue => '続ける';

  @override
  String get actionReset => 'リセット';

  @override
  String get commonOr => 'または';

  @override
  String get commonTitleLabel => 'タイトル';

  @override
  String get themeModeSystem => 'システム';

  @override
  String get themeModeLight => 'ライト';

  @override
  String get themeModeDark => 'ダーク';

  @override
  String get pdfLayoutModeAuto => '自動';

  @override
  String get pdfLayoutModeSingle => '1ページ';

  @override
  String get pdfLayoutModeTwoPages => '見開き2ページ';

  @override
  String get pdfLayoutModeScroll => 'スクロール';

  @override
  String get pdfLayoutModeScrollSideways => 'スクロール（横）';

  @override
  String get pdfLayoutModeHalfPageTopBottom => '1ページ＋のぞき見';

  @override
  String get pdfLayoutModeHalfPageLeftRight => '1ページ＋横のぞき見';

  @override
  String get pageColorFilterOff => 'オフ';

  @override
  String get pageColorFilterSepia => 'セピア';

  @override
  String get pageColorFilterGreen => 'グリーン';

  @override
  String get pageColorFilterInvert => '反転';

  @override
  String get pageScaleScopeFixed => '固定';

  @override
  String get pageScaleScopePerScore => '楽譜ごと';

  @override
  String get pageScaleScopePerPage => 'ページごと';

  @override
  String get stagePresetSetUpToPlay => '演奏モードにする';

  @override
  String get stagePresetSetUpToPractise => '練習モードにする';

  @override
  String get stagePresetChromeHidden => 'UIを非表示';

  @override
  String get stagePresetChromeShown => 'UIを表示';

  @override
  String get stagePresetStatusBarShown => 'ステータスバー表示';

  @override
  String get stagePresetStatusBarHidden => 'ステータスバー非表示';

  @override
  String get stagePresetScaleKept => '拡大率を維持';

  @override
  String get stagePresetPinchFree => 'ピンチ操作を無効化';

  @override
  String get relativeDayToday => '今日';

  @override
  String get relativeDayYesterday => '昨日';

  @override
  String relativeDayDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '日前',
      one: '日前',
    );
    return '$days$_temp0';
  }

  @override
  String pageOrderEditorEntryBlank(int index) {
    return '$index. 空白';
  }

  @override
  String pageOrderEditorEntryPdfPage(int index, int sourcePage) {
    return '$index. PDFページ$sourcePage';
  }

  @override
  String get pageOrderEditorResetTitle => '元の順番に戻しますか？';

  @override
  String get pageOrderEditorResetBody => 'PDFのページ順を元に戻し、空白ページと重複を削除しますか？';

  @override
  String get pageOrderEditorReset => 'リセット';

  @override
  String get pageOrderEditorAppBarTitle => 'ページ順';

  @override
  String get pageOrderEditorNoPages => 'ページがありません';

  @override
  String get pageOrderEditorDuplicate => '複製';

  @override
  String get pageOrderEditorInsertBlank => '空白ページを挿入';

  @override
  String get pageOrderEditorRemove => '削除';

  @override
  String get librarySortTitle => 'タイトル';

  @override
  String get librarySortCreated => '作成日';

  @override
  String get librarySortLastViewed => '最終閲覧';

  @override
  String scoreOriginPage(int page) {
    return '$pageページ目';
  }

  @override
  String scoreOriginPages(int first, int last) {
    return '$first〜$lastページ目';
  }

  @override
  String scoreOriginPagesOfBook(String pages, String name) {
    return '$pages（$name）';
  }

  @override
  String libraryVisibilityInBook(String title) {
    return '$title内';
  }

  @override
  String get libraryVisibilityInBookFallback => '本の中';

  @override
  String get libraryBackupFileNotFound => 'バックアップファイルが見つかりません。';

  @override
  String get libraryBackupFailedGeneric => 'バックアップに失敗しました。';

  @override
  String libraryBackupCreateFailed(String error) {
    return 'バックアップを作成できませんでした：$error';
  }

  @override
  String libraryBackupRestoreFailed(String error) {
    return 'バックアップを復元できませんでした：$error';
  }

  @override
  String get libraryBackupMissingMarker =>
      'StageScoreのバックアップではありません（マーカーがありません）。';

  @override
  String get libraryBackupUnknownFormat => 'StageScoreのバックアップではありません（不明な形式）。';

  @override
  String get libraryBackupUnsupportedVersion =>
      'サポートされていないStageScoreバックアップのバージョンです。';

  @override
  String get libraryBackupCorruptMarker =>
      'StageScoreのバックアップではありません（マーカーが壊れています）。';

  @override
  String get gestureMapLongPress => '長押し';

  @override
  String get gestureMapTapTopEdge => '上端をタップ';

  @override
  String get gestureMapTapBottomEdge => '下端をタップ';

  @override
  String get gestureMapEmptyHint => '「メニュー/UIを表示」の操作を設定すると呼び出せます。';

  @override
  String gestureMapRevealHint(String joined) {
    return '演奏中はツールバーとページバーを隠します。表示に戻すには、$joinedしてください。';
  }

  @override
  String get layoutNavigationPedalOrPageBar => 'ペダルまたはページバー';

  @override
  String get layoutNavigationTapLeftRight => '左右をタップ';

  @override
  String get layoutNavigationTapTopBottom => '上下をタップ';

  @override
  String get layoutNavigationTapAnywhere => 'どこでもタップ';

  @override
  String get layoutNavigationTapAnywhereBack => 'どこでもタップして戻る';

  @override
  String get layoutNavigationSwipe => 'スワイプ';

  @override
  String get layoutNavigationSwipeSideways => '横にスワイプ';

  @override
  String get layoutNavigationSwipeUpDown => '上下にスワイプ';

  @override
  String get scoreMenuSheetTitle => 'メニュー';

  @override
  String get appearanceSheetTitle => '外観';

  @override
  String get appearanceSheetMode => 'モード';

  @override
  String get appearanceSheetThemeColor => 'テーマカラー';

  @override
  String get appearanceSheetCustomChip => 'カスタム';

  @override
  String get appearanceSheetCustomColorDialog => 'カスタムカラー';

  @override
  String get appearanceSheetHue => '色相';

  @override
  String get appearanceSheetSat => '彩度';

  @override
  String get appearanceSheetVal => '明度';

  @override
  String get scoreMenuGoTo => '移動';

  @override
  String get scoreMenuBookmarks => 'ブックマーク';

  @override
  String get scoreMenuJumpLinks => 'ジャンプリンク';

  @override
  String get scoreMenuPageOrder => 'ページ順…';

  @override
  String get scoreMenuMarks => 'マーク';

  @override
  String get scoreMenuHideAnnotations => '注釈を隠す';

  @override
  String get scoreMenuShowAnnotations => '注釈を表示';

  @override
  String get scoreMenuExporting => '書き出し中…';

  @override
  String get scoreMenuExportAnnotated => '注釈付きPDFを書き出す';

  @override
  String get scoreMenuView => '表示';

  @override
  String get scoreMenuLayout => 'レイアウト';

  @override
  String get scoreMenuDisplay => '画面設定…';

  @override
  String get scoreMenuColorFilter => 'カラーフィルター…';

  @override
  String get scoreMenuPageScale => 'ページの拡大率…';

  @override
  String get scoreMenuLocked => 'ロック中';

  @override
  String get scoreMenuPlaying => '再生中';

  @override
  String get scoreMenuMetronomeRunning => 'メトロノーム（動作中）…';

  @override
  String get scoreMenuMetronome => 'メトロノーム…';

  @override
  String get scoreMenuPageTurnSettings => 'ページめくり設定';

  @override
  String scoreMenuLayoutValueBoth(String stored, String resolved) {
    return '$stored・$resolved';
  }

  @override
  String get languageSheetTitle => '言語';

  @override
  String get languageSheetSystem => 'システム';

  @override
  String get languageSheetSystemSubtitle => '端末の言語に合わせる';

  @override
  String get stampSheetTitle => 'スタンプ';

  @override
  String get stampBox => '四角';

  @override
  String get stampCircle => '丸';

  @override
  String get stampArrow => '矢印';

  @override
  String get stampText => 'テキスト';

  @override
  String get pageScaleSheetTitle => 'ページの拡大率';

  @override
  String get pageScaleSheetExplainer =>
      '楽譜をどれくらい大きく表示するかで、次回以降も保持されます。ピンチ操作はその場限りの表示変更ですが、ここでの設定は保存されます。';

  @override
  String pageScaleSheetCurrent(String value) {
    return '現在このページでは：$value×';
  }

  @override
  String get pageScaleSheetAppliesTo => '適用範囲';

  @override
  String get pageScaleSheetScale => '拡大率';

  @override
  String pageScaleSheetScaleValue(String value) {
    return '$value×';
  }

  @override
  String get pageScaleSheetKeepScale => 'この拡大率を保持';

  @override
  String get pageScaleSheetKeepScaleSubtitle =>
      'ピンチ操作がオフになるため、演奏中に誤って触れても表示が動きません';

  @override
  String get pageScaleSheetHintFixed => '個別設定のある楽譜を除き、すべての楽譜に適用';

  @override
  String get pageScaleSheetHintPerScore => 'この楽譜のみ、すべてのページに適用';

  @override
  String get pageScaleSheetHintPerPage =>
      'このページのみ ― 文字が密なページだけ大きくして、他のページはそのまま';

  @override
  String get layoutSettingsSheetTitle => 'レイアウト';

  @override
  String get layoutSettingsSheetPageTurnSettings => 'ページめくり設定';

  @override
  String get layoutSettingsSheetPageTurnSettingsSubtitle =>
      'タップ範囲、スワイプ、ペダル、アニメーション';

  @override
  String get layoutSettingsSheetFallsBack => 'この画面では1ページ表示です ― 回転すると見開きになります';

  @override
  String layoutSettingsSheetNow(String mode) {
    return '現在：$mode';
  }

  @override
  String get layoutSettingsSheetFitsScreen => 'この画面に収まっています';

  @override
  String get pageTurnSettingsSheetGestureWarning =>
      '少なくとも1つの操作は「メニュー/UIを表示」に設定してください。';

  @override
  String get pageTurnSettingsSheetTitle => 'ページめくり';

  @override
  String get pageTurnSettingsSheetTapZones => 'タップ範囲';

  @override
  String pageTurnSettingsSheetTapZonesHint(
    String layoutMode,
    String navigationHint,
  ) {
    return '$layoutModeでは：$navigationHint。';
  }

  @override
  String get pageTurnSettingsSheetSwipe => 'スワイプ';

  @override
  String get pageTurnSettingsSheetMatchLayout => 'レイアウトに合わせる';

  @override
  String get pageTurnSettingsSheetMatchLayoutSubtitle => 'ページが動く向きに合わせてスワイプします';

  @override
  String get pageTurnSettingsSheetSwipeLeftNext => '左にスワイプ → 次へ';

  @override
  String get pageTurnSettingsSheetSwipeRightPrevious => '右にスワイプ → 前へ';

  @override
  String get pageTurnSettingsSheetSwipeUpNext => '上にスワイプ → 次へ';

  @override
  String get pageTurnSettingsSheetSwipeDownPrevious => '下にスワイプ → 前へ';

  @override
  String get pageTurnSettingsSheetReverseDirection => 'ページめくりの向きを反転';

  @override
  String get pageTurnSettingsSheetReverseDirectionSubtitle => '逆綴じの本向け';

  @override
  String get pageTurnSettingsSheetTurnAmount => 'めくる量';

  @override
  String get pageTurnSettingsSheetTurnAmountHintTwoPage =>
      '「半分」にすると見開き全体ではなく片側の1ページだけ進みます。';

  @override
  String get pageTurnSettingsSheetTurnAmountHintDefault =>
      '「半分」にすると画面全体ではなく約半分だけ進みます。';

  @override
  String get pageTurnSettingsSheetAnimation => 'アニメーション';

  @override
  String get pageTurnSettingsSheetPageTurnDelay => 'ページめくりの遅延';

  @override
  String get pageTurnSettingsSheetApplyTo => '適用範囲';

  @override
  String get pageTurnSettingsSheetGestures => '操作';

  @override
  String get pageTurnSettingsSheetGesturesHint =>
      '端タップは画面の上下にある細い帯状の範囲で、上/下のページめくり範囲とは異なります。少なくとも1つは「メニュー/UIを表示」に設定してください。演奏モードでもこの操作でツールバーを呼び出せます。描画はツールバーからのみ開始でき、操作からは開始できません。';

  @override
  String get pageTurnSettingsSheetLongPress => '長押し';

  @override
  String get pageTurnSettingsSheetTopEdge => '上端';

  @override
  String get pageTurnSettingsSheetBottomEdge => '下端';

  @override
  String get pageTurnSettingsSheetPedalKeyboard => 'ペダル／キーボード';

  @override
  String get pageTurnSettingsSheetPedalKeyboardHint =>
      'キーボード操作を送信するBluetoothペダルに対応しています：\nPrevious（前へ） — PageUp、←、↑、スペース\nNext（次へ） — PageDown、→、↓、Enter';

  @override
  String get pageTurnAnimationOff => 'オフ';

  @override
  String get pageTurnAnimationFast => '速い';

  @override
  String get pageTurnAnimationNormal => '標準';

  @override
  String get pageTurnAnimationSlow => '遅い';

  @override
  String get pageTurnDelayOff => 'オフ';

  @override
  String get pageTurnDelay300ms => '0.3秒';

  @override
  String get pageTurnDelay500ms => '0.5秒';

  @override
  String get pageTurnDelay1000ms => '1.0秒';

  @override
  String get pageTurnDelayScopeAll => 'すべて';

  @override
  String get pageTurnDelayScopePedalOnly => 'ペダル／キーボードのみ';

  @override
  String get pageTurnTapModeMatchLayout => 'レイアウトに合わせる';

  @override
  String get pageTurnTapModeLeftRight => '左／右';

  @override
  String get pageTurnTapModeTopBottom => '上／下';

  @override
  String get pageTurnTapModePrevious => 'どこでも → 前へ';

  @override
  String get pageTurnTapModeNext => 'どこでも → 次へ';

  @override
  String get pageTurnTapModeDisabled => '無効';

  @override
  String get turnAmountFull => '1ページ全体';

  @override
  String get turnAmountHalf => '半ページ';

  @override
  String get gestureMapActionShowChrome => 'メニュー/UIを表示';

  @override
  String get gestureMapActionDisabled => 'オフ';

  @override
  String get drawToolbarColorLabel => '色';

  @override
  String get drawToolbarSizeLabel => 'サイズ';

  @override
  String get drawToolbarUndo => '元に戻す';

  @override
  String get drawToolbarRedo => 'やり直す';

  @override
  String get drawToolbarDelete => '削除';

  @override
  String get drawToolbarStamp => 'スタンプ';

  @override
  String get drawToolbarPlace => '配置';

  @override
  String get drawToolbarMore => 'その他';

  @override
  String get drawToolbarTextStampTitle => 'テキストスタンプ';

  @override
  String get drawToolbarTextStampHint => '短いラベル';

  @override
  String get drawToolbarDrawOptionsTitle => '描画オプション';

  @override
  String get drawToolbarTool => 'ツール';

  @override
  String get drawToolbarWidth => '太さ';

  @override
  String get drawToolbarStraightLine => '直線';

  @override
  String get drawToolPen => 'ペン';

  @override
  String get drawToolMarker => 'マーカー';

  @override
  String get drawToolEraser => '消しゴム';

  @override
  String get drawToolEyedropper => 'スポイト';

  @override
  String get drawWidthThin => '細い';

  @override
  String get drawWidthMedium => '普通';

  @override
  String get drawWidthThick => '太い';

  @override
  String get pdfModeScreenTapHint => '右半分をタップで次のページ、左半分で前のページに戻ります。';

  @override
  String get pdfModeScreenColorFilterTitle => 'カラーフィルター';

  @override
  String get scoreMenuQuickBarBookmarks => 'ブックマーク';

  @override
  String get scoreMenuQuickBarDraw => '描画';

  @override
  String get scoreMenuQuickBarExitDraw => '描画を終了';

  @override
  String get scoreMenuQuickBarMetronome => 'メトロノーム';

  @override
  String get scoreMenuQuickBarMetronomeRunning => 'メトロノーム（動作中）';

  @override
  String get pdfModeScreenExporting => 'PDFを書き出し中…';

  @override
  String get pdfModeScreenExportReady => '書き出し完了 ― 共有シートを開きました';

  @override
  String pdfModeScreenExportRestartHint(String path) {
    return '$pathに書き出しました。共有シートを有効にするには、アプリを完全に再起動してください（stop + flutter run）。';
  }

  @override
  String pdfModeScreenExportFailed(String error) {
    return '書き出しに失敗しました：$error';
  }

  @override
  String pdfModeScreenPieceIndex(int index) {
    return '$index.';
  }

  @override
  String get pdfModeScreenHidePieceNotes => '曲のメモを隠す';

  @override
  String get pdfModeScreenShowPieceNotes => '曲のメモを表示';

  @override
  String get pdfModeScreenPieceNotes => '曲のメモ';

  @override
  String get libraryScreenSort => '並べ替え';

  @override
  String get libraryScreenFilter => 'フィルター';

  @override
  String get libraryScreenManageLabels => 'ラベルを管理';

  @override
  String get libraryScreenMore => 'その他';

  @override
  String get libraryScreenAppearance => '外観…';

  @override
  String get libraryScreenLanguage => '言語…';

  @override
  String get libraryScreenBackup => 'バックアップ…';

  @override
  String get libraryScreenRestore => '復元…';

  @override
  String libraryScreenAbout(String productName) {
    return '$productNameについて…';
  }

  @override
  String libraryScreenSplitIntoPiecesSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '曲',
      one: '曲',
    );
    return '$count$_temp0に分割しました';
  }

  @override
  String get libraryScreenStillReadingPdf =>
      'まだこのPDFを読み込み中です ― もう少し待ってから再試行してください。';

  @override
  String get libraryScreenEditPiecesAppBarTitle => '曲を編集';

  @override
  String libraryScreenUpdatedPieces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '曲',
      one: '曲',
    );
    return '$count$_temp0に更新しました。';
  }

  @override
  String get libraryScreenEditPiecesDialogTitle => '曲のデータを削除しますか？';

  @override
  String libraryScreenEditPiecesBody(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'を削除します。関連する注釈、ブックマーク、ジャンプリンク、ラベル、セットリストへの登録も削除されます。',
      one: 'を削除します。関連する注釈、ブックマーク、ジャンプリンク、ラベル、セットリストへの登録も削除されます。',
    );
    return '$names$_temp0';
  }

  @override
  String get libraryScreenSplitIntoPiecesDialogTitle => '曲に分割しますか？';

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
      other: 'ページ',
      one: 'ページ',
    );
    return '「$title」をページ$firstPage〜$lastPageに絞り込むと、ページ順から$dropping$_temp0削除されます。';
  }

  @override
  String get libraryScreenSplitConfirm => '分割';

  @override
  String get libraryScreenChangePagesTitle => 'ページを変更しますか？';

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
      other: 'ページ',
      one: 'ページ',
    );
    return '「$title」のページを$firstPage〜$lastPageに変更すると、ページ順から$dropping$_temp0削除されます。';
  }

  @override
  String get libraryScreenChangePagesConfirm => '変更';

  @override
  String get libraryScreenSetlistEmptyAddScores => 'まずこのセットリストに楽譜を追加してください。';

  @override
  String get libraryScreenNoScoresAvailable => 'このセットリストの楽譜は見つかりませんでした。';

  @override
  String libraryScreenSkippedMissingScores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '件',
      one: '件',
    );
    return '$count$_temp0の見つからない楽譜をスキップしました。';
  }

  @override
  String get libraryScreenNewSetlist => '新しいセットリスト';

  @override
  String get libraryScreenDeleteSetlistTitle => 'セットリストを削除しますか？';

  @override
  String libraryScreenDeleteSetlistBody(String title) {
    return '「$title」を削除しますか？中の楽譜は削除されません。';
  }

  @override
  String libraryScreenDeleteScoreBody(String title) {
    return '「$title」を削除しますか？この操作は取り消せません。';
  }

  @override
  String libraryScreenDeleteScoreWithPiecesBody(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '曲',
      one: '曲',
    );
    return '「$title」とその$count$_temp0を削除しますか？この操作は取り消せません。';
  }

  @override
  String get libraryScreenDeleteScoreTitle => '楽譜を削除しますか？';

  @override
  String get libraryScreenTabScores => '楽譜';

  @override
  String get libraryScreenTabSetlists => 'セットリスト';

  @override
  String get libraryScreenSearchHint => '楽譜を検索';

  @override
  String get libraryScreenAddPdf => 'PDFを追加';

  @override
  String libraryScreenSplitSuggestionWithPages(String name, int pages) {
    return '「$name」（$pagesページ）は複数の曲に分けられそうです。';
  }

  @override
  String libraryScreenSplitSuggestionGeneric(String name) {
    return '「$name」は複数の曲に分けられそうです。';
  }

  @override
  String get libraryScreenNotNow => '今はしない';

  @override
  String get libraryScreenSplitEllipsis => '分割…';

  @override
  String libraryScreenFailedToOpen(String error) {
    return 'ライブラリを開けませんでした：$error';
  }

  @override
  String get libraryScreenNoScoresYet => '楽譜がまだありません';

  @override
  String get libraryScreenImportPdfHint => 'PDFをインポートして始めましょう。';

  @override
  String get libraryScreenAddSampleScore => 'サンプル楽譜を追加';

  @override
  String libraryScreenNoScoresMatchSearch(String query) {
    return '「$query」に一致する楽譜がありません。';
  }

  @override
  String libraryScreenNoScoresMatchFilter(String filter) {
    return '$filterに一致する楽譜がありません。';
  }

  @override
  String get libraryScreenClearSearch => '検索をクリア';

  @override
  String get libraryScreenClearFilter => 'フィルターをクリア';

  @override
  String libraryScreenRecencyWithPieces(String when, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '曲',
      one: '曲',
    );
    return '$when・$count$_temp0';
  }

  @override
  String get libraryScreenPiecesEllipsis => '曲…';

  @override
  String get libraryScreenEditPiecesMenuItem => '曲を編集…';

  @override
  String get libraryScreenOpenFullScore => '全曲を開く';

  @override
  String get libraryScreenRenameEllipsis => '名前を変更…';

  @override
  String get libraryScreenLabelsEllipsis => 'ラベル…';

  @override
  String get libraryScreenSplitIntoPiecesEllipsis => '曲に分割…';

  @override
  String get libraryScreenPagesEllipsis => 'ページ…';

  @override
  String get libraryScreenReplacePdfEllipsis => 'PDFを置き換え…';

  @override
  String get libraryScreenDeleteEllipsis => '削除…';

  @override
  String libraryScreenAddedRelative(String when) {
    return '$whenに追加';
  }

  @override
  String libraryScreenOpenedRelative(String when) {
    return '$whenに開いた';
  }

  @override
  String libraryScreenRecencyWithPages(String when, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: 'ページ',
      one: 'ページ',
    );
    return '$when・$pages$_temp0';
  }

  @override
  String get libraryScreenNoSetlistsYet => 'セットリストがまだありません';

  @override
  String get libraryScreenSetlistsEmptyHint =>
      '楽譜をまとめておけば、一曲ずつ開き直さずに続けて演奏・閲覧できます。';

  @override
  String libraryScreenSetlistScoreCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '曲',
      one: '曲',
    );
    return '$count$_temp0';
  }

  @override
  String get libraryScreenSetlistCountEmpty => '空';

  @override
  String libraryScreenSetlistScoreCountOpened(
    String scoreCount,
    String opened,
  ) {
    return '$scoreCount・$opened';
  }

  @override
  String get metronomeSheetTitle => 'メトロノーム';

  @override
  String get metronomeSheetTempo => 'テンポ';

  @override
  String get metronomeSheetMeter => '拍子';

  @override
  String get metronomeSheetMeterHint => '1小節内での拍のまとまり方';

  @override
  String get metronomeSheetEqual => '均等';

  @override
  String get metronomeSheetMute => 'ミュート';

  @override
  String get metronomeSheetShowBeats => '拍を表示';

  @override
  String get metronomeSheetShowBeatsHint => '再生中に楽譜上で拍を点滅させます';

  @override
  String metronomeSheetVolume(int percent) {
    return '音量：$percent%';
  }

  @override
  String get metronomeSheetStop => '停止';

  @override
  String get metronomeSheetStart => '開始';

  @override
  String get metronomeSheetEnterNumber => '数値を入力してください';

  @override
  String get metronomeSheetTempoDialogTitle => 'テンポを設定';

  @override
  String get pageExtentScreenTitle => 'ページ';

  @override
  String pageExtentScreenFirstPage(int page) {
    return '先頭ページ：$page';
  }

  @override
  String pageExtentScreenLastPage(int page) {
    return '最終ページ：$page';
  }

  @override
  String get pageExtentScreenNoPages => 'ページがありません';

  @override
  String get pageExtentScreenBadgeOnly => '単独';

  @override
  String get pageExtentScreenBadgeFirst => '先頭';

  @override
  String get pageExtentScreenBadgeLast => '最終';

  @override
  String pageExtentScreenSummary(String title, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: 'ページ',
      one: 'ページ',
    );
    return '$title ― $pages$_temp0';
  }

  @override
  String get pageExtentScreenHint => '下のページをタップして、選択中の境界を設定します。';

  @override
  String get pageNavBarPreviousPageTooltip => '前のページ';

  @override
  String get pageNavBarNextPageTooltip => '次のページ';

  @override
  String pageNavBarJumpedSnackbar(int page, int count) {
    return '$pageページ目（全$countページ）に移動しました';
  }

  @override
  String get pageNavBarGoToPageTitle => 'ページに移動';

  @override
  String pageNavBarPageFieldLabel(int count) {
    return 'ページ（1〜$count）';
  }

  @override
  String get piecesScreenEditPieces => '曲を編集…';

  @override
  String get piecesScreenNoPieces => '曲がありません';

  @override
  String get piecesScreenRename => '名前を変更…';

  @override
  String get piecesScreenLabels => 'ラベル…';

  @override
  String get piecesScreenSplitIntoPieces => '曲に分割…';

  @override
  String get piecesScreenPages => 'ページ…';

  @override
  String get piecesScreenReplacePdf => 'PDFを置き換え…';

  @override
  String get piecesScreenDelete => '削除…';

  @override
  String piecesScreenAdded(String when) {
    return '$whenに追加';
  }

  @override
  String piecesScreenOpened(String when) {
    return '$whenに開いた';
  }

  @override
  String piecesScreenRecencyWithPages(String when, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: 'ページ',
      one: 'ページ',
    );
    return '$when・$pages$_temp0';
  }

  @override
  String piecesScreenPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '曲',
      one: '曲',
    );
    return '$count$_temp0';
  }

  @override
  String piecesScreenPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ページ',
      one: 'ページ',
    );
    return '$count$_temp0';
  }

  @override
  String get piecesScreenOpenFullScore => '全曲を開く';

  @override
  String get setlistEditorImportFirst => 'まず楽譜をインポートしてください。';

  @override
  String get setlistEditorDefaultTitle => '新しいセットリスト';

  @override
  String get setlistEditorAppBarTitle => 'セットリストを編集';

  @override
  String get setlistEditorAddScores => '楽譜を追加';

  @override
  String get setlistEditorTitleFieldLabel => 'タイトル';

  @override
  String get setlistEditorEmpty => '楽譜がまだありません。「楽譜を追加」をタップしてセットリストを作りましょう。';

  @override
  String get setlistEditorMissingScore => '見つからない楽譜';

  @override
  String get setlistEditorRemovedFromLibrary => 'ライブラリから削除されました';

  @override
  String get setlistEditorRemoveTooltip => '削除';

  @override
  String setlistEditorAddCount(int count) {
    return '追加（$count）';
  }

  @override
  String setlistEditorPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '曲',
      one: '曲',
    );
    return '$count$_temp0';
  }

  @override
  String get setlistEditorPiecesTooltip => '曲を見る';

  @override
  String get splitScoreScreenRenameTitle => '名前を変更';

  @override
  String get splitScoreScreenTitle => '曲に分割';

  @override
  String get splitScoreScreenClearMarks => 'マークをクリア';

  @override
  String get splitScoreScreenNoPages => 'ページがありません';

  @override
  String splitScoreScreenPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count曲',
      one: '1曲',
      zero: '曲はまだありません',
    );
    return '$_temp0';
  }

  @override
  String get splitScoreScreenHint =>
      '新しい曲の始まりにしたいページをタップしてマークします。マーク済みのページを長押しすると名前を変更できます。';

  @override
  String splitScoreScreenFrontMatterPage(int page) {
    return '$pageページ目は前付けページのため、どの曲にも属しません。';
  }

  @override
  String splitScoreScreenFrontMatterPages(int first, int last) {
    return '$first〜$lastページ目は前付けページのため、どの曲にも属しません。';
  }

  @override
  String splitScoreScreenUseContents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '件',
      one: '件',
    );
    return '目次を使用する（$count$_temp0）';
  }

  @override
  String get libraryScreenNoPdfFiles => 'PDFファイルが見つかりませんでした。';

  @override
  String libraryScreenImportedScores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '件',
      one: '件',
    );
    return '$count$_temp0の楽譜をインポートしました';
  }

  @override
  String get libraryScreenCreateBackupTitle => 'バックアップを作成しますか？';

  @override
  String get libraryScreenCreateBackupBody =>
      'ライブラリ全体 ― 楽譜、ラベル、セットリスト、設定 ― のコピーをzipファイルとして保存します。共有したり、安全な場所に保管したりできます。';

  @override
  String get libraryScreenCreateBackupConfirm => 'バックアップを作成';

  @override
  String get libraryScreenCreatingBackup => 'バックアップを作成中…';

  @override
  String get libraryScreenBackupShareSubject => 'StageScoreバックアップ';

  @override
  String libraryScreenBackupSaved(String path) {
    return 'バックアップを$pathに保存しました';
  }

  @override
  String get libraryScreenBackupReady => 'バックアップ完了 ― 共有シートを開きました';

  @override
  String libraryScreenBackupFailed(String error) {
    return 'バックアップを作成できませんでした：$error';
  }

  @override
  String get libraryScreenRestoreBackupTitle => 'バックアップを復元しますか？';

  @override
  String get libraryScreenRestoreBackupBody =>
      'ライブラリ全体 ― 楽譜、ラベル、セットリスト、設定 ― をバックアップの内容で置き換えます。この操作は取り消せません。';

  @override
  String get libraryScreenReplaceAll => 'すべて置き換える';

  @override
  String get libraryScreenRestoringBackup => 'バックアップを復元中…';

  @override
  String get libraryScreenLibraryRestored => 'ライブラリを復元しました';

  @override
  String libraryScreenRestoreFailed(String error) {
    return 'バックアップを復元できませんでした：$error';
  }

  @override
  String libraryScreenPercentValue(int percent) {
    return '$percent%';
  }

  @override
  String get libraryScreenUntagged => 'ラベルなし';

  @override
  String get libraryScreenThisFilter => 'このフィルター';

  @override
  String get libraryScreenAndConjunction => 'かつ';

  @override
  String get libraryScreenAllOf => 'すべて';

  @override
  String libraryScreenRemoveFilterChip(String label) {
    return '$labelフィルターを削除';
  }

  @override
  String get libraryScreenRenameScoreTitle => '楽譜の名前を変更';

  @override
  String get libraryScreenReplacePdfTitle => 'PDFを置き換えますか？';

  @override
  String libraryScreenReplacePdfBodyShared(
    int sharing,
    String title,
    int others,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '曲',
      one: '曲',
    );
    return 'このPDFは$sharing曲で共有されており、「$title」もその一つです。置き換えると、他の$others$_temp0も変更されます。';
  }

  @override
  String libraryScreenReplacePdfBodySingle(String title) {
    return '「$title」のPDFを置き換えますか？下で注釈を保持するかリセットするか選べます。';
  }

  @override
  String get libraryScreenKeepOverlays => '注釈を保持';

  @override
  String get libraryScreenResetOverlays => '注釈をリセット';

  @override
  String get libraryScreenOverlaysReset => '注釈をリセットしました。';

  @override
  String get libraryScreenOverlaysKept => '注釈を保持しました。';

  @override
  String libraryScreenPdfReplaced(String overlayNote) {
    return 'PDFを置き換えました。$overlayNote';
  }

  @override
  String libraryScreenPdfReplacedShortened(String overlayNote, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '件のページ設定が削除されました。',
      one: '件のページ設定が削除されました。',
    );
    return 'PDFを置き換えました。$overlayNote 新しいファイルの方が短いため、$count$_temp0';
  }

  @override
  String libraryScreenReplaceFailed(String error) {
    return 'PDFを置き換えられませんでした：$error';
  }

  @override
  String continuousPageOrderViewOpenFailed(String error) {
    return 'PDFを開けませんでした：$error';
  }

  @override
  String get performancePageSlotBlank => '空白';

  @override
  String performancePageSlotMissingPage(int page) {
    return '$pageページが見つかりません';
  }

  @override
  String singlePageSliderOpenFailed(String error) {
    return 'PDFを開けませんでした：$error';
  }

  @override
  String aboutSheetVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String aboutSheetVersionWithBuild(String version, String build) {
    return 'バージョン $version（$build）';
  }

  @override
  String aboutSheetLinkOpenFailed(String url) {
    return 'リンクを開けませんでした：$url';
  }

  @override
  String aboutSheetTitle(String productName) {
    return '$productNameについて';
  }

  @override
  String get aboutSheetWebsiteLabel => 'ウェブサイト';

  @override
  String get aboutSheetPrivacyLabel => 'プライバシー';

  @override
  String get aboutSheetSupportLabel => 'サポート';

  @override
  String get bookmarksSheetAddTitle => 'ブックマークを追加';

  @override
  String bookmarksSheetPageLabel(int page) {
    return '$pageページ目';
  }

  @override
  String get bookmarksSheetRenameTitle => 'ブックマーク名を変更';

  @override
  String get bookmarksSheetTitle => 'ブックマーク';

  @override
  String get bookmarksSheetEmpty => 'ブックマークがまだありません';

  @override
  String get displaySheetBorderColorTitle => '枠線の色';

  @override
  String displaySheetHue(int value) {
    return '色相：$value';
  }

  @override
  String displaySheetSaturation(int value) {
    return '彩度：$value';
  }

  @override
  String displaySheetColorValue(int value) {
    return '明度：$value';
  }

  @override
  String get displaySheetTitle => '画面設定';

  @override
  String get displaySheetPerformanceMode => '演奏モード';

  @override
  String get displaySheetPageBorder => 'ページの枠線';

  @override
  String displaySheetThickness(String value) {
    return '太さ：$value';
  }

  @override
  String get displaySheetColorLabel => '色';

  @override
  String get displaySheetCustomChip => 'カスタム';

  @override
  String get displaySheetShowStatusBar => 'ステータスバーを表示';

  @override
  String get displaySheetShowStatusBarHint => '演奏中も時計とバッテリー残量を表示したままにします';

  @override
  String get displaySheetAvoidNotches => 'ノッチを避ける';

  @override
  String get displaySheetAvoidNotchesHint => 'カメラノッチや角の丸みにページがかからないようにします';

  @override
  String get jumpLinkEditSheetAddTitle => 'ジャンプリンクを追加';

  @override
  String get jumpLinkEditSheetEditTitle => 'ジャンプリンクを編集';

  @override
  String jumpLinkEditSheetOriginLabel(int page) {
    return '$pageページ目から';
  }

  @override
  String jumpLinkEditSheetDestinationLabel(int page, int pageCount) {
    return '$pageページ目（全$pageCountページ）';
  }

  @override
  String get jumpLinkEditSheetColorLabel => '色';

  @override
  String get jumpLinkEditSheetSizeLabel => 'サイズ';

  @override
  String get jumpLinksSheetDragHint => '追加しました。リスト内でジャンプリンクをドラッグすると順番を変えられます。';

  @override
  String get jumpLinksSheetTitle => 'ジャンプリンク';

  @override
  String get jumpLinksSheetEmpty => 'ジャンプリンクがまだありません';

  @override
  String jumpLinksSheetRowTitle(int from, int to) {
    return '$fromページ → $toページ';
  }

  @override
  String get jumpLinksSheetRowSubtitle => 'タップするとこのリンク先に移動します';

  @override
  String labelSheetsTitle(String title) {
    return '$titleのラベル';
  }

  @override
  String get labelSheetsManage => '管理';

  @override
  String get labelSheetsCreateLabel => 'ラベルを作成';

  @override
  String get labelSheetsNewLabel => '新しいラベル';

  @override
  String get labelSheetsManageTitle => 'ラベルを管理';

  @override
  String get labelSheetsNoLabelsYet => 'ラベルがまだありません';

  @override
  String labelSheetsUsageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '曲',
      one: '曲',
    );
    return '$count$_temp0で使用中';
  }

  @override
  String get labelSheetsDeleteTitle => 'ラベルを削除しますか？';

  @override
  String labelSheetsDeleteConfirm(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String labelSheetsDeleteConfirmWithUsage(String name, int usage) {
    String _temp0 = intl.Intl.pluralLogic(
      usage,
      locale: localeName,
      other: '曲',
      one: '曲',
    );
    return '「$name」は$usage$_temp0で使用されています。それでも削除しますか？';
  }

  @override
  String get labelSheetsRenameLabelTitle => 'ラベル名を変更';

  @override
  String get labelSheetsNameHint => 'ラベル名';

  @override
  String get libraryFilterSheetTitle => 'フィルター';

  @override
  String get libraryFilterSheetModeAny => 'いずれか';

  @override
  String get libraryFilterSheetModeAll => 'すべて';

  @override
  String get libraryFilterSheetModeUntagged => 'ラベルなし';

  @override
  String get libraryFilterSheetUntaggedHint => 'ラベルが付いていない楽譜';

  @override
  String get libraryFilterSheetEmptyLabels => '絞り込めるラベルがまだありません';
}
