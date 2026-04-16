// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'AllergyGuard';

  @override
  String get bootstrapErrorTitle => '启动错误';

  @override
  String get bootstrapErrorMessage => '应用无法正常启动。';

  @override
  String get bootstrapErrorHint => '如果您刚刚修改了配置，请检查 .env 文件并重新编译应用。';

  @override
  String get commonBack => '返回';

  @override
  String get commonNext => '下一步';

  @override
  String get commonStart => '开始';

  @override
  String get commonCancel => '取消';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '删除';

  @override
  String get commonRepeat => '重复';

  @override
  String get commonClose => '关闭';

  @override
  String get commonSend => '发送';

  @override
  String get commonSending => '发送中…';

  @override
  String get onboardingChooseLanguageTitle => '选择语言';

  @override
  String get onboardingChooseLanguageIntro => 'AllergyGuard 将引导您完成初始设置。';

  @override
  String get onboardingChooseLanguageHint => '此选择用于界面、过敏原名称和应用偏好。';

  @override
  String get onboardingAllergensTitle => '选择您的过敏原';

  @override
  String get onboardingAllergensEmptyHint => '您可以不选择直接开始，但选择过敏原后应用可以更好地突出显示它们。';

  @override
  String onboardingAllergensSelectedCount(int count) {
    return '已选 $count 种过敏原';
  }

  @override
  String get onboardingAllergenEuRegulated => '欧盟监管过敏原';

  @override
  String get onboardingAllergenCustom => '自定义过敏原';

  @override
  String get scannerTitle => '扫描';

  @override
  String get scannerModeBarcode => '条形码';

  @override
  String get scannerModeLabel => '标签';

  @override
  String get scannerTapToCapture => '点击拍照';

  @override
  String get scannerScanning => '扫描中…';

  @override
  String get scannerOpenHistory => '历史记录';

  @override
  String get scannerOpenSettings => '设置';

  @override
  String get scannerPillAuto => '自动扫描';

  @override
  String get scannerPillBarcodeOcr => '条形码 + OCR';

  @override
  String get scannerHintOverlay => '将相机对准条形码或配料表。扫描器会自动交替使用条形码和 OCR。';

  @override
  String get scannerNoCamera => '相机不可用';

  @override
  String get scannerRetry => '重试';

  @override
  String get scannerOpenAppSettings => '打开设置';

  @override
  String get scannerCameraErrorDefault => '请检查相机权限并重试。';

  @override
  String get scannerCameraPermissionPermanent => '相机权限已被永久拒绝。';

  @override
  String get scannerCameraPermissionNeeded => '需要相机权限才能使用扫描器。';

  @override
  String get scannerCameraNone => '设备上没有可用的相机。';

  @override
  String scannerCameraInitError(String error) {
    return '无法初始化相机：$error';
  }

  @override
  String scannerAutoAnalysisError(String error) {
    return '扫描器错误：$error';
  }

  @override
  String get scannerNoAllergenSelected => '请在设置中至少选择一种过敏原，以启用自动提醒。';

  @override
  String get scannerAnalysisActive => '条形码与 OCR 分析已启用。';

  @override
  String scannerLastBarcode(String barcode) {
    return '最近条形码：$barcode';
  }

  @override
  String get scannerPointCamera => '请将相机对准条形码或配料表。';

  @override
  String get resultLevelDanger => '危险';

  @override
  String get resultLevelWarning => '注意';

  @override
  String get resultLevelSafe => '可能安全';

  @override
  String get resultLevelUnknown => '无法确认';

  @override
  String get resultAllergensDetected => '检测到的过敏原：';

  @override
  String get resultLabelAccordion => '完整标签文本';

  @override
  String get resultReportError => '报告错误';

  @override
  String get resultSaveToHistory => '结果已保存到历史';

  @override
  String get resultReportDialogTitle => '报告问题';

  @override
  String get resultReportTypeLabel => '报告类型';

  @override
  String get resultReportWrongDetection => '识别错误';

  @override
  String get resultReportMissingAllergen => '未识别到过敏原';

  @override
  String get resultReportOcrProblem => 'OCR 问题';

  @override
  String get resultReportOptionalNote => '可选备注';

  @override
  String get resultReportNoteHint => '描述您认为哪里不对';

  @override
  String get resultReportSaveAction => '保存报告';

  @override
  String get resultReportSaved => '报告已本地保存';

  @override
  String get resultRecognizedPrefix => '已识别：';

  @override
  String get resultFoundInPrefix => '出现于：';

  @override
  String get resultPartialMatch => '部分匹配';

  @override
  String get resultFullMatch => '完全匹配';

  @override
  String get resultOcrContext => 'OCR 上下文：';

  @override
  String get resultZoomedArea => '放大区域';

  @override
  String get resultFeedbackCta => '结果不对？帮助我们改进';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSectionAllergens => '过敏原';

  @override
  String get settingsManageAllergens => '管理过敏原';

  @override
  String get settingsSectionAccessibility => '辅助功能';

  @override
  String get settingsLanguage => '界面语言';

  @override
  String get settingsTtsSpeed => '朗读速度';

  @override
  String get settingsTtsSpeedSlow => '慢速';

  @override
  String get settingsTtsSpeedNormal => '正常';

  @override
  String get settingsTtsSpeedFast => '快速';

  @override
  String get settingsAutoPlay => '自动朗读结果';

  @override
  String get settingsSectionCommunity => '社区';

  @override
  String get settingsLeaveFeedback => '留下反馈';

  @override
  String get settingsLeaveFeedbackSubtitle => '帮我们改进：建议、错误、准确性';

  @override
  String get settingsAboutAndPrivacy => '关于与隐私';

  @override
  String get settingsAboutAndPrivacySubtitle => '版本、许可、致谢';

  @override
  String get settingsCommunityLearning => '贡献改进';

  @override
  String get settingsCommunityLearningSubtitle => '发送匿名文本片段以帮助识别新的过敏原模式';

  @override
  String get settingsSectionPrivacy => '隐私';

  @override
  String get settingsRepeatOnboarding => '重新引导';

  @override
  String get settingsRepeatOnboardingSubtitle => '返回到语言和过敏原选择';

  @override
  String get settingsRepeatOnboardingDialogTitle => '重新引导？';

  @override
  String get settingsRepeatOnboardingDialogBody => '将要求您再次选择语言和过敏原。';

  @override
  String get settingsClearLocalData => '删除本地数据';

  @override
  String get settingsClearLocalDataSubtitle => '移除偏好、引导和自定义过敏原';

  @override
  String get settingsClearDialogTitle => '删除本地数据？';

  @override
  String get settingsClearDialogBody => '将移除引导、语言、所选过敏原和自定义过敏原。';

  @override
  String get feedbackTitle => '留下反馈';

  @override
  String get feedbackAnonymousNotice => '反馈完全匿名。我们不收集姓名、邮箱或位置。仅使用随机 ID 以避免重复。';

  @override
  String get feedbackTypeLabel => '反馈类型';

  @override
  String get feedbackTypeScanAccuracy => '扫描准确性';

  @override
  String get feedbackTypeSuggestion => '建议';

  @override
  String get feedbackTypeBugReport => '报告错误';

  @override
  String get feedbackTypeGeneral => '一般评论';

  @override
  String get feedbackWasCorrectQuestion => '扫描结果正确吗？';

  @override
  String get feedbackWasCorrectYes => '是，正确';

  @override
  String get feedbackWasCorrectNo => '否，错误';

  @override
  String get feedbackExpectedQuestion => '正确的结果应该是什么？';

  @override
  String get feedbackExpectedDanger => '危险';

  @override
  String get feedbackExpectedWarning => '注意';

  @override
  String get feedbackExpectedSafe => '安全';

  @override
  String get feedbackExpectedUnknown => '无法确定';

  @override
  String get feedbackCommentLabel => '评论';

  @override
  String get feedbackCommentHintScanAccuracy => '描述您扫描的内容以及您预期的结果…';

  @override
  String get feedbackCommentHintSuggestion => '您希望应用中有哪些功能？';

  @override
  String get feedbackCommentHintBugReport => '描述遇到的问题。发生前您在做什么？';

  @override
  String get feedbackCommentHintGeneral => '告诉我们您对应用的看法…';

  @override
  String get feedbackSubmit => '发送反馈';

  @override
  String get feedbackStoreReviewCta => '如果您喜欢本应用，请在应用商店留下评价！';

  @override
  String get feedbackNeedComment => '发送前请写评论。';

  @override
  String get feedbackNeedCorrectness => '请指明扫描结果是否正确。';

  @override
  String get feedbackBackendUnavailable => '后端未配置。反馈将在可用时发送。';

  @override
  String get feedbackThankYouTitle => '谢谢！';

  @override
  String get feedbackThankYouBody => '您的反馈帮助我们改进 AllergyGuard。每条反馈都会被阅读和考虑。';

  @override
  String get feedbackSubmitError => '发送错误。请稍后再试。';

  @override
  String get historyTitle => '扫描历史';

  @override
  String get historyFilterAll => '全部';

  @override
  String get historyFilterDanger => '危险';

  @override
  String get historyFilterWarning => '注意';

  @override
  String get historyFilterSafe => '安全';

  @override
  String get historyFilterUnknown => '未知';

  @override
  String get historySearchHint => '搜索产品...';

  @override
  String get historyEmpty => '没有已保存的扫描';

  @override
  String get historyUnknownProduct => '未知产品';

  @override
  String get allergenSetupTitle => '您的过敏原';

  @override
  String get allergenSetupAddCustom => '添加自定义过敏原';

  @override
  String get allergenSetupCustomHint => '例如：开心果、猕猴桃等。';

  @override
  String get allergenSetupSave => '保存';

  @override
  String get allergenSetupSearchHint => '搜索过敏原...';

  @override
  String get allergenSetupAddButton => '添加';

  @override
  String get allergenSetupEmpty => '未找到过敏原';

  @override
  String get allergenSetupNameHint => '过敏原名称';

  @override
  String allergenSetupAddedToList(String name) {
    return '已将\"$name\"添加到列表';
  }

  @override
  String get aboutTitle => '关于与隐私';

  @override
  String get aboutVersion => '版本';

  @override
  String get aboutDisclaimerTitle => '重要提示';

  @override
  String get aboutDisclaimer =>
      'AllergyGuard 是一种支持工具，不是安全认证。对于严重过敏，请始终咨询医生并亲自核对标签。';

  @override
  String get aboutPrivacyPolicy => '隐私政策';

  @override
  String get aboutViewPrivacy => '打开隐私政策';

  @override
  String get aboutLicense => 'MIT 许可';

  @override
  String get aboutViewLicenses => '开源许可';

  @override
  String get aboutContact => '联系方式';

  @override
  String get aboutAttributionTitle => '致谢';

  @override
  String get aboutAttributionOff => '产品数据来自 Open Food Facts (ODbL)';

  @override
  String get aboutAttributionMlkit => 'OCR 和条形码由 Google ML Kit 提供';

  @override
  String get aboutAttributionSupabase => '后端由 Supabase 提供';

  @override
  String get aboutSectionLegal => '法律与隐私';

  @override
  String get aboutPrivacySubtitle => '我们如何处理数据（简而言之：非常少）';

  @override
  String get aboutLicenseSubtitle => '开源。可免费使用、修改和再分发。';

  @override
  String get aboutSectionCredits => '致谢与来源';

  @override
  String get aboutOffSubtitle => '通过条形码获取产品数据 — ODbL 许可。openfoodfacts.org';

  @override
  String get aboutMlkitSubtitle => '在设备上进行文字和条形码识别。不向 Google 服务器发送任何数据。';

  @override
  String get aboutSupabaseSubtitle => '用于社区语言模式的后端。欧盟服务器加密存储。';

  @override
  String get aboutSectionContact => '联系方式';

  @override
  String get aboutRepositoryTitle => '源代码';

  @override
  String aboutLaunchError(String url) {
    return '无法打开 $url';
  }

  @override
  String get disclaimerShort => '支持工具，非认证。请始终核对标签，严重过敏请咨询医生。';
}
