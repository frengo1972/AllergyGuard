import 'package:allergyguard/domain/models/allergen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Allergen', () {
    test('merges localized label and search aliases per language', () {
      final allergen = Allergen.fromJson({
        'id': 3,
        'name_key': 'milk',
        'names': {
          'it': 'latticini',
          'en': 'dairy',
        },
        'search_terms': {
          'it': ['latte'],
          'en': ['milk'],
        },
        'severity': 'high',
        'eu_regulated': true,
      });

      expect(allergen.localizedName('it'), 'latticini');
      expect(allergen.searchableTermsByLanguage['it'], ['latticini', 'latte']);
      expect(allergen.searchableTermsByLanguage['en'], ['dairy', 'milk']);
      expect(
        allergen.allNames,
        containsAll(['latticini', 'latte', 'dairy', 'milk']),
      );
    });

    test('falls back to visible names when aliases are missing', () {
      final allergen = Allergen.fromJson({
        'id': 2,
        'name_key': 'peanut',
        'names': {
          'it': 'arachidi',
          'en': 'peanuts',
        },
      });

      expect(allergen.searchableTermsByLanguage['it'], ['arachidi']);
      expect(allergen.searchableTermsByLanguage['en'], ['peanuts']);
    });
  });
}
