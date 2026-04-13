import 'package:dio/dio.dart';
import 'package:allergyguard/domain/models/product.dart';

/// Client REST per Open Food Facts API.
class OpenFoodFactsClient {

  OpenFoodFactsClient({required Dio dio}) : _dio = dio;
  final Dio _dio;

  static const _baseUrl = 'https://world.openfoodfacts.org';

  /// Mappatura tag allergeni OFF → chiave allergene interna.
  static const allergenTagMap = {
    'en:gluten': 'gluten',
    'en:peanuts': 'peanut',
    'en:milk': 'milk',
    'en:eggs': 'egg',
    'en:nuts': 'tree_nut',
    'en:soybeans': 'soy',
    'en:fish': 'fish',
    'en:crustaceans': 'crustacean',
    'en:molluscs': 'mollusc',
    'en:celery': 'celery',
    'en:mustard': 'mustard',
    'en:sesame': 'sesame',
    'en:sulphites': 'sulphite',
    'en:lupin': 'lupin',
  };

  /// Cerca un prodotto per barcode.
  Future<Product?> getByBarcode(String barcode) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/v2/product/$barcode.json',
      );

      if (response.data['status'] != 1) return null;

      final productData = response.data['product'] as Map<String, dynamic>;
      return _parseProduct(barcode, productData);
    } on DioException {
      return null;
    }
  }

  /// Cerca prodotti per nome.
  Future<List<Product>> searchByName(String query) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/cgi/search.pl',
        queryParameters: {
          'search_terms': query,
          'json': '1',
          'page_size': '10',
        },
      );

      final products = response.data['products'] as List<dynamic>? ?? [];
      return products
          .map((p) => _parseProduct(
              p['code'] as String? ?? '', p as Map<String, dynamic>))
          .toList();
    } on DioException {
      return [];
    }
  }

  Product _parseProduct(String barcode, Map<String, dynamic> data) {
    final allergenTags =
        (data['allergens_tags'] as List<dynamic>?)?.cast<String>() ?? [];
    final tracesTags =
        (data['traces_tags'] as List<dynamic>?)?.cast<String>() ?? [];

    final allergenKeys = allergenTags
        .map((tag) => allergenTagMap[tag])
        .whereType<String>()
        .toList();

    final tracesKeys = tracesTags
        .map((tag) => allergenTagMap[tag])
        .whereType<String>()
        .toList();

    return Product(
      barcode: barcode,
      name: data['product_name'] as String? ?? '',
      brand: data['brands'] as String? ?? '',
      ingredientsText: data['ingredients_text'] as String? ?? '',
      allergenKeys: allergenKeys,
      tracesKeys: tracesKeys,
      imageUrl: data['image_url'] as String?,
    );
  }
}
