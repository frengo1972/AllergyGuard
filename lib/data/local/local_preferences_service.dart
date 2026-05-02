import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LanguageOption {
  const LanguageOption({
    required this.code,
    required this.label,
    required this.flagEmoji,
  });

  final String code;
  final String label;
  final String flagEmoji;
}

class LocalPreferencesService {
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String interfaceLanguageKey = 'interface_language';
  static const String selectedAllergenKeysKey = 'selected_allergen_keys';
  static const String customAllergensKey = 'custom_allergens';
  static const String ttsSpeedKey = 'tts_speed';
  static const String resultAutoPlayKey = 'result_auto_play';
  static const String scanHistoryKey = 'scan_history';
  static const String pendingReportsKey = 'pending_reports';
  static const String pendingFeedbackKey = 'pending_feedback';
  static const String deviceIdKey = 'device_id';
  static const String communityLearningKey = 'community_learning_enabled';
  static const String textScaleKey = 'text_scale';
  static const String cachedRemoteAllergensKey = 'cached_remote_allergens';
  static const String cachedRemoteAllergensVersionKey =
      'cached_remote_allergens_version';
  static const String cachedRemoteAllergensUpdatedAtKey =
      'cached_remote_allergens_updated_at';

  static const List<LanguageOption> supportedLanguages = [
    LanguageOption(code: 'it', label: 'Italiano', flagEmoji: '🇮🇹'),
    LanguageOption(code: 'en', label: 'English', flagEmoji: '🇬🇧'),
    LanguageOption(code: 'de', label: 'Deutsch', flagEmoji: '🇩🇪'),
    LanguageOption(code: 'fr', label: 'Français', flagEmoji: '🇫🇷'),
    LanguageOption(code: 'es', label: 'Español', flagEmoji: '🇪🇸'),
    LanguageOption(code: 'zh', label: '中文', flagEmoji: '🇨🇳'),
    LanguageOption(code: 'ja', label: '日本語', flagEmoji: '🇯🇵'),
  ];

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<bool> isOnboardingComplete() async {
    final prefs = await _prefs;
    return prefs.getBool(onboardingCompleteKey) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(onboardingCompleteKey, value);
  }

  Future<String> getInterfaceLanguage() async {
    final prefs = await _prefs;
    return prefs.getString(interfaceLanguageKey) ?? 'it';
  }

  Future<void> setInterfaceLanguage(String languageCode) async {
    final prefs = await _prefs;
    await prefs.setString(interfaceLanguageKey, languageCode);
  }

  Future<List<String>> getSelectedAllergenKeys() async {
    final prefs = await _prefs;
    return prefs.getStringList(selectedAllergenKeysKey) ?? <String>[];
  }

  Future<void> setSelectedAllergenKeys(List<String> allergenKeys) async {
    final prefs = await _prefs;
    await prefs.setStringList(selectedAllergenKeysKey, allergenKeys);
  }

  Future<List<Map<String, dynamic>>> getCustomAllergensJson() async {
    final prefs = await _prefs;
    final raw = prefs.getString(customAllergensKey);
    if (raw == null || raw.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> setCustomAllergensJson(List<Map<String, dynamic>> items) async {
    final prefs = await _prefs;
    await prefs.setString(customAllergensKey, jsonEncode(items));
  }

  Future<List<Map<String, dynamic>>> getCachedRemoteAllergensJson() async {
    final prefs = await _prefs;
    final raw = prefs.getString(cachedRemoteAllergensKey);
    if (raw == null || raw.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> setCachedRemoteAllergensJson(
    List<Map<String, dynamic>> items,
  ) async {
    final prefs = await _prefs;
    await prefs.setString(cachedRemoteAllergensKey, jsonEncode(items));
  }

  Future<int> getCachedRemoteAllergensVersion() async {
    final prefs = await _prefs;
    return prefs.getInt(cachedRemoteAllergensVersionKey) ?? 0;
  }

  Future<void> setCachedRemoteAllergensVersion(int version) async {
    final prefs = await _prefs;
    await prefs.setInt(cachedRemoteAllergensVersionKey, version);
  }

  Future<DateTime?> getCachedRemoteAllergensUpdatedAt() async {
    final prefs = await _prefs;
    final raw = prefs.getString(cachedRemoteAllergensUpdatedAtKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setCachedRemoteAllergensUpdatedAt(DateTime? value) async {
    final prefs = await _prefs;
    if (value == null) {
      await prefs.remove(cachedRemoteAllergensUpdatedAtKey);
      return;
    }
    await prefs.setString(
      cachedRemoteAllergensUpdatedAtKey,
      value.toIso8601String(),
    );
  }

  Future<String> getTtsSpeedName() async {
    final prefs = await _prefs;
    return prefs.getString(ttsSpeedKey) ?? 'normal';
  }

  Future<void> setTtsSpeedName(String speedName) async {
    final prefs = await _prefs;
    await prefs.setString(ttsSpeedKey, speedName);
  }

  Future<bool> isResultAutoPlayEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(resultAutoPlayKey) ?? true;
  }

  Future<void> setResultAutoPlayEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(resultAutoPlayKey, enabled);
  }

  Future<void> clearAllPreferences() async {
    final prefs = await _prefs;
    await prefs.clear();
  }

  Future<List<String>> getScanHistoryJson() async {
    final prefs = await _prefs;
    return prefs.getStringList(scanHistoryKey) ?? <String>[];
  }

  Future<void> setScanHistoryJson(List<String> items) async {
    final prefs = await _prefs;
    await prefs.setStringList(scanHistoryKey, items);
  }

  Future<List<String>> getPendingReportsJson() async {
    final prefs = await _prefs;
    return prefs.getStringList(pendingReportsKey) ?? <String>[];
  }

  Future<void> setPendingReportsJson(List<String> items) async {
    final prefs = await _prefs;
    await prefs.setStringList(pendingReportsKey, items);
  }

  Future<List<String>> getPendingFeedbackJson() async {
    final prefs = await _prefs;
    return prefs.getStringList(pendingFeedbackKey) ?? <String>[];
  }

  Future<void> setPendingFeedbackJson(List<String> items) async {
    final prefs = await _prefs;
    await prefs.setStringList(pendingFeedbackKey, items);
  }

  Future<String> getTextScaleName() async {
    final prefs = await _prefs;
    return prefs.getString(textScaleKey) ?? 'medium';
  }

  Future<void> setTextScaleName(String value) async {
    final prefs = await _prefs;
    await prefs.setString(textScaleKey, value);
  }

  Future<bool> isCommunityLearningEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(communityLearningKey) ?? true;
  }

  Future<void> setCommunityLearningEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(communityLearningKey, enabled);
  }

  /// Ritorna un device ID anonimo stabile (UUID v4) generato al primo uso.
  /// Usato per deduplicare contributi community, non è legato a identità.
  Future<String> getOrCreateDeviceId() async {
    final prefs = await _prefs;
    final existing = prefs.getString(deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final newId = const Uuid().v4();
    await prefs.setString(deviceIdKey, newId);
    return newId;
  }
}

String languageLabelForCode(String languageCode) {
  final match = LocalPreferencesService.supportedLanguages
      .cast<LanguageOption?>()
      .firstWhere(
        (language) => language?.code == languageCode,
        orElse: () => null,
      );
  return match?.label ?? languageCode.toUpperCase();
}
