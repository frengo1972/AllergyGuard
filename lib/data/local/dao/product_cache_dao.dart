import 'package:drift/drift.dart';
import 'package:allergyguard/data/local/app_database.dart';

part 'product_cache_dao.g.dart';

@DriftAccessor(tables: [ProductCache])
class ProductCacheDao extends DatabaseAccessor<AppDatabase>
    with _$ProductCacheDaoMixin {
  ProductCacheDao(super.db);

  Future<ProductCacheData?> getByBarcode(String barcode) =>
      (select(productCache)..where((t) => t.barcode.equals(barcode)))
          .getSingleOrNull();

  Future<void> upsertProduct(ProductCacheCompanion product) =>
      into(productCache).insert(product, mode: InsertMode.insertOrReplace);

  /// Elimina prodotti con cache scaduta.
  Future<int> deleteExpired(int ttlDays) {
    final cutoff = DateTime.now().subtract(Duration(days: ttlDays));
    return (delete(productCache)
          ..where((t) => t.cachedAt.isSmallerThanValue(cutoff)))
        .go();
  }
}
