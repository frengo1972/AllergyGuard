import 'package:supabase_flutter/supabase_flutter.dart';

/// Servizio per caricare pattern candidati su Supabase
/// e accodarli localmente per sync offline.
class ContextUploadService {

  ContextUploadService({required SupabaseClient supabase})
      : _supabase = supabase;
  final SupabaseClient _supabase;

  /// Carica un pattern candidato su Supabase.
  Future<void> upload({
    required String patternText,
    required String languageCode,
    required String patternType,
    required double confidence,
    required String sourceOcrText,
    required String deviceId,
  }) async {
    await _supabase.from('context_patterns').upsert(
      {
        'pattern_text': patternText,
        'language_code': languageCode,
        'pattern_type': patternType,
        'confidence': confidence,
        'status': 'candidate',
        'seen_count': 1,
        'device_ids': [deviceId],
        'source_ocr_text': sourceOcrText,
      },
      onConflict: 'pattern_text,language_code',
    );
  }

  /// Accoda un pattern per upload successivo (modalità offline).
  Future<void> queueForLater({
    required String patternText,
    required String sourceOcrText,
    required String deviceId,
  }) async {
    // TODO: Salvare in Drift per sync successivo
  }

  /// Sincronizza i pattern accodati quando torna la connessione.
  Future<void> syncQueued() async {
    // TODO: Leggere dalla coda Drift e caricare su Supabase
  }
}
