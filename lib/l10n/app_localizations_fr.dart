// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'AllergyGuard';

  @override
  String get bootstrapErrorTitle => 'Erreur de démarrage';

  @override
  String get bootstrapErrorMessage =>
      'L\'application n\'a pas pu démarrer correctement.';

  @override
  String get bootstrapErrorHint =>
      'Vérifiez le fichier .env et recompilez l\'application si vous venez de modifier la configuration.';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonNext => 'Suivant';

  @override
  String get commonStart => 'Commencer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonRepeat => 'Recommencer';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonSend => 'Envoyer';

  @override
  String get commonSending => 'Envoi…';

  @override
  String get onboardingChooseLanguageTitle => 'Choisissez votre langue';

  @override
  String get onboardingChooseLanguageIntro =>
      'AllergyGuard vous guidera dans la configuration initiale.';

  @override
  String get onboardingChooseLanguageHint =>
      'Ce choix est utilisé pour l\'interface, les noms d\'allergènes et les préférences de l\'app.';

  @override
  String get onboardingAllergensTitle => 'Sélectionnez vos allergènes';

  @override
  String get onboardingAllergensEmptyHint =>
      'Vous pouvez commencer sans sélection, mais en choisissant les allergènes l\'app les mettra mieux en évidence.';

  @override
  String onboardingAllergensSelectedCount(int count) {
    return '$count allergènes sélectionnés';
  }

  @override
  String get onboardingAllergenEuRegulated => 'Allergène réglementé UE';

  @override
  String get onboardingAllergenCustom => 'Allergène personnalisé';

  @override
  String get scannerTitle => 'Scanner';

  @override
  String get scannerModeBarcode => 'Code-barres';

  @override
  String get scannerModeLabel => 'Étiquette';

  @override
  String get scannerTapToCapture => 'Appuyez pour capturer';

  @override
  String get scannerScanning => 'Analyse en cours…';

  @override
  String get scannerOpenHistory => 'Historique';

  @override
  String get scannerOpenSettings => 'Paramètres';

  @override
  String get scannerPillAuto => 'Scanner automatique';

  @override
  String get scannerPillBarcodeOcr => 'Code-barres + OCR';

  @override
  String get scannerHintOverlay =>
      'Visez le code-barres ou la liste des ingrédients. Le scanner alterne automatiquement entre code-barres et OCR.';

  @override
  String get scannerNoCamera => 'Caméra indisponible';

  @override
  String get scannerRetry => 'Réessayer';

  @override
  String get scannerOpenAppSettings => 'Ouvrir les paramètres';

  @override
  String get scannerCameraErrorDefault =>
      'Vérifiez l\'autorisation caméra et réessayez.';

  @override
  String get scannerCameraPermissionPermanent =>
      'L\'autorisation caméra a été refusée de manière permanente.';

  @override
  String get scannerCameraPermissionNeeded =>
      'L\'autorisation caméra est nécessaire pour utiliser le scanner.';

  @override
  String get scannerCameraNone => 'Aucune caméra disponible sur cet appareil.';

  @override
  String scannerCameraInitError(String error) {
    return 'Impossible d\'initialiser la caméra : $error';
  }

  @override
  String scannerAutoAnalysisError(String error) {
    return 'Erreur du scanner : $error';
  }

  @override
  String get scannerNoAllergenSelected =>
      'Sélectionnez au moins un allergène dans les paramètres pour activer les alertes automatiques.';

  @override
  String get scannerAnalysisActive => 'Analyse active sur code-barres et OCR.';

  @override
  String scannerLastBarcode(String barcode) {
    return 'Dernier code-barres : $barcode';
  }

  @override
  String get scannerPointCamera =>
      'Pointez la caméra vers le code-barres ou la liste des ingrédients.';

  @override
  String get resultLevelDanger => 'DANGER';

  @override
  String get resultLevelWarning => 'ATTENTION';

  @override
  String get resultLevelSafe => 'PROBABLEMENT SÛR';

  @override
  String get resultLevelUnknown => 'NON VÉRIFIABLE';

  @override
  String get resultAllergensDetected => 'Allergènes détectés :';

  @override
  String get resultLabelAccordion => 'Texte complet de l\'étiquette';

  @override
  String get resultReportError => 'Signaler une erreur';

  @override
  String get resultSaveToHistory => 'Résultat enregistré dans l\'historique';

  @override
  String get resultReportDialogTitle => 'Signaler un problème';

  @override
  String get resultReportTypeLabel => 'Type de signalement';

  @override
  String get resultReportWrongDetection => 'Détection incorrecte';

  @override
  String get resultReportMissingAllergen => 'Allergène non détecté';

  @override
  String get resultReportOcrProblem => 'Problème OCR';

  @override
  String get resultReportOptionalNote => 'Note facultative';

  @override
  String get resultReportNoteHint => 'Décrivez ce qui ne va pas';

  @override
  String get resultReportSaveAction => 'Enregistrer le signalement';

  @override
  String get resultReportSaved => 'Signalement enregistré localement';

  @override
  String get resultRecognizedPrefix => 'Reconnu :';

  @override
  String get resultFoundInPrefix => 'Trouvé dans :';

  @override
  String get resultPartialMatch => 'Correspondance partielle';

  @override
  String get resultFullMatch => 'Correspondance complète';

  @override
  String get resultOcrContext => 'Contexte OCR :';

  @override
  String get resultZoomedArea => 'Zone agrandie';

  @override
  String get resultFeedbackCta => 'Résultat incorrect ? Aidez-nous à améliorer';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSectionAllergens => 'Allergènes';

  @override
  String get settingsManageAllergens => 'Gérer les allergènes';

  @override
  String get settingsSectionAccessibility => 'Accessibilité';

  @override
  String get settingsLanguage => 'Langue de l\'interface';

  @override
  String get settingsTtsSpeed => 'Vitesse de lecture';

  @override
  String get settingsTtsSpeedSlow => 'Lente';

  @override
  String get settingsTtsSpeedNormal => 'Normale';

  @override
  String get settingsTtsSpeedFast => 'Rapide';

  @override
  String get settingsAutoPlay => 'Lecture automatique du résultat';

  @override
  String get settingsSectionCommunity => 'Communauté';

  @override
  String get settingsLeaveFeedback => 'Laisser un retour';

  @override
  String get settingsLeaveFeedbackSubtitle =>
      'Aidez-nous à améliorer : suggestions, bugs, précision';

  @override
  String get settingsAboutAndPrivacy => 'À propos et confidentialité';

  @override
  String get settingsAboutAndPrivacySubtitle => 'Version, licences, crédits';

  @override
  String get settingsCommunityLearning => 'Contribuer à l\'amélioration';

  @override
  String get settingsCommunityLearningSubtitle =>
      'Envoyer des fragments de texte anonymes pour aider à reconnaître de nouveaux allergènes';

  @override
  String get settingsSectionPrivacy => 'Confidentialité';

  @override
  String get settingsRepeatOnboarding => 'Recommencer l\'onboarding';

  @override
  String get settingsRepeatOnboardingSubtitle =>
      'Revenir au choix de langue et allergènes';

  @override
  String get settingsRepeatOnboardingDialogTitle =>
      'Recommencer l\'onboarding ?';

  @override
  String get settingsRepeatOnboardingDialogBody =>
      'Vous devrez choisir à nouveau la langue et les allergènes.';

  @override
  String get settingsClearLocalData => 'Supprimer les données locales';

  @override
  String get settingsClearLocalDataSubtitle =>
      'Supprime préférences, onboarding et allergènes personnalisés';

  @override
  String get settingsClearDialogTitle => 'Supprimer les données locales ?';

  @override
  String get settingsClearDialogBody =>
      'L\'onboarding, la langue, les allergènes sélectionnés et les allergènes personnalisés seront supprimés.';

  @override
  String get feedbackTitle => 'Laisser un retour';

  @override
  String get feedbackAnonymousNotice =>
      'Le retour est totalement anonyme. Nous ne collectons ni nom, ni e-mail, ni position. Seulement un ID aléatoire pour éviter les doublons.';

  @override
  String get feedbackTypeLabel => 'Type de retour';

  @override
  String get feedbackTypeScanAccuracy => 'Précision du scan';

  @override
  String get feedbackTypeSuggestion => 'Suggestion';

  @override
  String get feedbackTypeBugReport => 'Signaler un bug';

  @override
  String get feedbackTypeGeneral => 'Commentaire général';

  @override
  String get feedbackWasCorrectQuestion =>
      'Le résultat du scan était-il correct ?';

  @override
  String get feedbackWasCorrectYes => 'Oui, correct';

  @override
  String get feedbackWasCorrectNo => 'Non, faux';

  @override
  String get feedbackExpectedQuestion =>
      'Quel aurait été le résultat correct ?';

  @override
  String get feedbackExpectedDanger => 'Dangereux';

  @override
  String get feedbackExpectedWarning => 'Attention';

  @override
  String get feedbackExpectedSafe => 'Sûr';

  @override
  String get feedbackExpectedUnknown => 'Indéterminable';

  @override
  String get feedbackCommentLabel => 'Commentaire';

  @override
  String get feedbackCommentHintScanAccuracy =>
      'Décrivez ce que vous avez scanné et ce que vous attendiez…';

  @override
  String get feedbackCommentHintSuggestion =>
      'Quelle fonctionnalité aimeriez-vous voir dans l\'app ?';

  @override
  String get feedbackCommentHintBugReport =>
      'Décrivez le problème. Que faisiez-vous avant qu\'il ne survienne ?';

  @override
  String get feedbackCommentHintGeneral =>
      'Dites-nous ce que vous pensez de l\'app…';

  @override
  String get feedbackSubmit => 'Envoyer le retour';

  @override
  String get feedbackStoreReviewCta =>
      'Si vous aimez l\'app, laissez-nous un avis sur le store !';

  @override
  String get feedbackNeedComment => 'Écrivez un commentaire avant d\'envoyer.';

  @override
  String get feedbackNeedCorrectness =>
      'Indiquez si le résultat du scan était correct.';

  @override
  String get feedbackBackendUnavailable =>
      'Backend non configuré. Le retour sera envoyé une fois disponible.';

  @override
  String get feedbackThankYouTitle => 'Merci !';

  @override
  String get feedbackThankYouBody =>
      'Votre retour nous aide à améliorer AllergyGuard. Chaque signalement est lu et pris en compte.';

  @override
  String get feedbackSubmitError => 'Erreur d\'envoi. Réessayez plus tard.';

  @override
  String get historyTitle => 'Historique des scans';

  @override
  String get historyFilterAll => 'Tous';

  @override
  String get historyFilterDanger => 'Danger';

  @override
  String get historyFilterWarning => 'Attention';

  @override
  String get historyFilterSafe => 'Sûr';

  @override
  String get historyFilterUnknown => 'Inconnu';

  @override
  String get historySearchHint => 'Rechercher un produit...';

  @override
  String get historyEmpty => 'Aucun scan enregistré';

  @override
  String get historyUnknownProduct => 'Produit inconnu';

  @override
  String get allergenSetupTitle => 'Vos allergènes';

  @override
  String get allergenSetupAddCustom => 'Ajouter un allergène personnalisé';

  @override
  String get allergenSetupCustomHint => 'Ex. pistache, kiwi, etc.';

  @override
  String get allergenSetupSave => 'Enregistrer';

  @override
  String get allergenSetupSearchHint => 'Rechercher un allergène...';

  @override
  String get allergenSetupAddButton => 'Ajouter';

  @override
  String get allergenSetupEmpty => 'Aucun allergène trouvé';

  @override
  String get allergenSetupNameHint => 'Nom de l\'allergène';

  @override
  String allergenSetupAddedToList(String name) {
    return '\"$name\" ajouté à votre liste';
  }

  @override
  String get aboutTitle => 'À propos et confidentialité';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutDisclaimerTitle => 'Avertissement important';

  @override
  String get aboutDisclaimer =>
      'AllergyGuard est un outil d\'aide, PAS une certification de sécurité. En cas d\'allergie grave, consultez toujours un médecin et vérifiez personnellement l\'étiquette.';

  @override
  String get aboutPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get aboutViewPrivacy => 'Ouvrir la politique de confidentialité';

  @override
  String get aboutLicense => 'Licence MIT';

  @override
  String get aboutViewLicenses => 'Licences open source';

  @override
  String get aboutContact => 'Contact';

  @override
  String get aboutAttributionTitle => 'Crédits';

  @override
  String get aboutAttributionOff =>
      'Données produit via Open Food Facts (ODbL)';

  @override
  String get aboutAttributionMlkit => 'OCR et code-barres via Google ML Kit';

  @override
  String get aboutAttributionSupabase => 'Backend via Supabase';

  @override
  String get aboutSectionLegal => 'Mentions légales et confidentialité';

  @override
  String get aboutPrivacySubtitle =>
      'Comment nous gérons les données (en bref : très peu)';

  @override
  String get aboutLicenseSubtitle =>
      'Open source. Libre d\'utilisation, de modification et de redistribution.';

  @override
  String get aboutSectionCredits => 'Crédits et remerciements';

  @override
  String get aboutOffSubtitle =>
      'Données produit via code-barres — licence ODbL. openfoodfacts.org';

  @override
  String get aboutMlkitSubtitle =>
      'Reconnaissance de texte et codes-barres sur l\'appareil. Rien n\'est envoyé aux serveurs Google.';

  @override
  String get aboutSupabaseSubtitle =>
      'Backend pour les motifs linguistiques de la communauté. Serveurs UE avec chiffrement.';

  @override
  String get aboutSectionContact => 'Contact';

  @override
  String get aboutRepositoryTitle => 'Code source';

  @override
  String aboutLaunchError(String url) {
    return 'Impossible d\'ouvrir $url';
  }

  @override
  String get disclaimerShort =>
      'Outil d\'aide, non une certification. Vérifiez toujours l\'étiquette et consultez un médecin pour les allergies graves.';
}
