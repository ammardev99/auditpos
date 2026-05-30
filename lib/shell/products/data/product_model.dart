class ProductModel {
  final int productId;

  final String productName;

  final String productCode;

  final double quantityInstock;

  final double currentRate;

  final double saleRate;

  final double wholesaleRate;

  final String rack;

  ProductModel({
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.quantityInstock,
    required this.currentRate,
    required this.saleRate,
    required this.wholesaleRate,
    required this.rack,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic v) {
      return double.tryParse(v.toString()) ?? 0;
    }

    return ProductModel(
      productId: int.tryParse(json['product_id'].toString()) ?? 0,
      productName: json['product_name']?.toString() ?? "",
      productCode: json['product_code']?.toString() ?? "",
      quantityInstock: parseNum(json['quantity_instock']),
      currentRate: parseNum(json['current_rate']),
      saleRate: parseNum(json['current_rate']),
      wholesaleRate: parseNum(json['f_days']),
      rack: json['rack']?.toString() ?? "",
    );
  }
}
