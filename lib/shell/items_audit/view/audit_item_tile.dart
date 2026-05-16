import 'package:flutter/material.dart';

import '../data/audit_item_model.dart';

class AuditItemTile extends StatelessWidget {
  final AuditItemModel item;

  final VoidCallback onTap;

  const AuditItemTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mismatchQty = item.mismatchQty;

    final hasMismatch = mismatchQty != 0;

    final isShortage = mismatchQty < 0;

    final isExcess = mismatchQty > 0;

    Color? bgColor;

    if (isShortage) {
      bgColor = Colors.red.shade50;
    } else if (isExcess) {
      bgColor = Colors.orange.shade50;
    }

    return Card(
      color: bgColor,

      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      child: ListTile(
        onTap: onTap,

        leading: CircleAvatar(child: Text(item.productName[0])),

        title: Text(item.productName),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text("Code: ${item.productCode}"),

            const SizedBox(height: 4),

            Text("SYS Qty: ${item.sysQty}"),

            Text("PHY Qty: ${item.phyQty}"),

            if (hasMismatch)
              Text(
                isShortage
                    ? "Shortage: ${mismatchQty.abs()}"
                    : "Excess: ${mismatchQty.abs()}",

                style: TextStyle(
                  color: isShortage ? Colors.red : Colors.orange,

                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),

        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            Text("SYS ${item.sysPrice}"),

            Text("PHY ${item.phyPrice}"),

            if (hasMismatch)
              Text(
                item.mismatchValue.isNegative
                    ? "-${item.mismatchValue.abs()}"
                    : "+${item.mismatchValue}",

                style: TextStyle(
                  color: isShortage ? Colors.red : Colors.orange,

                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
