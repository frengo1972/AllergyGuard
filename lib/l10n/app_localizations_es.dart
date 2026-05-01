// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'AllergyGuard';

  @override
  String get bootstrapErrorTitle => 'Error de inicio';

  @override
  String get bootstrapErrorMessage =>
      'La aplicación no pudo iniciarse correctamente.';

  @override
  String get bootstrapErrorHint =>
      'Revisa el archivo .env y vuelve a compilar la app si has cambiado la configuración.';

  @override
  String get commonBack => 'Atrás';

  @override
  String get commonNext => 'Siguiente';

  @override
  String get commonStart => 'Empezar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonRepeat => 'Repetir';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonSend => 'Enviar';

  @override
  String get commonSending => 'Enviando…';

  @override
  String get onboardingChooseLanguageTitle => 'Elige tu idioma';

  @override
  String get onboardingChooseLanguageIntro =>
      'AllergyGuard te guiará en la configuración inicial.';

  @override
  String get onboardingChooseLanguageHint =>
      'Esta elección se usa para la interfaz, los nombres de alérgenos y las preferencias de la app.';

  @override
  String get onboardingAllergensTitle => 'Selecciona tus alérgenos';

  @override
  String get onboardingAllergensEmptyHint =>
      'Puedes empezar sin selección, pero eligiendo los alérgenos la app podrá resaltarlos mejor.';

  @override
  String onboardingAllergensSelectedCount(int count) {
    return '$count alérgenos seleccionados';
  }

  @override
  String get onboardingAllergenEuRegulated => 'Alérgeno regulado UE';

  @override
  String get onboardingAllergenCustom => 'Alérgeno personalizado';

  @override
  String get scannerTitle => 'Escanear';

  @override
  String get scannerModeBarcode => 'Código de barras';

  @override
  String get scannerModeLabel => 'Etiqueta';

  @override
  String get scannerTapToCapture => 'Toca para capturar';

  @override
  String get scannerScanning => 'Escaneando…';

  @override
  String get scannerOpenHistory => 'Historial';

  @override
  String get scannerOpenSettings => 'Ajustes';

  @override
  String get scannerPillAuto => 'Escáner automático';

  @override
  String get scannerPillBarcodeOcr => 'Código de barras + OCR';

  @override
  String get scannerHintOverlay =>
      'Apunta al código de barras o a la lista de ingredientes. El escáner alterna automáticamente entre código de barras y OCR.';

  @override
  String get scannerNoCamera => 'Cámara no disponible';

  @override
  String get scannerRetry => 'Reintentar';

  @override
  String get scannerOpenAppSettings => 'Abrir ajustes';

  @override
  String get scannerCameraErrorDefault =>
      'Comprueba el permiso de la cámara e inténtalo de nuevo.';

  @override
  String get scannerCameraPermissionPermanent =>
      'El permiso de la cámara ha sido denegado permanentemente.';

  @override
  String get scannerCameraPermissionNeeded =>
      'Se necesita el permiso de la cámara para usar el escáner.';

  @override
  String get scannerCameraNone =>
      'No hay cámara disponible en este dispositivo.';

  @override
  String scannerCameraInitError(String error) {
    return 'No se pudo inicializar la cámara: $error';
  }

  @override
  String scannerAutoAnalysisError(String error) {
    return 'Error del escáner: $error';
  }

  @override
  String get scannerNoAllergenSelected =>
      'Selecciona al menos un alérgeno en ajustes para activar los avisos automáticos.';

  @override
  String get scannerAnalysisActive =>
      'Análisis activo en código de barras y OCR.';

  @override
  String scannerLastBarcode(String barcode) {
    return 'Último código de barras: $barcode';
  }

  @override
  String get scannerPointCamera =>
      'Apunta la cámara al código de barras o a la lista de ingredientes.';

  @override
  String get resultLevelDanger => 'PELIGRO';

  @override
  String get resultLevelWarning => 'ATENCIÓN';

  @override
  String get resultLevelSafe => 'PROBABLEMENTE SEGURO';

  @override
  String get resultLevelUnknown => 'NO VERIFICABLE';

  @override
  String get resultAllergensDetected => 'Alérgenos detectados:';

  @override
  String get resultLabelAccordion => 'Texto completo de la etiqueta';

  @override
  String get resultReportError => 'Reportar error';

  @override
  String get resultSaveToHistory => 'Resultado guardado en el historial';

  @override
  String get resultReportDialogTitle => 'Reportar un problema';

  @override
  String get resultReportTypeLabel => 'Tipo de reporte';

  @override
  String get resultReportWrongDetection => 'Detección incorrecta';

  @override
  String get resultReportMissingAllergen => 'Alérgeno no detectado';

  @override
  String get resultReportOcrProblem => 'Problema de OCR';

  @override
  String get resultReportOptionalNote => 'Nota opcional';

  @override
  String get resultReportNoteHint => 'Describe qué no te convence';

  @override
  String get resultReportSaveAction => 'Guardar reporte';

  @override
  String get resultReportSaved => 'Reporte guardado localmente';

  @override
  String get resultRecognizedPrefix => 'Reconocido:';

  @override
  String get resultFoundInPrefix => 'Encontrado en:';

  @override
  String get resultPartialMatch => 'Coincidencia parcial';

  @override
  String get resultFullMatch => 'Coincidencia completa';

  @override
  String get resultOcrContext => 'Contexto OCR:';

  @override
  String get resultZoomedArea => 'Zona ampliada';

  @override
  String get resultFeedbackCta => '¿Resultado incorrecto? Ayúdanos a mejorar';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionAllergens => 'Alérgenos';

  @override
  String get settingsManageAllergens => 'Gestionar alérgenos';

  @override
  String get settingsSectionAccessibility => 'Accesibilidad';

  @override
  String get settingsLanguage => 'Idioma de la interfaz';

  @override
  String get settingsTtsSpeed => 'Velocidad de lectura';

  @override
  String get settingsTtsSpeedSlow => 'Lenta';

  @override
  String get settingsTtsSpeedNormal => 'Normal';

  @override
  String get settingsTtsSpeedFast => 'Rápida';

  @override
  String get settingsAutoPlay => 'Lectura automática del resultado';

  @override
  String get settingsSectionCommunity => 'Comunidad';

  @override
  String get settingsLeaveFeedback => 'Dejar un comentario';

  @override
  String get settingsLeaveFeedbackSubtitle =>
      'Ayúdanos a mejorar: sugerencias, bugs, precisión';

  @override
  String get settingsAboutAndPrivacy => 'Información y privacidad';

  @override
  String get settingsAboutAndPrivacySubtitle => 'Versión, licencias, créditos';

  @override
  String get settingsCommunityLearning => 'Contribuir a la mejora';

  @override
  String get settingsCommunityLearningSubtitle =>
      'Enviar fragmentos de texto anónimos para ayudar a reconocer nuevos patrones de alérgenos';

  @override
  String get settingsSectionPrivacy => 'Privacidad';

  @override
  String get settingsRepeatOnboarding => 'Repetir onboarding';

  @override
  String get settingsRepeatOnboardingSubtitle =>
      'Vuelve a la selección de idioma y alérgenos';

  @override
  String get settingsRepeatOnboardingDialogTitle => '¿Repetir onboarding?';

  @override
  String get settingsRepeatOnboardingDialogBody =>
      'Se te pedirá elegir de nuevo idioma y alérgenos.';

  @override
  String get settingsClearLocalData => 'Eliminar datos locales';

  @override
  String get settingsClearLocalDataSubtitle =>
      'Elimina preferencias, onboarding y alérgenos personalizados';

  @override
  String get settingsClearDialogTitle => '¿Eliminar datos locales?';

  @override
  String get settingsClearDialogBody =>
      'Se eliminarán onboarding, idioma, alérgenos seleccionados y alérgenos personalizados.';

  @override
  String get feedbackTitle => 'Dejar un comentario';

  @override
  String get feedbackAnonymousNotice =>
      'El comentario es totalmente anónimo. No recopilamos nombre, email ni ubicación. Solo un ID aleatorio para evitar duplicados.';

  @override
  String get feedbackTypeLabel => 'Tipo de comentario';

  @override
  String get feedbackTypeScanAccuracy => 'Precisión del escaneo';

  @override
  String get feedbackTypeSuggestion => 'Sugerencia';

  @override
  String get feedbackTypeBugReport => 'Reportar bug';

  @override
  String get feedbackTypeGeneral => 'Comentario general';

  @override
  String get feedbackWasCorrectQuestion =>
      '¿El resultado del escaneo era correcto?';

  @override
  String get feedbackWasCorrectYes => 'Sí, correcto';

  @override
  String get feedbackWasCorrectNo => 'No, incorrecto';

  @override
  String get feedbackExpectedQuestion =>
      '¿Cuál habría sido el resultado correcto?';

  @override
  String get feedbackExpectedDanger => 'Peligroso';

  @override
  String get feedbackExpectedWarning => 'Atención';

  @override
  String get feedbackExpectedSafe => 'Seguro';

  @override
  String get feedbackExpectedUnknown => 'No determinable';

  @override
  String get feedbackCommentLabel => 'Comentario';

  @override
  String get feedbackCommentHintScanAccuracy =>
      'Describe qué escaneaste y qué esperabas…';

  @override
  String get feedbackCommentHintSuggestion =>
      '¿Qué funcionalidad te gustaría ver en la app?';

  @override
  String get feedbackCommentHintBugReport =>
      'Describe el problema. ¿Qué hacías antes de que ocurriera?';

  @override
  String get feedbackCommentHintGeneral => 'Cuéntanos qué piensas de la app…';

  @override
  String get feedbackSubmit => 'Enviar comentario';

  @override
  String get feedbackStoreReviewCta =>
      '¡Si te gusta la app, déjanos una reseña en la tienda!';

  @override
  String get feedbackNeedComment => 'Escribe un comentario antes de enviar.';

  @override
  String get feedbackNeedCorrectness =>
      'Indica si el resultado del escaneo era correcto.';

  @override
  String get feedbackBackendUnavailable =>
      'Backend no configurado. El comentario se enviará cuando esté disponible.';

  @override
  String get feedbackThankYouTitle => '¡Gracias!';

  @override
  String get feedbackThankYouBody =>
      'Tu comentario nos ayuda a mejorar AllergyGuard. Cada reporte se lee y se considera.';

  @override
  String get feedbackSubmitError => 'Error de envío. Inténtalo más tarde.';

  @override
  String get historyTitle => 'Historial de escaneos';

  @override
  String get historyFilterAll => 'Todos';

  @override
  String get historyFilterDanger => 'Peligro';

  @override
  String get historyFilterWarning => 'Atención';

  @override
  String get historyFilterSafe => 'Seguro';

  @override
  String get historyFilterUnknown => 'Desconocido';

  @override
  String get historySearchHint => 'Buscar producto...';

  @override
  String get historyEmpty => 'No hay escaneos guardados';

  @override
  String get historyUnknownProduct => 'Producto desconocido';

  @override
  String get allergenSetupTitle => 'Tus alérgenos';

  @override
  String get allergenSetupAddCustom => 'Añadir alérgeno personalizado';

  @override
  String get allergenSetupCustomHint => 'P. ej. pistacho, kiwi, etc.';

  @override
  String get allergenSetupSave => 'Guardar';

  @override
  String get allergenSetupSearchHint => 'Buscar alérgeno...';

  @override
  String get allergenSetupAddButton => 'Añadir';

  @override
  String get allergenSetupEmpty => 'No se encontraron alérgenos';

  @override
  String get allergenSetupNameHint => 'Nombre del alérgeno';

  @override
  String allergenSetupAddedToList(String name) {
    return '\"$name\" añadido a tu lista';
  }

  @override
  String get aboutTitle => 'Información y privacidad';

  @override
  String get aboutVersion => 'Versión';

  @override
  String get aboutDisclaimerTitle => 'Aviso importante';

  @override
  String get aboutDisclaimer =>
      'AllergyGuard es una herramienta de apoyo, NO una certificación de seguridad. Para alergias graves, consulta siempre al médico y verifica personalmente la etiqueta.';

  @override
  String get aboutPrivacyPolicy => 'Política de privacidad';

  @override
  String get aboutViewPrivacy => 'Abrir política de privacidad';

  @override
  String get aboutLicense => 'Licencia MIT';

  @override
  String get aboutViewLicenses => 'Licencias open source';

  @override
  String get aboutContact => 'Contacto';

  @override
  String get aboutAttributionTitle => 'Créditos';

  @override
  String get aboutAttributionOff =>
      'Datos de producto vía Open Food Facts (ODbL)';

  @override
  String get aboutAttributionMlkit =>
      'OCR y códigos de barras vía Google ML Kit';

  @override
  String get aboutAttributionSupabase => 'Backend vía Supabase';

  @override
  String get aboutSectionLegal => 'Legal y privacidad';

  @override
  String get aboutPrivacySubtitle =>
      'Cómo tratamos los datos (en resumen: muy pocos)';

  @override
  String get aboutLicenseSubtitle =>
      'Código abierto. Libre uso, modificación y redistribución.';

  @override
  String get aboutSectionCredits => 'Créditos y agradecimientos';

  @override
  String get aboutOffSubtitle =>
      'Datos de productos vía código de barras — licencia ODbL. openfoodfacts.org';

  @override
  String get aboutMlkitSubtitle =>
      'Reconocimiento de texto y códigos de barras en el dispositivo. No se envía nada a los servidores de Google.';

  @override
  String get aboutSupabaseSubtitle =>
      'Backend para patrones lingüísticos de la comunidad. Servidores UE con cifrado.';

  @override
  String get aboutSectionContact => 'Contacto';

  @override
  String get aboutRepositoryTitle => 'Código fuente';

  @override
  String aboutLaunchError(String url) {
    return 'No se puede abrir $url';
  }

  @override
  String get disclaimerShort =>
      'Herramienta de apoyo, no una certificación. Verifica siempre la etiqueta y consulta al médico para alergias graves.';
}
