import 'dart:convert';
import 'package:flutter/services.dart';
import 'allergen_pattern_engine.dart';

/// Carica i pattern di contesto da JSON locale e li sincronizza con Supabase.
class PatternRepository {
  List<ContextPattern> _patterns = [];

  List<ContextPattern> get verifiedPatterns =>
      _patterns.where((p) => p.status == 'verified').toList();

  List<ContextPattern> get allPatterns => List.unmodifiable(_patterns);

  /// Carica i pattern dal file JSON locale in assets/.
  Future<void> loadLocalPatterns() async {
    final jsonString =
        await rootBundle.loadString('assets/allergens/context_patterns.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final patternsList = data['patterns'] as List<dynamic>;
    _patterns = patternsList
        .map((p) => ContextPattern.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// Aggiorna i pattern con quelli scaricati da Supabase.
  void updatePatterns(List<ContextPattern> remotePatterns) {
    final patternMap = {for (final p in _patterns) p.id: p};
    for (final remote in remotePatterns) {
      patternMap[remote.id] = remote;
    }
    _patterns = patternMap.values.toList();
  }

  /// Verifica se un testo è già presente tra i pattern esistenti.
  bool patternExists(String normalizedText) {
    return _patterns.any(
        (p) => p.text.toLowerCase().trim() == normalizedText.toLowerCase().trim());
  }

  Set<String> get existingPatternTexts =>
      _patterns.map((p) => p.text.toLowerCase().trim()).toSet();
}
