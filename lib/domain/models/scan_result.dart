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

/// Risultato di una scansione prodotto.
class ScanResult {
  final ScanResultLevel level;
  final List<String> allergens;
  final String ocrText;
  final String? barcode;
  final String? productName;
  final String? brand;
  final double? confidence;
  final DateTime scannedAt;

  ScanResult({
    required this.level,
    required this.allergens,
    required this.ocrText,
    this.barcode,
    this.productName,
    this.brand,
    this.confidence,
    DateTime? scannedAt,
  }) : scannedAt = scannedAt ?? DateTime.now();
}
