// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionDone => 'Fertig';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionOk => 'OK';

  @override
  String get actionClear => 'Leeren';

  @override
  String get actionApply => 'Anwenden';

  @override
  String get actionAdd => 'Hinzufügen';

  @override
  String get actionEdit => 'Bearbeiten';

  @override
  String get actionRename => 'Umbenennen';

  @override
  String get actionBack => 'Zurück';

  @override
  String get actionMore => 'Mehr';

  @override
  String get actionGo => 'Los';

  @override
  String get actionUndo => 'Rückgängig';

  @override
  String get actionContinue => 'Weiter';

  @override
  String get actionReset => 'Zurücksetzen';

  @override
  String get commonOr => 'oder';

  @override
  String get commonTitleLabel => 'Titel';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Hell';

  @override
  String get themeModeDark => 'Dunkel';

  @override
  String get pdfLayoutModeAuto => 'Automatisch';

  @override
  String get pdfLayoutModeSingle => 'Eine Seite';

  @override
  String get pdfLayoutModeTwoPages => 'Zwei Seiten';

  @override
  String get pdfLayoutModeScroll => 'Scrollen';

  @override
  String get pdfLayoutModeScrollSideways => 'Scrollen (seitwärts)';

  @override
  String get pdfLayoutModeHalfPageTopBottom => 'Eine Seite + Vorschau';

  @override
  String get pdfLayoutModeHalfPageLeftRight =>
      'Eine Seite + seitliche Vorschau';

  @override
  String get pageColorFilterOff => 'Aus';

  @override
  String get pageColorFilterSepia => 'Sepia';

  @override
  String get pageColorFilterGreen => 'Grün';

  @override
  String get pageColorFilterInvert => 'Invertiert';

  @override
  String get pageScaleScopeFixed => 'Fest';

  @override
  String get pageScaleScopePerScore => 'Pro Stück';

  @override
  String get pageScaleScopePerPage => 'Pro Seite';

  @override
  String get stagePresetSetUpToPlay => 'Bereit zum Spielen';

  @override
  String get stagePresetSetUpToPractise => 'Bereit zum Üben';

  @override
  String get stagePresetChromeHidden => 'Bedienelemente ausgeblendet';

  @override
  String get stagePresetChromeShown => 'Bedienelemente eingeblendet';

  @override
  String get stagePresetStatusBarShown => 'Statusleiste eingeblendet';

  @override
  String get stagePresetStatusBarHidden => 'Statusleiste ausgeblendet';

  @override
  String get stagePresetScaleKept => 'Skalierung beibehalten';

  @override
  String get stagePresetPinchFree => 'Zoomen frei';

  @override
  String get relativeDayToday => 'heute';

  @override
  String get relativeDayYesterday => 'gestern';

  @override
  String relativeDayDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Tagen',
      one: 'Tag',
    );
    return 'vor $days $_temp0';
  }

  @override
  String pageOrderEditorEntryBlank(int index) {
    return '$index. Leer';
  }

  @override
  String pageOrderEditorEntryPdfPage(int index, int sourcePage) {
    return '$index. PDF-Seite $sourcePage';
  }

  @override
  String get pageOrderEditorResetTitle => 'Auf Original zurücksetzen?';

  @override
  String get pageOrderEditorResetBody =>
      'Die PDF-Seitenreihenfolge wiederherstellen und Leerseiten sowie Duplikate entfernen?';

  @override
  String get pageOrderEditorReset => 'Zurücksetzen';

  @override
  String get pageOrderEditorAppBarTitle => 'Seitenreihenfolge';

  @override
  String get pageOrderEditorNoPages => 'Keine Seiten';

  @override
  String get pageOrderEditorDuplicate => 'Duplizieren';

  @override
  String get pageOrderEditorInsertBlank => 'Leerseite einfügen';

  @override
  String get pageOrderEditorRemove => 'Entfernen';

  @override
  String get librarySortTitle => 'Titel';

  @override
  String get librarySortCreated => 'Erstellt';

  @override
  String get librarySortLastViewed => 'Zuletzt angesehen';

  @override
  String scoreOriginPage(int page) {
    return 'Seite $page';
  }

  @override
  String scoreOriginPages(int first, int last) {
    return 'Seiten $first–$last';
  }

  @override
  String scoreOriginPagesOfBook(String pages, String name) {
    return '$pages von $name';
  }

  @override
  String libraryVisibilityInBook(String title) {
    return 'in $title';
  }

  @override
  String get libraryVisibilityInBookFallback => 'im Buch';

  @override
  String get libraryBackupFileNotFound => 'Sicherungsdatei nicht gefunden.';

  @override
  String get libraryBackupFailedGeneric => 'Sicherung fehlgeschlagen.';

  @override
  String libraryBackupCreateFailed(String error) {
    return 'Sicherung konnte nicht erstellt werden: $error';
  }

  @override
  String libraryBackupRestoreFailed(String error) {
    return 'Sicherung konnte nicht wiederhergestellt werden: $error';
  }

  @override
  String get libraryBackupMissingMarker =>
      'Keine StageScore-Sicherung (fehlende Kennung).';

  @override
  String get libraryBackupUnknownFormat =>
      'Keine StageScore-Sicherung (unbekanntes Format).';

  @override
  String get libraryBackupUnsupportedVersion =>
      'Nicht unterstützte StageScore-Sicherungsversion.';

  @override
  String get libraryBackupCorruptMarker =>
      'Keine StageScore-Sicherung (beschädigte Kennung).';

  @override
  String get gestureMapLongPress => 'gedrückt halten';

  @override
  String get gestureMapTapTopEdge => 'oberen Rand antippen';

  @override
  String get gestureMapTapBottomEdge => 'unteren Rand antippen';

  @override
  String get gestureMapEmptyHint =>
      'Lege eine Geste auf „Menü/Bedienelemente anzeigen“, um es einzublenden.';

  @override
  String gestureMapRevealHint(String joined) {
    return 'Blende Symbolleiste und Seitenleiste beim Spielen aus. Um sie wieder einzublenden: $joined.';
  }

  @override
  String get layoutNavigationPedalOrPageBar => 'Pedal oder die Seitenleiste';

  @override
  String get layoutNavigationTapLeftRight => 'links/rechts antippen';

  @override
  String get layoutNavigationTapTopBottom => 'oben/unten antippen';

  @override
  String get layoutNavigationTapAnywhere => 'irgendwo antippen';

  @override
  String get layoutNavigationTapAnywhereBack =>
      'irgendwo antippen, um zurückzugehen';

  @override
  String get layoutNavigationSwipe => 'wischen';

  @override
  String get layoutNavigationSwipeSideways => 'seitwärts wischen';

  @override
  String get layoutNavigationSwipeUpDown => 'hoch/runter wischen';

  @override
  String get scoreMenuSheetTitle => 'Menü';

  @override
  String get appearanceSheetTitle => 'Erscheinungsbild';

  @override
  String get appearanceSheetMode => 'Modus';

  @override
  String get appearanceSheetThemeColor => 'Designfarbe';

  @override
  String get appearanceSheetCustomChip => 'Benutzerdefiniert';

  @override
  String get appearanceSheetCustomColorDialog => 'Benutzerdefinierte Farbe';

  @override
  String get appearanceSheetHue => 'Farbton';

  @override
  String get appearanceSheetSat => 'Sätt.';

  @override
  String get appearanceSheetVal => 'Hellw.';

  @override
  String get scoreMenuGoTo => 'Gehe zu';

  @override
  String get scoreMenuBookmarks => 'Lesezeichen';

  @override
  String get scoreMenuJumpLinks => 'Sprungmarken';

  @override
  String get scoreMenuPageOrder => 'Seitenreihenfolge…';

  @override
  String get scoreMenuGoToMeasure => 'Zur Taktnummer…';

  @override
  String get scoreMenuMeasureMap => 'Measure map…';

  @override
  String get scoreMenuMarks => 'Markierungen';

  @override
  String get scoreMenuHideAnnotations => 'Anmerkungen ausblenden';

  @override
  String get scoreMenuShowAnnotations => 'Anmerkungen einblenden';

  @override
  String get scoreMenuExporting => 'Wird exportiert…';

  @override
  String get scoreMenuExportAnnotated => 'PDF mit Anmerkungen exportieren';

  @override
  String get scoreMenuView => 'Ansicht';

  @override
  String get scoreMenuLayout => 'Layout';

  @override
  String get scoreMenuDisplay => 'Anzeige…';

  @override
  String get scoreMenuColorFilter => 'Farbfilter…';

  @override
  String get scoreMenuPageScale => 'Seitenskalierung…';

  @override
  String get scoreMenuLocked => 'Gesperrt';

  @override
  String get scoreMenuPlaying => 'Spielt';

  @override
  String get scoreMenuMetronomeRunning => 'Metronom (läuft)…';

  @override
  String get scoreMenuMetronome => 'Metronom…';

  @override
  String get scoreMenuPageTurnSettings => 'Seitenwechsel-Einstellungen';

  @override
  String scoreMenuLayoutValueBoth(String stored, String resolved) {
    return '$stored · $resolved';
  }

  @override
  String get languageSheetTitle => 'Sprache';

  @override
  String get languageSheetSystem => 'System';

  @override
  String get languageSheetSystemSubtitle => 'Der Gerätesprache folgen';

  @override
  String get stampSheetTitle => 'Stempel';

  @override
  String get stampBox => 'Rechteck';

  @override
  String get stampCircle => 'Kreis';

  @override
  String get stampArrow => 'Pfeil';

  @override
  String get stampText => 'Text';

  @override
  String get pageScaleSheetTitle => 'Seitenskalierung';

  @override
  String get pageScaleSheetExplainer =>
      'Wie groß die Noten dargestellt werden – wird zwischen Sitzungen gespeichert. Zoomen mit zwei Fingern ändert die Ansicht nur vorübergehend; hier änderst du sie dauerhaft.';

  @override
  String pageScaleSheetCurrent(String value) {
    return 'Auf dieser Seite gerade: $value×';
  }

  @override
  String get pageScaleSheetAppliesTo => 'Gilt für';

  @override
  String get pageScaleSheetScale => 'Skalierung';

  @override
  String pageScaleSheetScaleValue(String value) {
    return '$value×';
  }

  @override
  String get pageScaleSheetKeepScale => 'Diese Skalierung beibehalten';

  @override
  String get pageScaleSheetKeepScaleSubtitle =>
      'Zoomen ist deaktiviert, damit eine versehentliche Berührung während des Spiels die Noten nicht verschiebt';

  @override
  String get pageScaleSheetHintFixed =>
      'Für jedes Stück, außer eines hat eine eigene Skalierung';

  @override
  String get pageScaleSheetHintPerScore =>
      'Nur für dieses Stück, auf jeder seiner Seiten';

  @override
  String get pageScaleSheetHintPerPage =>
      'Nur für diese Seite — eine dicht bedruckte Seite kann größer sein, ohne den Rest zu verändern';

  @override
  String get layoutSettingsSheetTitle => 'Layout';

  @override
  String get layoutSettingsSheetPageTurnSettings =>
      'Seitenwechsel-Einstellungen';

  @override
  String get layoutSettingsSheetPageTurnSettingsSubtitle =>
      'Tippzonen, Wischen, Pedal, Animation';

  @override
  String get layoutSettingsSheetFallsBack =>
      'Eine Seite auf diesem Bildschirm — drehen für eine Doppelseite';

  @override
  String layoutSettingsSheetNow(String mode) {
    return 'Aktuell: $mode';
  }

  @override
  String get layoutSettingsSheetFitsScreen => 'passt auf diesen Bildschirm';

  @override
  String get pageTurnSettingsSheetGestureWarning =>
      'Behalte mindestens eine Geste für „Menü/Bedienelemente anzeigen“.';

  @override
  String get pageTurnSettingsSheetTitle => 'Seitenwechsel';

  @override
  String get pageTurnSettingsSheetTapZones => 'Tippzonen';

  @override
  String pageTurnSettingsSheetTapZonesHint(
    String layoutMode,
    String navigationHint,
  ) {
    return 'Bei $layoutMode: $navigationHint.';
  }

  @override
  String get pageTurnSettingsSheetSwipe => 'Wischen';

  @override
  String get pageTurnSettingsSheetMatchLayout => 'Wie im Layout';

  @override
  String get pageTurnSettingsSheetMatchLayoutSubtitle =>
      'Wischen entsprechend der Bewegungsrichtung der Seiten';

  @override
  String get pageTurnSettingsSheetSwipeLeftNext =>
      'Nach links wischen → weiter';

  @override
  String get pageTurnSettingsSheetSwipeRightPrevious =>
      'Nach rechts wischen → zurück';

  @override
  String get pageTurnSettingsSheetSwipeUpNext => 'Nach oben wischen → weiter';

  @override
  String get pageTurnSettingsSheetSwipeDownPrevious =>
      'Nach unten wischen → zurück';

  @override
  String get pageTurnSettingsSheetReverseDirection =>
      'Seitenwechsel-Richtung umkehren';

  @override
  String get pageTurnSettingsSheetReverseDirectionSubtitle =>
      'Für Notenhefte, die andersherum blättern';

  @override
  String get pageTurnSettingsSheetTurnAmount => 'Umblätterschritt';

  @override
  String get pageTurnSettingsSheetTurnAmountHintTwoPage =>
      '„Halb“ blättert eine Seite der Doppelseite weiter statt das ganze Paar.';

  @override
  String get pageTurnSettingsSheetTurnAmountHintDefault =>
      '„Halb“ blättert etwa einen halben Bildschirm weiter statt einen ganzen.';

  @override
  String get pageTurnSettingsSheetAnimation => 'Animation';

  @override
  String get pageTurnSettingsSheetPageTurnDelay => 'Seitenwechsel-Verzögerung';

  @override
  String get pageTurnSettingsSheetApplyTo => 'Anwenden auf';

  @override
  String get pageTurnSettingsSheetGestures => 'Gesten';

  @override
  String get pageTurnSettingsSheetGesturesHint =>
      'Randtipps sind schmale Streifen oben und unten — nicht dasselbe wie die Oben/Unten-Zonen für den Seitenwechsel. Mindestens eine Geste muss auf „Menü/Bedienelemente anzeigen“ stehen; diese Geste blendet im Performance-Modus auch die Symbolleiste ein. Der Zeichenmodus wird nur über die Symbolleiste aufgerufen, nie über eine Geste.';

  @override
  String get pageTurnSettingsSheetLongPress => 'Gedrückt halten';

  @override
  String get pageTurnSettingsSheetTopEdge => 'Oberer Rand';

  @override
  String get pageTurnSettingsSheetBottomEdge => 'Unterer Rand';

  @override
  String get pageTurnSettingsSheetPedalKeyboard => 'Pedal/Tastatur';

  @override
  String get pageTurnSettingsSheetPedalKeyboardHint =>
      'Bluetooth-Pedale, die Tastaturtasten senden, werden unterstützt:\nZurück — Bild ↑, ←, ↑, Leertaste\nWeiter — Bild ↓, →, ↓, Eingabetaste';

  @override
  String get pageTurnAnimationOff => 'Aus';

  @override
  String get pageTurnAnimationFast => 'Schnell';

  @override
  String get pageTurnAnimationNormal => 'Normal';

  @override
  String get pageTurnAnimationSlow => 'Langsam';

  @override
  String get pageTurnDelayOff => 'Aus';

  @override
  String get pageTurnDelay300ms => '0,3 s';

  @override
  String get pageTurnDelay500ms => '0,5 s';

  @override
  String get pageTurnDelay1000ms => '1,0 s';

  @override
  String get pageTurnDelayScopeAll => 'Alle';

  @override
  String get pageTurnDelayScopePedalOnly => 'Nur Pedal & Tastatur';

  @override
  String get pageTurnTapModeMatchLayout => 'Wie im Layout';

  @override
  String get pageTurnTapModeLeftRight => 'Links/rechts';

  @override
  String get pageTurnTapModeTopBottom => 'Oben/unten';

  @override
  String get pageTurnTapModePrevious => 'Überall → zurück';

  @override
  String get pageTurnTapModeNext => 'Überall → weiter';

  @override
  String get pageTurnTapModeDisabled => 'Deaktiviert';

  @override
  String get turnAmountFull => 'Ganze Seite';

  @override
  String get turnAmountHalf => 'Halbe Seite';

  @override
  String get gestureMapActionShowChrome => 'Menü/Bedienelemente anzeigen';

  @override
  String get gestureMapActionDisabled => 'Aus';

  @override
  String get drawToolbarColorLabel => 'Farbe';

  @override
  String get drawToolbarSizeLabel => 'Größe';

  @override
  String get drawToolbarUndo => 'Rückgängig';

  @override
  String get drawToolbarRedo => 'Wiederholen';

  @override
  String get drawToolbarDelete => 'Löschen';

  @override
  String get drawToolbarStamp => 'Stempel';

  @override
  String get drawToolbarPlace => 'Platzieren';

  @override
  String get drawToolbarMore => 'Mehr';

  @override
  String get drawToolbarTextStampTitle => 'Textstempel';

  @override
  String get drawToolbarTextStampHint => 'Kurzer Text';

  @override
  String get drawToolbarDrawOptionsTitle => 'Zeichenoptionen';

  @override
  String get drawToolbarTool => 'Werkzeug';

  @override
  String get drawToolbarWidth => 'Breite';

  @override
  String get drawToolbarStraightLine => 'Gerade Linie';

  @override
  String get drawToolPen => 'Stift';

  @override
  String get drawToolMarker => 'Marker';

  @override
  String get drawToolEraser => 'Radierer';

  @override
  String get drawToolEyedropper => 'Pipette';

  @override
  String get drawWidthThin => 'Dünn';

  @override
  String get drawWidthMedium => 'Mittel';

  @override
  String get drawWidthThick => 'Dick';

  @override
  String get pdfModeScreenTapHint =>
      'Rechte Hälfte antippen für die nächste Seite, linke für die vorherige.';

  @override
  String get pdfModeScreenColorFilterTitle => 'Farbfilter';

  @override
  String get scoreMenuQuickBarBookmarks => 'Lesezeichen';

  @override
  String get scoreMenuQuickBarDraw => 'Zeichnen';

  @override
  String get scoreMenuQuickBarExitDraw => 'Zeichnen beenden';

  @override
  String get scoreMenuQuickBarMetronome => 'Metronom';

  @override
  String get scoreMenuQuickBarMetronomeRunning => 'Metronom (läuft)';

  @override
  String get pdfModeScreenExporting => 'PDF wird exportiert…';

  @override
  String get pdfModeScreenExportReady => 'Export bereit — Teilen-Menü geöffnet';

  @override
  String pdfModeScreenExportRestartHint(String path) {
    return 'Exportiert nach $path. Starte die App komplett neu (stop + flutter run), um das Teilen-Menü zu aktivieren.';
  }

  @override
  String pdfModeScreenExportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String pdfModeScreenPieceIndex(int index) {
    return '$index.';
  }

  @override
  String get pdfModeScreenHidePieceNotes => 'Notizen zum Stück ausblenden';

  @override
  String get pdfModeScreenShowPieceNotes => 'Notizen zum Stück einblenden';

  @override
  String get pdfModeScreenPieceNotes => 'Notizen zum Stück';

  @override
  String get libraryScreenSort => 'Sortieren';

  @override
  String get libraryScreenFilter => 'Filter';

  @override
  String get libraryScreenManageLabels => 'Labels verwalten';

  @override
  String get libraryScreenMore => 'Mehr';

  @override
  String get libraryScreenAppearance => 'Erscheinungsbild…';

  @override
  String get libraryScreenLanguage => 'Sprache…';

  @override
  String get libraryScreenBackup => 'Sicherung…';

  @override
  String get libraryScreenRestore => 'Wiederherstellen…';

  @override
  String libraryScreenAbout(String productName) {
    return 'Über $productName…';
  }

  @override
  String libraryScreenSplitIntoPiecesSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Stücke',
      one: 'Stück',
    );
    return 'In $count $_temp0 aufgeteilt';
  }

  @override
  String get libraryScreenStillReadingPdf =>
      'Dieses PDF wird noch gelesen — versuch es gleich noch einmal.';

  @override
  String get libraryScreenEditPiecesAppBarTitle => 'Stücke bearbeiten';

  @override
  String libraryScreenUpdatedPieces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Stücke',
      one: 'Stück',
    );
    return 'Auf $count $_temp0 aktualisiert.';
  }

  @override
  String get libraryScreenEditPiecesDialogTitle => 'Stückdaten entfernen?';

  @override
  String libraryScreenEditPiecesBody(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'werden gemeinsam mit ihren',
      one: 'wird gemeinsam mit seinen',
    );
    return '$names $_temp0 Anmerkungen, Lesezeichen, Sprungmarken, Labels und der Setlist-Zugehörigkeit entfernt.';
  }

  @override
  String get libraryScreenSplitIntoPiecesDialogTitle => 'In Stücke aufteilen?';

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
      other: 'fallen $dropping Seiten',
      one: 'fällt 1 Seite',
    );
    return 'Wenn du „$title“ auf die Seiten $firstPage–$lastPage eingrenzt, $_temp0 aus der Seitenreihenfolge weg.';
  }

  @override
  String get libraryScreenSplitConfirm => 'Aufteilen';

  @override
  String get libraryScreenChangePagesTitle => 'Seiten ändern?';

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
      other: 'fallen $dropping Seiten',
      one: 'fällt 1 Seite',
    );
    return 'Wenn du „$title“ auf die Seiten $firstPage–$lastPage änderst, $_temp0 aus der Seitenreihenfolge weg.';
  }

  @override
  String get libraryScreenChangePagesConfirm => 'Ändern';

  @override
  String get libraryScreenSetlistEmptyAddScores =>
      'Füge zuerst Stücke zu dieser Setlist hinzu.';

  @override
  String get libraryScreenNoScoresAvailable =>
      'Keines der Stücke in dieser Setlist wurde gefunden.';

  @override
  String libraryScreenSkippedMissingScores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fehlende Stücke übersprungen',
      one: '1 fehlendes Stück übersprungen',
    );
    return '$_temp0.';
  }

  @override
  String get libraryScreenNewSetlist => 'Neue Setlist';

  @override
  String get libraryScreenDeleteSetlistTitle => 'Setlist löschen?';

  @override
  String libraryScreenDeleteSetlistBody(String title) {
    return '„$title“ löschen? Die enthaltenen Stücke bleiben davon unberührt.';
  }

  @override
  String libraryScreenDeleteScoreBody(String title) {
    return '„$title“ löschen? Das kann nicht rückgängig gemacht werden.';
  }

  @override
  String libraryScreenDeleteScoreWithPiecesBody(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'zugehörige Stücke',
      one: 'zugehöriges Stück',
    );
    return '„$title“ und $count $_temp0 löschen? Das kann nicht rückgängig gemacht werden.';
  }

  @override
  String get libraryScreenDeleteScoreTitle => 'Stück löschen?';

  @override
  String get libraryScreenTabScores => 'Stücke';

  @override
  String get libraryScreenTabSetlists => 'Setlists';

  @override
  String get libraryScreenSearchHint => 'Stücke suchen';

  @override
  String get libraryScreenAddPdf => 'PDF hinzufügen';

  @override
  String libraryScreenSplitSuggestionWithPages(String name, int pages) {
    return '„$name“ ($pages Seiten) sieht so aus, als könnten es mehrere Stücke sein.';
  }

  @override
  String libraryScreenSplitSuggestionGeneric(String name) {
    return '„$name“ sieht so aus, als könnten es mehrere Stücke sein.';
  }

  @override
  String get libraryScreenNotNow => 'Nicht jetzt';

  @override
  String get libraryScreenSplitEllipsis => 'Aufteilen…';

  @override
  String libraryScreenFailedToOpen(String error) {
    return 'Bibliothek konnte nicht geöffnet werden: $error';
  }

  @override
  String get libraryScreenNoScoresYet => 'Noch keine Stücke';

  @override
  String get libraryScreenImportPdfHint => 'Importiere ein PDF, um loszulegen.';

  @override
  String get libraryScreenAddSampleScore => 'Beispielstück hinzufügen';

  @override
  String libraryScreenNoScoresMatchSearch(String query) {
    return 'Keine Stücke gefunden für „$query“.';
  }

  @override
  String libraryScreenNoScoresMatchFilter(String filter) {
    return 'Keine Stücke entsprechen $filter.';
  }

  @override
  String get libraryScreenClearSearch => 'Suche löschen';

  @override
  String get libraryScreenClearFilter => 'Filter entfernen';

  @override
  String libraryScreenRecencyWithPieces(String when, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Stücke',
      one: 'Stück',
    );
    return '$when · $count $_temp0';
  }

  @override
  String get libraryScreenPiecesEllipsis => 'Stücke…';

  @override
  String get libraryScreenEditPiecesMenuItem => 'Stücke bearbeiten…';

  @override
  String get libraryScreenOpenFullScore => 'Gesamtes Stück öffnen';

  @override
  String get libraryScreenRenameEllipsis => 'Umbenennen…';

  @override
  String get libraryScreenLabelsEllipsis => 'Labels…';

  @override
  String get libraryScreenSplitIntoPiecesEllipsis => 'In Stücke aufteilen…';

  @override
  String get libraryScreenPagesEllipsis => 'Seiten…';

  @override
  String get libraryScreenReplacePdfEllipsis => 'PDF ersetzen…';

  @override
  String get libraryScreenDeleteEllipsis => 'Löschen…';

  @override
  String libraryScreenAddedRelative(String when) {
    return 'Hinzugefügt $when';
  }

  @override
  String libraryScreenOpenedRelative(String when) {
    return 'Geöffnet $when';
  }

  @override
  String libraryScreenRecencyWithPages(String when, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: 'Seiten',
      one: 'Seite',
    );
    return '$when · $pages $_temp0';
  }

  @override
  String get libraryScreenNoSetlistsYet => 'Noch keine Setlists';

  @override
  String get libraryScreenSetlistsEmptyHint =>
      'Gruppiere Stücke für ein durchgehendes Konzert, ohne jedes einzeln öffnen zu müssen.';

  @override
  String libraryScreenSetlistScoreCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Stücke',
      one: 'Stück',
    );
    return '$count $_temp0';
  }

  @override
  String get libraryScreenSetlistCountEmpty => 'Leer';

  @override
  String libraryScreenSetlistScoreCountOpened(
    String scoreCount,
    String opened,
  ) {
    return '$scoreCount · $opened';
  }

  @override
  String get metronomeSheetTitle => 'Metronom';

  @override
  String get metronomeSheetTempo => 'Tempo';

  @override
  String get metronomeSheetMeter => 'Taktart';

  @override
  String get metronomeSheetMeterHint =>
      'Wie die Schläge in jedem Takt gruppiert sind';

  @override
  String get metronomeSheetEqual => 'Gleichmäßig';

  @override
  String get metronomeSheetMute => 'Stumm';

  @override
  String get metronomeSheetShowBeats => 'Schläge anzeigen';

  @override
  String get metronomeSheetShowBeatsHint =>
      'Blinkt im Takt auf dem Stück, während es läuft';

  @override
  String metronomeSheetVolume(int percent) {
    return 'Lautstärke: $percent%';
  }

  @override
  String get metronomeSheetStop => 'Stopp';

  @override
  String get metronomeSheetStart => 'Start';

  @override
  String get metronomeSheetEnterNumber => 'Zahl eingeben';

  @override
  String get metronomeSheetTempoDialogTitle => 'Tempo festlegen';

  @override
  String get pageExtentScreenTitle => 'Seiten';

  @override
  String pageExtentScreenFirstPage(int page) {
    return 'Erste Seite: $page';
  }

  @override
  String pageExtentScreenLastPage(int page) {
    return 'Letzte Seite: $page';
  }

  @override
  String get pageExtentScreenNoPages => 'Keine Seiten';

  @override
  String get pageExtentScreenBadgeOnly => 'Einzig';

  @override
  String get pageExtentScreenBadgeFirst => 'Erste';

  @override
  String get pageExtentScreenBadgeLast => 'Letzte';

  @override
  String pageExtentScreenSummary(String title, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: 'Seiten',
      one: 'Seite',
    );
    return '$title — $pages $_temp0';
  }

  @override
  String get pageExtentScreenHint =>
      'Tippe unten auf eine Seite, um die ausgewählte Grenze festzulegen.';

  @override
  String get pageNavBarPreviousPageTooltip => 'Vorherige Seite';

  @override
  String get pageNavBarNextPageTooltip => 'Nächste Seite';

  @override
  String pageNavBarJumpedSnackbar(int page, int count) {
    return 'Zu Seite $page von $count gesprungen';
  }

  @override
  String get pageNavBarGoToPageTitle => 'Zu Seite springen';

  @override
  String pageNavBarPageFieldLabel(int count) {
    return 'Seite (1–$count)';
  }

  @override
  String get piecesScreenEditPieces => 'Stücke bearbeiten…';

  @override
  String get piecesScreenNoPieces => 'Keine Stücke';

  @override
  String get piecesScreenRename => 'Umbenennen…';

  @override
  String get piecesScreenLabels => 'Labels…';

  @override
  String get piecesScreenSplitIntoPieces => 'In Stücke aufteilen…';

  @override
  String get piecesScreenPages => 'Seiten…';

  @override
  String get piecesScreenReplacePdf => 'PDF ersetzen…';

  @override
  String get piecesScreenDelete => 'Löschen…';

  @override
  String piecesScreenAdded(String when) {
    return 'Hinzugefügt $when';
  }

  @override
  String piecesScreenOpened(String when) {
    return 'Geöffnet $when';
  }

  @override
  String piecesScreenRecencyWithPages(String when, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: 'Seiten',
      one: 'Seite',
    );
    return '$when · $pages $_temp0';
  }

  @override
  String piecesScreenPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Stücke',
      one: 'Stück',
    );
    return '$count $_temp0';
  }

  @override
  String piecesScreenPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seiten',
      one: 'Seite',
    );
    return '$count $_temp0';
  }

  @override
  String get piecesScreenOpenFullScore => 'Gesamtes Stück öffnen';

  @override
  String get setlistEditorImportFirst => 'Importiere zuerst ein Stück.';

  @override
  String get setlistEditorDefaultTitle => 'Neue Setlist';

  @override
  String get setlistEditorAppBarTitle => 'Setlist bearbeiten';

  @override
  String get setlistEditorAddScores => 'Stücke hinzufügen';

  @override
  String get setlistEditorTitleFieldLabel => 'Titel';

  @override
  String get setlistEditorEmpty =>
      'Noch keine Stücke. Tippe auf „Stücke hinzufügen“, um die Setlist zu erstellen.';

  @override
  String get setlistEditorMissingScore => 'Fehlendes Stück';

  @override
  String get setlistEditorRemovedFromLibrary => 'Aus der Bibliothek entfernt';

  @override
  String get setlistEditorRemoveTooltip => 'Entfernen';

  @override
  String setlistEditorAddCount(int count) {
    return 'Hinzufügen ($count)';
  }

  @override
  String setlistEditorPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Stücke',
      one: 'Stück',
    );
    return '$count $_temp0';
  }

  @override
  String get setlistEditorPiecesTooltip => 'Stücke ansehen';

  @override
  String get splitScoreScreenRenameTitle => 'Umbenennen';

  @override
  String get splitScoreScreenTitle => 'In Stücke aufteilen';

  @override
  String get splitScoreScreenClearMarks => 'Markierungen löschen';

  @override
  String get splitScoreScreenNoPages => 'Keine Seiten';

  @override
  String splitScoreScreenPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stücke',
      one: '1 Stück',
      zero: 'Noch keine Stücke',
    );
    return '$_temp0';
  }

  @override
  String get splitScoreScreenHint =>
      'Tippe auf eine Seite, um den Beginn eines neuen Stücks zu markieren. Halte eine markierte Seite gedrückt, um sie umzubenennen.';

  @override
  String splitScoreScreenFrontMatterPage(int page) {
    return 'Seite $page gehört zum Vorspann und wird keinem Stück zugeordnet.';
  }

  @override
  String splitScoreScreenFrontMatterPages(int first, int last) {
    return 'Seiten $first–$last gehören zum Vorspann und werden keinem Stück zugeordnet.';
  }

  @override
  String splitScoreScreenUseContents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Einträge',
      one: 'Eintrag',
    );
    return 'Inhaltsverzeichnis verwenden ($count $_temp0)';
  }

  @override
  String get libraryScreenNoPdfFiles => 'Keine PDF-Dateien gefunden.';

  @override
  String libraryScreenImportedScores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stücke importiert',
      one: '1 Stück importiert',
    );
    return '$_temp0';
  }

  @override
  String get libraryScreenCreateBackupTitle => 'Sicherung erstellen?';

  @override
  String get libraryScreenCreateBackupBody =>
      'Dies speichert eine Kopie deiner gesamten Bibliothek — Stücke, Labels, Setlists und Einstellungen — als ZIP-Datei, die du teilen oder sicher aufbewahren kannst.';

  @override
  String get libraryScreenCreateBackupConfirm => 'Sicherung erstellen';

  @override
  String get libraryScreenCreatingBackup => 'Sicherung wird erstellt…';

  @override
  String get libraryScreenBackupShareSubject => 'StageScore-Sicherung';

  @override
  String libraryScreenBackupSaved(String path) {
    return 'Sicherung gespeichert unter $path';
  }

  @override
  String get libraryScreenBackupReady =>
      'Sicherung bereit — Teilen-Menü geöffnet';

  @override
  String libraryScreenBackupFailed(String error) {
    return 'Sicherung konnte nicht erstellt werden: $error';
  }

  @override
  String get libraryScreenRestoreBackupTitle => 'Sicherung wiederherstellen?';

  @override
  String get libraryScreenRestoreBackupBody =>
      'Dies ersetzt deine gesamte Bibliothek — Stücke, Labels, Setlists und Einstellungen — durch den Inhalt der Sicherung. Das kann nicht rückgängig gemacht werden.';

  @override
  String get libraryScreenReplaceAll => 'Alles ersetzen';

  @override
  String get libraryScreenRestoringBackup =>
      'Sicherung wird wiederhergestellt…';

  @override
  String get libraryScreenLibraryRestored => 'Bibliothek wiederhergestellt';

  @override
  String libraryScreenRestoreFailed(String error) {
    return 'Sicherung konnte nicht wiederhergestellt werden: $error';
  }

  @override
  String libraryScreenPercentValue(int percent) {
    return '$percent%';
  }

  @override
  String get libraryScreenUntagged => 'Ohne Label';

  @override
  String get libraryScreenThisFilter => 'diesem Filter';

  @override
  String get libraryScreenAndConjunction => 'und';

  @override
  String get libraryScreenAllOf => 'Alle von';

  @override
  String libraryScreenRemoveFilterChip(String label) {
    return 'Filter „$label“ entfernen';
  }

  @override
  String get libraryScreenRenameScoreTitle => 'Stück umbenennen';

  @override
  String get libraryScreenReplacePdfTitle => 'PDF ersetzen?';

  @override
  String libraryScreenReplacePdfBodyShared(
    int sharing,
    String title,
    int others,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: 'Stücke',
      one: 'Stück',
    );
    return 'Dieses PDF wird von $sharing Stücken gemeinsam genutzt, darunter „$title“. Wenn du es ersetzt, ändert sich auch das PDF für die anderen $others $_temp0.';
  }

  @override
  String libraryScreenReplacePdfBodySingle(String title) {
    return 'Das PDF hinter „$title“ ersetzen? Du kannst seine Anmerkungen unten behalten oder zurücksetzen.';
  }

  @override
  String get libraryScreenKeepOverlays => 'Anmerkungen behalten';

  @override
  String get libraryScreenResetOverlays => 'Anmerkungen zurücksetzen';

  @override
  String get libraryScreenOverlaysReset => 'Anmerkungen zurückgesetzt.';

  @override
  String get libraryScreenOverlaysKept => 'Anmerkungen beibehalten.';

  @override
  String libraryScreenPdfReplaced(String overlayNote) {
    return 'PDF ersetzt. $overlayNote';
  }

  @override
  String libraryScreenPdfReplacedShortened(String overlayNote, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'wurden $count Seiteneinträge entfernt',
      one: 'wurde 1 Seiteneintrag entfernt',
    );
    return 'PDF ersetzt. $overlayNote Die neue Datei ist kürzer, daher $_temp0.';
  }

  @override
  String libraryScreenReplaceFailed(String error) {
    return 'PDF konnte nicht ersetzt werden: $error';
  }

  @override
  String continuousPageOrderViewOpenFailed(String error) {
    return 'PDF konnte nicht geöffnet werden: $error';
  }

  @override
  String get performancePageSlotBlank => 'Leer';

  @override
  String performancePageSlotMissingPage(int page) {
    return 'Fehlende Seite $page';
  }

  @override
  String singlePageSliderOpenFailed(String error) {
    return 'PDF konnte nicht geöffnet werden: $error';
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
    return 'Link konnte nicht geöffnet werden: $url';
  }

  @override
  String aboutSheetTitle(String productName) {
    return 'Über $productName';
  }

  @override
  String get aboutSheetWebsiteLabel => 'Website';

  @override
  String get aboutSheetPrivacyLabel => 'Datenschutz';

  @override
  String get aboutSheetSupportLabel => 'Support';

  @override
  String get bookmarksSheetAddTitle => 'Lesezeichen hinzufügen';

  @override
  String bookmarksSheetPageLabel(int page) {
    return 'Seite $page';
  }

  @override
  String get bookmarksSheetRenameTitle => 'Lesezeichen umbenennen';

  @override
  String get bookmarksSheetTitle => 'Lesezeichen';

  @override
  String get bookmarksSheetEmpty => 'Noch keine Lesezeichen';

  @override
  String get displaySheetBorderColorTitle => 'Randfarbe';

  @override
  String displaySheetHue(int value) {
    return 'Farbton: $value';
  }

  @override
  String displaySheetSaturation(int value) {
    return 'Sättigung: $value';
  }

  @override
  String displaySheetColorValue(int value) {
    return 'Wert: $value';
  }

  @override
  String get displaySheetTitle => 'Anzeige';

  @override
  String get displaySheetPerformanceMode => 'Performance-Modus';

  @override
  String get displaySheetPageBorder => 'Seitenrand';

  @override
  String displaySheetThickness(String value) {
    return 'Dicke: $value';
  }

  @override
  String get displaySheetColorLabel => 'Farbe';

  @override
  String get displaySheetCustomChip => 'Benutzerdefiniert';

  @override
  String get displaySheetShowStatusBar => 'Statusleiste anzeigen';

  @override
  String get displaySheetShowStatusBarHint =>
      'Zeigt Uhrzeit und Akkustand während des Spielens weiter an';

  @override
  String get displaySheetAvoidNotches => 'Notch vermeiden';

  @override
  String get displaySheetAvoidNotchesHint =>
      'Hält die Seite frei von Kamera-Notch und abgerundeten Ecken';

  @override
  String get jumpLinkEditSheetAddTitle => 'Sprungmarke hinzufügen';

  @override
  String get jumpLinkEditSheetEditTitle => 'Sprungmarke bearbeiten';

  @override
  String jumpLinkEditSheetOriginLabel(int page) {
    return 'Von Seite $page';
  }

  @override
  String jumpLinkEditSheetDestinationLabel(int page, int pageCount) {
    return 'Zu Seite $page von $pageCount';
  }

  @override
  String get jumpLinkEditSheetColorLabel => 'Farbe';

  @override
  String get jumpLinkEditSheetSizeLabel => 'Größe';

  @override
  String get jumpLinksSheetDragHint =>
      'Hinzugefügt. Ziehe eine Sprungmarke in der Liste, um sie neu anzuordnen.';

  @override
  String get jumpLinksSheetTitle => 'Sprungmarken';

  @override
  String get jumpLinksSheetEmpty => 'Noch keine Sprungmarken';

  @override
  String jumpLinksSheetRowTitle(int from, int to) {
    return 'Seite $from → $to';
  }

  @override
  String get jumpLinksSheetRowSubtitle => 'Zum Springen antippen';

  @override
  String labelSheetsTitle(String title) {
    return 'Labels für $title';
  }

  @override
  String get labelSheetsManage => 'Verwalten';

  @override
  String get labelSheetsCreateLabel => 'Label erstellen';

  @override
  String get labelSheetsNewLabel => 'Neues Label';

  @override
  String get labelSheetsManageTitle => 'Labels verwalten';

  @override
  String get labelSheetsNoLabelsYet => 'Noch keine Labels';

  @override
  String labelSheetsUsageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Verwendet von $count Stücken',
      one: 'Verwendet von 1 Stück',
    );
    return '$_temp0';
  }

  @override
  String get labelSheetsDeleteTitle => 'Label löschen?';

  @override
  String labelSheetsDeleteConfirm(String name) {
    return '„$name“ löschen?';
  }

  @override
  String labelSheetsDeleteConfirmWithUsage(String name, int usage) {
    String _temp0 = intl.Intl.pluralLogic(
      usage,
      locale: localeName,
      other: 'Stücken',
      one: 'Stück',
    );
    return '„$name“ wird von $usage $_temp0 verwendet. Trotzdem löschen?';
  }

  @override
  String get labelSheetsRenameLabelTitle => 'Label umbenennen';

  @override
  String get labelSheetsNameHint => 'Labelname';

  @override
  String get libraryFilterSheetTitle => 'Filter';

  @override
  String get libraryFilterSheetModeAny => 'Beliebig';

  @override
  String get libraryFilterSheetModeAll => 'Alle';

  @override
  String get libraryFilterSheetModeUntagged => 'Ohne Label';

  @override
  String get libraryFilterSheetUntaggedHint => 'Stücke ohne Labels';

  @override
  String get libraryFilterSheetEmptyLabels => 'Noch keine Labels zum Filtern';

  @override
  String get measureMapMeasureCountTitle => 'Wie viele MeasureBoxes?';

  @override
  String get measureMapMeasureCountLabel => 'MeasureBoxes';

  @override
  String get measureMapGoToTitle => 'Zur Taktnummer';

  @override
  String get measureMapGoToLabel => 'Taktnummer';

  @override
  String measureMapGoToMissing(int number) {
    return 'Takt $number ist noch nicht gemappt';
  }

  @override
  String get measureMapMetaTitle => 'Tempo & Taktart';

  @override
  String get measureMapTimeSignatureLabel => 'Taktart';

  @override
  String get measureMapTempoLabel => 'Tempo';

  @override
  String get measureMapMetaScopeTitle => 'Anwenden auf';

  @override
  String get measureMapScopeThisMeasure => 'Nur diesen Takt';

  @override
  String get measureMapScopeThisSystem => 'Dieses System';

  @override
  String get measureMapScopeThisPage => 'Diese Seite';

  @override
  String get measureMapScopeRestOfScore => 'Rest des Scores';

  @override
  String get measureMapScopeNextN => 'Next N…';

  @override
  String get measureMapMetaNextNLabel => 'Anzahl Takte';

  @override
  String get measureMapClearTitle => 'MeasureMap löschen?';

  @override
  String get measureMapClearBody =>
      'Löscht alle SystemBox- und MeasureBox-Einträge dieses Scores. Nicht rückgängig.';

  @override
  String get measureMapClearConfirm => 'Löschen';

  @override
  String get measureMapDeleteSystemTitle => 'System löschen?';

  @override
  String get measureMapDeleteSystemBody =>
      'Löscht diese SystemBox und alle MeasureBoxes darin.';

  @override
  String get measureMapCopyFromPageTitle => 'Layout von Seite kopieren';

  @override
  String get measureMapCopyFromPageLabel => 'Quellseite';

  @override
  String get measureMapCopyPrevious => 'Vorherige Seite kopieren';

  @override
  String get measureMapEmptyHint =>
      'Zeichne ein System — die App fragt nach der Taktzahl';

  @override
  String get measureMapDone => 'Fertig';

  @override
  String get measureMapEditBeats => 'Edit beats';

  @override
  String get measureMapSetMeasureCount => 'Taktanzahl festlegen…';

  @override
  String get measureMapDeleteSystem => 'System löschen';

  @override
  String get measureMapDeleteMeasure => 'Takt löschen';

  @override
  String get measureMapEditMeta => 'Tempo & Taktart…';

  @override
  String get measureMapClearAll => 'MeasureMap löschen…';
}
