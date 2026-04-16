import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allergyguard/core/locale/locale_provider.dart';
import 'package:allergyguard/core/tts/tts_service.dart';
import 'package:allergyguard/data/local/local_preferences_service.dart';
import 'package:allergyguard/l10n/app_localizations.dart';
import 'package:allergyguard/ui/common/visual_metadata.dart';
import 'package:allergyguard/ui/about/about_screen.dart';
import 'package:allergyguard/ui/allergen_setup/allergen_setup_screen.dart';
import 'package:allergyguard/ui/feedback/feedback_screen.dart';
import 'package:allergyguard/ui/onboarding/onboarding_screen.dart';

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
  bool _communityLearningEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
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
            leading:
                const Icon(Icons.favorite_outline, color: Colors.redAccent),
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
          SwitchListTile(
            secondary: const Icon(Icons.group_outlined),
            title: Text(l10n.settingsCommunityLearning),
            subtitle: Text(l10n.settingsCommunityLearningSubtitle),
            value: _communityLearningEnabled,
            onChanged: _toggleCommunityLearning,
          ),
          _SectionHeader(l10n.settingsSectionPrivacy),
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: Text(l10n.settingsRepeatOnboarding),
            subtitle: Text(l10n.settingsRepeatOnboardingSubtitle),
            onTap: _resetOnboarding,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(
              l10n.settingsClearLocalData,
              style: const TextStyle(color: Colors.red),
            ),
            subtitle: Text(l10n.settingsClearLocalDataSubtitle),
            onTap: _clearLocalData,
          ),
        ],
      ),
    );
  }

  Future<void> _loadSettings() async {
    final languageCode = await _preferences.getInterfaceLanguage();
    final speedName = await _preferences.getTtsSpeedName();
    final autoPlayEnabled = await _preferences.isResultAutoPlayEnabled();
    final communityLearningEnabled =
        await _preferences.isCommunityLearningEnabled();
    final speed = TtsSpeed.values.firstWhere(
      (value) => value.name == speedName,
      orElse: () => TtsSpeed.normal,
    );
    if (!mounted) return;
    setState(() {
      _languageCode = languageCode;
      _ttsSpeed = speed;
      _resultAutoPlayEnabled = autoPlayEnabled;
      _communityLearningEnabled = communityLearningEnabled;
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

  Future<void> _toggleResultAutoPlay(bool value) async {
    await _preferences.setResultAutoPlayEnabled(value);
    if (!mounted) return;
    setState(() => _resultAutoPlayEnabled = value);
  }

  Future<void> _toggleCommunityLearning(bool value) async {
    await _preferences.setCommunityLearningEnabled(value);
    if (!mounted) return;
    setState(() => _communityLearningEnabled = value);
  }

  Future<void> _resetOnboarding() async {
    final l10n = AppLocalizations.of(context);
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.settingsRepeatOnboardingDialogTitle),
          content: Text(l10n.settingsRepeatOnboardingDialogBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.commonRepeat),
            ),
          ],
        );
      },
    );

    if (shouldReset != true) return;

    await _preferences.setOnboardingComplete(false);
    if (!mounted) return;

    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const OnboardingScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _clearLocalData() async {
    final l10n = AppLocalizations.of(context);
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.settingsClearDialogTitle),
          content: Text(l10n.settingsClearDialogBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
    );

    if (shouldClear != true) return;

    await _preferences.clearAllPreferences();
    if (!mounted) return;
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const OnboardingScreen(),
      ),
      (route) => false,
    );
  }

  String _ttsSpeedLabel(TtsSpeed speed, AppLocalizations l10n) {
    return switch (speed) {
      TtsSpeed.slow => l10n.settingsTtsSpeedSlow,
      TtsSpeed.normal => l10n.settingsTtsSpeedNormal,
      TtsSpeed.fast => l10n.settingsTtsSpeedFast,
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
