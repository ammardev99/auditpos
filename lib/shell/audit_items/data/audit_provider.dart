import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../network/websocket_service.dart';

import 'audit_item_model.dart';
import 'audit_session_model.dart';

// Change to autoDispose so the state resets when you leave the AuditScreen
final auditProvider =
    StateNotifierProvider.autoDispose<AuditNotifier, AuditState>((ref) {
      final notifier = AuditNotifier();

      // This is the clean, correct way to dispose of the subscription
      ref.onDispose(() {
        notifier.disposeModule();
      });

      return notifier;
    });

class AuditState {
  final bool loading;
  final AuditSessionModel? session;
  final List<AuditItemModel> items;
  final List<AuditItemModel> filteredItems;
  final String searchQuery;
  final String? error;

  AuditState({
    key,
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
      filteredItems: filteredItems ?? this.filteredItems,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error,
    );
  }
}

class AuditNotifier extends StateNotifier<AuditState> {
  StreamSubscription<Map<String, dynamic>>? _wsSubscription;

  AuditNotifier() : super(AuditState()) {
    _listenWS();
  }

  void _listenWS() {
    // Cancel any older dangling subscriptions
    _wsSubscription?.cancel();

    // Use the reliable broadcast stream so multiple screens don't step on each other
    _wsSubscription = WebSocketService.instance.messageStream.listen((data) {
      debugPrint("AUDIT SCREEN WS => ${data['action']}");

      /// START AUDIT
      if (data['action'] == 'start_audit') {
        final session = AuditSessionModel.fromJson(data);
        state = state.copyWith(session: session);
        getAuditItems(session.auditId);
      }

      /// GET AUDIT ITEMS
      if (data['action'] == 'get_audit_items') {
        final List list = data['data'] ?? [];
        final items = list.map((e) => AuditItemModel.fromJson(e)).toList();

        state = state.copyWith(
          loading: false,
          items: items,
          filteredItems: items,
        );

        // Re-apply search query if there was one active during an live update
        if (state.searchQuery.isNotEmpty) {
          searchItems(state.searchQuery);
        }
      }

      /// UPDATE ITEM ACKNOWLEDGEMENT FROM SERVER
      if (data['action'] == 'update_audit_item') {
        debugPrint("ITEM UPDATED SUCCESSFULLY ON SERVER");
      }

      /// COMPLETE AUDIT
      if (data['action'] == 'complete_audit') {
        state = AuditState();
        debugPrint("AUDIT COMPLETED");
      }
    });
  }

  /// START AUDIT
  void startAudit() {
    state = state.copyWith(loading: true);
    WebSocketService.instance.send({"action": "start_audit", "payload": {}});
  }

  /// FETCH ITEMS (Explicitly asks for everything, no mismatch filtering)
  void getAuditItems(int auditId) {
    WebSocketService.instance.send({
      "action": "get_audit_items",
      "payload": {
        "audit_id": auditId,
        "mismatch_only":
            false, // explicitly request all items to add physical counts
      },
    });
  }

  /// SEARCH LOCAL LIST
  void searchItems(String query) {
    final q = query.toLowerCase().trim();

    if (q.isEmpty) {
      state = state.copyWith(searchQuery: '', filteredItems: state.items);
      return;
    }

    final filtered =
        state.items.where((item) {
          return item.productName.toLowerCase().contains(q) ||
              item.productCode.toLowerCase().contains(q);
        }).toList();

    state = state.copyWith(searchQuery: query, filteredItems: filtered);
  }

  /// UPDATE ITEM (Local Optimistic State Update + Server Send)
  void updateAuditItem({
    required int productId,
    required double phyQty,
    required double phyPrice,
    required double phyWholesalePrice,
    required String phyRack,
  }) {
    final auditId = state.session?.auditId;

    if (auditId == null) return;

    WebSocketService.instance.send({
      "action": "update_audit_item",

      "payload": {
        "audit_id": auditId,

        "product_id": productId,

        "phyQty": phyQty,

        "phyPrice": phyPrice,

        "phyWholesalePrice": phyWholesalePrice,

        "phyRack": phyRack,
      },
    });

    final updated =
        state.items.map((item) {
          if (item.productId != productId) {
            return item;
          }

          final mismatchQty = phyQty - item.sysQty;

          final mismatchValue =
              (phyQty * phyPrice) - (item.sysQty * item.sysPrice);

          return item.copyWith(
            phyQty: phyQty,
            phyPrice: phyPrice,

            phyWholesalePrice: phyWholesalePrice,

            phyRack: phyRack,

            mismatchQty: mismatchQty,

            mismatchValue: mismatchValue,

            audited: true, // ONLY LOCAL
          );
        }).toList();

    state = state.copyWith(items: updated);

    searchItems(state.searchQuery);
  }
  // void updateAuditItem({
  //   required int productId,
  //   required double phyQty,
  //   required double phyPrice,
  //   required double phyWholesalePrice,
  //   required String phyRack,
  // }) {
  //   final auditId = state.session?.auditId;
  //   if (auditId == null) return;

  //   WebSocketService.instance.send({
  //     "action": "update_audit_item",
  //     "payload": {
  //       "audit_id": auditId,
  //       "product_id": productId,
  //       "phyQty": phyQty,
  //       "phyPrice": phyPrice,
  //       "phyWholesalePrice": phyWholesalePrice,
  //       "phyRack": phyRack,
  //     },
  //   });

  //   /// Update local list immediately so the UI snaps instantly without waiting on network
  //   final updated =
  //       state.items.map((item) {
  //         if (item.productId == productId) {
  //           final mismatchQty = double.parse(
  //             (phyQty - item.sysQty).toStringAsFixed(2),
  //           );

  //           final mismatchValue = double.parse(
  //             ((phyQty * phyPrice) - (item.sysQty * item.sysPrice))
  //                 .toStringAsFixed(2),
  //           );

  //           return item.copyWith(
  //             phyQty: phyQty,
  //             phyPrice: phyPrice,
  //             phyWholesalePrice: phyWholesalePrice,
  //             phyRack: phyRack,
  //             mismatchQty: mismatchQty,
  //             mismatchValue: mismatchValue,
  //           );
  //         }
  //         return item;
  //       }).toList();

  //   state = state.copyWith(items: updated);

  //   // Refresh search filter presentation array
  //   searchItems(state.searchQuery);
  // }

  /// COMPLETE AUDIT
  void completeAudit() {
    final auditId = state.session?.auditId;
    if (auditId == null) return;

    WebSocketService.instance.send({
      "action": "complete_audit",
      "payload": {"audit_id": auditId},
    });
  }

  void disposeModule() {
    _wsSubscription?.cancel();
  }

  void reset() {
    // Reset the state to the initial state (empty list, null session, etc.)
    state = AuditState(
      items: [],
      filteredItems: [],
      session: null,
      loading: false,
    );
  }
}
