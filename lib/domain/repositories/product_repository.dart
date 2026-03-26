import 'package:allergyguard/domain/models/product.dart';

/// Interfaccia astratta per il repository dei prodotti.
abstract class ProductRepository {
  Future<Product?> getByBarcode(String barcode);
  Future<List<Product>> searchByName(String query);
  Future<void> cacheProduct(Product product);
  Future<void> clearExpiredCache();
}
