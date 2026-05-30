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

  // New Wholesale Fields
  final double sysWholesalePrice;
  final double phyWholesalePrice;

  // New Rack Fields (Strings because they usually contain letters like 'a55')
  final String sysRack;
  final String phyRack;

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
    required this.sysWholesalePrice,
    required this.phyWholesalePrice,
    required this.sysRack,
    required this.phyRack,
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

      // Parsing new fields safely
      sysWholesalePrice: double.parse(
        (json['sys_wholesale_price'] ?? 0).toString(),
      ),

      phyWholesalePrice: double.parse(
        (json['phy_wholesale_price'] ?? 0).toString(),
      ),

      sysRack: json['sys_rack']?.toString() ?? '',

      phyRack: json['phy_rack']?.toString() ?? '',

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
    double? phyWholesalePrice,
    String? phyRack,
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
      sysWholesalePrice: sysWholesalePrice,
      phyWholesalePrice: phyWholesalePrice ?? this.phyWholesalePrice,
      sysRack: sysRack,
      phyRack: phyRack ?? this.phyRack,
      mismatchQty: mismatchQty ?? this.mismatchQty,
      mismatchValue: mismatchValue ?? this.mismatchValue,
    );
  }
}
