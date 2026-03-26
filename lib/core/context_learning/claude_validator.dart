import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:allergyguard/core/constants.dart';

/// Chiama Claude API per validare e tradurre nuovi pattern candidati.
/// La chiamata è asincrona e non blocca la UI.
class ClaudeValidator {
  final Dio _dio;
  final String _apiKey;

  ClaudeValidator({
    required Dio dio,
    required String apiKey,
  })  : _dio = dio,
        _apiKey = apiKey;

  /// Valida un frammento di testo estratto da un'etichetta.
  /// Ritorna null se la validazione fallisce.
  Future<ClaudeValidationResult?> validate(String contextText) async {
    try {
      final response = await _dio.post(
        'https://api.anthropic.com/v1/messages',
        options: Options(headers: {
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        }),
        data: {
          'model': AppConstants.claudeModel,
          'max_tokens': 500,
          'system': AppConstants.claudeSystemPrompt,
          'messages': [
            {
              'role': 'user',
              'content':
                  'Evaluate this text fragment from a food label OCR: "$contextText"',
            }
          ],
        },
      );

      final content = response.data['content'] as List<dynamic>;
      final text = content.first['text'] as String;
      final parsed = json.decode(text) as Map<String, dynamic>;

      return ClaudeValidationResult(
        isValid: parsed['is_valid_label_context'] as bool,
        confidence: (parsed['confidence'] as num).toDouble(),
        patternType: parsed['pattern_type'] as String,
        detectedLanguage: parsed['detected_language'] as String,
        translations:
            (parsed['translations'] as Map<String, dynamic>?)?.cast<String, String>() ?? {},
        rejectionReason: parsed['rejection_reason'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

class ClaudeValidationResult {
  final bool isValid;
  final double confidence;
  final String patternType;
  final String detectedLanguage;
  final Map<String, String> translations;
  final String? rejectionReason;

  const ClaudeValidationResult({
    required this.isValid,
    required this.confidence,
    required this.patternType,
    required this.detectedLanguage,
    required this.translations,
    this.rejectionReason,
  });
}
