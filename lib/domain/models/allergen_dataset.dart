import 'package:allergyguard/domain/models/allergen.dart';

class AllergenDatasetInfo {
  const AllergenDatasetInfo({
    required this.version,
    this.updatedAt,
    this.summary,
    this.addedKeys = const <String>[],
  });

  final int version;
  final DateTime? updatedAt;
  final String? summary;
  final List<String> addedKeys;
}

class AllergenCatalogState {
  const AllergenCatalogState({
    required this.bundledVersion,
    required this.cachedVersion,
    required this.remoteAvailable,
    this.cachedUpdatedAt,
  });

  final int bundledVersion;
  final int cachedVersion;
  final bool remoteAvailable;
  final DateTime? cachedUpdatedAt;
}

class AllergenSyncResult {
  const AllergenSyncResult({
    required this.success,
    required this.updated,
    required this.remoteAvailable,
    required this.localVersion,
    this.remoteVersion,
    this.updatedAt,
    this.summary,
    this.addedAllergens = const <Allergen>[],
    this.errorMessage,
  });

  final bool success;
  final bool updated;
  final bool remoteAvailable;
  final int localVersion;
  final int? remoteVersion;
  final DateTime? updatedAt;
  final String? summary;
  final List<Allergen> addedAllergens;
  final String? errorMessage;

  bool get alreadyUpToDate => success && !updated;
}
