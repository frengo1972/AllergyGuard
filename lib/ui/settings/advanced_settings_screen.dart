import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allergyguard/data/local/local_allergen_repository.dart';
import 'package:allergyguard/data/local/local_preferences_service.dart';
import 'package:allergyguard/domain/models/allergen_dataset.dart';
import 'package:allergyguard/l10n/app_localizations.dart';
import 'package:allergyguard/ui/onboarding/onboarding_screen.dart';

class AdvancedSettingsScreen extends ConsumerStatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  ConsumerState<AdvancedSettingsScreen> createState() =>
      _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState
    extends ConsumerState<AdvancedSettingsScreen> {
  final LocalAllergenRepository _allergenRepository = LocalAllergenRepository();
  final LocalPreferencesService _preferences = LocalPreferencesService();
  String _languageCode = 'it';
  bool _communityLearningEnabled = true;
  bool _isSyncingAllergenData = false;
  AllergenCatalogState? _allergenCatalogState;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsAdvancedTitle)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            ListTile(
              leading: const Icon(Icons.cloud_sync_outlined),
              title: Text(_allergenDataUpdateTitle),
              subtitle: Text(_allergenDataUpdateSubtitle),
              trailing: _isSyncingAllergenData
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _isSyncingAllergenData ? null : _syncAllergenData,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.group_outlined),
              title: Text(l10n.settingsCommunityLearning),
              subtitle: Text(l10n.settingsCommunityLearningSubtitle),
              value: _communityLearningEnabled,
              onChanged: _toggleCommunityLearning,
            ),
            const Divider(),
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
      ),
    );
  }

  Future<void> _loadState() async {
    final languageCode = await _preferences.getInterfaceLanguage();
    final communityLearningEnabled =
        await _preferences.isCommunityLearningEnabled();
    final catalogState = await _allergenRepository.getCatalogState();
    if (!mounted) return;
    setState(() {
      _languageCode = languageCode;
      _communityLearningEnabled = communityLearningEnabled;
      _allergenCatalogState = catalogState;
    });
  }

  Future<void> _syncAllergenData() async {
    setState(() => _isSyncingAllergenData = true);
    final result = await _allergenRepository.syncRemoteAllergens();
    await _loadState();
    if (!mounted) return;

    setState(() => _isSyncingAllergenData = false);

    final messenger = ScaffoldMessenger.of(context);
    final names = result.addedAllergens
        .map((allergen) => allergen.localizedName(_languageCode))
        .toList(growable: false);

    if (!result.remoteAvailable) {
      messenger.showSnackBar(
        SnackBar(content: Text(_catalogMessageRemoteUnavailable())),
      );
      return;
    }

    if (!result.success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage == null || result.errorMessage!.isEmpty
                ? _catalogMessageSyncError()
                : '${_catalogMessageSyncError()} ${result.errorMessage!}',
          ),
        ),
      );
      return;
    }

    if (!result.updated) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(_catalogMessageAlreadyUpdated(result.localVersion)),
        ),
      );
      return;
    }

    final details = names.isEmpty ? null : names.join(', ');
    final baseMessage = _catalogMessageUpdated(result.localVersion);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          details == null || details.isEmpty
              ? baseMessage
              : '$baseMessage ${_catalogMessageAddedPrefix()} $details',
        ),
        duration: const Duration(seconds: 5),
      ),
    );
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

  String get _allergenDataUpdateTitle {
    return switch (_languageCode) {
      'it' => 'Aggiorna dati allergeni',
      'de' => 'Allergendaten aktualisieren',
      'fr' => 'Mettre a jour les donnees allergenes',
      'es' => 'Actualizar datos de alergenos',
      'ja' => 'アレルゲンデータを更新',
      'zh' => '更新过敏原数据',
      _ => 'Refresh allergen data',
    };
  }

  String get _allergenDataUpdateSubtitle {
    final state = _allergenCatalogState;
    if (state == null) {
      return switch (_languageCode) {
        'it' => 'Carico stato catalogo...',
        'de' => 'Katalogstatus wird geladen...',
        'fr' => 'Chargement du statut du catalogue...',
        'es' => 'Cargando estado del catalogo...',
        'ja' => 'カタログ状態を読み込み中...',
        'zh' => '正在加载目录状态...',
        _ => 'Loading catalog status...',
      };
    }

    final sourceLabel = state.cachedVersion > 0
        ? _catalogSubtitleCacheVersion(state.cachedVersion)
        : _catalogSubtitleBundleVersion(state.bundledVersion);
    final remoteLabel = state.remoteAvailable
        ? _catalogSubtitleRemoteAvailable()
        : _catalogSubtitleRemoteUnavailable();

    if (state.cachedUpdatedAt == null) {
      return '$sourceLabel. $remoteLabel';
    }

    final updated = _formatShortDate(state.cachedUpdatedAt!);
    return '$sourceLabel. ${_catalogSubtitleUpdatedAt(updated)}. $remoteLabel';
  }

  String _catalogSubtitleCacheVersion(int version) {
    return switch (_languageCode) {
      'it' => 'Catalogo remoto locale v$version',
      'de' => 'Lokal gecachter Katalog v$version',
      'fr' => 'Catalogue distant en cache v$version',
      'es' => 'Catalogo remoto en cache v$version',
      'ja' => 'リモートカタログ（キャッシュ）v$version',
      'zh' => '远程目录缓存 v$version',
      _ => 'Cached remote catalog v$version',
    };
  }

  String _catalogSubtitleBundleVersion(int version) {
    return switch (_languageCode) {
      'it' => 'Solo bundle locale v$version',
      'de' => 'Nur lokales Bundle v$version',
      'fr' => 'Bundle local uniquement v$version',
      'es' => 'Solo bundle local v$version',
      'ja' => 'ローカルバンドルのみ v$version',
      'zh' => '仅本地数据 v$version',
      _ => 'Bundled catalog only v$version',
    };
  }

  String _catalogSubtitleUpdatedAt(String value) {
    return switch (_languageCode) {
      'it' => 'Aggiornato il $value',
      'de' => 'Aktualisiert am $value',
      'fr' => 'Mis a jour le $value',
      'es' => 'Actualizado el $value',
      'ja' => '$value に更新',
      'zh' => '$value 已更新',
      _ => 'Updated on $value',
    };
  }

  String _catalogSubtitleRemoteAvailable() {
    return switch (_languageCode) {
      'it' => 'Sync remota disponibile',
      'de' => 'Remote-Sync verfuegbar',
      'fr' => 'Sync distant disponible',
      'es' => 'Sync remota disponible',
      'ja' => 'リモート同期が利用可能',
      'zh' => '远程同步可用',
      _ => 'Remote sync available',
    };
  }

  String _catalogSubtitleRemoteUnavailable() {
    return switch (_languageCode) {
      'it' => 'Backend non configurato',
      'de' => 'Backend nicht konfiguriert',
      'fr' => 'Backend non configure',
      'es' => 'Backend no configurado',
      'ja' => 'バックエンドが未設定',
      'zh' => '后端未配置',
      _ => 'Backend not configured',
    };
  }

  String _catalogMessageRemoteUnavailable() {
    return switch (_languageCode) {
      'it' => 'Sync allergeni non disponibile: backend non configurato.',
      'de' => 'Allergen-Sync nicht verfuegbar: Backend nicht konfiguriert.',
      'fr' => 'Sync allergenes indisponible : backend non configure.',
      'es' => 'Sync de alergenos no disponible: backend no configurado.',
      'ja' => 'アレルゲン同期は利用できません：バックエンド未設定。',
      'zh' => '过敏原同步不可用：后端未配置。',
      _ => 'Allergen sync unavailable: backend not configured.',
    };
  }

  String _catalogMessageSyncError() {
    return switch (_languageCode) {
      'it' => 'Impossibile aggiornare i dati allergeni.',
      'de' => 'Allergendaten konnten nicht aktualisiert werden.',
      'fr' => 'Impossible de mettre a jour les donnees allergenes.',
      'es' => 'No se pueden actualizar los datos de alergenos.',
      'ja' => 'アレルゲンデータを更新できません。',
      'zh' => '无法更新过敏原数据。',
      _ => 'Unable to refresh allergen data.',
    };
  }

  String _catalogMessageAlreadyUpdated(int version) {
    return switch (_languageCode) {
      'it' => 'Dati allergeni gia aggiornati alla versione $version.',
      'de' => 'Allergendaten sind bereits auf Version $version.',
      'fr' => 'Donnees allergenes deja a jour en version $version.',
      'es' => 'Datos de alergenos ya actualizados a la version $version.',
      'ja' => 'アレルゲンデータは既にバージョン $version です。',
      'zh' => '过敏原数据已是最新版本 $version。',
      _ => 'Allergen data is already up to date at version $version.',
    };
  }

  String _catalogMessageUpdated(int version) {
    return switch (_languageCode) {
      'it' => 'Dati allergeni aggiornati alla versione $version.',
      'de' => 'Allergendaten auf Version $version aktualisiert.',
      'fr' => 'Donnees allergenes mises a jour en version $version.',
      'es' => 'Datos de alergenos actualizados a la version $version.',
      'ja' => 'アレルゲンデータをバージョン $version に更新しました。',
      'zh' => '过敏原数据已更新至版本 $version。',
      _ => 'Allergen data updated to version $version.',
    };
  }

  String _catalogMessageAddedPrefix() {
    return switch (_languageCode) {
      'it' => 'Nuovi allergeni:',
      'de' => 'Neue Allergene:',
      'fr' => 'Nouveaux allergenes :',
      'es' => 'Nuevos alergenos:',
      'ja' => '新しいアレルゲン：',
      'zh' => '新增过敏原：',
      _ => 'New allergens:',
    };
  }

  String _formatShortDate(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    return '$day/$month/$year';
  }
}
