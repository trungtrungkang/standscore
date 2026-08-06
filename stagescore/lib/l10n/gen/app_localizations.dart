import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('vi'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @actionApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get actionApply;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get actionRename;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get actionMore;

  /// No description provided for @actionGo.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get actionGo;

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionReset;

  /// No description provided for @commonOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get commonOr;

  /// No description provided for @commonTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get commonTitleLabel;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @pdfLayoutModeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get pdfLayoutModeAuto;

  /// No description provided for @pdfLayoutModeSingle.
  ///
  /// In en, this message translates to:
  /// **'One page'**
  String get pdfLayoutModeSingle;

  /// No description provided for @pdfLayoutModeTwoPages.
  ///
  /// In en, this message translates to:
  /// **'Two pages'**
  String get pdfLayoutModeTwoPages;

  /// No description provided for @pdfLayoutModeScroll.
  ///
  /// In en, this message translates to:
  /// **'Scroll'**
  String get pdfLayoutModeScroll;

  /// No description provided for @pdfLayoutModeScrollSideways.
  ///
  /// In en, this message translates to:
  /// **'Scroll (sideways)'**
  String get pdfLayoutModeScrollSideways;

  /// No description provided for @pdfLayoutModeHalfPageTopBottom.
  ///
  /// In en, this message translates to:
  /// **'One page + peek'**
  String get pdfLayoutModeHalfPageTopBottom;

  /// No description provided for @pdfLayoutModeHalfPageLeftRight.
  ///
  /// In en, this message translates to:
  /// **'One page + side peek'**
  String get pdfLayoutModeHalfPageLeftRight;

  /// No description provided for @pageColorFilterOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get pageColorFilterOff;

  /// No description provided for @pageColorFilterSepia.
  ///
  /// In en, this message translates to:
  /// **'Sepia'**
  String get pageColorFilterSepia;

  /// No description provided for @pageColorFilterGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get pageColorFilterGreen;

  /// No description provided for @pageColorFilterInvert.
  ///
  /// In en, this message translates to:
  /// **'Invert'**
  String get pageColorFilterInvert;

  /// No description provided for @pageScaleScopeFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get pageScaleScopeFixed;

  /// No description provided for @pageScaleScopePerScore.
  ///
  /// In en, this message translates to:
  /// **'Per Score'**
  String get pageScaleScopePerScore;

  /// No description provided for @pageScaleScopePerPage.
  ///
  /// In en, this message translates to:
  /// **'Per Page'**
  String get pageScaleScopePerPage;

  /// No description provided for @stagePresetSetUpToPlay.
  ///
  /// In en, this message translates to:
  /// **'Set up to play'**
  String get stagePresetSetUpToPlay;

  /// No description provided for @stagePresetSetUpToPractise.
  ///
  /// In en, this message translates to:
  /// **'Set up to practise'**
  String get stagePresetSetUpToPractise;

  /// No description provided for @stagePresetChromeHidden.
  ///
  /// In en, this message translates to:
  /// **'chrome hidden'**
  String get stagePresetChromeHidden;

  /// No description provided for @stagePresetChromeShown.
  ///
  /// In en, this message translates to:
  /// **'chrome shown'**
  String get stagePresetChromeShown;

  /// No description provided for @stagePresetStatusBarShown.
  ///
  /// In en, this message translates to:
  /// **'status bar shown'**
  String get stagePresetStatusBarShown;

  /// No description provided for @stagePresetStatusBarHidden.
  ///
  /// In en, this message translates to:
  /// **'status bar hidden'**
  String get stagePresetStatusBarHidden;

  /// No description provided for @stagePresetScaleKept.
  ///
  /// In en, this message translates to:
  /// **'scale kept'**
  String get stagePresetScaleKept;

  /// No description provided for @stagePresetPinchFree.
  ///
  /// In en, this message translates to:
  /// **'pinch free'**
  String get stagePresetPinchFree;

  /// No description provided for @relativeDayToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get relativeDayToday;

  /// No description provided for @relativeDayYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get relativeDayYesterday;

  /// No description provided for @relativeDayDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} {days, plural, =1{day} other{days}} ago'**
  String relativeDayDaysAgo(int days);

  /// No description provided for @pageOrderEditorEntryBlank.
  ///
  /// In en, this message translates to:
  /// **'{index}. Blank'**
  String pageOrderEditorEntryBlank(int index);

  /// No description provided for @pageOrderEditorEntryPdfPage.
  ///
  /// In en, this message translates to:
  /// **'{index}. PDF page {sourcePage}'**
  String pageOrderEditorEntryPdfPage(int index, int sourcePage);

  /// No description provided for @pageOrderEditorResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset to original?'**
  String get pageOrderEditorResetTitle;

  /// No description provided for @pageOrderEditorResetBody.
  ///
  /// In en, this message translates to:
  /// **'Restore the PDF page order and remove blanks and duplicates?'**
  String get pageOrderEditorResetBody;

  /// No description provided for @pageOrderEditorReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get pageOrderEditorReset;

  /// No description provided for @pageOrderEditorAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Page order'**
  String get pageOrderEditorAppBarTitle;

  /// No description provided for @pageOrderEditorNoPages.
  ///
  /// In en, this message translates to:
  /// **'No pages'**
  String get pageOrderEditorNoPages;

  /// No description provided for @pageOrderEditorDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get pageOrderEditorDuplicate;

  /// No description provided for @pageOrderEditorInsertBlank.
  ///
  /// In en, this message translates to:
  /// **'Insert blank'**
  String get pageOrderEditorInsertBlank;

  /// No description provided for @pageOrderEditorRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get pageOrderEditorRemove;

  /// No description provided for @librarySortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get librarySortTitle;

  /// No description provided for @librarySortCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get librarySortCreated;

  /// No description provided for @librarySortLastViewed.
  ///
  /// In en, this message translates to:
  /// **'Last viewed'**
  String get librarySortLastViewed;

  /// No description provided for @scoreOriginPage.
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String scoreOriginPage(int page);

  /// No description provided for @scoreOriginPages.
  ///
  /// In en, this message translates to:
  /// **'Pages {first}–{last}'**
  String scoreOriginPages(int first, int last);

  /// No description provided for @scoreOriginPagesOfBook.
  ///
  /// In en, this message translates to:
  /// **'{pages} of {name}'**
  String scoreOriginPagesOfBook(String pages, String name);

  /// No description provided for @libraryVisibilityInBook.
  ///
  /// In en, this message translates to:
  /// **'in {title}'**
  String libraryVisibilityInBook(String title);

  /// No description provided for @libraryVisibilityInBookFallback.
  ///
  /// In en, this message translates to:
  /// **'in book'**
  String get libraryVisibilityInBookFallback;

  /// No description provided for @libraryBackupFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Backup file not found.'**
  String get libraryBackupFileNotFound;

  /// No description provided for @libraryBackupFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Backup failed.'**
  String get libraryBackupFailedGeneric;

  /// No description provided for @libraryBackupCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create backup: {error}'**
  String libraryBackupCreateFailed(String error);

  /// No description provided for @libraryBackupRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not restore backup: {error}'**
  String libraryBackupRestoreFailed(String error);

  /// No description provided for @libraryBackupMissingMarker.
  ///
  /// In en, this message translates to:
  /// **'Not a StageScore backup (missing marker).'**
  String get libraryBackupMissingMarker;

  /// No description provided for @libraryBackupUnknownFormat.
  ///
  /// In en, this message translates to:
  /// **'Not a StageScore backup (unknown format).'**
  String get libraryBackupUnknownFormat;

  /// No description provided for @libraryBackupUnsupportedVersion.
  ///
  /// In en, this message translates to:
  /// **'Unsupported StageScore backup version.'**
  String get libraryBackupUnsupportedVersion;

  /// No description provided for @libraryBackupCorruptMarker.
  ///
  /// In en, this message translates to:
  /// **'Not a StageScore backup (corrupt marker).'**
  String get libraryBackupCorruptMarker;

  /// No description provided for @gestureMapLongPress.
  ///
  /// In en, this message translates to:
  /// **'long-press'**
  String get gestureMapLongPress;

  /// No description provided for @gestureMapTapTopEdge.
  ///
  /// In en, this message translates to:
  /// **'tap the top edge'**
  String get gestureMapTapTopEdge;

  /// No description provided for @gestureMapTapBottomEdge.
  ///
  /// In en, this message translates to:
  /// **'tap the bottom edge'**
  String get gestureMapTapBottomEdge;

  /// No description provided for @gestureMapEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Set a gesture to Show menu / chrome to reveal it.'**
  String get gestureMapEmptyHint;

  /// No description provided for @gestureMapRevealHint.
  ///
  /// In en, this message translates to:
  /// **'Hide the toolbar and page bar while you play. To bring them back, {joined}.'**
  String gestureMapRevealHint(String joined);

  /// No description provided for @layoutNavigationPedalOrPageBar.
  ///
  /// In en, this message translates to:
  /// **'Pedal or the page bar'**
  String get layoutNavigationPedalOrPageBar;

  /// No description provided for @layoutNavigationTapLeftRight.
  ///
  /// In en, this message translates to:
  /// **'tap left / right'**
  String get layoutNavigationTapLeftRight;

  /// No description provided for @layoutNavigationTapTopBottom.
  ///
  /// In en, this message translates to:
  /// **'tap top / bottom'**
  String get layoutNavigationTapTopBottom;

  /// No description provided for @layoutNavigationTapAnywhere.
  ///
  /// In en, this message translates to:
  /// **'tap anywhere'**
  String get layoutNavigationTapAnywhere;

  /// No description provided for @layoutNavigationTapAnywhereBack.
  ///
  /// In en, this message translates to:
  /// **'tap anywhere to go back'**
  String get layoutNavigationTapAnywhereBack;

  /// No description provided for @layoutNavigationSwipe.
  ///
  /// In en, this message translates to:
  /// **'swipe'**
  String get layoutNavigationSwipe;

  /// No description provided for @layoutNavigationSwipeSideways.
  ///
  /// In en, this message translates to:
  /// **'swipe sideways'**
  String get layoutNavigationSwipeSideways;

  /// No description provided for @layoutNavigationSwipeUpDown.
  ///
  /// In en, this message translates to:
  /// **'swipe up / down'**
  String get layoutNavigationSwipeUpDown;

  /// No description provided for @scoreMenuSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get scoreMenuSheetTitle;

  /// No description provided for @appearanceSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSheetTitle;

  /// No description provided for @appearanceSheetMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get appearanceSheetMode;

  /// No description provided for @appearanceSheetThemeColor.
  ///
  /// In en, this message translates to:
  /// **'Theme color'**
  String get appearanceSheetThemeColor;

  /// No description provided for @appearanceSheetCustomChip.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get appearanceSheetCustomChip;

  /// No description provided for @appearanceSheetCustomColorDialog.
  ///
  /// In en, this message translates to:
  /// **'Custom color'**
  String get appearanceSheetCustomColorDialog;

  /// No description provided for @appearanceSheetHue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get appearanceSheetHue;

  /// No description provided for @appearanceSheetSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get appearanceSheetSat;

  /// No description provided for @appearanceSheetVal.
  ///
  /// In en, this message translates to:
  /// **'Val'**
  String get appearanceSheetVal;

  /// No description provided for @scoreMenuGoTo.
  ///
  /// In en, this message translates to:
  /// **'Go to'**
  String get scoreMenuGoTo;

  /// No description provided for @scoreMenuBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get scoreMenuBookmarks;

  /// No description provided for @scoreMenuJumpLinks.
  ///
  /// In en, this message translates to:
  /// **'Jump Links'**
  String get scoreMenuJumpLinks;

  /// No description provided for @scoreMenuPageOrder.
  ///
  /// In en, this message translates to:
  /// **'Page order…'**
  String get scoreMenuPageOrder;

  /// No description provided for @scoreMenuGoToMeasure.
  ///
  /// In en, this message translates to:
  /// **'Go to measure…'**
  String get scoreMenuGoToMeasure;

  /// No description provided for @scoreMenuMeasureMap.
  ///
  /// In en, this message translates to:
  /// **'Measure map…'**
  String get scoreMenuMeasureMap;

  /// No description provided for @scoreMenuFormMap.
  ///
  /// In en, this message translates to:
  /// **'Form map…'**
  String get scoreMenuFormMap;

  /// No description provided for @scoreMenuFormMapNeedsMeasureMap.
  ///
  /// In en, this message translates to:
  /// **'Map measures first'**
  String get scoreMenuFormMapNeedsMeasureMap;

  /// No description provided for @formMapEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'No form = play straight through once. Add a repeat (with optional 1st/2nd ending) or tap a MeasureBox for markers/jumps. Jump Links are different — they jump pages by hand.'**
  String get formMapEmptyHint;

  /// No description provided for @formMapDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get formMapDone;

  /// No description provided for @formMapAddRepeat.
  ///
  /// In en, this message translates to:
  /// **'Add repeat…'**
  String get formMapAddRepeat;

  /// No description provided for @formMapReplaceRepeatTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace existing repeat?'**
  String get formMapReplaceRepeatTitle;

  /// No description provided for @formMapReplaceRepeatBody.
  ///
  /// In en, this message translates to:
  /// **'This Score already has a repeat that overlaps these measures. Replace it with the new one?'**
  String get formMapReplaceRepeatBody;

  /// No description provided for @formMapReplaceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get formMapReplaceConfirm;

  /// No description provided for @formMapVoltaSection.
  ///
  /// In en, this message translates to:
  /// **'1st / 2nd ending (optional)'**
  String get formMapVoltaSection;

  /// No description provided for @formMapVoltaHint.
  ///
  /// In en, this message translates to:
  /// **'Leave blank for a plain repeat. Example: first time play 8 then go back; second time skip 8 → set pass 1 to 8 and pass 2 to 9.'**
  String get formMapVoltaHint;

  /// No description provided for @formMapPass1Label.
  ///
  /// In en, this message translates to:
  /// **'Pass 1 only (1st ending)'**
  String get formMapPass1Label;

  /// No description provided for @formMapPass2Label.
  ///
  /// In en, this message translates to:
  /// **'Pass 2 only (2nd ending)'**
  String get formMapPass2Label;

  /// No description provided for @formMapAddEnding.
  ///
  /// In en, this message translates to:
  /// **'1st / 2nd ending…'**
  String get formMapAddEnding;

  /// No description provided for @formMapEndingHint.
  ///
  /// In en, this message translates to:
  /// **'Volta brackets on the page — measures played only on one pass through a repeat. Example: first time play measure 8 then go back; second time skip 8 and continue at 9 → mark 8 as pass 1.'**
  String get formMapEndingHint;

  /// No description provided for @formMapEndingNumberHint.
  ///
  /// In en, this message translates to:
  /// **'1 = first time through the repeat, 2 = second time, …'**
  String get formMapEndingNumberHint;

  /// No description provided for @formMapSetMarker.
  ///
  /// In en, this message translates to:
  /// **'Marker…'**
  String get formMapSetMarker;

  /// No description provided for @formMapSetJump.
  ///
  /// In en, this message translates to:
  /// **'Jump…'**
  String get formMapSetJump;

  /// No description provided for @formMapClearMeasure.
  ///
  /// In en, this message translates to:
  /// **'Clear on measure'**
  String get formMapClearMeasure;

  /// No description provided for @formMapClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear FormMap…'**
  String get formMapClearAll;

  /// No description provided for @formMapClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear FormMap?'**
  String get formMapClearTitle;

  /// No description provided for @formMapClearBody.
  ///
  /// In en, this message translates to:
  /// **'Removes all repeats, endings, markers, and jumps on this Score. Cannot be undone.'**
  String get formMapClearBody;

  /// No description provided for @formMapClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get formMapClearConfirm;

  /// No description provided for @formMapMarkerNone.
  ///
  /// In en, this message translates to:
  /// **'No marker'**
  String get formMapMarkerNone;

  /// No description provided for @formMapMarkerNoneDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear any marker on this measure'**
  String get formMapMarkerNoneDesc;

  /// No description provided for @formMapMarkerSegno.
  ///
  /// In en, this message translates to:
  /// **'Segno'**
  String get formMapMarkerSegno;

  /// No description provided for @formMapMarkerSegnoDesc.
  ///
  /// In en, this message translates to:
  /// **'Landmark on the page. D.S. jumps back here'**
  String get formMapMarkerSegnoDesc;

  /// No description provided for @formMapMarkerCoda.
  ///
  /// In en, this message translates to:
  /// **'Coda'**
  String get formMapMarkerCoda;

  /// No description provided for @formMapMarkerCodaDesc.
  ///
  /// In en, this message translates to:
  /// **'Start of the coda section. To Coda lands here'**
  String get formMapMarkerCodaDesc;

  /// No description provided for @formMapMarkerToCoda.
  ///
  /// In en, this message translates to:
  /// **'To Coda'**
  String get formMapMarkerToCoda;

  /// No description provided for @formMapMarkerToCodaDesc.
  ///
  /// In en, this message translates to:
  /// **'After D.C./D.S. returns, skip ahead to the Coda'**
  String get formMapMarkerToCodaDesc;

  /// No description provided for @formMapMarkerFine.
  ///
  /// In en, this message translates to:
  /// **'Fine'**
  String get formMapMarkerFine;

  /// No description provided for @formMapMarkerFineDesc.
  ///
  /// In en, this message translates to:
  /// **'Stop here after D.C./D.S. returns (ignored on the first pass)'**
  String get formMapMarkerFineDesc;

  /// No description provided for @formMapJumpNone.
  ///
  /// In en, this message translates to:
  /// **'No jump'**
  String get formMapJumpNone;

  /// No description provided for @formMapJumpNoneDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear any jump on this measure'**
  String get formMapJumpNoneDesc;

  /// No description provided for @formMapJumpDaCapo.
  ///
  /// In en, this message translates to:
  /// **'D.C.'**
  String get formMapJumpDaCapo;

  /// No description provided for @formMapJumpDaCapoDesc.
  ///
  /// In en, this message translates to:
  /// **'Da Capo — go back to the start, then follow To Coda / Fine'**
  String get formMapJumpDaCapoDesc;

  /// No description provided for @formMapJumpDalSegno.
  ///
  /// In en, this message translates to:
  /// **'D.S.'**
  String get formMapJumpDalSegno;

  /// No description provided for @formMapJumpDalSegnoDesc.
  ///
  /// In en, this message translates to:
  /// **'Dal Segno — go back to the Segno, then follow To Coda / Fine'**
  String get formMapJumpDalSegnoDesc;

  /// No description provided for @formMapJumpToCoda.
  ///
  /// In en, this message translates to:
  /// **'To Coda'**
  String get formMapJumpToCoda;

  /// No description provided for @formMapJumpToCodaDesc.
  ///
  /// In en, this message translates to:
  /// **'Jump to the Coda marker (only after a D.C. or D.S.)'**
  String get formMapJumpToCodaDesc;

  /// No description provided for @formMapStartMeasure.
  ///
  /// In en, this message translates to:
  /// **'Start measure'**
  String get formMapStartMeasure;

  /// No description provided for @formMapEndMeasure.
  ///
  /// In en, this message translates to:
  /// **'End measure'**
  String get formMapEndMeasure;

  /// No description provided for @formMapRepeatTimes.
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get formMapRepeatTimes;

  /// No description provided for @formMapEndingNumber.
  ///
  /// In en, this message translates to:
  /// **'Which pass?'**
  String get formMapEndingNumber;

  /// No description provided for @formMapInvalidSnackbar.
  ///
  /// In en, this message translates to:
  /// **'FormMap is invalid — fix repeats/jumps before Play'**
  String get formMapInvalidSnackbar;

  /// No description provided for @formMapInvalidMissingMeasure.
  ///
  /// In en, this message translates to:
  /// **'FormMap references a measure that is not mapped'**
  String get formMapInvalidMissingMeasure;

  /// No description provided for @formMapInvalidRepeat.
  ///
  /// In en, this message translates to:
  /// **'FormMap has an invalid repeat region'**
  String get formMapInvalidRepeat;

  /// No description provided for @formMapInvalidEnding.
  ///
  /// In en, this message translates to:
  /// **'FormMap has an invalid ending'**
  String get formMapInvalidEnding;

  /// No description provided for @formMapInvalidLoop.
  ///
  /// In en, this message translates to:
  /// **'FormMap loops too long — check repeats and jumps'**
  String get formMapInvalidLoop;

  /// No description provided for @formMapInvalidEmptyTimeline.
  ///
  /// In en, this message translates to:
  /// **'FormMap produces an empty timeline'**
  String get formMapInvalidEmptyTimeline;

  /// No description provided for @scoreMenuMarks.
  ///
  /// In en, this message translates to:
  /// **'Marks'**
  String get scoreMenuMarks;

  /// No description provided for @scoreMenuHideAnnotations.
  ///
  /// In en, this message translates to:
  /// **'Hide annotations'**
  String get scoreMenuHideAnnotations;

  /// No description provided for @scoreMenuShowAnnotations.
  ///
  /// In en, this message translates to:
  /// **'Show annotations'**
  String get scoreMenuShowAnnotations;

  /// No description provided for @scoreMenuExporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting…'**
  String get scoreMenuExporting;

  /// No description provided for @scoreMenuExportAnnotated.
  ///
  /// In en, this message translates to:
  /// **'Export PDF with annotations'**
  String get scoreMenuExportAnnotated;

  /// No description provided for @scoreMenuView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get scoreMenuView;

  /// No description provided for @scoreMenuLayout.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get scoreMenuLayout;

  /// No description provided for @scoreMenuDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display…'**
  String get scoreMenuDisplay;

  /// No description provided for @scoreMenuColorFilter.
  ///
  /// In en, this message translates to:
  /// **'Color filter…'**
  String get scoreMenuColorFilter;

  /// No description provided for @scoreMenuPageScale.
  ///
  /// In en, this message translates to:
  /// **'Page scale…'**
  String get scoreMenuPageScale;

  /// No description provided for @scoreMenuLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get scoreMenuLocked;

  /// No description provided for @scoreMenuPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get scoreMenuPlaying;

  /// No description provided for @scoreMenuMetronomeRunning.
  ///
  /// In en, this message translates to:
  /// **'Metronome (running)…'**
  String get scoreMenuMetronomeRunning;

  /// No description provided for @scoreMenuMetronome.
  ///
  /// In en, this message translates to:
  /// **'Metronome…'**
  String get scoreMenuMetronome;

  /// No description provided for @scoreMenuShowPlaybackControls.
  ///
  /// In en, this message translates to:
  /// **'Show Playback controls'**
  String get scoreMenuShowPlaybackControls;

  /// No description provided for @scoreMenuHidePlaybackControls.
  ///
  /// In en, this message translates to:
  /// **'Hide Playback controls'**
  String get scoreMenuHidePlaybackControls;

  /// No description provided for @scoreMenuPlaybackSettings.
  ///
  /// In en, this message translates to:
  /// **'Playback settings…'**
  String get scoreMenuPlaybackSettings;

  /// No description provided for @playbackSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Playback settings'**
  String get playbackSettingsTitle;

  /// No description provided for @playbackSettingsPlayhead.
  ///
  /// In en, this message translates to:
  /// **'Playhead'**
  String get playbackSettingsPlayhead;

  /// No description provided for @playbackSettingsPlayheadHint.
  ///
  /// In en, this message translates to:
  /// **'Line on the score while playing'**
  String get playbackSettingsPlayheadHint;

  /// No description provided for @playbackSettingsPlayheadColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get playbackSettingsPlayheadColor;

  /// No description provided for @playbackSettingsPlayheadSize.
  ///
  /// In en, this message translates to:
  /// **'Thickness {value}'**
  String playbackSettingsPlayheadSize(String value);

  /// No description provided for @playbackSettingsPlayheadOpacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity {percent}%'**
  String playbackSettingsPlayheadOpacity(int percent);

  /// No description provided for @playbackSettingsPlayheadHeight.
  ///
  /// In en, this message translates to:
  /// **'Height {percent}% of measure'**
  String playbackSettingsPlayheadHeight(int percent);

  /// No description provided for @scoreMenuPlaybackMapFirst.
  ///
  /// In en, this message translates to:
  /// **'Map measures first'**
  String get scoreMenuPlaybackMapFirst;

  /// No description provided for @scoreMenuPageTurnSettings.
  ///
  /// In en, this message translates to:
  /// **'Page turn settings'**
  String get scoreMenuPageTurnSettings;

  /// No description provided for @playbackControlsPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playbackControlsPlay;

  /// No description provided for @playbackControlsPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get playbackControlsPause;

  /// No description provided for @playbackControlsStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get playbackControlsStop;

  /// No description provided for @playbackControlsCountInBadge.
  ///
  /// In en, this message translates to:
  /// **'Count-in {count}'**
  String playbackControlsCountInBadge(int count);

  /// No description provided for @playbackControlsCountInLabel.
  ///
  /// In en, this message translates to:
  /// **'Count-in'**
  String get playbackControlsCountInLabel;

  /// No description provided for @metronomeSheetPlaybackStyle.
  ///
  /// In en, this message translates to:
  /// **'Controls layout'**
  String get metronomeSheetPlaybackStyle;

  /// No description provided for @metronomeSheetPlaybackStyleHint.
  ///
  /// In en, this message translates to:
  /// **'Bar sits above page chrome; Float is a small draggable Play/Stop'**
  String get metronomeSheetPlaybackStyleHint;

  /// No description provided for @metronomeSheetPlaybackStyleDocked.
  ///
  /// In en, this message translates to:
  /// **'Bar'**
  String get metronomeSheetPlaybackStyleDocked;

  /// No description provided for @metronomeSheetPlaybackStyleFloating.
  ///
  /// In en, this message translates to:
  /// **'Float'**
  String get metronomeSheetPlaybackStyleFloating;

  /// No description provided for @playbackMapLostSnackbar.
  ///
  /// In en, this message translates to:
  /// **'MeasureMap changed — playback stopped'**
  String get playbackMapLostSnackbar;

  /// No description provided for @scoreMenuLayoutValueBoth.
  ///
  /// In en, this message translates to:
  /// **'{stored} · {resolved}'**
  String scoreMenuLayoutValueBoth(String stored, String resolved);

  /// No description provided for @languageSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSheetTitle;

  /// No description provided for @languageSheetSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSheetSystem;

  /// No description provided for @languageSheetSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Match the device language'**
  String get languageSheetSystemSubtitle;

  /// No description provided for @stampSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Stamps'**
  String get stampSheetTitle;

  /// No description provided for @stampBox.
  ///
  /// In en, this message translates to:
  /// **'Box'**
  String get stampBox;

  /// No description provided for @stampCircle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get stampCircle;

  /// No description provided for @stampArrow.
  ///
  /// In en, this message translates to:
  /// **'Arrow'**
  String get stampArrow;

  /// No description provided for @stampText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get stampText;

  /// No description provided for @pageScaleSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Page scale'**
  String get pageScaleSheetTitle;

  /// No description provided for @pageScaleSheetExplainer.
  ///
  /// In en, this message translates to:
  /// **'How big the music is drawn, remembered between sessions. Pinching changes the view for now; this changes it for good.'**
  String get pageScaleSheetExplainer;

  /// No description provided for @pageScaleSheetCurrent.
  ///
  /// In en, this message translates to:
  /// **'On this page right now: {value}×'**
  String pageScaleSheetCurrent(String value);

  /// No description provided for @pageScaleSheetAppliesTo.
  ///
  /// In en, this message translates to:
  /// **'Applies to'**
  String get pageScaleSheetAppliesTo;

  /// No description provided for @pageScaleSheetScale.
  ///
  /// In en, this message translates to:
  /// **'Scale'**
  String get pageScaleSheetScale;

  /// No description provided for @pageScaleSheetScaleValue.
  ///
  /// In en, this message translates to:
  /// **'{value}×'**
  String pageScaleSheetScaleValue(String value);

  /// No description provided for @pageScaleSheetKeepScale.
  ///
  /// In en, this message translates to:
  /// **'Keep this scale'**
  String get pageScaleSheetKeepScale;

  /// No description provided for @pageScaleSheetKeepScaleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pinch is off, so a stray touch mid-piece cannot move the music'**
  String get pageScaleSheetKeepScaleSubtitle;

  /// No description provided for @pageScaleSheetHintFixed.
  ///
  /// In en, this message translates to:
  /// **'Every Score, unless one has its own scale'**
  String get pageScaleSheetHintFixed;

  /// No description provided for @pageScaleSheetHintPerScore.
  ///
  /// In en, this message translates to:
  /// **'This Score only, on every page of it'**
  String get pageScaleSheetHintPerScore;

  /// No description provided for @pageScaleSheetHintPerPage.
  ///
  /// In en, this message translates to:
  /// **'This page only — a dense page can be bigger without changing the rest'**
  String get pageScaleSheetHintPerPage;

  /// No description provided for @layoutSettingsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get layoutSettingsSheetTitle;

  /// No description provided for @layoutSettingsSheetPageTurnSettings.
  ///
  /// In en, this message translates to:
  /// **'Page turn settings'**
  String get layoutSettingsSheetPageTurnSettings;

  /// No description provided for @layoutSettingsSheetPageTurnSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap zones, swipe, pedal, animation'**
  String get layoutSettingsSheetPageTurnSettingsSubtitle;

  /// No description provided for @layoutSettingsSheetFallsBack.
  ///
  /// In en, this message translates to:
  /// **'One page on this screen — rotate for a spread'**
  String get layoutSettingsSheetFallsBack;

  /// No description provided for @layoutSettingsSheetNow.
  ///
  /// In en, this message translates to:
  /// **'Now: {mode}'**
  String layoutSettingsSheetNow(String mode);

  /// No description provided for @layoutSettingsSheetFitsScreen.
  ///
  /// In en, this message translates to:
  /// **'fits this screen'**
  String get layoutSettingsSheetFitsScreen;

  /// No description provided for @pageTurnSettingsSheetGestureWarning.
  ///
  /// In en, this message translates to:
  /// **'Keep at least one gesture set to Show menu / chrome.'**
  String get pageTurnSettingsSheetGestureWarning;

  /// No description provided for @pageTurnSettingsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Page turn'**
  String get pageTurnSettingsSheetTitle;

  /// No description provided for @pageTurnSettingsSheetTapZones.
  ///
  /// In en, this message translates to:
  /// **'Tap zones'**
  String get pageTurnSettingsSheetTapZones;

  /// No description provided for @pageTurnSettingsSheetTapZonesHint.
  ///
  /// In en, this message translates to:
  /// **'In {layoutMode}: {navigationHint}.'**
  String pageTurnSettingsSheetTapZonesHint(
    String layoutMode,
    String navigationHint,
  );

  /// No description provided for @pageTurnSettingsSheetSwipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe'**
  String get pageTurnSettingsSheetSwipe;

  /// No description provided for @pageTurnSettingsSheetMatchLayout.
  ///
  /// In en, this message translates to:
  /// **'Match layout'**
  String get pageTurnSettingsSheetMatchLayout;

  /// No description provided for @pageTurnSettingsSheetMatchLayoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Swipe along the way the pages move'**
  String get pageTurnSettingsSheetMatchLayoutSubtitle;

  /// No description provided for @pageTurnSettingsSheetSwipeLeftNext.
  ///
  /// In en, this message translates to:
  /// **'Swipe left → next'**
  String get pageTurnSettingsSheetSwipeLeftNext;

  /// No description provided for @pageTurnSettingsSheetSwipeRightPrevious.
  ///
  /// In en, this message translates to:
  /// **'Swipe right → previous'**
  String get pageTurnSettingsSheetSwipeRightPrevious;

  /// No description provided for @pageTurnSettingsSheetSwipeUpNext.
  ///
  /// In en, this message translates to:
  /// **'Swipe up → next'**
  String get pageTurnSettingsSheetSwipeUpNext;

  /// No description provided for @pageTurnSettingsSheetSwipeDownPrevious.
  ///
  /// In en, this message translates to:
  /// **'Swipe down → previous'**
  String get pageTurnSettingsSheetSwipeDownPrevious;

  /// No description provided for @pageTurnSettingsSheetReverseDirection.
  ///
  /// In en, this message translates to:
  /// **'Reverse page-turn direction'**
  String get pageTurnSettingsSheetReverseDirection;

  /// No description provided for @pageTurnSettingsSheetReverseDirectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For books that turn the other way'**
  String get pageTurnSettingsSheetReverseDirectionSubtitle;

  /// No description provided for @pageTurnSettingsSheetTurnAmount.
  ///
  /// In en, this message translates to:
  /// **'Turn amount'**
  String get pageTurnSettingsSheetTurnAmount;

  /// No description provided for @pageTurnSettingsSheetTurnAmountHintTwoPage.
  ///
  /// In en, this message translates to:
  /// **'Half advances one page of the spread instead of the whole pair.'**
  String get pageTurnSettingsSheetTurnAmountHintTwoPage;

  /// No description provided for @pageTurnSettingsSheetTurnAmountHintDefault.
  ///
  /// In en, this message translates to:
  /// **'Half advances ~½ screen instead of a whole one.'**
  String get pageTurnSettingsSheetTurnAmountHintDefault;

  /// No description provided for @pageTurnSettingsSheetAnimation.
  ///
  /// In en, this message translates to:
  /// **'Animation'**
  String get pageTurnSettingsSheetAnimation;

  /// No description provided for @pageTurnSettingsSheetPageTurnDelay.
  ///
  /// In en, this message translates to:
  /// **'Page turn delay'**
  String get pageTurnSettingsSheetPageTurnDelay;

  /// No description provided for @pageTurnSettingsSheetApplyTo.
  ///
  /// In en, this message translates to:
  /// **'Apply to'**
  String get pageTurnSettingsSheetApplyTo;

  /// No description provided for @pageTurnSettingsSheetGestures.
  ///
  /// In en, this message translates to:
  /// **'Gestures'**
  String get pageTurnSettingsSheetGestures;

  /// No description provided for @pageTurnSettingsSheetGesturesHint.
  ///
  /// In en, this message translates to:
  /// **'Edge taps are thin strips at the top and bottom — not the same as Top/bottom page-turn zones. At least one must be Show menu / chrome; that gesture also reveals the toolbar in Performance mode. Draw is entered from the toolbar, never from a gesture.'**
  String get pageTurnSettingsSheetGesturesHint;

  /// No description provided for @pageTurnSettingsSheetLongPress.
  ///
  /// In en, this message translates to:
  /// **'Long-press'**
  String get pageTurnSettingsSheetLongPress;

  /// No description provided for @pageTurnSettingsSheetTopEdge.
  ///
  /// In en, this message translates to:
  /// **'Top edge'**
  String get pageTurnSettingsSheetTopEdge;

  /// No description provided for @pageTurnSettingsSheetBottomEdge.
  ///
  /// In en, this message translates to:
  /// **'Bottom edge'**
  String get pageTurnSettingsSheetBottomEdge;

  /// No description provided for @pageTurnSettingsSheetPedalKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Pedal / keyboard'**
  String get pageTurnSettingsSheetPedalKeyboard;

  /// No description provided for @pageTurnSettingsSheetPedalKeyboardHint.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth pedals that send keyboard keys are supported:\nPrevious — PageUp, ←, ↑, Space\nNext — PageDown, →, ↓, Enter'**
  String get pageTurnSettingsSheetPedalKeyboardHint;

  /// No description provided for @pageTurnAnimationOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get pageTurnAnimationOff;

  /// No description provided for @pageTurnAnimationFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get pageTurnAnimationFast;

  /// No description provided for @pageTurnAnimationNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get pageTurnAnimationNormal;

  /// No description provided for @pageTurnAnimationSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get pageTurnAnimationSlow;

  /// No description provided for @pageTurnDelayOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get pageTurnDelayOff;

  /// No description provided for @pageTurnDelay300ms.
  ///
  /// In en, this message translates to:
  /// **'0.3s'**
  String get pageTurnDelay300ms;

  /// No description provided for @pageTurnDelay500ms.
  ///
  /// In en, this message translates to:
  /// **'0.5s'**
  String get pageTurnDelay500ms;

  /// No description provided for @pageTurnDelay1000ms.
  ///
  /// In en, this message translates to:
  /// **'1.0s'**
  String get pageTurnDelay1000ms;

  /// No description provided for @pageTurnDelayScopeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get pageTurnDelayScopeAll;

  /// No description provided for @pageTurnDelayScopePedalOnly.
  ///
  /// In en, this message translates to:
  /// **'Pedal & keyboard only'**
  String get pageTurnDelayScopePedalOnly;

  /// No description provided for @pageTurnTapModeMatchLayout.
  ///
  /// In en, this message translates to:
  /// **'Match layout'**
  String get pageTurnTapModeMatchLayout;

  /// No description provided for @pageTurnTapModeLeftRight.
  ///
  /// In en, this message translates to:
  /// **'Left / right'**
  String get pageTurnTapModeLeftRight;

  /// No description provided for @pageTurnTapModeTopBottom.
  ///
  /// In en, this message translates to:
  /// **'Top / bottom'**
  String get pageTurnTapModeTopBottom;

  /// No description provided for @pageTurnTapModePrevious.
  ///
  /// In en, this message translates to:
  /// **'Anywhere → prev'**
  String get pageTurnTapModePrevious;

  /// No description provided for @pageTurnTapModeNext.
  ///
  /// In en, this message translates to:
  /// **'Anywhere → next'**
  String get pageTurnTapModeNext;

  /// No description provided for @pageTurnTapModeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get pageTurnTapModeDisabled;

  /// No description provided for @turnAmountFull.
  ///
  /// In en, this message translates to:
  /// **'Full page'**
  String get turnAmountFull;

  /// No description provided for @turnAmountHalf.
  ///
  /// In en, this message translates to:
  /// **'Half page'**
  String get turnAmountHalf;

  /// No description provided for @gestureMapActionShowChrome.
  ///
  /// In en, this message translates to:
  /// **'Show menu / chrome'**
  String get gestureMapActionShowChrome;

  /// No description provided for @gestureMapActionDisabled.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get gestureMapActionDisabled;

  /// No description provided for @drawToolbarColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get drawToolbarColorLabel;

  /// No description provided for @drawToolbarSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get drawToolbarSizeLabel;

  /// No description provided for @drawToolbarUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get drawToolbarUndo;

  /// No description provided for @drawToolbarRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get drawToolbarRedo;

  /// No description provided for @drawToolbarDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get drawToolbarDelete;

  /// No description provided for @drawToolbarStamp.
  ///
  /// In en, this message translates to:
  /// **'Stamp'**
  String get drawToolbarStamp;

  /// No description provided for @drawToolbarPlace.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get drawToolbarPlace;

  /// No description provided for @drawToolbarMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get drawToolbarMore;

  /// No description provided for @drawToolbarTextStampTitle.
  ///
  /// In en, this message translates to:
  /// **'Text stamp'**
  String get drawToolbarTextStampTitle;

  /// No description provided for @drawToolbarTextStampHint.
  ///
  /// In en, this message translates to:
  /// **'Short label'**
  String get drawToolbarTextStampHint;

  /// No description provided for @drawToolbarDrawOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Draw options'**
  String get drawToolbarDrawOptionsTitle;

  /// No description provided for @drawToolbarTool.
  ///
  /// In en, this message translates to:
  /// **'Tool'**
  String get drawToolbarTool;

  /// No description provided for @drawToolbarWidth.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get drawToolbarWidth;

  /// No description provided for @drawToolbarStraightLine.
  ///
  /// In en, this message translates to:
  /// **'Straight line'**
  String get drawToolbarStraightLine;

  /// No description provided for @drawToolPen.
  ///
  /// In en, this message translates to:
  /// **'Pen'**
  String get drawToolPen;

  /// No description provided for @drawToolMarker.
  ///
  /// In en, this message translates to:
  /// **'Marker'**
  String get drawToolMarker;

  /// No description provided for @drawToolEraser.
  ///
  /// In en, this message translates to:
  /// **'Eraser'**
  String get drawToolEraser;

  /// No description provided for @drawToolEyedropper.
  ///
  /// In en, this message translates to:
  /// **'Dropper'**
  String get drawToolEyedropper;

  /// No description provided for @drawWidthThin.
  ///
  /// In en, this message translates to:
  /// **'Thin'**
  String get drawWidthThin;

  /// No description provided for @drawWidthMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get drawWidthMedium;

  /// No description provided for @drawWidthThick.
  ///
  /// In en, this message translates to:
  /// **'Thick'**
  String get drawWidthThick;

  /// No description provided for @pdfModeScreenTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the right half for next page, left for previous.'**
  String get pdfModeScreenTapHint;

  /// No description provided for @pdfModeScreenColorFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Color filter'**
  String get pdfModeScreenColorFilterTitle;

  /// No description provided for @scoreMenuQuickBarBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get scoreMenuQuickBarBookmarks;

  /// No description provided for @scoreMenuQuickBarDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get scoreMenuQuickBarDraw;

  /// No description provided for @scoreMenuQuickBarExitDraw.
  ///
  /// In en, this message translates to:
  /// **'Exit draw'**
  String get scoreMenuQuickBarExitDraw;

  /// No description provided for @scoreMenuQuickBarMetronome.
  ///
  /// In en, this message translates to:
  /// **'Metronome'**
  String get scoreMenuQuickBarMetronome;

  /// No description provided for @scoreMenuQuickBarMetronomeRunning.
  ///
  /// In en, this message translates to:
  /// **'Metronome (running)'**
  String get scoreMenuQuickBarMetronomeRunning;

  /// No description provided for @pdfModeScreenExporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting PDF…'**
  String get pdfModeScreenExporting;

  /// No description provided for @pdfModeScreenExportReady.
  ///
  /// In en, this message translates to:
  /// **'Export ready — share sheet opened'**
  String get pdfModeScreenExportReady;

  /// No description provided for @pdfModeScreenExportRestartHint.
  ///
  /// In en, this message translates to:
  /// **'Exported to {path}. Fully restart the app (stop + flutter run) to enable the share sheet.'**
  String pdfModeScreenExportRestartHint(String path);

  /// No description provided for @pdfModeScreenExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String pdfModeScreenExportFailed(String error);

  /// No description provided for @pdfModeScreenPieceIndex.
  ///
  /// In en, this message translates to:
  /// **'{index}.'**
  String pdfModeScreenPieceIndex(int index);

  /// No description provided for @pdfModeScreenHidePieceNotes.
  ///
  /// In en, this message translates to:
  /// **'Hide piece notes'**
  String get pdfModeScreenHidePieceNotes;

  /// No description provided for @pdfModeScreenShowPieceNotes.
  ///
  /// In en, this message translates to:
  /// **'Show piece notes'**
  String get pdfModeScreenShowPieceNotes;

  /// No description provided for @pdfModeScreenPieceNotes.
  ///
  /// In en, this message translates to:
  /// **'Piece notes'**
  String get pdfModeScreenPieceNotes;

  /// No description provided for @libraryScreenSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get libraryScreenSort;

  /// No description provided for @libraryScreenFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get libraryScreenFilter;

  /// No description provided for @libraryScreenManageLabels.
  ///
  /// In en, this message translates to:
  /// **'Manage Labels'**
  String get libraryScreenManageLabels;

  /// No description provided for @libraryScreenMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get libraryScreenMore;

  /// No description provided for @libraryScreenAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance…'**
  String get libraryScreenAppearance;

  /// No description provided for @libraryScreenLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language…'**
  String get libraryScreenLanguage;

  /// No description provided for @libraryScreenBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup…'**
  String get libraryScreenBackup;

  /// No description provided for @libraryScreenRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore…'**
  String get libraryScreenRestore;

  /// No description provided for @libraryScreenAbout.
  ///
  /// In en, this message translates to:
  /// **'About {productName}…'**
  String libraryScreenAbout(String productName);

  /// No description provided for @libraryScreenSplitIntoPiecesSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Split into {count} {count, plural, =1{piece} other{pieces}}'**
  String libraryScreenSplitIntoPiecesSnackbar(int count);

  /// No description provided for @libraryScreenStillReadingPdf.
  ///
  /// In en, this message translates to:
  /// **'Still reading this PDF — try again in a moment.'**
  String get libraryScreenStillReadingPdf;

  /// No description provided for @libraryScreenEditPiecesAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit pieces'**
  String get libraryScreenEditPiecesAppBarTitle;

  /// No description provided for @libraryScreenUpdatedPieces.
  ///
  /// In en, this message translates to:
  /// **'Updated to {count} {count, plural, =1{piece} other{pieces}}.'**
  String libraryScreenUpdatedPieces(int count);

  /// No description provided for @libraryScreenEditPiecesDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove piece data?'**
  String get libraryScreenEditPiecesDialogTitle;

  /// No description provided for @libraryScreenEditPiecesBody.
  ///
  /// In en, this message translates to:
  /// **'{names} will be removed, along with {count, plural, =1{its} other{their}} annotations, bookmarks, jump links, Labels, and Setlist membership.'**
  String libraryScreenEditPiecesBody(String names, int count);

  /// No description provided for @libraryScreenSplitIntoPiecesDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Split into pieces?'**
  String get libraryScreenSplitIntoPiecesDialogTitle;

  /// No description provided for @libraryScreenSplitPageOrderBody.
  ///
  /// In en, this message translates to:
  /// **'Narrowing “{title}” to pages {firstPage}–{lastPage} will drop {dropping} {dropping, plural, =1{page} other{pages}} from its page order.'**
  String libraryScreenSplitPageOrderBody(
    int dropping,
    String title,
    int firstPage,
    int lastPage,
  );

  /// No description provided for @libraryScreenSplitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get libraryScreenSplitConfirm;

  /// No description provided for @libraryScreenChangePagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Change pages?'**
  String get libraryScreenChangePagesTitle;

  /// No description provided for @libraryScreenChangePagesBody.
  ///
  /// In en, this message translates to:
  /// **'Changing “{title}” to pages {firstPage}–{lastPage} will drop {dropping} {dropping, plural, =1{page} other{pages}} from its page order.'**
  String libraryScreenChangePagesBody(
    int dropping,
    String title,
    int firstPage,
    int lastPage,
  );

  /// No description provided for @libraryScreenChangePagesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get libraryScreenChangePagesConfirm;

  /// No description provided for @libraryScreenSetlistEmptyAddScores.
  ///
  /// In en, this message translates to:
  /// **'Add scores to this setlist first.'**
  String get libraryScreenSetlistEmptyAddScores;

  /// No description provided for @libraryScreenNoScoresAvailable.
  ///
  /// In en, this message translates to:
  /// **'None of the scores in this setlist could be found.'**
  String get libraryScreenNoScoresAvailable;

  /// No description provided for @libraryScreenSkippedMissingScores.
  ///
  /// In en, this message translates to:
  /// **'Skipped {count} missing {count, plural, =1{score} other{scores}}.'**
  String libraryScreenSkippedMissingScores(int count);

  /// No description provided for @libraryScreenNewSetlist.
  ///
  /// In en, this message translates to:
  /// **'New setlist'**
  String get libraryScreenNewSetlist;

  /// No description provided for @libraryScreenDeleteSetlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete setlist?'**
  String get libraryScreenDeleteSetlistTitle;

  /// No description provided for @libraryScreenDeleteSetlistBody.
  ///
  /// In en, this message translates to:
  /// **'Delete “{title}”? The scores in it are not affected.'**
  String libraryScreenDeleteSetlistBody(String title);

  /// No description provided for @libraryScreenDeleteScoreBody.
  ///
  /// In en, this message translates to:
  /// **'Delete “{title}”? This can\'t be undone.'**
  String libraryScreenDeleteScoreBody(String title);

  /// No description provided for @libraryScreenDeleteScoreWithPiecesBody.
  ///
  /// In en, this message translates to:
  /// **'Delete “{title}” and its {count} {count, plural, =1{piece} other{pieces}}? This can\'t be undone.'**
  String libraryScreenDeleteScoreWithPiecesBody(String title, int count);

  /// No description provided for @libraryScreenDeleteScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete score?'**
  String get libraryScreenDeleteScoreTitle;

  /// No description provided for @libraryScreenTabScores.
  ///
  /// In en, this message translates to:
  /// **'Scores'**
  String get libraryScreenTabScores;

  /// No description provided for @libraryScreenTabSetlists.
  ///
  /// In en, this message translates to:
  /// **'Setlists'**
  String get libraryScreenTabSetlists;

  /// No description provided for @libraryScreenSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search scores'**
  String get libraryScreenSearchHint;

  /// No description provided for @libraryScreenAddPdf.
  ///
  /// In en, this message translates to:
  /// **'Add PDF'**
  String get libraryScreenAddPdf;

  /// No description provided for @libraryScreenSplitSuggestionWithPages.
  ///
  /// In en, this message translates to:
  /// **'“{name}” ({pages} pages) looks like it could be several pieces.'**
  String libraryScreenSplitSuggestionWithPages(String name, int pages);

  /// No description provided for @libraryScreenSplitSuggestionGeneric.
  ///
  /// In en, this message translates to:
  /// **'“{name}” looks like it could be several pieces.'**
  String libraryScreenSplitSuggestionGeneric(String name);

  /// No description provided for @libraryScreenNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get libraryScreenNotNow;

  /// No description provided for @libraryScreenSplitEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Split…'**
  String get libraryScreenSplitEllipsis;

  /// No description provided for @libraryScreenFailedToOpen.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the library: {error}'**
  String libraryScreenFailedToOpen(String error);

  /// No description provided for @libraryScreenNoScoresYet.
  ///
  /// In en, this message translates to:
  /// **'No scores yet'**
  String get libraryScreenNoScoresYet;

  /// No description provided for @libraryScreenImportPdfHint.
  ///
  /// In en, this message translates to:
  /// **'Import a PDF to get started.'**
  String get libraryScreenImportPdfHint;

  /// No description provided for @libraryScreenAddSampleScore.
  ///
  /// In en, this message translates to:
  /// **'Add sample score'**
  String get libraryScreenAddSampleScore;

  /// No description provided for @libraryScreenNoScoresMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No scores match “{query}”.'**
  String libraryScreenNoScoresMatchSearch(String query);

  /// No description provided for @libraryScreenNoScoresMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No scores match {filter}.'**
  String libraryScreenNoScoresMatchFilter(String filter);

  /// No description provided for @libraryScreenClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get libraryScreenClearSearch;

  /// No description provided for @libraryScreenClearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear filter'**
  String get libraryScreenClearFilter;

  /// No description provided for @libraryScreenRecencyWithPieces.
  ///
  /// In en, this message translates to:
  /// **'{when} · {count} {count, plural, =1{piece} other{pieces}}'**
  String libraryScreenRecencyWithPieces(String when, int count);

  /// No description provided for @libraryScreenPiecesEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Pieces…'**
  String get libraryScreenPiecesEllipsis;

  /// No description provided for @libraryScreenEditPiecesMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Edit pieces…'**
  String get libraryScreenEditPiecesMenuItem;

  /// No description provided for @libraryScreenOpenFullScore.
  ///
  /// In en, this message translates to:
  /// **'Open full score'**
  String get libraryScreenOpenFullScore;

  /// No description provided for @libraryScreenRenameEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Rename…'**
  String get libraryScreenRenameEllipsis;

  /// No description provided for @libraryScreenLabelsEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Labels…'**
  String get libraryScreenLabelsEllipsis;

  /// No description provided for @libraryScreenSplitIntoPiecesEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Split into pieces…'**
  String get libraryScreenSplitIntoPiecesEllipsis;

  /// No description provided for @libraryScreenPagesEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Pages…'**
  String get libraryScreenPagesEllipsis;

  /// No description provided for @libraryScreenReplacePdfEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Replace PDF…'**
  String get libraryScreenReplacePdfEllipsis;

  /// No description provided for @libraryScreenDeleteEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Delete…'**
  String get libraryScreenDeleteEllipsis;

  /// No description provided for @libraryScreenAddedRelative.
  ///
  /// In en, this message translates to:
  /// **'Added {when}'**
  String libraryScreenAddedRelative(String when);

  /// No description provided for @libraryScreenOpenedRelative.
  ///
  /// In en, this message translates to:
  /// **'Opened {when}'**
  String libraryScreenOpenedRelative(String when);

  /// No description provided for @libraryScreenRecencyWithPages.
  ///
  /// In en, this message translates to:
  /// **'{when} · {pages} {pages, plural, =1{page} other{pages}}'**
  String libraryScreenRecencyWithPages(String when, int pages);

  /// No description provided for @libraryScreenNoSetlistsYet.
  ///
  /// In en, this message translates to:
  /// **'No setlists yet'**
  String get libraryScreenNoSetlistsYet;

  /// No description provided for @libraryScreenSetlistsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Group scores for continuous performance without reopening each piece.'**
  String get libraryScreenSetlistsEmptyHint;

  /// No description provided for @libraryScreenSetlistScoreCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{score} other{scores}}'**
  String libraryScreenSetlistScoreCount(int count);

  /// No description provided for @libraryScreenSetlistCountEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get libraryScreenSetlistCountEmpty;

  /// No description provided for @libraryScreenSetlistScoreCountOpened.
  ///
  /// In en, this message translates to:
  /// **'{scoreCount} · {opened}'**
  String libraryScreenSetlistScoreCountOpened(String scoreCount, String opened);

  /// No description provided for @metronomeSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Metronome'**
  String get metronomeSheetTitle;

  /// No description provided for @metronomeSheetTempo.
  ///
  /// In en, this message translates to:
  /// **'Tempo'**
  String get metronomeSheetTempo;

  /// No description provided for @metronomeSheetMeter.
  ///
  /// In en, this message translates to:
  /// **'Meter'**
  String get metronomeSheetMeter;

  /// No description provided for @metronomeSheetMeterHint.
  ///
  /// In en, this message translates to:
  /// **'How beats are grouped in each bar'**
  String get metronomeSheetMeterHint;

  /// No description provided for @metronomeSheetEqual.
  ///
  /// In en, this message translates to:
  /// **'Equal'**
  String get metronomeSheetEqual;

  /// No description provided for @metronomeSheetMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get metronomeSheetMute;

  /// No description provided for @metronomeSheetShowBeats.
  ///
  /// In en, this message translates to:
  /// **'Show beats'**
  String get metronomeSheetShowBeats;

  /// No description provided for @metronomeSheetShowBeatsHint.
  ///
  /// In en, this message translates to:
  /// **'Flash the beat on the score while it plays'**
  String get metronomeSheetShowBeatsHint;

  /// No description provided for @metronomeSheetCountIn.
  ///
  /// In en, this message translates to:
  /// **'Count-in'**
  String get metronomeSheetCountIn;

  /// No description provided for @metronomeSheetCountInHint.
  ///
  /// In en, this message translates to:
  /// **'Click measures before Play from the start (not after Pause)'**
  String get metronomeSheetCountInHint;

  /// No description provided for @metronomeSheetCountInNone.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get metronomeSheetCountInNone;

  /// No description provided for @metronomeSheetCountInOne.
  ///
  /// In en, this message translates to:
  /// **'1'**
  String get metronomeSheetCountInOne;

  /// No description provided for @metronomeSheetCountInTwo.
  ///
  /// In en, this message translates to:
  /// **'2'**
  String get metronomeSheetCountInTwo;

  /// No description provided for @metronomeSheetVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume: {percent}%'**
  String metronomeSheetVolume(int percent);

  /// No description provided for @metronomeSheetStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get metronomeSheetStop;

  /// No description provided for @metronomeSheetStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get metronomeSheetStart;

  /// No description provided for @metronomeSheetEnterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get metronomeSheetEnterNumber;

  /// No description provided for @metronomeSheetTempoDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Set tempo'**
  String get metronomeSheetTempoDialogTitle;

  /// No description provided for @pageExtentScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pageExtentScreenTitle;

  /// No description provided for @pageExtentScreenFirstPage.
  ///
  /// In en, this message translates to:
  /// **'First page: {page}'**
  String pageExtentScreenFirstPage(int page);

  /// No description provided for @pageExtentScreenLastPage.
  ///
  /// In en, this message translates to:
  /// **'Last page: {page}'**
  String pageExtentScreenLastPage(int page);

  /// No description provided for @pageExtentScreenNoPages.
  ///
  /// In en, this message translates to:
  /// **'No pages'**
  String get pageExtentScreenNoPages;

  /// No description provided for @pageExtentScreenBadgeOnly.
  ///
  /// In en, this message translates to:
  /// **'Only'**
  String get pageExtentScreenBadgeOnly;

  /// No description provided for @pageExtentScreenBadgeFirst.
  ///
  /// In en, this message translates to:
  /// **'First'**
  String get pageExtentScreenBadgeFirst;

  /// No description provided for @pageExtentScreenBadgeLast.
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get pageExtentScreenBadgeLast;

  /// No description provided for @pageExtentScreenSummary.
  ///
  /// In en, this message translates to:
  /// **'{title} — {pages} {pages, plural, =1{page} other{pages}}'**
  String pageExtentScreenSummary(String title, int pages);

  /// No description provided for @pageExtentScreenHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a page below to set the selected boundary.'**
  String get pageExtentScreenHint;

  /// No description provided for @pageNavBarPreviousPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get pageNavBarPreviousPageTooltip;

  /// No description provided for @pageNavBarNextPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get pageNavBarNextPageTooltip;

  /// No description provided for @pageNavBarJumpedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Jumped to page {page} of {count}'**
  String pageNavBarJumpedSnackbar(int page, int count);

  /// No description provided for @pageNavBarGoToPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Go to page'**
  String get pageNavBarGoToPageTitle;

  /// No description provided for @pageNavBarPageFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Page (1–{count})'**
  String pageNavBarPageFieldLabel(int count);

  /// No description provided for @piecesScreenEditPieces.
  ///
  /// In en, this message translates to:
  /// **'Edit pieces…'**
  String get piecesScreenEditPieces;

  /// No description provided for @piecesScreenNoPieces.
  ///
  /// In en, this message translates to:
  /// **'No pieces'**
  String get piecesScreenNoPieces;

  /// No description provided for @piecesScreenRename.
  ///
  /// In en, this message translates to:
  /// **'Rename…'**
  String get piecesScreenRename;

  /// No description provided for @piecesScreenLabels.
  ///
  /// In en, this message translates to:
  /// **'Labels…'**
  String get piecesScreenLabels;

  /// No description provided for @piecesScreenSplitIntoPieces.
  ///
  /// In en, this message translates to:
  /// **'Split into pieces…'**
  String get piecesScreenSplitIntoPieces;

  /// No description provided for @piecesScreenPages.
  ///
  /// In en, this message translates to:
  /// **'Pages…'**
  String get piecesScreenPages;

  /// No description provided for @piecesScreenReplacePdf.
  ///
  /// In en, this message translates to:
  /// **'Replace PDF…'**
  String get piecesScreenReplacePdf;

  /// No description provided for @piecesScreenDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete…'**
  String get piecesScreenDelete;

  /// No description provided for @piecesScreenAdded.
  ///
  /// In en, this message translates to:
  /// **'Added {when}'**
  String piecesScreenAdded(String when);

  /// No description provided for @piecesScreenOpened.
  ///
  /// In en, this message translates to:
  /// **'Opened {when}'**
  String piecesScreenOpened(String when);

  /// No description provided for @piecesScreenRecencyWithPages.
  ///
  /// In en, this message translates to:
  /// **'{when} · {pages} {pages, plural, =1{page} other{pages}}'**
  String piecesScreenRecencyWithPages(String when, int pages);

  /// No description provided for @piecesScreenPieceCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{piece} other{pieces}}'**
  String piecesScreenPieceCount(int count);

  /// No description provided for @piecesScreenPageCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{page} other{pages}}'**
  String piecesScreenPageCount(int count);

  /// No description provided for @piecesScreenOpenFullScore.
  ///
  /// In en, this message translates to:
  /// **'Open full score'**
  String get piecesScreenOpenFullScore;

  /// No description provided for @setlistEditorImportFirst.
  ///
  /// In en, this message translates to:
  /// **'Import a score first.'**
  String get setlistEditorImportFirst;

  /// No description provided for @setlistEditorDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'New setlist'**
  String get setlistEditorDefaultTitle;

  /// No description provided for @setlistEditorAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit setlist'**
  String get setlistEditorAppBarTitle;

  /// No description provided for @setlistEditorAddScores.
  ///
  /// In en, this message translates to:
  /// **'Add scores'**
  String get setlistEditorAddScores;

  /// No description provided for @setlistEditorTitleFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get setlistEditorTitleFieldLabel;

  /// No description provided for @setlistEditorEmpty.
  ///
  /// In en, this message translates to:
  /// **'No scores yet. Tap Add scores to build the setlist.'**
  String get setlistEditorEmpty;

  /// No description provided for @setlistEditorMissingScore.
  ///
  /// In en, this message translates to:
  /// **'Missing score'**
  String get setlistEditorMissingScore;

  /// No description provided for @setlistEditorRemovedFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Removed from library'**
  String get setlistEditorRemovedFromLibrary;

  /// No description provided for @setlistEditorRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get setlistEditorRemoveTooltip;

  /// No description provided for @setlistEditorAddCount.
  ///
  /// In en, this message translates to:
  /// **'Add ({count})'**
  String setlistEditorAddCount(int count);

  /// No description provided for @setlistEditorPieceCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{piece} other{pieces}}'**
  String setlistEditorPieceCount(int count);

  /// No description provided for @setlistEditorPiecesTooltip.
  ///
  /// In en, this message translates to:
  /// **'View pieces'**
  String get setlistEditorPiecesTooltip;

  /// No description provided for @splitScoreScreenRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get splitScoreScreenRenameTitle;

  /// No description provided for @splitScoreScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Split into pieces'**
  String get splitScoreScreenTitle;

  /// No description provided for @splitScoreScreenClearMarks.
  ///
  /// In en, this message translates to:
  /// **'Clear marks'**
  String get splitScoreScreenClearMarks;

  /// No description provided for @splitScoreScreenNoPages.
  ///
  /// In en, this message translates to:
  /// **'No pages'**
  String get splitScoreScreenNoPages;

  /// No description provided for @splitScoreScreenPieceCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No pieces yet} =1{1 piece} other{{count} pieces}}'**
  String splitScoreScreenPieceCount(int count);

  /// No description provided for @splitScoreScreenHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a page to mark where a new piece begins. Long-press a marked page to rename it.'**
  String get splitScoreScreenHint;

  /// No description provided for @splitScoreScreenFrontMatterPage.
  ///
  /// In en, this message translates to:
  /// **'Page {page} is front matter and won\'t belong to any piece.'**
  String splitScoreScreenFrontMatterPage(int page);

  /// No description provided for @splitScoreScreenFrontMatterPages.
  ///
  /// In en, this message translates to:
  /// **'Pages {first}–{last} are front matter and won\'t belong to any piece.'**
  String splitScoreScreenFrontMatterPages(int first, int last);

  /// No description provided for @splitScoreScreenUseContents.
  ///
  /// In en, this message translates to:
  /// **'Use table of contents ({count} {count, plural, =1{entry} other{entries}})'**
  String splitScoreScreenUseContents(int count);

  /// No description provided for @libraryScreenNoPdfFiles.
  ///
  /// In en, this message translates to:
  /// **'No PDF files found.'**
  String get libraryScreenNoPdfFiles;

  /// No description provided for @libraryScreenImportedScores.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} {count, plural, =1{score} other{scores}}'**
  String libraryScreenImportedScores(int count);

  /// No description provided for @libraryScreenCreateBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create backup?'**
  String get libraryScreenCreateBackupTitle;

  /// No description provided for @libraryScreenCreateBackupBody.
  ///
  /// In en, this message translates to:
  /// **'This saves a copy of your entire library — scores, labels, setlists, and settings — as a zip file you can share or store somewhere safe.'**
  String get libraryScreenCreateBackupBody;

  /// No description provided for @libraryScreenCreateBackupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get libraryScreenCreateBackupConfirm;

  /// No description provided for @libraryScreenCreatingBackup.
  ///
  /// In en, this message translates to:
  /// **'Creating backup…'**
  String get libraryScreenCreatingBackup;

  /// No description provided for @libraryScreenBackupShareSubject.
  ///
  /// In en, this message translates to:
  /// **'StageScore backup'**
  String get libraryScreenBackupShareSubject;

  /// No description provided for @libraryScreenBackupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved to {path}'**
  String libraryScreenBackupSaved(String path);

  /// No description provided for @libraryScreenBackupReady.
  ///
  /// In en, this message translates to:
  /// **'Backup ready — share sheet opened'**
  String get libraryScreenBackupReady;

  /// No description provided for @libraryScreenBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create backup: {error}'**
  String libraryScreenBackupFailed(String error);

  /// No description provided for @libraryScreenRestoreBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup?'**
  String get libraryScreenRestoreBackupTitle;

  /// No description provided for @libraryScreenRestoreBackupBody.
  ///
  /// In en, this message translates to:
  /// **'This replaces your entire library — scores, labels, setlists, and settings — with the contents of the backup. This cannot be undone.'**
  String get libraryScreenRestoreBackupBody;

  /// No description provided for @libraryScreenReplaceAll.
  ///
  /// In en, this message translates to:
  /// **'Replace all'**
  String get libraryScreenReplaceAll;

  /// No description provided for @libraryScreenRestoringBackup.
  ///
  /// In en, this message translates to:
  /// **'Restoring backup…'**
  String get libraryScreenRestoringBackup;

  /// No description provided for @libraryScreenLibraryRestored.
  ///
  /// In en, this message translates to:
  /// **'Library restored'**
  String get libraryScreenLibraryRestored;

  /// No description provided for @libraryScreenRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not restore backup: {error}'**
  String libraryScreenRestoreFailed(String error);

  /// No description provided for @libraryScreenPercentValue.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String libraryScreenPercentValue(int percent);

  /// No description provided for @libraryScreenUntagged.
  ///
  /// In en, this message translates to:
  /// **'Untagged'**
  String get libraryScreenUntagged;

  /// No description provided for @libraryScreenThisFilter.
  ///
  /// In en, this message translates to:
  /// **'this filter'**
  String get libraryScreenThisFilter;

  /// No description provided for @libraryScreenAndConjunction.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get libraryScreenAndConjunction;

  /// No description provided for @libraryScreenAllOf.
  ///
  /// In en, this message translates to:
  /// **'All of'**
  String get libraryScreenAllOf;

  /// No description provided for @libraryScreenRemoveFilterChip.
  ///
  /// In en, this message translates to:
  /// **'Remove {label} filter'**
  String libraryScreenRemoveFilterChip(String label);

  /// No description provided for @libraryScreenRenameScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename score'**
  String get libraryScreenRenameScoreTitle;

  /// No description provided for @libraryScreenReplacePdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace PDF?'**
  String get libraryScreenReplacePdfTitle;

  /// No description provided for @libraryScreenReplacePdfBodyShared.
  ///
  /// In en, this message translates to:
  /// **'This PDF is shared by {sharing} pieces, including “{title}”. Replacing it will also change it for the other {others} {others, plural, =1{piece} other{pieces}}.'**
  String libraryScreenReplacePdfBodyShared(
    int sharing,
    String title,
    int others,
  );

  /// No description provided for @libraryScreenReplacePdfBodySingle.
  ///
  /// In en, this message translates to:
  /// **'Replace the PDF behind “{title}”? You can keep or reset its annotations below.'**
  String libraryScreenReplacePdfBodySingle(String title);

  /// No description provided for @libraryScreenKeepOverlays.
  ///
  /// In en, this message translates to:
  /// **'Keep annotations'**
  String get libraryScreenKeepOverlays;

  /// No description provided for @libraryScreenResetOverlays.
  ///
  /// In en, this message translates to:
  /// **'Reset annotations'**
  String get libraryScreenResetOverlays;

  /// No description provided for @libraryScreenOverlaysReset.
  ///
  /// In en, this message translates to:
  /// **'Annotations reset.'**
  String get libraryScreenOverlaysReset;

  /// No description provided for @libraryScreenOverlaysKept.
  ///
  /// In en, this message translates to:
  /// **'Annotations kept.'**
  String get libraryScreenOverlaysKept;

  /// No description provided for @libraryScreenPdfReplaced.
  ///
  /// In en, this message translates to:
  /// **'PDF replaced. {overlayNote}'**
  String libraryScreenPdfReplaced(String overlayNote);

  /// No description provided for @libraryScreenPdfReplacedShortened.
  ///
  /// In en, this message translates to:
  /// **'PDF replaced. {overlayNote} The new file is shorter, so {count} {count, plural, =1{page entry was} other{page entries were}} dropped.'**
  String libraryScreenPdfReplacedShortened(String overlayNote, int count);

  /// No description provided for @libraryScreenReplaceFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not replace PDF: {error}'**
  String libraryScreenReplaceFailed(String error);

  /// No description provided for @continuousPageOrderViewOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open PDF: {error}'**
  String continuousPageOrderViewOpenFailed(String error);

  /// No description provided for @performancePageSlotBlank.
  ///
  /// In en, this message translates to:
  /// **'Blank'**
  String get performancePageSlotBlank;

  /// No description provided for @performancePageSlotMissingPage.
  ///
  /// In en, this message translates to:
  /// **'Missing page {page}'**
  String performancePageSlotMissingPage(int page);

  /// No description provided for @singlePageSliderOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open PDF: {error}'**
  String singlePageSliderOpenFailed(String error);

  /// No description provided for @aboutSheetVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutSheetVersion(String version);

  /// No description provided for @aboutSheetVersionWithBuild.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String aboutSheetVersionWithBuild(String version, String build);

  /// No description provided for @aboutSheetLinkOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open link: {url}'**
  String aboutSheetLinkOpenFailed(String url);

  /// No description provided for @aboutSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'About {productName}'**
  String aboutSheetTitle(String productName);

  /// No description provided for @aboutSheetWebsiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get aboutSheetWebsiteLabel;

  /// No description provided for @aboutSheetPrivacyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get aboutSheetPrivacyLabel;

  /// No description provided for @aboutSheetSupportLabel.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get aboutSheetSupportLabel;

  /// No description provided for @bookmarksSheetAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add bookmark'**
  String get bookmarksSheetAddTitle;

  /// No description provided for @bookmarksSheetPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String bookmarksSheetPageLabel(int page);

  /// No description provided for @bookmarksSheetRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename bookmark'**
  String get bookmarksSheetRenameTitle;

  /// No description provided for @bookmarksSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarksSheetTitle;

  /// No description provided for @bookmarksSheetEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get bookmarksSheetEmpty;

  /// No description provided for @displaySheetBorderColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Border color'**
  String get displaySheetBorderColorTitle;

  /// No description provided for @displaySheetHue.
  ///
  /// In en, this message translates to:
  /// **'Hue: {value}'**
  String displaySheetHue(int value);

  /// No description provided for @displaySheetSaturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation: {value}'**
  String displaySheetSaturation(int value);

  /// No description provided for @displaySheetColorValue.
  ///
  /// In en, this message translates to:
  /// **'Value: {value}'**
  String displaySheetColorValue(int value);

  /// No description provided for @displaySheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get displaySheetTitle;

  /// No description provided for @displaySheetPerformanceMode.
  ///
  /// In en, this message translates to:
  /// **'Performance mode'**
  String get displaySheetPerformanceMode;

  /// No description provided for @displaySheetPageBorder.
  ///
  /// In en, this message translates to:
  /// **'Page border'**
  String get displaySheetPageBorder;

  /// No description provided for @displaySheetThickness.
  ///
  /// In en, this message translates to:
  /// **'Thickness: {value}'**
  String displaySheetThickness(String value);

  /// No description provided for @displaySheetColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get displaySheetColorLabel;

  /// No description provided for @displaySheetCustomChip.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get displaySheetCustomChip;

  /// No description provided for @displaySheetShowStatusBar.
  ///
  /// In en, this message translates to:
  /// **'Show status bar'**
  String get displaySheetShowStatusBar;

  /// No description provided for @displaySheetShowStatusBarHint.
  ///
  /// In en, this message translates to:
  /// **'Keep the clock and battery visible while you play'**
  String get displaySheetShowStatusBarHint;

  /// No description provided for @displaySheetAvoidNotches.
  ///
  /// In en, this message translates to:
  /// **'Avoid notches'**
  String get displaySheetAvoidNotches;

  /// No description provided for @displaySheetAvoidNotchesHint.
  ///
  /// In en, this message translates to:
  /// **'Keep the page clear of the camera notch and rounded corners'**
  String get displaySheetAvoidNotchesHint;

  /// No description provided for @jumpLinkEditSheetAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add jump link'**
  String get jumpLinkEditSheetAddTitle;

  /// No description provided for @jumpLinkEditSheetEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit jump link'**
  String get jumpLinkEditSheetEditTitle;

  /// No description provided for @jumpLinkEditSheetOriginLabel.
  ///
  /// In en, this message translates to:
  /// **'From page {page}'**
  String jumpLinkEditSheetOriginLabel(int page);

  /// No description provided for @jumpLinkEditSheetDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'To page {page} of {pageCount}'**
  String jumpLinkEditSheetDestinationLabel(int page, int pageCount);

  /// No description provided for @jumpLinkEditSheetColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get jumpLinkEditSheetColorLabel;

  /// No description provided for @jumpLinkEditSheetSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get jumpLinkEditSheetSizeLabel;

  /// No description provided for @jumpLinksSheetDragHint.
  ///
  /// In en, this message translates to:
  /// **'Added. Drag a jump link in the list to reorder it.'**
  String get jumpLinksSheetDragHint;

  /// No description provided for @jumpLinksSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Jump Links'**
  String get jumpLinksSheetTitle;

  /// No description provided for @jumpLinksSheetEmpty.
  ///
  /// In en, this message translates to:
  /// **'No jump links yet'**
  String get jumpLinksSheetEmpty;

  /// No description provided for @jumpLinksSheetRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Page {from} → {to}'**
  String jumpLinksSheetRowTitle(int from, int to);

  /// No description provided for @jumpLinksSheetRowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to jump to this link'**
  String get jumpLinksSheetRowSubtitle;

  /// No description provided for @labelSheetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Labels for {title}'**
  String labelSheetsTitle(String title);

  /// No description provided for @labelSheetsManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get labelSheetsManage;

  /// No description provided for @labelSheetsCreateLabel.
  ///
  /// In en, this message translates to:
  /// **'Create Label'**
  String get labelSheetsCreateLabel;

  /// No description provided for @labelSheetsNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New Label'**
  String get labelSheetsNewLabel;

  /// No description provided for @labelSheetsManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Labels'**
  String get labelSheetsManageTitle;

  /// No description provided for @labelSheetsNoLabelsYet.
  ///
  /// In en, this message translates to:
  /// **'No Labels yet'**
  String get labelSheetsNoLabelsYet;

  /// No description provided for @labelSheetsUsageCount.
  ///
  /// In en, this message translates to:
  /// **'Used by {count} {count, plural, =1{Score} other{Scores}}'**
  String labelSheetsUsageCount(int count);

  /// No description provided for @labelSheetsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Label?'**
  String get labelSheetsDeleteTitle;

  /// No description provided for @labelSheetsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String labelSheetsDeleteConfirm(String name);

  /// No description provided for @labelSheetsDeleteConfirmWithUsage.
  ///
  /// In en, this message translates to:
  /// **'“{name}” is used by {usage} {usage, plural, =1{Score} other{Scores}}. Delete anyway?'**
  String labelSheetsDeleteConfirmWithUsage(String name, int usage);

  /// No description provided for @labelSheetsRenameLabelTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Label'**
  String get labelSheetsRenameLabelTitle;

  /// No description provided for @labelSheetsNameHint.
  ///
  /// In en, this message translates to:
  /// **'Label name'**
  String get labelSheetsNameHint;

  /// No description provided for @libraryFilterSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get libraryFilterSheetTitle;

  /// No description provided for @libraryFilterSheetModeAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get libraryFilterSheetModeAny;

  /// No description provided for @libraryFilterSheetModeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get libraryFilterSheetModeAll;

  /// No description provided for @libraryFilterSheetModeUntagged.
  ///
  /// In en, this message translates to:
  /// **'Untagged'**
  String get libraryFilterSheetModeUntagged;

  /// No description provided for @libraryFilterSheetUntaggedHint.
  ///
  /// In en, this message translates to:
  /// **'Scores with no Labels'**
  String get libraryFilterSheetUntaggedHint;

  /// No description provided for @libraryFilterSheetEmptyLabels.
  ///
  /// In en, this message translates to:
  /// **'No Labels to filter by yet'**
  String get libraryFilterSheetEmptyLabels;

  /// No description provided for @measureMapMeasureCountTitle.
  ///
  /// In en, this message translates to:
  /// **'How many MeasureBoxes?'**
  String get measureMapMeasureCountTitle;

  /// No description provided for @measureMapMeasureCountLabel.
  ///
  /// In en, this message translates to:
  /// **'MeasureBoxes'**
  String get measureMapMeasureCountLabel;

  /// No description provided for @measureMapGoToTitle.
  ///
  /// In en, this message translates to:
  /// **'Go to measure'**
  String get measureMapGoToTitle;

  /// No description provided for @measureMapGoToLabel.
  ///
  /// In en, this message translates to:
  /// **'Measure number'**
  String get measureMapGoToLabel;

  /// No description provided for @measureMapGoToMissing.
  ///
  /// In en, this message translates to:
  /// **'Measure {number} is not mapped yet'**
  String measureMapGoToMissing(int number);

  /// No description provided for @measureMapMetaTitle.
  ///
  /// In en, this message translates to:
  /// **'Tempo & time signature'**
  String get measureMapMetaTitle;

  /// No description provided for @measureMapTimeSignatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Time signature'**
  String get measureMapTimeSignatureLabel;

  /// No description provided for @measureMapTempoLabel.
  ///
  /// In en, this message translates to:
  /// **'Tempo'**
  String get measureMapTempoLabel;

  /// No description provided for @measureMapMetaScopeTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply to'**
  String get measureMapMetaScopeTitle;

  /// No description provided for @measureMapScopeThisMeasure.
  ///
  /// In en, this message translates to:
  /// **'This measure only'**
  String get measureMapScopeThisMeasure;

  /// No description provided for @measureMapScopeThisSystem.
  ///
  /// In en, this message translates to:
  /// **'This system'**
  String get measureMapScopeThisSystem;

  /// No description provided for @measureMapScopeThisPage.
  ///
  /// In en, this message translates to:
  /// **'This page'**
  String get measureMapScopeThisPage;

  /// No description provided for @measureMapScopeRestOfScore.
  ///
  /// In en, this message translates to:
  /// **'Rest of score'**
  String get measureMapScopeRestOfScore;

  /// No description provided for @measureMapScopeNextN.
  ///
  /// In en, this message translates to:
  /// **'Next N…'**
  String get measureMapScopeNextN;

  /// No description provided for @measureMapMetaNextNLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of measures'**
  String get measureMapMetaNextNLabel;

  /// No description provided for @measureMapClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear MeasureMap?'**
  String get measureMapClearTitle;

  /// No description provided for @measureMapClearBody.
  ///
  /// In en, this message translates to:
  /// **'Delete every SystemBox and MeasureBox for this Score. This cannot be undone.'**
  String get measureMapClearBody;

  /// No description provided for @measureMapClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get measureMapClearConfirm;

  /// No description provided for @measureMapDeleteSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete system?'**
  String get measureMapDeleteSystemTitle;

  /// No description provided for @measureMapDeleteSystemBody.
  ///
  /// In en, this message translates to:
  /// **'Delete this SystemBox and all its MeasureBoxes.'**
  String get measureMapDeleteSystemBody;

  /// No description provided for @measureMapCopyFromPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Copy layout from page'**
  String get measureMapCopyFromPageTitle;

  /// No description provided for @measureMapCopyFromPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Source page'**
  String get measureMapCopyFromPageLabel;

  /// No description provided for @measureMapCopyPrevious.
  ///
  /// In en, this message translates to:
  /// **'Copy previous page'**
  String get measureMapCopyPrevious;

  /// No description provided for @measureMapEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Draw a system — the app will ask how many measures'**
  String get measureMapEmptyHint;

  /// No description provided for @measureMapDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get measureMapDone;

  /// No description provided for @measureMapEditBeats.
  ///
  /// In en, this message translates to:
  /// **'Edit beats'**
  String get measureMapEditBeats;

  /// No description provided for @measureMapSetMeasureCount.
  ///
  /// In en, this message translates to:
  /// **'Set measure count…'**
  String get measureMapSetMeasureCount;

  /// No description provided for @measureMapDeleteSystem.
  ///
  /// In en, this message translates to:
  /// **'Delete system'**
  String get measureMapDeleteSystem;

  /// No description provided for @measureMapDeleteMeasure.
  ///
  /// In en, this message translates to:
  /// **'Delete measure'**
  String get measureMapDeleteMeasure;

  /// No description provided for @measureMapEditMeta.
  ///
  /// In en, this message translates to:
  /// **'Tempo & time signature…'**
  String get measureMapEditMeta;

  /// No description provided for @measureMapStartsAtBeat.
  ///
  /// In en, this message translates to:
  /// **'Starts at beat'**
  String get measureMapStartsAtBeat;

  /// No description provided for @measureMapStartsAtBeatHint.
  ///
  /// In en, this message translates to:
  /// **'1 = full measure; higher skips early beats (pickup on a wide box)'**
  String get measureMapStartsAtBeatHint;

  /// No description provided for @measureMapClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear MeasureMap…'**
  String get measureMapClearAll;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'ko',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
