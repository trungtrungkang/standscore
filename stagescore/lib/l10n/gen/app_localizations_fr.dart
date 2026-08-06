// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionDone => 'Terminé';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionOk => 'OK';

  @override
  String get actionClear => 'Effacer';

  @override
  String get actionApply => 'Appliquer';

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionRename => 'Renommer';

  @override
  String get actionBack => 'Retour';

  @override
  String get actionMore => 'Plus';

  @override
  String get actionGo => 'Aller';

  @override
  String get actionUndo => 'Annuler';

  @override
  String get actionContinue => 'Continuer';

  @override
  String get actionReset => 'Réinitialiser';

  @override
  String get commonOr => 'ou';

  @override
  String get commonTitleLabel => 'Titre';

  @override
  String get themeModeSystem => 'Système';

  @override
  String get themeModeLight => 'Clair';

  @override
  String get themeModeDark => 'Sombre';

  @override
  String get pdfLayoutModeAuto => 'Auto';

  @override
  String get pdfLayoutModeSingle => 'Une page';

  @override
  String get pdfLayoutModeTwoPages => 'Deux pages';

  @override
  String get pdfLayoutModeScroll => 'Défilement';

  @override
  String get pdfLayoutModeScrollSideways => 'Défilement (latéral)';

  @override
  String get pdfLayoutModeHalfPageTopBottom => 'Une page + aperçu';

  @override
  String get pdfLayoutModeHalfPageLeftRight => 'Une page + aperçu latéral';

  @override
  String get pageColorFilterOff => 'Désactivé';

  @override
  String get pageColorFilterSepia => 'Sépia';

  @override
  String get pageColorFilterGreen => 'Vert';

  @override
  String get pageColorFilterInvert => 'Inversé';

  @override
  String get pageScaleScopeFixed => 'Fixe';

  @override
  String get pageScaleScopePerScore => 'Par partition';

  @override
  String get pageScaleScopePerPage => 'Par page';

  @override
  String get stagePresetSetUpToPlay => 'Préparer pour jouer';

  @override
  String get stagePresetSetUpToPractise => 'Préparer pour répéter';

  @override
  String get stagePresetChromeHidden => 'interface masquée';

  @override
  String get stagePresetChromeShown => 'interface affichée';

  @override
  String get stagePresetStatusBarShown => 'barre d\'état affichée';

  @override
  String get stagePresetStatusBarHidden => 'barre d\'état masquée';

  @override
  String get stagePresetScaleKept => 'échelle conservée';

  @override
  String get stagePresetPinchFree => 'pincement libre';

  @override
  String get relativeDayToday => 'aujourd\'hui';

  @override
  String get relativeDayYesterday => 'hier';

  @override
  String relativeDayDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'jours',
      one: 'jour',
    );
    return 'il y a $days $_temp0';
  }

  @override
  String pageOrderEditorEntryBlank(int index) {
    return '$index. Vierge';
  }

  @override
  String pageOrderEditorEntryPdfPage(int index, int sourcePage) {
    return '$index. Page PDF $sourcePage';
  }

  @override
  String get pageOrderEditorResetTitle => 'Réinitialiser à l\'original ?';

  @override
  String get pageOrderEditorResetBody =>
      'Restaurer l\'ordre des pages du PDF et supprimer les pages vierges et les doublons ?';

  @override
  String get pageOrderEditorReset => 'Réinitialiser';

  @override
  String get pageOrderEditorAppBarTitle => 'Ordre des pages';

  @override
  String get pageOrderEditorNoPages => 'Aucune page';

  @override
  String get pageOrderEditorDuplicate => 'Dupliquer';

  @override
  String get pageOrderEditorInsertBlank => 'Insérer une page vierge';

  @override
  String get pageOrderEditorRemove => 'Retirer';

  @override
  String get librarySortTitle => 'Titre';

  @override
  String get librarySortCreated => 'Création';

  @override
  String get librarySortLastViewed => 'Dernière consultation';

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
    return '$pages de $name';
  }

  @override
  String libraryVisibilityInBook(String title) {
    return 'dans $title';
  }

  @override
  String get libraryVisibilityInBookFallback => 'dans le recueil';

  @override
  String get libraryBackupFileNotFound => 'Fichier de sauvegarde introuvable.';

  @override
  String get libraryBackupFailedGeneric => 'Échec de la sauvegarde.';

  @override
  String libraryBackupCreateFailed(String error) {
    return 'Impossible de créer la sauvegarde : $error';
  }

  @override
  String libraryBackupRestoreFailed(String error) {
    return 'Impossible de restaurer la sauvegarde : $error';
  }

  @override
  String get libraryBackupMissingMarker =>
      'Ce n\'est pas une sauvegarde StageScore (marqueur manquant).';

  @override
  String get libraryBackupUnknownFormat =>
      'Ce n\'est pas une sauvegarde StageScore (format inconnu).';

  @override
  String get libraryBackupUnsupportedVersion =>
      'Version de sauvegarde StageScore non prise en charge.';

  @override
  String get libraryBackupCorruptMarker =>
      'Ce n\'est pas une sauvegarde StageScore (marqueur corrompu).';

  @override
  String get gestureMapLongPress => 'appui long';

  @override
  String get gestureMapTapTopEdge => 'toucher le bord supérieur';

  @override
  String get gestureMapTapBottomEdge => 'toucher le bord inférieur';

  @override
  String get gestureMapEmptyHint =>
      'Associe un geste à Afficher le menu / l\'interface pour pouvoir le faire réapparaître.';

  @override
  String gestureMapRevealHint(String joined) {
    return 'Masque la barre d\'outils et la barre de pages pendant que tu joues. Pour les faire réapparaître, $joined.';
  }

  @override
  String get layoutNavigationPedalOrPageBar => 'La pédale ou la barre de pages';

  @override
  String get layoutNavigationTapLeftRight => 'toucher à gauche / à droite';

  @override
  String get layoutNavigationTapTopBottom => 'toucher en haut / en bas';

  @override
  String get layoutNavigationTapAnywhere => 'toucher n\'importe où';

  @override
  String get layoutNavigationTapAnywhereBack =>
      'toucher n\'importe où pour revenir';

  @override
  String get layoutNavigationSwipe => 'glisser';

  @override
  String get layoutNavigationSwipeSideways => 'glisser latéralement';

  @override
  String get layoutNavigationSwipeUpDown => 'glisser vers le haut / le bas';

  @override
  String get scoreMenuSheetTitle => 'Menu';

  @override
  String get appearanceSheetTitle => 'Apparence';

  @override
  String get appearanceSheetMode => 'Mode';

  @override
  String get appearanceSheetThemeColor => 'Couleur du thème';

  @override
  String get appearanceSheetCustomChip => 'Personnalisée';

  @override
  String get appearanceSheetCustomColorDialog => 'Couleur personnalisée';

  @override
  String get appearanceSheetHue => 'Teinte';

  @override
  String get appearanceSheetSat => 'Sat';

  @override
  String get appearanceSheetVal => 'Val';

  @override
  String get scoreMenuGoTo => 'Aller à';

  @override
  String get scoreMenuBookmarks => 'Signets';

  @override
  String get scoreMenuJumpLinks => 'Renvois';

  @override
  String get scoreMenuPageOrder => 'Ordre des pages…';

  @override
  String get scoreMenuGoToMeasure => 'Aller à la mesure…';

  @override
  String get scoreMenuMeasureMap => 'Measure map…';

  @override
  String get scoreMenuFormMap => 'Form map…';

  @override
  String get scoreMenuFormMapNeedsMeasureMap => 'Map measures first';

  @override
  String get formMapEmptyHint =>
      'No form = play straight through once. Add a repeat (with optional 1st/2nd ending) or tap a MeasureBox for markers/jumps. Jump Links are different — they jump pages by hand.';

  @override
  String get formMapDone => 'Done';

  @override
  String get formMapAddRepeat => 'Add repeat…';

  @override
  String get formMapReplaceRepeatTitle => 'Replace existing repeat?';

  @override
  String get formMapReplaceRepeatBody =>
      'This Score already has a repeat that overlaps these measures. Replace it with the new one?';

  @override
  String get formMapReplaceConfirm => 'Replace';

  @override
  String get formMapVoltaSection => '1st / 2nd ending (optional)';

  @override
  String get formMapVoltaHint =>
      'Leave blank for a plain repeat. Example: first time play 8 then go back; second time skip 8 → set pass 1 to 8 and pass 2 to 9.';

  @override
  String get formMapPass1Label => 'Pass 1 only (1st ending)';

  @override
  String get formMapPass2Label => 'Pass 2 only (2nd ending)';

  @override
  String get formMapAddEnding => '1st / 2nd ending…';

  @override
  String get formMapEndingHint =>
      'Volta brackets on the page — measures played only on one pass through a repeat. Example: first time play measure 8 then go back; second time skip 8 and continue at 9 → mark 8 as pass 1.';

  @override
  String get formMapEndingNumberHint =>
      '1 = first time through the repeat, 2 = second time, …';

  @override
  String get formMapSetMarker => 'Marker…';

  @override
  String get formMapSetJump => 'Jump…';

  @override
  String get formMapClearMeasure => 'Clear on measure';

  @override
  String get formMapClearAll => 'Clear FormMap…';

  @override
  String get formMapClearTitle => 'Clear FormMap?';

  @override
  String get formMapClearBody =>
      'Removes all repeats, endings, markers, and jumps on this Score. Cannot be undone.';

  @override
  String get formMapClearConfirm => 'Clear';

  @override
  String get formMapMarkerNone => 'No marker';

  @override
  String get formMapMarkerNoneDesc => 'Clear any marker on this measure';

  @override
  String get formMapMarkerSegno => 'Segno';

  @override
  String get formMapMarkerSegnoDesc =>
      'Landmark on the page. D.S. jumps back here';

  @override
  String get formMapMarkerCoda => 'Coda';

  @override
  String get formMapMarkerCodaDesc =>
      'Start of the coda section. To Coda lands here';

  @override
  String get formMapMarkerToCoda => 'To Coda';

  @override
  String get formMapMarkerToCodaDesc =>
      'After D.C./D.S. returns, skip ahead to the Coda';

  @override
  String get formMapMarkerFine => 'Fine';

  @override
  String get formMapMarkerFineDesc =>
      'Stop here after D.C./D.S. returns (ignored on the first pass)';

  @override
  String get formMapJumpNone => 'No jump';

  @override
  String get formMapJumpNoneDesc => 'Clear any jump on this measure';

  @override
  String get formMapJumpDaCapo => 'D.C.';

  @override
  String get formMapJumpDaCapoDesc =>
      'Da Capo — go back to the start, then follow To Coda / Fine';

  @override
  String get formMapJumpDalSegno => 'D.S.';

  @override
  String get formMapJumpDalSegnoDesc =>
      'Dal Segno — go back to the Segno, then follow To Coda / Fine';

  @override
  String get formMapJumpToCoda => 'To Coda';

  @override
  String get formMapJumpToCodaDesc =>
      'Jump to the Coda marker (only after a D.C. or D.S.)';

  @override
  String get formMapStartMeasure => 'Start measure';

  @override
  String get formMapEndMeasure => 'End measure';

  @override
  String get formMapRepeatTimes => 'Times';

  @override
  String get formMapEndingNumber => 'Which pass?';

  @override
  String get formMapInvalidSnackbar =>
      'FormMap is invalid — fix repeats/jumps before Play';

  @override
  String get formMapInvalidMissingMeasure =>
      'FormMap references a measure that is not mapped';

  @override
  String get formMapInvalidRepeat => 'FormMap has an invalid repeat region';

  @override
  String get formMapInvalidEnding => 'FormMap has an invalid ending';

  @override
  String get formMapInvalidLoop =>
      'FormMap loops too long — check repeats and jumps';

  @override
  String get formMapInvalidEmptyTimeline =>
      'FormMap produces an empty timeline';

  @override
  String get scoreMenuMarks => 'Annotations';

  @override
  String get scoreMenuHideAnnotations => 'Masquer les annotations';

  @override
  String get scoreMenuShowAnnotations => 'Afficher les annotations';

  @override
  String get scoreMenuExporting => 'Exportation…';

  @override
  String get scoreMenuExportAnnotated => 'Exporter le PDF avec annotations';

  @override
  String get scoreMenuView => 'Vue';

  @override
  String get scoreMenuLayout => 'Disposition';

  @override
  String get scoreMenuDisplay => 'Affichage…';

  @override
  String get scoreMenuColorFilter => 'Filtre de couleur…';

  @override
  String get scoreMenuPageScale => 'Échelle de page…';

  @override
  String get scoreMenuLocked => 'Verrouillé';

  @override
  String get scoreMenuPlaying => 'En lecture';

  @override
  String get scoreMenuMetronomeRunning => 'Métronome (en cours)…';

  @override
  String get scoreMenuMetronome => 'Métronome…';

  @override
  String get scoreMenuShowPlaybackControls => 'Show Playback controls';

  @override
  String get scoreMenuHidePlaybackControls => 'Hide Playback controls';

  @override
  String get scoreMenuPlaybackSettings => 'Playback settings…';

  @override
  String get playbackSettingsTitle => 'Playback settings';

  @override
  String get playbackSettingsPlayhead => 'Playhead';

  @override
  String get playbackSettingsPlayheadHint =>
      'Ligne sur la partition pendant la lecture';

  @override
  String get playbackSettingsPlayheadColor => 'Couleur';

  @override
  String playbackSettingsPlayheadSize(String value) {
    return 'Épaisseur $value';
  }

  @override
  String playbackSettingsPlayheadOpacity(int percent) {
    return 'Opacité $percent%';
  }

  @override
  String playbackSettingsPlayheadHeight(int percent) {
    return 'Hauteur $percent% de la mesure';
  }

  @override
  String get scoreMenuPlaybackMapFirst => 'Map measures first';

  @override
  String get scoreMenuPageTurnSettings => 'Réglages de tourne-page';

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
  String get metronomeSheetPlaybackStyle => 'Controls layout';

  @override
  String get metronomeSheetPlaybackStyleHint =>
      'Bar sits above page chrome; Float is a small draggable Play/Stop';

  @override
  String get metronomeSheetPlaybackStyleDocked => 'Bar';

  @override
  String get metronomeSheetPlaybackStyleFloating => 'Float';

  @override
  String get playbackMapLostSnackbar => 'MeasureMap changed — playback stopped';

  @override
  String scoreMenuLayoutValueBoth(String stored, String resolved) {
    return '$stored · $resolved';
  }

  @override
  String get languageSheetTitle => 'Langue';

  @override
  String get languageSheetSystem => 'Système';

  @override
  String get languageSheetSystemSubtitle => 'Utiliser la langue de l\'appareil';

  @override
  String get stampSheetTitle => 'Tampons';

  @override
  String get stampBox => 'Rectangle';

  @override
  String get stampCircle => 'Cercle';

  @override
  String get stampArrow => 'Flèche';

  @override
  String get stampText => 'Texte';

  @override
  String get pageScaleSheetTitle => 'Échelle de page';

  @override
  String get pageScaleSheetExplainer =>
      'Détermine la taille d\'affichage de la partition, mémorisée d\'une session à l\'autre. Pincer change l\'affichage temporairement ; ce réglage le change définitivement.';

  @override
  String pageScaleSheetCurrent(String value) {
    return 'Sur cette page en ce moment : $value×';
  }

  @override
  String get pageScaleSheetAppliesTo => 'S\'applique à';

  @override
  String get pageScaleSheetScale => 'Échelle';

  @override
  String pageScaleSheetScaleValue(String value) {
    return '$value×';
  }

  @override
  String get pageScaleSheetKeepScale => 'Conserver cette échelle';

  @override
  String get pageScaleSheetKeepScaleSubtitle =>
      'Le pincement est désactivé : un contact accidentel en plein morceau ne peut pas déplacer la partition';

  @override
  String get pageScaleSheetHintFixed =>
      'Toutes les partitions, sauf celles qui ont leur propre échelle';

  @override
  String get pageScaleSheetHintPerScore =>
      'Cette partition uniquement, sur toutes ses pages';

  @override
  String get pageScaleSheetHintPerPage =>
      'Cette page uniquement — une page dense peut être agrandie sans changer les autres';

  @override
  String get layoutSettingsSheetTitle => 'Disposition';

  @override
  String get layoutSettingsSheetPageTurnSettings => 'Réglages de tourne-page';

  @override
  String get layoutSettingsSheetPageTurnSettingsSubtitle =>
      'Zones tactiles, glissement, pédale, animation';

  @override
  String get layoutSettingsSheetFallsBack =>
      'Une page sur cet écran — pivote l\'appareil pour une double page';

  @override
  String layoutSettingsSheetNow(String mode) {
    return 'Actuellement : $mode';
  }

  @override
  String get layoutSettingsSheetFitsScreen => 's\'adapte à cet écran';

  @override
  String get pageTurnSettingsSheetGestureWarning =>
      'Garde au moins un geste associé à Afficher le menu / l\'interface.';

  @override
  String get pageTurnSettingsSheetTitle => 'Tourne-page';

  @override
  String get pageTurnSettingsSheetTapZones => 'Zones tactiles';

  @override
  String pageTurnSettingsSheetTapZonesHint(
    String layoutMode,
    String navigationHint,
  ) {
    return 'En $layoutMode : $navigationHint.';
  }

  @override
  String get pageTurnSettingsSheetSwipe => 'Glissement';

  @override
  String get pageTurnSettingsSheetMatchLayout => 'Suivre la disposition';

  @override
  String get pageTurnSettingsSheetMatchLayoutSubtitle =>
      'Glisse dans le sens où les pages se déplacent';

  @override
  String get pageTurnSettingsSheetSwipeLeftNext => 'Glisser à gauche → suivant';

  @override
  String get pageTurnSettingsSheetSwipeRightPrevious =>
      'Glisser à droite → précédent';

  @override
  String get pageTurnSettingsSheetSwipeUpNext =>
      'Glisser vers le haut → suivant';

  @override
  String get pageTurnSettingsSheetSwipeDownPrevious =>
      'Glisser vers le bas → précédent';

  @override
  String get pageTurnSettingsSheetReverseDirection =>
      'Inverser le sens du tourne-page';

  @override
  String get pageTurnSettingsSheetReverseDirectionSubtitle =>
      'Pour les recueils qui se tournent dans l\'autre sens';

  @override
  String get pageTurnSettingsSheetTurnAmount => 'Amplitude du tourne-page';

  @override
  String get pageTurnSettingsSheetTurnAmountHintTwoPage =>
      '« Demi » avance une page de la double page au lieu de la paire entière.';

  @override
  String get pageTurnSettingsSheetTurnAmountHintDefault =>
      '« Demi » avance d\'environ ½ écran au lieu d\'un écran entier.';

  @override
  String get pageTurnSettingsSheetAnimation => 'Animation';

  @override
  String get pageTurnSettingsSheetPageTurnDelay => 'Délai du tourne-page';

  @override
  String get pageTurnSettingsSheetApplyTo => 'Appliquer à';

  @override
  String get pageTurnSettingsSheetGestures => 'Gestes';

  @override
  String get pageTurnSettingsSheetGesturesHint =>
      'Les appuis sur les bords sont de fines bandes en haut et en bas — différentes des zones de tourne-page Haut/bas. Au moins un geste doit être Afficher le menu / l\'interface ; ce geste fait aussi réapparaître la barre d\'outils en mode Performance. Le dessin s\'active depuis la barre d\'outils, jamais par un geste.';

  @override
  String get pageTurnSettingsSheetLongPress => 'Appui long';

  @override
  String get pageTurnSettingsSheetTopEdge => 'Bord supérieur';

  @override
  String get pageTurnSettingsSheetBottomEdge => 'Bord inférieur';

  @override
  String get pageTurnSettingsSheetPedalKeyboard => 'Pédale / clavier';

  @override
  String get pageTurnSettingsSheetPedalKeyboardHint =>
      'Les pédales Bluetooth qui envoient des touches de clavier sont prises en charge :\nPrécédent — PageUp, ←, ↑, Espace\nSuivant — PageDown, →, ↓, Entrée';

  @override
  String get pageTurnAnimationOff => 'Désactivée';

  @override
  String get pageTurnAnimationFast => 'Rapide';

  @override
  String get pageTurnAnimationNormal => 'Normale';

  @override
  String get pageTurnAnimationSlow => 'Lente';

  @override
  String get pageTurnDelayOff => 'Désactivé';

  @override
  String get pageTurnDelay300ms => '0,3 s';

  @override
  String get pageTurnDelay500ms => '0,5 s';

  @override
  String get pageTurnDelay1000ms => '1,0 s';

  @override
  String get pageTurnDelayScopeAll => 'Tous';

  @override
  String get pageTurnDelayScopePedalOnly => 'Pédale et clavier uniquement';

  @override
  String get pageTurnTapModeMatchLayout => 'Suivre la disposition';

  @override
  String get pageTurnTapModeLeftRight => 'Gauche / droite';

  @override
  String get pageTurnTapModeTopBottom => 'Haut / bas';

  @override
  String get pageTurnTapModePrevious => 'N\'importe où → préc.';

  @override
  String get pageTurnTapModeNext => 'N\'importe où → suiv.';

  @override
  String get pageTurnTapModeDisabled => 'Désactivé';

  @override
  String get turnAmountFull => 'Page entière';

  @override
  String get turnAmountHalf => 'Demi-page';

  @override
  String get gestureMapActionShowChrome => 'Afficher le menu / l\'interface';

  @override
  String get gestureMapActionDisabled => 'Désactivé';

  @override
  String get drawToolbarColorLabel => 'Couleur';

  @override
  String get drawToolbarSizeLabel => 'Taille';

  @override
  String get drawToolbarUndo => 'Annuler';

  @override
  String get drawToolbarRedo => 'Rétablir';

  @override
  String get drawToolbarDelete => 'Supprimer';

  @override
  String get drawToolbarStamp => 'Tampon';

  @override
  String get drawToolbarPlace => 'Placer';

  @override
  String get drawToolbarMore => 'Plus';

  @override
  String get drawToolbarTextStampTitle => 'Tampon texte';

  @override
  String get drawToolbarTextStampHint => 'Texte court';

  @override
  String get drawToolbarDrawOptionsTitle => 'Options de dessin';

  @override
  String get drawToolbarTool => 'Outil';

  @override
  String get drawToolbarWidth => 'Épaisseur';

  @override
  String get drawToolbarStraightLine => 'Ligne droite';

  @override
  String get drawToolPen => 'Stylo';

  @override
  String get drawToolMarker => 'Marqueur';

  @override
  String get drawToolEraser => 'Gomme';

  @override
  String get drawToolEyedropper => 'Pipette';

  @override
  String get drawWidthThin => 'Fine';

  @override
  String get drawWidthMedium => 'Moyenne';

  @override
  String get drawWidthThick => 'Épaisse';

  @override
  String get pdfModeScreenTapHint =>
      'Touche la moitié droite pour la page suivante, la gauche pour la précédente.';

  @override
  String get pdfModeScreenColorFilterTitle => 'Filtre de couleur';

  @override
  String get scoreMenuQuickBarBookmarks => 'Signets';

  @override
  String get scoreMenuQuickBarDraw => 'Dessiner';

  @override
  String get scoreMenuQuickBarExitDraw => 'Quitter le dessin';

  @override
  String get scoreMenuQuickBarMetronome => 'Métronome';

  @override
  String get scoreMenuQuickBarMetronomeRunning => 'Métronome (en cours)';

  @override
  String get pdfModeScreenExporting => 'Exportation du PDF…';

  @override
  String get pdfModeScreenExportReady =>
      'Export prêt — fenêtre de partage ouverte';

  @override
  String pdfModeScreenExportRestartHint(String path) {
    return 'Exporté vers $path. Redémarre complètement l\'application (stop + flutter run) pour activer la fenêtre de partage.';
  }

  @override
  String pdfModeScreenExportFailed(String error) {
    return 'Échec de l\'export : $error';
  }

  @override
  String pdfModeScreenPieceIndex(int index) {
    return '$index.';
  }

  @override
  String get pdfModeScreenHidePieceNotes => 'Masquer les notes du morceau';

  @override
  String get pdfModeScreenShowPieceNotes => 'Afficher les notes du morceau';

  @override
  String get pdfModeScreenPieceNotes => 'Notes du morceau';

  @override
  String get libraryScreenSort => 'Trier';

  @override
  String get libraryScreenFilter => 'Filtrer';

  @override
  String get libraryScreenManageLabels => 'Gérer les libellés';

  @override
  String get libraryScreenMore => 'Plus';

  @override
  String get libraryScreenAppearance => 'Apparence…';

  @override
  String get libraryScreenLanguage => 'Langue…';

  @override
  String get libraryScreenBackup => 'Sauvegarde…';

  @override
  String get libraryScreenRestore => 'Restauration…';

  @override
  String libraryScreenAbout(String productName) {
    return 'À propos de $productName…';
  }

  @override
  String libraryScreenSplitIntoPiecesSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'morceaux',
      one: 'morceau',
    );
    return 'Divisé en $count $_temp0';
  }

  @override
  String get libraryScreenStillReadingPdf =>
      'Ce PDF est encore en cours de lecture — réessaie dans un instant.';

  @override
  String get libraryScreenEditPiecesAppBarTitle => 'Modifier les morceaux';

  @override
  String libraryScreenUpdatedPieces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'morceaux',
      one: 'morceau',
    );
    return 'Mis à jour : $count $_temp0.';
  }

  @override
  String get libraryScreenEditPiecesDialogTitle =>
      'Supprimer les données du morceau ?';

  @override
  String libraryScreenEditPiecesBody(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'leurs',
      one: 'ses',
    );
    return 'Le contenu suivant sera supprimé : $names, ainsi que $_temp0 annotations, signets, renvois, libellés et appartenance à une setlist.';
  }

  @override
  String get libraryScreenSplitIntoPiecesDialogTitle => 'Diviser en morceaux ?';

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
    return 'Réduire « $title » aux pages $firstPage–$lastPage supprimera $dropping $_temp0 de son ordre des pages.';
  }

  @override
  String get libraryScreenSplitConfirm => 'Diviser';

  @override
  String get libraryScreenChangePagesTitle => 'Modifier les pages ?';

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
    return 'Modifier « $title » aux pages $firstPage–$lastPage supprimera $dropping $_temp0 de son ordre des pages.';
  }

  @override
  String get libraryScreenChangePagesConfirm => 'Modifier';

  @override
  String get libraryScreenSetlistEmptyAddScores =>
      'Ajoute d\'abord des partitions à cette setlist.';

  @override
  String get libraryScreenNoScoresAvailable =>
      'Aucune des partitions de cette setlist n\'a pu être trouvée.';

  @override
  String libraryScreenSkippedMissingScores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partitions manquantes ignorées',
      one: '$count partition manquante ignorée',
    );
    return '$_temp0.';
  }

  @override
  String get libraryScreenNewSetlist => 'Nouvelle setlist';

  @override
  String get libraryScreenDeleteSetlistTitle => 'Supprimer la setlist ?';

  @override
  String libraryScreenDeleteSetlistBody(String title) {
    return 'Supprimer « $title » ? Les partitions qu\'elle contient ne seront pas affectées.';
  }

  @override
  String libraryScreenDeleteScoreBody(String title) {
    return 'Supprimer « $title » ? Cette action est irréversible.';
  }

  @override
  String libraryScreenDeleteScoreWithPiecesBody(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'morceaux',
      one: 'morceau',
    );
    return 'Supprimer « $title » et ses $count $_temp0 ? Cette action est irréversible.';
  }

  @override
  String get libraryScreenDeleteScoreTitle => 'Supprimer la partition ?';

  @override
  String get libraryScreenTabScores => 'Partitions';

  @override
  String get libraryScreenTabSetlists => 'Setlists';

  @override
  String get libraryScreenSearchHint => 'Rechercher des partitions';

  @override
  String get libraryScreenAddPdf => 'Ajouter un PDF';

  @override
  String libraryScreenSplitSuggestionWithPages(String name, int pages) {
    return '« $name » ($pages pages) ressemble à un recueil de plusieurs morceaux.';
  }

  @override
  String libraryScreenSplitSuggestionGeneric(String name) {
    return '« $name » ressemble à un recueil de plusieurs morceaux.';
  }

  @override
  String get libraryScreenNotNow => 'Pas maintenant';

  @override
  String get libraryScreenSplitEllipsis => 'Diviser…';

  @override
  String libraryScreenFailedToOpen(String error) {
    return 'Impossible d\'ouvrir la bibliothèque : $error';
  }

  @override
  String get libraryScreenNoScoresYet => 'Aucune partition pour l\'instant';

  @override
  String get libraryScreenImportPdfHint => 'Importe un PDF pour commencer.';

  @override
  String get libraryScreenAddSampleScore => 'Ajouter une partition d\'exemple';

  @override
  String libraryScreenNoScoresMatchSearch(String query) {
    return 'Aucune partition ne correspond à « $query ».';
  }

  @override
  String libraryScreenNoScoresMatchFilter(String filter) {
    return 'Aucune partition ne correspond à $filter.';
  }

  @override
  String get libraryScreenClearSearch => 'Effacer la recherche';

  @override
  String get libraryScreenClearFilter => 'Effacer le filtre';

  @override
  String libraryScreenRecencyWithPieces(String when, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'morceaux',
      one: 'morceau',
    );
    return '$when · $count $_temp0';
  }

  @override
  String get libraryScreenPiecesEllipsis => 'Morceaux…';

  @override
  String get libraryScreenEditPiecesMenuItem => 'Modifier les morceaux…';

  @override
  String get libraryScreenOpenFullScore => 'Ouvrir la partition complète';

  @override
  String get libraryScreenRenameEllipsis => 'Renommer…';

  @override
  String get libraryScreenLabelsEllipsis => 'Libellés…';

  @override
  String get libraryScreenSplitIntoPiecesEllipsis => 'Diviser en morceaux…';

  @override
  String get libraryScreenPagesEllipsis => 'Pages…';

  @override
  String get libraryScreenReplacePdfEllipsis => 'Remplacer le PDF…';

  @override
  String get libraryScreenDeleteEllipsis => 'Supprimer…';

  @override
  String libraryScreenAddedRelative(String when) {
    return 'Ajouté $when';
  }

  @override
  String libraryScreenOpenedRelative(String when) {
    return 'Ouvert $when';
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
  String get libraryScreenNoSetlistsYet => 'Aucune setlist pour l\'instant';

  @override
  String get libraryScreenSetlistsEmptyHint =>
      'Regroupe des partitions pour un enchaînement continu, sans avoir à rouvrir chaque morceau.';

  @override
  String libraryScreenSetlistScoreCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'partitions',
      one: 'partition',
    );
    return '$count $_temp0';
  }

  @override
  String get libraryScreenSetlistCountEmpty => 'Vide';

  @override
  String libraryScreenSetlistScoreCountOpened(
    String scoreCount,
    String opened,
  ) {
    return '$scoreCount · $opened';
  }

  @override
  String get metronomeSheetTitle => 'Métronome';

  @override
  String get metronomeSheetTempo => 'Tempo';

  @override
  String get metronomeSheetMeter => 'Mesure';

  @override
  String get metronomeSheetMeterHint =>
      'La façon dont les temps sont regroupés dans chaque mesure';

  @override
  String get metronomeSheetEqual => 'Égal';

  @override
  String get metronomeSheetMute => 'Muet';

  @override
  String get metronomeSheetShowBeats => 'Afficher les temps';

  @override
  String get metronomeSheetShowBeatsHint =>
      'Faire clignoter le temps sur la partition pendant la lecture';

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
    return 'Volume : $percent%';
  }

  @override
  String get metronomeSheetStop => 'Arrêter';

  @override
  String get metronomeSheetStart => 'Démarrer';

  @override
  String get metronomeSheetEnterNumber => 'Saisis un nombre';

  @override
  String get metronomeSheetTempoDialogTitle => 'Définir le tempo';

  @override
  String get pageExtentScreenTitle => 'Pages';

  @override
  String pageExtentScreenFirstPage(int page) {
    return 'Première page : $page';
  }

  @override
  String pageExtentScreenLastPage(int page) {
    return 'Dernière page : $page';
  }

  @override
  String get pageExtentScreenNoPages => 'Aucune page';

  @override
  String get pageExtentScreenBadgeOnly => 'Seule';

  @override
  String get pageExtentScreenBadgeFirst => 'Première';

  @override
  String get pageExtentScreenBadgeLast => 'Dernière';

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
      'Touche une page ci-dessous pour définir la limite sélectionnée.';

  @override
  String get pageNavBarPreviousPageTooltip => 'Page précédente';

  @override
  String get pageNavBarNextPageTooltip => 'Page suivante';

  @override
  String pageNavBarJumpedSnackbar(int page, int count) {
    return 'Sauté à la page $page sur $count';
  }

  @override
  String get pageNavBarGoToPageTitle => 'Aller à la page';

  @override
  String pageNavBarPageFieldLabel(int count) {
    return 'Page (1–$count)';
  }

  @override
  String get piecesScreenEditPieces => 'Modifier les morceaux…';

  @override
  String get piecesScreenNoPieces => 'Aucun morceau';

  @override
  String get piecesScreenRename => 'Renommer…';

  @override
  String get piecesScreenLabels => 'Libellés…';

  @override
  String get piecesScreenSplitIntoPieces => 'Diviser en morceaux…';

  @override
  String get piecesScreenPages => 'Pages…';

  @override
  String get piecesScreenReplacePdf => 'Remplacer le PDF…';

  @override
  String get piecesScreenDelete => 'Supprimer…';

  @override
  String piecesScreenAdded(String when) {
    return 'Ajouté $when';
  }

  @override
  String piecesScreenOpened(String when) {
    return 'Ouvert $when';
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
      other: 'morceaux',
      one: 'morceau',
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
  String get piecesScreenOpenFullScore => 'Ouvrir la partition complète';

  @override
  String get setlistEditorImportFirst => 'Importe d\'abord une partition.';

  @override
  String get setlistEditorDefaultTitle => 'Nouvelle setlist';

  @override
  String get setlistEditorAppBarTitle => 'Modifier la setlist';

  @override
  String get setlistEditorAddScores => 'Ajouter des partitions';

  @override
  String get setlistEditorTitleFieldLabel => 'Titre';

  @override
  String get setlistEditorEmpty =>
      'Aucune partition pour l\'instant. Touche Ajouter des partitions pour créer la setlist.';

  @override
  String get setlistEditorMissingScore => 'Partition manquante';

  @override
  String get setlistEditorRemovedFromLibrary => 'Retiré de la bibliothèque';

  @override
  String get setlistEditorRemoveTooltip => 'Retirer';

  @override
  String setlistEditorAddCount(int count) {
    return 'Ajouter ($count)';
  }

  @override
  String setlistEditorPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'morceaux',
      one: 'morceau',
    );
    return '$count $_temp0';
  }

  @override
  String get setlistEditorPiecesTooltip => 'Voir les morceaux';

  @override
  String get splitScoreScreenRenameTitle => 'Renommer';

  @override
  String get splitScoreScreenTitle => 'Diviser en morceaux';

  @override
  String get splitScoreScreenClearMarks => 'Effacer les repères';

  @override
  String get splitScoreScreenNoPages => 'Aucune page';

  @override
  String splitScoreScreenPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count morceaux',
      one: '1 morceau',
      zero: 'Aucun morceau pour l\'instant',
    );
    return '$_temp0';
  }

  @override
  String get splitScoreScreenHint =>
      'Touche une page pour marquer le début d\'un nouveau morceau. Fais un appui long sur une page marquée pour la renommer.';

  @override
  String splitScoreScreenFrontMatterPage(int page) {
    return 'La page $page fait partie des pages préliminaires et n\'appartiendra à aucun morceau.';
  }

  @override
  String splitScoreScreenFrontMatterPages(int first, int last) {
    return 'Les pages $first–$last font partie des pages préliminaires et n\'appartiendront à aucun morceau.';
  }

  @override
  String splitScoreScreenUseContents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entrées',
      one: 'entrée',
    );
    return 'Utiliser la table des matières ($count $_temp0)';
  }

  @override
  String get libraryScreenNoPdfFiles => 'Aucun fichier PDF trouvé.';

  @override
  String libraryScreenImportedScores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'partitions importées',
      one: 'partition importée',
    );
    return '$count $_temp0';
  }

  @override
  String get libraryScreenCreateBackupTitle => 'Créer une sauvegarde ?';

  @override
  String get libraryScreenCreateBackupBody =>
      'Cela enregistre une copie de toute ta bibliothèque — partitions, libellés, setlists et réglages — sous forme de fichier zip que tu peux partager ou conserver en lieu sûr.';

  @override
  String get libraryScreenCreateBackupConfirm => 'Créer la sauvegarde';

  @override
  String get libraryScreenCreatingBackup => 'Création de la sauvegarde…';

  @override
  String get libraryScreenBackupShareSubject => 'Sauvegarde StageScore';

  @override
  String libraryScreenBackupSaved(String path) {
    return 'Sauvegarde enregistrée dans $path';
  }

  @override
  String get libraryScreenBackupReady =>
      'Sauvegarde prête — fenêtre de partage ouverte';

  @override
  String libraryScreenBackupFailed(String error) {
    return 'Impossible de créer la sauvegarde : $error';
  }

  @override
  String get libraryScreenRestoreBackupTitle => 'Restaurer la sauvegarde ?';

  @override
  String get libraryScreenRestoreBackupBody =>
      'Cela remplace toute ta bibliothèque — partitions, libellés, setlists et réglages — par le contenu de la sauvegarde. Cette action est irréversible.';

  @override
  String get libraryScreenReplaceAll => 'Tout remplacer';

  @override
  String get libraryScreenRestoringBackup => 'Restauration de la sauvegarde…';

  @override
  String get libraryScreenLibraryRestored => 'Bibliothèque restaurée';

  @override
  String libraryScreenRestoreFailed(String error) {
    return 'Impossible de restaurer la sauvegarde : $error';
  }

  @override
  String libraryScreenPercentValue(int percent) {
    return '$percent%';
  }

  @override
  String get libraryScreenUntagged => 'Sans libellé';

  @override
  String get libraryScreenThisFilter => 'ce filtre';

  @override
  String get libraryScreenAndConjunction => 'et';

  @override
  String get libraryScreenAllOf => 'Tous les';

  @override
  String libraryScreenRemoveFilterChip(String label) {
    return 'Retirer le filtre $label';
  }

  @override
  String get libraryScreenRenameScoreTitle => 'Renommer la partition';

  @override
  String get libraryScreenReplacePdfTitle => 'Remplacer le PDF ?';

  @override
  String libraryScreenReplacePdfBodyShared(
    int sharing,
    String title,
    int others,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: 'autres morceaux',
      one: 'autre morceau',
    );
    return 'Ce PDF est partagé par $sharing morceaux, dont « $title ». Le remplacer changera aussi les $others $_temp0.';
  }

  @override
  String libraryScreenReplacePdfBodySingle(String title) {
    return 'Remplacer le PDF derrière « $title » ? Tu peux conserver ou réinitialiser ses annotations ci-dessous.';
  }

  @override
  String get libraryScreenKeepOverlays => 'Conserver les annotations';

  @override
  String get libraryScreenResetOverlays => 'Réinitialiser les annotations';

  @override
  String get libraryScreenOverlaysReset => 'Annotations réinitialisées.';

  @override
  String get libraryScreenOverlaysKept => 'Annotations conservées.';

  @override
  String libraryScreenPdfReplaced(String overlayNote) {
    return 'PDF remplacé. $overlayNote';
  }

  @override
  String libraryScreenPdfReplacedShortened(String overlayNote, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entrées de page ont été supprimées',
      one: 'entrée de page a été supprimée',
    );
    return 'PDF remplacé. $overlayNote Le nouveau fichier est plus court : $count $_temp0.';
  }

  @override
  String libraryScreenReplaceFailed(String error) {
    return 'Impossible de remplacer le PDF : $error';
  }

  @override
  String continuousPageOrderViewOpenFailed(String error) {
    return 'Impossible d\'ouvrir le PDF : $error';
  }

  @override
  String get performancePageSlotBlank => 'Vierge';

  @override
  String performancePageSlotMissingPage(int page) {
    return 'Page $page manquante';
  }

  @override
  String singlePageSliderOpenFailed(String error) {
    return 'Impossible d\'ouvrir le PDF : $error';
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
    return 'Impossible d\'ouvrir le lien : $url';
  }

  @override
  String aboutSheetTitle(String productName) {
    return 'À propos de $productName';
  }

  @override
  String get aboutSheetWebsiteLabel => 'Site web';

  @override
  String get aboutSheetPrivacyLabel => 'Confidentialité';

  @override
  String get aboutSheetSupportLabel => 'Assistance';

  @override
  String get bookmarksSheetAddTitle => 'Ajouter un signet';

  @override
  String bookmarksSheetPageLabel(int page) {
    return 'Page $page';
  }

  @override
  String get bookmarksSheetRenameTitle => 'Renommer le signet';

  @override
  String get bookmarksSheetTitle => 'Signets';

  @override
  String get bookmarksSheetEmpty => 'Aucun signet pour l\'instant';

  @override
  String get displaySheetBorderColorTitle => 'Couleur de la bordure';

  @override
  String displaySheetHue(int value) {
    return 'Teinte : $value';
  }

  @override
  String displaySheetSaturation(int value) {
    return 'Saturation : $value';
  }

  @override
  String displaySheetColorValue(int value) {
    return 'Valeur : $value';
  }

  @override
  String get displaySheetTitle => 'Affichage';

  @override
  String get displaySheetPerformanceMode => 'Mode performance';

  @override
  String get displaySheetPageBorder => 'Bordure de page';

  @override
  String displaySheetThickness(String value) {
    return 'Épaisseur : $value';
  }

  @override
  String get displaySheetColorLabel => 'Couleur';

  @override
  String get displaySheetCustomChip => 'Personnalisée';

  @override
  String get displaySheetShowStatusBar => 'Afficher la barre d\'état';

  @override
  String get displaySheetShowStatusBarHint =>
      'Garder l\'heure et la batterie visibles pendant que tu joues';

  @override
  String get displaySheetAvoidNotches => 'Éviter les encoches';

  @override
  String get displaySheetAvoidNotchesHint =>
      'Garder la page dégagée de l\'encoche caméra et des coins arrondis';

  @override
  String get jumpLinkEditSheetAddTitle => 'Ajouter un renvoi';

  @override
  String get jumpLinkEditSheetEditTitle => 'Modifier le renvoi';

  @override
  String jumpLinkEditSheetOriginLabel(int page) {
    return 'Depuis la page $page';
  }

  @override
  String jumpLinkEditSheetDestinationLabel(int page, int pageCount) {
    return 'Vers la page $page sur $pageCount';
  }

  @override
  String get jumpLinkEditSheetColorLabel => 'Couleur';

  @override
  String get jumpLinkEditSheetSizeLabel => 'Taille';

  @override
  String get jumpLinksSheetDragHint =>
      'Ajouté. Fais glisser un renvoi dans la liste pour le réordonner.';

  @override
  String get jumpLinksSheetTitle => 'Renvois';

  @override
  String get jumpLinksSheetEmpty => 'Aucun renvoi pour l\'instant';

  @override
  String jumpLinksSheetRowTitle(int from, int to) {
    return 'Page $from → $to';
  }

  @override
  String get jumpLinksSheetRowSubtitle => 'Touche pour aller à ce renvoi';

  @override
  String labelSheetsTitle(String title) {
    return 'Libellés de $title';
  }

  @override
  String get labelSheetsManage => 'Gérer';

  @override
  String get labelSheetsCreateLabel => 'Créer un libellé';

  @override
  String get labelSheetsNewLabel => 'Nouveau libellé';

  @override
  String get labelSheetsManageTitle => 'Gérer les libellés';

  @override
  String get labelSheetsNoLabelsYet => 'Aucun libellé pour l\'instant';

  @override
  String labelSheetsUsageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'partitions',
      one: 'partition',
    );
    return 'Utilisé par $count $_temp0';
  }

  @override
  String get labelSheetsDeleteTitle => 'Supprimer le libellé ?';

  @override
  String labelSheetsDeleteConfirm(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String labelSheetsDeleteConfirmWithUsage(String name, int usage) {
    String _temp0 = intl.Intl.pluralLogic(
      usage,
      locale: localeName,
      other: 'partitions',
      one: 'partition',
    );
    return '« $name » est utilisé par $usage $_temp0. Le supprimer quand même ?';
  }

  @override
  String get labelSheetsRenameLabelTitle => 'Renommer le libellé';

  @override
  String get labelSheetsNameHint => 'Nom du libellé';

  @override
  String get libraryFilterSheetTitle => 'Filtrer';

  @override
  String get libraryFilterSheetModeAny => 'Au moins un';

  @override
  String get libraryFilterSheetModeAll => 'Tous';

  @override
  String get libraryFilterSheetModeUntagged => 'Sans libellé';

  @override
  String get libraryFilterSheetUntaggedHint => 'Partitions sans libellé';

  @override
  String get libraryFilterSheetEmptyLabels =>
      'Aucun libellé disponible pour filtrer';

  @override
  String get measureMapMeasureCountTitle => 'Combien de MeasureBoxes ?';

  @override
  String get measureMapMeasureCountLabel => 'MeasureBoxes';

  @override
  String get measureMapGoToTitle => 'Aller à la mesure';

  @override
  String get measureMapGoToLabel => 'Numéro de mesure';

  @override
  String measureMapGoToMissing(int number) {
    return 'La mesure $number n’est pas encore cartographiée';
  }

  @override
  String get measureMapMetaTitle => 'Tempo et signature';

  @override
  String get measureMapTimeSignatureLabel => 'Signature rythmique';

  @override
  String get measureMapTempoLabel => 'Tempo';

  @override
  String get measureMapMetaScopeTitle => 'Appliquer à';

  @override
  String get measureMapScopeThisMeasure => 'Cette mesure seulement';

  @override
  String get measureMapScopeThisSystem => 'Ce system';

  @override
  String get measureMapScopeThisPage => 'Cette page';

  @override
  String get measureMapScopeRestOfScore => 'Reste du Score';

  @override
  String get measureMapScopeNextN => 'Next N…';

  @override
  String get measureMapMetaNextNLabel => 'Nombre de mesures';

  @override
  String get measureMapClearTitle => 'Effacer le MeasureMap ?';

  @override
  String get measureMapClearBody =>
      'Supprime tous les SystemBox et MeasureBox de ce Score. Irréversible.';

  @override
  String get measureMapClearConfirm => 'Effacer';

  @override
  String get measureMapDeleteSystemTitle => 'Supprimer le system ?';

  @override
  String get measureMapDeleteSystemBody =>
      'Supprime ce SystemBox et tous ses MeasureBoxes.';

  @override
  String get measureMapCopyFromPageTitle =>
      'Copier la mise en page depuis la page';

  @override
  String get measureMapCopyFromPageLabel => 'Page source';

  @override
  String get measureMapCopyPrevious => 'Copier la page précédente';

  @override
  String get measureMapEmptyHint =>
      'Dessinez un system — l’app demandera combien de mesures';

  @override
  String get measureMapDone => 'Terminé';

  @override
  String get measureMapEditBeats => 'Edit beats';

  @override
  String get measureMapSetMeasureCount => 'Définir le nombre de mesures…';

  @override
  String get measureMapDeleteSystem => 'Supprimer le system';

  @override
  String get measureMapDeleteMeasure => 'Supprimer la mesure';

  @override
  String get measureMapEditMeta => 'Tempo et signature…';

  @override
  String get measureMapStartsAtBeat => 'Starts at beat';

  @override
  String get measureMapStartsAtBeatHint =>
      '1 = full measure; higher skips early beats (pickup on a wide box)';

  @override
  String get measureMapClearAll => 'Effacer le MeasureMap…';
}
