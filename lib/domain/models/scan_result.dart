import 'dart:convert';
import 'dart:ui';

/// Livelli di risultato della scansione.
enum ScanResultLevel {
  /// Allergene trovato in contesto VERIFIED — sfondo rosso, vibrazione lunga
  danger,

  /// Allergene trovato ma contesto non riconosciuto — sfondo arancione
  warning,

  /// Sezione allergeni presente, allergene non trovato — sfondo verde
  safe,

  /// Nessuna sezione allergeni rilevata — sfondo grigio
  unknown,
}

class ScanResultMatch {
  const ScanResultMatch({
    required this.allergenKey,
    required this.localizedAllergenName,
    required this.matchedText,
    required this.containingText,
    required this.languageCode,
    required this.languageLabel,
    required this.isPartial,
    this.boundingBox,
    this.lineText,
  });

  factory ScanResultMatch.fromJson(Map<String, dynamic> json) {
    final boundingBoxJson = json['bounding_box'] as Map<String, dynamic>?;
    return ScanResultMatch(
      allergenKey: json['allergen_key'] as String,
      localizedAllergenName: json['localized_allergen_name'] as String,
      matchedText: json['matched_text'] as String,
      containingText: json['containing_text'] as String,
      languageCode: json['language_code'] as String,
      languageLabel: json['language_label'] as String,
      isPartial: json['is_partial'] as bool? ?? false,
      boundingBox: boundingBoxJson == null
          ? null
          : Rect.fromLTRB(
              (boundingBoxJson['left'] as num).toDouble(),
              (boundingBoxJson['top'] as num).toDouble(),
              (boundingBoxJson['right'] as num).toDouble(),
              (boundingBoxJson['bottom'] as num).toDouble(),
            ),
      lineText: json['line_text'] as String?,
    );
  }

  final String allergenKey;
  final String localizedAllergenName;
  final String matchedText;
  final String containingText;
  final String languageCode;
  final String languageLabel;
  final bool isPartial;
  final Rect? boundingBox;
  final String? lineText;

  Map<String, dynamic> toJson() => {
        'allergen_key': allergenKey,
        'localized_allergen_name': localizedAllergenName,
        'matched_text': matchedText,
        'containing_text': containingText,
        'language_code': languageCode,
        'language_label': languageLabel,
        'is_partial': isPartial,
        'bounding_box': boundingBox == null
            ? null
            : {
                'left': boundingBox!.left,
                'top': boundingBox!.top,
                'right': boundingBox!.right,
                'bottom': boundingBox!.bottom,
              },
        'line_text': lineText,
      };
}

/// Risultato di una scansione prodotto.
class ScanResult {
  ScanResult({
    required this.level,
    required this.allergens,
    required this.ocrText,
    this.highlightTerms = const <String>[],
    this.matches = const <ScanResultMatch>[],
    this.referenceImagePath,
    this.barcode,
    this.productName,
    this.brand,
    this.confidence,
    DateTime? scannedAt,
  }) : scannedAt = scannedAt ?? DateTime.now();

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      level: ScanResultLevel.values.byName(json['level'] as String),
      allergens: (json['allergens'] as List<dynamic>? ?? const <dynamic>[])
          .cast<String>(),
      ocrText: json['ocr_text'] as String? ?? '',
      highlightTerms:
          (json['highlight_terms'] as List<dynamic>? ?? const <dynamic>[])
              .cast<String>(),
      matches: (json['matches'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(ScanResultMatch.fromJson)
          .toList(),
      referenceImagePath: json['reference_image_path'] as String?,
      barcode: json['barcode'] as String?,
      productName: json['product_name'] as String?,
      brand: json['brand'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      scannedAt: DateTime.tryParse(json['scanned_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  final ScanResultLevel level;
  final List<String> allergens;
  final String ocrText;
  final List<String> highlightTerms;
  final List<ScanResultMatch> matches;
  final String? referenceImagePath;
  final String? barcode;
  final String? productName;
  final String? brand;
  final double? confidence;
  final DateTime scannedAt;

  Map<String, dynamic> toJson() => {
        'level': level.name,
        'allergens': allergens,
        'ocr_text': ocrText,
        'highlight_terms': highlightTerms,
        'matches': matches.map((match) => match.toJson()).toList(),
        'reference_image_path': referenceImagePath,
        'barcode': barcode,
        'product_name': productName,
        'brand': brand,
        'confidence': confidence,
        'scanned_at': scannedAt.toIso8601String(),
      };

  String toJsonString() => jsonEncode(toJson());

  static ScanResult fromJsonString(String raw) {
    return ScanResult.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }
}
