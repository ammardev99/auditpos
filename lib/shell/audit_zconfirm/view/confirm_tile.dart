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
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: item.isApproved ? Colors.green : Colors.redAccent,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SelectionArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.productName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          item.isApproved
                              ? Colors.green
                              : Colors.amber.shade700,
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

              /// =========================
              /// TABLE HEADER
              /// =========================
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        "FIELD",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "SYS",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "PHY",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Δ",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              /// =========================
              /// TABLE ROWS
              /// =========================
              _row(
                "Rack",
                item.systemRack,
                item.physicalRack,
                item.systemRack == item.physicalRack ? "✓" : "●",
              ),

              _row(
                "Qty",
                "${item.systemQty}",
                "${item.physicalQty}",
                "${item.mismatchQty}",
              ),

              _row(
                "Wholesale",
                "${item.systemWPrice}",
                "${item.physicalWPrice}",
                "${item.physicalWPrice - item.systemWPrice}",
              ),

              _row(
                "Sale Rate",
                "${item.systemPrice}",
                "${item.physicalPrice}",
                "${item.physicalPrice - item.systemPrice}",
              ),

              const SizedBox(height: 10),

              /// ACTIONS
              if (!readOnly && !item.isApproved)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onAdjust,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text("Adjust"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text("Approve"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// TABLE ROW BUILDER
  Widget _row(String label, String sys, String phy, String diff) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(flex: 2, child: Text(sys, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(phy, textAlign: TextAlign.center)),
          Expanded(
            flex: 2,
            child: Text(
              diff,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
