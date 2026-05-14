class ProductModel {
  final int productId;
  final String productName;
  final String productCode;
  final double quantityInstock;
  final double currentRate;

  ProductModel({
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.quantityInstock,
    required this.currentRate,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: int.parse(json['product_id'].toString()),
      productName: json['product_name'] ?? '',
      productCode: json['product_code'] ?? '',
      quantityInstock: double.parse(json['quantity_instock'].toString()),
      currentRate: double.parse(json['current_rate'].toString()),
    );
  }
}