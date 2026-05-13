import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:allergyguard/data/local/local_preferences_service.dart';
import 'package:allergyguard/data/remote/allergen_remote_repo.dart';
import 'package:allergyguard/domain/models/allergen.dart';
import 'package:allergyguard/domain/models/allergen_dataset.dart';
import 'package:allergyguard/domain/repositories/allergen_repository.dart';

class LocalAllergenRepository implements AllergenRepository {
  LocalAllergenRepository({
    LocalPreferencesService? preferences,
    AllergenRemoteRepository? remoteRepository,
  })  : _preferences = preferences ?? LocalPreferencesService(),
        _remoteRepository = remoteRepository ?? _buildDefaultRemoteRepository();

  final LocalPreferencesService _preferences;
  final AllergenRemoteRepository? _remoteRepository;

  @override
  Future<void> addCustomAllergen(Allergen allergen) async {
    final customAllergens = await _preferences.getCustomAllergensJson();
    customAllergens.add(allergen.toJson());
    await _preferences.setCustomAllergensJson(customAllergens);
  }

  @override
  Future<List<Allergen>> getAllAllergens() async {
    final bundled = await _loadBundledAllergens();
    final cachedRemote = await _loadCachedRemoteAllergens();
    final custom = await _loadCustomAllergens();
    final merged = <String, Allergen>{
      for (final allergen in bundled) allergen.nameKey: allergen,
      for (final allergen in cachedRemote) allergen.nameKey: allergen,
      for (final allergen in custom) allergen.nameKey: allergen,
    };
    return merged.values.toList(growable: false);
  }

  @override
  Future<List<Allergen>> getUserAllergens() async {
    final allAllergens = await getAllAllergens();
    final selectedKeys = await _preferences.getSelectedAllergenKeys();
    final selectedSet = selectedKeys.toSet();
    return allAllergens
        .where((allergen) => selectedSet.contains(allergen.nameKey))
        .toList();
  }

  @override
  Future<void> setUserAllergens(List<String> allergenKeys) {
    return _preferences.setSelectedAllergenKeys(allergenKeys);
  }

  Future<List<String>> getSelectedAllergenKeys() {
    return _preferences.getSelectedAllergenKeys();
  }

  Future<AllergenCatalogState> getCatalogState() async {
    final bundledVersion = await _loadBundledCatalogVersion();
    final cachedVersion = await _preferences.getCachedRemoteAllergensVersion();
    final cachedUpdatedAt = await _preferences.getCachedRemoteAllergensUpdatedAt();
    return AllergenCatalogState(
      bundledVersion: bundledVersion,
      cachedVersion: cachedVersion,
      remoteAvailable: _remoteRepository != null,
      cachedUpdatedAt: cachedUpdatedAt,
    );
  }

  Future<AllergenSyncResult> syncRemoteAllergens() async {
    final bundledVersion = await _loadBundledCatalogVersion();
    final localVersion = await _preferences.getCachedRemoteAllergensVersion();
    final effectiveLocalVersion =
        localVersion > 0 ? localVersion : bundledVersion;

    if (_remoteRepository == null) {
      return AllergenSyncResult(
        success: false,
        updated: false,
        remoteAvailable: false,
        localVersion: effectiveLocalVersion,
        errorMessage: 'Backend Supabase non configurato.',
      );
    }

    try {
      final beforeKeys = (await getAllAllergens())
          .map((allergen) => allergen.nameKey)
          .toSet();
      final datasetInfo = await _remoteRepository.getAllergenDatasetInfo();
      final remoteAllergens = await _remoteRepository.getActiveAllergens();

      if (remoteAllergens.isEmpty) {
        return AllergenSyncResult(
          success: false,
          updated: false,
          remoteAvailable: true,
          localVersion: effectiveLocalVersion,
          remoteVersion: datasetInfo?.version,
          errorMessage: 'Catalogo remoto non disponibile o non ancora migrato.',
        );
      }

      final remoteVersion = datasetInfo?.version ??
          remoteAllergens
              .map((allergen) => allergen.datasetVersion ?? 0)
              .fold<int>(0, (current, value) => value > current ? value : current);
      final needsUpdate = remoteVersion > localVersion || localVersion == 0;

      if (!needsUpdate) {
        return AllergenSyncResult(
          success: true,
          updated: false,
          remoteAvailable: true,
          localVersion: effectiveLocalVersion,
          remoteVersion: remoteVersion,
          updatedAt: await _preferences.getCachedRemoteAllergensUpdatedAt(),
          summary: datasetInfo?.summary,
        );
      }

      await _preferences.setCachedRemoteAllergensJson(
        remoteAllergens.map((allergen) => allergen.toJson()).toList(),
      );
      await _preferences.setCachedRemoteAllergensVersion(remoteVersion);
      await _preferences.setCachedRemoteAllergensUpdatedAt(
        datasetInfo?.updatedAt ?? DateTime.now(),
      );

      final addedCandidates = datasetInfo?.addedKeys.isNotEmpty == true
          ? remoteAllergens
              .where((allergen) => datasetInfo!.addedKeys.contains(allergen.nameKey))
              .where((allergen) => !beforeKeys.contains(allergen.nameKey))
              .toList(growable: false)
          : remoteAllergens
              .where((allergen) => !beforeKeys.contains(allergen.nameKey))
              .toList(growable: false);

      return AllergenSyncResult(
        success: true,
        updated: true,
        remoteAvailable: true,
        localVersion: remoteVersion,
        remoteVersion: remoteVersion,
        updatedAt: datasetInfo?.updatedAt ?? DateTime.now(),
        summary: datasetInfo?.summary,
        addedAllergens: addedCandidates,
      );
    } on PostgrestException catch (error) {
      return AllergenSyncResult(
        success: false,
        updated: false,
        remoteAvailable: true,
        localVersion: effectiveLocalVersion,
        errorMessage: error.message,
      );
    } on AuthException catch (error) {
      return AllergenSyncResult(
        success: false,
        updated: false,
        remoteAvailable: true,
        localVersion: effectiveLocalVersion,
        errorMessage: error.message,
      );
    } catch (error) {
      final raw = error.toString();
      final isNetworkError = raw.contains('SocketException') ||
          raw.contains('ClientException') ||
          raw.contains('Failed host lookup') ||
          raw.contains('Connection refused') ||
          raw.contains('Connection timed out');
      return AllergenSyncResult(
        success: false,
        updated: false,
        remoteAvailable: true,
        localVersion: effectiveLocalVersion,
        errorMessage: isNetworkError
            ? 'Server non raggiungibile. Verifica la connessione o riprova più tardi.'
            : raw,
      );
    }
  }

  Future<List<Allergen>> _loadBundledAllergens() async {
    final jsonString =
        await rootBundle.loadString('assets/allergens/allergen_list.json');
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final allergens = decoded['allergens'] as List<dynamic>? ?? <dynamic>[];

    return allergens
        .whereType<Map>()
        .map((item) => Allergen.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<int> _loadBundledCatalogVersion() async {
    final jsonString =
        await rootBundle.loadString('assets/allergens/allergen_list.json');
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    return decoded['version'] as int? ?? 1;
  }

  Future<List<Allergen>> _loadCachedRemoteAllergens() async {
    final cachedAllergens = await _preferences.getCachedRemoteAllergensJson();
    return cachedAllergens.map(Allergen.fromJson).toList();
  }

  Future<List<Allergen>> _loadCustomAllergens() async {
    final customAllergens = await _preferences.getCustomAllergensJson();
    return customAllergens.map(Allergen.fromJson).toList();
  }

  static AllergenRemoteRepository? _buildDefaultRemoteRepository() {
    try {
      return AllergenRemoteRepository(client: Supabase.instance.client);
    } catch (_) {
      return null;
    }
  }
}
