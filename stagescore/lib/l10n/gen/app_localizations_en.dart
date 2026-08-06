// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDone => 'Done';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionOk => 'OK';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionRename => 'Rename';

  @override
  String get actionBack => 'Back';

  @override
  String get actionMore => 'More';

  @override
  String get actionGo => 'Go';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionReset => 'Reset';

  @override
  String get commonOr => 'or';

  @override
  String get commonTitleLabel => 'Title';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get pdfLayoutModeAuto => 'Auto';

  @override
  String get pdfLayoutModeSingle => 'One page';

  @override
  String get pdfLayoutModeTwoPages => 'Two pages';

  @override
  String get pdfLayoutModeScroll => 'Scroll';

  @override
  String get pdfLayoutModeScrollSideways => 'Scroll (sideways)';

  @override
  String get pdfLayoutModeHalfPageTopBottom => 'One page + peek';

  @override
  String get pdfLayoutModeHalfPageLeftRight => 'One page + side peek';

  @override
  String get pageColorFilterOff => 'Off';

  @override
  String get pageColorFilterSepia => 'Sepia';

  @override
  String get pageColorFilterGreen => 'Green';

  @override
  String get pageColorFilterInvert => 'Invert';

  @override
  String get pageScaleScopeFixed => 'Fixed';

  @override
  String get pageScaleScopePerScore => 'Per Score';

  @override
  String get pageScaleScopePerPage => 'Per Page';

  @override
  String get stagePresetSetUpToPlay => 'Set up to play';

  @override
  String get stagePresetSetUpToPractise => 'Set up to practise';

  @override
  String get stagePresetChromeHidden => 'chrome hidden';

  @override
  String get stagePresetChromeShown => 'chrome shown';

  @override
  String get stagePresetStatusBarShown => 'status bar shown';

  @override
  String get stagePresetStatusBarHidden => 'status bar hidden';

  @override
  String get stagePresetScaleKept => 'scale kept';

  @override
  String get stagePresetPinchFree => 'pinch free';

  @override
  String get relativeDayToday => 'today';

  @override
  String get relativeDayYesterday => 'yesterday';

  @override
  String relativeDayDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$days $_temp0 ago';
  }

  @override
  String pageOrderEditorEntryBlank(int index) {
    return '$index. Blank';
  }

  @override
  String pageOrderEditorEntryPdfPage(int index, int sourcePage) {
    return '$index. PDF page $sourcePage';
  }

  @override
  String get pageOrderEditorResetTitle => 'Reset to original?';

  @override
  String get pageOrderEditorResetBody =>
      'Restore the PDF page order and remove blanks and duplicates?';

  @override
  String get pageOrderEditorReset => 'Reset';

  @override
  String get pageOrderEditorAppBarTitle => 'Page order';

  @override
  String get pageOrderEditorNoPages => 'No pages';

  @override
  String get pageOrderEditorDuplicate => 'Duplicate';

  @override
  String get pageOrderEditorInsertBlank => 'Insert blank';

  @override
  String get pageOrderEditorRemove => 'Remove';

  @override
  String get librarySortTitle => 'Title';

  @override
  String get librarySortCreated => 'Created';

  @override
  String get librarySortLastViewed => 'Last viewed';

  @override
  String scoreOriginPage(int page) {
    return 'Page $page';
  }

  @override
  String scoreOriginPages(int first, int last) {
    return 'Pages $first–$last';
  }

  @override
  String scoreOriginPagesOfBook(String pages, String name) {
    return '$pages of $name';
  }

  @override
  String libraryVisibilityInBook(String title) {
    return 'in $title';
  }

  @override
  String get libraryVisibilityInBookFallback => 'in book';

  @override
  String get libraryBackupFileNotFound => 'Backup file not found.';

  @override
  String get libraryBackupFailedGeneric => 'Backup failed.';

  @override
  String libraryBackupCreateFailed(String error) {
    return 'Could not create backup: $error';
  }

  @override
  String libraryBackupRestoreFailed(String error) {
    return 'Could not restore backup: $error';
  }

  @override
  String get libraryBackupMissingMarker =>
      'Not a StageScore backup (missing marker).';

  @override
  String get libraryBackupUnknownFormat =>
      'Not a StageScore backup (unknown format).';

  @override
  String get libraryBackupUnsupportedVersion =>
      'Unsupported StageScore backup version.';

  @override
  String get libraryBackupCorruptMarker =>
      'Not a StageScore backup (corrupt marker).';

  @override
  String get gestureMapLongPress => 'long-press';

  @override
  String get gestureMapTapTopEdge => 'tap the top edge';

  @override
  String get gestureMapTapBottomEdge => 'tap the bottom edge';

  @override
  String get gestureMapEmptyHint =>
      'Set a gesture to Show menu / chrome to reveal it.';

  @override
  String gestureMapRevealHint(String joined) {
    return 'Hide the toolbar and page bar while you play. To bring them back, $joined.';
  }

  @override
  String get layoutNavigationPedalOrPageBar => 'Pedal or the page bar';

  @override
  String get layoutNavigationTapLeftRight => 'tap left / right';

  @override
  String get layoutNavigationTapTopBottom => 'tap top / bottom';

  @override
  String get layoutNavigationTapAnywhere => 'tap anywhere';

  @override
  String get layoutNavigationTapAnywhereBack => 'tap anywhere to go back';

  @override
  String get layoutNavigationSwipe => 'swipe';

  @override
  String get layoutNavigationSwipeSideways => 'swipe sideways';

  @override
  String get layoutNavigationSwipeUpDown => 'swipe up / down';

  @override
  String get scoreMenuSheetTitle => 'Menu';

  @override
  String get appearanceSheetTitle => 'Appearance';

  @override
  String get appearanceSheetMode => 'Mode';

  @override
  String get appearanceSheetThemeColor => 'Theme color';

  @override
  String get appearanceSheetCustomChip => 'Custom';

  @override
  String get appearanceSheetCustomColorDialog => 'Custom color';

  @override
  String get appearanceSheetHue => 'Hue';

  @override
  String get appearanceSheetSat => 'Sat';

  @override
  String get appearanceSheetVal => 'Val';

  @override
  String get scoreMenuGoTo => 'Go to';

  @override
  String get scoreMenuBookmarks => 'Bookmarks';

  @override
  String get scoreMenuJumpLinks => 'Jump Links';

  @override
  String get scoreMenuPageOrder => 'Page order…';

  @override
  String get scoreMenuGoToMeasure => 'Go to measure…';

  @override
  String get scoreMenuMeasureMap => 'Measure map…';

  @override
  String get scoreMenuMarks => 'Marks';

  @override
  String get scoreMenuHideAnnotations => 'Hide annotations';

  @override
  String get scoreMenuShowAnnotations => 'Show annotations';

  @override
  String get scoreMenuExporting => 'Exporting…';

  @override
  String get scoreMenuExportAnnotated => 'Export PDF with annotations';

  @override
  String get scoreMenuView => 'View';

  @override
  String get scoreMenuLayout => 'Layout';

  @override
  String get scoreMenuDisplay => 'Display…';

  @override
  String get scoreMenuColorFilter => 'Color filter…';

  @override
  String get scoreMenuPageScale => 'Page scale…';

  @override
  String get scoreMenuLocked => 'Locked';

  @override
  String get scoreMenuPlaying => 'Playing';

  @override
  String get scoreMenuMetronomeRunning => 'Metronome (running)…';

  @override
  String get scoreMenuMetronome => 'Metronome…';

  @override
  String get scoreMenuPageTurnSettings => 'Page turn settings';

  @override
  String scoreMenuLayoutValueBoth(String stored, String resolved) {
    return '$stored · $resolved';
  }

  @override
  String get languageSheetTitle => 'Language';

  @override
  String get languageSheetSystem => 'System';

  @override
  String get languageSheetSystemSubtitle => 'Match the device language';

  @override
  String get stampSheetTitle => 'Stamps';

  @override
  String get stampBox => 'Box';

  @override
  String get stampCircle => 'Circle';

  @override
  String get stampArrow => 'Arrow';

  @override
  String get stampText => 'Text';

  @override
  String get pageScaleSheetTitle => 'Page scale';

  @override
  String get pageScaleSheetExplainer =>
      'How big the music is drawn, remembered between sessions. Pinching changes the view for now; this changes it for good.';

  @override
  String pageScaleSheetCurrent(String value) {
    return 'On this page right now: $value×';
  }

  @override
  String get pageScaleSheetAppliesTo => 'Applies to';

  @override
  String get pageScaleSheetScale => 'Scale';

  @override
  String pageScaleSheetScaleValue(String value) {
    return '$value×';
  }

  @override
  String get pageScaleSheetKeepScale => 'Keep this scale';

  @override
  String get pageScaleSheetKeepScaleSubtitle =>
      'Pinch is off, so a stray touch mid-piece cannot move the music';

  @override
  String get pageScaleSheetHintFixed =>
      'Every Score, unless one has its own scale';

  @override
  String get pageScaleSheetHintPerScore =>
      'This Score only, on every page of it';

  @override
  String get pageScaleSheetHintPerPage =>
      'This page only — a dense page can be bigger without changing the rest';

  @override
  String get layoutSettingsSheetTitle => 'Layout';

  @override
  String get layoutSettingsSheetPageTurnSettings => 'Page turn settings';

  @override
  String get layoutSettingsSheetPageTurnSettingsSubtitle =>
      'Tap zones, swipe, pedal, animation';

  @override
  String get layoutSettingsSheetFallsBack =>
      'One page on this screen — rotate for a spread';

  @override
  String layoutSettingsSheetNow(String mode) {
    return 'Now: $mode';
  }

  @override
  String get layoutSettingsSheetFitsScreen => 'fits this screen';

  @override
  String get pageTurnSettingsSheetGestureWarning =>
      'Keep at least one gesture set to Show menu / chrome.';

  @override
  String get pageTurnSettingsSheetTitle => 'Page turn';

  @override
  String get pageTurnSettingsSheetTapZones => 'Tap zones';

  @override
  String pageTurnSettingsSheetTapZonesHint(
    String layoutMode,
    String navigationHint,
  ) {
    return 'In $layoutMode: $navigationHint.';
  }

  @override
  String get pageTurnSettingsSheetSwipe => 'Swipe';

  @override
  String get pageTurnSettingsSheetMatchLayout => 'Match layout';

  @override
  String get pageTurnSettingsSheetMatchLayoutSubtitle =>
      'Swipe along the way the pages move';

  @override
  String get pageTurnSettingsSheetSwipeLeftNext => 'Swipe left → next';

  @override
  String get pageTurnSettingsSheetSwipeRightPrevious =>
      'Swipe right → previous';

  @override
  String get pageTurnSettingsSheetSwipeUpNext => 'Swipe up → next';

  @override
  String get pageTurnSettingsSheetSwipeDownPrevious => 'Swipe down → previous';

  @override
  String get pageTurnSettingsSheetReverseDirection =>
      'Reverse page-turn direction';

  @override
  String get pageTurnSettingsSheetReverseDirectionSubtitle =>
      'For books that turn the other way';

  @override
  String get pageTurnSettingsSheetTurnAmount => 'Turn amount';

  @override
  String get pageTurnSettingsSheetTurnAmountHintTwoPage =>
      'Half advances one page of the spread instead of the whole pair.';

  @override
  String get pageTurnSettingsSheetTurnAmountHintDefault =>
      'Half advances ~½ screen instead of a whole one.';

  @override
  String get pageTurnSettingsSheetAnimation => 'Animation';

  @override
  String get pageTurnSettingsSheetPageTurnDelay => 'Page turn delay';

  @override
  String get pageTurnSettingsSheetApplyTo => 'Apply to';

  @override
  String get pageTurnSettingsSheetGestures => 'Gestures';

  @override
  String get pageTurnSettingsSheetGesturesHint =>
      'Edge taps are thin strips at the top and bottom — not the same as Top/bottom page-turn zones. At least one must be Show menu / chrome; that gesture also reveals the toolbar in Performance mode. Draw is entered from the toolbar, never from a gesture.';

  @override
  String get pageTurnSettingsSheetLongPress => 'Long-press';

  @override
  String get pageTurnSettingsSheetTopEdge => 'Top edge';

  @override
  String get pageTurnSettingsSheetBottomEdge => 'Bottom edge';

  @override
  String get pageTurnSettingsSheetPedalKeyboard => 'Pedal / keyboard';

  @override
  String get pageTurnSettingsSheetPedalKeyboardHint =>
      'Bluetooth pedals that send keyboard keys are supported:\nPrevious — PageUp, ←, ↑, Space\nNext — PageDown, →, ↓, Enter';

  @override
  String get pageTurnAnimationOff => 'Off';

  @override
  String get pageTurnAnimationFast => 'Fast';

  @override
  String get pageTurnAnimationNormal => 'Normal';

  @override
  String get pageTurnAnimationSlow => 'Slow';

  @override
  String get pageTurnDelayOff => 'Off';

  @override
  String get pageTurnDelay300ms => '0.3s';

  @override
  String get pageTurnDelay500ms => '0.5s';

  @override
  String get pageTurnDelay1000ms => '1.0s';

  @override
  String get pageTurnDelayScopeAll => 'All';

  @override
  String get pageTurnDelayScopePedalOnly => 'Pedal & keyboard only';

  @override
  String get pageTurnTapModeMatchLayout => 'Match layout';

  @override
  String get pageTurnTapModeLeftRight => 'Left / right';

  @override
  String get pageTurnTapModeTopBottom => 'Top / bottom';

  @override
  String get pageTurnTapModePrevious => 'Anywhere → prev';

  @override
  String get pageTurnTapModeNext => 'Anywhere → next';

  @override
  String get pageTurnTapModeDisabled => 'Disabled';

  @override
  String get turnAmountFull => 'Full page';

  @override
  String get turnAmountHalf => 'Half page';

  @override
  String get gestureMapActionShowChrome => 'Show menu / chrome';

  @override
  String get gestureMapActionDisabled => 'Off';

  @override
  String get drawToolbarColorLabel => 'Color';

  @override
  String get drawToolbarSizeLabel => 'Size';

  @override
  String get drawToolbarUndo => 'Undo';

  @override
  String get drawToolbarRedo => 'Redo';

  @override
  String get drawToolbarDelete => 'Delete';

  @override
  String get drawToolbarStamp => 'Stamp';

  @override
  String get drawToolbarPlace => 'Place';

  @override
  String get drawToolbarMore => 'More';

  @override
  String get drawToolbarTextStampTitle => 'Text stamp';

  @override
  String get drawToolbarTextStampHint => 'Short label';

  @override
  String get drawToolbarDrawOptionsTitle => 'Draw options';

  @override
  String get drawToolbarTool => 'Tool';

  @override
  String get drawToolbarWidth => 'Width';

  @override
  String get drawToolbarStraightLine => 'Straight line';

  @override
  String get drawToolPen => 'Pen';

  @override
  String get drawToolMarker => 'Marker';

  @override
  String get drawToolEraser => 'Eraser';

  @override
  String get drawToolEyedropper => 'Dropper';

  @override
  String get drawWidthThin => 'Thin';

  @override
  String get drawWidthMedium => 'Medium';

  @override
  String get drawWidthThick => 'Thick';

  @override
  String get pdfModeScreenTapHint =>
      'Tap the right half for next page, left for previous.';

  @override
  String get pdfModeScreenColorFilterTitle => 'Color filter';

  @override
  String get scoreMenuQuickBarBookmarks => 'Bookmarks';

  @override
  String get scoreMenuQuickBarDraw => 'Draw';

  @override
  String get scoreMenuQuickBarExitDraw => 'Exit draw';

  @override
  String get scoreMenuQuickBarMetronome => 'Metronome';

  @override
  String get scoreMenuQuickBarMetronomeRunning => 'Metronome (running)';

  @override
  String get pdfModeScreenExporting => 'Exporting PDF…';

  @override
  String get pdfModeScreenExportReady => 'Export ready — share sheet opened';

  @override
  String pdfModeScreenExportRestartHint(String path) {
    return 'Exported to $path. Fully restart the app (stop + flutter run) to enable the share sheet.';
  }

  @override
  String pdfModeScreenExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String pdfModeScreenPieceIndex(int index) {
    return '$index.';
  }

  @override
  String get pdfModeScreenHidePieceNotes => 'Hide piece notes';

  @override
  String get pdfModeScreenShowPieceNotes => 'Show piece notes';

  @override
  String get pdfModeScreenPieceNotes => 'Piece notes';

  @override
  String get libraryScreenSort => 'Sort';

  @override
  String get libraryScreenFilter => 'Filter';

  @override
  String get libraryScreenManageLabels => 'Manage Labels';

  @override
  String get libraryScreenMore => 'More';

  @override
  String get libraryScreenAppearance => 'Appearance…';

  @override
  String get libraryScreenLanguage => 'Language…';

  @override
  String get libraryScreenBackup => 'Backup…';

  @override
  String get libraryScreenRestore => 'Restore…';

  @override
  String libraryScreenAbout(String productName) {
    return 'About $productName…';
  }

  @override
  String libraryScreenSplitIntoPiecesSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pieces',
      one: 'piece',
    );
    return 'Split into $count $_temp0';
  }

  @override
  String get libraryScreenStillReadingPdf =>
      'Still reading this PDF — try again in a moment.';

  @override
  String get libraryScreenEditPiecesAppBarTitle => 'Edit pieces';

  @override
  String libraryScreenUpdatedPieces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pieces',
      one: 'piece',
    );
    return 'Updated to $count $_temp0.';
  }

  @override
  String get libraryScreenEditPiecesDialogTitle => 'Remove piece data?';

  @override
  String libraryScreenEditPiecesBody(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'their',
      one: 'its',
    );
    return '$names will be removed, along with $_temp0 annotations, bookmarks, jump links, Labels, and Setlist membership.';
  }

  @override
  String get libraryScreenSplitIntoPiecesDialogTitle => 'Split into pieces?';

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
      other: 'pages',
      one: 'page',
    );
    return 'Narrowing “$title” to pages $firstPage–$lastPage will drop $dropping $_temp0 from its page order.';
  }

  @override
  String get libraryScreenSplitConfirm => 'Split';

  @override
  String get libraryScreenChangePagesTitle => 'Change pages?';

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
      other: 'pages',
      one: 'page',
    );
    return 'Changing “$title” to pages $firstPage–$lastPage will drop $dropping $_temp0 from its page order.';
  }

  @override
  String get libraryScreenChangePagesConfirm => 'Change';

  @override
  String get libraryScreenSetlistEmptyAddScores =>
      'Add scores to this setlist first.';

  @override
  String get libraryScreenNoScoresAvailable =>
      'None of the scores in this setlist could be found.';

  @override
  String libraryScreenSkippedMissingScores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'scores',
      one: 'score',
    );
    return 'Skipped $count missing $_temp0.';
  }

  @override
  String get libraryScreenNewSetlist => 'New setlist';

  @override
  String get libraryScreenDeleteSetlistTitle => 'Delete setlist?';

  @override
  String libraryScreenDeleteSetlistBody(String title) {
    return 'Delete “$title”? The scores in it are not affected.';
  }

  @override
  String libraryScreenDeleteScoreBody(String title) {
    return 'Delete “$title”? This can\'t be undone.';
  }

  @override
  String libraryScreenDeleteScoreWithPiecesBody(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pieces',
      one: 'piece',
    );
    return 'Delete “$title” and its $count $_temp0? This can\'t be undone.';
  }

  @override
  String get libraryScreenDeleteScoreTitle => 'Delete score?';

  @override
  String get libraryScreenTabScores => 'Scores';

  @override
  String get libraryScreenTabSetlists => 'Setlists';

  @override
  String get libraryScreenSearchHint => 'Search scores';

  @override
  String get libraryScreenAddPdf => 'Add PDF';

  @override
  String libraryScreenSplitSuggestionWithPages(String name, int pages) {
    return '“$name” ($pages pages) looks like it could be several pieces.';
  }

  @override
  String libraryScreenSplitSuggestionGeneric(String name) {
    return '“$name” looks like it could be several pieces.';
  }

  @override
  String get libraryScreenNotNow => 'Not now';

  @override
  String get libraryScreenSplitEllipsis => 'Split…';

  @override
  String libraryScreenFailedToOpen(String error) {
    return 'Couldn\'t open the library: $error';
  }

  @override
  String get libraryScreenNoScoresYet => 'No scores yet';

  @override
  String get libraryScreenImportPdfHint => 'Import a PDF to get started.';

  @override
  String get libraryScreenAddSampleScore => 'Add sample score';

  @override
  String libraryScreenNoScoresMatchSearch(String query) {
    return 'No scores match “$query”.';
  }

  @override
  String libraryScreenNoScoresMatchFilter(String filter) {
    return 'No scores match $filter.';
  }

  @override
  String get libraryScreenClearSearch => 'Clear search';

  @override
  String get libraryScreenClearFilter => 'Clear filter';

  @override
  String libraryScreenRecencyWithPieces(String when, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pieces',
      one: 'piece',
    );
    return '$when · $count $_temp0';
  }

  @override
  String get libraryScreenPiecesEllipsis => 'Pieces…';

  @override
  String get libraryScreenEditPiecesMenuItem => 'Edit pieces…';

  @override
  String get libraryScreenOpenFullScore => 'Open full score';

  @override
  String get libraryScreenRenameEllipsis => 'Rename…';

  @override
  String get libraryScreenLabelsEllipsis => 'Labels…';

  @override
  String get libraryScreenSplitIntoPiecesEllipsis => 'Split into pieces…';

  @override
  String get libraryScreenPagesEllipsis => 'Pages…';

  @override
  String get libraryScreenReplacePdfEllipsis => 'Replace PDF…';

  @override
  String get libraryScreenDeleteEllipsis => 'Delete…';

  @override
  String libraryScreenAddedRelative(String when) {
    return 'Added $when';
  }

  @override
  String libraryScreenOpenedRelative(String when) {
    return 'Opened $when';
  }

  @override
  String libraryScreenRecencyWithPages(String when, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: 'pages',
      one: 'page',
    );
    return '$when · $pages $_temp0';
  }

  @override
  String get libraryScreenNoSetlistsYet => 'No setlists yet';

  @override
  String get libraryScreenSetlistsEmptyHint =>
      'Group scores for continuous performance without reopening each piece.';

  @override
  String libraryScreenSetlistScoreCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'scores',
      one: 'score',
    );
    return '$count $_temp0';
  }

  @override
  String get libraryScreenSetlistCountEmpty => 'Empty';

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
  String get metronomeSheetMeter => 'Meter';

  @override
  String get metronomeSheetMeterHint => 'How beats are grouped in each bar';

  @override
  String get metronomeSheetEqual => 'Equal';

  @override
  String get metronomeSheetMute => 'Mute';

  @override
  String get metronomeSheetShowBeats => 'Show beats';

  @override
  String get metronomeSheetShowBeatsHint =>
      'Flash the beat on the score while it plays';

  @override
  String metronomeSheetVolume(int percent) {
    return 'Volume: $percent%';
  }

  @override
  String get metronomeSheetStop => 'Stop';

  @override
  String get metronomeSheetStart => 'Start';

  @override
  String get metronomeSheetEnterNumber => 'Enter a number';

  @override
  String get metronomeSheetTempoDialogTitle => 'Set tempo';

  @override
  String get pageExtentScreenTitle => 'Pages';

  @override
  String pageExtentScreenFirstPage(int page) {
    return 'First page: $page';
  }

  @override
  String pageExtentScreenLastPage(int page) {
    return 'Last page: $page';
  }

  @override
  String get pageExtentScreenNoPages => 'No pages';

  @override
  String get pageExtentScreenBadgeOnly => 'Only';

  @override
  String get pageExtentScreenBadgeFirst => 'First';

  @override
  String get pageExtentScreenBadgeLast => 'Last';

  @override
  String pageExtentScreenSummary(String title, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: 'pages',
      one: 'page',
    );
    return '$title — $pages $_temp0';
  }

  @override
  String get pageExtentScreenHint =>
      'Tap a page below to set the selected boundary.';

  @override
  String get pageNavBarPreviousPageTooltip => 'Previous page';

  @override
  String get pageNavBarNextPageTooltip => 'Next page';

  @override
  String pageNavBarJumpedSnackbar(int page, int count) {
    return 'Jumped to page $page of $count';
  }

  @override
  String get pageNavBarGoToPageTitle => 'Go to page';

  @override
  String pageNavBarPageFieldLabel(int count) {
    return 'Page (1–$count)';
  }

  @override
  String get piecesScreenEditPieces => 'Edit pieces…';

  @override
  String get piecesScreenNoPieces => 'No pieces';

  @override
  String get piecesScreenRename => 'Rename…';

  @override
  String get piecesScreenLabels => 'Labels…';

  @override
  String get piecesScreenSplitIntoPieces => 'Split into pieces…';

  @override
  String get piecesScreenPages => 'Pages…';

  @override
  String get piecesScreenReplacePdf => 'Replace PDF…';

  @override
  String get piecesScreenDelete => 'Delete…';

  @override
  String piecesScreenAdded(String when) {
    return 'Added $when';
  }

  @override
  String piecesScreenOpened(String when) {
    return 'Opened $when';
  }

  @override
  String piecesScreenRecencyWithPages(String when, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: 'pages',
      one: 'page',
    );
    return '$when · $pages $_temp0';
  }

  @override
  String piecesScreenPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pieces',
      one: 'piece',
    );
    return '$count $_temp0';
  }

  @override
  String piecesScreenPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pages',
      one: 'page',
    );
    return '$count $_temp0';
  }

  @override
  String get piecesScreenOpenFullScore => 'Open full score';

  @override
  String get setlistEditorImportFirst => 'Import a score first.';

  @override
  String get setlistEditorDefaultTitle => 'New setlist';

  @override
  String get setlistEditorAppBarTitle => 'Edit setlist';

  @override
  String get setlistEditorAddScores => 'Add scores';

  @override
  String get setlistEditorTitleFieldLabel => 'Title';

  @override
  String get setlistEditorEmpty =>
      'No scores yet. Tap Add scores to build the setlist.';

  @override
  String get setlistEditorMissingScore => 'Missing score';

  @override
  String get setlistEditorRemovedFromLibrary => 'Removed from library';

  @override
  String get setlistEditorRemoveTooltip => 'Remove';

  @override
  String setlistEditorAddCount(int count) {
    return 'Add ($count)';
  }

  @override
  String setlistEditorPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pieces',
      one: 'piece',
    );
    return '$count $_temp0';
  }

  @override
  String get setlistEditorPiecesTooltip => 'View pieces';

  @override
  String get splitScoreScreenRenameTitle => 'Rename';

  @override
  String get splitScoreScreenTitle => 'Split into pieces';

  @override
  String get splitScoreScreenClearMarks => 'Clear marks';

  @override
  String get splitScoreScreenNoPages => 'No pages';

  @override
  String splitScoreScreenPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces',
      one: '1 piece',
      zero: 'No pieces yet',
    );
    return '$_temp0';
  }

  @override
  String get splitScoreScreenHint =>
      'Tap a page to mark where a new piece begins. Long-press a marked page to rename it.';

  @override
  String splitScoreScreenFrontMatterPage(int page) {
    return 'Page $page is front matter and won\'t belong to any piece.';
  }

  @override
  String splitScoreScreenFrontMatterPages(int first, int last) {
    return 'Pages $first–$last are front matter and won\'t belong to any piece.';
  }

  @override
  String splitScoreScreenUseContents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Use table of contents ($count $_temp0)';
  }

  @override
  String get libraryScreenNoPdfFiles => 'No PDF files found.';

  @override
  String libraryScreenImportedScores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'scores',
      one: 'score',
    );
    return 'Imported $count $_temp0';
  }

  @override
  String get libraryScreenCreateBackupTitle => 'Create backup?';

  @override
  String get libraryScreenCreateBackupBody =>
      'This saves a copy of your entire library — scores, labels, setlists, and settings — as a zip file you can share or store somewhere safe.';

  @override
  String get libraryScreenCreateBackupConfirm => 'Create backup';

  @override
  String get libraryScreenCreatingBackup => 'Creating backup…';

  @override
  String get libraryScreenBackupShareSubject => 'StageScore backup';

  @override
  String libraryScreenBackupSaved(String path) {
    return 'Backup saved to $path';
  }

  @override
  String get libraryScreenBackupReady => 'Backup ready — share sheet opened';

  @override
  String libraryScreenBackupFailed(String error) {
    return 'Could not create backup: $error';
  }

  @override
  String get libraryScreenRestoreBackupTitle => 'Restore backup?';

  @override
  String get libraryScreenRestoreBackupBody =>
      'This replaces your entire library — scores, labels, setlists, and settings — with the contents of the backup. This cannot be undone.';

  @override
  String get libraryScreenReplaceAll => 'Replace all';

  @override
  String get libraryScreenRestoringBackup => 'Restoring backup…';

  @override
  String get libraryScreenLibraryRestored => 'Library restored';

  @override
  String libraryScreenRestoreFailed(String error) {
    return 'Could not restore backup: $error';
  }

  @override
  String libraryScreenPercentValue(int percent) {
    return '$percent%';
  }

  @override
  String get libraryScreenUntagged => 'Untagged';

  @override
  String get libraryScreenThisFilter => 'this filter';

  @override
  String get libraryScreenAndConjunction => 'and';

  @override
  String get libraryScreenAllOf => 'All of';

  @override
  String libraryScreenRemoveFilterChip(String label) {
    return 'Remove $label filter';
  }

  @override
  String get libraryScreenRenameScoreTitle => 'Rename score';

  @override
  String get libraryScreenReplacePdfTitle => 'Replace PDF?';

  @override
  String libraryScreenReplacePdfBodyShared(
    int sharing,
    String title,
    int others,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: 'pieces',
      one: 'piece',
    );
    return 'This PDF is shared by $sharing pieces, including “$title”. Replacing it will also change it for the other $others $_temp0.';
  }

  @override
  String libraryScreenReplacePdfBodySingle(String title) {
    return 'Replace the PDF behind “$title”? You can keep or reset its annotations below.';
  }

  @override
  String get libraryScreenKeepOverlays => 'Keep annotations';

  @override
  String get libraryScreenResetOverlays => 'Reset annotations';

  @override
  String get libraryScreenOverlaysReset => 'Annotations reset.';

  @override
  String get libraryScreenOverlaysKept => 'Annotations kept.';

  @override
  String libraryScreenPdfReplaced(String overlayNote) {
    return 'PDF replaced. $overlayNote';
  }

  @override
  String libraryScreenPdfReplacedShortened(String overlayNote, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'page entries were',
      one: 'page entry was',
    );
    return 'PDF replaced. $overlayNote The new file is shorter, so $count $_temp0 dropped.';
  }

  @override
  String libraryScreenReplaceFailed(String error) {
    return 'Could not replace PDF: $error';
  }

  @override
  String continuousPageOrderViewOpenFailed(String error) {
    return 'Could not open PDF: $error';
  }

  @override
  String get performancePageSlotBlank => 'Blank';

  @override
  String performancePageSlotMissingPage(int page) {
    return 'Missing page $page';
  }

  @override
  String singlePageSliderOpenFailed(String error) {
    return 'Could not open PDF: $error';
  }

  @override
  String aboutSheetVersion(String version) {
    return 'Version $version';
  }

  @override
  String aboutSheetVersionWithBuild(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String aboutSheetLinkOpenFailed(String url) {
    return 'Could not open link: $url';
  }

  @override
  String aboutSheetTitle(String productName) {
    return 'About $productName';
  }

  @override
  String get aboutSheetWebsiteLabel => 'Website';

  @override
  String get aboutSheetPrivacyLabel => 'Privacy';

  @override
  String get aboutSheetSupportLabel => 'Support';

  @override
  String get bookmarksSheetAddTitle => 'Add bookmark';

  @override
  String bookmarksSheetPageLabel(int page) {
    return 'Page $page';
  }

  @override
  String get bookmarksSheetRenameTitle => 'Rename bookmark';

  @override
  String get bookmarksSheetTitle => 'Bookmarks';

  @override
  String get bookmarksSheetEmpty => 'No bookmarks yet';

  @override
  String get displaySheetBorderColorTitle => 'Border color';

  @override
  String displaySheetHue(int value) {
    return 'Hue: $value';
  }

  @override
  String displaySheetSaturation(int value) {
    return 'Saturation: $value';
  }

  @override
  String displaySheetColorValue(int value) {
    return 'Value: $value';
  }

  @override
  String get displaySheetTitle => 'Display';

  @override
  String get displaySheetPerformanceMode => 'Performance mode';

  @override
  String get displaySheetPageBorder => 'Page border';

  @override
  String displaySheetThickness(String value) {
    return 'Thickness: $value';
  }

  @override
  String get displaySheetColorLabel => 'Color';

  @override
  String get displaySheetCustomChip => 'Custom';

  @override
  String get displaySheetShowStatusBar => 'Show status bar';

  @override
  String get displaySheetShowStatusBarHint =>
      'Keep the clock and battery visible while you play';

  @override
  String get displaySheetAvoidNotches => 'Avoid notches';

  @override
  String get displaySheetAvoidNotchesHint =>
      'Keep the page clear of the camera notch and rounded corners';

  @override
  String get jumpLinkEditSheetAddTitle => 'Add jump link';

  @override
  String get jumpLinkEditSheetEditTitle => 'Edit jump link';

  @override
  String jumpLinkEditSheetOriginLabel(int page) {
    return 'From page $page';
  }

  @override
  String jumpLinkEditSheetDestinationLabel(int page, int pageCount) {
    return 'To page $page of $pageCount';
  }

  @override
  String get jumpLinkEditSheetColorLabel => 'Color';

  @override
  String get jumpLinkEditSheetSizeLabel => 'Size';

  @override
  String get jumpLinksSheetDragHint =>
      'Added. Drag a jump link in the list to reorder it.';

  @override
  String get jumpLinksSheetTitle => 'Jump Links';

  @override
  String get jumpLinksSheetEmpty => 'No jump links yet';

  @override
  String jumpLinksSheetRowTitle(int from, int to) {
    return 'Page $from → $to';
  }

  @override
  String get jumpLinksSheetRowSubtitle => 'Tap to jump to this link';

  @override
  String labelSheetsTitle(String title) {
    return 'Labels for $title';
  }

  @override
  String get labelSheetsManage => 'Manage';

  @override
  String get labelSheetsCreateLabel => 'Create Label';

  @override
  String get labelSheetsNewLabel => 'New Label';

  @override
  String get labelSheetsManageTitle => 'Manage Labels';

  @override
  String get labelSheetsNoLabelsYet => 'No Labels yet';

  @override
  String labelSheetsUsageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Scores',
      one: 'Score',
    );
    return 'Used by $count $_temp0';
  }

  @override
  String get labelSheetsDeleteTitle => 'Delete Label?';

  @override
  String labelSheetsDeleteConfirm(String name) {
    return 'Delete “$name”?';
  }

  @override
  String labelSheetsDeleteConfirmWithUsage(String name, int usage) {
    String _temp0 = intl.Intl.pluralLogic(
      usage,
      locale: localeName,
      other: 'Scores',
      one: 'Score',
    );
    return '“$name” is used by $usage $_temp0. Delete anyway?';
  }

  @override
  String get labelSheetsRenameLabelTitle => 'Rename Label';

  @override
  String get labelSheetsNameHint => 'Label name';

  @override
  String get libraryFilterSheetTitle => 'Filter';

  @override
  String get libraryFilterSheetModeAny => 'Any';

  @override
  String get libraryFilterSheetModeAll => 'All';

  @override
  String get libraryFilterSheetModeUntagged => 'Untagged';

  @override
  String get libraryFilterSheetUntaggedHint => 'Scores with no Labels';

  @override
  String get libraryFilterSheetEmptyLabels => 'No Labels to filter by yet';

  @override
  String get measureMapMeasureCountTitle => 'How many MeasureBoxes?';

  @override
  String get measureMapMeasureCountLabel => 'MeasureBoxes';

  @override
  String get measureMapGoToTitle => 'Go to measure';

  @override
  String get measureMapGoToLabel => 'Measure number';

  @override
  String measureMapGoToMissing(int number) {
    return 'Measure $number is not mapped yet';
  }

  @override
  String get measureMapMetaTitle => 'Tempo & time signature';

  @override
  String get measureMapTimeSignatureLabel => 'Time signature';

  @override
  String get measureMapTempoLabel => 'Tempo';

  @override
  String get measureMapMetaScopeTitle => 'Apply to';

  @override
  String get measureMapScopeThisMeasure => 'This measure only';

  @override
  String get measureMapScopeThisSystem => 'This system';

  @override
  String get measureMapScopeThisPage => 'This page';

  @override
  String get measureMapScopeRestOfScore => 'Rest of score';

  @override
  String get measureMapScopeNextN => 'Next N…';

  @override
  String get measureMapMetaNextNLabel => 'Number of measures';

  @override
  String get measureMapClearTitle => 'Clear MeasureMap?';

  @override
  String get measureMapClearBody =>
      'Delete every SystemBox and MeasureBox for this Score. This cannot be undone.';

  @override
  String get measureMapClearConfirm => 'Clear';

  @override
  String get measureMapDeleteSystemTitle => 'Delete system?';

  @override
  String get measureMapDeleteSystemBody =>
      'Delete this SystemBox and all its MeasureBoxes.';

  @override
  String get measureMapCopyFromPageTitle => 'Copy layout from page';

  @override
  String get measureMapCopyFromPageLabel => 'Source page';

  @override
  String get measureMapCopyPrevious => 'Copy previous page';

  @override
  String get measureMapEmptyHint =>
      'Draw a system — the app will ask how many measures';

  @override
  String get measureMapDone => 'Done';

  @override
  String get measureMapEditBeats => 'Edit beats';

  @override
  String get measureMapSetMeasureCount => 'Set measure count…';

  @override
  String get measureMapDeleteSystem => 'Delete system';

  @override
  String get measureMapDeleteMeasure => 'Delete measure';

  @override
  String get measureMapEditMeta => 'Tempo & time signature…';

  @override
  String get measureMapClearAll => 'Clear MeasureMap…';
}
