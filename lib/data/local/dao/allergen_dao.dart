import 'package:drift/drift.dart';
import 'package:allergyguard/data/local/app_database.dart';

part 'allergen_dao.g.dart';

@DriftAccessor(tables: [LocalAllergens, UserAllergenPrefs])
class AllergenDao extends DatabaseAccessor<AppDatabase>
    with _$AllergenDaoMixin {
  AllergenDao(super.db);

  Future<List<LocalAllergen>> getAllAllergens() =>
      select(localAllergens).get();

  Future<void> insertAllergen(LocalAllergensCompanion allergen) =>
      into(localAllergens).insert(allergen, mode: InsertMode.insertOrReplace);

  Future<void> insertAllAllergens(
          List<LocalAllergensCompanion> allergens) async {
    await batch((b) {
      b.insertAll(localAllergens, allergens, mode: InsertMode.insertOrReplace);
    });
  }

  Future<List<UserAllergenPref>> getUserPrefs() =>
      (select(userAllergenPrefs)..where((t) => t.enabled.equals(true))).get();

  Future<void> setUserAllergenPref(String allergenKey, bool enabled) =>
      into(userAllergenPrefs).insert(
        UserAllergenPrefsCompanion(
          allergenKey: Value(allergenKey),
          enabled: Value(enabled),
        ),
        mode: InsertMode.insertOrReplace,
      );
}
