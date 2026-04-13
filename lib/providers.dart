import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:allergyguard/core/allergen_patterns/pattern_repository.dart';
import 'package:allergyguard/core/allergen_patterns/context_extractor.dart';
import 'package:allergyguard/core/ocr/ocr_service.dart';
import 'package:allergyguard/core/ocr/mlkit_ocr.dart';
import 'package:allergyguard/core/ocr/cloud_vision_ocr.dart';
import 'package:allergyguard/core/scanner/barcode_scanner.dart';
import 'package:allergyguard/core/scanner/open_food_facts_client.dart';
import 'package:allergyguard/core/tts/tts_service.dart';
import 'package:allergyguard/data/remote/allergen_remote_repo.dart';
import 'package:allergyguard/data/remote/feedback_remote_repo.dart';

/// Provider Dio HTTP client
final dioProvider = Provider<Dio>((ref) => Dio());

/// Provider Supabase client (throws se Supabase non inizializzato).
final supabaseProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

/// Provider Supabase client opzionale: ritorna null se backend non configurato.
final optionalSupabaseProvider = Provider<SupabaseClient?>((ref) {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
});

/// Provider Pattern Repository
final patternRepositoryProvider = Provider<PatternRepository>(
  (ref) => PatternRepository(),
);

/// Provider Context Extractor
final contextExtractorProvider = Provider<ContextExtractor>(
  (ref) => ContextExtractor(),
);

/// Provider OCR Service
final ocrServiceProvider = Provider<OcrService>((ref) {
  final dio = ref.watch(dioProvider);
  return OcrService(
    mlKitOcr: MlKitOcr(),
    cloudVisionOcr: CloudVisionOcr(
      dio: dio,
      apiKey: '', // Da .env via edge function
    ),
  );
});

/// Provider Barcode Scanner
final barcodeScannerProvider = Provider<BarcodeScannerService>(
  (ref) => BarcodeScannerService(),
);

/// Provider Open Food Facts client
final openFoodFactsProvider = Provider<OpenFoodFactsClient>((ref) {
  return OpenFoodFactsClient(dio: ref.watch(dioProvider));
});

/// Provider TTS Service
final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService();
});

/// Provider Allergen Remote Repository
final allergenRemoteRepoProvider = Provider<AllergenRemoteRepository>((ref) {
  return AllergenRemoteRepository(client: ref.watch(supabaseProvider));
});

/// Provider Feedback Remote Repository (accetta backend opzionale).
final feedbackRemoteRepoProvider = Provider<FeedbackRemoteRepository>((ref) {
  return FeedbackRemoteRepository(client: ref.watch(optionalSupabaseProvider));
});
