// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'AllergyGuard';

  @override
  String get bootstrapErrorTitle => 'Startfehler';

  @override
  String get bootstrapErrorMessage =>
      'Die App konnte nicht korrekt gestartet werden.';

  @override
  String get bootstrapErrorHint =>
      'Prüfe die .env-Datei und baue die App neu, falls du gerade die Konfiguration geändert hast.';

  @override
  String get commonBack => 'Zurück';

  @override
  String get commonNext => 'Weiter';

  @override
  String get commonStart => 'Starten';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonRepeat => 'Wiederholen';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonSend => 'Senden';

  @override
  String get commonSending => 'Senden…';

  @override
  String get onboardingChooseLanguageTitle => 'Sprache wählen';

  @override
  String get onboardingChooseLanguageIntro =>
      'AllergyGuard führt dich durch die Ersteinrichtung.';

  @override
  String get onboardingChooseLanguageHint =>
      'Diese Wahl gilt für Oberfläche, Allergennamen und App-Einstellungen.';

  @override
  String get onboardingAllergensTitle => 'Wähle deine Allergene';

  @override
  String get onboardingAllergensEmptyHint =>
      'Du kannst auch ohne Auswahl starten, aber mit ausgewählten Allergenen hebt die App sie besser hervor.';

  @override
  String onboardingAllergensSelectedCount(int count) {
    return '$count Allergene ausgewählt';
  }

  @override
  String get onboardingAllergenEuRegulated => 'EU-reguliertes Allergen';

  @override
  String get onboardingAllergenCustom => 'Eigenes Allergen';

  @override
  String get scannerTitle => 'Scannen';

  @override
  String get scannerModeBarcode => 'Barcode';

  @override
  String get scannerModeLabel => 'Etikett';

  @override
  String get scannerTapToCapture => 'Zum Aufnehmen tippen';

  @override
  String get scannerScanning => 'Scanne…';

  @override
  String get scannerOpenHistory => 'Verlauf';

  @override
  String get scannerOpenSettings => 'Einstellungen';

  @override
  String get scannerPillAuto => 'Automatischer Scanner';

  @override
  String get scannerPillBarcodeOcr => 'Barcode + OCR';

  @override
  String get scannerHintOverlay =>
      'Richte die Kamera auf den Barcode oder die Zutatenliste. Der Scanner wechselt automatisch zwischen Barcode- und OCR-Bildern.';

  @override
  String get scannerNoCamera => 'Kamera nicht verfügbar';

  @override
  String get scannerRetry => 'Erneut versuchen';

  @override
  String get scannerOpenAppSettings => 'Einstellungen öffnen';

  @override
  String get scannerCameraErrorDefault =>
      'Prüfe die Kameraberechtigung und versuche es erneut.';

  @override
  String get scannerCameraPermissionPermanent =>
      'Die Kameraberechtigung wurde dauerhaft verweigert.';

  @override
  String get scannerCameraPermissionNeeded =>
      'Für den Scanner ist die Kameraberechtigung erforderlich.';

  @override
  String get scannerCameraNone => 'Keine Kamera auf diesem Gerät verfügbar.';

  @override
  String scannerCameraInitError(String error) {
    return 'Kamera kann nicht initialisiert werden: $error';
  }

  @override
  String scannerAutoAnalysisError(String error) {
    return 'Scanner-Fehler: $error';
  }

  @override
  String get scannerNoAllergenSelected =>
      'Wähle in den Einstellungen mindestens ein Allergen, um automatische Warnungen zu aktivieren.';

  @override
  String get scannerAnalysisActive => 'Analyse aktiv für Barcode und OCR.';

  @override
  String scannerLastBarcode(String barcode) {
    return 'Letzter Barcode: $barcode';
  }

  @override
  String get scannerPointCamera =>
      'Richte die Kamera auf den Barcode oder die Zutatenliste.';

  @override
  String get resultLevelDanger => 'GEFAHR';

  @override
  String get resultLevelWarning => 'ACHTUNG';

  @override
  String get resultLevelSafe => 'WAHRSCHEINLICH SICHER';

  @override
  String get resultLevelUnknown => 'NICHT VERIFIZIERBAR';

  @override
  String get resultAllergensDetected => 'Erkannte Allergene:';

  @override
  String get resultLabelAccordion => 'Vollständiger Etikettentext';

  @override
  String get resultReportError => 'Fehler melden';

  @override
  String get resultSaveToHistory => 'Ergebnis im Verlauf gespeichert';

  @override
  String get resultReportDialogTitle => 'Problem melden';

  @override
  String get resultReportTypeLabel => 'Art der Meldung';

  @override
  String get resultReportWrongDetection => 'Falsche Erkennung';

  @override
  String get resultReportMissingAllergen => 'Allergen nicht erkannt';

  @override
  String get resultReportOcrProblem => 'OCR-Problem';

  @override
  String get resultReportOptionalNote => 'Optionale Notiz';

  @override
  String get resultReportNoteHint => 'Beschreibe, was nicht stimmt';

  @override
  String get resultReportSaveAction => 'Meldung speichern';

  @override
  String get resultReportSaved => 'Meldung lokal gespeichert';

  @override
  String get resultRecognizedPrefix => 'Erkannt:';

  @override
  String get resultFoundInPrefix => 'Gefunden in:';

  @override
  String get resultPartialMatch => 'Teiltreffer';

  @override
  String get resultFullMatch => 'Vollständiger Treffer';

  @override
  String get resultOcrContext => 'OCR-Kontext:';

  @override
  String get resultZoomedArea => 'Vergrößerter Bildausschnitt';

  @override
  String get resultFeedbackCta => 'Ergebnis falsch? Hilf uns besser zu werden';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSectionAllergens => 'Allergene';

  @override
  String get settingsManageAllergens => 'Allergene verwalten';

  @override
  String get settingsSectionAccessibility => 'Barrierefreiheit';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsTtsSpeed => 'Lesegeschwindigkeit';

  @override
  String get settingsTtsSpeedSlow => 'Langsam';

  @override
  String get settingsTtsSpeedNormal => 'Normal';

  @override
  String get settingsTtsSpeedFast => 'Schnell';

  @override
  String get settingsAutoPlay => 'Ergebnis automatisch vorlesen';

  @override
  String get settingsSectionCommunity => 'Community';

  @override
  String get settingsLeaveFeedback => 'Feedback senden';

  @override
  String get settingsLeaveFeedbackSubtitle =>
      'Hilf uns: Vorschläge, Bugs, Genauigkeit';

  @override
  String get settingsAboutAndPrivacy => 'Info & Datenschutz';

  @override
  String get settingsAboutAndPrivacySubtitle => 'Version, Lizenzen, Credits';

  @override
  String get settingsCommunityLearning => 'Zur Verbesserung beitragen';

  @override
  String get settingsCommunityLearningSubtitle =>
      'Anonyme Textfragmente senden, um neue Allergenmuster zu erkennen';

  @override
  String get settingsSectionPrivacy => 'Datenschutz';

  @override
  String get settingsRepeatOnboarding => 'Einrichtung wiederholen';

  @override
  String get settingsRepeatOnboardingSubtitle =>
      'Zurück zur Sprach- und Allergenauswahl';

  @override
  String get settingsRepeatOnboardingDialogTitle => 'Einrichtung wiederholen?';

  @override
  String get settingsRepeatOnboardingDialogBody =>
      'Du wirst Sprache und Allergene erneut auswählen.';

  @override
  String get settingsClearLocalData => 'Lokale Daten löschen';

  @override
  String get settingsClearLocalDataSubtitle =>
      'Entfernt Einstellungen, Einrichtung und eigene Allergene';

  @override
  String get settingsClearDialogTitle => 'Lokale Daten löschen?';

  @override
  String get settingsClearDialogBody =>
      'Einrichtung, Sprache, ausgewählte Allergene und eigene Allergene werden entfernt.';

  @override
  String get feedbackTitle => 'Feedback senden';

  @override
  String get feedbackAnonymousNotice =>
      'Feedback ist vollständig anonym. Wir sammeln keinen Namen, E-Mail oder Standort. Nur eine zufällige ID, um Duplikate zu vermeiden.';

  @override
  String get feedbackTypeLabel => 'Art des Feedbacks';

  @override
  String get feedbackTypeScanAccuracy => 'Scan-Genauigkeit';

  @override
  String get feedbackTypeSuggestion => 'Vorschlag';

  @override
  String get feedbackTypeBugReport => 'Bug melden';

  @override
  String get feedbackTypeGeneral => 'Allgemeiner Kommentar';

  @override
  String get feedbackWasCorrectQuestion => 'War das Scan-Ergebnis korrekt?';

  @override
  String get feedbackWasCorrectYes => 'Ja, korrekt';

  @override
  String get feedbackWasCorrectNo => 'Nein, falsch';

  @override
  String get feedbackExpectedQuestion =>
      'Wie hätte das Ergebnis lauten sollen?';

  @override
  String get feedbackExpectedDanger => 'Gefährlich';

  @override
  String get feedbackExpectedWarning => 'Achtung';

  @override
  String get feedbackExpectedSafe => 'Sicher';

  @override
  String get feedbackExpectedUnknown => 'Nicht bestimmbar';

  @override
  String get feedbackCommentLabel => 'Kommentar';

  @override
  String get feedbackCommentHintScanAccuracy =>
      'Beschreibe, was du gescannt hast und was du erwartet hast…';

  @override
  String get feedbackCommentHintSuggestion =>
      'Welche Funktion hättest du gern in der App?';

  @override
  String get feedbackCommentHintBugReport =>
      'Beschreibe das Problem. Was hast du davor getan?';

  @override
  String get feedbackCommentHintGeneral =>
      'Erzähl uns, was du von der App hältst…';

  @override
  String get feedbackSubmit => 'Feedback senden';

  @override
  String get feedbackStoreReviewCta =>
      'Wenn dir die App gefällt, hinterlasse bitte eine Bewertung im Store!';

  @override
  String get feedbackNeedComment =>
      'Bitte schreibe einen Kommentar vor dem Senden.';

  @override
  String get feedbackNeedCorrectness =>
      'Bitte gib an, ob das Scan-Ergebnis korrekt war.';

  @override
  String get feedbackBackendUnavailable =>
      'Backend nicht konfiguriert. Feedback wird gesendet, sobald verfügbar.';

  @override
  String get feedbackThankYouTitle => 'Danke!';

  @override
  String get feedbackThankYouBody =>
      'Dein Feedback hilft uns, AllergyGuard zu verbessern. Jede Meldung wird gelesen und berücksichtigt.';

  @override
  String get feedbackSubmitError =>
      'Sendefehler. Bitte später erneut versuchen.';

  @override
  String get historyTitle => 'Scan-Verlauf';

  @override
  String get historyFilterAll => 'Alle';

  @override
  String get historyFilterDanger => 'Gefahr';

  @override
  String get historyFilterWarning => 'Achtung';

  @override
  String get historyFilterSafe => 'Sicher';

  @override
  String get historyFilterUnknown => 'Unbekannt';

  @override
  String get historySearchHint => 'Produkt suchen...';

  @override
  String get historyEmpty => 'Keine Scans gespeichert';

  @override
  String get historyUnknownProduct => 'Unbekanntes Produkt';

  @override
  String get allergenSetupTitle => 'Deine Allergene';

  @override
  String get allergenSetupAddCustom => 'Eigenes Allergen hinzufügen';

  @override
  String get allergenSetupCustomHint => 'z. B. Pistazie, Kiwi usw.';

  @override
  String get allergenSetupSave => 'Speichern';

  @override
  String get allergenSetupSearchHint => 'Allergen suchen...';

  @override
  String get allergenSetupAddButton => 'Hinzufügen';

  @override
  String get allergenSetupEmpty => 'Keine Allergene gefunden';

  @override
  String get allergenSetupNameHint => 'Name des Allergens';

  @override
  String allergenSetupAddedToList(String name) {
    return '\"$name\" wurde zur Liste hinzugefügt';
  }

  @override
  String get aboutTitle => 'Info & Datenschutz';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutDisclaimerTitle => 'Wichtiger Hinweis';

  @override
  String get aboutDisclaimer =>
      'AllergyGuard ist ein Hilfsmittel, KEINE Sicherheitszertifizierung. Bei schweren Allergien immer einen Arzt konsultieren und das Etikett persönlich prüfen.';

  @override
  String get aboutPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get aboutViewPrivacy => 'Datenschutzerklärung öffnen';

  @override
  String get aboutLicense => 'MIT-Lizenz';

  @override
  String get aboutViewLicenses => 'Open-Source-Lizenzen';

  @override
  String get aboutContact => 'Kontakt';

  @override
  String get aboutAttributionTitle => 'Danksagungen';

  @override
  String get aboutAttributionOff => 'Produktdaten von Open Food Facts (ODbL)';

  @override
  String get aboutAttributionMlkit => 'OCR und Barcode via Google ML Kit';

  @override
  String get aboutAttributionSupabase => 'Backend via Supabase';

  @override
  String get aboutSectionLegal => 'Rechtliches & Datenschutz';

  @override
  String get aboutPrivacySubtitle =>
      'Wie wir mit Daten umgehen (kurz: sehr wenig)';

  @override
  String get aboutLicenseSubtitle =>
      'Open Source. Frei nutzbar, veränderbar und weitergebbar.';

  @override
  String get aboutSectionCredits => 'Credits & Danksagungen';

  @override
  String get aboutOffSubtitle =>
      'Produktdaten per Barcode — ODbL-Lizenz. openfoodfacts.org';

  @override
  String get aboutMlkitSubtitle =>
      'Text- und Barcode-Erkennung auf dem Gerät. Keine Übertragung an Google-Server.';

  @override
  String get aboutSupabaseSubtitle =>
      'Backend für Community-Sprachmuster. EU-Server mit Verschlüsselung.';

  @override
  String get aboutSectionContact => 'Kontakt';

  @override
  String get aboutRepositoryTitle => 'Quellcode';

  @override
  String aboutLaunchError(String url) {
    return '$url kann nicht geöffnet werden';
  }

  @override
  String get disclaimerShort =>
      'Hilfsmittel, keine Zertifizierung. Immer das Etikett prüfen und bei schweren Allergien einen Arzt konsultieren.';
}
