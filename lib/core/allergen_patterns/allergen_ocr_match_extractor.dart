import 'package:allergyguard/core/ocr/ocr_service.dart';
import 'package:allergyguard/domain/models/scan_result.dart';

/// Estrae match OCR leggibili per la UI evitando sottostringhe fuorvianti.
class AllergenOcrMatchExtractor {
  const AllergenOcrMatchExtractor();

  List<ScanResultMatch> extract({
    required OcrResult ocrResult,
    required Iterable<String> selectedAllergenKeys,
    required Map<String, Map<String, String>> allergenTranslationsByKey,
    required Map<String, String> localizedAllergenNames,
    bool singleBestMatchPerAllergen = false,
  }) {
    final matchesBySignature = <String, ScanResultMatch>{};

    for (final allergenKey in selectedAllergenKeys) {
      final translations = allergenTranslationsByKey[allergenKey];
      if (translations == null) continue;

      for (final entry in translations.entries) {
        final term = entry.value.trim();
        final normalizedTerm = _normalizeText(term);
        if (normalizedTerm.isEmpty) continue;

        for (final line in ocrResult.lines) {
          var matchedElementInLine = false;

          for (final element in line.elements) {
            final word = element.text.trim();
            final normalizedWord = _normalizeText(word);
            if (normalizedWord.isEmpty ||
                !_containsWholeNormalizedTerm(normalizedWord, normalizedTerm)) {
              continue;
            }

            matchedElementInLine = true;
            _registerMatch(
              matchesBySignature,
              ScanResultMatch(
                allergenKey: allergenKey,
                localizedAllergenName:
                    localizedAllergenNames[allergenKey] ?? allergenKey,
                matchedText: _extractMatchedSubstring(
                  word,
                  term,
                  normalizedTerm,
                ),
                containingText: word,
                languageCode: entry.key,
                languageLabel: _languageLabelForCode(entry.key),
                isPartial: false,
                boundingBox: element.boundingBox ?? line.boundingBox,
                lineText: line.text,
              ),
            );
          }

          final normalizedLine = _normalizeText(line.text);
          final isWholeLineMatch = _containsWholeNormalizedTerm(
            normalizedLine,
            normalizedTerm,
          );
          if (!isWholeLineMatch ||
              (!term.contains(' ') && matchedElementInLine)) {
            continue;
          }

          _registerMatch(
            matchesBySignature,
            ScanResultMatch(
              allergenKey: allergenKey,
              localizedAllergenName:
                  localizedAllergenNames[allergenKey] ?? allergenKey,
              matchedText: term,
              containingText: line.text.trim(),
              languageCode: entry.key,
              languageLabel: _languageLabelForCode(entry.key),
              isPartial: false,
              boundingBox: line.boundingBox,
              lineText: line.text,
            ),
          );
        }
      }
    }

    var matches = matchesBySignature.values.toList();
    if (singleBestMatchPerAllergen) {
      matches = _keepSingleBestMatchPerAllergen(matches);
    }

    matches.sort((left, right) {
      final allergenCompare =
          left.localizedAllergenName.compareTo(right.localizedAllergenName);
      if (allergenCompare != 0) return allergenCompare;

      final lineCompare = left.containingText
          .toLowerCase()
          .compareTo(right.containingText.toLowerCase());
      if (lineCompare != 0) return lineCompare;

      return left.languageLabel.compareTo(right.languageLabel);
    });
    return matches;
  }

  List<ScanResultMatch> _keepSingleBestMatchPerAllergen(
    List<ScanResultMatch> matches,
  ) {
    final bestByAllergen = <String, ScanResultMatch>{};
    for (final match in matches) {
      final existing = bestByAllergen[match.allergenKey];
      if (existing == null || _shouldPrefer(match, existing)) {
        bestByAllergen[match.allergenKey] = match;
      }
    }
    return bestByAllergen.values.toList(growable: false);
  }

  void _registerMatch(
    Map<String, ScanResultMatch> matchesBySignature,
    ScanResultMatch candidate,
  ) {
    final signature = [
      candidate.allergenKey,
      _normalizeText(candidate.containingText),
      _normalizeText(candidate.lineText ?? candidate.containingText),
    ].join('|');
    final existing = matchesBySignature[signature];
    if (existing == null || _shouldPrefer(candidate, existing)) {
      matchesBySignature[signature] = candidate;
    }
  }

  bool _shouldPrefer(ScanResultMatch candidate, ScanResultMatch existing) {
    final candidateHasBox = candidate.boundingBox != null ? 1 : 0;
    final existingHasBox = existing.boundingBox != null ? 1 : 0;
    if (candidateHasBox != existingHasBox) {
      return candidateHasBox > existingHasBox;
    }

    final candidateLength = _normalizeText(candidate.matchedText).length;
    final existingLength = _normalizeText(existing.matchedText).length;
    if (candidateLength != existingLength) {
      return candidateLength > existingLength;
    }

    final candidateContainingLength =
        _normalizeText(candidate.containingText).length;
    final existingContainingLength =
        _normalizeText(existing.containingText).length;
    if (candidateContainingLength != existingContainingLength) {
      return candidateContainingLength < existingContainingLength;
    }

    final candidateText = _normalizeText(candidate.matchedText);
    final existingText = _normalizeText(existing.matchedText);
    if (candidateText != existingText) {
      return candidateText.compareTo(existingText) < 0;
    }

    return candidate.languageCode.compareTo(existing.languageCode) < 0;
  }

  String _extractMatchedSubstring(
    String word,
    String originalTerm,
    String normalizedTerm,
  ) {
    final lowerWord = word.toLowerCase();
    final lowerTerm = originalTerm.toLowerCase();
    final directIndex = lowerWord.indexOf(lowerTerm);
    if (directIndex >= 0) {
      return word.substring(directIndex, directIndex + originalTerm.length);
    }

    final normalizedWord = _normalizeText(word);
    final normalizedIndex = normalizedWord.indexOf(normalizedTerm);
    if (normalizedIndex < 0) {
      return originalTerm;
    }

    final start = normalizedIndex.clamp(0, word.length);
    final end = (start + originalTerm.length).clamp(start, word.length);
    return word.substring(start, end);
  }

  String _normalizeText(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool _containsWholeNormalizedTerm(String text, String term) {
    var searchStart = 0;
    while (true) {
      final index = text.indexOf(term, searchStart);
      if (index < 0) return false;

      final beforeIndex = index - 1;
      final afterIndex = index + term.length;
      final isStartBoundary =
          beforeIndex < 0 || !_isAsciiLetterOrDigit(text[beforeIndex]);
      final isEndBoundary =
          afterIndex >= text.length || !_isAsciiLetterOrDigit(text[afterIndex]);

      if (isStartBoundary && isEndBoundary) {
        return true;
      }
      searchStart = index + 1;
    }
  }

  bool _isAsciiLetterOrDigit(String char) {
    final codeUnit = char.codeUnitAt(0);
    return (codeUnit >= 48 && codeUnit <= 57) ||
        (codeUnit >= 65 && codeUnit <= 90) ||
        (codeUnit >= 97 && codeUnit <= 122);
  }

  String _languageLabelForCode(String languageCode) {
    const labels = <String, String>{
      'it': 'Italiano',
      'en': 'English',
      'de': 'Deutsch',
      'fr': 'Francais',
      'es': 'Espanol',
      'zh': 'Chinese',
      'ja': 'Japanese',
    };
    return labels[languageCode] ?? languageCode.toUpperCase();
  }
}
