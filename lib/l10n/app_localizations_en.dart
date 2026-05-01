// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AllergyGuard';

  @override
  String get bootstrapErrorTitle => 'Startup error';

  @override
  String get bootstrapErrorMessage => 'The app failed to start correctly.';

  @override
  String get bootstrapErrorHint =>
      'Check the .env file and rebuild the app if you just changed the configuration.';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonStart => 'Start';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRepeat => 'Repeat';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSend => 'Send';

  @override
  String get commonSending => 'Sending...';

  @override
  String get onboardingChooseLanguageTitle => 'Choose your language';

  @override
  String get onboardingChooseLanguageIntro =>
      'AllergyGuard will guide you through the initial setup.';

  @override
  String get onboardingChooseLanguageHint =>
      'This choice is used for the interface, allergen names, and app preferences.';

  @override
  String get onboardingAllergensTitle => 'Select your allergens';

  @override
  String get onboardingAllergensEmptyHint =>
      'You can start without selections, but choosing your allergens helps the app highlight them better.';

  @override
  String onboardingAllergensSelectedCount(int count) {
    return '$count allergens selected';
  }

  @override
  String get onboardingAllergenEuRegulated => 'EU regulated allergen';

  @override
  String get onboardingAllergenCustom => 'Custom allergen';

  @override
  String get scannerTitle => 'Scan';

  @override
  String get scannerModeBarcode => 'Barcode';

  @override
  String get scannerModeLabel => 'Label';

  @override
  String get scannerTapToCapture => 'Tap to capture';

  @override
  String get scannerScanning => 'Scanning...';

  @override
  String get scannerOpenHistory => 'History';

  @override
  String get scannerOpenSettings => 'Settings';

  @override
  String get scannerPillAuto => 'Automatic scanner';

  @override
  String get scannerPillBarcodeOcr => 'Barcode + OCR';

  @override
  String get scannerHintOverlay =>
      'Point the camera at the barcode or at the ingredient list. The scanner alternates between barcode and OCR frames automatically.';

  @override
  String get scannerNoCamera => 'Camera not available';

  @override
  String get scannerRetry => 'Retry';

  @override
  String get scannerOpenAppSettings => 'Open settings';

  @override
  String get scannerCameraErrorDefault =>
      'Check the camera permission and try again.';

  @override
  String get scannerCameraPermissionPermanent =>
      'Camera permission has been permanently denied.';

  @override
  String get scannerCameraPermissionNeeded =>
      'Camera permission is required to use the scanner.';

  @override
  String get scannerCameraNone => 'No camera available on this device.';

  @override
  String scannerCameraInitError(String error) {
    return 'Cannot initialize the camera: $error';
  }

  @override
  String scannerAutoAnalysisError(String error) {
    return 'Scanner error: $error';
  }

  @override
  String get scannerNoAllergenSelected =>
      'Select at least one allergen in settings to enable automatic alerts.';

  @override
  String get scannerAnalysisActive => 'Analysis active on barcode and OCR.';

  @override
  String scannerLastBarcode(String barcode) {
    return 'Last barcode: $barcode';
  }

  @override
  String get scannerPointCamera =>
      'Aim the camera at the barcode or at the ingredient list.';

  @override
  String get resultLevelDanger => 'DANGER';

  @override
  String get resultLevelWarning => 'WARNING';

  @override
  String get resultLevelSafe => 'LIKELY SAFE';

  @override
  String get resultLevelUnknown => 'UNVERIFIABLE';

  @override
  String get resultAllergensDetected => 'Allergens detected:';

  @override
  String get resultLabelAccordion => 'Full label text';

  @override
  String get resultReportError => 'Report error';

  @override
  String get resultSaveToHistory => 'Result saved to history';

  @override
  String get resultReportDialogTitle => 'Report a problem';

  @override
  String get resultReportTypeLabel => 'Report type';

  @override
  String get resultReportWrongDetection => 'Wrong detection';

  @override
  String get resultReportMissingAllergen => 'Allergen not detected';

  @override
  String get resultReportOcrProblem => 'OCR problem';

  @override
  String get resultReportOptionalNote => 'Optional note';

  @override
  String get resultReportNoteHint => 'Describe what seems wrong';

  @override
  String get resultReportSaveAction => 'Save report';

  @override
  String get resultReportSaved => 'Report saved locally';

  @override
  String get resultRecognizedPrefix => 'Recognized:';

  @override
  String get resultFoundInPrefix => 'Found in:';

  @override
  String get resultPartialMatch => 'Partial match';

  @override
  String get resultFullMatch => 'Full match';

  @override
  String get resultOcrContext => 'OCR context:';

  @override
  String get resultZoomedArea => 'Zoomed image area';

  @override
  String get resultFeedbackCta => 'Was the result wrong? Help us improve';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAllergens => 'Allergens';

  @override
  String get settingsManageAllergens => 'Manage allergens';

  @override
  String get settingsSectionAccessibility => 'Accessibility';

  @override
  String get settingsLanguage => 'Interface language';

  @override
  String get settingsTtsSpeed => 'Reading speed';

  @override
  String get settingsTtsSpeedSlow => 'Slow';

  @override
  String get settingsTtsSpeedNormal => 'Normal';

  @override
  String get settingsTtsSpeedFast => 'Fast';

  @override
  String get settingsAutoPlay => 'Auto-read result';

  @override
  String get settingsSectionCommunity => 'Community';

  @override
  String get settingsLeaveFeedback => 'Leave feedback';

  @override
  String get settingsLeaveFeedbackSubtitle =>
      'Help us improve: suggestions, bugs, accuracy';

  @override
  String get settingsAboutAndPrivacy => 'About and privacy';

  @override
  String get settingsAboutAndPrivacySubtitle =>
      'Version, licenses, attributions';

  @override
  String get settingsCommunityLearning => 'Contribute to improvement';

  @override
  String get settingsCommunityLearningSubtitle =>
      'Send anonymous text fragments to help recognize new allergen patterns';

  @override
  String get settingsSectionPrivacy => 'Privacy';

  @override
  String get settingsRepeatOnboarding => 'Repeat onboarding';

  @override
  String get settingsRepeatOnboardingSubtitle =>
      'Return the app to the language and allergen choice';

  @override
  String get settingsRepeatOnboardingDialogTitle => 'Repeat onboarding?';

  @override
  String get settingsRepeatOnboardingDialogBody =>
      'You will be asked to choose language and allergens again.';

  @override
  String get settingsClearLocalData => 'Delete local data';

  @override
  String get settingsClearLocalDataSubtitle =>
      'Removes preferences, onboarding and custom allergens';

  @override
  String get settingsClearDialogTitle => 'Delete local data?';

  @override
  String get settingsClearDialogBody =>
      'Onboarding, language, selected allergens and custom allergens will be removed.';

  @override
  String get feedbackTitle => 'Leave feedback';

  @override
  String get feedbackAnonymousNotice =>
      'Feedback is fully anonymous. We don\'t collect name, email or location. Only a random ID to avoid duplicates.';

  @override
  String get feedbackTypeLabel => 'Feedback type';

  @override
  String get feedbackTypeScanAccuracy => 'Scan accuracy';

  @override
  String get feedbackTypeSuggestion => 'Suggestion';

  @override
  String get feedbackTypeBugReport => 'Report bug';

  @override
  String get feedbackTypeGeneral => 'General comment';

  @override
  String get feedbackWasCorrectQuestion => 'Was the scan result correct?';

  @override
  String get feedbackWasCorrectYes => 'Yes, correct';

  @override
  String get feedbackWasCorrectNo => 'No, wrong';

  @override
  String get feedbackExpectedQuestion =>
      'What should the correct result have been?';

  @override
  String get feedbackExpectedDanger => 'Dangerous';

  @override
  String get feedbackExpectedWarning => 'Warning';

  @override
  String get feedbackExpectedSafe => 'Safe';

  @override
  String get feedbackExpectedUnknown => 'Not determinable';

  @override
  String get feedbackCommentLabel => 'Comment';

  @override
  String get feedbackCommentHintScanAccuracy =>
      'Describe what you scanned and what you expected...';

  @override
  String get feedbackCommentHintSuggestion =>
      'Which feature would you like to see in the app?';

  @override
  String get feedbackCommentHintBugReport =>
      'Describe the problem. What were you doing when it happened?';

  @override
  String get feedbackCommentHintGeneral =>
      'Tell us what you think about the app...';

  @override
  String get feedbackSubmit => 'Send feedback';

  @override
  String get feedbackStoreReviewCta =>
      'If you like the app, please leave a review on the store!';

  @override
  String get feedbackNeedComment => 'Please write a comment before sending.';

  @override
  String get feedbackNeedCorrectness =>
      'Please indicate whether the scan result was correct.';

  @override
  String get feedbackBackendUnavailable =>
      'Backend not configured. Feedback will be sent when available.';

  @override
  String get feedbackThankYouTitle => 'Thank you!';

  @override
  String get feedbackThankYouBody =>
      'Your feedback helps us improve AllergyGuard. Every report is read and considered.';

  @override
  String get feedbackSubmitError => 'Submit error. Please try again later.';

  @override
  String get historyTitle => 'Scan history';

  @override
  String get historyFilterAll => 'All';

  @override
  String get historyFilterDanger => 'Danger';

  @override
  String get historyFilterWarning => 'Warning';

  @override
  String get historyFilterSafe => 'Safe';

  @override
  String get historyFilterUnknown => 'Unknown';

  @override
  String get historySearchHint => 'Search product...';

  @override
  String get historyEmpty => 'No scans saved';

  @override
  String get historyUnknownProduct => 'Unknown product';

  @override
  String get allergenSetupTitle => 'Your allergens';

  @override
  String get allergenSetupAddCustom => 'Add custom allergen';

  @override
  String get allergenSetupCustomHint => 'E.g. pistachio, kiwi, etc.';

  @override
  String get allergenSetupSave => 'Save';

  @override
  String get allergenSetupSearchHint => 'Search allergen...';

  @override
  String get allergenSetupAddButton => 'Add';

  @override
  String get allergenSetupEmpty => 'No allergens found';

  @override
  String get allergenSetupNameHint => 'Allergen name';

  @override
  String allergenSetupAddedToList(String name) {
    return '\"$name\" added to your list';
  }

  @override
  String get aboutTitle => 'About and privacy';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutDisclaimerTitle => 'Important notice';

  @override
  String get aboutDisclaimer =>
      'AllergyGuard is a support tool, NOT a safety certification. For severe allergies, always consult a doctor and personally verify the label.';

  @override
  String get aboutPrivacyPolicy => 'Privacy Policy';

  @override
  String get aboutViewPrivacy => 'Open privacy policy';

  @override
  String get aboutLicense => 'MIT License';

  @override
  String get aboutViewLicenses => 'Open source licenses';

  @override
  String get aboutContact => 'Contact';

  @override
  String get aboutAttributionTitle => 'Attributions';

  @override
  String get aboutAttributionOff => 'Product data from Open Food Facts (ODbL)';

  @override
  String get aboutAttributionMlkit => 'OCR and barcode via Google ML Kit';

  @override
  String get aboutAttributionSupabase => 'Backend via Supabase';

  @override
  String get aboutSectionLegal => 'Legal & privacy';

  @override
  String get aboutPrivacySubtitle =>
      'How we handle data (in short: very little)';

  @override
  String get aboutLicenseSubtitle =>
      'Open source. Free to use, modify and redistribute.';

  @override
  String get aboutSectionCredits => 'Credits & attributions';

  @override
  String get aboutOffSubtitle =>
      'Product data via barcode — ODbL license. openfoodfacts.org';

  @override
  String get aboutMlkitSubtitle =>
      'On-device text and barcode recognition. Nothing sent to Google servers.';

  @override
  String get aboutSupabaseSubtitle =>
      'Backend for community language patterns. EU servers with encryption.';

  @override
  String get aboutSectionContact => 'Contact';

  @override
  String get aboutRepositoryTitle => 'Source code';

  @override
  String aboutLaunchError(String url) {
    return 'Cannot open $url';
  }

  @override
  String get disclaimerShort =>
      'Support tool, not a certification. Always verify the label and consult a doctor for serious allergies.';
}
