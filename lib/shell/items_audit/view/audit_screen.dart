import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shell/network/app_constants.dart';
import '../../../shell/network/websocket_service.dart';

import '../data/audit_provider.dart';

import 'audit_item_tile.dart';
import 'audit_update_dialog.dart';

class AuditScreen extends ConsumerStatefulWidget {
  const AuditScreen({super.key});

  @override
  ConsumerState<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends ConsumerState<AuditScreen> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(auditProvider);
    final notifier = ref.read(auditProvider.notifier);

    final totalItems = state.items.length;
    final updatedItems = state.items.where((e) => e.phyQty > 0).length;

    return ValueListenableBuilder<bool>(
      valueListenable: WebSocketService.instance.isConnectedNotifier,
      builder: (context, connected, _) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.session == null
                      ? "Audit Session"
                      : state.session!.auditNo,
                ),
                Text(
                  "$updatedItems / $totalItems Updated",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [
              Tooltip(
                message: AppConstants.wsUrl,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 14,
                        color: connected ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        connected ? "WS" : "OFF",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar:
              !connected
                  ? null
                  : Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        icon: Icon(
                          state.session == null
                              ? Icons.play_arrow
                              : Icons.check,
                        ),
                        onPressed:
                            state.loading
                                ? null
                                : () {
                                  if (state.session == null) {
                                    notifier.startAudit();
                                  } else {
                                    notifier.completeAudit();
                                  }
                                },
                        label: Text(
                          state.loading
                              ? "PLEASE WAIT..."
                              : state.session == null
                              ? "START AUDIT"
                              : "COMPLETE AUDIT",
                        ),
                      ),
                    ),
                  ),
          body:
              !connected
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off, size: 60, color: Colors.red),
                        SizedBox(height: 12),
                        Text(
                          "WebSocket Disconnected",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Audit operations are blocked until connection restores.",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                  : Column(
                    children: [
                      /// SEARCH BAR (Shows if we have *any* master items loaded)
                      if (state.items.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) {
                              notifier.searchItems(value);
                            },
                            decoration: InputDecoration(
                              hintText: "Search by name or barcode",
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon:
                                  searchController.text.isNotEmpty
                                      ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          searchController.clear();
                                          notifier.searchItems('');
                                          setState(() {});
                                        },
                                      )
                                      : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                      /// STATS CHIPS BAR
                      if (state.session != null && state.items.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              _buildChip(
                                label: "Total $totalItems",
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              _buildChip(
                                label: "Updated $updatedItems",
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              _buildChip(
                                label: "Pending ${totalItems - updatedItems}",
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 8),

                      /// CONDITIONAL CONTENT WINDOW
                      if (state.loading)
                        const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (state.items.isEmpty)
                        const Expanded(
                          child: Center(
                            child: Text("Click on START AUDIT and load items"),
                          ),
                        )
                      else if (state.filteredItems.isEmpty)
                        const Expanded(
                          child: Center(
                            child: Text("No items match your search criteria"),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemCount: state.filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = state.filteredItems[index];

                              return AuditItemTile(
                                item: item,
                                onTap: () {
                                  if (!connected) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("WebSocket disconnected"),
                                      ),
                                    );
                                    return;
                                  }

                                  showDialog(
                                    context: context,
                                    builder: (_) {
                                      return AuditUpdateDialog(
                                        item: item,
                                        onSave: (
                                          qty,
                                          price,
                                          wholesalePrice,
                                          rack,
                                        ) {
                                          notifier.updateAuditItem(
                                            productId: item.productId,
                                            phyQty: qty,
                                            phyPrice: price,
                                            phyWholesalePrice: wholesalePrice,
                                            phyRack: rack,
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
        );
      },
    );
  }

  Widget _buildChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
