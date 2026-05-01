// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'AllergyGuard';

  @override
  String get bootstrapErrorTitle => 'Errore di avvio';

  @override
  String get bootstrapErrorMessage =>
      'L\'app non è riuscita ad avviarsi correttamente.';

  @override
  String get bootstrapErrorHint =>
      'Controlla il file .env e ricompila l\'app se hai appena modificato la configurazione.';

  @override
  String get commonBack => 'Indietro';

  @override
  String get commonNext => 'Avanti';

  @override
  String get commonStart => 'Inizia';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonSave => 'Salva';

  @override
  String get commonDelete => 'Elimina';

  @override
  String get commonRepeat => 'Ripeti';

  @override
  String get commonClose => 'Chiudi';

  @override
  String get commonSend => 'Invia';

  @override
  String get commonSending => 'Invio...';

  @override
  String get onboardingChooseLanguageTitle => 'Scegli la lingua';

  @override
  String get onboardingChooseLanguageIntro =>
      'AllergyGuard ti guiderà subito nella configurazione iniziale.';

  @override
  String get onboardingChooseLanguageHint =>
      'Questa scelta viene usata per l\'interfaccia, i nomi degli allergeni e le preferenze dell\'app.';

  @override
  String get onboardingAllergensTitle => 'Seleziona i tuoi allergeni';

  @override
  String get onboardingAllergensEmptyHint =>
      'Puoi iniziare senza selezioni, ma scegliendo gli allergeni l\'app potrà evidenziarli meglio.';

  @override
  String onboardingAllergensSelectedCount(int count) {
    return '$count allergeni selezionati';
  }

  @override
  String get onboardingAllergenEuRegulated => 'Allergene UE regolamentato';

  @override
  String get onboardingAllergenCustom => 'Allergene personalizzato';

  @override
  String get scannerTitle => 'Scansiona';

  @override
  String get scannerModeBarcode => 'Codice a barre';

  @override
  String get scannerModeLabel => 'Etichetta';

  @override
  String get scannerTapToCapture => 'Tocca per fotografare';

  @override
  String get scannerScanning => 'Scansione in corso...';

  @override
  String get scannerOpenHistory => 'Storico';

  @override
  String get scannerOpenSettings => 'Impostazioni';

  @override
  String get scannerPillAuto => 'Scanner automatico';

  @override
  String get scannerPillBarcodeOcr => 'Barcode + OCR';

  @override
  String get scannerHintOverlay =>
      'Inquadra il codice a barre oppure la lista ingredienti. Lo scanner prova automaticamente barcode e OCR a frame alterni.';

  @override
  String get scannerNoCamera => 'Fotocamera non disponibile';

  @override
  String get scannerRetry => 'Riprova';

  @override
  String get scannerOpenAppSettings => 'Apri impostazioni';

  @override
  String get scannerCameraErrorDefault =>
      'Controlla il permesso fotocamera e riprova.';

  @override
  String get scannerCameraPermissionPermanent =>
      'Il permesso fotocamera è negato in modo permanente.';

  @override
  String get scannerCameraPermissionNeeded =>
      'Serve il permesso fotocamera per usare lo scanner.';

  @override
  String get scannerCameraNone =>
      'Nessuna fotocamera disponibile sul dispositivo.';

  @override
  String scannerCameraInitError(String error) {
    return 'Impossibile inizializzare la fotocamera: $error';
  }

  @override
  String scannerAutoAnalysisError(String error) {
    return 'Errore scanner automatico: $error';
  }

  @override
  String get scannerNoAllergenSelected =>
      'Seleziona almeno un allergene dalle impostazioni per attivare gli avvisi automatici.';

  @override
  String get scannerAnalysisActive => 'Analisi attiva su barcode e OCR.';

  @override
  String scannerLastBarcode(String barcode) {
    return 'Ultimo barcode: $barcode';
  }

  @override
  String get scannerPointCamera =>
      'Punta la fotocamera verso il codice a barre o la sezione ingredienti.';

  @override
  String get resultLevelDanger => 'PERICOLO';

  @override
  String get resultLevelWarning => 'ATTENZIONE';

  @override
  String get resultLevelSafe => 'APPARENTEMENTE SICURO';

  @override
  String get resultLevelUnknown => 'NON VERIFICABILE';

  @override
  String get resultAllergensDetected => 'Allergeni rilevati:';

  @override
  String get resultLabelAccordion => 'Testo etichetta completo';

  @override
  String get resultReportError => 'Segnala errore';

  @override
  String get resultSaveToHistory => 'Risultato salvato nello storico';

  @override
  String get resultReportDialogTitle => 'Segnala un problema';

  @override
  String get resultReportTypeLabel => 'Tipo segnalazione';

  @override
  String get resultReportWrongDetection => 'Rilevamento errato';

  @override
  String get resultReportMissingAllergen => 'Allergene non rilevato';

  @override
  String get resultReportOcrProblem => 'Problema OCR';

  @override
  String get resultReportOptionalNote => 'Nota facoltativa';

  @override
  String get resultReportNoteHint => 'Descrivi cosa non ti convince';

  @override
  String get resultReportSaveAction => 'Salva segnalazione';

  @override
  String get resultReportSaved => 'Segnalazione salvata localmente';

  @override
  String get resultRecognizedPrefix => 'Riconosciuto:';

  @override
  String get resultFoundInPrefix => 'Trovato in:';

  @override
  String get resultPartialMatch => 'Match parziale';

  @override
  String get resultFullMatch => 'Match completo';

  @override
  String get resultOcrContext => 'Contesto OCR:';

  @override
  String get resultZoomedArea => 'Area immagine ingrandita';

  @override
  String get resultFeedbackCta =>
      'Il risultato era sbagliato? Aiutaci a migliorare';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsSectionAllergens => 'Allergeni';

  @override
  String get settingsManageAllergens => 'Gestisci allergeni';

  @override
  String get settingsSectionAccessibility => 'Accessibilità';

  @override
  String get settingsLanguage => 'Lingua interfaccia';

  @override
  String get settingsTtsSpeed => 'Velocità lettura';

  @override
  String get settingsTtsSpeedSlow => 'Lenta';

  @override
  String get settingsTtsSpeedNormal => 'Normale';

  @override
  String get settingsTtsSpeedFast => 'Veloce';

  @override
  String get settingsAutoPlay => 'Lettura automatica risultato';

  @override
  String get settingsSectionCommunity => 'Community';

  @override
  String get settingsLeaveFeedback => 'Lascia un feedback';

  @override
  String get settingsLeaveFeedbackSubtitle =>
      'Aiutaci a migliorare: suggerimenti, bug, accuratezza';

  @override
  String get settingsAboutAndPrivacy => 'Informazioni e privacy';

  @override
  String get settingsAboutAndPrivacySubtitle =>
      'Versione, licenze, attribuzioni';

  @override
  String get settingsCommunityLearning => 'Contribuisci al miglioramento';

  @override
  String get settingsCommunityLearningSubtitle =>
      'Invia frammenti di testo anonimi per aiutare a riconoscere nuovi pattern allergeni';

  @override
  String get settingsSectionPrivacy => 'Privacy';

  @override
  String get settingsRepeatOnboarding => 'Ripeti onboarding';

  @override
  String get settingsRepeatOnboardingSubtitle =>
      'Riporta l\'app alla scelta lingua e allergeni';

  @override
  String get settingsRepeatOnboardingDialogTitle => 'Ripetere onboarding?';

  @override
  String get settingsRepeatOnboardingDialogBody =>
      'Ti verrà richiesto di scegliere di nuovo lingua e allergeni.';

  @override
  String get settingsClearLocalData => 'Elimina dati locali';

  @override
  String get settingsClearLocalDataSubtitle =>
      'Rimuove preferenze, onboarding e allergeni personalizzati';

  @override
  String get settingsClearDialogTitle => 'Eliminare i dati locali?';

  @override
  String get settingsClearDialogBody =>
      'Verranno rimossi onboarding, lingua, allergeni selezionati e allergeni personalizzati.';

  @override
  String get feedbackTitle => 'Lascia un feedback';

  @override
  String get feedbackAnonymousNotice =>
      'Il feedback è completamente anonimo. Non raccogliamo nome, email o posizione. Solo un ID casuale per evitare duplicati.';

  @override
  String get feedbackTypeLabel => 'Tipo di feedback';

  @override
  String get feedbackTypeScanAccuracy => 'Accuratezza scansione';

  @override
  String get feedbackTypeSuggestion => 'Suggerimento';

  @override
  String get feedbackTypeBugReport => 'Segnala bug';

  @override
  String get feedbackTypeGeneral => 'Commento generale';

  @override
  String get feedbackWasCorrectQuestion =>
      'Il risultato della scansione era corretto?';

  @override
  String get feedbackWasCorrectYes => 'Sì, corretto';

  @override
  String get feedbackWasCorrectNo => 'No, sbagliato';

  @override
  String get feedbackExpectedQuestion =>
      'Quale sarebbe stato il risultato corretto?';

  @override
  String get feedbackExpectedDanger => 'Pericoloso';

  @override
  String get feedbackExpectedWarning => 'Attenzione';

  @override
  String get feedbackExpectedSafe => 'Sicuro';

  @override
  String get feedbackExpectedUnknown => 'Non determinabile';

  @override
  String get feedbackCommentLabel => 'Commento';

  @override
  String get feedbackCommentHintScanAccuracy =>
      'Descrivi cosa hai scansionato e cosa ti aspettavi...';

  @override
  String get feedbackCommentHintSuggestion =>
      'Quale funzionalità vorresti vedere nell\'app?';

  @override
  String get feedbackCommentHintBugReport =>
      'Descrivi il problema riscontrato. Cosa hai fatto prima che accadesse?';

  @override
  String get feedbackCommentHintGeneral => 'Raccontaci cosa pensi dell\'app...';

  @override
  String get feedbackSubmit => 'Invia feedback';

  @override
  String get feedbackStoreReviewCta =>
      'Se ti piace l\'app, lascia una recensione sullo store!';

  @override
  String get feedbackNeedComment => 'Scrivi un commento prima di inviare.';

  @override
  String get feedbackNeedCorrectness =>
      'Indica se il risultato della scansione era corretto.';

  @override
  String get feedbackBackendUnavailable =>
      'Backend non configurato. Il feedback verrà inviato quando disponibile.';

  @override
  String get feedbackThankYouTitle => 'Grazie!';

  @override
  String get feedbackThankYouBody =>
      'Il tuo feedback ci aiuta a migliorare AllergyGuard. Ogni segnalazione viene letta e presa in considerazione.';

  @override
  String get feedbackSubmitError => 'Errore di invio. Riprova più tardi.';

  @override
  String get historyTitle => 'Storico scansioni';

  @override
  String get historyFilterAll => 'Tutti';

  @override
  String get historyFilterDanger => 'Pericolo';

  @override
  String get historyFilterWarning => 'Attenzione';

  @override
  String get historyFilterSafe => 'Sicuro';

  @override
  String get historyFilterUnknown => 'Sconosciuto';

  @override
  String get historySearchHint => 'Cerca prodotto...';

  @override
  String get historyEmpty => 'Nessuna scansione salvata';

  @override
  String get historyUnknownProduct => 'Prodotto sconosciuto';

  @override
  String get allergenSetupTitle => 'I tuoi allergeni';

  @override
  String get allergenSetupAddCustom => 'Aggiungi allergene personalizzato';

  @override
  String get allergenSetupCustomHint => 'Es. pistacchio, kiwi, ecc.';

  @override
  String get allergenSetupSave => 'Salva';

  @override
  String get allergenSetupSearchHint => 'Cerca allergene...';

  @override
  String get allergenSetupAddButton => 'Aggiungi';

  @override
  String get allergenSetupEmpty => 'Nessun allergene trovato';

  @override
  String get allergenSetupNameHint => 'Nome allergene';

  @override
  String allergenSetupAddedToList(String name) {
    return '\"$name\" aggiunto alla lista';
  }

  @override
  String get aboutTitle => 'Informazioni e privacy';

  @override
  String get aboutVersion => 'Versione';

  @override
  String get aboutDisclaimerTitle => 'Avvertenza importante';

  @override
  String get aboutDisclaimer =>
      'AllergyGuard è uno strumento di supporto, NON una certificazione di sicurezza. In caso di allergie gravi consulta sempre un medico e verifica personalmente l\'etichetta.';

  @override
  String get aboutPrivacyPolicy => 'Privacy Policy';

  @override
  String get aboutViewPrivacy => 'Apri privacy policy';

  @override
  String get aboutLicense => 'Licenza MIT';

  @override
  String get aboutViewLicenses => 'Licenze open source';

  @override
  String get aboutContact => 'Contatto';

  @override
  String get aboutAttributionTitle => 'Attribuzioni';

  @override
  String get aboutAttributionOff => 'Dati prodotto da Open Food Facts (ODbL)';

  @override
  String get aboutAttributionMlkit => 'OCR e barcode con Google ML Kit';

  @override
  String get aboutAttributionSupabase => 'Backend con Supabase';

  @override
  String get aboutSectionLegal => 'Legale e privacy';

  @override
  String get aboutPrivacySubtitle =>
      'Come trattiamo i dati (in breve: pochissimi)';

  @override
  String get aboutLicenseSubtitle =>
      'Codice aperto. Libero utilizzo, modifica e ridistribuzione.';

  @override
  String get aboutSectionCredits => 'Crediti e attribuzioni';

  @override
  String get aboutOffSubtitle =>
      'Dati prodotti via barcode — licenza ODbL. openfoodfacts.org';

  @override
  String get aboutMlkitSubtitle =>
      'Riconoscimento testo e codici a barre on-device. Nessun invio a server Google.';

  @override
  String get aboutSupabaseSubtitle =>
      'Backend per pattern linguistici della community. Server UE con crittografia.';

  @override
  String get aboutSectionContact => 'Contatti';

  @override
  String get aboutRepositoryTitle => 'Codice sorgente';

  @override
  String aboutLaunchError(String url) {
    return 'Impossibile aprire $url';
  }

  @override
  String get disclaimerShort =>
      'Strumento di supporto, non una certificazione. Verifica sempre l\'etichetta e consulta il medico per allergie gravi.';
}
