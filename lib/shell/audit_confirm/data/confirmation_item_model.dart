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
  });

  factory ConfirmationItemModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) =>
        double.tryParse(value?.toString() ?? '0') ?? 0.0;
    int parseInt(dynamic value) =>
        (double.tryParse(value?.toString() ?? '0') ?? 0.0).round();

    // Determine status from database flags
    final approved =
        json['is_approved'] == 1 ||
        json['is_approved'] == true ||
        json['status'] == 'approved';

    return ConfirmationItemModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      productId: int.tryParse(json['product_id'].toString()) ?? 0,
      productName: (json['product_name'] ?? 'Unknown Item').toString().trim(),
      barcode:
          (json['barcode'] ?? json['sku'] ?? json['upc'] ?? 'N/A')
              .toString()
              .trim(),
      systemQty: parseInt(
        json['sys_qty'] ?? json['system_qty'] ?? json['quantity_instock'],
      ),
      physicalQty: parseInt(json['phy_qty'] ?? json['physical_qty'] ?? 0),
      systemPrice: parseDouble(
        json['sys_price'] ?? json['system_price'] ?? json['current_rate'],
      ),
      physicalPrice: parseDouble(
        json['phy_price'] ?? json['physical_price'] ?? 0.0,
      ),
      mismatchQty: parseDouble(json['mismatch_qty']),
      mismatchValue: parseDouble(json['mismatch_value']),
      isApproved: approved,
    );
  }
}
