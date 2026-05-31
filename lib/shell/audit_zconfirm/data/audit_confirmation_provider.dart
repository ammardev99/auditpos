import 'dart:async'; // Add this import for StreamSubscription
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/websocket_service.dart';
import 'audit_confirmation_state.dart';
import 'confirmation_item_model.dart';

// Change to autoDispose.family
final auditConfirmationProvider = StateNotifierProvider.family
    .autoDispose<AuditConfirmationNotifier, AuditConfirmationState, int>((
      ref,
      auditId,
    ) {
      final notifier = AuditConfirmationNotifier(auditId: auditId);

      ref.onDispose(() {
        notifier.disposeModule();
      });

      return notifier;
    });

class AuditConfirmationNotifier extends StateNotifier<AuditConfirmationState> {
  final int auditId;
  StreamSubscription<Map<String, dynamic>>? _wsSubscription;

  AuditConfirmationNotifier({required this.auditId})
    : super(AuditConfirmationState());

  void initializeModule() {
    state = state.copyWith(isLoading: true);

    // Cancel old subscription if initialize gets called multiple times
    _wsSubscription?.cancel();

    // Subscribe to our brand new stream controller broadcast channel
    _wsSubscription = WebSocketService.instance.messageStream.listen((data) {
      final String? actionReceived = data['action'];

      // CRITICAL CHECK: Look closely at your raw logs: your server sends back "audit_id": 88
      // If the incoming message doesn't match this notifier's instance ID, drop it instantly!
      final int? incomingAuditId = int.tryParse(
        data['audit_id']?.toString() ?? '',
      );
      if (incomingAuditId != null && incomingAuditId != auditId) {
        return; // Ignore this message silently, it belongs to an older/different screen session
      }

      // Catch backend list delivery
      if (actionReceived == 'get_audit_items') {
        final List rawDataList = data['data'] ?? [];
        final parsed =
            rawDataList.map((e) => ConfirmationItemModel.fromJson(e)).toList();
        state = state.copyWith(isLoading: false, items: parsed);
      }

      // Automatically refresh when updates or row confirmations happen for THIS session
      if (actionReceived == 'update_audit_item' ||
          actionReceived == 'audit_item_approved' ||
          actionReceived == 'approve_audit_item') {
        fetchDataFromServer();
      }
    });

    fetchDataFromServer();
  }

  void fetchDataFromServer() {
    WebSocketService.instance.send({
      "action": "get_audit_items",
      "payload": {
        "audit_id": auditId,
        "mismatch_only": state.showMismatchesOnly,
      },
    });
  }

  // Closes out the pipeline allocation safely
  void disposeModule() {
    _wsSubscription?.cancel();
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

  void approveSingleRowItem(int productId) {
    WebSocketService.instance.send({
      "action": "approve_audit_item",
      "payload": {"audit_id": auditId, "product_id": productId},
    });
  }

  void submitItemAdjustment({
    required int productId,
    required int qty,
    required double price,
    double? wPrice,
  }) {
    WebSocketService.instance.send({
      "action": "update_audit_item",
      "payload": {
        "audit_id": auditId,
        "product_id": productId,
        "phyQty": qty,
        "phyPrice": price,
        if (wPrice != null) "phyWPrice": wPrice,
      },
    });
  }
}
