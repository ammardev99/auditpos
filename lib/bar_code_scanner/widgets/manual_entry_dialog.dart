import 'package:flutter/material.dart';
import 'package:zi_core/zi_core_io.dart';

class ManualEntryDialog extends StatefulWidget {
  const ManualEntryDialog({super.key});

  @override
  State<ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<ManualEntryDialog> {
  final controller = TextEditingController();

  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 250), () {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    controller.dispose();

    focusNode.dispose();

    super.dispose();
  }

  void submit() {
    final value = controller.text.trim();

    if (value.isEmpty) return;

    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,

      child: Container(
        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(28),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),

                  decoration: BoxDecoration(
                    color: ZiColors.accent,

                    shape: BoxShape.circle,
                  ),

                  child: Icon(Icons.qr_code, size: 28, color: ZiColors.primary),
                ),

                const SizedBox(width: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Manual Entry",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "Enter value manually",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            TextField(
              controller: controller,

              focusNode: focusNode,

              textInputAction: TextInputAction.done,

              onSubmitted: (_) => submit(),

              decoration: InputDecoration(
                hintText: "Barcode / QR",

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),

                    child: const Text("Cancel"),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: submit,
                    child: const Text("Add"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
