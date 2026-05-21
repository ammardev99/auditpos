import 'package:auditpos/shell/audit_sessions_data/data/after_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/audit_items_provider.dart';

class AuditDetailScreen extends ConsumerStatefulWidget {
  final int auditId;
  final String auditNo;

  const AuditDetailScreen({
    super.key,
    required this.auditId,
    required this.auditNo,
  });

  @override
  ConsumerState<AuditDetailScreen> createState() => _AuditDetailScreenState();
}

class _AuditDetailScreenState extends ConsumerState<AuditDetailScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      ref.read(auditItemsProvider(widget.auditId).notifier).setupListenerAndFetch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(auditItemsProvider(widget.auditId));
    final notifier = ref.read(auditItemsProvider(widget.auditId).notifier);
    final displayedList = state.visibleItems;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.auditNo),
        actions: [
          IconButton(
            icon: Icon(
              state.showOnlyMismatches ? Icons.filter_alt : Icons.filter_alt_off,
              color: state.showOnlyMismatches ? Colors.orange : Colors.white,
            ),
            tooltip: state.showOnlyMismatches ? "Showing Mismatches Only" : "Showing All Items",
            onPressed: () => notifier.toggleFilter(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.getAuditItems(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90.0), // Expanded to accommodate search field bar
          child: Column(
            children: [
              // Search Input field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => notifier.updateSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: "Search by Product name or Barcode...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.clear), 
                            onPressed: () {
                              _searchController.clear();
                              notifier.updateSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 2.0),
                child: Text(
                  "Active Mismatches Detected: ${state.totalMismatches}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.amberAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : displayedList.isEmpty
              ? Center(
                  child: Text(
                    state.showOnlyMismatches
                        ? "No discrepancies matched your search criteria!"
                        : "No inventory items found.",
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: displayedList.length,
                  itemBuilder: (context, index) {
                    final item = displayedList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: item.isMismatch && !item.isApproved
                          ? RoundedRectangleBorder(
                              side: const BorderSide(color: Colors.redAccent, width: 1),
                              borderRadius: BorderRadius.circular(12),
                            )
                          : null,
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
                                    item.productName,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (item.isMismatch && !item.isApproved)
                                  const Badge(
                                    label: Text("Mismatch"),
                                    backgroundColor: Colors.red,
                                  )
                                else if (item.isApproved)
                                  const Badge(
                                    label: Text("Approved"),
                                    backgroundColor: Colors.green,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // CHANGED FROM ID TO BARCODE TEXT DISPLAY FIELD
                            Text(
                              "Barcode: ${item.barcode}",
                              style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text("System Data", style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text("Qty: ${item.systemQty}"),
                                    Text("\$${item.systemPrice.toStringAsFixed(2)}"),
                                  ],
                                ),
                                const Icon(Icons.arrow_right_alt, color: Colors.grey),
                                Column(
                                  children: [
                                    Text(
                                      !item.isCounted
                                          ? "Physical (Untouched)"
                                          : item.isMismatch
                                              ? "Physical (Discrepancy)"
                                              : "Physical (Matched)",
                                      style: TextStyle(
                                        color: !item.isCounted
                                            ? Colors.grey
                                            : item.isMismatch
                                                ? Colors.orange
                                                : Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text("Qty: ${item.isCounted ? item.physicalQty : '-'}"),
                                    Text(item.isCounted ? "\$${item.physicalPrice.toStringAsFixed(2)}" : "\$ --"),
                                  ],
                                ),
                              ],
                            ),
                            
                            // CONDITIONAL LOGIC CHECK:
                            // If the item is already approved (isApproved == true), 
                            // we hide the actions entirely so they cannot be fired again.
                            if (!item.isApproved) ...[
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.edit, color: Colors.orange),
                                    label: const Text("Adjust Counts"),
                                    onPressed: () => _showAdjustmentDialog(context, item, notifier),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.check),
                                    label: const Text("Approve"),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Approve Item?"),
                                          content: Text("Approve and update ${item.productName} in live inventory?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text("Cancel"),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                              onPressed: () {
                                                notifier.approveSingleItem(item.productId);
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Approve & Sync"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showAdjustmentDialog(
    BuildContext context,
    AfterAuditItemModel item,
    AuditItemsNotifier notifier,
  ) {
    final qtyController = TextEditingController(
      text: item.physicalQty.toString(),
    );
    final priceController = TextEditingController(
      text: item.physicalPrice.toString(),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text("Adjust ${item.productName}"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Physical Quantity Count",
                  ),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Physical Unit Price",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final newQty =
                      int.tryParse(qtyController.text) ?? item.physicalQty;
                  final newPrice =
                      double.tryParse(priceController.text) ??
                      item.physicalPrice;

                  notifier.updateItemDetails(
                    productId: item.productId,
                    phyQty: newQty,
                    phyPrice: newPrice,
                  );
                  Navigator.pop(context);
                },
                child: const Text("Save Adjustments"),
              ),
            ],
          ),
    );
  }
}
