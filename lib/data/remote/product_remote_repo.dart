import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository remoto per report prodotti e sync storico.
class ProductRemoteRepository {
  final SupabaseClient _client;

  ProductRemoteRepository({required SupabaseClient client}) : _client = client;

  /// Recupera i report community per un barcode.
  Future<List<Map<String, dynamic>>> getReportsForBarcode(
      String barcode) async {
    final data = await _client
        .from('product_reports')
        .select()
        .eq('barcode', barcode);
    return (data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  /// Sincronizza lo storico locale dell'utente su Supabase.
  Future<void> syncScanHistory({
    required String userId,
    required List<Map<String, dynamic>> scans,
  }) async {
    await _client.from('scan_history').upsert(
      scans.map((s) => {...s, 'user_id': userId}).toList(),
      onConflict: 'id',
    );
  }
}
