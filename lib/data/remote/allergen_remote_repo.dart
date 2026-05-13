import 'package:allergyguard/domain/models/allergen.dart';
import 'package:allergyguard/domain/models/allergen_dataset.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:allergyguard/core/allergen_patterns/allergen_pattern_engine.dart';

/// Repository remoto per allergeni e pattern da Supabase.
class AllergenRemoteRepository {

  AllergenRemoteRepository({required SupabaseClient client}) : _client = client;
  final SupabaseClient _client;

  Future<AllergenDatasetInfo?> getAllergenDatasetInfo() async {
    try {
      final data = await _client
          .from('app_datasets')
          .select('version, updated_at, summary, added_keys')
          .eq('dataset_name', 'allergens')
          .maybeSingle();

      if (data == null) return null;
      final map = Map<String, dynamic>.from(data);
      return AllergenDatasetInfo(
        version: map['version'] as int? ?? 0,
        updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? ''),
        summary: map['summary'] as String?,
        addedKeys: (map['added_keys'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<String>()
            .toList(growable: false),
      );
    } on PostgrestException {
      return null;
    }
  }

  Future<List<Allergen>> getActiveAllergens() async {
    try {
      final data = await _client
          .from('allergens')
          .select(
            'id, name_key, names, search_terms, severity, eu_regulated, '
            'icon_type, icon_emoji, icon_color, dataset_version',
          )
          .eq('is_active', true)
          .order('id');

      return (data as List<dynamic>)
          .whereType<Map>()
          .map((row) => Allergen.fromJson(Map<String, dynamic>.from(row)))
          .toList(growable: false);
    } on PostgrestException {
      return <Allergen>[];
    }
  }

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
