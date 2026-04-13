/// Modello per i report della community su un prodotto.
class ProductReport {

  const ProductReport({
    required this.id,
    required this.barcode,
    this.productName,
    this.brand,
    required this.allergenId,
    required this.reportType,
    required this.deviceId,
    required this.confirmedBy,
    required this.createdAt,
  });
  final int id;
  final String barcode;
  final String? productName;
  final String? brand;
  final int allergenId;
  final String reportType; // 'contains' | 'may_contain' | 'safe'
  final String deviceId;
  final List<String> confirmedBy;
  final DateTime createdAt;
}
