import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:allergyguard/data/local/local_preferences_service.dart';
import 'package:allergyguard/domain/models/allergen.dart';
import 'package:allergyguard/domain/repositories/allergen_repository.dart';

class LocalAllergenRepository implements AllergenRepository {
  LocalAllergenRepository({
    LocalPreferencesService? preferences,
  }) : _preferences = preferences ?? LocalPreferencesService();

  final LocalPreferencesService _preferences;

  @override
  Future<void> addCustomAllergen(Allergen allergen) async {
    final customAllergens = await _preferences.getCustomAllergensJson();
    customAllergens.add(allergen.toJson());
    await _preferences.setCustomAllergensJson(customAllergens);
  }

  @override
  Future<List<Allergen>> getAllAllergens() async {
    final bundled = await _loadBundledAllergens();
    final custom = await _loadCustomAllergens();
    return <Allergen>[
      ...bundled,
      ...custom,
    ];
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

  Future<List<Allergen>> _loadBundledAllergens() async {
    final jsonString =
        await rootBundle.loadString('assets/allergens/allergen_list.json');
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final allergens = decoded['allergens'] as List<dynamic>? ?? <dynamic>[];

    return allergens
        .whereType<Map<String, dynamic>>()
        .map((item) => Allergen.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<Allergen>> _loadCustomAllergens() async {
    final customAllergens = await _preferences.getCustomAllergensJson();
    return customAllergens.map(Allergen.fromJson).toList();
  }
}
