/// Modello prodotto alimentare (da Open Food Facts o cache locale).
class Product {
  final String barcode;
  final String name;
  final String brand;
  final String ingredientsText;
  final List<String> allergenKeys;
  final List<String> tracesKeys;
  final String? imageUrl;

  const Product({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.ingredientsText,
    required this.allergenKeys,
    required this.tracesKeys,
    this.imageUrl,
  });
}
