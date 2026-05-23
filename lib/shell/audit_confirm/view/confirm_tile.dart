import 'package:flutter/material.dart';
import '../data/confirmation_item_model.dart';

class AuditConfirmItemTile extends StatelessWidget {
  final ConfirmationItemModel item;
  final bool readOnly;
  final VoidCallback onAdjust;
  final VoidCallback onApprove;

  const AuditConfirmItemTile({
    super.key,
    required this.item,
    required this.readOnly,
    required this.onAdjust,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: item.isApproved ? Colors.green : Colors.redAccent,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Title and Sync Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.productName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isApproved ? Colors.green : Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.isApproved ? "Synced" : "Pending Sync",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Barcode: ${item.barcode}",
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 16),

            // Row 2: Quantities, Prices, and Rack Locations Comparison Matrix
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // System Properties Column
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        "System Data",
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text("Stock Qty: ${item.systemQty}"),
                      Text("Retail: \$${item.systemPrice.toStringAsFixed(2)}"),
                      Text("Wholesale: \$${item.systemWPrice.toStringAsFixed(2)}", style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                      Text("Rack: ${item.systemRack}", style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const Icon(Icons.compare_arrows, color: Colors.grey),
                
                // Physical Properties Column
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        "Physical Count",
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text("Stock Qty: ${item.physicalQty}"),
                      Text("Retail: \$${item.physicalPrice.toStringAsFixed(2)}"),
                      Text("Wholesale: \$${item.physicalWPrice.toStringAsFixed(2)}", style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                      Text("Rack: ${item.physicalRack}", style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),

            // Mismatch Visual indicator area if present
            if (item.mismatchQty != 0) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    "Mismatch: ${item.mismatchQty.toStringAsFixed(0)} items (Value Impact: \$${item.mismatchValue.toStringAsFixed(2)})",
                    style: TextStyle(fontSize: 11, color: Colors.red.shade900, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],

            // Action Buttons Section
            if (!readOnly && !item.isApproved) ...[
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.edit, color: Colors.orange, size: 18),
                    label: const Text("Adjust Counts"),
                    onPressed: onAdjust,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text("Approve"),
                    onPressed: onApprove,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}