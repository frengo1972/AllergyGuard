import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:allergyguard/core/locale/locale_provider.dart';
import 'package:allergyguard/core/theme/text_scale_provider.dart';
import 'package:allergyguard/core/tts/tts_service.dart';
import 'package:allergyguard/data/local/local_preferences_service.dart';
import 'package:allergyguard/l10n/app_localizations.dart';
import 'package:allergyguard/ui/common/visual_metadata.dart';
import 'package:allergyguard/ui/about/about_screen.dart';
import 'package:allergyguard/ui/allergen_setup/allergen_setup_screen.dart';
import 'package:allergyguard/ui/feedback/feedback_screen.dart';
import 'package:allergyguard/ui/settings/advanced_settings_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final LocalPreferencesService _preferences = LocalPreferencesService();
  String _languageCode = 'it';
  TtsSpeed _ttsSpeed = TtsSpeed.normal;
  bool _resultAutoPlayEnabled = true;
  String _appVersion = '';
  String _appBuild = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textScale = ref.watch(textScaleControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  _SectionHeader(l10n.settingsSectionAllergens),
                  ListTile(
                    leading: const Icon(Icons.warning_amber),
                    title: Text(l10n.settingsManageAllergens),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AllergenSetupScreen(),
                      ),
                    ),
                  ),
                  _SectionHeader(l10n.settingsSectionAccessibility),
                  ListTile(
                    leading: Text(
                      languageFlagForCode(_languageCode),
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(l10n.settingsLanguage),
                    subtitle: Text(languageLabelForCode(_languageCode)),
                    onTap: _showLanguagePicker,
                  ),
                  ListTile(
                    leading: const Icon(Icons.format_size),
                    title: Text(l10n.settingsTextSize),
                    subtitle: Text(_textScaleLabel(textScale, l10n)),
                    onTap: _showTextScalePicker,
                  ),
                  ListTile(
                    leading: const Icon(Icons.speed),
                    title: Text(l10n.settingsTtsSpeed),
                    subtitle: Text(_ttsSpeedLabel(_ttsSpeed, l10n)),
                    onTap: _showTtsSpeedPicker,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.volume_up),
                    title: Text(l10n.settingsAutoPlay),
                    value: _resultAutoPlayEnabled,
                    onChanged: _toggleResultAutoPlay,
                  ),
                  _SectionHeader(l10n.settingsSectionCommunity),
                  ListTile(
                    leading: const Icon(
                      Icons.favorite_outline,
                      color: Colors.redAccent,
                    ),
                    title: Text(l10n.settingsLeaveFeedback),
                    subtitle: Text(l10n.settingsLeaveFeedbackSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const FeedbackScreen(),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(l10n.settingsAboutAndPrivacy),
                    subtitle: Text(l10n.settingsAboutAndPrivacySubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AboutScreen(),
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.tune),
                    title: Text(l10n.settingsAdvanced),
                    subtitle: Text(l10n.settingsAdvancedSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AdvancedSettingsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_appVersion.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  l10n.settingsVersion(_appVersion, _appBuild),
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadSettings() async {
    final languageCode = await _preferences.getInterfaceLanguage();
    final speedName = await _preferences.getTtsSpeedName();
    final autoPlayEnabled = await _preferences.isResultAutoPlayEnabled();
    final speed = TtsSpeed.values.firstWhere(
      (value) => value.name == speedName,
      orElse: () => TtsSpeed.normal,
    );
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _languageCode = languageCode;
      _ttsSpeed = speed;
      _resultAutoPlayEnabled = autoPlayEnabled;
      _appVersion = info.version;
      _appBuild = info.buildNumber;
    });
  }

  Future<void> _showLanguagePicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: LocalPreferencesService.supportedLanguages.map((option) {
              return ListTile(
                leading: Text(
                  option.flagEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(option.label),
                trailing: option.code == _languageCode
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(context, option.code),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selected == null || selected == _languageCode) return;
    await ref.read(localeControllerProvider.notifier).setLanguage(selected);
    if (!mounted) return;
    setState(() => _languageCode = selected);
  }

  Future<void> _showTtsSpeedPicker() async {
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<TtsSpeed>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: TtsSpeed.values.map((speed) {
              return ListTile(
                leading: Icon(
                  speed == _ttsSpeed ? Icons.check_circle : Icons.speed,
                ),
                title: Text(_ttsSpeedLabel(speed, l10n)),
                onTap: () => Navigator.pop(context, speed),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selected == null || selected == _ttsSpeed) return;
    await _preferences.setTtsSpeedName(selected.name);
    if (!mounted) return;
    setState(() => _ttsSpeed = selected);
  }

  Future<void> _showTextScalePicker() async {
    final l10n = AppLocalizations.of(context);
    final current = ref.read(textScaleControllerProvider);
    final selected = await showModalBottomSheet<AppTextScale>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: AppTextScale.values.map((scale) {
              return ListTile(
                leading: Icon(
                  scale == current ? Icons.check_circle : Icons.format_size,
                ),
                title: Text(_textScaleLabel(scale, l10n)),
                onTap: () => Navigator.pop(context, scale),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selected == null || selected == current) return;
    await ref.read(textScaleControllerProvider.notifier).setScale(selected);
  }

  Future<void> _toggleResultAutoPlay(bool value) async {
    await _preferences.setResultAutoPlayEnabled(value);
    if (!mounted) return;
    setState(() => _resultAutoPlayEnabled = value);
  }

  String _ttsSpeedLabel(TtsSpeed speed, AppLocalizations l10n) {
    return switch (speed) {
      TtsSpeed.slow => l10n.settingsTtsSpeedSlow,
      TtsSpeed.normal => l10n.settingsTtsSpeedNormal,
      TtsSpeed.fast => l10n.settingsTtsSpeedFast,
    };
  }

  String _textScaleLabel(AppTextScale scale, AppLocalizations l10n) {
    return switch (scale) {
      AppTextScale.small => l10n.settingsTextSizeSmall,
      AppTextScale.medium => l10n.settingsTextSizeMedium,
      AppTextScale.large => l10n.settingsTextSizeLarge,
    };
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
