/// Costanti di configurazione dell'applicazione AllergyGuard.
class AppConstants {
  AppConstants._();

  // Soglie OCR
  static const double ocrMinConfidence = 0.60;

  // Soglie Context Learning
  static const double contextMinConfidence = 0.85;
  static const double claudeMinConfidence = 0.70;
  static const int contextWindowBefore = 60;
  static const int contextWindowAfter = 30;
  static const int contextMinLength = 3;
  static const int contextMaxLength = 80;

  // Soglie promozione pattern
  static const int patternPromoteSeenCount = 5;
  static const int patternPromoteDeviceCount = 3;

  // Cache e storico
  static const int offCacheTtlDays = 7;
  static const int localHistoryMaxDays = 30;
  static const int offlineCacheMaxProducts = 50;

  // Camera
  static const int cameraOcrIntervalMs = 800;

  // Claude API
  static const String claudeModel = 'claude-sonnet-4-20250514';
  static const String claudeSystemPrompt = '''
You are a food label allergen expert. You will receive a text fragment
extracted from a food product label using OCR. Your task is to evaluate
if this fragment is a valid allergen declaration context from a food label.

Respond ONLY with valid JSON, no markdown, no preamble:
{
  "is_valid_label_context": boolean,
  "confidence": float (0.0-1.0),
  "pattern_type": "contains"|"may_contain"|"facility"|"unknown",
  "detected_language": "ISO 639-1 code",
  "translations": {
    "it": "...", "en": "...", "de": "...", "fr": "...",
    "es": "...", "pt": "...", "nl": "...", "pl": "...",
    "ja": "...", "zh": "...", "ko": "...", "ar": "...",
    "tr": "...", "sv": "...", "da": "...", "fi": "..."
  },
  "rejection_reason": "string or null"
}''';
}
