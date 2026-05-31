import 'package:auditpos/shell/audit_zconfirm/view/audit_adjustment_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zi_core/zi_core_io.dart';
import '../data/audit_confirmation_provider.dart';
import '../data/confirmation_item_model.dart';
import 'confirm_tile.dart';

class AuditConfirmationScreen extends ConsumerStatefulWidget {
  final int auditId;
  final String auditNo;

  // NEW
  final bool readOnly;

  const AuditConfirmationScreen({
    super.key,
    required this.auditId,
    required this.auditNo,

    // NEW
    this.readOnly = false,
  });

  @override
  ConsumerState<AuditConfirmationScreen> createState() =>
      _AuditConfirmationScreenState();
}

class _AuditConfirmationScreenState
    extends ConsumerState<AuditConfirmationScreen> {
  final TextEditingController _searchFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      ref
          .read(auditConfirmationProvider(widget.auditId).notifier)
          .initializeModule();
    });
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateWatcher = ref.watch(auditConfirmationProvider(widget.auditId));
    final notifierAction = ref.read(
      auditConfirmationProvider(widget.auditId).notifier,
    );
    final visibleList = stateWatcher.computedVisibleItems;
    return Scaffold(
      appBar: ZiAppBarB(
        title: "Confirm Audit: ${widget.auditNo}",
        subtitle:
            // READ ONLY BADGE
            widget.readOnly ? "READ ONLY MODE" : null,

        actions: [
          IconButton(
            icon: Icon(
              stateWatcher.showMismatchesOnly
                  ? Icons.filter_alt
                  : Icons.filter_alt_off,

              color:
                  stateWatcher.showMismatchesOnly
                      ? Colors.orange
                      : Colors.white,
            ),

            tooltip:
                stateWatcher.showMismatchesOnly
                    ? "Mismatches Only"
                    : "All Items Displayed",

            onPressed: () => notifierAction.toggleServerFilter(),
          ),

          IconButton(
            icon: const Icon(Icons.refresh),

            onPressed: () => notifierAction.fetchDataFromServer(),
          ),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(65.0),

          child: Padding(
            padding: const EdgeInsets.all(8.0),

            child: TextField(
              controller: _searchFieldController,

              onChanged: (value) => notifierAction.updateSearchBarText(value),

              decoration: InputDecoration(
                hintText: "Search items via Name or Barcode...",

                prefixIcon: const Icon(Icons.search, color: Colors.grey),

                suffixIcon:
                    _searchFieldController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),

                          onPressed: () {
                            _searchFieldController.clear();

                            notifierAction.updateSearchBarText('');
                          },
                        )
                        : null,

                filled: true,

                fillColor: Colors.white,

                contentPadding: EdgeInsets.zero,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),

                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),

      body:
          stateWatcher.isLoading
              ? const Center(child: CircularProgressIndicator())
              : visibleList.isEmpty
              ? const Center(
                child: Text(
                  "No items match specifications.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
              : // Inside your original screen's ListView.builder block:
              ListView.builder(
                itemCount: visibleList.length,
                itemBuilder: (context, idx) {
                  final targetItem = visibleList[idx];

                  return AuditConfirmItemTile(
                    item: targetItem,
                    readOnly: widget.readOnly,
                    onAdjust:
                        () => _displayAdjustmentPopup(
                          context,
                          targetItem,
                          notifierAction,
                        ),
                    onApprove:
                        () => _displayConfirmationPopup(
                          context,
                          targetItem,
                          notifierAction,
                        ),
                  );
                },
              ),
    );
  }

  void _displayConfirmationPopup(
    BuildContext context,
    ConfirmationItemModel targetItem,
    AuditConfirmationNotifier notifierAction,
  ) {
    showDialog(
      context: context,

      builder:
          (context) => AlertDialog(
            title: const Text("Approve Product Line?"),

            content: Text(
              "Are you sure you want to approve ${targetItem.productName}? This will synchronize quantities directly into live stock inventory tracking tables.",
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),

                child: const Text("Cancel"),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),

                onPressed: () {
                  notifierAction.approveSingleRowItem(targetItem.productId);

                  Navigator.pop(context);
                },

                child: const Text("Confirm & Sync"),
              ),
            ],
          ),
    );
  }

  void _displayAdjustmentPopup(
    BuildContext context,
    ConfirmationItemModel targetItem,
    AuditConfirmationNotifier notifierAction,
  ) {
    showDialog(
      
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: ZiColors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AuditAdjustmentDialogContent(
              item: targetItem,
              onSave: (qty, price, wPrice, rack) {
                notifierAction.submitItemAdjustment(
                  productId: targetItem.productId,
                  qty: qty.toInt(),
                  price: price,
                  wholesalePrice: wPrice,
                  rack: rack

                );

              },
            ),
          ),
        );
      },
    );
  }
}
