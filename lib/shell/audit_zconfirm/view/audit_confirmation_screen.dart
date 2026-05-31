import 'package:auditpos/shell/audit_zconfirm/view/audit_adjustment_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zi_core/zi_core_io.dart';
import '../../../bar_code_scanner/bar_code_io.dart';
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

  // The Scanner logic
  Future<void> _handleScan(AuditConfirmationNotifier notifier) async {
    final code = await ZiToBarCodeScanner.scan(context);
    if (code != null) {
      _searchFieldController.text = code;
      notifier.updateSearchBarText(code);
      setState(() {}); // Rebuild to update suffix icon to 'clear'
    }
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
        subtitle: widget.readOnly ? "READ ONLY MODE" : null,
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
              onChanged: (value) {
                notifierAction.updateSearchBarText(value);
                setState(() {}); // Rebuild to toggle between scan/clear
              },
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
                            setState(() {});
                          },
                        )
                        : IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: () => _handleScan(notifierAction),
                        ),
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
              ? Center(
                child: Text(
                  _searchFieldController.text.isNotEmpty
                      ? "No items match: '${_searchFieldController.text}'"
                      : "No items match specifications.",
                  style: const TextStyle(color: Colors.grey),
                ),
              )
              : ListView.builder(
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
            title: const Text("Update in System?"),

            content: Text(
              "${targetItem.productName}\nThis will synchronize quantities directly into live stock inventory tracking tables.",
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

                child: const Text(
                  "Confirm & Sync",
                  style: TextStyle(color: ZiColors.white),
                ),
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
                  rack: rack,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
