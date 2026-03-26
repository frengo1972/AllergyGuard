import 'package:allergyguard/domain/models/scan_result.dart';

/// Motore di pattern matching multilingua per allergeni.
///
/// Opera in quest'ordine:
/// 1. Normalizza il testo OCR (lowercase, rimozione accenti, trim)
/// 2. Cerca pattern 'type: contains' nel testo → sezione allergeni PRESENT
/// 3. Cerca nome allergene (in tutte le lingue) nel testo
/// 4. Determina il livello di risultato
class AllergenPatternEngine {
  final List<ContextPattern> _verifiedPatterns;
  final Map<String, List<String>> _allergenNames;

  AllergenPatternEngine({
    required List<ContextPattern> verifiedPatterns,
    required Map<String, List<String>> allergenNames,
  })  : _verifiedPatterns = verifiedPatterns,
        _allergenNames = allergenNames;

  ScanResult analyze({
    required String ocrText,
    required List<String> userAllergenKeys,
  }) {
    final normalizedText = _normalize(ocrText);
    final foundAllergens = <String>[];
    var sectionFound = false;

    // Cerca sezione allergeni nel testo
    for (final pattern in _verifiedPatterns) {
      if (pattern.type == 'contains' || pattern.type == 'may_contain') {
        final normalizedPattern = _normalize(pattern.text);
        if (normalizedText.contains(normalizedPattern)) {
          sectionFound = true;
          break;
        }
      }
    }

    // Cerca allergeni dell'utente nel testo
    for (final allergenKey in userAllergenKeys) {
      final names = _allergenNames[allergenKey] ?? [];
      for (final name in names) {
        final normalizedName = _normalize(name);
        if (normalizedName.isNotEmpty &&
            normalizedText.contains(normalizedName)) {
          foundAllergens.add(allergenKey);
          break;
        }
      }
    }

    return _determineResult(
      sectionFound: sectionFound,
      foundAllergens: foundAllergens,
      ocrText: ocrText,
    );
  }

  ScanResult _determineResult({
    required bool sectionFound,
    required List<String> foundAllergens,
    required String ocrText,
  }) {
    if (sectionFound && foundAllergens.isNotEmpty) {
      return ScanResult(
        level: ScanResultLevel.danger,
        allergens: foundAllergens,
        ocrText: ocrText,
      );
    } else if (foundAllergens.isNotEmpty) {
      return ScanResult(
        level: ScanResultLevel.warning,
        allergens: foundAllergens,
        ocrText: ocrText,
      );
    } else if (sectionFound) {
      return ScanResult(
        level: ScanResultLevel.safe,
        allergens: [],
        ocrText: ocrText,
      );
    } else {
      return ScanResult(
        level: ScanResultLevel.unknown,
        allergens: [],
        ocrText: ocrText,
      );
    }
  }

  /// Normalizza il testo: lowercase, rimozione accenti, trim.
  String _normalize(String text) {
    return _removeAccents(text.toLowerCase().trim());
  }

  static final _accentMap = {
    'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
    'ñ': 'n', 'ç': 'c', 'ß': 'ss',
  };

  String _removeAccents(String text) {
    return text.split('').map((c) => _accentMap[c] ?? c).join();
  }
}

/// Modello per i pattern di contesto caricati dal JSON/Supabase.
class ContextPattern {
  final String id;
  final String text;
  final String language;
  final String type; // 'contains' | 'may_contain' | 'facility'
  final String status; // 'candidate' | 'verified'
  final double confidence;

  const ContextPattern({
    required this.id,
    required this.text,
    required this.language,
    required this.type,
    required this.status,
    required this.confidence,
  });

  factory ContextPattern.fromJson(Map<String, dynamic> json) {
    return ContextPattern(
      id: json['id'] as String,
      text: json['text'] as String,
      language: json['language'] as String,
      type: json['type'] as String,
      status: json['status'] as String? ?? 'candidate',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'language': language,
        'type': type,
        'status': status,
        'confidence': confidence,
      };
}
