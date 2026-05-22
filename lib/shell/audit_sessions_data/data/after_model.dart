// class AfterAuditItemModel {
//   final int id;
//   final int productId;
//   final String productName;
//   final String barcode; // Added barcode field
//   final int systemQty;
//   final int physicalQty;
//   final double systemPrice;
//   final double physicalPrice;
//   final double mismatchQty;
//   final String status;
//   final bool isApproved;
//   final bool isCounted;

//   AfterAuditItemModel({
//     required this.id,
//     required this.productId,
//     required this.productName,
//     required this.barcode, // Required field
//     required this.systemQty,
//     required this.physicalQty,
//     required this.systemPrice,
//     required this.physicalPrice,
//     required this.mismatchQty,
//     required this.status,
//     required this.isApproved,
//     required this.isCounted,
//   });

//   bool get isMismatch => 
//       isCounted && (mismatchQty != 0.0 || (systemQty != physicalQty) || (systemPrice != physicalPrice));

//   factory AfterAuditItemModel.fromJson(Map<String, dynamic> json) {
//     double parseDouble(dynamic value) {
//       if (value == null) return 0.0;
//       return double.tryParse(value.toString()) ?? 0.0;
//     }

//     int parseInt(dynamic value) {
//       if (value == null) return 0;
//       return (double.tryParse(value.toString()) ?? 0.0).round();
//     }

//     final rawPhyQty = json['phy_qty'] ?? json['physical_qty'];
//     final rawPhyPrice = json['phy_price'] ?? json['physical_price'];
//     final isCounted = rawPhyQty != null || rawPhyPrice != null;

//     final sysQty = parseInt(json['sys_qty'] ?? json['system_qty'] ?? json['quantity_instock']);
//     final phyQty = parseInt(rawPhyQty);
//     final sysPrice = parseDouble(json['sys_price'] ?? json['system_price'] ?? json['current_rate']);
//     final phyPrice = parseDouble(rawPhyPrice);
//     final misQty = parseDouble(json['mismatch_qty']);

//     final approved = json['is_approved'] == 1 || json['is_approved'] == true || json['status'] == 'approved';

//     return AfterAuditItemModel(
//       id: int.tryParse(json['id'].toString()) ?? 0,
//       productId: int.tryParse(json['product_id'].toString()) ?? 0,
//       productName: (json['product_name'] ?? json['name'] ?? 'Unknown Item').toString().trim(),
//       // Extract barcode safely from common backend keys
//       barcode: (json['barcode'] ?? json['sku'] ?? json['upc'] ?? 'N/A').toString().trim(),
//       systemQty: sysQty,
//       physicalQty: phyQty,
//       systemPrice: sysPrice,
//       physicalPrice: phyPrice,
//       mismatchQty: misQty,
//       status: approved ? 'approved' : (json['status'] ?? 'pending'),
//       isApproved: approved,
//       isCounted: isCounted,
//     );
//   }

//   AfterAuditItemModel copyWith({
//     int? physicalQty,
//     double? physicalPrice,
//     String? status,
//     bool? isApproved,
//     bool? isCounted,
//     String? barcode,
//   }) {
//     return AfterAuditItemModel(
//       id: id,
//       productId: productId,
//       productName: productName,
//       barcode: barcode ?? this.barcode,
//       systemQty: systemQty,
//       physicalQty: physicalQty ?? this.physicalQty,
//       systemPrice: systemPrice,
//       physicalPrice: physicalPrice ?? this.physicalPrice,
//       mismatchQty: mismatchQty,
//       status: status ?? this.status,
//       isApproved: isApproved ?? this.isApproved,
//       isCounted: isCounted ?? this.isCounted,
//     );
//   }
// }