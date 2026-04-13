import 'package:allergyguard/domain/models/scan_result.dart';

/// Motore di pattern matching multilingua per allergeni.
///
/// Pipeline:
/// 1. Normalizza il testo OCR (lowercase, rimozione accenti, trim)
/// 2. Cerca pattern sezione ('contains' / 'may_contain') con word boundary
/// 3. Per ogni allergene utente, genera varianti (plurale/singolare) e
///    cerca match con word boundary Unicode-aware
/// 4. Scarta i match preceduti/seguiti da negazioni ("senza X", "X-free")
/// 5. Determina il livello di risultato
class AllergenPatternEngine {
  AllergenPatternEngine({
    required List<ContextPattern> verifiedPatterns,
    required Map<String, List<String>> allergenNames,
  })  : _verifiedPatterns = verifiedPatterns,
        _allergenNames = allergenNames {
    _precomputeVariants();
  }

  final List<ContextPattern> _verifiedPatterns;
  final Map<String, List<String>> _allergenNames;
  final Map<String, List<String>> _allergenVariants = {};

  void _precomputeVariants() {
    _allergenNames.forEach((key, names) {
      final variants = <String>{};
      for (final name in names) {
        final normalized = _normalize(name);
        if (normalized.isEmpty) continue;
        variants.addAll(_generateVariants(normalized));
      }
      final sorted = variants.toList()
        ..sort((a, b) => b.length.compareTo(a.length));
      _allergenVariants[key] = sorted;
    });
  }

  ScanResult analyze({
    required String ocrText,
    required List<String> userAllergenKeys,
  }) {
    final normalizedText = _normalize(ocrText);
    final foundAllergens = <String>[];
    final matchedTerms = <String>[];
    var sectionFound = false;

    for (final pattern in _verifiedPatterns) {
      if (pattern.type == 'contains' || pattern.type == 'may_contain') {
        final normalizedPattern = _normalize(pattern.text);
        if (_findWholeTerm(normalizedText, normalizedPattern) != null) {
          sectionFound = true;
          break;
        }
      }
    }

    for (final allergenKey in userAllergenKeys) {
      final variants = _allergenVariants[allergenKey] ?? const <String>[];
      for (final variant in variants) {
        final matchIndex = _findWholeTerm(normalizedText, variant);
        if (matchIndex == null) continue;
        if (_isNegated(normalizedText, matchIndex, matchIndex + variant.length)) {
          continue;
        }
        foundAllergens.add(allergenKey);
        matchedTerms.add(variant);
        break;
      }
    }

    return _determineResult(
      sectionFound: sectionFound,
      foundAllergens: foundAllergens,
      matchedTerms: matchedTerms,
      ocrText: ocrText,
    );
  }

  ScanResult _determineResult({
    required bool sectionFound,
    required List<String> foundAllergens,
    required List<String> matchedTerms,
    required String ocrText,
  }) {
    if (sectionFound && foundAllergens.isNotEmpty) {
      return ScanResult(
        level: ScanResultLevel.danger,
        allergens: foundAllergens,
        ocrText: ocrText,
        highlightTerms: matchedTerms,
      );
    } else if (foundAllergens.isNotEmpty) {
      return ScanResult(
        level: ScanResultLevel.warning,
        allergens: foundAllergens,
        ocrText: ocrText,
        highlightTerms: matchedTerms,
      );
    } else if (sectionFound) {
      return ScanResult(
        level: ScanResultLevel.safe,
        allergens: [],
        ocrText: ocrText,
        highlightTerms: const <String>[],
      );
    } else {
      return ScanResult(
        level: ScanResultLevel.unknown,
        allergens: [],
        ocrText: ocrText,
        highlightTerms: const <String>[],
      );
    }
  }

  String _normalize(String text) => _removeAccents(text.toLowerCase().trim());

  static final _accentMap = {
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'å': 'a',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ø': 'o',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'ñ': 'n',
    'ç': 'c',
    'ß': 'ss',
    'œ': 'oe',
    'æ': 'ae',
    'ý': 'y',
    'ÿ': 'y',
    'š': 's',
    'ž': 'z',
    'č': 'c',
    'ř': 'r',
    'ě': 'e',
    'ů': 'u',
    'ą': 'a',
    'ć': 'c',
    'ę': 'e',
    'ł': 'l',
    'ń': 'n',
    'ś': 's',
    'ź': 'z',
    'ż': 'z',
  };

  String _removeAccents(String text) {
    final buffer = StringBuffer();
    for (final char in text.split('')) {
      buffer.write(_accentMap[char] ?? char);
    }
    return buffer.toString();
  }

  /// Ritorna l'indice del primo match con word boundary, o null.
  /// I termini CJK (cinese/giapponese/coreano) usano substring diretto
  /// perché non hanno separatori di parola.
  int? _findWholeTerm(String text, String term) {
    if (term.isEmpty || term.length > text.length) return null;
    if (_hasCjk(term)) {
      final idx = text.indexOf(term);
      return idx < 0 ? null : idx;
    }
    var searchStart = 0;
    while (searchStart <= text.length - term.length) {
      final index = text.indexOf(term, searchStart);
      if (index < 0) return null;
      final beforeIndex = index - 1;
      final afterIndex = index + term.length;
      final isStartBoundary = beforeIndex < 0 ||
          !_isLetterOrDigit(text.codeUnitAt(beforeIndex));
      final isEndBoundary = afterIndex >= text.length ||
          !_isLetterOrDigit(text.codeUnitAt(afterIndex));
      if (isStartBoundary && isEndBoundary) return index;
      searchStart = index + 1;
    }
    return null;
  }

  static const _negationPhrases = [
    'senza',
    'privo di',
    'privi di',
    'priva di',
    'prive di',
    'without',
    'free from',
    'free of',
    'no added',
    'ohne',
    'frei von',
    'sans',
    'sin',
    'libre de',
    'sem',
    'livre de',
    'zonder',
    'bez',
  ];

  static final _boundarySplitRegExp = RegExp(r'[.,;:!?()\[\]]');
  static final _freeSuffixRegExp =
      RegExp(r'^[\s\-_]*(free|frei|libre|gratis|frei\s*von)\b');

  /// Controlla se un match di allergene è all'interno di una clausola
  /// di negazione ("senza glutine", "gluten-free", ecc).
  bool _isNegated(String text, int matchStart, int matchEnd) {
    final windowStart = matchStart - 40 < 0 ? 0 : matchStart - 40;
    final before = text.substring(windowStart, matchStart);
    final boundaries = _boundarySplitRegExp.allMatches(before).toList();
    final relevantBefore =
        boundaries.isEmpty ? before : before.substring(boundaries.last.end);
    for (final phrase in _negationPhrases) {
      final idx = relevantBefore.indexOf(phrase);
      if (idx < 0) continue;
      final beforePhrase = idx - 1;
      final afterPhrase = idx + phrase.length;
      final isStartOk = beforePhrase < 0 ||
          !_isLetterOrDigit(relevantBefore.codeUnitAt(beforePhrase));
      final isEndOk = afterPhrase >= relevantBefore.length ||
          !_isLetterOrDigit(relevantBefore.codeUnitAt(afterPhrase));
      if (isStartOk && isEndOk) return true;
    }
    final windowEnd =
        matchEnd + 20 > text.length ? text.length : matchEnd + 20;
    final after = text.substring(matchEnd, windowEnd);
    if (_freeSuffixRegExp.hasMatch(after)) return true;
    return false;
  }

  static const _vowels = {'a', 'e', 'i', 'o', 'u'};

  /// Genera varianti plurale/singolare di un termine.
  /// Approccio conservativo: solo trasformazioni sicure sui suffissi comuni.
  Set<String> _generateVariants(String term) {
    final variants = <String>{term};
    if (term.length < 4 || _hasCjk(term)) return variants;

    if (term.endsWith('es') && term.length > 5) {
      variants.add(term.substring(0, term.length - 2));
    }
    if (term.endsWith('s') && term.length > 4) {
      variants.add(term.substring(0, term.length - 1));
    } else {
      variants.add('${term}s');
      if (term.endsWith('x') ||
          term.endsWith('ch') ||
          term.endsWith('sh') ||
          term.endsWith('z')) {
        variants.add('${term}es');
      }
    }

    if (term.endsWith('en') && term.length > 5) {
      variants.add(term.substring(0, term.length - 2));
    }
    if (term.endsWith('er') && term.length > 5) {
      variants.add(term.substring(0, term.length - 2));
    }

    final last = term[term.length - 1];
    if (_vowels.contains(last)) {
      final stem = term.substring(0, term.length - 1);
      if (stem.length >= 3) {
        if (last == 'i') {
          variants..add('${stem}o')..add('${stem}e')..add('${stem}a');
        } else if (last == 'e') {
          variants..add('${stem}i')..add('${stem}a')..add('${stem}o');
        } else if (last == 'o') {
          variants..add('${stem}i')..add('${stem}a');
        } else if (last == 'a') {
          variants..add('${stem}e')..add('${stem}i')..add('${stem}o');
        }
      }
      if (stem.length >= 4) {
        variants.add(stem);
      }
    }

    return variants;
  }

  bool _hasCjk(String text) {
    for (final rune in text.runes) {
      if ((rune >= 0x4E00 && rune <= 0x9FFF) ||
          (rune >= 0x3040 && rune <= 0x30FF) ||
          (rune >= 0xAC00 && rune <= 0xD7AF)) {
        return true;
      }
    }
    return false;
  }

  /// Unicode-aware letter/digit detection per confini di parola.
  /// Copre Latin + estensioni, Greco, Cirillico, Arabo, Ebraico, CJK,
  /// sufficiente per le 20 lingue supportate.
  bool _isLetterOrDigit(int codeUnit) {
    if (codeUnit >= 0x30 && codeUnit <= 0x39) return true;
    if ((codeUnit >= 0x41 && codeUnit <= 0x5A) ||
        (codeUnit >= 0x61 && codeUnit <= 0x7A)) {
      return true;
    }
    if (codeUnit >= 0xC0 &&
        codeUnit <= 0xFF &&
        codeUnit != 0xD7 &&
        codeUnit != 0xF7) {
      return true;
    }
    if (codeUnit >= 0x100 && codeUnit <= 0x17F) return true;
    if (codeUnit >= 0x180 && codeUnit <= 0x24F) return true;
    if (codeUnit >= 0x370 && codeUnit <= 0x3FF) return true;
    if (codeUnit >= 0x400 && codeUnit <= 0x4FF) return true;
    if (codeUnit >= 0x621 && codeUnit <= 0x64A) return true;
    if (codeUnit >= 0x5D0 && codeUnit <= 0x5EA) return true;
    if (codeUnit >= 0x4E00 && codeUnit <= 0x9FFF) return true;
    if (codeUnit >= 0x3040 && codeUnit <= 0x309F) return true;
    if (codeUnit >= 0x30A0 && codeUnit <= 0x30FF) return true;
    if (codeUnit >= 0xAC00 && codeUnit <= 0xD7AF) return true;
    return false;
  }
}

/// Modello per i pattern di contesto caricati dal JSON/Supabase.
class ContextPattern {
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
  final String id;
  final String text;
  final String language;
  final String type; // 'contains' | 'may_contain' | 'facility'
  final String status; // 'candidate' | 'verified'
  final double confidence;

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'language': language,
        'type': type,
        'status': status,
        'confidence': confidence,
      };
}
