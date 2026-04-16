import 'dart:ui';

import 'package:allergyguard/core/allergen_patterns/allergen_ocr_match_extractor.dart';
import 'package:allergyguard/core/ocr/ocr_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const extractor = AllergenOcrMatchExtractor();

  OcrResult buildResult({
    required String text,
    required List<OcrTextLineData> lines,
  }) {
    return OcrResult(
      text: text,
      confidence: 0.99,
      source: OcrSource.mlKit,
      lines: lines,
    );
  }

  group('AllergenOcrMatchExtractor', () {
    test('does not match a shorter translation inside a longer word', () {
      final result = buildResult(
        text: 'Ingredienti: sesamo.',
        lines: const [
          OcrTextLineData(
            text: 'Ingredienti: sesamo.',
            elements: [
              OcrTextElementData(text: 'Ingredienti:'),
              OcrTextElementData(text: 'sesamo'),
            ],
          ),
        ],
      );

      final matches = extractor.extract(
        ocrResult: result,
        selectedAllergenKeys: const ['sesame'],
        allergenTranslationsByKey: const {
          'sesame': {
            'it': 'sesamo',
            'de': 'sesam',
          },
        },
        localizedAllergenNames: const {'sesame': 'Sesamo'},
      );

      expect(matches, hasLength(1));
      expect(matches.single.matchedText, 'sesamo');
      expect(matches.single.languageCode, 'it');
      expect(matches.single.isPartial, isFalse);
    });

    test('deduplicates same recognized word across multiple languages', () {
      final result = buildResult(
        text: 'Contains sesam.',
        lines: const [
          OcrTextLineData(
            text: 'Contains sesam.',
            elements: [
              OcrTextElementData(text: 'Contains'),
              OcrTextElementData(text: 'sesam'),
            ],
          ),
        ],
      );

      final matches = extractor.extract(
        ocrResult: result,
        selectedAllergenKeys: const ['sesame'],
        allergenTranslationsByKey: const {
          'sesame': {
            'de': 'sesam',
            'nl': 'sesam',
            'sv': 'sesam',
          },
        },
        localizedAllergenNames: const {'sesame': 'Sesamo'},
      );

      expect(matches, hasLength(1));
      expect(matches.single.matchedText, 'sesam');
    });

    test('matches a whole word followed by punctuation', () {
      final result = buildResult(
        text: 'Ingredienti: sesamo, sale.',
        lines: const [
          OcrTextLineData(
            text: 'Ingredienti: sesamo, sale.',
            elements: [
              OcrTextElementData(text: 'Ingredienti:'),
              OcrTextElementData(
                text: 'sesamo,',
                boundingBox: Rect.fromLTRB(10, 10, 40, 20),
              ),
              OcrTextElementData(text: 'sale.'),
            ],
          ),
        ],
      );

      final matches = extractor.extract(
        ocrResult: result,
        selectedAllergenKeys: const ['sesame'],
        allergenTranslationsByKey: const {
          'sesame': {
            'it': 'sesamo',
          },
        },
        localizedAllergenNames: const {'sesame': 'Sesamo'},
      );

      expect(matches, hasLength(1));
      expect(matches.single.matchedText, 'sesamo');
      expect(matches.single.containingText, 'sesamo,');
      expect(matches.single.boundingBox, isNotNull);
    });

    test('does not match inside a longer token', () {
      final result = buildResult(
        text: 'Prodotto soiaqualcosa inventato.',
        lines: const [
          OcrTextLineData(
            text: 'Prodotto soiaqualcosa inventato.',
            elements: [
              OcrTextElementData(text: 'Prodotto'),
              OcrTextElementData(text: 'soiaqualcosa'),
              OcrTextElementData(text: 'inventato.'),
            ],
          ),
        ],
      );

      final matches = extractor.extract(
        ocrResult: result,
        selectedAllergenKeys: const ['soy'],
        allergenTranslationsByKey: const {
          'soy': {
            'it': 'soia',
          },
        },
        localizedAllergenNames: const {'soy': 'Soia'},
      );

      expect(matches, isEmpty);
    });

    test('keeps only the best match per allergen when requested', () {
      final result = buildResult(
        text: 'Ingredienti: sesamo. Allergeni: sesam.',
        lines: const [
          OcrTextLineData(
            text: 'Ingredienti: sesamo.',
            elements: [
              OcrTextElementData(text: 'Ingredienti:'),
              OcrTextElementData(
                text: 'sesamo',
                boundingBox: Rect.fromLTRB(10, 10, 50, 20),
              ),
            ],
          ),
          OcrTextLineData(
            text: 'Allergeni: sesam.',
            elements: [
              OcrTextElementData(text: 'Allergeni:'),
              OcrTextElementData(text: 'sesam'),
            ],
          ),
        ],
      );

      final matches = extractor.extract(
        ocrResult: result,
        selectedAllergenKeys: const ['sesame'],
        allergenTranslationsByKey: const {
          'sesame': {
            'it': 'sesamo',
            'de': 'sesam',
          },
        },
        localizedAllergenNames: const {'sesame': 'Sesamo'},
        singleBestMatchPerAllergen: true,
      );

      expect(matches, hasLength(1));
      expect(matches.single.matchedText, 'sesamo');
      expect(matches.single.languageCode, 'it');
    });
  });
}
