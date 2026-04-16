import 'package:supabase_flutter/supabase_flutter.dart';

enum FeedbackType {
  scanAccuracy('scan_accuracy'),
  suggestion('suggestion'),
  bugReport('bug_report'),
  general('general');

  const FeedbackType(this.apiValue);
  final String apiValue;
}

/// Repository remoto per feedback utente.
///
/// Inserisce record anonimi nella tabella `user_feedback` di Supabase.
/// Il client può essere null se il backend non è configurato: in quel caso
/// [submit] ritorna false e il chiamante può mettere in coda o avvisare.
class FeedbackRemoteRepository {
  FeedbackRemoteRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  bool get isConfigured => _client != null;

  Future<bool> submitPayload(Map<String, dynamic> payload) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('user_feedback').insert(payload);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> submit({
    required String deviceId,
    required FeedbackType type,
    String? resultLevel,
    bool? isCorrect,
    String? expectedLevel,
    String? productBarcode,
    List<String> allergenKeys = const <String>[],
    String? comment,
    String? languageCode,
    String? countryCode,
    String? appVersion,
  }) async {
    return submitPayload({
      'device_id': deviceId,
      'feedback_type': type.apiValue,
      'result_level': resultLevel,
      'is_correct': isCorrect,
      'expected_level': expectedLevel,
      'product_barcode': productBarcode,
      'allergen_keys': allergenKeys,
      'comment': comment,
      'language_code': languageCode,
      'country_code': countryCode,
      'app_version': appVersion,
    });
  }
}
