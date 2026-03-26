/// Modello allergene con traduzioni multilingua.
class Allergen {
  final int id;
  final String nameKey;
  final Map<String, String> names; // {'it': 'arachidi', 'en': 'peanuts', ...}
  final String severity; // 'high' | 'medium' | 'low'
  final bool euRegulated;

  const Allergen({
    required this.id,
    required this.nameKey,
    required this.names,
    this.severity = 'high',
    this.euRegulated = false,
  });

  /// Restituisce il nome localizzato o il nameKey come fallback.
  String localizedName(String languageCode) {
    return names[languageCode] ?? names['en'] ?? nameKey;
  }

  /// Restituisce tutti i nomi in tutte le lingue (per pattern matching).
  List<String> get allNames => names.values.toList();

  factory Allergen.fromJson(Map<String, dynamic> json) {
    return Allergen(
      id: json['id'] as int,
      nameKey: json['name_key'] as String,
      names: (json['names'] as Map<String, dynamic>).cast<String, String>(),
      severity: json['severity'] as String? ?? 'high',
      euRegulated: json['eu_regulated'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_key': nameKey,
        'names': names,
        'severity': severity,
        'eu_regulated': euRegulated,
      };
}
