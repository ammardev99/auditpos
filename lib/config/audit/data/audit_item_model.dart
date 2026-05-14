class AuditItemModel {
  final int productId;
  final String productCode;
  final double sysQty;
  final double phyQty;
  final double mismatchQty;

  AuditItemModel({
    required this.productId,
    required this.productCode,
    required this.sysQty,
    required this.phyQty,
    required this.mismatchQty,
  });

  factory AuditItemModel.fromJson(
      Map<String, dynamic> json) {
    return AuditItemModel(
      productId: json['product_id'],
      productCode: json['product_code'],
      sysQty:
          double.parse(json['sys_qty'].toString()),
      phyQty:
          double.parse(json['phy_qty'].toString()),
      mismatchQty:
          double.parse(json['mismatch_qty'].toString()),
    );
  }
}