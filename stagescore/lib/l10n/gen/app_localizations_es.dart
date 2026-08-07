// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionDone => 'Listo';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionOk => 'Aceptar';

  @override
  String get actionClear => 'Borrar';

  @override
  String get actionApply => 'Aplicar';

  @override
  String get actionAdd => 'Agregar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionRename => 'Renombrar';

  @override
  String get actionBack => 'Atrás';

  @override
  String get actionMore => 'Más';

  @override
  String get actionGo => 'Ir';

  @override
  String get actionUndo => 'Deshacer';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionReset => 'Restablecer';

  @override
  String get commonOr => 'o';

  @override
  String get commonTitleLabel => 'Título';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Oscuro';

  @override
  String get pdfLayoutModeAuto => 'Automático';

  @override
  String get pdfLayoutModeSingle => 'Una página';

  @override
  String get pdfLayoutModeTwoPages => 'Dos páginas';

  @override
  String get pdfLayoutModeScroll => 'Desplazamiento';

  @override
  String get pdfLayoutModeScrollSideways => 'Desplazamiento (lateral)';

  @override
  String get pdfLayoutModeHalfPageTopBottom => 'Una página + vistazo';

  @override
  String get pdfLayoutModeHalfPageLeftRight => 'Una página + vistazo lateral';

  @override
  String get pageColorFilterOff => 'Desactivado';

  @override
  String get pageColorFilterSepia => 'Sepia';

  @override
  String get pageColorFilterGreen => 'Verde';

  @override
  String get pageColorFilterInvert => 'Invertir';

  @override
  String get pageScaleScopeFixed => 'Fija';

  @override
  String get pageScaleScopePerScore => 'Por partitura';

  @override
  String get pageScaleScopePerPage => 'Por página';

  @override
  String get stagePresetSetUpToPlay => 'Preparar para tocar';

  @override
  String get stagePresetSetUpToPractise => 'Preparar para practicar';

  @override
  String get stagePresetChromeHidden => 'controles ocultos';

  @override
  String get stagePresetChromeShown => 'controles visibles';

  @override
  String get stagePresetStatusBarShown => 'barra de estado visible';

  @override
  String get stagePresetStatusBarHidden => 'barra de estado oculta';

  @override
  String get stagePresetScaleKept => 'escala fija';

  @override
  String get stagePresetPinchFree => 'sin pellizco';

  @override
  String get relativeDayToday => 'hoy';

  @override
  String get relativeDayYesterday => 'ayer';

  @override
  String relativeDayDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'días',
      one: 'día',
    );
    return 'hace $days $_temp0';
  }

  @override
  String pageOrderEditorEntryBlank(int index) {
    return '$index. En blanco';
  }

  @override
  String pageOrderEditorEntryPdfPage(int index, int sourcePage) {
    return '$index. Página PDF $sourcePage';
  }

  @override
  String get pageOrderEditorResetTitle => '¿Restablecer al original?';

  @override
  String get pageOrderEditorResetBody =>
      '¿Restaurar el orden original de páginas del PDF y quitar las páginas en blanco y duplicadas?';

  @override
  String get pageOrderEditorReset => 'Restablecer';

  @override
  String get pageOrderEditorAppBarTitle => 'Orden de páginas';

  @override
  String get pageOrderEditorNoPages => 'Sin páginas';

  @override
  String get pageOrderEditorDuplicate => 'Duplicar';

  @override
  String get pageOrderEditorInsertBlank => 'Insertar página en blanco';

  @override
  String get pageOrderEditorRemove => 'Quitar';

  @override
  String get librarySortTitle => 'Título';

  @override
  String get librarySortCreated => 'Creación';

  @override
  String get librarySortLastViewed => 'Visto por última vez';

  @override
  String scoreOriginPage(int page) {
    return 'Página $page';
  }

  @override
  String scoreOriginPages(int first, int last) {
    return 'Páginas $first–$last';
  }

  @override
  String scoreOriginPagesOfBook(String pages, String name) {
    return '$pages de $name';
  }

  @override
  String libraryVisibilityInBook(String title) {
    return 'en $title';
  }

  @override
  String get libraryVisibilityInBookFallback => 'en el libro';

  @override
  String get libraryBackupFileNotFound =>
      'No se encontró el archivo de copia de seguridad.';

  @override
  String get libraryBackupFailedGeneric =>
      'Error al crear la copia de seguridad.';

  @override
  String libraryBackupCreateFailed(String error) {
    return 'No se pudo crear la copia de seguridad: $error';
  }

  @override
  String libraryBackupRestoreFailed(String error) {
    return 'No se pudo restaurar la copia de seguridad: $error';
  }

  @override
  String get libraryBackupMissingMarker =>
      'No es una copia de seguridad de StageScore (falta el marcador).';

  @override
  String get libraryBackupUnknownFormat =>
      'No es una copia de seguridad de StageScore (formato desconocido).';

  @override
  String get libraryBackupUnsupportedVersion =>
      'Versión de copia de seguridad de StageScore no compatible.';

  @override
  String get libraryBackupCorruptMarker =>
      'No es una copia de seguridad de StageScore (marcador dañado).';

  @override
  String get gestureMapLongPress => 'mantener pulsado';

  @override
  String get gestureMapTapTopEdge => 'tocar el borde superior';

  @override
  String get gestureMapTapBottomEdge => 'tocar el borde inferior';

  @override
  String get gestureMapEmptyHint =>
      'Asigna un gesto a Mostrar menú / controles para poder mostrarlo.';

  @override
  String gestureMapRevealHint(String joined) {
    return 'Oculta la barra de herramientas y la barra de páginas mientras tocas. Para volver a mostrarlas, $joined.';
  }

  @override
  String get layoutNavigationPedalOrPageBar => 'el pedal o la barra de páginas';

  @override
  String get layoutNavigationTapLeftRight => 'tocar izquierda / derecha';

  @override
  String get layoutNavigationTapTopBottom => 'tocar arriba / abajo';

  @override
  String get layoutNavigationTapAnywhere => 'tocar en cualquier parte';

  @override
  String get layoutNavigationTapAnywhereBack =>
      'tocar en cualquier parte para volver';

  @override
  String get layoutNavigationSwipe => 'deslizar';

  @override
  String get layoutNavigationSwipeSideways => 'deslizar lateralmente';

  @override
  String get layoutNavigationSwipeUpDown => 'deslizar arriba / abajo';

  @override
  String get scoreMenuSheetTitle => 'Menú';

  @override
  String get appearanceSheetTitle => 'Apariencia';

  @override
  String get appearanceSheetMode => 'Modo';

  @override
  String get appearanceSheetThemeColor => 'Color del tema';

  @override
  String get appearanceSheetCustomChip => 'Personalizado';

  @override
  String get appearanceSheetCustomColorDialog => 'Color personalizado';

  @override
  String get appearanceSheetHue => 'Tono';

  @override
  String get appearanceSheetSat => 'Sat';

  @override
  String get appearanceSheetVal => 'Val';

  @override
  String get scoreMenuGoTo => 'Ir a';

  @override
  String get scoreMenuBookmarks => 'Marcadores';

  @override
  String get scoreMenuJumpLinks => 'Enlaces de salto';

  @override
  String get scoreMenuPageOrder => 'Orden de páginas…';

  @override
  String get scoreMenuGoToMeasure => 'Ir al compás…';

  @override
  String get scoreMenuMeasureMap => 'Measure map…';

  @override
  String get scoreMenuFormMap => 'Form map…';

  @override
  String get scoreMenuFormMapNeedsMeasureMap => 'Map measures first';

  @override
  String get scoreMenuReflowSpike => 'Reflow (spike)';

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
  String get scoreMenuMarks => 'Marcas';

  @override
  String get scoreMenuHideAnnotations => 'Ocultar anotaciones';

  @override
  String get scoreMenuShowAnnotations => 'Mostrar anotaciones';

  @override
  String get scoreMenuExporting => 'Exportando…';

  @override
  String get scoreMenuExportAnnotated => 'Exportar PDF con anotaciones';

  @override
  String get scoreMenuView => 'Vista';

  @override
  String get scoreMenuLayout => 'Diseño';

  @override
  String get scoreMenuDisplay => 'Pantalla…';

  @override
  String get scoreMenuColorFilter => 'Filtro de color…';

  @override
  String get scoreMenuPageScale => 'Escala de página…';

  @override
  String get scoreMenuLocked => 'Bloqueado';

  @override
  String get scoreMenuPlaying => 'Reproduciendo';

  @override
  String get scoreMenuMetronomeRunning => 'Metrónomo (en marcha)…';

  @override
  String get scoreMenuMetronome => 'Metrónomo…';

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
      'Línea sobre la partitura al reproducir';

  @override
  String get playbackSettingsPlayheadColor => 'Color';

  @override
  String playbackSettingsPlayheadSize(String value) {
    return 'Grosor $value';
  }

  @override
  String playbackSettingsPlayheadOpacity(int percent) {
    return 'Opacidad $percent%';
  }

  @override
  String playbackSettingsPlayheadHeight(int percent) {
    return 'Altura $percent% del compás';
  }

  @override
  String get scoreMenuPlaybackMapFirst => 'Map measures first';

  @override
  String get scoreMenuPageTurnSettings => 'Ajustes de cambio de página';

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
  String get languageSheetTitle => 'Idioma';

  @override
  String get languageSheetSystem => 'Sistema';

  @override
  String get languageSheetSystemSubtitle => 'Usar el idioma del dispositivo';

  @override
  String get stampSheetTitle => 'Sellos';

  @override
  String get stampBox => 'Cuadro';

  @override
  String get stampCircle => 'Círculo';

  @override
  String get stampArrow => 'Flecha';

  @override
  String get stampText => 'Texto';

  @override
  String get pageScaleSheetTitle => 'Escala de página';

  @override
  String get pageScaleSheetExplainer =>
      'Define el tamaño con el que se dibuja la partitura, y se recuerda entre sesiones. Pellizcar para hacer zoom cambia la vista solo por ahora; esto la cambia de forma permanente.';

  @override
  String pageScaleSheetCurrent(String value) {
    return 'En esta página ahora mismo: $value×';
  }

  @override
  String get pageScaleSheetAppliesTo => 'Se aplica a';

  @override
  String get pageScaleSheetScale => 'Escala';

  @override
  String pageScaleSheetScaleValue(String value) {
    return '$value×';
  }

  @override
  String get pageScaleSheetKeepScale => 'Mantener esta escala';

  @override
  String get pageScaleSheetKeepScaleSubtitle =>
      'El pellizco está desactivado, así que un toque accidental a mitad de la pieza no puede mover la partitura';

  @override
  String get pageScaleSheetHintFixed =>
      'Todas las partituras, salvo que alguna tenga su propia escala';

  @override
  String get pageScaleSheetHintPerScore =>
      'Solo esta partitura, en todas sus páginas';

  @override
  String get pageScaleSheetHintPerPage =>
      'Solo esta página: una página densa puede ser más grande sin cambiar el resto';

  @override
  String get layoutSettingsSheetTitle => 'Diseño';

  @override
  String get layoutSettingsSheetPageTurnSettings =>
      'Ajustes de cambio de página';

  @override
  String get layoutSettingsSheetPageTurnSettingsSubtitle =>
      'Zonas táctiles, deslizar, pedal, animación';

  @override
  String get layoutSettingsSheetFallsBack =>
      'Una página en esta pantalla: gira el dispositivo para ver dos páginas';

  @override
  String layoutSettingsSheetNow(String mode) {
    return 'Ahora: $mode';
  }

  @override
  String get layoutSettingsSheetFitsScreen => 'se ajusta a esta pantalla';

  @override
  String get pageTurnSettingsSheetGestureWarning =>
      'Mantén al menos un gesto asignado a Mostrar menú / controles.';

  @override
  String get pageTurnSettingsSheetTitle => 'Cambio de página';

  @override
  String get pageTurnSettingsSheetTapZones => 'Zonas táctiles';

  @override
  String pageTurnSettingsSheetTapZonesHint(
    String layoutMode,
    String navigationHint,
  ) {
    return 'En $layoutMode: $navigationHint.';
  }

  @override
  String get pageTurnSettingsSheetSwipe => 'Deslizar';

  @override
  String get pageTurnSettingsSheetMatchLayout => 'Según el diseño';

  @override
  String get pageTurnSettingsSheetMatchLayoutSubtitle =>
      'Desliza en la misma dirección en que se mueven las páginas';

  @override
  String get pageTurnSettingsSheetSwipeLeftNext =>
      'Deslizar a la izquierda → siguiente';

  @override
  String get pageTurnSettingsSheetSwipeRightPrevious =>
      'Deslizar a la derecha → anterior';

  @override
  String get pageTurnSettingsSheetSwipeUpNext =>
      'Deslizar hacia arriba → siguiente';

  @override
  String get pageTurnSettingsSheetSwipeDownPrevious =>
      'Deslizar hacia abajo → anterior';

  @override
  String get pageTurnSettingsSheetReverseDirection =>
      'Invertir la dirección del cambio de página';

  @override
  String get pageTurnSettingsSheetReverseDirectionSubtitle =>
      'Para libros que se pasan al revés';

  @override
  String get pageTurnSettingsSheetTurnAmount => 'Cantidad de avance';

  @override
  String get pageTurnSettingsSheetTurnAmountHintTwoPage =>
      'Con Media, avanza una página del conjunto en lugar de las dos a la vez.';

  @override
  String get pageTurnSettingsSheetTurnAmountHintDefault =>
      'Con Media, avanza ~½ pantalla en lugar de una completa.';

  @override
  String get pageTurnSettingsSheetAnimation => 'Animación';

  @override
  String get pageTurnSettingsSheetPageTurnDelay =>
      'Retraso al cambiar de página';

  @override
  String get pageTurnSettingsSheetApplyTo => 'Aplicar a';

  @override
  String get pageTurnSettingsSheetGestures => 'Gestos';

  @override
  String get pageTurnSettingsSheetGesturesHint =>
      'Los toques en el borde son franjas finas arriba y abajo, distintas de las zonas de cambio de página Superior/Inferior. Al menos uno debe ser Mostrar menú / controles; ese gesto también muestra la barra de herramientas en el modo actuación. Al modo Dibujar se entra desde la barra de herramientas, nunca desde un gesto.';

  @override
  String get pageTurnSettingsSheetLongPress => 'Mantener pulsado';

  @override
  String get pageTurnSettingsSheetTopEdge => 'Borde superior';

  @override
  String get pageTurnSettingsSheetBottomEdge => 'Borde inferior';

  @override
  String get pageTurnSettingsSheetPedalKeyboard => 'Pedal / teclado';

  @override
  String get pageTurnSettingsSheetPedalKeyboardHint =>
      'Se admiten pedales Bluetooth que envían teclas de teclado:\nAnterior — RePág, ←, ↑, Espacio\nSiguiente — AvPág, →, ↓, Intro';

  @override
  String get pageTurnAnimationOff => 'Desactivada';

  @override
  String get pageTurnAnimationFast => 'Rápida';

  @override
  String get pageTurnAnimationNormal => 'Normal';

  @override
  String get pageTurnAnimationSlow => 'Lenta';

  @override
  String get pageTurnDelayOff => 'Desactivado';

  @override
  String get pageTurnDelay300ms => '0,3 s';

  @override
  String get pageTurnDelay500ms => '0,5 s';

  @override
  String get pageTurnDelay1000ms => '1,0 s';

  @override
  String get pageTurnDelayScopeAll => 'Todo';

  @override
  String get pageTurnDelayScopePedalOnly => 'Solo pedal y teclado';

  @override
  String get pageTurnTapModeMatchLayout => 'Según el diseño';

  @override
  String get pageTurnTapModeLeftRight => 'Izquierda / derecha';

  @override
  String get pageTurnTapModeTopBottom => 'Arriba / abajo';

  @override
  String get pageTurnTapModePrevious => 'Cualquier parte → anterior';

  @override
  String get pageTurnTapModeNext => 'Cualquier parte → siguiente';

  @override
  String get pageTurnTapModeDisabled => 'Desactivado';

  @override
  String get turnAmountFull => 'Página completa';

  @override
  String get turnAmountHalf => 'Media página';

  @override
  String get gestureMapActionShowChrome => 'Mostrar menú / controles';

  @override
  String get gestureMapActionDisabled => 'Desactivado';

  @override
  String get drawToolbarColorLabel => 'Color';

  @override
  String get drawToolbarSizeLabel => 'Tamaño';

  @override
  String get drawToolbarUndo => 'Deshacer';

  @override
  String get drawToolbarRedo => 'Rehacer';

  @override
  String get drawToolbarDelete => 'Eliminar';

  @override
  String get drawToolbarStamp => 'Sello';

  @override
  String get drawToolbarPlace => 'Colocar';

  @override
  String get drawToolbarMore => 'Más';

  @override
  String get drawToolbarTextStampTitle => 'Sello de texto';

  @override
  String get drawToolbarTextStampHint => 'Texto breve';

  @override
  String get drawToolbarDrawOptionsTitle => 'Opciones de dibujo';

  @override
  String get drawToolbarTool => 'Herramienta';

  @override
  String get drawToolbarWidth => 'Grosor';

  @override
  String get drawToolbarStraightLine => 'Línea recta';

  @override
  String get drawToolPen => 'Bolígrafo';

  @override
  String get drawToolMarker => 'Rotulador';

  @override
  String get drawToolEraser => 'Borrador';

  @override
  String get drawToolEyedropper => 'Cuentagotas';

  @override
  String get drawWidthThin => 'Fino';

  @override
  String get drawWidthMedium => 'Medio';

  @override
  String get drawWidthThick => 'Grueso';

  @override
  String get pdfModeScreenTapHint =>
      'Toca la mitad derecha para la página siguiente, la izquierda para la anterior.';

  @override
  String get pdfModeScreenColorFilterTitle => 'Filtro de color';

  @override
  String get scoreMenuQuickBarBookmarks => 'Marcadores';

  @override
  String get scoreMenuQuickBarDraw => 'Dibujar';

  @override
  String get scoreMenuQuickBarExitDraw => 'Salir de Dibujar';

  @override
  String get scoreMenuQuickBarMetronome => 'Metrónomo';

  @override
  String get scoreMenuQuickBarMetronomeRunning => 'Metrónomo (en marcha)';

  @override
  String get pdfModeScreenExporting => 'Exportando PDF…';

  @override
  String get pdfModeScreenExportReady =>
      'Exportación lista: se abrió el panel para compartir';

  @override
  String pdfModeScreenExportRestartHint(String path) {
    return 'Exportado a $path. Reinicia la app por completo (stop + flutter run) para habilitar el panel para compartir.';
  }

  @override
  String pdfModeScreenExportFailed(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String pdfModeScreenPieceIndex(int index) {
    return '$index.';
  }

  @override
  String get pdfModeScreenHidePieceNotes => 'Ocultar notas de la pieza';

  @override
  String get pdfModeScreenShowPieceNotes => 'Mostrar notas de la pieza';

  @override
  String get pdfModeScreenPieceNotes => 'Notas de la pieza';

  @override
  String get libraryScreenSort => 'Ordenar';

  @override
  String get libraryScreenFilter => 'Filtrar';

  @override
  String get libraryScreenManageLabels => 'Administrar etiquetas';

  @override
  String get libraryScreenMore => 'Más';

  @override
  String get libraryScreenAppearance => 'Apariencia…';

  @override
  String get libraryScreenLanguage => 'Idioma…';

  @override
  String get libraryScreenBackup => 'Copia de seguridad…';

  @override
  String get libraryScreenRestore => 'Restaurar…';

  @override
  String libraryScreenAbout(String productName) {
    return 'Acerca de $productName…';
  }

  @override
  String libraryScreenSplitIntoPiecesSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'piezas',
      one: 'pieza',
    );
    return 'Dividido en $count $_temp0';
  }

  @override
  String get libraryScreenStillReadingPdf =>
      'Todavía se está leyendo este PDF: inténtalo de nuevo en un momento.';

  @override
  String get libraryScreenEditPiecesAppBarTitle => 'Editar piezas';

  @override
  String libraryScreenUpdatedPieces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'piezas',
      one: 'pieza',
    );
    return 'Actualizado a $count $_temp0.';
  }

  @override
  String get libraryScreenEditPiecesDialogTitle =>
      '¿Quitar los datos de la pieza?';

  @override
  String libraryScreenEditPiecesBody(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sus',
      one: 'sus',
    );
    return '$names se eliminará(n), junto con $_temp0 anotaciones, marcadores, enlaces de salto, etiquetas y pertenencia a setlists.';
  }

  @override
  String get libraryScreenSplitIntoPiecesDialogTitle => '¿Dividir en piezas?';

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
      other: 'páginas',
      one: 'página',
    );
    return 'Al reducir “$title” a las páginas $firstPage–$lastPage se eliminarán $dropping $_temp0 de su orden de páginas.';
  }

  @override
  String get libraryScreenSplitConfirm => 'Dividir';

  @override
  String get libraryScreenChangePagesTitle => '¿Cambiar páginas?';

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
      other: 'páginas',
      one: 'página',
    );
    return 'Al cambiar “$title” a las páginas $firstPage–$lastPage se eliminarán $dropping $_temp0 de su orden de páginas.';
  }

  @override
  String get libraryScreenChangePagesConfirm => 'Cambiar';

  @override
  String get libraryScreenSetlistEmptyAddScores =>
      'Agrega partituras a este setlist primero.';

  @override
  String get libraryScreenNoScoresAvailable =>
      'No se encontró ninguna de las partituras de este setlist.';

  @override
  String libraryScreenSkippedMissingScores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'partituras faltantes',
      one: 'partitura faltante',
    );
    return 'Se omitieron $count $_temp0.';
  }

  @override
  String get libraryScreenNewSetlist => 'Nuevo setlist';

  @override
  String get libraryScreenDeleteSetlistTitle => '¿Eliminar setlist?';

  @override
  String libraryScreenDeleteSetlistBody(String title) {
    return '¿Eliminar “$title”? Las partituras que contiene no se ven afectadas.';
  }

  @override
  String libraryScreenDeleteScoreBody(String title) {
    return '¿Eliminar “$title”? Esta acción no se puede deshacer.';
  }

  @override
  String libraryScreenDeleteScoreWithPiecesBody(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sus piezas',
      one: 'su pieza',
    );
    return '¿Eliminar “$title” y $count $_temp0? Esta acción no se puede deshacer.';
  }

  @override
  String get libraryScreenDeleteScoreTitle => '¿Eliminar partitura?';

  @override
  String get libraryScreenTabScores => 'Partituras';

  @override
  String get libraryScreenTabSetlists => 'Setlists';

  @override
  String get libraryScreenSearchHint => 'Buscar partituras';

  @override
  String get libraryScreenAddPdf => 'Agregar PDF';

  @override
  String libraryScreenSplitSuggestionWithPages(String name, int pages) {
    return '“$name” ($pages páginas) parece que podría ser varias piezas.';
  }

  @override
  String libraryScreenSplitSuggestionGeneric(String name) {
    return '“$name” parece que podría ser varias piezas.';
  }

  @override
  String get libraryScreenNotNow => 'Ahora no';

  @override
  String get libraryScreenSplitEllipsis => 'Dividir…';

  @override
  String libraryScreenFailedToOpen(String error) {
    return 'No se pudo abrir la biblioteca: $error';
  }

  @override
  String get libraryScreenNoScoresYet => 'Aún no hay partituras';

  @override
  String get libraryScreenImportPdfHint => 'Importa un PDF para empezar.';

  @override
  String get libraryScreenAddSampleScore => 'Agregar partitura de ejemplo';

  @override
  String libraryScreenNoScoresMatchSearch(String query) {
    return 'Ninguna partitura coincide con “$query”.';
  }

  @override
  String libraryScreenNoScoresMatchFilter(String filter) {
    return 'Ninguna partitura coincide con $filter.';
  }

  @override
  String get libraryScreenClearSearch => 'Borrar búsqueda';

  @override
  String get libraryScreenClearFilter => 'Borrar filtro';

  @override
  String libraryScreenRecencyWithPieces(String when, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'piezas',
      one: 'pieza',
    );
    return '$when · $count $_temp0';
  }

  @override
  String get libraryScreenPiecesEllipsis => 'Piezas…';

  @override
  String get libraryScreenEditPiecesMenuItem => 'Editar piezas…';

  @override
  String get libraryScreenOpenFullScore => 'Abrir partitura completa';

  @override
  String get libraryScreenRenameEllipsis => 'Renombrar…';

  @override
  String get libraryScreenLabelsEllipsis => 'Etiquetas…';

  @override
  String get libraryScreenSplitIntoPiecesEllipsis => 'Dividir en piezas…';

  @override
  String get libraryScreenPagesEllipsis => 'Páginas…';

  @override
  String get libraryScreenReplacePdfEllipsis => 'Reemplazar PDF…';

  @override
  String get libraryScreenDeleteEllipsis => 'Eliminar…';

  @override
  String libraryScreenAddedRelative(String when) {
    return 'Agregado $when';
  }

  @override
  String libraryScreenOpenedRelative(String when) {
    return 'Abierto $when';
  }

  @override
  String libraryScreenRecencyWithPages(String when, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: 'páginas',
      one: 'página',
    );
    return '$when · $pages $_temp0';
  }

  @override
  String get libraryScreenNoSetlistsYet => 'Aún no hay setlists';

  @override
  String get libraryScreenSetlistsEmptyHint =>
      'Agrupa partituras para tocarlas seguidas sin tener que abrir cada pieza por separado.';

  @override
  String libraryScreenSetlistScoreCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'partituras',
      one: 'partitura',
    );
    return '$count $_temp0';
  }

  @override
  String get libraryScreenSetlistCountEmpty => 'Vacío';

  @override
  String libraryScreenSetlistScoreCountOpened(
    String scoreCount,
    String opened,
  ) {
    return '$scoreCount · $opened';
  }

  @override
  String get metronomeSheetTitle => 'Metrónomo';

  @override
  String get metronomeSheetTempo => 'Tempo';

  @override
  String get metronomeSheetMeter => 'Compás';

  @override
  String get metronomeSheetMeterHint =>
      'Cómo se agrupan los tiempos en cada compás';

  @override
  String get metronomeSheetEqual => 'Igual';

  @override
  String get metronomeSheetMute => 'Silenciar';

  @override
  String get metronomeSheetShowBeats => 'Mostrar tiempos';

  @override
  String get metronomeSheetShowBeatsHint =>
      'Resalta el tiempo en la partitura mientras suena';

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
    return 'Volumen: $percent%';
  }

  @override
  String get metronomeSheetStop => 'Detener';

  @override
  String get metronomeSheetStart => 'Iniciar';

  @override
  String get metronomeSheetEnterNumber => 'Ingresa un número';

  @override
  String get metronomeSheetTempoDialogTitle => 'Definir tempo';

  @override
  String get pageExtentScreenTitle => 'Páginas';

  @override
  String pageExtentScreenFirstPage(int page) {
    return 'Primera página: $page';
  }

  @override
  String pageExtentScreenLastPage(int page) {
    return 'Última página: $page';
  }

  @override
  String get pageExtentScreenNoPages => 'Sin páginas';

  @override
  String get pageExtentScreenBadgeOnly => 'Única';

  @override
  String get pageExtentScreenBadgeFirst => 'Primera';

  @override
  String get pageExtentScreenBadgeLast => 'Última';

  @override
  String pageExtentScreenSummary(String title, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: 'páginas',
      one: 'página',
    );
    return '$title — $pages $_temp0';
  }

  @override
  String get pageExtentScreenHint =>
      'Toca una página abajo para definir el límite seleccionado.';

  @override
  String get pageNavBarPreviousPageTooltip => 'Página anterior';

  @override
  String get pageNavBarNextPageTooltip => 'Página siguiente';

  @override
  String pageNavBarJumpedSnackbar(int page, int count) {
    return 'Se saltó a la página $page de $count';
  }

  @override
  String get pageNavBarGoToPageTitle => 'Ir a la página';

  @override
  String pageNavBarPageFieldLabel(int count) {
    return 'Página (1–$count)';
  }

  @override
  String get piecesScreenEditPieces => 'Editar piezas…';

  @override
  String get piecesScreenNoPieces => 'Sin piezas';

  @override
  String get piecesScreenRename => 'Renombrar…';

  @override
  String get piecesScreenLabels => 'Etiquetas…';

  @override
  String get piecesScreenSplitIntoPieces => 'Dividir en piezas…';

  @override
  String get piecesScreenPages => 'Páginas…';

  @override
  String get piecesScreenReplacePdf => 'Reemplazar PDF…';

  @override
  String get piecesScreenDelete => 'Eliminar…';

  @override
  String piecesScreenAdded(String when) {
    return 'Agregado $when';
  }

  @override
  String piecesScreenOpened(String when) {
    return 'Abierto $when';
  }

  @override
  String piecesScreenRecencyWithPages(String when, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: 'páginas',
      one: 'página',
    );
    return '$when · $pages $_temp0';
  }

  @override
  String piecesScreenPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'piezas',
      one: 'pieza',
    );
    return '$count $_temp0';
  }

  @override
  String piecesScreenPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'páginas',
      one: 'página',
    );
    return '$count $_temp0';
  }

  @override
  String get piecesScreenOpenFullScore => 'Abrir partitura completa';

  @override
  String get setlistEditorImportFirst => 'Importa una partitura primero.';

  @override
  String get setlistEditorDefaultTitle => 'Nuevo setlist';

  @override
  String get setlistEditorAppBarTitle => 'Editar setlist';

  @override
  String get setlistEditorAddScores => 'Agregar partituras';

  @override
  String get setlistEditorTitleFieldLabel => 'Título';

  @override
  String get setlistEditorEmpty =>
      'Aún no hay partituras. Toca Agregar partituras para armar el setlist.';

  @override
  String get setlistEditorMissingScore => 'Partitura faltante';

  @override
  String get setlistEditorRemovedFromLibrary => 'Se quitó de la biblioteca';

  @override
  String get setlistEditorRemoveTooltip => 'Quitar';

  @override
  String setlistEditorAddCount(int count) {
    return 'Agregar ($count)';
  }

  @override
  String setlistEditorPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'piezas',
      one: 'pieza',
    );
    return '$count $_temp0';
  }

  @override
  String get setlistEditorPiecesTooltip => 'Ver piezas';

  @override
  String get splitScoreScreenRenameTitle => 'Renombrar';

  @override
  String get splitScoreScreenTitle => 'Dividir en piezas';

  @override
  String get splitScoreScreenClearMarks => 'Borrar marcas';

  @override
  String get splitScoreScreenNoPages => 'Sin páginas';

  @override
  String splitScoreScreenPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count piezas',
      one: '1 pieza',
      zero: 'Aún no hay piezas',
    );
    return '$_temp0';
  }

  @override
  String get splitScoreScreenHint =>
      'Toca una página para marcar dónde empieza una nueva pieza. Mantén pulsada una página marcada para renombrarla.';

  @override
  String splitScoreScreenFrontMatterPage(int page) {
    return 'La página $page es material preliminar y no pertenecerá a ninguna pieza.';
  }

  @override
  String splitScoreScreenFrontMatterPages(int first, int last) {
    return 'Las páginas $first–$last son material preliminar y no pertenecerán a ninguna pieza.';
  }

  @override
  String splitScoreScreenUseContents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entradas',
      one: 'entrada',
    );
    return 'Usar tabla de contenido ($count $_temp0)';
  }

  @override
  String get libraryScreenNoPdfFiles => 'No se encontraron archivos PDF.';

  @override
  String libraryScreenImportedScores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'partituras',
      one: 'partitura',
    );
    return 'Se importaron $count $_temp0';
  }

  @override
  String get libraryScreenCreateBackupTitle => '¿Crear copia de seguridad?';

  @override
  String get libraryScreenCreateBackupBody =>
      'Esto guarda una copia de toda tu biblioteca (partituras, etiquetas, setlists y ajustes) como un archivo zip que puedes compartir o guardar en un lugar seguro.';

  @override
  String get libraryScreenCreateBackupConfirm => 'Crear copia de seguridad';

  @override
  String get libraryScreenCreatingBackup => 'Creando copia de seguridad…';

  @override
  String get libraryScreenBackupShareSubject =>
      'Copia de seguridad de StageScore';

  @override
  String libraryScreenBackupSaved(String path) {
    return 'Copia de seguridad guardada en $path';
  }

  @override
  String get libraryScreenBackupReady =>
      'Copia de seguridad lista: se abrió el panel para compartir';

  @override
  String libraryScreenBackupFailed(String error) {
    return 'No se pudo crear la copia de seguridad: $error';
  }

  @override
  String get libraryScreenRestoreBackupTitle =>
      '¿Restaurar copia de seguridad?';

  @override
  String get libraryScreenRestoreBackupBody =>
      'Esto reemplaza toda tu biblioteca (partituras, etiquetas, setlists y ajustes) con el contenido de la copia de seguridad. Esta acción no se puede deshacer.';

  @override
  String get libraryScreenReplaceAll => 'Reemplazar todo';

  @override
  String get libraryScreenRestoringBackup => 'Restaurando copia de seguridad…';

  @override
  String get libraryScreenLibraryRestored => 'Biblioteca restaurada';

  @override
  String libraryScreenRestoreFailed(String error) {
    return 'No se pudo restaurar la copia de seguridad: $error';
  }

  @override
  String libraryScreenPercentValue(int percent) {
    return '$percent%';
  }

  @override
  String get libraryScreenUntagged => 'Sin etiquetas';

  @override
  String get libraryScreenThisFilter => 'este filtro';

  @override
  String get libraryScreenAndConjunction => 'y';

  @override
  String get libraryScreenAllOf => 'Todas de';

  @override
  String libraryScreenRemoveFilterChip(String label) {
    return 'Quitar filtro $label';
  }

  @override
  String get libraryScreenRenameScoreTitle => 'Renombrar partitura';

  @override
  String get libraryScreenReplacePdfTitle => '¿Reemplazar PDF?';

  @override
  String libraryScreenReplacePdfBodyShared(
    int sharing,
    String title,
    int others,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: 'otras piezas',
      one: 'otra pieza',
    );
    return 'Este PDF es compartido por $sharing piezas, incluida “$title”. Reemplazarlo también lo cambiará para $others $_temp0.';
  }

  @override
  String libraryScreenReplacePdfBodySingle(String title) {
    return '¿Reemplazar el PDF detrás de “$title”? Puedes conservar o restablecer sus anotaciones abajo.';
  }

  @override
  String get libraryScreenKeepOverlays => 'Conservar anotaciones';

  @override
  String get libraryScreenResetOverlays => 'Restablecer anotaciones';

  @override
  String get libraryScreenOverlaysReset => 'Anotaciones restablecidas.';

  @override
  String get libraryScreenOverlaysKept => 'Anotaciones conservadas.';

  @override
  String libraryScreenPdfReplaced(String overlayNote) {
    return 'PDF reemplazado. $overlayNote';
  }

  @override
  String libraryScreenPdfReplacedShortened(String overlayNote, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'eliminaron',
      one: 'eliminó',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entradas de página',
      one: 'entrada de página',
    );
    return 'PDF reemplazado. $overlayNote El nuevo archivo es más corto, así que se $_temp0 $count $_temp1.';
  }

  @override
  String libraryScreenReplaceFailed(String error) {
    return 'No se pudo reemplazar el PDF: $error';
  }

  @override
  String continuousPageOrderViewOpenFailed(String error) {
    return 'No se pudo abrir el PDF: $error';
  }

  @override
  String get performancePageSlotBlank => 'En blanco';

  @override
  String performancePageSlotMissingPage(int page) {
    return 'Falta la página $page';
  }

  @override
  String singlePageSliderOpenFailed(String error) {
    return 'No se pudo abrir el PDF: $error';
  }

  @override
  String aboutSheetVersion(String version) {
    return 'Versión $version';
  }

  @override
  String aboutSheetVersionWithBuild(String version, String build) {
    return 'Versión $version ($build)';
  }

  @override
  String aboutSheetLinkOpenFailed(String url) {
    return 'No se pudo abrir el enlace: $url';
  }

  @override
  String aboutSheetTitle(String productName) {
    return 'Acerca de $productName';
  }

  @override
  String get aboutSheetWebsiteLabel => 'Sitio web';

  @override
  String get aboutSheetPrivacyLabel => 'Privacidad';

  @override
  String get aboutSheetSupportLabel => 'Soporte';

  @override
  String get bookmarksSheetAddTitle => 'Agregar marcador';

  @override
  String bookmarksSheetPageLabel(int page) {
    return 'Página $page';
  }

  @override
  String get bookmarksSheetRenameTitle => 'Renombrar marcador';

  @override
  String get bookmarksSheetTitle => 'Marcadores';

  @override
  String get bookmarksSheetEmpty => 'Aún no hay marcadores';

  @override
  String get displaySheetBorderColorTitle => 'Color del borde';

  @override
  String displaySheetHue(int value) {
    return 'Tono: $value';
  }

  @override
  String displaySheetSaturation(int value) {
    return 'Saturación: $value';
  }

  @override
  String displaySheetColorValue(int value) {
    return 'Valor: $value';
  }

  @override
  String get displaySheetTitle => 'Pantalla';

  @override
  String get displaySheetPerformanceMode => 'Modo actuación';

  @override
  String get displaySheetPageBorder => 'Borde de página';

  @override
  String displaySheetThickness(String value) {
    return 'Grosor: $value';
  }

  @override
  String get displaySheetColorLabel => 'Color';

  @override
  String get displaySheetCustomChip => 'Personalizado';

  @override
  String get displaySheetShowStatusBar => 'Mostrar barra de estado';

  @override
  String get displaySheetShowStatusBarHint =>
      'Mantén visibles el reloj y la batería mientras tocas';

  @override
  String get displaySheetAvoidNotches => 'Evitar muescas de la cámara';

  @override
  String get displaySheetAvoidNotchesHint =>
      'Mantén la página libre de la muesca de la cámara y las esquinas redondeadas';

  @override
  String get jumpLinkEditSheetAddTitle => 'Agregar enlace de salto';

  @override
  String get jumpLinkEditSheetEditTitle => 'Editar enlace de salto';

  @override
  String jumpLinkEditSheetOriginLabel(int page) {
    return 'Desde la página $page';
  }

  @override
  String jumpLinkEditSheetDestinationLabel(int page, int pageCount) {
    return 'A la página $page de $pageCount';
  }

  @override
  String get jumpLinkEditSheetColorLabel => 'Color';

  @override
  String get jumpLinkEditSheetSizeLabel => 'Tamaño';

  @override
  String get jumpLinksSheetDragHint =>
      'Agregado. Arrastra un enlace de salto en la lista para reordenarlo.';

  @override
  String get jumpLinksSheetTitle => 'Enlaces de salto';

  @override
  String get jumpLinksSheetEmpty => 'Aún no hay enlaces de salto';

  @override
  String jumpLinksSheetRowTitle(int from, int to) {
    return 'Página $from → $to';
  }

  @override
  String get jumpLinksSheetRowSubtitle => 'Toca para saltar a este enlace';

  @override
  String labelSheetsTitle(String title) {
    return 'Etiquetas de $title';
  }

  @override
  String get labelSheetsManage => 'Administrar';

  @override
  String get labelSheetsCreateLabel => 'Crear etiqueta';

  @override
  String get labelSheetsNewLabel => 'Nueva etiqueta';

  @override
  String get labelSheetsManageTitle => 'Administrar etiquetas';

  @override
  String get labelSheetsNoLabelsYet => 'Aún no hay etiquetas';

  @override
  String labelSheetsUsageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'partituras',
      one: 'partitura',
    );
    return 'Usada por $count $_temp0';
  }

  @override
  String get labelSheetsDeleteTitle => '¿Eliminar etiqueta?';

  @override
  String labelSheetsDeleteConfirm(String name) {
    return '¿Eliminar “$name”?';
  }

  @override
  String labelSheetsDeleteConfirmWithUsage(String name, int usage) {
    String _temp0 = intl.Intl.pluralLogic(
      usage,
      locale: localeName,
      other: 'partituras',
      one: 'partitura',
    );
    return '“$name” está en uso por $usage $_temp0. ¿Eliminarla de todas formas?';
  }

  @override
  String get labelSheetsRenameLabelTitle => 'Renombrar etiqueta';

  @override
  String get labelSheetsNameHint => 'Nombre de la etiqueta';

  @override
  String get libraryFilterSheetTitle => 'Filtro';

  @override
  String get libraryFilterSheetModeAny => 'Cualquiera';

  @override
  String get libraryFilterSheetModeAll => 'Todas';

  @override
  String get libraryFilterSheetModeUntagged => 'Sin etiquetas';

  @override
  String get libraryFilterSheetUntaggedHint => 'Partituras sin etiquetas';

  @override
  String get libraryFilterSheetEmptyLabels =>
      'Aún no hay etiquetas por las que filtrar';

  @override
  String get measureMapMeasureCountTitle => '¿Cuántos MeasureBoxes?';

  @override
  String get measureMapMeasureCountLabel => 'MeasureBoxes';

  @override
  String get measureMapGoToTitle => 'Ir al compás';

  @override
  String get measureMapGoToLabel => 'Número de compás';

  @override
  String measureMapGoToMissing(int number) {
    return 'El compás $number aún no está mapeado';
  }

  @override
  String get measureMapMetaTitle => 'Tempo y métrica';

  @override
  String get measureMapTimeSignatureLabel => 'Métrica';

  @override
  String get measureMapTempoLabel => 'Tempo';

  @override
  String get measureMapMetaScopeTitle => 'Aplicar a';

  @override
  String get measureMapScopeThisMeasure => 'Solo este compás';

  @override
  String get measureMapScopeThisSystem => 'Este system';

  @override
  String get measureMapScopeThisPage => 'Esta página';

  @override
  String get measureMapScopeRestOfScore => 'Resto del Score';

  @override
  String get measureMapScopeNextN => 'Next N…';

  @override
  String get measureMapMetaNextNLabel => 'Número de compases';

  @override
  String get measureMapClearTitle => '¿Borrar MeasureMap?';

  @override
  String get measureMapClearBody =>
      'Borra todos los SystemBox y MeasureBox de este Score. No se puede deshacer.';

  @override
  String get measureMapClearConfirm => 'Borrar';

  @override
  String get measureMapDeleteSystemTitle => '¿Borrar system?';

  @override
  String get measureMapDeleteSystemBody =>
      'Borra este SystemBox y todos sus MeasureBoxes.';

  @override
  String get measureMapCopyFromPageTitle => 'Copiar diseño desde página';

  @override
  String get measureMapCopyFromPageLabel => 'Página de origen';

  @override
  String get measureMapCopyPrevious => 'Copiar página anterior';

  @override
  String get measureMapEmptyHint =>
      'Dibuja un system — todos los pentagramas que suenan a la vez. La app preguntará cuántos compases';

  @override
  String get measureMapDone => 'Listo';

  @override
  String get measureMapEditBeats => 'Edit beats';

  @override
  String get measureMapSetMeasureCount => 'Establecer número de compases…';

  @override
  String get measureMapDeleteSystem => 'Borrar system';

  @override
  String get measureMapDeleteMeasure => 'Borrar compás';

  @override
  String get measureMapEditMeta => 'Tempo y métrica…';

  @override
  String get measureMapStartsAtBeat => 'Starts at beat';

  @override
  String get measureMapStartsAtBeatHint =>
      '1 = full measure; higher skips early beats (pickup on a wide box)';

  @override
  String get measureMapClearAll => 'Borrar MeasureMap…';
}
