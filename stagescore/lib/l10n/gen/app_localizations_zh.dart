// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get actionCancel => '取消';

  @override
  String get actionSave => '保存';

  @override
  String get actionDone => '完成';

  @override
  String get actionDelete => '删除';

  @override
  String get actionOk => '好';

  @override
  String get actionClear => '清除';

  @override
  String get actionApply => '应用';

  @override
  String get actionAdd => '添加';

  @override
  String get actionEdit => '编辑';

  @override
  String get actionRename => '重命名';

  @override
  String get actionBack => '返回';

  @override
  String get actionMore => '更多';

  @override
  String get actionGo => '前往';

  @override
  String get actionUndo => '撤销';

  @override
  String get actionContinue => '继续';

  @override
  String get actionReset => '重置';

  @override
  String get commonOr => '或';

  @override
  String get commonTitleLabel => '标题';

  @override
  String get themeModeSystem => '系统';

  @override
  String get themeModeLight => '浅色';

  @override
  String get themeModeDark => '深色';

  @override
  String get pdfLayoutModeAuto => '自动';

  @override
  String get pdfLayoutModeSingle => '单页';

  @override
  String get pdfLayoutModeTwoPages => '双页';

  @override
  String get pdfLayoutModeScroll => '滚动';

  @override
  String get pdfLayoutModeScrollSideways => '滚动（横向）';

  @override
  String get pdfLayoutModeHalfPageTopBottom => '单页 + 预览';

  @override
  String get pdfLayoutModeHalfPageLeftRight => '单页 + 侧向预览';

  @override
  String get pageColorFilterOff => '关闭';

  @override
  String get pageColorFilterSepia => '怀旧棕';

  @override
  String get pageColorFilterGreen => '护眼绿';

  @override
  String get pageColorFilterInvert => '反色';

  @override
  String get pageScaleScopeFixed => '固定';

  @override
  String get pageScaleScopePerScore => '按 Score';

  @override
  String get pageScaleScopePerPage => '按页';

  @override
  String get stagePresetSetUpToPlay => '切换到演奏';

  @override
  String get stagePresetSetUpToPractise => '切换到练习';

  @override
  String get stagePresetChromeHidden => '已隐藏界面';

  @override
  String get stagePresetChromeShown => '已显示界面';

  @override
  String get stagePresetStatusBarShown => '已显示状态栏';

  @override
  String get stagePresetStatusBarHidden => '已隐藏状态栏';

  @override
  String get stagePresetScaleKept => '保留缩放';

  @override
  String get stagePresetPinchFree => '已禁用双指缩放';

  @override
  String get relativeDayToday => '今天';

  @override
  String get relativeDayYesterday => '昨天';

  @override
  String relativeDayDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '天',
      one: '天',
    );
    return '$days $_temp0前';
  }

  @override
  String pageOrderEditorEntryBlank(int index) {
    return '$index. 空白页';
  }

  @override
  String pageOrderEditorEntryPdfPage(int index, int sourcePage) {
    return '$index. PDF 第 $sourcePage 页';
  }

  @override
  String get pageOrderEditorResetTitle => '重置为原始顺序？';

  @override
  String get pageOrderEditorResetBody => '恢复 PDF 原始的 Page order，并移除空白页与重复页？';

  @override
  String get pageOrderEditorReset => '重置';

  @override
  String get pageOrderEditorAppBarTitle => 'Page order';

  @override
  String get pageOrderEditorNoPages => '暂无页面';

  @override
  String get pageOrderEditorDuplicate => '复制';

  @override
  String get pageOrderEditorInsertBlank => '插入空白页';

  @override
  String get pageOrderEditorRemove => '移除';

  @override
  String get librarySortTitle => '标题';

  @override
  String get librarySortCreated => '创建时间';

  @override
  String get librarySortLastViewed => '最近查看';

  @override
  String scoreOriginPage(int page) {
    return '第 $page 页';
  }

  @override
  String scoreOriginPages(int first, int last) {
    return '第 $first–$last 页';
  }

  @override
  String scoreOriginPagesOfBook(String pages, String name) {
    return '$name 的 $pages';
  }

  @override
  String libraryVisibilityInBook(String title) {
    return '在 $title 中';
  }

  @override
  String get libraryVisibilityInBookFallback => '在书中';

  @override
  String get libraryBackupFileNotFound => '未找到备份文件。';

  @override
  String get libraryBackupFailedGeneric => '备份失败。';

  @override
  String libraryBackupCreateFailed(String error) {
    return '无法创建备份：$error';
  }

  @override
  String libraryBackupRestoreFailed(String error) {
    return '无法恢复备份：$error';
  }

  @override
  String get libraryBackupMissingMarker => '不是 StageScore 备份（缺少标记）。';

  @override
  String get libraryBackupUnknownFormat => '不是 StageScore 备份（格式未知）。';

  @override
  String get libraryBackupUnsupportedVersion => '不支持的 StageScore 备份版本。';

  @override
  String get libraryBackupCorruptMarker => '不是 StageScore 备份（标记已损坏）。';

  @override
  String get gestureMapLongPress => '长按';

  @override
  String get gestureMapTapTopEdge => '点按顶部边缘';

  @override
  String get gestureMapTapBottomEdge => '点按底部边缘';

  @override
  String get gestureMapEmptyHint => '设置一个手势为「显示菜单 / 界面」，以便重新唤出它。';

  @override
  String gestureMapRevealHint(String joined) {
    return '演奏时隐藏工具栏和翻页栏。要重新唤出它们，请$joined。';
  }

  @override
  String get layoutNavigationPedalOrPageBar => '踏板或翻页栏';

  @override
  String get layoutNavigationTapLeftRight => '点按左侧 / 右侧';

  @override
  String get layoutNavigationTapTopBottom => '点按上方 / 下方';

  @override
  String get layoutNavigationTapAnywhere => '点按任意位置';

  @override
  String get layoutNavigationTapAnywhereBack => '点按任意位置返回';

  @override
  String get layoutNavigationSwipe => '滑动';

  @override
  String get layoutNavigationSwipeSideways => '左右滑动';

  @override
  String get layoutNavigationSwipeUpDown => '上下滑动';

  @override
  String get scoreMenuSheetTitle => '菜单';

  @override
  String get appearanceSheetTitle => '外观';

  @override
  String get appearanceSheetMode => '模式';

  @override
  String get appearanceSheetThemeColor => '主题颜色';

  @override
  String get appearanceSheetCustomChip => '自定义';

  @override
  String get appearanceSheetCustomColorDialog => '自定义颜色';

  @override
  String get appearanceSheetHue => '色相';

  @override
  String get appearanceSheetSat => '饱和度';

  @override
  String get appearanceSheetVal => '明度';

  @override
  String get scoreMenuGoTo => '跳转到';

  @override
  String get scoreMenuBookmarks => 'Bookmark';

  @override
  String get scoreMenuJumpLinks => 'Jump Link';

  @override
  String get scoreMenuPageOrder => 'Page order…';

  @override
  String get scoreMenuGoToMeasure => '跳转到小节…';

  @override
  String get scoreMenuMeasureMap => 'Measure map…';

  @override
  String get scoreMenuMarks => '标注';

  @override
  String get scoreMenuHideAnnotations => '隐藏标注';

  @override
  String get scoreMenuShowAnnotations => '显示标注';

  @override
  String get scoreMenuExporting => '正在导出…';

  @override
  String get scoreMenuExportAnnotated => '导出带标注的 PDF';

  @override
  String get scoreMenuView => '查看';

  @override
  String get scoreMenuLayout => '布局';

  @override
  String get scoreMenuDisplay => '显示…';

  @override
  String get scoreMenuColorFilter => '颜色滤镜…';

  @override
  String get scoreMenuPageScale => '页面缩放…';

  @override
  String get scoreMenuLocked => '已锁定';

  @override
  String get scoreMenuPlaying => '播放中';

  @override
  String get scoreMenuMetronomeRunning => '节拍器（运行中）…';

  @override
  String get scoreMenuMetronome => '节拍器…';

  @override
  String get scoreMenuShowPlaybackControls => 'Show Playback controls';

  @override
  String get scoreMenuHidePlaybackControls => 'Hide Playback controls';

  @override
  String get scoreMenuPlaybackMapFirst => 'Map measures first';

  @override
  String get scoreMenuPageTurnSettings => 'Page turn 设置';

  @override
  String get playbackControlsPlay => 'Play';

  @override
  String get playbackControlsPause => 'Pause';

  @override
  String get playbackControlsStop => 'Stop';

  @override
  String playbackControlsCountInBadge(int count) {
    return 'Count-in $count';
  }

  @override
  String get playbackControlsCountInLabel => 'Count-in';

  @override
  String get playbackMapLostSnackbar => 'MeasureMap changed — playback stopped';

  @override
  String scoreMenuLayoutValueBoth(String stored, String resolved) {
    return '$stored · $resolved';
  }

  @override
  String get languageSheetTitle => '语言';

  @override
  String get languageSheetSystem => '系统';

  @override
  String get languageSheetSystemSubtitle => '跟随设备语言';

  @override
  String get stampSheetTitle => 'Stamp';

  @override
  String get stampBox => '方框';

  @override
  String get stampCircle => '圆形';

  @override
  String get stampArrow => '箭头';

  @override
  String get stampText => '文字';

  @override
  String get pageScaleSheetTitle => '页面缩放';

  @override
  String get pageScaleSheetExplainer =>
      '乐谱显示的大小，会在多次使用之间被记住。双指缩放只是临时改变视图，这里的设置才会永久生效。';

  @override
  String pageScaleSheetCurrent(String value) {
    return '当前页面：$value×';
  }

  @override
  String get pageScaleSheetAppliesTo => '应用范围';

  @override
  String get pageScaleSheetScale => '缩放';

  @override
  String pageScaleSheetScaleValue(String value) {
    return '$value×';
  }

  @override
  String get pageScaleSheetKeepScale => '保持此缩放';

  @override
  String get pageScaleSheetKeepScaleSubtitle => '已关闭双指缩放，演奏中不慎触碰也不会移动乐谱';

  @override
  String get pageScaleSheetHintFixed => '适用于所有 Score，除非某个 Score 单独设置了缩放';

  @override
  String get pageScaleSheetHintPerScore => '仅适用于此 Score 的所有页面';

  @override
  String get pageScaleSheetHintPerPage => '仅适用于此页 —— 内容密集的页面可以单独放大，不影响其他页面';

  @override
  String get layoutSettingsSheetTitle => '布局';

  @override
  String get layoutSettingsSheetPageTurnSettings => 'Page turn 设置';

  @override
  String get layoutSettingsSheetPageTurnSettingsSubtitle => '点按区域、滑动、踏板、动画';

  @override
  String get layoutSettingsSheetFallsBack => '此屏幕仅显示单页 —— 旋转设备可显示对页';

  @override
  String layoutSettingsSheetNow(String mode) {
    return '当前：$mode';
  }

  @override
  String get layoutSettingsSheetFitsScreen => '适配此屏幕';

  @override
  String get pageTurnSettingsSheetGestureWarning => '请至少保留一个手势设为「显示菜单 / 界面」。';

  @override
  String get pageTurnSettingsSheetTitle => 'Page turn';

  @override
  String get pageTurnSettingsSheetTapZones => '点按区域';

  @override
  String pageTurnSettingsSheetTapZonesHint(
    String layoutMode,
    String navigationHint,
  ) {
    return '在$layoutMode中：$navigationHint。';
  }

  @override
  String get pageTurnSettingsSheetSwipe => '滑动';

  @override
  String get pageTurnSettingsSheetMatchLayout => '匹配布局';

  @override
  String get pageTurnSettingsSheetMatchLayoutSubtitle => '沿页面翻动的方向滑动';

  @override
  String get pageTurnSettingsSheetSwipeLeftNext => '左滑 → 下一页';

  @override
  String get pageTurnSettingsSheetSwipeRightPrevious => '右滑 → 上一页';

  @override
  String get pageTurnSettingsSheetSwipeUpNext => '上滑 → 下一页';

  @override
  String get pageTurnSettingsSheetSwipeDownPrevious => '下滑 → 上一页';

  @override
  String get pageTurnSettingsSheetReverseDirection => '反转翻页方向';

  @override
  String get pageTurnSettingsSheetReverseDirectionSubtitle => '适用于翻页方向相反的乐谱';

  @override
  String get pageTurnSettingsSheetTurnAmount => 'Turn amount';

  @override
  String get pageTurnSettingsSheetTurnAmountHintTwoPage =>
      '选择「半页」时，一次只翻动对页中的一页，而不是整组两页。';

  @override
  String get pageTurnSettingsSheetTurnAmountHintDefault =>
      '选择「半页」时，一次只翻动约半屏，而不是整屏。';

  @override
  String get pageTurnSettingsSheetAnimation => '动画';

  @override
  String get pageTurnSettingsSheetPageTurnDelay => '翻页延迟';

  @override
  String get pageTurnSettingsSheetApplyTo => '应用范围';

  @override
  String get pageTurnSettingsSheetGestures => '手势';

  @override
  String get pageTurnSettingsSheetGesturesHint =>
      '边缘点按是顶部和底部的细长区域 —— 与「上 / 下翻页区域」不同。必须至少保留一个手势设为「显示菜单 / 界面」；该手势也用于在 Performance mode 下唤出工具栏。绘制功能只能从工具栏进入，无法通过手势触发。';

  @override
  String get pageTurnSettingsSheetLongPress => '长按';

  @override
  String get pageTurnSettingsSheetTopEdge => '顶部边缘';

  @override
  String get pageTurnSettingsSheetBottomEdge => '底部边缘';

  @override
  String get pageTurnSettingsSheetPedalKeyboard => '踏板 / 键盘';

  @override
  String get pageTurnSettingsSheetPedalKeyboardHint =>
      '支持发送键盘按键的蓝牙踏板：\n上一页 — PageUp、←、↑、空格\n下一页 — PageDown、→、↓、Enter';

  @override
  String get pageTurnAnimationOff => '关闭';

  @override
  String get pageTurnAnimationFast => '快';

  @override
  String get pageTurnAnimationNormal => '正常';

  @override
  String get pageTurnAnimationSlow => '慢';

  @override
  String get pageTurnDelayOff => '关闭';

  @override
  String get pageTurnDelay300ms => '0.3 秒';

  @override
  String get pageTurnDelay500ms => '0.5 秒';

  @override
  String get pageTurnDelay1000ms => '1.0 秒';

  @override
  String get pageTurnDelayScopeAll => '全部';

  @override
  String get pageTurnDelayScopePedalOnly => '仅踏板与键盘';

  @override
  String get pageTurnTapModeMatchLayout => '匹配布局';

  @override
  String get pageTurnTapModeLeftRight => '左 / 右';

  @override
  String get pageTurnTapModeTopBottom => '上 / 下';

  @override
  String get pageTurnTapModePrevious => '任意位置 → 上一页';

  @override
  String get pageTurnTapModeNext => '任意位置 → 下一页';

  @override
  String get pageTurnTapModeDisabled => '禁用';

  @override
  String get turnAmountFull => '整页';

  @override
  String get turnAmountHalf => '半页';

  @override
  String get gestureMapActionShowChrome => '显示菜单 / 界面';

  @override
  String get gestureMapActionDisabled => '关闭';

  @override
  String get drawToolbarColorLabel => '颜色';

  @override
  String get drawToolbarSizeLabel => '大小';

  @override
  String get drawToolbarUndo => '撤销';

  @override
  String get drawToolbarRedo => '重做';

  @override
  String get drawToolbarDelete => '删除';

  @override
  String get drawToolbarStamp => 'Stamp';

  @override
  String get drawToolbarPlace => '放置';

  @override
  String get drawToolbarMore => '更多';

  @override
  String get drawToolbarTextStampTitle => '文字 Stamp';

  @override
  String get drawToolbarTextStampHint => '简短文字';

  @override
  String get drawToolbarDrawOptionsTitle => '绘制选项';

  @override
  String get drawToolbarTool => '工具';

  @override
  String get drawToolbarWidth => '粗细';

  @override
  String get drawToolbarStraightLine => '直线';

  @override
  String get drawToolPen => '钢笔';

  @override
  String get drawToolMarker => '马克笔';

  @override
  String get drawToolEraser => '橡皮擦';

  @override
  String get drawToolEyedropper => '取色器';

  @override
  String get drawWidthThin => '细';

  @override
  String get drawWidthMedium => '中';

  @override
  String get drawWidthThick => '粗';

  @override
  String get pdfModeScreenTapHint => '点按右半屏翻到下一页，左半屏翻到上一页。';

  @override
  String get pdfModeScreenColorFilterTitle => '颜色滤镜';

  @override
  String get scoreMenuQuickBarBookmarks => 'Bookmark';

  @override
  String get scoreMenuQuickBarDraw => '绘制';

  @override
  String get scoreMenuQuickBarExitDraw => '退出绘制';

  @override
  String get scoreMenuQuickBarMetronome => '节拍器';

  @override
  String get scoreMenuQuickBarMetronomeRunning => '节拍器（运行中）';

  @override
  String get pdfModeScreenExporting => '正在导出 PDF…';

  @override
  String get pdfModeScreenExportReady => '导出完成 —— 已打开分享面板';

  @override
  String pdfModeScreenExportRestartHint(String path) {
    return '已导出到 $path。请完全重启应用（stop + flutter run）以启用分享面板。';
  }

  @override
  String pdfModeScreenExportFailed(String error) {
    return '导出失败：$error';
  }

  @override
  String pdfModeScreenPieceIndex(int index) {
    return '$index.';
  }

  @override
  String get pdfModeScreenHidePieceNotes => '隐藏曲目备注';

  @override
  String get pdfModeScreenShowPieceNotes => '显示曲目备注';

  @override
  String get pdfModeScreenPieceNotes => '曲目备注';

  @override
  String get libraryScreenSort => '排序';

  @override
  String get libraryScreenFilter => '筛选';

  @override
  String get libraryScreenManageLabels => '管理 Label';

  @override
  String get libraryScreenMore => '更多';

  @override
  String get libraryScreenAppearance => '外观…';

  @override
  String get libraryScreenLanguage => '语言…';

  @override
  String get libraryScreenBackup => '备份…';

  @override
  String get libraryScreenRestore => '恢复…';

  @override
  String libraryScreenAbout(String productName) {
    return '关于 $productName…';
  }

  @override
  String libraryScreenSplitIntoPiecesSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '首曲目',
      one: '首曲目',
    );
    return '已拆分为 $count $_temp0';
  }

  @override
  String get libraryScreenStillReadingPdf => '仍在读取此 PDF —— 请稍后重试。';

  @override
  String get libraryScreenEditPiecesAppBarTitle => '编辑曲目';

  @override
  String libraryScreenUpdatedPieces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '首曲目',
      one: '首曲目',
    );
    return '已更新为 $count $_temp0。';
  }

  @override
  String get libraryScreenEditPiecesDialogTitle => '移除曲目数据？';

  @override
  String libraryScreenEditPiecesBody(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '其',
      one: '其',
    );
    return '$names 将被移除，连同$_temp0标注、Bookmark、Jump Link、Label 以及所属的 Setlist。';
  }

  @override
  String get libraryScreenSplitIntoPiecesDialogTitle => '拆分为多首曲目？';

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
      other: '页',
      one: '页',
    );
    return '将「$title」缩小到第 $firstPage–$lastPage 页后，将从其 Page order 中移除 $dropping $_temp0。';
  }

  @override
  String get libraryScreenSplitConfirm => '拆分';

  @override
  String get libraryScreenChangePagesTitle => '更改页面范围？';

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
      other: '页',
      one: '页',
    );
    return '将「$title」更改为第 $firstPage–$lastPage 页后，将从其 Page order 中移除 $dropping $_temp0。';
  }

  @override
  String get libraryScreenChangePagesConfirm => '更改';

  @override
  String get libraryScreenSetlistEmptyAddScores => '请先向此 Setlist 添加 Score。';

  @override
  String get libraryScreenNoScoresAvailable => '此 Setlist 中的 Score 均未找到。';

  @override
  String libraryScreenSkippedMissingScores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Score',
      one: 'Score',
    );
    return '已跳过 $count 个缺失的 $_temp0。';
  }

  @override
  String get libraryScreenNewSetlist => '新建 Setlist';

  @override
  String get libraryScreenDeleteSetlistTitle => '删除 Setlist？';

  @override
  String libraryScreenDeleteSetlistBody(String title) {
    return '删除「$title」？其中的 Score 不会受影响。';
  }

  @override
  String libraryScreenDeleteScoreBody(String title) {
    return '删除「$title」？此操作无法撤销。';
  }

  @override
  String libraryScreenDeleteScoreWithPiecesBody(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '首曲目',
      one: '首曲目',
    );
    return '删除「$title」及其 $count $_temp0？此操作无法撤销。';
  }

  @override
  String get libraryScreenDeleteScoreTitle => '删除 Score？';

  @override
  String get libraryScreenTabScores => 'Score';

  @override
  String get libraryScreenTabSetlists => 'Setlist';

  @override
  String get libraryScreenSearchHint => '搜索 Score';

  @override
  String get libraryScreenAddPdf => '添加 PDF';

  @override
  String libraryScreenSplitSuggestionWithPages(String name, int pages) {
    return '「$name」（$pages 页）看起来可能包含多首曲目。';
  }

  @override
  String libraryScreenSplitSuggestionGeneric(String name) {
    return '「$name」看起来可能包含多首曲目。';
  }

  @override
  String get libraryScreenNotNow => '暂不';

  @override
  String get libraryScreenSplitEllipsis => '拆分…';

  @override
  String libraryScreenFailedToOpen(String error) {
    return '无法打开曲库：$error';
  }

  @override
  String get libraryScreenNoScoresYet => '暂无 Score';

  @override
  String get libraryScreenImportPdfHint => '导入一个 PDF 即可开始。';

  @override
  String get libraryScreenAddSampleScore => '添加示例 Score';

  @override
  String libraryScreenNoScoresMatchSearch(String query) {
    return '没有与「$query」匹配的 Score。';
  }

  @override
  String libraryScreenNoScoresMatchFilter(String filter) {
    return '没有与 $filter 匹配的 Score。';
  }

  @override
  String get libraryScreenClearSearch => '清除搜索';

  @override
  String get libraryScreenClearFilter => '清除筛选';

  @override
  String libraryScreenRecencyWithPieces(String when, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '首曲目',
      one: '首曲目',
    );
    return '$when · $count $_temp0';
  }

  @override
  String get libraryScreenPiecesEllipsis => '曲目…';

  @override
  String get libraryScreenEditPiecesMenuItem => '编辑曲目…';

  @override
  String get libraryScreenOpenFullScore => '打开完整 Score';

  @override
  String get libraryScreenRenameEllipsis => '重命名…';

  @override
  String get libraryScreenLabelsEllipsis => 'Label…';

  @override
  String get libraryScreenSplitIntoPiecesEllipsis => '拆分为曲目…';

  @override
  String get libraryScreenPagesEllipsis => '页面…';

  @override
  String get libraryScreenReplacePdfEllipsis => '替换 PDF…';

  @override
  String get libraryScreenDeleteEllipsis => '删除…';

  @override
  String libraryScreenAddedRelative(String when) {
    return '$when添加';
  }

  @override
  String libraryScreenOpenedRelative(String when) {
    return '$when打开';
  }

  @override
  String libraryScreenRecencyWithPages(String when, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '页',
      one: '页',
    );
    return '$when · $pages $_temp0';
  }

  @override
  String get libraryScreenNoSetlistsYet => '暂无 Setlist';

  @override
  String get libraryScreenSetlistsEmptyHint => '将多个 Score 编成一组，连续演奏而无需逐个重新打开。';

  @override
  String libraryScreenSetlistScoreCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Score',
      one: 'Score',
    );
    return '$count 个 $_temp0';
  }

  @override
  String get libraryScreenSetlistCountEmpty => '空';

  @override
  String libraryScreenSetlistScoreCountOpened(
    String scoreCount,
    String opened,
  ) {
    return '$scoreCount · $opened';
  }

  @override
  String get metronomeSheetTitle => '节拍器';

  @override
  String get metronomeSheetTempo => '速度';

  @override
  String get metronomeSheetMeter => '拍号';

  @override
  String get metronomeSheetMeterHint => '每小节内拍子的分组方式';

  @override
  String get metronomeSheetEqual => '均等';

  @override
  String get metronomeSheetMute => '静音';

  @override
  String get metronomeSheetShowBeats => '显示节拍';

  @override
  String get metronomeSheetShowBeatsHint => '播放时在 Score 上闪烁提示节拍';

  @override
  String get metronomeSheetCountIn => 'Count-in';

  @override
  String get metronomeSheetCountInHint =>
      'Click measures before Play from the start (not after Pause)';

  @override
  String get metronomeSheetCountInNone => 'Off';

  @override
  String get metronomeSheetCountInOne => '1';

  @override
  String get metronomeSheetCountInTwo => '2';

  @override
  String metronomeSheetVolume(int percent) {
    return '音量：$percent%';
  }

  @override
  String get metronomeSheetStop => '停止';

  @override
  String get metronomeSheetStart => '开始';

  @override
  String get metronomeSheetEnterNumber => '请输入数字';

  @override
  String get metronomeSheetTempoDialogTitle => '设置速度';

  @override
  String get pageExtentScreenTitle => '页面';

  @override
  String pageExtentScreenFirstPage(int page) {
    return '首页：第 $page 页';
  }

  @override
  String pageExtentScreenLastPage(int page) {
    return '末页：第 $page 页';
  }

  @override
  String get pageExtentScreenNoPages => '暂无页面';

  @override
  String get pageExtentScreenBadgeOnly => '唯一';

  @override
  String get pageExtentScreenBadgeFirst => '首页';

  @override
  String get pageExtentScreenBadgeLast => '末页';

  @override
  String pageExtentScreenSummary(String title, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '页',
      one: '页',
    );
    return '$title —— $pages $_temp0';
  }

  @override
  String get pageExtentScreenHint => '点按下方页面以设置所选边界。';

  @override
  String get pageNavBarPreviousPageTooltip => '上一页';

  @override
  String get pageNavBarNextPageTooltip => '下一页';

  @override
  String pageNavBarJumpedSnackbar(int page, int count) {
    return '已跳转到第 $page / $count 页';
  }

  @override
  String get pageNavBarGoToPageTitle => '跳转到指定页';

  @override
  String pageNavBarPageFieldLabel(int count) {
    return '页码（1–$count）';
  }

  @override
  String get piecesScreenEditPieces => '编辑曲目…';

  @override
  String get piecesScreenNoPieces => '暂无曲目';

  @override
  String get piecesScreenRename => '重命名…';

  @override
  String get piecesScreenLabels => 'Label…';

  @override
  String get piecesScreenSplitIntoPieces => '拆分为曲目…';

  @override
  String get piecesScreenPages => '页面…';

  @override
  String get piecesScreenReplacePdf => '替换 PDF…';

  @override
  String get piecesScreenDelete => '删除…';

  @override
  String piecesScreenAdded(String when) {
    return '$when添加';
  }

  @override
  String piecesScreenOpened(String when) {
    return '$when打开';
  }

  @override
  String piecesScreenRecencyWithPages(String when, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '页',
      one: '页',
    );
    return '$when · $pages $_temp0';
  }

  @override
  String piecesScreenPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '首曲目',
      one: '首曲目',
    );
    return '$count $_temp0';
  }

  @override
  String piecesScreenPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '页',
      one: '页',
    );
    return '$count $_temp0';
  }

  @override
  String get piecesScreenOpenFullScore => '打开完整 Score';

  @override
  String get setlistEditorImportFirst => '请先导入一个 Score。';

  @override
  String get setlistEditorDefaultTitle => '新建 Setlist';

  @override
  String get setlistEditorAppBarTitle => '编辑 Setlist';

  @override
  String get setlistEditorAddScores => '添加 Score';

  @override
  String get setlistEditorTitleFieldLabel => '标题';

  @override
  String get setlistEditorEmpty => '暂无 Score。点按「添加 Score」来创建这个 Setlist。';

  @override
  String get setlistEditorMissingScore => '缺失的 Score';

  @override
  String get setlistEditorRemovedFromLibrary => '已从曲库中移除';

  @override
  String get setlistEditorRemoveTooltip => '移除';

  @override
  String setlistEditorAddCount(int count) {
    return '添加（$count）';
  }

  @override
  String setlistEditorPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '首曲目',
      one: '首曲目',
    );
    return '$count $_temp0';
  }

  @override
  String get setlistEditorPiecesTooltip => '查看曲目';

  @override
  String get splitScoreScreenRenameTitle => '重命名';

  @override
  String get splitScoreScreenTitle => '拆分为曲目';

  @override
  String get splitScoreScreenClearMarks => '清除标记';

  @override
  String get splitScoreScreenNoPages => '暂无页面';

  @override
  String splitScoreScreenPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 首曲目',
      one: '1 首曲目',
      zero: '暂无曲目',
    );
    return '$_temp0';
  }

  @override
  String get splitScoreScreenHint => '点按页面以标记新曲目的起始位置。长按已标记的页面可重命名。';

  @override
  String splitScoreScreenFrontMatterPage(int page) {
    return '第 $page 页是前置页面，不属于任何曲目。';
  }

  @override
  String splitScoreScreenFrontMatterPages(int first, int last) {
    return '第 $first–$last 页是前置页面，不属于任何曲目。';
  }

  @override
  String splitScoreScreenUseContents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '项',
      one: '项',
    );
    return '使用目录（$count $_temp0）';
  }

  @override
  String get libraryScreenNoPdfFiles => '未找到 PDF 文件。';

  @override
  String libraryScreenImportedScores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Score',
      one: 'Score',
    );
    return '已导入 $count 个 $_temp0';
  }

  @override
  String get libraryScreenCreateBackupTitle => '创建备份？';

  @override
  String get libraryScreenCreateBackupBody =>
      '这会将你的整个曲库 —— Score、Label、Setlist 和设置 —— 保存为一个可分享或妥善保存的 zip 文件副本。';

  @override
  String get libraryScreenCreateBackupConfirm => '创建备份';

  @override
  String get libraryScreenCreatingBackup => '正在创建备份…';

  @override
  String get libraryScreenBackupShareSubject => 'StageScore 备份';

  @override
  String libraryScreenBackupSaved(String path) {
    return '备份已保存到 $path';
  }

  @override
  String get libraryScreenBackupReady => '备份已完成 —— 已打开分享面板';

  @override
  String libraryScreenBackupFailed(String error) {
    return '无法创建备份：$error';
  }

  @override
  String get libraryScreenRestoreBackupTitle => '恢复备份？';

  @override
  String get libraryScreenRestoreBackupBody =>
      '这会用备份内容替换你的整个曲库 —— Score、Label、Setlist 和设置。此操作无法撤销。';

  @override
  String get libraryScreenReplaceAll => '全部替换';

  @override
  String get libraryScreenRestoringBackup => '正在恢复备份…';

  @override
  String get libraryScreenLibraryRestored => '曲库已恢复';

  @override
  String libraryScreenRestoreFailed(String error) {
    return '无法恢复备份：$error';
  }

  @override
  String libraryScreenPercentValue(int percent) {
    return '$percent%';
  }

  @override
  String get libraryScreenUntagged => '无 Label';

  @override
  String get libraryScreenThisFilter => '此筛选条件';

  @override
  String get libraryScreenAndConjunction => '和';

  @override
  String get libraryScreenAllOf => '全部';

  @override
  String libraryScreenRemoveFilterChip(String label) {
    return '移除 $label 筛选';
  }

  @override
  String get libraryScreenRenameScoreTitle => '重命名 Score';

  @override
  String get libraryScreenReplacePdfTitle => '替换 PDF？';

  @override
  String libraryScreenReplacePdfBodyShared(
    int sharing,
    String title,
    int others,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '首曲目',
      one: '首曲目',
    );
    return '此 PDF 由 $sharing 首曲目共用，包括「$title」。替换它也会同时更改其他 $others $_temp0。';
  }

  @override
  String libraryScreenReplacePdfBodySingle(String title) {
    return '替换「$title」背后的 PDF？你可以在下方选择保留或重置其标注。';
  }

  @override
  String get libraryScreenKeepOverlays => '保留标注';

  @override
  String get libraryScreenResetOverlays => '重置标注';

  @override
  String get libraryScreenOverlaysReset => '标注已重置。';

  @override
  String get libraryScreenOverlaysKept => '标注已保留。';

  @override
  String libraryScreenPdfReplaced(String overlayNote) {
    return 'PDF 已替换。$overlayNote';
  }

  @override
  String libraryScreenPdfReplacedShortened(String overlayNote, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '条页面记录',
      one: '条页面记录',
    );
    return 'PDF 已替换。$overlayNote新文件页数更少，已移除 $count $_temp0。';
  }

  @override
  String libraryScreenReplaceFailed(String error) {
    return '无法替换 PDF：$error';
  }

  @override
  String continuousPageOrderViewOpenFailed(String error) {
    return '无法打开 PDF：$error';
  }

  @override
  String get performancePageSlotBlank => '空白页';

  @override
  String performancePageSlotMissingPage(int page) {
    return '缺失第 $page 页';
  }

  @override
  String singlePageSliderOpenFailed(String error) {
    return '无法打开 PDF：$error';
  }

  @override
  String aboutSheetVersion(String version) {
    return '版本 $version';
  }

  @override
  String aboutSheetVersionWithBuild(String version, String build) {
    return '版本 $version（$build）';
  }

  @override
  String aboutSheetLinkOpenFailed(String url) {
    return '无法打开链接：$url';
  }

  @override
  String aboutSheetTitle(String productName) {
    return '关于 $productName';
  }

  @override
  String get aboutSheetWebsiteLabel => '网站';

  @override
  String get aboutSheetPrivacyLabel => '隐私政策';

  @override
  String get aboutSheetSupportLabel => '支持';

  @override
  String get bookmarksSheetAddTitle => '添加 Bookmark';

  @override
  String bookmarksSheetPageLabel(int page) {
    return '第 $page 页';
  }

  @override
  String get bookmarksSheetRenameTitle => '重命名 Bookmark';

  @override
  String get bookmarksSheetTitle => 'Bookmark';

  @override
  String get bookmarksSheetEmpty => '暂无 Bookmark';

  @override
  String get displaySheetBorderColorTitle => '边框颜色';

  @override
  String displaySheetHue(int value) {
    return '色相：$value';
  }

  @override
  String displaySheetSaturation(int value) {
    return '饱和度：$value';
  }

  @override
  String displaySheetColorValue(int value) {
    return '明度：$value';
  }

  @override
  String get displaySheetTitle => '显示';

  @override
  String get displaySheetPerformanceMode => 'Performance mode';

  @override
  String get displaySheetPageBorder => '页面边框';

  @override
  String displaySheetThickness(String value) {
    return '粗细：$value';
  }

  @override
  String get displaySheetColorLabel => '颜色';

  @override
  String get displaySheetCustomChip => '自定义';

  @override
  String get displaySheetShowStatusBar => '显示状态栏';

  @override
  String get displaySheetShowStatusBarHint => '演奏时保持时钟和电量可见';

  @override
  String get displaySheetAvoidNotches => '避开刘海 / 挖孔';

  @override
  String get displaySheetAvoidNotchesHint => '使页面内容避开摄像头刘海和圆角区域';

  @override
  String get jumpLinkEditSheetAddTitle => '添加 Jump Link';

  @override
  String get jumpLinkEditSheetEditTitle => '编辑 Jump Link';

  @override
  String jumpLinkEditSheetOriginLabel(int page) {
    return '从第 $page 页';
  }

  @override
  String jumpLinkEditSheetDestinationLabel(int page, int pageCount) {
    return '到第 $page / $pageCount 页';
  }

  @override
  String get jumpLinkEditSheetColorLabel => '颜色';

  @override
  String get jumpLinkEditSheetSizeLabel => '大小';

  @override
  String get jumpLinksSheetDragHint => '已添加。在列表中拖动 Jump Link 可调整顺序。';

  @override
  String get jumpLinksSheetTitle => 'Jump Link';

  @override
  String get jumpLinksSheetEmpty => '暂无 Jump Link';

  @override
  String jumpLinksSheetRowTitle(int from, int to) {
    return '第 $from 页 → 第 $to 页';
  }

  @override
  String get jumpLinksSheetRowSubtitle => '点按以跳转到此 Jump Link';

  @override
  String labelSheetsTitle(String title) {
    return '「$title」的 Label';
  }

  @override
  String get labelSheetsManage => '管理';

  @override
  String get labelSheetsCreateLabel => '创建 Label';

  @override
  String get labelSheetsNewLabel => '新 Label';

  @override
  String get labelSheetsManageTitle => '管理 Label';

  @override
  String get labelSheetsNoLabelsYet => '暂无 Label';

  @override
  String labelSheetsUsageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Score',
      one: 'Score',
    );
    return '被 $count 个 $_temp0 使用';
  }

  @override
  String get labelSheetsDeleteTitle => '删除 Label？';

  @override
  String labelSheetsDeleteConfirm(String name) {
    return '删除「$name」？';
  }

  @override
  String labelSheetsDeleteConfirmWithUsage(String name, int usage) {
    String _temp0 = intl.Intl.pluralLogic(
      usage,
      locale: localeName,
      other: 'Score',
      one: 'Score',
    );
    return '「$name」正被 $usage 个 $_temp0 使用。仍要删除吗？';
  }

  @override
  String get labelSheetsRenameLabelTitle => '重命名 Label';

  @override
  String get labelSheetsNameHint => 'Label 名称';

  @override
  String get libraryFilterSheetTitle => '筛选';

  @override
  String get libraryFilterSheetModeAny => '任一';

  @override
  String get libraryFilterSheetModeAll => '全部';

  @override
  String get libraryFilterSheetModeUntagged => '无 Label';

  @override
  String get libraryFilterSheetUntaggedHint => '没有 Label 的 Score';

  @override
  String get libraryFilterSheetEmptyLabels => '暂无可用于筛选的 Label';

  @override
  String get measureMapMeasureCountTitle => '多少个 MeasureBox？';

  @override
  String get measureMapMeasureCountLabel => 'MeasureBoxes';

  @override
  String get measureMapGoToTitle => '跳转到小节';

  @override
  String get measureMapGoToLabel => '小节号';

  @override
  String measureMapGoToMissing(int number) {
    return '第 $number 小节尚未映射';
  }

  @override
  String get measureMapMetaTitle => '速度与拍号';

  @override
  String get measureMapTimeSignatureLabel => '拍号';

  @override
  String get measureMapTempoLabel => '速度';

  @override
  String get measureMapMetaScopeTitle => '应用于';

  @override
  String get measureMapScopeThisMeasure => '仅此小节';

  @override
  String get measureMapScopeThisSystem => '此 System';

  @override
  String get measureMapScopeThisPage => '本页';

  @override
  String get measureMapScopeRestOfScore => 'Score 剩余部分';

  @override
  String get measureMapScopeNextN => 'Next N…';

  @override
  String get measureMapMetaNextNLabel => '小节数';

  @override
  String get measureMapClearTitle => '清除 MeasureMap？';

  @override
  String get measureMapClearBody =>
      '删除此 Score 的所有 SystemBox 与 MeasureBox。无法撤销。';

  @override
  String get measureMapClearConfirm => '清除';

  @override
  String get measureMapDeleteSystemTitle => '删除 System？';

  @override
  String get measureMapDeleteSystemBody => '删除此 SystemBox 及其所有 MeasureBox。';

  @override
  String get measureMapCopyFromPageTitle => '从页面复制布局';

  @override
  String get measureMapCopyFromPageLabel => '源页面';

  @override
  String get measureMapCopyPrevious => '复制上一页';

  @override
  String get measureMapEmptyHint => '绘制一行 System — 应用会询问有多少小节';

  @override
  String get measureMapDone => '完成';

  @override
  String get measureMapEditBeats => 'Edit beats';

  @override
  String get measureMapSetMeasureCount => '设置小节数…';

  @override
  String get measureMapDeleteSystem => '删除 System';

  @override
  String get measureMapDeleteMeasure => '删除小节';

  @override
  String get measureMapEditMeta => '速度与拍号…';

  @override
  String get measureMapStartsAtBeat => 'Starts at beat';

  @override
  String get measureMapStartsAtBeatHint =>
      '1 = full measure; higher skips early beats (pickup on a wide box)';

  @override
  String get measureMapClearAll => '清除 MeasureMap…';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get actionCancel => '取消';

  @override
  String get actionSave => '儲存';

  @override
  String get actionDone => '完成';

  @override
  String get actionDelete => '刪除';

  @override
  String get actionOk => '好';

  @override
  String get actionClear => '清除';

  @override
  String get actionApply => '套用';

  @override
  String get actionAdd => '新增';

  @override
  String get actionEdit => '編輯';

  @override
  String get actionRename => '重新命名';

  @override
  String get actionBack => '返回';

  @override
  String get actionMore => '更多';

  @override
  String get actionGo => '前往';

  @override
  String get actionUndo => '復原';

  @override
  String get actionContinue => '繼續';

  @override
  String get actionReset => '重設';

  @override
  String get commonOr => '或';

  @override
  String get commonTitleLabel => '標題';

  @override
  String get themeModeSystem => '系統';

  @override
  String get themeModeLight => '淺色';

  @override
  String get themeModeDark => '深色';

  @override
  String get pdfLayoutModeAuto => '自動';

  @override
  String get pdfLayoutModeSingle => '單頁';

  @override
  String get pdfLayoutModeTwoPages => '雙頁';

  @override
  String get pdfLayoutModeScroll => '捲動';

  @override
  String get pdfLayoutModeScrollSideways => '捲動（橫向）';

  @override
  String get pdfLayoutModeHalfPageTopBottom => '單頁 + 預覽';

  @override
  String get pdfLayoutModeHalfPageLeftRight => '單頁 + 側邊預覽';

  @override
  String get pageColorFilterOff => '關閉';

  @override
  String get pageColorFilterSepia => '懷舊棕';

  @override
  String get pageColorFilterGreen => '護眼綠';

  @override
  String get pageColorFilterInvert => '反轉色彩';

  @override
  String get pageScaleScopeFixed => '固定';

  @override
  String get pageScaleScopePerScore => '依樂譜';

  @override
  String get pageScaleScopePerPage => '依頁面';

  @override
  String get stagePresetSetUpToPlay => '準備演出';

  @override
  String get stagePresetSetUpToPractise => '準備練習';

  @override
  String get stagePresetChromeHidden => '介面已隱藏';

  @override
  String get stagePresetChromeShown => '介面已顯示';

  @override
  String get stagePresetStatusBarShown => '狀態列已顯示';

  @override
  String get stagePresetStatusBarHidden => '狀態列已隱藏';

  @override
  String get stagePresetScaleKept => '縮放已保留';

  @override
  String get stagePresetPinchFree => '已停用縮放手勢';

  @override
  String get relativeDayToday => '今天';

  @override
  String get relativeDayYesterday => '昨天';

  @override
  String relativeDayDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '天前',
      one: '天前',
    );
    return '$days $_temp0';
  }

  @override
  String pageOrderEditorEntryBlank(int index) {
    return '$index. 空白頁';
  }

  @override
  String pageOrderEditorEntryPdfPage(int index, int sourcePage) {
    return '$index. PDF 第 $sourcePage 頁';
  }

  @override
  String get pageOrderEditorResetTitle => '重設為原始順序？';

  @override
  String get pageOrderEditorResetBody => '還原 PDF 原始頁面順序，並移除空白頁與重複頁？';

  @override
  String get pageOrderEditorReset => '重設';

  @override
  String get pageOrderEditorAppBarTitle => '頁面順序';

  @override
  String get pageOrderEditorNoPages => '沒有頁面';

  @override
  String get pageOrderEditorDuplicate => '複製';

  @override
  String get pageOrderEditorInsertBlank => '插入空白頁';

  @override
  String get pageOrderEditorRemove => '移除';

  @override
  String get librarySortTitle => '標題';

  @override
  String get librarySortCreated => '建立時間';

  @override
  String get librarySortLastViewed => '最近檢視';

  @override
  String scoreOriginPage(int page) {
    return '第 $page 頁';
  }

  @override
  String scoreOriginPages(int first, int last) {
    return '第 $first–$last 頁';
  }

  @override
  String scoreOriginPagesOfBook(String pages, String name) {
    return '$name 的 $pages';
  }

  @override
  String libraryVisibilityInBook(String title) {
    return '在《$title》中';
  }

  @override
  String get libraryVisibilityInBookFallback => '在合輯中';

  @override
  String get libraryBackupFileNotFound => '找不到備份檔案。';

  @override
  String get libraryBackupFailedGeneric => '備份失敗。';

  @override
  String libraryBackupCreateFailed(String error) {
    return '無法建立備份：$error';
  }

  @override
  String libraryBackupRestoreFailed(String error) {
    return '無法還原備份：$error';
  }

  @override
  String get libraryBackupMissingMarker => '這不是 StageScore 備份檔（缺少標記）。';

  @override
  String get libraryBackupUnknownFormat => '這不是 StageScore 備份檔（格式不明）。';

  @override
  String get libraryBackupUnsupportedVersion => '不支援此 StageScore 備份版本。';

  @override
  String get libraryBackupCorruptMarker => '這不是 StageScore 備份檔（標記已損毀）。';

  @override
  String get gestureMapLongPress => '長按';

  @override
  String get gestureMapTapTopEdge => '點按上邊緣';

  @override
  String get gestureMapTapBottomEdge => '點按下邊緣';

  @override
  String get gestureMapEmptyHint => '請將某個手勢設為「顯示選單／介面」，才能叫出它。';

  @override
  String gestureMapRevealHint(String joined) {
    return '演奏時隱藏工具列與頁面列，若要叫回，請$joined。';
  }

  @override
  String get layoutNavigationPedalOrPageBar => '踏板或頁面列';

  @override
  String get layoutNavigationTapLeftRight => '點按左／右側';

  @override
  String get layoutNavigationTapTopBottom => '點按上／下方';

  @override
  String get layoutNavigationTapAnywhere => '點按任意處';

  @override
  String get layoutNavigationTapAnywhereBack => '點按任意處返回';

  @override
  String get layoutNavigationSwipe => '滑動';

  @override
  String get layoutNavigationSwipeSideways => '左右滑動';

  @override
  String get layoutNavigationSwipeUpDown => '上下滑動';

  @override
  String get scoreMenuSheetTitle => '選單';

  @override
  String get appearanceSheetTitle => '外觀';

  @override
  String get appearanceSheetMode => '模式';

  @override
  String get appearanceSheetThemeColor => '主題色彩';

  @override
  String get appearanceSheetCustomChip => '自訂';

  @override
  String get appearanceSheetCustomColorDialog => '自訂色彩';

  @override
  String get appearanceSheetHue => '色相';

  @override
  String get appearanceSheetSat => '飽和度';

  @override
  String get appearanceSheetVal => '明度';

  @override
  String get scoreMenuGoTo => '前往';

  @override
  String get scoreMenuBookmarks => '書籤';

  @override
  String get scoreMenuJumpLinks => '跳頁連結';

  @override
  String get scoreMenuPageOrder => '頁面順序…';

  @override
  String get scoreMenuGoToMeasure => '跳到小節…';

  @override
  String get scoreMenuMeasureMap => 'Measure map…';

  @override
  String get scoreMenuMarks => '標記';

  @override
  String get scoreMenuHideAnnotations => '隱藏註記';

  @override
  String get scoreMenuShowAnnotations => '顯示註記';

  @override
  String get scoreMenuExporting => '匯出中…';

  @override
  String get scoreMenuExportAnnotated => '匯出含註記的 PDF';

  @override
  String get scoreMenuView => '檢視';

  @override
  String get scoreMenuLayout => '版面';

  @override
  String get scoreMenuDisplay => '顯示…';

  @override
  String get scoreMenuColorFilter => '色彩濾鏡…';

  @override
  String get scoreMenuPageScale => '頁面縮放…';

  @override
  String get scoreMenuLocked => '已鎖定';

  @override
  String get scoreMenuPlaying => '播放中';

  @override
  String get scoreMenuMetronomeRunning => '節拍器（運作中）…';

  @override
  String get scoreMenuMetronome => '節拍器…';

  @override
  String get scoreMenuShowPlaybackControls => 'Show Playback controls';

  @override
  String get scoreMenuHidePlaybackControls => 'Hide Playback controls';

  @override
  String get scoreMenuPlaybackMapFirst => 'Map measures first';

  @override
  String get scoreMenuPageTurnSettings => '翻頁設定';

  @override
  String get playbackControlsPlay => 'Play';

  @override
  String get playbackControlsPause => 'Pause';

  @override
  String get playbackControlsStop => 'Stop';

  @override
  String playbackControlsCountInBadge(int count) {
    return 'Count-in $count';
  }

  @override
  String get playbackControlsCountInLabel => 'Count-in';

  @override
  String get playbackMapLostSnackbar => 'MeasureMap changed — playback stopped';

  @override
  String scoreMenuLayoutValueBoth(String stored, String resolved) {
    return '$stored · $resolved';
  }

  @override
  String get languageSheetTitle => '語言';

  @override
  String get languageSheetSystem => '系統';

  @override
  String get languageSheetSystemSubtitle => '跟隨裝置語言';

  @override
  String get stampSheetTitle => '印章';

  @override
  String get stampBox => '方框';

  @override
  String get stampCircle => '圓圈';

  @override
  String get stampArrow => '箭頭';

  @override
  String get stampText => '文字';

  @override
  String get pageScaleSheetTitle => '頁面縮放';

  @override
  String get pageScaleSheetExplainer =>
      '設定樂譜顯示的大小，並會在每次開啟時記住。用手指縮放只是暫時調整檢視畫面，這裡的設定則會永久生效。';

  @override
  String pageScaleSheetCurrent(String value) {
    return '目前這一頁：$value×';
  }

  @override
  String get pageScaleSheetAppliesTo => '套用範圍';

  @override
  String get pageScaleSheetScale => '縮放';

  @override
  String pageScaleSheetScaleValue(String value) {
    return '$value×';
  }

  @override
  String get pageScaleSheetKeepScale => '保持此縮放';

  @override
  String get pageScaleSheetKeepScaleSubtitle => '已關閉手勢縮放，避免演奏中不小心誤觸移動畫面';

  @override
  String get pageScaleSheetHintFixed => '套用到每份樂譜，除非該樂譜另有設定';

  @override
  String get pageScaleSheetHintPerScore => '僅套用到此樂譜的所有頁面';

  @override
  String get pageScaleSheetHintPerPage => '僅套用到此頁 — 內容較密的頁面可以放大，不影響其他頁面';

  @override
  String get layoutSettingsSheetTitle => '版面';

  @override
  String get layoutSettingsSheetPageTurnSettings => '翻頁設定';

  @override
  String get layoutSettingsSheetPageTurnSettingsSubtitle => '點按區域、滑動、踏板、動畫效果';

  @override
  String get layoutSettingsSheetFallsBack => '此螢幕僅顯示單頁 — 旋轉裝置可顯示跨頁';

  @override
  String layoutSettingsSheetNow(String mode) {
    return '目前：$mode';
  }

  @override
  String get layoutSettingsSheetFitsScreen => '適合此螢幕';

  @override
  String get pageTurnSettingsSheetGestureWarning => '請至少保留一個手勢設為「顯示選單／介面」。';

  @override
  String get pageTurnSettingsSheetTitle => '翻頁';

  @override
  String get pageTurnSettingsSheetTapZones => '點按區域';

  @override
  String pageTurnSettingsSheetTapZonesHint(
    String layoutMode,
    String navigationHint,
  ) {
    return '在$layoutMode中：$navigationHint。';
  }

  @override
  String get pageTurnSettingsSheetSwipe => '滑動';

  @override
  String get pageTurnSettingsSheetMatchLayout => '配合版面';

  @override
  String get pageTurnSettingsSheetMatchLayoutSubtitle => '依照頁面翻動方向滑動';

  @override
  String get pageTurnSettingsSheetSwipeLeftNext => '向左滑 → 下一頁';

  @override
  String get pageTurnSettingsSheetSwipeRightPrevious => '向右滑 → 上一頁';

  @override
  String get pageTurnSettingsSheetSwipeUpNext => '向上滑 → 下一頁';

  @override
  String get pageTurnSettingsSheetSwipeDownPrevious => '向下滑 → 上一頁';

  @override
  String get pageTurnSettingsSheetReverseDirection => '反轉翻頁方向';

  @override
  String get pageTurnSettingsSheetReverseDirectionSubtitle => '適用於翻頁方向相反的樂譜';

  @override
  String get pageTurnSettingsSheetTurnAmount => '翻頁幅度';

  @override
  String get pageTurnSettingsSheetTurnAmountHintTwoPage =>
      '設為「半頁」時，一次只翻動跨頁中的一頁，而非整組跨頁。';

  @override
  String get pageTurnSettingsSheetTurnAmountHintDefault =>
      '設為「半頁」時，一次大約翻動半個螢幕，而非整個畫面。';

  @override
  String get pageTurnSettingsSheetAnimation => '動畫效果';

  @override
  String get pageTurnSettingsSheetPageTurnDelay => '翻頁延遲';

  @override
  String get pageTurnSettingsSheetApplyTo => '套用範圍';

  @override
  String get pageTurnSettingsSheetGestures => '手勢';

  @override
  String get pageTurnSettingsSheetGesturesHint =>
      '邊緣點按是位於畫面上下方的細長區域，和「上／下方翻頁區域」不同。其中至少要有一個設為「顯示選單／介面」；這個手勢在演出模式中也能叫出工具列。「繪圖」一律從工具列進入，無法透過手勢啟動。';

  @override
  String get pageTurnSettingsSheetLongPress => '長按';

  @override
  String get pageTurnSettingsSheetTopEdge => '上邊緣';

  @override
  String get pageTurnSettingsSheetBottomEdge => '下邊緣';

  @override
  String get pageTurnSettingsSheetPedalKeyboard => '踏板／鍵盤';

  @override
  String get pageTurnSettingsSheetPedalKeyboardHint =>
      '支援會送出鍵盤按鍵的藍牙翻頁踏板：\n上一頁 — PageUp、←、↑、空白鍵\n下一頁 — PageDown、→、↓、Enter';

  @override
  String get pageTurnAnimationOff => '關閉';

  @override
  String get pageTurnAnimationFast => '快';

  @override
  String get pageTurnAnimationNormal => '正常';

  @override
  String get pageTurnAnimationSlow => '慢';

  @override
  String get pageTurnDelayOff => '關閉';

  @override
  String get pageTurnDelay300ms => '0.3 秒';

  @override
  String get pageTurnDelay500ms => '0.5 秒';

  @override
  String get pageTurnDelay1000ms => '1.0 秒';

  @override
  String get pageTurnDelayScopeAll => '全部';

  @override
  String get pageTurnDelayScopePedalOnly => '僅限踏板與鍵盤';

  @override
  String get pageTurnTapModeMatchLayout => '配合版面';

  @override
  String get pageTurnTapModeLeftRight => '左／右';

  @override
  String get pageTurnTapModeTopBottom => '上／下';

  @override
  String get pageTurnTapModePrevious => '任意處 → 上一頁';

  @override
  String get pageTurnTapModeNext => '任意處 → 下一頁';

  @override
  String get pageTurnTapModeDisabled => '停用';

  @override
  String get turnAmountFull => '整頁';

  @override
  String get turnAmountHalf => '半頁';

  @override
  String get gestureMapActionShowChrome => '顯示選單／介面';

  @override
  String get gestureMapActionDisabled => '關閉';

  @override
  String get drawToolbarColorLabel => '顏色';

  @override
  String get drawToolbarSizeLabel => '大小';

  @override
  String get drawToolbarUndo => '復原';

  @override
  String get drawToolbarRedo => '重做';

  @override
  String get drawToolbarDelete => '刪除';

  @override
  String get drawToolbarStamp => '印章';

  @override
  String get drawToolbarPlace => '放置';

  @override
  String get drawToolbarMore => '更多';

  @override
  String get drawToolbarTextStampTitle => '文字印章';

  @override
  String get drawToolbarTextStampHint => '簡短標籤';

  @override
  String get drawToolbarDrawOptionsTitle => '繪圖選項';

  @override
  String get drawToolbarTool => '工具';

  @override
  String get drawToolbarWidth => '粗細';

  @override
  String get drawToolbarStraightLine => '直線';

  @override
  String get drawToolPen => '鋼筆';

  @override
  String get drawToolMarker => '麥克筆';

  @override
  String get drawToolEraser => '橡皮擦';

  @override
  String get drawToolEyedropper => '滴管';

  @override
  String get drawWidthThin => '細';

  @override
  String get drawWidthMedium => '中';

  @override
  String get drawWidthThick => '粗';

  @override
  String get pdfModeScreenTapHint => '點按畫面右半邊前進下一頁，左半邊回到上一頁。';

  @override
  String get pdfModeScreenColorFilterTitle => '色彩濾鏡';

  @override
  String get scoreMenuQuickBarBookmarks => '書籤';

  @override
  String get scoreMenuQuickBarDraw => '繪圖';

  @override
  String get scoreMenuQuickBarExitDraw => '結束繪圖';

  @override
  String get scoreMenuQuickBarMetronome => '節拍器';

  @override
  String get scoreMenuQuickBarMetronomeRunning => '節拍器（運作中）';

  @override
  String get pdfModeScreenExporting => '匯出 PDF 中…';

  @override
  String get pdfModeScreenExportReady => '匯出完成 — 已開啟分享面板';

  @override
  String pdfModeScreenExportRestartHint(String path) {
    return '已匯出至 $path。請完全重新啟動 App（停止後重新執行 flutter run）以啟用分享面板。';
  }

  @override
  String pdfModeScreenExportFailed(String error) {
    return '匯出失敗：$error';
  }

  @override
  String pdfModeScreenPieceIndex(int index) {
    return '$index.';
  }

  @override
  String get pdfModeScreenHidePieceNotes => '隱藏曲目筆記';

  @override
  String get pdfModeScreenShowPieceNotes => '顯示曲目筆記';

  @override
  String get pdfModeScreenPieceNotes => '曲目筆記';

  @override
  String get libraryScreenSort => '排序';

  @override
  String get libraryScreenFilter => '篩選';

  @override
  String get libraryScreenManageLabels => '管理標籤';

  @override
  String get libraryScreenMore => '更多';

  @override
  String get libraryScreenAppearance => '外觀…';

  @override
  String get libraryScreenLanguage => '語言…';

  @override
  String get libraryScreenBackup => '備份…';

  @override
  String get libraryScreenRestore => '還原…';

  @override
  String libraryScreenAbout(String productName) {
    return '關於 $productName…';
  }

  @override
  String libraryScreenSplitIntoPiecesSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '個曲目',
      one: '個曲目',
    );
    return '已拆分為 $count $_temp0';
  }

  @override
  String get libraryScreenStillReadingPdf => '仍在讀取此 PDF — 請稍後再試一次。';

  @override
  String get libraryScreenEditPiecesAppBarTitle => '編輯曲目';

  @override
  String libraryScreenUpdatedPieces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '個曲目',
      one: '個曲目',
    );
    return '已更新為 $count $_temp0。';
  }

  @override
  String get libraryScreenEditPiecesDialogTitle => '移除曲目資料？';

  @override
  String libraryScreenEditPiecesBody(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '其',
      one: '其',
    );
    return '$names 將被移除，包含$_temp0註記、書籤、跳頁連結、標籤與所屬的演出清單。';
  }

  @override
  String get libraryScreenSplitIntoPiecesDialogTitle => '拆分為多個曲目？';

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
      other: '頁',
      one: '頁',
    );
    return '將「$title」縮限為第 $firstPage–$lastPage 頁，將會從其頁面順序中移除 $dropping $_temp0。';
  }

  @override
  String get libraryScreenSplitConfirm => '拆分';

  @override
  String get libraryScreenChangePagesTitle => '變更頁面範圍？';

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
      other: '頁',
      one: '頁',
    );
    return '將「$title」變更為第 $firstPage–$lastPage 頁，將會從其頁面順序中移除 $dropping $_temp0。';
  }

  @override
  String get libraryScreenChangePagesConfirm => '變更';

  @override
  String get libraryScreenSetlistEmptyAddScores => '請先將樂譜加入此演出清單。';

  @override
  String get libraryScreenNoScoresAvailable => '找不到此演出清單中的任何樂譜。';

  @override
  String libraryScreenSkippedMissingScores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '份找不到的樂譜',
      one: '份找不到的樂譜',
    );
    return '已略過 $count $_temp0。';
  }

  @override
  String get libraryScreenNewSetlist => '新增演出清單';

  @override
  String get libraryScreenDeleteSetlistTitle => '刪除演出清單？';

  @override
  String libraryScreenDeleteSetlistBody(String title) {
    return '刪除「$title」？其中的樂譜不會受到影響。';
  }

  @override
  String libraryScreenDeleteScoreBody(String title) {
    return '刪除「$title」？此動作無法復原。';
  }

  @override
  String libraryScreenDeleteScoreWithPiecesBody(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '個曲目',
      one: '個曲目',
    );
    return '刪除「$title」及其 $count $_temp0？此動作無法復原。';
  }

  @override
  String get libraryScreenDeleteScoreTitle => '刪除樂譜？';

  @override
  String get libraryScreenTabScores => '樂譜';

  @override
  String get libraryScreenTabSetlists => '演出清單';

  @override
  String get libraryScreenSearchHint => '搜尋樂譜';

  @override
  String get libraryScreenAddPdf => '新增 PDF';

  @override
  String libraryScreenSplitSuggestionWithPages(String name, int pages) {
    return '「$name」（$pages 頁）看起來可能包含多個曲目。';
  }

  @override
  String libraryScreenSplitSuggestionGeneric(String name) {
    return '「$name」看起來可能包含多個曲目。';
  }

  @override
  String get libraryScreenNotNow => '稍後再說';

  @override
  String get libraryScreenSplitEllipsis => '拆分…';

  @override
  String libraryScreenFailedToOpen(String error) {
    return '無法開啟樂譜庫：$error';
  }

  @override
  String get libraryScreenNoScoresYet => '尚無樂譜';

  @override
  String get libraryScreenImportPdfHint => '匯入 PDF 即可開始使用。';

  @override
  String get libraryScreenAddSampleScore => '新增範例樂譜';

  @override
  String libraryScreenNoScoresMatchSearch(String query) {
    return '沒有符合「$query」的樂譜。';
  }

  @override
  String libraryScreenNoScoresMatchFilter(String filter) {
    return '沒有符合 $filter 的樂譜。';
  }

  @override
  String get libraryScreenClearSearch => '清除搜尋';

  @override
  String get libraryScreenClearFilter => '清除篩選';

  @override
  String libraryScreenRecencyWithPieces(String when, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '個曲目',
      one: '個曲目',
    );
    return '$when · $count $_temp0';
  }

  @override
  String get libraryScreenPiecesEllipsis => '曲目…';

  @override
  String get libraryScreenEditPiecesMenuItem => '編輯曲目…';

  @override
  String get libraryScreenOpenFullScore => '開啟完整樂譜';

  @override
  String get libraryScreenRenameEllipsis => '重新命名…';

  @override
  String get libraryScreenLabelsEllipsis => '標籤…';

  @override
  String get libraryScreenSplitIntoPiecesEllipsis => '拆分為曲目…';

  @override
  String get libraryScreenPagesEllipsis => '頁面…';

  @override
  String get libraryScreenReplacePdfEllipsis => '取代 PDF…';

  @override
  String get libraryScreenDeleteEllipsis => '刪除…';

  @override
  String libraryScreenAddedRelative(String when) {
    return '新增於 $when';
  }

  @override
  String libraryScreenOpenedRelative(String when) {
    return '開啟於 $when';
  }

  @override
  String libraryScreenRecencyWithPages(String when, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '頁',
      one: '頁',
    );
    return '$when · $pages $_temp0';
  }

  @override
  String get libraryScreenNoSetlistsYet => '尚無演出清單';

  @override
  String get libraryScreenSetlistsEmptyHint => '將樂譜分組，方便連續演出而不必逐一重新開啟每個曲目。';

  @override
  String libraryScreenSetlistScoreCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '份樂譜',
      one: '份樂譜',
    );
    return '$count $_temp0';
  }

  @override
  String get libraryScreenSetlistCountEmpty => '空的';

  @override
  String libraryScreenSetlistScoreCountOpened(
    String scoreCount,
    String opened,
  ) {
    return '$scoreCount · $opened';
  }

  @override
  String get metronomeSheetTitle => '節拍器';

  @override
  String get metronomeSheetTempo => '速度';

  @override
  String get metronomeSheetMeter => '拍號';

  @override
  String get metronomeSheetMeterHint => '每小節拍子的分組方式';

  @override
  String get metronomeSheetEqual => '平均';

  @override
  String get metronomeSheetMute => '靜音';

  @override
  String get metronomeSheetShowBeats => '顯示拍點';

  @override
  String get metronomeSheetShowBeatsHint => '播放時在樂譜上閃爍拍點';

  @override
  String get metronomeSheetCountIn => 'Count-in';

  @override
  String get metronomeSheetCountInHint =>
      'Click measures before Play from the start (not after Pause)';

  @override
  String get metronomeSheetCountInNone => 'Off';

  @override
  String get metronomeSheetCountInOne => '1';

  @override
  String get metronomeSheetCountInTwo => '2';

  @override
  String metronomeSheetVolume(int percent) {
    return '音量：$percent%';
  }

  @override
  String get metronomeSheetStop => '停止';

  @override
  String get metronomeSheetStart => '開始';

  @override
  String get metronomeSheetEnterNumber => '請輸入數字';

  @override
  String get metronomeSheetTempoDialogTitle => '設定速度';

  @override
  String get pageExtentScreenTitle => '頁面';

  @override
  String pageExtentScreenFirstPage(int page) {
    return '起始頁：第 $page 頁';
  }

  @override
  String pageExtentScreenLastPage(int page) {
    return '結束頁：第 $page 頁';
  }

  @override
  String get pageExtentScreenNoPages => '沒有頁面';

  @override
  String get pageExtentScreenBadgeOnly => '僅此頁';

  @override
  String get pageExtentScreenBadgeFirst => '起始';

  @override
  String get pageExtentScreenBadgeLast => '結束';

  @override
  String pageExtentScreenSummary(String title, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '頁',
      one: '頁',
    );
    return '$title — $pages $_temp0';
  }

  @override
  String get pageExtentScreenHint => '點按下方頁面以設定所選的邊界。';

  @override
  String get pageNavBarPreviousPageTooltip => '上一頁';

  @override
  String get pageNavBarNextPageTooltip => '下一頁';

  @override
  String pageNavBarJumpedSnackbar(int page, int count) {
    return '已跳至第 $page 頁，共 $count 頁';
  }

  @override
  String get pageNavBarGoToPageTitle => '跳至頁面';

  @override
  String pageNavBarPageFieldLabel(int count) {
    return '頁面（1–$count）';
  }

  @override
  String get piecesScreenEditPieces => '編輯曲目…';

  @override
  String get piecesScreenNoPieces => '尚無曲目';

  @override
  String get piecesScreenRename => '重新命名…';

  @override
  String get piecesScreenLabels => '標籤…';

  @override
  String get piecesScreenSplitIntoPieces => '拆分為曲目…';

  @override
  String get piecesScreenPages => '頁面…';

  @override
  String get piecesScreenReplacePdf => '取代 PDF…';

  @override
  String get piecesScreenDelete => '刪除…';

  @override
  String piecesScreenAdded(String when) {
    return '新增於 $when';
  }

  @override
  String piecesScreenOpened(String when) {
    return '開啟於 $when';
  }

  @override
  String piecesScreenRecencyWithPages(String when, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '頁',
      one: '頁',
    );
    return '$when · $pages $_temp0';
  }

  @override
  String piecesScreenPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '個曲目',
      one: '個曲目',
    );
    return '$count $_temp0';
  }

  @override
  String piecesScreenPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '頁',
      one: '頁',
    );
    return '$count $_temp0';
  }

  @override
  String get piecesScreenOpenFullScore => '開啟完整樂譜';

  @override
  String get setlistEditorImportFirst => '請先匯入一份樂譜。';

  @override
  String get setlistEditorDefaultTitle => '新增演出清單';

  @override
  String get setlistEditorAppBarTitle => '編輯演出清單';

  @override
  String get setlistEditorAddScores => '新增樂譜';

  @override
  String get setlistEditorTitleFieldLabel => '標題';

  @override
  String get setlistEditorEmpty => '尚無樂譜。點按「新增樂譜」以建立演出清單。';

  @override
  String get setlistEditorMissingScore => '找不到樂譜';

  @override
  String get setlistEditorRemovedFromLibrary => '已從樂譜庫移除';

  @override
  String get setlistEditorRemoveTooltip => '移除';

  @override
  String setlistEditorAddCount(int count) {
    return '新增（$count）';
  }

  @override
  String setlistEditorPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '個曲目',
      one: '個曲目',
    );
    return '$count $_temp0';
  }

  @override
  String get setlistEditorPiecesTooltip => '檢視曲目';

  @override
  String get splitScoreScreenRenameTitle => '重新命名';

  @override
  String get splitScoreScreenTitle => '拆分為曲目';

  @override
  String get splitScoreScreenClearMarks => '清除標記';

  @override
  String get splitScoreScreenNoPages => '沒有頁面';

  @override
  String splitScoreScreenPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個曲目',
      one: '1 個曲目',
      zero: '尚無曲目',
    );
    return '$_temp0';
  }

  @override
  String get splitScoreScreenHint => '點按頁面以標記新曲目的起始點。長按已標記的頁面可重新命名。';

  @override
  String splitScoreScreenFrontMatterPage(int page) {
    return '第 $page 頁為前置頁面，不屬於任何曲目。';
  }

  @override
  String splitScoreScreenFrontMatterPages(int first, int last) {
    return '第 $first–$last 頁為前置頁面，不屬於任何曲目。';
  }

  @override
  String splitScoreScreenUseContents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '項',
      one: '項',
    );
    return '使用目錄（$count $_temp0）';
  }

  @override
  String get libraryScreenNoPdfFiles => '找不到任何 PDF 檔案。';

  @override
  String libraryScreenImportedScores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '份樂譜',
      one: '份樂譜',
    );
    return '已匯入 $count $_temp0';
  }

  @override
  String get libraryScreenCreateBackupTitle => '建立備份？';

  @override
  String get libraryScreenCreateBackupBody =>
      '此操作會將整個樂譜庫 — 樂譜、標籤、演出清單與設定 — 儲存為一個 zip 檔，可供分享或另存於安全的地方。';

  @override
  String get libraryScreenCreateBackupConfirm => '建立備份';

  @override
  String get libraryScreenCreatingBackup => '建立備份中…';

  @override
  String get libraryScreenBackupShareSubject => 'StageScore 備份';

  @override
  String libraryScreenBackupSaved(String path) {
    return '備份已儲存至 $path';
  }

  @override
  String get libraryScreenBackupReady => '備份完成 — 已開啟分享面板';

  @override
  String libraryScreenBackupFailed(String error) {
    return '無法建立備份：$error';
  }

  @override
  String get libraryScreenRestoreBackupTitle => '還原備份？';

  @override
  String get libraryScreenRestoreBackupBody =>
      '此操作會以備份內容取代整個樂譜庫 — 樂譜、標籤、演出清單與設定。此動作無法復原。';

  @override
  String get libraryScreenReplaceAll => '全部取代';

  @override
  String get libraryScreenRestoringBackup => '還原備份中…';

  @override
  String get libraryScreenLibraryRestored => '樂譜庫已還原';

  @override
  String libraryScreenRestoreFailed(String error) {
    return '無法還原備份：$error';
  }

  @override
  String libraryScreenPercentValue(int percent) {
    return '$percent%';
  }

  @override
  String get libraryScreenUntagged => '未加標籤';

  @override
  String get libraryScreenThisFilter => '此篩選條件';

  @override
  String get libraryScreenAndConjunction => '和';

  @override
  String get libraryScreenAllOf => '全部符合';

  @override
  String libraryScreenRemoveFilterChip(String label) {
    return '移除 $label 篩選';
  }

  @override
  String get libraryScreenRenameScoreTitle => '重新命名樂譜';

  @override
  String get libraryScreenReplacePdfTitle => '取代 PDF？';

  @override
  String libraryScreenReplacePdfBodyShared(
    int sharing,
    String title,
    int others,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '個曲目',
      one: '個曲目',
    );
    return '此 PDF 由 $sharing 個曲目共用，包含「$title」。取代後，其他 $others $_temp0也會一併變更。';
  }

  @override
  String libraryScreenReplacePdfBodySingle(String title) {
    return '取代「$title」背後的 PDF？您可以在下方選擇保留或重設其註記。';
  }

  @override
  String get libraryScreenKeepOverlays => '保留註記';

  @override
  String get libraryScreenResetOverlays => '重設註記';

  @override
  String get libraryScreenOverlaysReset => '註記已重設。';

  @override
  String get libraryScreenOverlaysKept => '註記已保留。';

  @override
  String libraryScreenPdfReplaced(String overlayNote) {
    return 'PDF 已取代。$overlayNote';
  }

  @override
  String libraryScreenPdfReplacedShortened(String overlayNote, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '個頁面項目',
      one: '個頁面項目',
    );
    return 'PDF 已取代。$overlayNote 新檔案頁數較少，因此已移除 $count $_temp0。';
  }

  @override
  String libraryScreenReplaceFailed(String error) {
    return '無法取代 PDF：$error';
  }

  @override
  String continuousPageOrderViewOpenFailed(String error) {
    return '無法開啟 PDF：$error';
  }

  @override
  String get performancePageSlotBlank => '空白頁';

  @override
  String performancePageSlotMissingPage(int page) {
    return '缺少第 $page 頁';
  }

  @override
  String singlePageSliderOpenFailed(String error) {
    return '無法開啟 PDF：$error';
  }

  @override
  String aboutSheetVersion(String version) {
    return '版本 $version';
  }

  @override
  String aboutSheetVersionWithBuild(String version, String build) {
    return '版本 $version（$build）';
  }

  @override
  String aboutSheetLinkOpenFailed(String url) {
    return '無法開啟連結：$url';
  }

  @override
  String aboutSheetTitle(String productName) {
    return '關於 $productName';
  }

  @override
  String get aboutSheetWebsiteLabel => '網站';

  @override
  String get aboutSheetPrivacyLabel => '隱私權';

  @override
  String get aboutSheetSupportLabel => '支援';

  @override
  String get bookmarksSheetAddTitle => '新增書籤';

  @override
  String bookmarksSheetPageLabel(int page) {
    return '第 $page 頁';
  }

  @override
  String get bookmarksSheetRenameTitle => '重新命名書籤';

  @override
  String get bookmarksSheetTitle => '書籤';

  @override
  String get bookmarksSheetEmpty => '尚無書籤';

  @override
  String get displaySheetBorderColorTitle => '邊框顏色';

  @override
  String displaySheetHue(int value) {
    return '色相：$value';
  }

  @override
  String displaySheetSaturation(int value) {
    return '飽和度：$value';
  }

  @override
  String displaySheetColorValue(int value) {
    return '明度：$value';
  }

  @override
  String get displaySheetTitle => '顯示';

  @override
  String get displaySheetPerformanceMode => '演出模式';

  @override
  String get displaySheetPageBorder => '頁面邊框';

  @override
  String displaySheetThickness(String value) {
    return '粗細：$value';
  }

  @override
  String get displaySheetColorLabel => '顏色';

  @override
  String get displaySheetCustomChip => '自訂';

  @override
  String get displaySheetShowStatusBar => '顯示狀態列';

  @override
  String get displaySheetShowStatusBarHint => '演奏時保持時鐘與電量顯示';

  @override
  String get displaySheetAvoidNotches => '避開瀏海';

  @override
  String get displaySheetAvoidNotchesHint => '讓頁面內容避開相機瀏海與圓角區域';

  @override
  String get jumpLinkEditSheetAddTitle => '新增跳頁連結';

  @override
  String get jumpLinkEditSheetEditTitle => '編輯跳頁連結';

  @override
  String jumpLinkEditSheetOriginLabel(int page) {
    return '從第 $page 頁';
  }

  @override
  String jumpLinkEditSheetDestinationLabel(int page, int pageCount) {
    return '跳至第 $page 頁，共 $pageCount 頁';
  }

  @override
  String get jumpLinkEditSheetColorLabel => '顏色';

  @override
  String get jumpLinkEditSheetSizeLabel => '大小';

  @override
  String get jumpLinksSheetDragHint => '已新增。拖曳清單中的跳頁連結即可調整順序。';

  @override
  String get jumpLinksSheetTitle => '跳頁連結';

  @override
  String get jumpLinksSheetEmpty => '尚無跳頁連結';

  @override
  String jumpLinksSheetRowTitle(int from, int to) {
    return '第 $from 頁 → 第 $to 頁';
  }

  @override
  String get jumpLinksSheetRowSubtitle => '點按以跳至此連結';

  @override
  String labelSheetsTitle(String title) {
    return '「$title」的標籤';
  }

  @override
  String get labelSheetsManage => '管理';

  @override
  String get labelSheetsCreateLabel => '建立標籤';

  @override
  String get labelSheetsNewLabel => '新標籤';

  @override
  String get labelSheetsManageTitle => '管理標籤';

  @override
  String get labelSheetsNoLabelsYet => '尚無標籤';

  @override
  String labelSheetsUsageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '份樂譜',
      one: '份樂譜',
    );
    return '被 $count $_temp0使用';
  }

  @override
  String get labelSheetsDeleteTitle => '刪除標籤？';

  @override
  String labelSheetsDeleteConfirm(String name) {
    return '刪除「$name」？';
  }

  @override
  String labelSheetsDeleteConfirmWithUsage(String name, int usage) {
    String _temp0 = intl.Intl.pluralLogic(
      usage,
      locale: localeName,
      other: '份樂譜',
      one: '份樂譜',
    );
    return '「$name」正被 $usage $_temp0使用。仍要刪除嗎？';
  }

  @override
  String get labelSheetsRenameLabelTitle => '重新命名標籤';

  @override
  String get labelSheetsNameHint => '標籤名稱';

  @override
  String get libraryFilterSheetTitle => '篩選';

  @override
  String get libraryFilterSheetModeAny => '符合任一';

  @override
  String get libraryFilterSheetModeAll => '符合全部';

  @override
  String get libraryFilterSheetModeUntagged => '未加標籤';

  @override
  String get libraryFilterSheetUntaggedHint => '沒有標籤的樂譜';

  @override
  String get libraryFilterSheetEmptyLabels => '目前沒有可用來篩選的標籤';

  @override
  String get measureMapMeasureCountTitle => '幾個 MeasureBox？';

  @override
  String get measureMapMeasureCountLabel => 'MeasureBoxes';

  @override
  String get measureMapGoToTitle => '跳到小節';

  @override
  String get measureMapGoToLabel => '小節編號';

  @override
  String measureMapGoToMissing(int number) {
    return '第 $number 小節尚未對應';
  }

  @override
  String get measureMapMetaTitle => '速度與拍號';

  @override
  String get measureMapTimeSignatureLabel => '拍號';

  @override
  String get measureMapTempoLabel => '速度';

  @override
  String get measureMapMetaScopeTitle => '套用至';

  @override
  String get measureMapScopeThisMeasure => '僅此小節';

  @override
  String get measureMapScopeThisSystem => '此 System';

  @override
  String get measureMapScopeThisPage => '本頁';

  @override
  String get measureMapScopeRestOfScore => 'Score 其餘部分';

  @override
  String get measureMapScopeNextN => 'Next N…';

  @override
  String get measureMapMetaNextNLabel => '小節數';

  @override
  String get measureMapClearTitle => '清除 MeasureMap？';

  @override
  String get measureMapClearBody =>
      '刪除此 Score 的所有 SystemBox 與 MeasureBox。無法復原。';

  @override
  String get measureMapClearConfirm => '清除';

  @override
  String get measureMapDeleteSystemTitle => '刪除 System？';

  @override
  String get measureMapDeleteSystemBody => '刪除此 SystemBox 及其所有 MeasureBox。';

  @override
  String get measureMapCopyFromPageTitle => '從頁面複製版面';

  @override
  String get measureMapCopyFromPageLabel => '來源頁';

  @override
  String get measureMapCopyPrevious => '複製上一頁';

  @override
  String get measureMapEmptyHint => '繪製一行 System — 應用程式會詢問有多少小節';

  @override
  String get measureMapDone => '完成';

  @override
  String get measureMapEditBeats => 'Edit beats';

  @override
  String get measureMapSetMeasureCount => '設定小節數…';

  @override
  String get measureMapDeleteSystem => '刪除 System';

  @override
  String get measureMapDeleteMeasure => '刪除小節';

  @override
  String get measureMapEditMeta => '速度與拍號…';

  @override
  String get measureMapStartsAtBeat => 'Starts at beat';

  @override
  String get measureMapStartsAtBeatHint =>
      '1 = full measure; higher skips early beats (pickup on a wide box)';

  @override
  String get measureMapClearAll => '清除 MeasureMap…';
}
