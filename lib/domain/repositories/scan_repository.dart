import 'package:allergyguard/domain/models/scan_result.dart';

/// Interfaccia astratta per il repository dello storico scansioni.
abstract class ScanRepository {
  Future<List<ScanResult>> getHistory({int limit = 50});
  Future<void> saveScan(ScanResult result);
  Future<void> deleteScan(String id);
  Future<void> clearHistory();
  Future<void> syncToCloud();
}
