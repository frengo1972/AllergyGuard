/// Modello prodotto alimentare (da Open Food Facts o cache locale).
class Product {
  const Product({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.ingredientsText,
    required this.allergenKeys,
    required this.tracesKeys,
    this.imageUrl,
    this.labelImageCandidates = const <ProductImageCandidate>[],
  });
  final String barcode;
  final String name;
  final String brand;
  final String ingredientsText;
  final List<String> allergenKeys;
  final List<String> tracesKeys;
  final String? imageUrl;
  final List<ProductImageCandidate> labelImageCandidates;
}

/// Immagine Open Food Facts utile per OCR su etichetta.
class ProductImageCandidate {
  const ProductImageCandidate({
    required this.url,
    required this.type,
    this.languageCode,
  });

  final String url;
  final ProductImageType type;
  final String? languageCode;
}

enum ProductImageType {
  ingredients,
  packaging,
  front,
  nutrition,
}
