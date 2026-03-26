import 'package:drift/drift.dart';
import 'package:allergyguard/data/local/app_database.dart';

part 'scan_history_dao.g.dart';

@DriftAccessor(tables: [ScanHistoryLocal])
class ScanHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$ScanHistoryDaoMixin {
  ScanHistoryDao(super.db);

  Future<List<ScanHistoryLocalData>> getHistory({int limit = 50}) =>
      (select(scanHistoryLocal)
            ..orderBy([(t) => OrderingTerm.desc(t.scannedAt)])
            ..limit(limit))
          .get();

  Future<void> insertScan(ScanHistoryLocalCompanion scan) =>
      into(scanHistoryLocal).insert(scan);

  Future<int> deleteScan(int id) =>
      (delete(scanHistoryLocal)..where((t) => t.id.equals(id))).go();

  Future<int> clearAll() => delete(scanHistoryLocal).go();

  Future<List<ScanHistoryLocalData>> getUnsynced() =>
      (select(scanHistoryLocal)..where((t) => t.synced.equals(false))).get();

  Future<void> markSynced(int id) =>
      (update(scanHistoryLocal)..where((t) => t.id.equals(id)))
          .write(const ScanHistoryLocalCompanion(synced: Value(true)));

  /// Elimina scansioni più vecchie di N giorni.
  Future<int> deleteOlderThan(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (delete(scanHistoryLocal)
          ..where((t) => t.scannedAt.isSmallerThanValue(cutoff)))
        .go();
  }
}
