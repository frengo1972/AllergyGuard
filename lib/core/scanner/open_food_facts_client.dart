import 'package:dio/dio.dart';
import 'package:allergyguard/domain/models/product.dart';

/// Client REST per Open Food Facts API.
class OpenFoodFactsClient {
  OpenFoodFactsClient({required Dio dio}) : _dio = dio;
  final Dio _dio;

  static const _baseUrl = 'https://world.openfoodfacts.org';
  static const _imageBaseUrl =
      'https://images.openfoodfacts.org/images/products';

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
      labelImageCandidates: _extractLabelImageCandidates(barcode, data),
    );
  }

  List<ProductImageCandidate> _extractLabelImageCandidates(
    String barcode,
    Map<String, dynamic> data,
  ) {
    final candidates = <ProductImageCandidate>[];
    final seenUrls = <String>{};

    void addUrl(
      Object? value,
      ProductImageType type, {
      String? languageCode,
    }) {
      if (value is! String || value.trim().isEmpty || !seenUrls.add(value)) {
        return;
      }
      candidates.add(
        ProductImageCandidate(
          url: value,
          type: type,
          languageCode: languageCode,
        ),
      );
    }

    addUrl(data['image_ingredients_url'], ProductImageType.ingredients);
    addUrl(data['image_ingredients_small_url'], ProductImageType.ingredients);

    _addSelectedImageUrls(
      data['selected_images'],
      addUrl: addUrl,
    );
    _addComputedSelectedImageUrls(
      barcode,
      data['images'],
      addUrl: addUrl,
    );

    return candidates;
  }

  void _addSelectedImageUrls(
    Object? selectedImages, {
    required void Function(
      Object? value,
      ProductImageType type, {
      String? languageCode,
    }) addUrl,
  }) {
    final selected = _asStringKeyedMap(selectedImages);
    if (selected == null) return;

    for (final entry in _candidateTypeBySelectedImageKey.entries) {
      final imageData = _asStringKeyedMap(selected[entry.key]);
      if (imageData == null) continue;

      for (final size in const ['display', 'small', 'thumb']) {
        final urlsByLanguage = _asStringKeyedMap(imageData[size]);
        if (urlsByLanguage == null) continue;

        for (final languageEntry in urlsByLanguage.entries) {
          addUrl(
            languageEntry.value,
            entry.value,
            languageCode: languageEntry.key,
          );
        }
      }
    }
  }

  void _addComputedSelectedImageUrls(
    String barcode,
    Object? images, {
    required void Function(
      Object? value,
      ProductImageType type, {
      String? languageCode,
    }) addUrl,
  }) {
    final imageData = _asStringKeyedMap(images);
    if (imageData == null) return;

    final folder = _buildImageFolder(barcode);
    for (final entry in imageData.entries) {
      final type = _typeForImageKey(entry.key);
      if (type == null) continue;

      final metadata = _asStringKeyedMap(entry.value);
      final rev = metadata?['rev']?.toString();
      if (rev == null || rev.isEmpty) continue;

      final sizes = _asStringKeyedMap(metadata?['sizes']);
      final size = sizes?.containsKey('400') == true ? '400' : 'full';
      final languageCode = _languageForImageKey(entry.key);
      addUrl(
        '$_imageBaseUrl/$folder/${entry.key}.$rev.$size.jpg',
        type,
        languageCode: languageCode,
      );
    }
  }

  String _buildImageFolder(String barcode) {
    final normalized = barcode.padLeft(13, '0');
    if (normalized.length <= 8) return normalized;
    return normalized.replaceFirstMapped(
      RegExp(r'^(.{3})(.{3})(.{3})(.*)$'),
      (match) => '${match[1]}/${match[2]}/${match[3]}/${match[4]}',
    );
  }

  Map<String, dynamic>? _asStringKeyedMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return {
        for (final entry in value.entries)
          if (entry.key is String) entry.key as String: entry.value,
      };
    }
    return null;
  }

  ProductImageType? _typeForImageKey(String key) {
    for (final entry in _candidateTypeBySelectedImageKey.entries) {
      if (key == entry.key || key.startsWith('${entry.key}_')) {
        return entry.value;
      }
    }
    return null;
  }

  String? _languageForImageKey(String key) {
    final separatorIndex = key.indexOf('_');
    if (separatorIndex < 0 || separatorIndex == key.length - 1) {
      return null;
    }
    return key.substring(separatorIndex + 1);
  }

  static const _candidateTypeBySelectedImageKey = {
    'ingredients': ProductImageType.ingredients,
    'packaging': ProductImageType.packaging,
    'front': ProductImageType.front,
    'nutrition': ProductImageType.nutrition,
  };
}
