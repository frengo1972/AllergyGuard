// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'AllergyGuard';

  @override
  String get bootstrapErrorTitle => '起動エラー';

  @override
  String get bootstrapErrorMessage => 'アプリを正しく起動できませんでした。';

  @override
  String get bootstrapErrorHint => '設定を変更した場合は、.env ファイルを確認してアプリを再ビルドしてください。';

  @override
  String get commonBack => '戻る';

  @override
  String get commonNext => '次へ';

  @override
  String get commonStart => '開始';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '削除';

  @override
  String get commonRepeat => '繰り返す';

  @override
  String get commonClose => '閉じる';

  @override
  String get commonSend => '送信';

  @override
  String get commonSending => '送信中…';

  @override
  String get onboardingChooseLanguageTitle => '言語を選択';

  @override
  String get onboardingChooseLanguageIntro => 'AllergyGuard が初期設定をご案内します。';

  @override
  String get onboardingChooseLanguageHint => 'この選択は画面表示、アレルゲン名、アプリ設定に使用されます。';

  @override
  String get onboardingAllergensTitle => 'アレルゲンを選択';

  @override
  String get onboardingAllergensEmptyHint =>
      '選択せずに始められますが、アレルゲンを選択するとアプリがよりよく強調表示します。';

  @override
  String onboardingAllergensSelectedCount(int count) {
    return '$count 個のアレルゲンを選択中';
  }

  @override
  String get onboardingAllergenEuRegulated => 'EU 規制対象アレルゲン';

  @override
  String get onboardingAllergenCustom => 'カスタムアレルゲン';

  @override
  String get scannerTitle => 'スキャン';

  @override
  String get scannerModeBarcode => 'バーコード';

  @override
  String get scannerModeLabel => 'ラベル';

  @override
  String get scannerTapToCapture => 'タップして撮影';

  @override
  String get scannerScanning => 'スキャン中…';

  @override
  String get scannerOpenHistory => '履歴';

  @override
  String get scannerOpenSettings => '設定';

  @override
  String get scannerPillAuto => '自動スキャン';

  @override
  String get scannerPillBarcodeOcr => 'バーコード + OCR';

  @override
  String get scannerHintOverlay =>
      'カメラをバーコードまたは原材料リストに向けてください。スキャナーはバーコードとOCRを自動的に切り替えます。';

  @override
  String get scannerNoCamera => 'カメラを利用できません';

  @override
  String get scannerRetry => '再試行';

  @override
  String get scannerOpenAppSettings => '設定を開く';

  @override
  String get scannerCameraErrorDefault => 'カメラの権限を確認してからもう一度お試しください。';

  @override
  String get scannerCameraPermissionPermanent => 'カメラの権限が完全に拒否されています。';

  @override
  String get scannerCameraPermissionNeeded => 'スキャナーを使用するにはカメラの権限が必要です。';

  @override
  String get scannerCameraNone => 'この端末では利用可能なカメラがありません。';

  @override
  String scannerCameraInitError(String error) {
    return 'カメラを初期化できません: $error';
  }

  @override
  String scannerAutoAnalysisError(String error) {
    return 'スキャナーのエラー: $error';
  }

  @override
  String get scannerNoAllergenSelected =>
      '自動通知を有効にするには、設定で少なくとも1つのアレルゲンを選択してください。';

  @override
  String get scannerAnalysisActive => 'バーコードとOCRの解析を実行中です。';

  @override
  String scannerLastBarcode(String barcode) {
    return '直近のバーコード: $barcode';
  }

  @override
  String get scannerPointCamera => 'バーコードまたは原材料リストにカメラを向けてください。';

  @override
  String get resultLevelDanger => '危険';

  @override
  String get resultLevelWarning => '注意';

  @override
  String get resultLevelSafe => 'おそらく安全';

  @override
  String get resultLevelUnknown => '確認不可';

  @override
  String get resultAllergensDetected => '検出されたアレルゲン:';

  @override
  String get resultLabelAccordion => 'ラベル全文';

  @override
  String get resultReportError => 'エラーを報告';

  @override
  String get resultSaveToHistory => '結果を履歴に保存しました';

  @override
  String get resultReportDialogTitle => '問題を報告';

  @override
  String get resultReportTypeLabel => '報告の種類';

  @override
  String get resultReportWrongDetection => '誤検出';

  @override
  String get resultReportMissingAllergen => 'アレルゲンが検出されない';

  @override
  String get resultReportOcrProblem => 'OCR の問題';

  @override
  String get resultReportOptionalNote => '任意のメモ';

  @override
  String get resultReportNoteHint => '気になる点を書いてください';

  @override
  String get resultReportSaveAction => '報告を保存';

  @override
  String get resultReportSaved => '報告をローカルに保存しました';

  @override
  String get resultRecognizedPrefix => '認識:';

  @override
  String get resultFoundInPrefix => '見つかった場所:';

  @override
  String get resultPartialMatch => '部分一致';

  @override
  String get resultFullMatch => '完全一致';

  @override
  String get resultOcrContext => 'OCR コンテキスト:';

  @override
  String get resultZoomedArea => '拡大表示';

  @override
  String get resultFeedbackCta => '結果は間違っていましたか？改善にご協力ください';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsSectionAllergens => 'アレルゲン';

  @override
  String get settingsManageAllergens => 'アレルゲンを管理';

  @override
  String get settingsSectionAccessibility => 'アクセシビリティ';

  @override
  String get settingsLanguage => 'インターフェース言語';

  @override
  String get settingsTtsSpeed => '読み上げ速度';

  @override
  String get settingsTtsSpeedSlow => '遅い';

  @override
  String get settingsTtsSpeedNormal => '普通';

  @override
  String get settingsTtsSpeedFast => '速い';

  @override
  String get settingsAutoPlay => '結果の自動読み上げ';

  @override
  String get settingsSectionCommunity => 'コミュニティ';

  @override
  String get settingsLeaveFeedback => 'フィードバックを送る';

  @override
  String get settingsLeaveFeedbackSubtitle => '改善にご協力を：提案、バグ、精度';

  @override
  String get settingsAboutAndPrivacy => '概要とプライバシー';

  @override
  String get settingsAboutAndPrivacySubtitle => 'バージョン、ライセンス、謝辞';

  @override
  String get settingsCommunityLearning => '改善に貢献する';

  @override
  String get settingsCommunityLearningSubtitle =>
      '新しいアレルゲンパターンの認識を助けるために匿名のテキストを送信する';

  @override
  String get settingsSectionPrivacy => 'プライバシー';

  @override
  String get settingsRepeatOnboarding => 'オンボーディングをやり直す';

  @override
  String get settingsRepeatOnboardingSubtitle => '言語とアレルゲンの選択をやり直します';

  @override
  String get settingsRepeatOnboardingDialogTitle => 'オンボーディングをやり直しますか？';

  @override
  String get settingsRepeatOnboardingDialogBody => '言語とアレルゲンの選択を再度求められます。';

  @override
  String get settingsClearLocalData => 'ローカルデータを削除';

  @override
  String get settingsClearLocalDataSubtitle => '設定、オンボーディング、カスタムアレルゲンを削除します';

  @override
  String get settingsClearDialogTitle => 'ローカルデータを削除しますか？';

  @override
  String get settingsClearDialogBody =>
      'オンボーディング、言語、選択したアレルゲン、カスタムアレルゲンが削除されます。';

  @override
  String get feedbackTitle => 'フィードバックを送る';

  @override
  String get feedbackAnonymousNotice =>
      'フィードバックは完全に匿名です。名前、メール、位置情報は収集しません。重複を避けるためランダム ID のみ使用します。';

  @override
  String get feedbackTypeLabel => 'フィードバックの種類';

  @override
  String get feedbackTypeScanAccuracy => 'スキャン精度';

  @override
  String get feedbackTypeSuggestion => '提案';

  @override
  String get feedbackTypeBugReport => 'バグ報告';

  @override
  String get feedbackTypeGeneral => '一般的なコメント';

  @override
  String get feedbackWasCorrectQuestion => 'スキャン結果は正しかったですか？';

  @override
  String get feedbackWasCorrectYes => 'はい、正しい';

  @override
  String get feedbackWasCorrectNo => 'いいえ、間違い';

  @override
  String get feedbackExpectedQuestion => '正しい結果は何であるべきでしたか？';

  @override
  String get feedbackExpectedDanger => '危険';

  @override
  String get feedbackExpectedWarning => '注意';

  @override
  String get feedbackExpectedSafe => '安全';

  @override
  String get feedbackExpectedUnknown => '判定不能';

  @override
  String get feedbackCommentLabel => 'コメント';

  @override
  String get feedbackCommentHintScanAccuracy => 'スキャンした内容と期待した結果を記述してください…';

  @override
  String get feedbackCommentHintSuggestion => 'アプリにどんな機能を追加してほしいですか？';

  @override
  String get feedbackCommentHintBugReport => '発生した問題を記述してください。発生前に何をしていましたか？';

  @override
  String get feedbackCommentHintGeneral => 'アプリについてご意見をお聞かせください…';

  @override
  String get feedbackSubmit => 'フィードバックを送信';

  @override
  String get feedbackStoreReviewCta => 'アプリを気に入ったら、ストアでレビューをお願いします！';

  @override
  String get feedbackNeedComment => '送信前にコメントを書いてください。';

  @override
  String get feedbackNeedCorrectness => 'スキャン結果が正しかったかどうか示してください。';

  @override
  String get feedbackBackendUnavailable => 'バックエンドが構成されていません。利用可能になり次第送信されます。';

  @override
  String get feedbackThankYouTitle => 'ありがとうございます！';

  @override
  String get feedbackThankYouBody =>
      'あなたのフィードバックは AllergyGuard の改善に役立ちます。すべての報告に目を通しています。';

  @override
  String get feedbackSubmitError => '送信エラー。後でもう一度お試しください。';

  @override
  String get historyTitle => 'スキャン履歴';

  @override
  String get historyFilterAll => 'すべて';

  @override
  String get historyFilterDanger => '危険';

  @override
  String get historyFilterWarning => '注意';

  @override
  String get historyFilterSafe => '安全';

  @override
  String get historyFilterUnknown => '不明';

  @override
  String get historySearchHint => '製品を検索...';

  @override
  String get historyEmpty => '保存されたスキャンはありません';

  @override
  String get historyUnknownProduct => '不明な製品';

  @override
  String get allergenSetupTitle => 'あなたのアレルゲン';

  @override
  String get allergenSetupAddCustom => 'カスタムアレルゲンを追加';

  @override
  String get allergenSetupCustomHint => '例：ピスタチオ、キウイなど';

  @override
  String get allergenSetupSave => '保存';

  @override
  String get allergenSetupSearchHint => 'アレルゲンを検索...';

  @override
  String get allergenSetupAddButton => '追加';

  @override
  String get allergenSetupEmpty => 'アレルゲンが見つかりません';

  @override
  String get allergenSetupNameHint => 'アレルゲン名';

  @override
  String allergenSetupAddedToList(String name) {
    return '「$name」をリストに追加しました';
  }

  @override
  String get aboutTitle => '概要とプライバシー';

  @override
  String get aboutVersion => 'バージョン';

  @override
  String get aboutDisclaimerTitle => '重要なお知らせ';

  @override
  String get aboutDisclaimer =>
      'AllergyGuard はサポートツールであり、安全認証ではありません。重篤なアレルギーの場合は必ず医師に相談し、ラベルをご自身で確認してください。';

  @override
  String get aboutPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get aboutViewPrivacy => 'プライバシーポリシーを開く';

  @override
  String get aboutLicense => 'MIT ライセンス';

  @override
  String get aboutViewLicenses => 'オープンソースライセンス';

  @override
  String get aboutContact => '連絡先';

  @override
  String get aboutAttributionTitle => '謝辞';

  @override
  String get aboutAttributionOff => '製品データ提供: Open Food Facts (ODbL)';

  @override
  String get aboutAttributionMlkit => 'OCR とバーコード: Google ML Kit';

  @override
  String get aboutAttributionSupabase => 'バックエンド: Supabase';

  @override
  String get aboutSectionLegal => '法的事項とプライバシー';

  @override
  String get aboutPrivacySubtitle => 'データの取り扱い（要するに：ほとんど収集しません）';

  @override
  String get aboutLicenseSubtitle => 'オープンソース。利用、変更、再配布は自由です。';

  @override
  String get aboutSectionCredits => 'クレジットと謝辞';

  @override
  String get aboutOffSubtitle => 'バーコード経由の製品データ — ODbL ライセンス。openfoodfacts.org';

  @override
  String get aboutMlkitSubtitle => '端末上でのテキスト/バーコード認識。Google サーバーへは送信されません。';

  @override
  String get aboutSupabaseSubtitle => 'コミュニティ言語パターン用のバックエンド。暗号化された EU サーバー。';

  @override
  String get aboutSectionContact => 'お問い合わせ';

  @override
  String get aboutRepositoryTitle => 'ソースコード';

  @override
  String aboutLaunchError(String url) {
    return '$url を開けません';
  }

  @override
  String get disclaimerShort =>
      'サポートツールであり認証ではありません。必ずラベルを確認し、重篤なアレルギーは医師に相談してください。';
}
