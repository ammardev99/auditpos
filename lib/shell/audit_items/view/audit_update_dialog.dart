import 'package:flutter/material.dart';
import 'package:zi_core/zi_core_io.dart';
import '../data/audit_item_model.dart';

class AuditUpdateDialog extends StatefulWidget {
  final AuditItemModel item;
  final Function(double qty, double price, double wholesalePrice, String rack)
  onSave;

  const AuditUpdateDialog({
    super.key,
    required this.item,
    required this.onSave,
  });

  @override
  State<AuditUpdateDialog> createState() => _AuditUpdateDialogState();
}

class _AuditUpdateDialogState extends State<AuditUpdateDialog> {
  late TextEditingController qtyController;
  late TextEditingController priceController;
  late TextEditingController wholesalePriceController;
  late TextEditingController rackController;

  @override
  void initState() {
    super.initState();

    qtyController = TextEditingController(
      text:
          widget.item.phyQty != 0
              ? widget.item.phyQty.toString()
              : widget.item.sysQty.toString(),
    );

    priceController = TextEditingController(
      text:
          widget.item.phyPrice != 0
              ? widget.item.phyPrice.toString()
              : widget.item.sysPrice.toString(),
    );

    wholesalePriceController = TextEditingController(
      text:
          widget.item.phyWholesalePrice != 0
              ? widget.item.phyWholesalePrice.toString()
              : widget.item.sysWholesalePrice.toString(),
    );

    rackController = TextEditingController(
      text:
          widget.item.phyRack.trim().isNotEmpty
              ? widget.item.phyRack
              : widget.item.sysRack,
    );
  }

  @override
  void dispose() {
    qtyController.dispose();
    priceController.dispose();
    wholesalePriceController.dispose();
    rackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rack & Qty
          Row(
            children: [
              Expanded(
                child: ZiInput(
                  controller: rackController,
                  label: "Rack (${widget.item.sysRack})",
                  hint: " ",
                  variant: ZiInputVariant.stacked,
                ),
              ),
              ziGap(10),
              Expanded(
                child: ZiInput(
                  controller: qtyController,
                  label: "Phy Qty (${widget.item.sysQty})",
                  hint: " ",
                  type: ZiInputType.number,
                  variant: ZiInputVariant.stacked,
                ),
              ),
              ziGap(10),
            ],
          ),
          ziGap(16),
          // W-Rate & S-Rate
          Row(
            children: [
              Expanded(
                child: ZiInput(
                  controller: wholesalePriceController,
                  label: "W-Rate (${widget.item.sysWholesalePrice})",
                  hint: " ",
                  type: ZiInputType.number,
                  variant: ZiInputVariant.stacked,
                ),
              ),
              ziGap(10),
              Expanded(
                child: ZiInput(
                  controller: priceController,
                  label: "S-Rate (${widget.item.sysPrice})",
                  hint: " ",
                  type: ZiInputType.number,
                  variant: ZiInputVariant.stacked,
                ),
              ),
              ziGap(10),
            ],
          ),

          ziGap(8),
          Divider(),
          ziGap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(ZiColors.primary),
                ),
                onPressed: () {
                  final qty = double.tryParse(qtyController.text) ?? 0.0;
                  final price = double.tryParse(priceController.text) ?? 0.0;
                  final wholesalePrice =
                      double.tryParse(wholesalePriceController.text) ?? 0.0;
                  final rack = rackController.text.trim();
                  widget.onSave(qty, price, wholesalePrice, rack);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Save",
                  style: TextStyle(color: ZiColors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    // actions: [
    // ],
  }
}
