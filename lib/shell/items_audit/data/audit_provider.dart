import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shell/network/websocket_service.dart';

import 'audit_item_model.dart';
import 'audit_session_model.dart';

final auditProvider =
    StateNotifierProvider<AuditNotifier, AuditState>(
  (ref) => AuditNotifier(),
);

class AuditState {
  final bool loading;

  final AuditSessionModel? session;

  final List<AuditItemModel> items;

  final List<AuditItemModel> filteredItems;

  final String searchQuery;

  final String? error;

  AuditState({
    this.loading = false,
    this.session,
    this.items = const [],
    this.filteredItems = const [],
    this.searchQuery = '',
    this.error,
  });

  AuditState copyWith({
    bool? loading,
    AuditSessionModel? session,
    List<AuditItemModel>? items,
    List<AuditItemModel>? filteredItems,
    String? searchQuery,
    String? error,
  }) {
    return AuditState(
      loading: loading ?? this.loading,
      session: session ?? this.session,
      items: items ?? this.items,
      filteredItems:
          filteredItems ?? this.filteredItems,
      searchQuery:
          searchQuery ?? this.searchQuery,
      error: error,
    );
  }
}

class AuditNotifier extends StateNotifier<AuditState> {
  AuditNotifier() : super(AuditState()) {
    _listenWS();
  }

  void _listenWS() {
    WebSocketService.instance.onMessage = (data) {
      debugPrint("AUDIT WS => $data");

      /// START AUDIT
      if (data['action'] == 'start_audit') {
        final session = AuditSessionModel.fromJson(data);
        state = state.copyWith(session: session);
        getAuditItems(session.auditId);
      }

      /// GET AUDIT ITEMS
      if (data['action'] == 'get_audit_items') {
        final List list = data['data'];
        final items = list.map((e) => AuditItemModel.fromJson(e)).toList();

        state = state.copyWith(
          loading: false,
          items: items,
          filteredItems: items,
        );
      }

      /// UPDATE ITEM
      if (data['action'] == 'update_audit_item') {
        debugPrint("ITEM UPDATED");
      }

      /// COMPLETE AUDIT
      if (data['action'] == 'complete_audit') {
        state = AuditState();
        debugPrint("AUDIT COMPLETED");
      }
    };
  }

  /// START AUDIT
  void startAudit() {
    state = state.copyWith(loading: true);
    WebSocketService.instance.send({
      "action": "start_audit",
      "payload": {}
    });
  }

  /// FETCH ITEMS
  void getAuditItems(int auditId) {
    WebSocketService.instance.send({
      "action": "get_audit_items",
      "payload": {
        "audit_id": auditId,
      }
    });
  }

  /// SEARCH
  void searchItems(String query) {
    final q = query.toLowerCase().trim();

    if (q.isEmpty) {
      state = state.copyWith(
        searchQuery: '',
        filteredItems: state.items,
      );
      return;
    }

    final filtered = state.items.where((item) {
      return item.productName.toLowerCase().contains(q) ||
          item.productCode.toLowerCase().contains(q);
    }).toList();

    state = state.copyWith(
      searchQuery: query,
      filteredItems: filtered,
    );
  }

  /// UPDATE ITEM (With new Wholesale and Rack fields)
  void updateAuditItem({
    required int productId,
    required double phyQty,
    required double phyPrice,
    required double phyWholesalePrice,
    required String phyRack,
  }) {
    final auditId = state.session?.auditId;
    if (auditId == null) return;

    // Outbound payload matching your specific key formatting
    WebSocketService.instance.send({
      "action": "update_audit_item",
      "payload": {
        "audit_id": auditId,
        "product_id": productId,
        "phyQty": phyQty,
        "phyPrice": phyPrice,
        "phyWholesalePrice": phyWholesalePrice,
        "phyRack": phyRack,
      }
    });

    /// LOCAL STATE UPDATE
    final updated = state.items.map((item) {
      if (item.productId == productId) {
        final mismatchQty = double.parse(
          (phyQty - item.sysQty).toStringAsFixed(2),
        );

        // Keep existing calculation using base retail price matching your original logic
        final mismatchValue = double.parse(
          ((phyQty * phyPrice) - (item.sysQty * item.sysPrice))
              .toStringAsFixed(2),
        );

        return item.copyWith(
          phyQty: phyQty,
          phyPrice: phyPrice,
          phyWholesalePrice: phyWholesalePrice,
          phyRack: phyRack,
          mismatchQty: mismatchQty,
          mismatchValue: mismatchValue,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(
      items: updated,
      filteredItems: updated,
    );
  }

  /// COMPLETE AUDIT
  void completeAudit() {
    final auditId = state.session?.auditId;
    if (auditId == null) return;

    WebSocketService.instance.send({
      "action": "complete_audit",
      "payload": {
        "audit_id": auditId,
      }
    });
  }
}