import 'package:allergyguard/core/constants.dart';

/// Estrae il contesto attorno ad un allergene trovato nel testo OCR.
///
/// Finestra di estrazione:
/// - 60 caratteri PRIMA dell'allergene
/// - 30 caratteri DOPO l'allergene
class ContextExtractor {
  /// Estrae contesti candidati dal testo OCR per ogni allergene trovato.
  List<ExtractedContext> extract({
    required String ocrText,
    required List<AllergenMatch> matches,
    required Set<String> existingPatterns,
  }) {
    final results = <ExtractedContext>[];

    for (final match in matches) {
      final start = (match.startIndex - AppConstants.contextWindowBefore)
          .clamp(0, ocrText.length);
      final end = (match.endIndex + AppConstants.contextWindowAfter)
          .clamp(0, ocrText.length);

      final rawContext = ocrText.substring(start, end);

      // Rimuovi il nome dell'allergene dal contesto
      final cleanContext = rawContext
          .replaceAll(RegExp(RegExp.escape(match.allergenName), caseSensitive: false), '')
          .trim()
          .toLowerCase();

      // Validazioni
      if (cleanContext.length < AppConstants.contextMinLength) continue;
      if (cleanContext.length > AppConstants.contextMaxLength) continue;
      if (existingPatterns.contains(cleanContext)) continue;

      results.add(ExtractedContext(
        text: cleanContext,
        sourceOcrText: ocrText,
        allergenKey: match.allergenKey,
      ));
    }

    return results;
  }
}

class AllergenMatch {

  const AllergenMatch({
    required this.allergenKey,
    required this.allergenName,
    required this.startIndex,
    required this.endIndex,
  });
  final String allergenKey;
  final String allergenName;
  final int startIndex;
  final int endIndex;
}

class ExtractedContext {

  const ExtractedContext({
    required this.text,
    required this.sourceOcrText,
    required this.allergenKey,
  });
  final String text;
  final String sourceOcrText;
  final String allergenKey;
}
