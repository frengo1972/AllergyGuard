import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
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
/// import 'l10n/app_localizations.dart';
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
    Locale('it'),
    Locale('ja'),
    Locale('zh')
  ];

  /// No description provided for @appName.
  ///
  /// In it, this message translates to:
  /// **'AllergyGuard'**
  String get appName;

  /// No description provided for @bootstrapErrorTitle.
  ///
  /// In it, this message translates to:
  /// **'Errore di avvio'**
  String get bootstrapErrorTitle;

  /// No description provided for @bootstrapErrorMessage.
  ///
  /// In it, this message translates to:
  /// **'L\'app non è riuscita ad avviarsi correttamente.'**
  String get bootstrapErrorMessage;

  /// No description provided for @bootstrapErrorHint.
  ///
  /// In it, this message translates to:
  /// **'Controlla il file .env e ricompila l\'app se hai appena modificato la configurazione.'**
  String get bootstrapErrorHint;

  /// No description provided for @commonBack.
  ///
  /// In it, this message translates to:
  /// **'Indietro'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get commonNext;

  /// No description provided for @commonStart.
  ///
  /// In it, this message translates to:
  /// **'Inizia'**
  String get commonStart;

  /// No description provided for @commonCancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get commonDelete;

  /// No description provided for @commonRepeat.
  ///
  /// In it, this message translates to:
  /// **'Ripeti'**
  String get commonRepeat;

  /// No description provided for @commonClose.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get commonClose;

  /// No description provided for @commonSend.
  ///
  /// In it, this message translates to:
  /// **'Invia'**
  String get commonSend;

  /// No description provided for @commonSending.
  ///
  /// In it, this message translates to:
  /// **'Invio...'**
  String get commonSending;

  /// No description provided for @onboardingChooseLanguageTitle.
  ///
  /// In it, this message translates to:
  /// **'Scegli la lingua'**
  String get onboardingChooseLanguageTitle;

  /// No description provided for @onboardingChooseLanguageIntro.
  ///
  /// In it, this message translates to:
  /// **'AllergyGuard ti guiderà subito nella configurazione iniziale.'**
  String get onboardingChooseLanguageIntro;

  /// No description provided for @onboardingChooseLanguageHint.
  ///
  /// In it, this message translates to:
  /// **'Questa scelta viene usata per l\'interfaccia, i nomi degli allergeni e le preferenze dell\'app.'**
  String get onboardingChooseLanguageHint;

  /// No description provided for @onboardingAllergensTitle.
  ///
  /// In it, this message translates to:
  /// **'Seleziona i tuoi allergeni'**
  String get onboardingAllergensTitle;

  /// No description provided for @onboardingAllergensEmptyHint.
  ///
  /// In it, this message translates to:
  /// **'Puoi iniziare senza selezioni, ma scegliendo gli allergeni l\'app potrà evidenziarli meglio.'**
  String get onboardingAllergensEmptyHint;

  /// No description provided for @onboardingAllergensSelectedCount.
  ///
  /// In it, this message translates to:
  /// **'{count} allergeni selezionati'**
  String onboardingAllergensSelectedCount(int count);

  /// No description provided for @onboardingAllergenEuRegulated.
  ///
  /// In it, this message translates to:
  /// **'Allergene UE regolamentato'**
  String get onboardingAllergenEuRegulated;

  /// No description provided for @onboardingAllergenCustom.
  ///
  /// In it, this message translates to:
  /// **'Allergene personalizzato'**
  String get onboardingAllergenCustom;

  /// No description provided for @scannerTitle.
  ///
  /// In it, this message translates to:
  /// **'Scansiona'**
  String get scannerTitle;

  /// No description provided for @scannerModeBarcode.
  ///
  /// In it, this message translates to:
  /// **'Codice a barre'**
  String get scannerModeBarcode;

  /// No description provided for @scannerModeLabel.
  ///
  /// In it, this message translates to:
  /// **'Etichetta'**
  String get scannerModeLabel;

  /// No description provided for @scannerTapToCapture.
  ///
  /// In it, this message translates to:
  /// **'Tocca per fotografare'**
  String get scannerTapToCapture;

  /// No description provided for @scannerScanning.
  ///
  /// In it, this message translates to:
  /// **'Scansione in corso...'**
  String get scannerScanning;

  /// No description provided for @scannerOpenHistory.
  ///
  /// In it, this message translates to:
  /// **'Storico'**
  String get scannerOpenHistory;

  /// No description provided for @scannerOpenSettings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get scannerOpenSettings;

  /// No description provided for @scannerPillAuto.
  ///
  /// In it, this message translates to:
  /// **'Scanner automatico'**
  String get scannerPillAuto;

  /// No description provided for @scannerPillBarcodeOcr.
  ///
  /// In it, this message translates to:
  /// **'Barcode + OCR'**
  String get scannerPillBarcodeOcr;

  /// No description provided for @scannerHintOverlay.
  ///
  /// In it, this message translates to:
  /// **'Inquadra il codice a barre oppure la lista ingredienti. Lo scanner prova automaticamente barcode e OCR a frame alterni.'**
  String get scannerHintOverlay;

  /// No description provided for @scannerNoCamera.
  ///
  /// In it, this message translates to:
  /// **'Fotocamera non disponibile'**
  String get scannerNoCamera;

  /// No description provided for @scannerRetry.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get scannerRetry;

  /// No description provided for @scannerOpenAppSettings.
  ///
  /// In it, this message translates to:
  /// **'Apri impostazioni'**
  String get scannerOpenAppSettings;

  /// No description provided for @scannerCameraErrorDefault.
  ///
  /// In it, this message translates to:
  /// **'Controlla il permesso fotocamera e riprova.'**
  String get scannerCameraErrorDefault;

  /// No description provided for @scannerCameraPermissionPermanent.
  ///
  /// In it, this message translates to:
  /// **'Il permesso fotocamera è negato in modo permanente.'**
  String get scannerCameraPermissionPermanent;

  /// No description provided for @scannerCameraPermissionNeeded.
  ///
  /// In it, this message translates to:
  /// **'Serve il permesso fotocamera per usare lo scanner.'**
  String get scannerCameraPermissionNeeded;

  /// No description provided for @scannerCameraNone.
  ///
  /// In it, this message translates to:
  /// **'Nessuna fotocamera disponibile sul dispositivo.'**
  String get scannerCameraNone;

  /// No description provided for @scannerCameraInitError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile inizializzare la fotocamera: {error}'**
  String scannerCameraInitError(String error);

  /// No description provided for @scannerAutoAnalysisError.
  ///
  /// In it, this message translates to:
  /// **'Errore scanner automatico: {error}'**
  String scannerAutoAnalysisError(String error);

  /// No description provided for @scannerNoAllergenSelected.
  ///
  /// In it, this message translates to:
  /// **'Seleziona almeno un allergene dalle impostazioni per attivare gli avvisi automatici.'**
  String get scannerNoAllergenSelected;

  /// No description provided for @scannerAnalysisActive.
  ///
  /// In it, this message translates to:
  /// **'Analisi attiva su barcode e OCR.'**
  String get scannerAnalysisActive;

  /// No description provided for @scannerLastBarcode.
  ///
  /// In it, this message translates to:
  /// **'Ultimo barcode: {barcode}'**
  String scannerLastBarcode(String barcode);

  /// No description provided for @scannerPointCamera.
  ///
  /// In it, this message translates to:
  /// **'Punta la fotocamera verso il codice a barre o la sezione ingredienti.'**
  String get scannerPointCamera;

  /// No description provided for @resultLevelDanger.
  ///
  /// In it, this message translates to:
  /// **'PERICOLO'**
  String get resultLevelDanger;

  /// No description provided for @resultLevelWarning.
  ///
  /// In it, this message translates to:
  /// **'ATTENZIONE'**
  String get resultLevelWarning;

  /// No description provided for @resultLevelSafe.
  ///
  /// In it, this message translates to:
  /// **'APPARENTEMENTE SICURO'**
  String get resultLevelSafe;

  /// No description provided for @resultLevelUnknown.
  ///
  /// In it, this message translates to:
  /// **'NON VERIFICABILE'**
  String get resultLevelUnknown;

  /// No description provided for @resultAllergensDetected.
  ///
  /// In it, this message translates to:
  /// **'Allergeni rilevati:'**
  String get resultAllergensDetected;

  /// No description provided for @resultLabelAccordion.
  ///
  /// In it, this message translates to:
  /// **'Testo etichetta completo'**
  String get resultLabelAccordion;

  /// No description provided for @resultReportError.
  ///
  /// In it, this message translates to:
  /// **'Segnala errore'**
  String get resultReportError;

  /// No description provided for @resultSaveToHistory.
  ///
  /// In it, this message translates to:
  /// **'Risultato salvato nello storico'**
  String get resultSaveToHistory;

  /// No description provided for @resultReportDialogTitle.
  ///
  /// In it, this message translates to:
  /// **'Segnala un problema'**
  String get resultReportDialogTitle;

  /// No description provided for @resultReportTypeLabel.
  ///
  /// In it, this message translates to:
  /// **'Tipo segnalazione'**
  String get resultReportTypeLabel;

  /// No description provided for @resultReportWrongDetection.
  ///
  /// In it, this message translates to:
  /// **'Rilevamento errato'**
  String get resultReportWrongDetection;

  /// No description provided for @resultReportMissingAllergen.
  ///
  /// In it, this message translates to:
  /// **'Allergene non rilevato'**
  String get resultReportMissingAllergen;

  /// No description provided for @resultReportOcrProblem.
  ///
  /// In it, this message translates to:
  /// **'Problema OCR'**
  String get resultReportOcrProblem;

  /// No description provided for @resultReportOptionalNote.
  ///
  /// In it, this message translates to:
  /// **'Nota facoltativa'**
  String get resultReportOptionalNote;

  /// No description provided for @resultReportNoteHint.
  ///
  /// In it, this message translates to:
  /// **'Descrivi cosa non ti convince'**
  String get resultReportNoteHint;

  /// No description provided for @resultReportSaveAction.
  ///
  /// In it, this message translates to:
  /// **'Salva segnalazione'**
  String get resultReportSaveAction;

  /// No description provided for @resultReportSaved.
  ///
  /// In it, this message translates to:
  /// **'Segnalazione salvata localmente'**
  String get resultReportSaved;

  /// No description provided for @resultRecognizedPrefix.
  ///
  /// In it, this message translates to:
  /// **'Riconosciuto:'**
  String get resultRecognizedPrefix;

  /// No description provided for @resultFoundInPrefix.
  ///
  /// In it, this message translates to:
  /// **'Trovato in:'**
  String get resultFoundInPrefix;

  /// No description provided for @resultPartialMatch.
  ///
  /// In it, this message translates to:
  /// **'Match parziale'**
  String get resultPartialMatch;

  /// No description provided for @resultFullMatch.
  ///
  /// In it, this message translates to:
  /// **'Match completo'**
  String get resultFullMatch;

  /// No description provided for @resultOcrContext.
  ///
  /// In it, this message translates to:
  /// **'Contesto OCR:'**
  String get resultOcrContext;

  /// No description provided for @resultZoomedArea.
  ///
  /// In it, this message translates to:
  /// **'Area immagine ingrandita'**
  String get resultZoomedArea;

  /// No description provided for @resultFeedbackCta.
  ///
  /// In it, this message translates to:
  /// **'Il risultato era sbagliato? Aiutaci a migliorare'**
  String get resultFeedbackCta;

  /// No description provided for @settingsTitle.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get settingsTitle;

  /// No description provided for @settingsSectionAllergens.
  ///
  /// In it, this message translates to:
  /// **'Allergeni'**
  String get settingsSectionAllergens;

  /// No description provided for @settingsManageAllergens.
  ///
  /// In it, this message translates to:
  /// **'Gestisci allergeni'**
  String get settingsManageAllergens;

  /// No description provided for @settingsSectionAccessibility.
  ///
  /// In it, this message translates to:
  /// **'Accessibilità'**
  String get settingsSectionAccessibility;

  /// No description provided for @settingsLanguage.
  ///
  /// In it, this message translates to:
  /// **'Lingua interfaccia'**
  String get settingsLanguage;

  /// No description provided for @settingsTtsSpeed.
  ///
  /// In it, this message translates to:
  /// **'Velocità lettura'**
  String get settingsTtsSpeed;

  /// No description provided for @settingsTtsSpeedSlow.
  ///
  /// In it, this message translates to:
  /// **'Lenta'**
  String get settingsTtsSpeedSlow;

  /// No description provided for @settingsTtsSpeedNormal.
  ///
  /// In it, this message translates to:
  /// **'Normale'**
  String get settingsTtsSpeedNormal;

  /// No description provided for @settingsTtsSpeedFast.
  ///
  /// In it, this message translates to:
  /// **'Veloce'**
  String get settingsTtsSpeedFast;

  /// No description provided for @settingsAutoPlay.
  ///
  /// In it, this message translates to:
  /// **'Lettura automatica risultato'**
  String get settingsAutoPlay;

  /// No description provided for @settingsSectionCommunity.
  ///
  /// In it, this message translates to:
  /// **'Community'**
  String get settingsSectionCommunity;

  /// No description provided for @settingsLeaveFeedback.
  ///
  /// In it, this message translates to:
  /// **'Lascia un feedback'**
  String get settingsLeaveFeedback;

  /// No description provided for @settingsLeaveFeedbackSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Aiutaci a migliorare: suggerimenti, bug, accuratezza'**
  String get settingsLeaveFeedbackSubtitle;

  /// No description provided for @settingsAboutAndPrivacy.
  ///
  /// In it, this message translates to:
  /// **'Informazioni e privacy'**
  String get settingsAboutAndPrivacy;

  /// No description provided for @settingsAboutAndPrivacySubtitle.
  ///
  /// In it, this message translates to:
  /// **'Versione, licenze, attribuzioni'**
  String get settingsAboutAndPrivacySubtitle;

  /// No description provided for @settingsCommunityLearning.
  ///
  /// In it, this message translates to:
  /// **'Contribuisci al miglioramento'**
  String get settingsCommunityLearning;

  /// No description provided for @settingsCommunityLearningSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Invia frammenti di testo anonimi per aiutare a riconoscere nuovi pattern allergeni'**
  String get settingsCommunityLearningSubtitle;

  /// No description provided for @settingsSectionPrivacy.
  ///
  /// In it, this message translates to:
  /// **'Privacy'**
  String get settingsSectionPrivacy;

  /// No description provided for @settingsRepeatOnboarding.
  ///
  /// In it, this message translates to:
  /// **'Ripeti onboarding'**
  String get settingsRepeatOnboarding;

  /// No description provided for @settingsRepeatOnboardingSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Riporta l\'app alla scelta lingua e allergeni'**
  String get settingsRepeatOnboardingSubtitle;

  /// No description provided for @settingsRepeatOnboardingDialogTitle.
  ///
  /// In it, this message translates to:
  /// **'Ripetere onboarding?'**
  String get settingsRepeatOnboardingDialogTitle;

  /// No description provided for @settingsRepeatOnboardingDialogBody.
  ///
  /// In it, this message translates to:
  /// **'Ti verrà richiesto di scegliere di nuovo lingua e allergeni.'**
  String get settingsRepeatOnboardingDialogBody;

  /// No description provided for @settingsClearLocalData.
  ///
  /// In it, this message translates to:
  /// **'Elimina dati locali'**
  String get settingsClearLocalData;

  /// No description provided for @settingsClearLocalDataSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Rimuove preferenze, onboarding e allergeni personalizzati'**
  String get settingsClearLocalDataSubtitle;

  /// No description provided for @settingsClearDialogTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare i dati locali?'**
  String get settingsClearDialogTitle;

  /// No description provided for @settingsClearDialogBody.
  ///
  /// In it, this message translates to:
  /// **'Verranno rimossi onboarding, lingua, allergeni selezionati e allergeni personalizzati.'**
  String get settingsClearDialogBody;

  /// No description provided for @feedbackTitle.
  ///
  /// In it, this message translates to:
  /// **'Lascia un feedback'**
  String get feedbackTitle;

  /// No description provided for @feedbackAnonymousNotice.
  ///
  /// In it, this message translates to:
  /// **'Il feedback è completamente anonimo. Non raccogliamo nome, email o posizione. Solo un ID casuale per evitare duplicati.'**
  String get feedbackAnonymousNotice;

  /// No description provided for @feedbackTypeLabel.
  ///
  /// In it, this message translates to:
  /// **'Tipo di feedback'**
  String get feedbackTypeLabel;

  /// No description provided for @feedbackTypeScanAccuracy.
  ///
  /// In it, this message translates to:
  /// **'Accuratezza scansione'**
  String get feedbackTypeScanAccuracy;

  /// No description provided for @feedbackTypeSuggestion.
  ///
  /// In it, this message translates to:
  /// **'Suggerimento'**
  String get feedbackTypeSuggestion;

  /// No description provided for @feedbackTypeBugReport.
  ///
  /// In it, this message translates to:
  /// **'Segnala bug'**
  String get feedbackTypeBugReport;

  /// No description provided for @feedbackTypeGeneral.
  ///
  /// In it, this message translates to:
  /// **'Commento generale'**
  String get feedbackTypeGeneral;

  /// No description provided for @feedbackWasCorrectQuestion.
  ///
  /// In it, this message translates to:
  /// **'Il risultato della scansione era corretto?'**
  String get feedbackWasCorrectQuestion;

  /// No description provided for @feedbackWasCorrectYes.
  ///
  /// In it, this message translates to:
  /// **'Sì, corretto'**
  String get feedbackWasCorrectYes;

  /// No description provided for @feedbackWasCorrectNo.
  ///
  /// In it, this message translates to:
  /// **'No, sbagliato'**
  String get feedbackWasCorrectNo;

  /// No description provided for @feedbackExpectedQuestion.
  ///
  /// In it, this message translates to:
  /// **'Quale sarebbe stato il risultato corretto?'**
  String get feedbackExpectedQuestion;

  /// No description provided for @feedbackExpectedDanger.
  ///
  /// In it, this message translates to:
  /// **'Pericoloso'**
  String get feedbackExpectedDanger;

  /// No description provided for @feedbackExpectedWarning.
  ///
  /// In it, this message translates to:
  /// **'Attenzione'**
  String get feedbackExpectedWarning;

  /// No description provided for @feedbackExpectedSafe.
  ///
  /// In it, this message translates to:
  /// **'Sicuro'**
  String get feedbackExpectedSafe;

  /// No description provided for @feedbackExpectedUnknown.
  ///
  /// In it, this message translates to:
  /// **'Non determinabile'**
  String get feedbackExpectedUnknown;

  /// No description provided for @feedbackCommentLabel.
  ///
  /// In it, this message translates to:
  /// **'Commento'**
  String get feedbackCommentLabel;

  /// No description provided for @feedbackCommentHintScanAccuracy.
  ///
  /// In it, this message translates to:
  /// **'Descrivi cosa hai scansionato e cosa ti aspettavi...'**
  String get feedbackCommentHintScanAccuracy;

  /// No description provided for @feedbackCommentHintSuggestion.
  ///
  /// In it, this message translates to:
  /// **'Quale funzionalità vorresti vedere nell\'app?'**
  String get feedbackCommentHintSuggestion;

  /// No description provided for @feedbackCommentHintBugReport.
  ///
  /// In it, this message translates to:
  /// **'Descrivi il problema riscontrato. Cosa hai fatto prima che accadesse?'**
  String get feedbackCommentHintBugReport;

  /// No description provided for @feedbackCommentHintGeneral.
  ///
  /// In it, this message translates to:
  /// **'Raccontaci cosa pensi dell\'app...'**
  String get feedbackCommentHintGeneral;

  /// No description provided for @feedbackSubmit.
  ///
  /// In it, this message translates to:
  /// **'Invia feedback'**
  String get feedbackSubmit;

  /// No description provided for @feedbackStoreReviewCta.
  ///
  /// In it, this message translates to:
  /// **'Se ti piace l\'app, lascia una recensione sullo store!'**
  String get feedbackStoreReviewCta;

  /// No description provided for @feedbackNeedComment.
  ///
  /// In it, this message translates to:
  /// **'Scrivi un commento prima di inviare.'**
  String get feedbackNeedComment;

  /// No description provided for @feedbackNeedCorrectness.
  ///
  /// In it, this message translates to:
  /// **'Indica se il risultato della scansione era corretto.'**
  String get feedbackNeedCorrectness;

  /// No description provided for @feedbackBackendUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Backend non configurato. Il feedback verrà inviato quando disponibile.'**
  String get feedbackBackendUnavailable;

  /// No description provided for @feedbackThankYouTitle.
  ///
  /// In it, this message translates to:
  /// **'Grazie!'**
  String get feedbackThankYouTitle;

  /// No description provided for @feedbackThankYouBody.
  ///
  /// In it, this message translates to:
  /// **'Il tuo feedback ci aiuta a migliorare AllergyGuard. Ogni segnalazione viene letta e presa in considerazione.'**
  String get feedbackThankYouBody;

  /// No description provided for @feedbackSubmitError.
  ///
  /// In it, this message translates to:
  /// **'Errore di invio. Riprova più tardi.'**
  String get feedbackSubmitError;

  /// No description provided for @historyTitle.
  ///
  /// In it, this message translates to:
  /// **'Storico scansioni'**
  String get historyTitle;

  /// No description provided for @historyFilterAll.
  ///
  /// In it, this message translates to:
  /// **'Tutti'**
  String get historyFilterAll;

  /// No description provided for @historyFilterDanger.
  ///
  /// In it, this message translates to:
  /// **'Pericolo'**
  String get historyFilterDanger;

  /// No description provided for @historyFilterWarning.
  ///
  /// In it, this message translates to:
  /// **'Attenzione'**
  String get historyFilterWarning;

  /// No description provided for @historyFilterSafe.
  ///
  /// In it, this message translates to:
  /// **'Sicuro'**
  String get historyFilterSafe;

  /// No description provided for @historyFilterUnknown.
  ///
  /// In it, this message translates to:
  /// **'Sconosciuto'**
  String get historyFilterUnknown;

  /// No description provided for @historySearchHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca prodotto...'**
  String get historySearchHint;

  /// No description provided for @historyEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessuna scansione salvata'**
  String get historyEmpty;

  /// No description provided for @historyUnknownProduct.
  ///
  /// In it, this message translates to:
  /// **'Prodotto sconosciuto'**
  String get historyUnknownProduct;

  /// No description provided for @allergenSetupTitle.
  ///
  /// In it, this message translates to:
  /// **'I tuoi allergeni'**
  String get allergenSetupTitle;

  /// No description provided for @allergenSetupAddCustom.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi allergene personalizzato'**
  String get allergenSetupAddCustom;

  /// No description provided for @allergenSetupCustomHint.
  ///
  /// In it, this message translates to:
  /// **'Es. pistacchio, kiwi, ecc.'**
  String get allergenSetupCustomHint;

  /// No description provided for @allergenSetupSave.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get allergenSetupSave;

  /// No description provided for @allergenSetupSearchHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca allergene...'**
  String get allergenSetupSearchHint;

  /// No description provided for @allergenSetupAddButton.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get allergenSetupAddButton;

  /// No description provided for @allergenSetupEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessun allergene trovato'**
  String get allergenSetupEmpty;

  /// No description provided for @allergenSetupNameHint.
  ///
  /// In it, this message translates to:
  /// **'Nome allergene'**
  String get allergenSetupNameHint;

  /// No description provided for @allergenSetupAddedToList.
  ///
  /// In it, this message translates to:
  /// **'\"{name}\" aggiunto alla lista'**
  String allergenSetupAddedToList(String name);

  /// No description provided for @aboutTitle.
  ///
  /// In it, this message translates to:
  /// **'Informazioni e privacy'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In it, this message translates to:
  /// **'Versione'**
  String get aboutVersion;

  /// No description provided for @aboutDisclaimerTitle.
  ///
  /// In it, this message translates to:
  /// **'Avvertenza importante'**
  String get aboutDisclaimerTitle;

  /// No description provided for @aboutDisclaimer.
  ///
  /// In it, this message translates to:
  /// **'AllergyGuard è uno strumento di supporto, NON una certificazione di sicurezza. In caso di allergie gravi consulta sempre un medico e verifica personalmente l\'etichetta.'**
  String get aboutDisclaimer;

  /// No description provided for @aboutPrivacyPolicy.
  ///
  /// In it, this message translates to:
  /// **'Privacy Policy'**
  String get aboutPrivacyPolicy;

  /// No description provided for @aboutViewPrivacy.
  ///
  /// In it, this message translates to:
  /// **'Apri privacy policy'**
  String get aboutViewPrivacy;

  /// No description provided for @aboutLicense.
  ///
  /// In it, this message translates to:
  /// **'Licenza MIT'**
  String get aboutLicense;

  /// No description provided for @aboutViewLicenses.
  ///
  /// In it, this message translates to:
  /// **'Licenze open source'**
  String get aboutViewLicenses;

  /// No description provided for @aboutContact.
  ///
  /// In it, this message translates to:
  /// **'Contatto'**
  String get aboutContact;

  /// No description provided for @aboutAttributionTitle.
  ///
  /// In it, this message translates to:
  /// **'Attribuzioni'**
  String get aboutAttributionTitle;

  /// No description provided for @aboutAttributionOff.
  ///
  /// In it, this message translates to:
  /// **'Dati prodotto da Open Food Facts (ODbL)'**
  String get aboutAttributionOff;

  /// No description provided for @aboutAttributionMlkit.
  ///
  /// In it, this message translates to:
  /// **'OCR e barcode con Google ML Kit'**
  String get aboutAttributionMlkit;

  /// No description provided for @aboutAttributionSupabase.
  ///
  /// In it, this message translates to:
  /// **'Backend con Supabase'**
  String get aboutAttributionSupabase;

  /// No description provided for @aboutSectionLegal.
  ///
  /// In it, this message translates to:
  /// **'Legale e privacy'**
  String get aboutSectionLegal;

  /// No description provided for @aboutPrivacySubtitle.
  ///
  /// In it, this message translates to:
  /// **'Come trattiamo i dati (in breve: pochissimi)'**
  String get aboutPrivacySubtitle;

  /// No description provided for @aboutLicenseSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Codice aperto. Libero utilizzo, modifica e ridistribuzione.'**
  String get aboutLicenseSubtitle;

  /// No description provided for @aboutSectionCredits.
  ///
  /// In it, this message translates to:
  /// **'Crediti e attribuzioni'**
  String get aboutSectionCredits;

  /// No description provided for @aboutOffSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Dati prodotti via barcode — licenza ODbL. openfoodfacts.org'**
  String get aboutOffSubtitle;

  /// No description provided for @aboutMlkitSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Riconoscimento testo e codici a barre on-device. Nessun invio a server Google.'**
  String get aboutMlkitSubtitle;

  /// No description provided for @aboutSupabaseSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Backend per pattern linguistici della community. Server UE con crittografia.'**
  String get aboutSupabaseSubtitle;

  /// No description provided for @aboutSectionContact.
  ///
  /// In it, this message translates to:
  /// **'Contatti'**
  String get aboutSectionContact;

  /// No description provided for @aboutRepositoryTitle.
  ///
  /// In it, this message translates to:
  /// **'Codice sorgente'**
  String get aboutRepositoryTitle;

  /// No description provided for @aboutLaunchError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aprire {url}'**
  String aboutLaunchError(String url);

  /// No description provided for @disclaimerShort.
  ///
  /// In it, this message translates to:
  /// **'Strumento di supporto, non una certificazione. Verifica sempre l\'etichetta e consulta il medico per allergie gravi.'**
  String get disclaimerShort;
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
        'it',
        'ja',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
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
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
