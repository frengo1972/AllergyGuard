import 'dart:convert';

import 'package:allergyguard/data/local/local_preferences_service.dart';
import 'package:allergyguard/domain/models/scan_result.dart';

class LocalScanRepository {
  LocalScanRepository({
    LocalPreferencesService? preferences,
  }) : _preferences = preferences ?? LocalPreferencesService();

  final LocalPreferencesService _preferences;

  Future<List<ScanResult>> getHistory() async {
    final rawItems = await _preferences.getScanHistoryJson();
    return rawItems.map((item) => ScanResult.fromJsonString(item)).toList()
      ..sort((left, right) => right.scannedAt.compareTo(left.scannedAt));
  }

  Future<void> saveScan(ScanResult result) async {
    final currentItems = await _preferences.getScanHistoryJson();
    final updatedItems = <String>[
      result.toJsonString(),
      ...currentItems,
    ];
    await _preferences.setScanHistoryJson(updatedItems.take(100).toList());
  }

  Future<void> savePendingReport({
    required ScanResult result,
    required String reportType,
    required String note,
  }) async {
    final currentItems = await _preferences.getPendingReportsJson();
    final nextItem = jsonEncode({
      'created_at': DateTime.now().toIso8601String(),
      'report_type': reportType,
      'note': note,
      'barcode': result.barcode,
      'product_name': result.productName,
      'brand': result.brand,
      'level': result.level.name,
      'allergens': result.allergens,
      'ocr_text': result.ocrText,
    });
    await _preferences.setPendingReportsJson(<String>[
      nextItem,
      ...currentItems,
    ]);
  }
}
