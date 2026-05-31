import 'package:flutter/material.dart';
import 'package:zi_core/zi_core_io.dart';

import '../data/confirmation_item_model.dart';

class AuditAdjustmentDialogContent extends StatefulWidget {
  final ConfirmationItemModel item;
  final Function(double qty, double price, double wholesalePrice, String rack)
  onSave;

  const AuditAdjustmentDialogContent({
    super.key,
    required this.item,
    required this.onSave,
  });

  @override
  State<AuditAdjustmentDialogContent> createState() =>
      _AuditAdjustmentDialogContentState();
}

class _AuditAdjustmentDialogContentState
    extends State<AuditAdjustmentDialogContent> {
  late TextEditingController qtyController;
  late TextEditingController priceController;
  late TextEditingController wPriceController;
  late TextEditingController rackController;

  @override
  void initState() {
    super.initState();

    qtyController = TextEditingController(
      text: widget.item.physicalQty.toString(),
    );

    priceController = TextEditingController(
      text: widget.item.physicalPrice.toString(),
    );

    wPriceController = TextEditingController(
      text: widget.item.physicalWPrice.toString(),
    );

    rackController = TextEditingController(text: widget.item.physicalRack);
  }

  @override
  void dispose() {
    qtyController.dispose();
    priceController.dispose();
    wPriceController.dispose();
    rackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// TITLE
          Text(
            "Adjust: ${widget.item.productName}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          /// ROW 1: RACK + QTY
          Row(
            children: [
              Expanded(
                child: ZiInput(
                  controller: rackController,
                  label: "Rack (${widget.item.systemRack})",
                  variant: ZiInputVariant.stacked,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ZiInput(
                  controller: qtyController,
                  label: "Qty (${widget.item.systemQty})",
                  type: ZiInputType.number,
                  variant: ZiInputVariant.stacked,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// ROW 2: WHOLESALE + RETAIL
          Row(
            children: [
              Expanded(
                child: ZiInput(
                  controller: wPriceController,
                  label:
                      "W-Rate (${widget.item.systemWPrice.toStringAsFixed(2)})",
                  type: ZiInputType.number,
                  variant: ZiInputVariant.stacked,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ZiInput(
                  controller: priceController,
                  label:
                      "S-Rate (${widget.item.systemPrice.toStringAsFixed(2)})",
                  type: ZiInputType.number,
                  variant: ZiInputVariant.stacked,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          /// ACTIONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final qty = double.tryParse(qtyController.text) ?? 0.0;

                  final price = double.tryParse(priceController.text) ?? 0.0;

                  final wPrice = double.tryParse(wPriceController.text) ?? 0.0;

                  final rack = rackController.text.trim();

                  widget.onSave(qty, price, wPrice, rack);

                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
