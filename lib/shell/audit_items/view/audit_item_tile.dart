import 'package:flutter/material.dart';
import 'package:zi_core/zi_core_io.dart';

import '../data/audit_item_model.dart';

class AuditItemTile extends StatelessWidget {
  final AuditItemModel item;
  final VoidCallback onTap;

  const AuditItemTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final showAudit = item.audited;

    final qtyMismatch = showAudit && item.sysQty != item.phyQty;

    final rackMismatch = showAudit && item.sysRack != item.phyRack;

    final wholesaleMismatch =
        showAudit && item.sysWholesalePrice != item.phyWholesalePrice;

    final saleMismatch = showAudit && item.sysPrice != item.phyPrice;

    final hasMismatch =
        qtyMismatch || rackMismatch || wholesaleMismatch || saleMismatch;

    final mismatchQty = item.mismatchQty;

    final isShortage = mismatchQty < 0;

    final isExcess = mismatchQty > 0;

    final Color stateColor =
        isShortage
            ? Colors.red.shade700
            : isExcess
            ? Colors.orange.shade700
            : Colors.green.shade700;

    return Card(
      elevation: 1,
      color: ZiColors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: hasMismatch ? stateColor.withAlpha(60) : Colors.grey.shade200,
        ),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 12),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// HEADER
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
                          ),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            Icon(Icons.qr_code, size: 18, color: ZiColors.grayLight,),
                            ziGap(4),
                            Text(
                              item.productCode,
                            
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontFamily: "monospace",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  _buildStatusBadge(
                    hasMismatch: hasMismatch,

                    isShortage: isShortage,

                    mismatchQty: mismatchQty,

                    mismatchValue: item.mismatchValue,

                    stateColor: stateColor,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              /// TABLE HEADER
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),

                decoration: BoxDecoration(
                  color: Colors.grey.shade100,

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
                      child: Text("SYS", textAlign: TextAlign.center),
                    ),

                    Expanded(
                      flex: 2,
                      child: Text("Δ", textAlign: TextAlign.center),
                    ),

                    Expanded(
                      flex: 2,
                      child: Text(
                        "PHY",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              buildAuditRow(
                label: "Rack",

                sys: item.sysRack.isEmpty ? "-" : item.sysRack,

                phy: showAudit ? item.phyRack : "-",

                diff:
                    !showAudit
                        ? "—"
                        : item.sysRack == item.phyRack
                        ? "✓"
                        : "●",

                bg: Colors.white,
              ),

              buildAuditRow(
                label: "Qty",

                sys: "${item.sysQty}",

                phy: showAudit ? "${item.phyQty}" : "-",

                diff: showAudit ? "${item.mismatchQty}" : "—",

                bg: Colors.grey.shade100,
              ),
              buildAuditRow(
                label: "Wholesale",

                sys: "${item.sysWholesalePrice}",

                phy: showAudit ? "${item.phyWholesalePrice}" : "-",

                diff:
                    showAudit
                        ? "${item.phyWholesalePrice - item.sysWholesalePrice}"
                        : "—",

                bg: Colors.white,
              ),

              buildAuditRow(
                label: "Sale Rate",

                sys: "${item.sysPrice}",

                phy: showAudit ? "${item.phyPrice}" : "-",

                diff: showAudit ? "${item.phyPrice - item.sysPrice}" : "—",

                bg: Colors.grey.shade100,
              ),

              const Divider(),

              Row(
                children: [
                  Text(
                    "#${item.id}",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),

                  const Spacer(),

                  IconButton(
                    onPressed: onTap,

                    icon: Icon(Icons.edit, color: ZiColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAuditRow({
    required String label,
    required String sys,
    required String phy,
    required String diff,

    Color? bg,
    Color? diffColor,
  }) {
    return Container(
      color: bg,

      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

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

          Expanded(
            flex: 2,

            child: Text(
              diff,

              textAlign: TextAlign.center,

              style: TextStyle(color: diffColor, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            flex: 2,

            child: Text(
              phy,

              textAlign: TextAlign.center,

              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge({
    required bool hasMismatch,
    required bool isShortage,
    required double mismatchQty,
    required double mismatchValue,
    required Color stateColor,
  }) {
    if (!hasMismatch) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

        decoration: BoxDecoration(
          color: Colors.green.shade50,

          borderRadius: BorderRadius.circular(8),
        ),

        child: Text(
          "MATCHED",

          style: TextStyle(
            color: Colors.green.shade700,

            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

      decoration: BoxDecoration(
        color: stateColor.withAlpha(25),

        borderRadius: BorderRadius.circular(8),
      ),

      child: Column(
        children: [
          Text(
            isShortage ? "Missing" : "EXCESS",

            style: TextStyle(color: stateColor, fontWeight: FontWeight.bold),
          ),

          Text("$mismatchQty", style: TextStyle(color: stateColor)),
        ],
      ),
    );
  }
}
