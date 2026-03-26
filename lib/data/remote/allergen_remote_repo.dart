import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:allergyguard/core/allergen_patterns/allergen_pattern_engine.dart';

/// Repository remoto per allergeni e pattern da Supabase.
class AllergenRemoteRepository {
  final SupabaseClient _client;

  AllergenRemoteRepository({required SupabaseClient client}) : _client = client;

  /// Scarica tutti i pattern verificati più recenti di una data versione.
  Future<List<ContextPattern>> getVerifiedPatterns({
    DateTime? since,
  }) async {
    var query = _client
        .from('context_patterns')
        .select()
        .eq('status', 'verified');

    if (since != null) {
      query = query.gte('promoted_at', since.toIso8601String());
    }

    final data = await query;

    return (data as List<dynamic>).map((row) {
      final map = row as Map<String, dynamic>;
      return ContextPattern(
        id: map['id'].toString(),
        text: map['pattern_text'] as String,
        language: map['language_code'] as String,
        type: map['pattern_type'] as String,
        status: 'verified',
        confidence: (map['confidence'] as num).toDouble(),
      );
    }).toList();
  }

  /// Invia un report di prodotto dalla community.
  Future<void> submitProductReport({
    required String barcode,
    String? productName,
    String? brand,
    required int allergenId,
    required String reportType,
    required String deviceId,
  }) async {
    await _client.from('product_reports').insert({
      'barcode': barcode,
      'product_name': productName,
      'brand': brand,
      'allergen_id': allergenId,
      'report_type': reportType,
      'device_id': deviceId,
    });
  }
}
