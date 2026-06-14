import 'package:flutter/material.dart';
import 'package:zi_core/zi_core_io.dart';
import '../../bar_code_scanner/bar_code_io.dart';
import '../network/websocket_service.dart';

class AddProductScreen extends StatefulWidget {
  final String? productCode;
  const AddProductScreen({super.key, this.productCode});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  @override
  void initState() {
    super.initState();

    if (widget.productCode != null) {
      codeController.text = widget.productCode!;
    }

    WebSocketService.instance.messageStream.listen(_handleWSResponse);
  }

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final urduNameController = TextEditingController();
  final codeController = TextEditingController();
  final brandController = TextEditingController();
  final categoryController = TextEditingController();
  final currentRateController = TextEditingController();
  final wholesaleController = TextEditingController();
  final purchaseController = TextEditingController();
  final alertController = TextEditingController();
  final rackController = TextEditingController();
  final descriptionController = TextEditingController();

  bool loading = false;

  Future<void> scanBarcode() async {
    final code = await ZiToBarCodeScanner.scan(context);

    if (code == null || code.isEmpty) return;

    setState(() {
      codeController.text = code;
    });
  }

  void submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final payload = {
      "action": "create_product",
      "payload": {
        "product_name": nameController.text,
        "product_name_urdu": nameController.text,
        "product_code": codeController.text,
        "brand_id": int.tryParse(brandController.text) ?? 0,
        "category_id": int.tryParse(categoryController.text) ?? 0,
        "current_rate": double.tryParse(currentRateController.text) ?? 0,
        "f_days": double.tryParse(wholesaleController.text) ?? 0,
        "purchase_rate": double.tryParse(purchaseController.text) ?? 0,
        "alert_at": int.tryParse(alertController.text) ?? 0,
        "availability": 1,
        "rack": rackController.text,
        "product_description": descriptionController.text,
      },
    };

    WebSocketService.instance.send(payload);
  }
  // void submit() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   setState(() => loading = true);

  //   final payload = {
  //     "action": "create_product",
  //     "payload": {
  //       "product_name": nameController.text,
  //       "product_name_urdu": nameController.text,
  //       // "product_name_urdu": urduNameController.text,
  //       "product_code": codeController.text,
  //       "brand_id": int.tryParse(brandController.text) ?? 0,
  //       "category_id": int.tryParse(categoryController.text) ?? 0,
  //       "current_rate": double.tryParse(currentRateController.text) ?? 0,
  //       "f_days": double.tryParse(wholesaleController.text) ?? 0,
  //       "purchase_rate": double.tryParse(purchaseController.text) ?? 0,
  //       "alert_at": int.tryParse(alertController.text) ?? 0,
  //       "availability": 1,
  //       "rack": rackController.text,
  //       "product_description": descriptionController.text,
  //     },
  //   };

  //   WebSocketService.instance.send(payload);

  //   setState(() => loading = false);

  //   if (mounted) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Product sent to server")));
  //     Navigator.pop(context);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return ZiScaffoldB(
      appBar: ZiAppBarB(title: "Add Product"),

      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            ziGap(10),
            ZiInput(
              controller: codeController,
              label: "Product Code",
              type: ZiInputType.text,
              variant: ZiInputVariant.animateLabelOutline,
              validator: (v) => v!.isEmpty ? "Required" : null,
              suffix: IconButton(
                onPressed: scanBarcode,
                icon: Icon(Icons.qr_code),
              ),
              isRequired: true,
            ),

            ziGap(10),

            ZiInput(
              controller: nameController,
              label: "Product Name",
              variant: ZiInputVariant.animateLabelOutline,
              type: ZiInputType.text,
              isRequired: true,
            ),

            ziGap(10),

            // ZiInput(
            //   controller: urduNameController,
            //   label: "Product Name (Urdu)",
            //   type: ZiInputType.text,
            //   variant: ZiInputVariant.animateLabelOutline,
            // ),

            // ZiInput(
            //   controller: brandController,
            //   label: "Brand ID",
            //   variant: ZiInputVariant.animateLabelOutline,
            //   type: ZiInputType.number,
            // ),

            // ZiInput(
            //   controller: categoryController,
            //   label: "Category ID",
            //   variant: ZiInputVariant.animateLabelOutline,
            //   type: ZiInputType.number,
            // ),
            ziGap(10),
            Row(
              children: [
                Expanded(
                  child: ZiInput(
                    controller: alertController,
                    label: "Alert Qty",
                    variant: ZiInputVariant.animateLabelOutline,
                    type: ZiInputType.number,
                  ),
                ),
                ziGap(10),
                Expanded(
                  child: ZiInput(
                    controller: rackController,
                    label: "Rack",
                    variant: ZiInputVariant.animateLabelOutline,
                    type: ZiInputType.text,
                  ),
                ),
              ],
            ),
            ziGap(10),
            Row(
              children: [
                Expanded(
                  child: ZiInput(
                    controller: currentRateController,
                    label: "Current Rate",
                    variant: ZiInputVariant.animateLabelOutline,
                    type: ZiInputType.number,
                    isRequired: true,
                  ),
                ),
                ziGap(10),
                Expanded(
                  child: ZiInput(
                    controller: wholesaleController,
                    label: "Wholesale Rate",
                    variant: ZiInputVariant.animateLabelOutline,
                    type: ZiInputType.number,
                    isRequired: true,
                  ),
                ),
              ],
            ),

            ziGap(10),
            ZiInput(
              controller: purchaseController,
              label: "Purchase Rate",
              variant: ZiInputVariant.animateLabelOutline,
              type: ZiInputType.number,
              isRequired: true,
            ),

            ziGap(10),
            ZiInput(
              controller: descriptionController,
              hint: "Description",
              variant: ZiInputVariant.animateLabelOutline,
              type: ZiInputType.multiline,
            ),

            const SizedBox(height: 20),

            ZiButtonB(
              label: loading ? "Creating..." : "Add New Item",
              action: () async {
                final isValid = _formKey.currentState!.validate();

                if (!isValid) return;

                final isCreate = await ZiConfirmationUser.saveChanges(
                  context: context,
                  title: "${nameController.text} ${currentRateController.text}",
                );

                if (isCreate == true) {
                  submit();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleWSResponse(Map<String, dynamic> msg) {
    if (msg['action'] != 'create_product') return;

    if (!mounted) return;

    setState(() => loading = false);

    if (msg['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Product created successfully (ID: ${msg['product_id']})",
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg['message'] ?? "Failed to create product"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
