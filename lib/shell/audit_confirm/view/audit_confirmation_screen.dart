import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/audit_confirmation_provider.dart';
import '../data/confirmation_item_model.dart';

class AuditConfirmationScreen extends ConsumerStatefulWidget {
  final int auditId;
  final String auditNo;

  const AuditConfirmationScreen({
    super.key,
    required this.auditId,
    required this.auditNo,
  });

  @override
  ConsumerState<AuditConfirmationScreen> createState() => _AuditConfirmationScreenState();
}

class _AuditConfirmationScreenState extends ConsumerState<AuditConfirmationScreen> {
  final TextEditingController _searchFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      ref.read(auditConfirmationProvider(widget.auditId).notifier).initializeModule();
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
    final notifierAction = ref.read(auditConfirmationProvider(widget.auditId).notifier);
    final visibleList = stateWatcher.computedVisibleItems;

    return Scaffold(
      appBar: AppBar(
        title: Text("Confirm Audit: ${widget.auditNo}"),
        actions: [
          IconButton(
            icon: Icon(
              stateWatcher.showMismatchesOnly ? Icons.filter_alt : Icons.filter_alt_off,
              color: stateWatcher.showMismatchesOnly ? Colors.orange : Colors.white,
            ),
            tooltip: stateWatcher.showMismatchesOnly ? "Mismatches Only" : "All Items Displayed",
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
                suffixIcon: _searchFieldController.text.isNotEmpty
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
      body: stateWatcher.isLoading
          ? const Center(child: CircularProgressIndicator())
          : visibleList.isEmpty
              ? const Center(child: Text("No items match specifications.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: visibleList.length,
                  itemBuilder: (context, idx) {
                    final targetItem = visibleList[idx];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: targetItem.isApproved ? Colors.green : Colors.redAccent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    targetItem.productName,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: targetItem.isApproved ? Colors.green : Colors.amber.shade700,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    targetItem.isApproved ? "Synced" : "Pending Sync",
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Barcode: ${targetItem.barcode}",
                              style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text("System", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                                    Text("Qty: ${targetItem.systemQty}"),
                                    Text("\$${targetItem.systemPrice.toStringAsFixed(2)}"),
                                  ],
                                ),
                                const Icon(Icons.compare_arrows, color: Colors.grey),
                                Column(
                                  children: [
                                    const Text("Physical", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                                    Text("Qty: ${targetItem.physicalQty}"),
                                    Text("\$${targetItem.physicalPrice.toStringAsFixed(2)}"),
                                  ],
                                ),
                              ],
                            ),
                            
                            // CONDITION RULE: Only show action configuration elements if row is NOT approved yet
                            if (!targetItem.isApproved) ...[
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.edit, color: Colors.orange, size: 18),
                                    label: const Text("Adjust Counts"),
                                    onPressed: () => _displayAdjustmentPopup(context, targetItem, notifierAction),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      // dense: true,
                                    ),
                                    icon: const Icon(Icons.check, size: 16),
                                    label: const Text("Approve"),
                                    onPressed: () => _displayConfirmationPopup(context, targetItem, notifierAction),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _displayConfirmationPopup(BuildContext context, ConfirmationItemModel targetItem, AuditConfirmationNotifier notifierAction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Approve Product Line?"),
        content: Text("Are you sure you want to approve ${targetItem.productName}? This will synchronize quantities directly into live stock inventory tracking tables."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
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

  void _displayAdjustmentPopup(BuildContext context, ConfirmationItemModel targetItem, AuditConfirmationNotifier notifierAction) {
    final qtyController = TextEditingController(text: targetItem.physicalQty.toString());
    final priceController = TextEditingController(text: targetItem.physicalPrice.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Adjust: ${targetItem.productName}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Physical Quantity Count"),
            ),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Physical Unit Price"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              final parsedQty = int.tryParse(qtyController.text) ?? targetItem.physicalQty;
              final parsedPrice = double.tryParse(priceController.text) ?? targetItem.physicalPrice;
              notifierAction.submitItemAdjustment(
                productId: targetItem.productId,
                qty: parsedQty,
                price: parsedPrice,
              );
              Navigator.pop(context);
            },
            child: const Text("Save Counts"),
          ),
        ],
      ),
    );
  }
}