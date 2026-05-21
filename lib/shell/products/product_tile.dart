import 'package:flutter/material.dart';

class ProductTile extends StatelessWidget {
  final String productName;
  final String productCode;
  final String qty;
  final String price;

  const ProductTile({
    super.key,
    required this.productName,
    required this.productCode,
    required this.qty,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      child: ListTile(
        // leading: CircleAvatar(child: Text(productName[0])),
        title: Text(productName, style: TextStyle(
          fontWeight: FontWeight.bold,
        ),),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text("Code: $productCode"), Text("Qty: $qty")],
        ),
        trailing: Text(
          "Rs. $price",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
