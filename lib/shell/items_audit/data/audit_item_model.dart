class AuditItemModel {
  final int id;
  final int auditId;
  final int productId;

  final String productCode;
  final String productName;

  final double sysQty;
  final double phyQty;

  final double sysPrice;
  final double phyPrice;

  final double mismatchQty;
  final double mismatchValue;

  AuditItemModel({
    required this.id,
    required this.auditId,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.sysQty,
    required this.phyQty,
    required this.sysPrice,
    required this.phyPrice,
    required this.mismatchQty,
    required this.mismatchValue,
  });

  factory AuditItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AuditItemModel(
      id: int.parse(json['id'].toString()),

      auditId: int.parse(
        json['audit_id'].toString(),
      ),

      productId: int.parse(
        json['product_id'].toString(),
      ),

      productCode: json['product_code'] ?? '',

      productName: json['product_name'] ?? '',

      sysQty: double.parse(
        json['sys_qty'].toString(),
      ),

      phyQty: double.parse(
        json['phy_qty'].toString(),
      ),

      sysPrice: double.parse(
        json['sys_price'].toString(),
      ),

      phyPrice: double.parse(
        json['phy_price'].toString(),
      ),

      mismatchQty: double.parse(
        json['mismatch_qty'].toString(),
      ),

      mismatchValue: double.parse(
        json['mismatch_value'].toString(),
      ),
    );
  }

  AuditItemModel copyWith({
    double? phyQty,
    double? phyPrice,
    double? mismatchQty,
    double? mismatchValue,
  }) {
    return AuditItemModel(
      id: id,
      auditId: auditId,
      productId: productId,
      productCode: productCode,
      productName: productName,
      sysQty: sysQty,
      phyQty: phyQty ?? this.phyQty,
      sysPrice: sysPrice,
      phyPrice: phyPrice ?? this.phyPrice,
      mismatchQty:
          mismatchQty ?? this.mismatchQty,
      mismatchValue:
          mismatchValue ?? this.mismatchValue,
    );
  }
}