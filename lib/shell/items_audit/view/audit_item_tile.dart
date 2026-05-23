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

    // Elegant colors for auditing states
    final Color stateColor =
        isShortage
            ? Colors.red.shade700
            : isExcess
            ? Colors.orange.shade800
            : Colors.green.shade700;

    final Color cardBorderColor =
        hasMismatch ? stateColor.withAlpha(40) : Colors.grey.shade200;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cardBorderColor, width: 1.5),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Item Header & Dynamic State Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.qr_code,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.productCode,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Mismatch indicator pill
                  _buildStatusBadge(
                    hasMismatch: hasMismatch,
                    isShortage: isShortage,
                    mismatchQty: mismatchQty,
                    mismatchValue: item.mismatchValue,
                    stateColor: stateColor,
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, thickness: 0.5),
              ),

              // Bottom Grid: System vs Physical comparison table look
              Row(
                children: [
                  // System Metrics Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("SYSTEM (SYS)"),
                        const SizedBox(height: 4),
                        _buildMetricRow("Qty:", "${item.sysQty}"),
                        _buildMetricRow("Price:", "Rs. ${item.sysPrice}"),
                        _buildMetricRow(
                          "Wholesale:",
                          "Rs. ${item.sysWholesalePrice}",
                        ),
                        _buildMetricRow(
                          "Rack Location:",
                          item.sysRack.isEmpty ? '—' : item.sysRack,
                        ),
                      ],
                    ),
                  ),

                  // Clean vertical spacer element
                  Container(
                    height: 75,
                    width: 1,
                    color: Colors.grey.shade200,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),

                  // Physical Metrics Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          "PHYSICAL (PHY)",
                          textColor: Colors.blue.shade800,
                        ),
                        const SizedBox(height: 4),
                        _buildMetricRow("Qty:", "${item.phyQty}", isBold: true),
                        _buildMetricRow(
                          "Price:",
                          "Rs. ${item.phyPrice}",
                          isBold: true,
                        ),
                        _buildMetricRow(
                          "Wholesale:",
                          "Rs. ${item.phyWholesalePrice}",
                          isBold: true,
                        ),
                        _buildMetricRow(
                          "Rack Location:",
                          item.phyRack.isEmpty ? '—' : item.phyRack,
                          isBold: true,
                        ),
                      ],
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

  // Helper widget to construct clean metric subtitles
  Widget _buildSectionHeader(String title, {Color? textColor}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: textColor ?? Colors.grey.shade500,
      ),
    );
  }

  // Side-by-side metric lines builder
  Widget _buildMetricRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.black87 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // Renders beautiful background colored state chips on the top right corner
  Widget _buildStatusBadge({
    required bool hasMismatch,
    required bool isShortage,
    required double mismatchQty,
    required double mismatchValue,
    required Color stateColor,
  }) {
    if (!hasMismatch) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "MATCHED",
          style: TextStyle(
            color: Colors.green.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      );
    }

    final String qtySign = isShortage ? "" : "+";
    final String valSign = mismatchValue.isNegative ? "" : "+";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: stateColor.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            isShortage ? "SHORTAGE" : "EXCESS",
            style: TextStyle(
              color: stateColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Qty: $qtySign$mismatchQty",
            style: TextStyle(
              color: stateColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          Text(
            "$valSign$mismatchValue",
            style: TextStyle(
              color: stateColor,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
