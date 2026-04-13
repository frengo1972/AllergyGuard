import 'package:flutter/material.dart';
import 'package:allergyguard/core/tts/tts_service.dart';
import 'package:allergyguard/data/local/local_preferences_service.dart';
import 'package:allergyguard/ui/common/visual_metadata.dart';
import 'package:allergyguard/ui/about/about_screen.dart';
import 'package:allergyguard/ui/allergen_setup/allergen_setup_screen.dart';
import 'package:allergyguard/ui/feedback/feedback_screen.dart';
import 'package:allergyguard/ui/onboarding/onboarding_screen.dart';

/// Schermata impostazioni.
///
/// - Gestione allergeni
/// - Velocita TTS (lento/normale/veloce)
/// - Auto-play TTS on/off
/// - Reset onboarding
/// - Eliminazione dati locali
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalPreferencesService _preferences = LocalPreferencesService();
  String _languageCode = 'it';
  TtsSpeed _ttsSpeed = TtsSpeed.normal;
  bool _resultAutoPlayEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: ListView(
        children: [
          const _SectionHeader('Allergeni'),
          ListTile(
            leading: const Icon(Icons.warning_amber),
            title: const Text('Gestisci allergeni'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AllergenSetupScreen(),
              ),
            ),
          ),
          const _SectionHeader('Accessibilita'),
          ListTile(
            leading: Text(
              languageFlagForCode(_languageCode),
              style: const TextStyle(fontSize: 24),
            ),
            title: const Text('Lingua interfaccia'),
            subtitle: Text(languageLabelForCode(_languageCode)),
            onTap: _showLanguagePicker,
          ),
          ListTile(
            leading: const Icon(Icons.speed),
            title: const Text('Velocita lettura'),
            subtitle: Text(_ttsSpeedLabel(_ttsSpeed)),
            onTap: _showTtsSpeedPicker,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: const Text('Lettura automatica risultato'),
            value: _resultAutoPlayEnabled,
            onChanged: _toggleResultAutoPlay,
          ),
          const _SectionHeader('Community'),
          ListTile(
            leading: const Icon(Icons.favorite_outline, color: Colors.redAccent),
            title: const Text('Lascia un feedback'),
            subtitle: const Text(
              'Aiutaci a migliorare: suggerimenti, bug, accuratezza',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const FeedbackScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Informazioni e privacy'),
            subtitle: const Text('Versione, licenze, attribuzioni'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AboutScreen(),
              ),
            ),
          ),
          const _SectionHeader('Privacy'),
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text('Ripeti onboarding'),
            subtitle: const Text(
              'Riporta l\'app alla scelta lingua e allergeni',
            ),
            onTap: _resetOnboarding,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Elimina dati locali',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text(
              'Rimuove preferenze, onboarding e allergeni personalizzati',
            ),
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
    final speed = TtsSpeed.values.firstWhere(
      (value) => value.name == speedName,
      orElse: () => TtsSpeed.normal,
    );
    if (!mounted) return;
    setState(() {
      _languageCode = languageCode;
      _ttsSpeed = speed;
      _resultAutoPlayEnabled = autoPlayEnabled;
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
    await _preferences.setInterfaceLanguage(selected);
    if (!mounted) return;
    setState(() => _languageCode = selected);
  }

  Future<void> _showTtsSpeedPicker() async {
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
                title: Text(_ttsSpeedLabel(speed)),
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

  Future<void> _resetOnboarding() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ripetere onboarding?'),
          content: const Text(
            'Ti verra richiesto di scegliere di nuovo lingua e allergeni.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Ripeti'),
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
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminare i dati locali?'),
          content: const Text(
            'Verranno rimossi onboarding, lingua, allergeni selezionati e allergeni personalizzati.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Elimina'),
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

  String _ttsSpeedLabel(TtsSpeed speed) {
    return switch (speed) {
      TtsSpeed.slow => 'Lenta',
      TtsSpeed.normal => 'Normale',
      TtsSpeed.fast => 'Veloce',
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
