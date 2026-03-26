import 'package:allergyguard/domain/models/allergen.dart';

/// Interfaccia astratta per il repository degli allergeni.
abstract class AllergenRepository {
  Future<List<Allergen>> getAllAllergens();
  Future<List<Allergen>> getUserAllergens();
  Future<void> setUserAllergens(List<String> allergenKeys);
  Future<void> addCustomAllergen(Allergen allergen);
}
