/// Modello allergene con traduzioni multilingua.
enum AllergenIconType {
  bundle,
  emoji,
  generic;

  static AllergenIconType fromRaw(String? raw) {
    switch (raw?.trim().toLowerCase()) {
      case 'emoji':
        return AllergenIconType.emoji;
      case 'generic':
        return AllergenIconType.generic;
      case 'bundle':
      default:
        return AllergenIconType.bundle;
    }
  }
}

class Allergen {
  const Allergen({
    required this.id,
    required this.nameKey,
    required this.names,
    Map<String, List<String>>? searchTerms,
    this.severity = 'high',
    this.euRegulated = false,
    this.iconType = AllergenIconType.bundle,
    this.iconEmoji,
    this.iconColor,
    this.datasetVersion,
  }) : searchTerms = searchTerms ?? const <String, List<String>>{};

  factory Allergen.fromJson(Map<String, dynamic> json) {
    final rawNames =
        json['names'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final names = <String, String>{
      for (final entry in rawNames.entries)
        if (entry.value != null) entry.key: entry.value.toString(),
    };
    return Allergen(
      id: json['id'] as int,
      nameKey: json['name_key'] as String,
      names: names,
      searchTerms: _parseSearchTerms(json['search_terms'], names),
      severity: json['severity'] as String? ?? 'high',
      euRegulated: json['eu_regulated'] as bool? ?? false,
      iconType: AllergenIconType.fromRaw(json['icon_type'] as String?),
      iconEmoji: (json['icon_emoji'] as String?)?.trim(),
      iconColor: (json['icon_color'] as String?)?.trim(),
      datasetVersion: json['dataset_version'] as int?,
    );
  }
  final int id;
  final String nameKey;
  final Map<String, String> names; // {'it': 'arachidi', 'en': 'peanuts', ...}
  final Map<String, List<String>> searchTerms;
  final String severity; // 'high' | 'medium' | 'low'
  final bool euRegulated;
  final AllergenIconType iconType;
  final String? iconEmoji;
  final String? iconColor;
  final int? datasetVersion;

  /// Restituisce il nome localizzato o il nameKey come fallback.
  String localizedName(String languageCode) {
    return names[languageCode] ?? names['en'] ?? nameKey;
  }

  /// Restituisce tutti i termini utili per ricerca e pattern matching.
  List<String> get allNames => searchableTermsByLanguage.values
      .expand((terms) => terms)
      .toSet()
      .toList(growable: false);

  /// Restituisce i termini per lingua includendo etichetta visibile e alias.
  Map<String, List<String>> get searchableTermsByLanguage {
    final merged = <String, List<String>>{};
    final languageCodes = <String>{
      ...names.keys,
      ...searchTerms.keys,
    };

    for (final languageCode in languageCodes) {
      final terms = <String>[];
      void addTerm(String? value) {
        final term = value?.trim();
        if (term == null || term.isEmpty || terms.contains(term)) return;
        terms.add(term);
      }

      addTerm(names[languageCode]);
      for (final term in searchTerms[languageCode] ?? const <String>[]) {
        addTerm(term);
      }
      if (terms.isNotEmpty) {
        merged[languageCode] = List<String>.unmodifiable(terms);
      }
    }

    return merged;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_key': nameKey,
        'names': names,
        'search_terms': {
          for (final entry in searchTerms.entries) entry.key: entry.value,
        },
        'severity': severity,
        'eu_regulated': euRegulated,
        'icon_type': iconType.name,
        'icon_emoji': iconEmoji,
        'icon_color': iconColor,
        'dataset_version': datasetVersion,
      };

  static Map<String, List<String>> _parseSearchTerms(
    dynamic rawSearchTerms,
    Map<String, String> names,
  ) {
    final parsed = <String, List<String>>{};
    final rawMap = rawSearchTerms is Map<String, dynamic>
        ? rawSearchTerms
        : <String, dynamic>{};
    final languageCodes = <String>{
      ...names.keys,
      ...rawMap.keys.whereType<String>(),
    };

    for (final languageCode in languageCodes) {
      final terms = <String>[];
      void addTerm(String? value) {
        final term = value?.trim();
        if (term == null || term.isEmpty || terms.contains(term)) return;
        terms.add(term);
      }

      addTerm(names[languageCode]);
      final rawValue = rawMap[languageCode];
      if (rawValue is String) {
        addTerm(rawValue);
      } else if (rawValue is List) {
        for (final item in rawValue.whereType<String>()) {
          addTerm(item);
        }
      }

      if (terms.isNotEmpty) {
        parsed[languageCode] = List<String>.unmodifiable(terms);
      }
    }

    return parsed;
  }
}
