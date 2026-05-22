import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shell/network/websocket_service.dart'; // Adjust path to match your layout
import 'audit_confirmation_state.dart';
import 'confirmation_item_model.dart';

final auditConfirmationProvider = StateNotifierProvider.family<
  AuditConfirmationNotifier,
  AuditConfirmationState,
  int
>((ref, auditId) {
  return AuditConfirmationNotifier(auditId: auditId);
});

class AuditConfirmationNotifier extends StateNotifier<AuditConfirmationState> {
  final int auditId;

  AuditConfirmationNotifier({required this.auditId})
    : super(AuditConfirmationState());

  void initializeModule() {
    state = state.copyWith(isLoading: true);
    final previousGlobalCallback = WebSocketService.instance.onMessage;

    WebSocketService.instance.onMessage = (data) {
      final String? actionReceived = data['action'];

      // Catch backend list delivery
      if (actionReceived == 'get_audit_items') {
        final List rawDataList = data['data'] ?? [];
        final parsed =
            rawDataList.map((e) => ConfirmationItemModel.fromJson(e)).toList();
        state = state.copyWith(isLoading: false, items: parsed);
      }

      // Automatically refresh when server states change or confirm a row approval
      if (actionReceived == 'update_audit_item' ||
          actionReceived == 'audit_item_approved') {
        fetchDataFromServer();
      }

      if (previousGlobalCallback != null) {
        previousGlobalCallback(data);
      }
    };

    fetchDataFromServer();
  }

  void fetchDataFromServer() {
    WebSocketService.instance.send({
      "action": "get_audit_items",
      "payload": {
        "audit_id": auditId,
        "mismatch_only":
            state
                .showMismatchesOnly, // Passes boolean directly to your PHP script
      },
    });
  }

  void toggleServerFilter() {
    state = state.copyWith(
      showMismatchesOnly: !state.showMismatchesOnly,
      isLoading: true,
    );
    fetchDataFromServer();
  }

  void updateSearchBarText(String text) {
    state = state.copyWith(searchQuery: text);
  }

  // Sends your backend JS equivalent action request
  void approveSingleRowItem(int productId) {
    WebSocketService.instance.send({
      "action": "approve_audit_item",
      "payload": {"audit_id": auditId, "product_id": productId},
    });
  }

  // Send an adjustment down the wire
  void submitItemAdjustment({
    required int productId,
    required int qty,
    required double price,
  }) {
    WebSocketService.instance.send({
      "action": "update_audit_item",
      "payload": {
        "audit_id": auditId,
        "product_id": productId,
        "phyQty": qty,
        "phyPrice": price,
      },
    });
  }
}
