import 'package:allergyguard/core/allergen_patterns/allergen_pattern_engine.dart';
import 'package:allergyguard/domain/models/scan_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sectionPatterns = <ContextPattern>[
    const ContextPattern(
      id: 'it-contains',
      text: 'contiene',
      language: 'it',
      type: 'contains',
      status: 'verified',
      confidence: 1.0,
    ),
    const ContextPattern(
      id: 'it-may',
      text: 'puo contenere tracce',
      language: 'it',
      type: 'may_contain',
      status: 'verified',
      confidence: 1.0,
    ),
    const ContextPattern(
      id: 'en-contains',
      text: 'contains',
      language: 'en',
      type: 'contains',
      status: 'verified',
      confidence: 1.0,
    ),
    const ContextPattern(
      id: 'de-contains',
      text: 'enthalt',
      language: 'de',
      type: 'contains',
      status: 'verified',
      confidence: 1.0,
    ),
  ];

  final allergenNames = <String, List<String>>{
    'gluten': ['glutine', 'gluten', 'Gluten'],
    'peanut': ['arachidi', 'peanuts', 'Erdnüsse', 'arachides'],
    'milk': ['latte', 'milk', 'Milch', 'lait'],
    'egg': ['uova', 'eggs', 'Eier'],
    'soy': ['soia', 'soybeans', 'Soja'],
    'sesame': ['sesamo', 'sesame'],
    'sulphite': ['solfiti', 'sulphites'],
  };

  AllergenPatternEngine buildEngine() => AllergenPatternEngine(
        verifiedPatterns: sectionPatterns,
        allergenNames: allergenNames,
      );

  group('word boundary', () {
    test('no match when allergen word is inside another word', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Contenitore riciclabile. Prodotto biologico.',
        userAllergenKeys: ['milk'],
      );
      expect(result.level, ScanResultLevel.unknown);
      expect(result.allergens, isEmpty);
    });

    test('section word "contiene" not matched inside "contenitore"', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Contenitore in vetro. Ingredienti: farina.',
        userAllergenKeys: ['gluten'],
      );
      expect(result.level, ScanResultLevel.unknown);
    });

    test('allergen at start of text matches with space boundary', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Latte fresco di alta qualita',
        userAllergenKeys: ['milk'],
      );
      expect(result.allergens, contains('milk'));
    });

    test('allergen followed by punctuation matches', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Ingredienti: latte, zucchero, cacao.',
        userAllergenKeys: ['milk'],
      );
      expect(result.allergens, contains('milk'));
    });

    test('does not match "gluten" inside "glutenfrei" when EN allergen', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'This product is glutenfrei und laktosefrei',
        userAllergenKeys: ['gluten'],
      );
      expect(result.allergens, isEmpty);
    });
  });

  group('plurals and singulars', () {
    test('EN plural "peanuts" matches "peanut" in text', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Contains peanut oil and sugar.',
        userAllergenKeys: ['peanut'],
      );
      expect(result.allergens, contains('peanut'));
      expect(result.level, ScanResultLevel.danger);
    });

    test('EN singular "milk" matches "milks" in text', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Contains milks from various sources',
        userAllergenKeys: ['milk'],
      );
      expect(result.allergens, contains('milk'));
    });

    test('IT plural "arachidi" matches "arachide" in text', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Contiene olio di arachide raffinato',
        userAllergenKeys: ['peanut'],
      );
      expect(result.allergens, contains('peanut'));
    });

    test('IT plural "uova" matches "uovo" in text', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Contiene uovo intero pastorizzato',
        userAllergenKeys: ['egg'],
      );
      expect(result.allergens, contains('egg'));
    });

    test('DE plural "Erdnüsse" matches "Erdnuss" (stripped -e)', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'enthalt Erdnuss und Milch',
        userAllergenKeys: ['peanut'],
      );
      expect(result.allergens, contains('peanut'));
    });

    test('FR plural "arachides" matches "arachide" in text', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Contient de l arachide grillee',
        userAllergenKeys: ['peanut'],
      );
      expect(result.allergens, contains('peanut'));
    });
  });

  group('negations', () {
    test('IT "senza glutine" does not trigger gluten', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Prodotto senza glutine e senza lattosio.',
        userAllergenKeys: ['gluten'],
      );
      expect(result.allergens, isEmpty);
    });

    test('EN "gluten-free" does not trigger gluten', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Certified gluten-free product. Safe to eat.',
        userAllergenKeys: ['gluten'],
      );
      expect(result.allergens, isEmpty);
    });

    test('DE "ohne Milch" does not trigger milk', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Hergestellt ohne Milch und Eier.',
        userAllergenKeys: ['milk'],
      );
      expect(result.allergens, isEmpty);
    });

    test('FR "sans lait" does not trigger milk', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Fabrique sans lait et sans oeuf.',
        userAllergenKeys: ['milk'],
      );
      expect(result.allergens, isEmpty);
    });

    test('ES "sin soja" does not trigger soy', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Producto sin soja y sin lactosa.',
        userAllergenKeys: ['soy'],
      );
      expect(result.allergens, isEmpty);
    });

    test('negation applies only before comma boundary', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Senza glutine, contiene latte e soia.',
        userAllergenKeys: ['gluten', 'milk', 'soy'],
      );
      expect(result.allergens, isNot(contains('gluten')));
      expect(result.allergens, contains('milk'));
      expect(result.allergens, contains('soy'));
    });

    test('"free from milk" treated as negation', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'This product is free from milk and eggs.',
        userAllergenKeys: ['milk', 'egg'],
      );
      expect(result.allergens, isEmpty);
    });
  });

  group('result levels', () {
    test('section + allergen → DANGER', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Ingredienti: farina, latte, zucchero. Contiene: latte.',
        userAllergenKeys: ['milk'],
      );
      expect(result.level, ScanResultLevel.danger);
      expect(result.allergens, contains('milk'));
    });

    test('allergen without section → WARNING', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Ricetta: farina, latte, zucchero, olio.',
        userAllergenKeys: ['milk'],
      );
      expect(result.level, ScanResultLevel.warning);
      expect(result.allergens, contains('milk'));
    });

    test('section without user allergen → SAFE', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Contiene: farina di riso, zucchero, sale.',
        userAllergenKeys: ['milk'],
      );
      expect(result.level, ScanResultLevel.safe);
      expect(result.allergens, isEmpty);
    });

    test('no section and no allergen → UNKNOWN', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Prodotto artigianale di alta qualita.',
        userAllergenKeys: ['milk'],
      );
      expect(result.level, ScanResultLevel.unknown);
    });
  });

  group('accents and casing', () {
    test('matches regardless of accents', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Enthält Erdnüsse und Milch.',
        userAllergenKeys: ['peanut', 'milk'],
      );
      expect(result.allergens, containsAll(['peanut', 'milk']));
    });

    test('matches regardless of case', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'CONTIENE LATTE E UOVA',
        userAllergenKeys: ['milk', 'egg'],
      );
      expect(result.allergens, containsAll(['milk', 'egg']));
    });
  });

  group('multiple allergens', () {
    test('detects multiple user allergens in same text', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Contiene: latte, soia, sesamo e solfiti.',
        userAllergenKeys: ['milk', 'soy', 'sesame', 'sulphite'],
      );
      expect(
        result.allergens,
        containsAll(['milk', 'soy', 'sesame', 'sulphite']),
      );
      expect(result.level, ScanResultLevel.danger);
    });

    test('ignores allergens user has not registered', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Contiene latte e soia.',
        userAllergenKeys: ['gluten'],
      );
      expect(result.allergens, isEmpty);
      expect(result.level, ScanResultLevel.safe);
    });
  });

  group('edge cases', () {
    test('empty text yields unknown', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: '',
        userAllergenKeys: ['milk'],
      );
      expect(result.level, ScanResultLevel.unknown);
    });

    test('empty allergen list yields unknown/safe', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Contiene zucchero e acqua.',
        userAllergenKeys: [],
      );
      expect(result.level, ScanResultLevel.safe);
      expect(result.allergens, isEmpty);
    });

    test('does not match "soia" inside "soiacanto" hypothetical word', () {
      final engine = buildEngine();
      final result = engine.analyze(
        ocrText: 'Prodotto soiaqualcosa inventato.',
        userAllergenKeys: ['soy'],
      );
      expect(result.allergens, isEmpty);
    });
  });
}
