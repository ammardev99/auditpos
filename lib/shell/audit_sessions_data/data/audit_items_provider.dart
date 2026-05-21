import 'package:auditpos/shell/audit_sessions_data/data/after_audit_state.dart';
import 'package:auditpos/shell/audit_sessions_data/data/after_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shell/network/websocket_service.dart';

final auditItemsProvider =
    StateNotifierProvider.family<AuditItemsNotifier, AfterAuditItemsState, int>(
  (ref, auditId) {
    // FIXED: Passed auditId as a named parameter as required by your constructor
    return AuditItemsNotifier(auditId: auditId); 
  },
);
class AuditItemsNotifier extends StateNotifier<AfterAuditItemsState> {
final int auditId;

  AuditItemsNotifier({required this.auditId}) : super(AfterAuditItemsState());

  void setupListenerAndFetch() {
    state = state.copyWith(loading: true);
    final originalCallback = WebSocketService.instance.onMessage;

    WebSocketService.instance.onMessage = (data) {
      if (data['action'] == 'get_audit_items') {
        final List list = data['data'] ?? [];
        final parsedItems =
            list.map((e) => AfterAuditItemModel.fromJson(e)).toList();
        state = state.copyWith(loading: false, items: parsedItems);
      }

      if (data['action'] == 'update_audit_item') {
        getAuditItems();
      }

      // 1. ADD THIS LISTENER: Handle single item approval confirmation from server
      if (data['action'] == 'audit_item_approved') {
        // Extract incoming data map safely
        final responseData = data['data'] ?? {};
        final pid = int.tryParse(responseData['product_id'].toString()) ?? 0;

        state = state.copyWith(
          items:
              state.items.map((item) {
                if (item.productId == pid) {
                  // Update status keys locally just like your developer's 'updateLocalItem' function
                  return item.copyWith(status: 'approved', isApproved: true);
                }
                return item;
              }).toList(),
        );
      }

      if (originalCallback != null) {
        originalCallback(data);
      }
    };

    getAuditItems();
  }

  // 2. UPDATE THIS METHOD: Send the correct message structure down the wire
  void approveSingleItem(int productId) {
    WebSocketService.instance.send({
      "action": "approve_audit_item",
      "payload": {"audit_id": auditId, "product_id": productId},
    });
  }

  void toggleFilter() {
    state = state.copyWith(showOnlyMismatches: !state.showOnlyMismatches);
  }

  void getAuditItems() {
    WebSocketService.instance.send({
      "action": "get_audit_items",
      "payload": {"audit_id": auditId},
    });
  }

  void updateItemDetails({
    required int productId,
    required int phyQty,
    required double phyPrice,
  }) {
    WebSocketService.instance.send({
      "action": "update_audit_item",
      "payload": {
        "audit_id": auditId,
        "product_id": productId,
        "phyQty": phyQty,
        "phyPrice": phyPrice,
      },
    });
  }

  void approveAndSyncAudit() {
    state = state.copyWith(loading: true);

    WebSocketService.instance.send({
      "action": "approve_audit",
      "payload": {"audit_id": auditId},
    });
  }

void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}
