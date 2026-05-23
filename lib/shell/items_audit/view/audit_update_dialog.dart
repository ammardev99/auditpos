import 'package:flutter/material.dart';
import '../data/audit_item_model.dart';

class AuditUpdateDialog extends StatefulWidget {
  final AuditItemModel item;
  final Function(
    double qty,
    double price,
    double wholesalePrice,
    String rack,
  ) onSave;

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
      text: widget.item.phyQty.toString(),
    );
    priceController = TextEditingController(
      text: widget.item.phyPrice.toString(),
    );
    wholesalePriceController = TextEditingController(
      text: widget.item.phyWholesalePrice.toString(),
    );
    rackController = TextEditingController(
      text: widget.item.phyRack,
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
    return AlertDialog(
      title: Text(widget.item.productName),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Physical Qty",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Physical Price",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: wholesalePriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Physical Wholesale Price",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rackController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: "Physical Rack No.",
                hintText: "e.g. A55",
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final qty = double.tryParse(qtyController.text) ?? 0.0;
            final price = double.tryParse(priceController.text) ?? 0.0;
            final wholesalePrice = double.tryParse(wholesalePriceController.text) ?? 0.0;
            final rack = rackController.text.trim();

            widget.onSave(qty, price, wholesalePrice, rack);
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
// import 'package:flutter/material.dart';

// import '../data/audit_item_model.dart';

// class AuditUpdateDialog
//     extends StatefulWidget {

//   final AuditItemModel item;

//   final Function(
//     double qty,
//     double price,
//   ) onSave;

//   const AuditUpdateDialog({
//     super.key,
//     required this.item,
//     required this.onSave,
//   });

//   @override
//   State<AuditUpdateDialog> createState() =>
//       _AuditUpdateDialogState();
// }

// class _AuditUpdateDialogState
//     extends State<AuditUpdateDialog> {

//   late TextEditingController qtyController;

//   late TextEditingController
//       priceController;

//   @override
//   void initState() {
//     super.initState();

//     qtyController =
//         TextEditingController(
//       text: widget.item.phyQty.toString(),
//     );

//     priceController =
//         TextEditingController(
//       text:
//           widget.item.phyPrice.toString(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {

//     return AlertDialog(

//       title: Text(
//         widget.item.productName,
//       ),

//       content: Column(
//         mainAxisSize: MainAxisSize.min,

//         children: [

//           TextField(
//             controller: qtyController,

//             keyboardType:
//                 TextInputType.number,

//             decoration:
//                 const InputDecoration(
//               labelText:
//                   "Physical Qty",
//             ),
//           ),

//           const SizedBox(height: 12),

//           TextField(
//             controller:
//                 priceController,

//             keyboardType:
//                 TextInputType.number,

//             decoration:
//                 const InputDecoration(
//               labelText:
//                   "Physical Price",
//             ),
//           ),
//         ],
//       ),

//       actions: [

//         TextButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },

//           child: const Text("Cancel"),
//         ),

//         ElevatedButton(
//           onPressed: () {

//             final qty =
//                 double.tryParse(
//                       qtyController.text,
//                     ) ??
//                     0;

//             final price =
//                 double.tryParse(
//                       priceController.text,
//                     ) ??
//                     0;

//             widget.onSave(
//               qty,
//               price,
//             );

//             Navigator.pop(context);
//           },

//           child: const Text("Save"),
//         ),
//       ],
//     );
//   }
// }