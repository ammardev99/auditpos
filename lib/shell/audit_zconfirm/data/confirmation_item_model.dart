class ConfirmationItemModel {
  final int id;
  final int productId;
  final String productName;
  final String barcode;
  final int systemQty;
  final int physicalQty;
  final double systemPrice;
  final double physicalPrice;
  final double mismatchQty;
  final double mismatchValue;
  final bool isApproved;

  // NEW FIELDS
  final String systemRack;
  final String physicalRack;
  final double systemWPrice;
  final double physicalWPrice;

  ConfirmationItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.barcode,
    required this.systemQty,
    required this.physicalQty,
    required this.systemPrice,
    required this.physicalPrice,
    required this.mismatchQty,
    required this.mismatchValue,
    required this.isApproved,

    // NEW REQUIRED PARAMETERS
    required this.systemRack,
    required this.physicalRack,
    required this.systemWPrice,
    required this.physicalWPrice,
  });

  // CLEAN COPYWITH HELPER FOR LOCAL STATE MUTATIONS
  ConfirmationItemModel copyWith({
    int? id,
    int? productId,
    String? productName,
    String? barcode,
    int? systemQty,
    int? physicalQty,
    double? systemPrice,
    double? physicalPrice,
    double? mismatchQty,
    double? mismatchValue,
    bool? isApproved,
    String? systemRack,
    String? physicalRack,
    double? systemWPrice,
    double? physicalWPrice,
  }) {
    return ConfirmationItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      barcode: barcode ?? this.barcode,
      systemQty: systemQty ?? this.systemQty,
      physicalQty: physicalQty ?? this.physicalQty,
      systemPrice: systemPrice ?? this.systemPrice,
      physicalPrice: physicalPrice ?? this.physicalPrice,
      mismatchQty: mismatchQty ?? this.mismatchQty,
      mismatchValue: mismatchValue ?? this.mismatchValue,
      isApproved: isApproved ?? this.isApproved,
      systemRack: systemRack ?? this.systemRack,
      physicalRack: physicalRack ?? this.physicalRack,
      systemWPrice: systemWPrice ?? this.systemWPrice,
      physicalWPrice: physicalWPrice ?? this.physicalWPrice,
    );
  }

  factory ConfirmationItemModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) =>
        double.tryParse(value?.toString() ?? '0') ?? 0.0;
    int parseInt(dynamic value) =>
        (double.tryParse(value?.toString() ?? '0') ?? 0.0).round();

    final approved =
        json['is_approved'] == 1 ||
        json['is_approved'] == true ||
        json['status'] == 'approved';

    return ConfirmationItemModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      productId: int.tryParse(json['product_id'].toString()) ?? 0,
      productName: (json['product_name'] ?? 'Unknown Item').toString().trim(),
      barcode:
          (json['product_code'] ?? json['barcode'] ?? json['sku'] ?? '-')
              .toString()
              .trim(),
      systemQty: parseInt(json['sys_qty'] ?? json['system_qty']),
      physicalQty: parseInt(json['phy_qty'] ?? json['physical_qty'] ?? 0),
      systemPrice: parseDouble(json['sys_price'] ?? json['system_price']),
      physicalPrice: parseDouble(
        json['phy_price'] ?? json['physical_price'] ?? 0.0,
      ),
      mismatchQty: parseDouble(json['mismatch_qty']),
      mismatchValue: parseDouble(json['mismatch_value']),
      isApproved: approved,

      systemRack: (json['sys_rack'] ?? '-').toString().trim(),
      physicalRack: (json['phy_rack'] ?? '-').toString().trim(),
systemWPrice: parseDouble(
  json['sys_wholesale_price'] ?? json['sys_wprice'] ?? 0,
),

physicalWPrice: parseDouble(
  json['phy_wholesale_price'] ?? json['phy_wprice'] ?? 0,
),
      // systemWPrice: parseDouble(
      //   // json['sys_wprice'] ?? json['sys_wholesale_price'],
      //   json['sys_wprice'] ?? json['sys_wprice'],
      // ),
      // physicalWPrice: parseDouble(
      //   // json['phy_wprice'] ?? json['phy_wholesale_price'],
      //   json['phy_wprice'] ?? json['phy_wprice'],
      // ),
    );
  }
}
