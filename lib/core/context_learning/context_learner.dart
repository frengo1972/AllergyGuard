import 'package:allergyguard/core/allergen_patterns/context_extractor.dart';
import 'package:allergyguard/core/constants.dart';
import 'package:allergyguard/core/context_learning/claude_validator.dart';
import 'package:allergyguard/core/context_learning/context_upload_service.dart';

/// Pipeline di apprendimento contesti.
///
/// Quando l'OCR trova un allergene noto nel testo, il testo circostante
/// diventa un potenziale nuovo pattern. Questa pipeline:
/// 1. Estrae il contesto (60 char prima, 30 dopo)
/// 2. Valida con Claude API (se confidence OCR >= 85%)
/// 3. Carica su Supabase come candidato
class ContextLearner {
  final ContextExtractor _extractor;
  final ClaudeValidator _validator;
  final ContextUploadService _uploadService;

  ContextLearner({
    required ContextExtractor extractor,
    required ClaudeValidator validator,
    required ContextUploadService uploadService,
  })  : _extractor = extractor,
        _validator = validator,
        _uploadService = uploadService;

  /// Esegue la pipeline di apprendimento in background.
  /// Non blocca la UI.
  Future<void> learn({
    required String ocrText,
    required double ocrConfidence,
    required List<AllergenMatch> matches,
    required Set<String> existingPatterns,
    required String deviceId,
  }) async {
    // Soglia pre-invio: OCR confidence >= 85%
    if (ocrConfidence < AppConstants.contextMinConfidence) return;

    final contexts = _extractor.extract(
      ocrText: ocrText,
      matches: matches,
      existingPatterns: existingPatterns,
    );

    for (final context in contexts) {
      try {
        final validation = await _validator.validate(context.text);

        if (validation == null) continue;
        if (!validation.isValid) continue;
        if (validation.confidence < AppConstants.claudeMinConfidence) continue;

        await _uploadService.upload(
          patternText: context.text,
          languageCode: validation.detectedLanguage,
          patternType: validation.patternType,
          confidence: validation.confidence,
          sourceOcrText: context.sourceOcrText,
          deviceId: deviceId,
        );
      } catch (_) {
        // Accoda per retry offline
        await _uploadService.queueForLater(
          patternText: context.text,
          sourceOcrText: context.sourceOcrText,
          deviceId: deviceId,
        );
      }
    }
  }
}
