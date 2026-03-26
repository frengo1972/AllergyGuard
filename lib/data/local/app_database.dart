import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// Tabella allergeni locale.
class LocalAllergens extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nameKey => text().unique()();
  TextColumn get namesJson => text()(); // JSON serializzato
  TextColumn get severity => text().withDefault(const Constant('high'))();
  BoolColumn get euRegulated => boolean().withDefault(const Constant(false))();
}

/// Preferenze allergeni dell'utente.
class UserAllergenPrefs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get allergenKey => text().unique()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}

/// Pattern di contesto verificati (cache locale).
class LocalContextPatterns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get patternText => text()();
  TextColumn get languageCode => text()();
  TextColumn get patternType => text()();
  RealColumn get confidence => real().withDefault(const Constant(0.0))();
  TextColumn get status =>
      text().withDefault(const Constant('verified'))();
}

/// Storico scansioni locale.
class ScanHistoryLocal extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get barcode => text().nullable()();
  TextColumn get productName => text().nullable()();
  TextColumn get ocrText => text().nullable()();
  TextColumn get result => text()(); // DANGER|WARNING|SAFE|UNKNOWN
  RealColumn get confidence => real().nullable()();
  TextColumn get allergensJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get scannedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

/// Cache prodotti Open Food Facts.
class ProductCache extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get barcode => text().unique()();
  TextColumn get productJson => text()(); // JSON serializzato
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Coda pattern da sincronizzare (offline queue).
class PendingPatternUploads extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get patternText => text()();
  TextColumn get sourceOcrText => text()();
  TextColumn get deviceId => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [
  LocalAllergens,
  UserAllergenPrefs,
  LocalContextPatterns,
  ScanHistoryLocal,
  ProductCache,
  PendingPatternUploads,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
