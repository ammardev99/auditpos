import 'package:flutter/material.dart';

import '../data/audit_item_model.dart';

class AuditUpdateDialog
    extends StatefulWidget {

  final AuditItemModel item;

  final Function(
    double qty,
    double price,
  ) onSave;

  const AuditUpdateDialog({
    super.key,
    required this.item,
    required this.onSave,
  });

  @override
  State<AuditUpdateDialog> createState() =>
      _AuditUpdateDialogState();
}

class _AuditUpdateDialogState
    extends State<AuditUpdateDialog> {

  late TextEditingController qtyController;

  late TextEditingController
      priceController;

  @override
  void initState() {
    super.initState();

    qtyController =
        TextEditingController(
      text: widget.item.phyQty.toString(),
    );

    priceController =
        TextEditingController(
      text:
          widget.item.phyPrice.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(

      title: Text(
        widget.item.productName,
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,

        children: [

          TextField(
            controller: qtyController,

            keyboardType:
                TextInputType.number,

            decoration:
                const InputDecoration(
              labelText:
                  "Physical Qty",
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller:
                priceController,

            keyboardType:
                TextInputType.number,

            decoration:
                const InputDecoration(
              labelText:
                  "Physical Price",
            ),
          ),
        ],
      ),

      actions: [

        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },

          child: const Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: () {

            final qty =
                double.tryParse(
                      qtyController.text,
                    ) ??
                    0;

            final price =
                double.tryParse(
                      priceController.text,
                    ) ??
                    0;

            widget.onSave(
              qty,
              price,
            );

            Navigator.pop(context);
          },

          child: const Text("Save"),
        ),
      ],
    );
  }
}