import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../../shell/network/websocket_service.dart';
import 'audit_session_history_model.dart';

final auditSessionsProvider =
    StateNotifierProvider<AuditSessionsNotifier, AuditSessionsState>(
      (ref) => AuditSessionsNotifier(),
    );

class AuditSessionsState {
  final bool loading;
  final List<AuditSessionHistoryModel> sessions;
  final String? error;

  AuditSessionsState({
    this.loading = false,
    this.sessions = const [],
    this.error,
  });

  AuditSessionsState copyWith({
    bool? loading,
    List<AuditSessionHistoryModel>? sessions,
    String? error,
  }) {
    return AuditSessionsState(
      loading: loading ?? this.loading,
      sessions: sessions ?? this.sessions,
      error: error,
    );
  }
}

class AuditSessionsNotifier extends StateNotifier<AuditSessionsState> {
  AuditSessionsNotifier() : super(AuditSessionsState()) {
    _listenWS();
  }

  void _listenWS() {
    WebSocketService.instance.onMessage = (data) {
      debugPrint("AUDIT SESSIONS => $data");

      /// GET SESSIONS
      if (data['action'] == 'get_audit_sessions') {
        final List list = data['data'] ?? [];
        final sessions =
            list.map((e) => AuditSessionHistoryModel.fromJson(e)).toList();

        state = state.copyWith(loading: false, sessions: sessions);
      }

      /// APPROVE AUDIT ACTION SUCCESS
      if (data['action'] == 'approve_audit') {
        debugPrint("AUDIT APPROVED");
        getSessions();
      }

      /// CLOSE AUDIT ACTION SUCCESS
      if (data['action'] == 'close_audit_session') {
        debugPrint("LOCAL SESSION CLOSED");
        getSessions();
      }

      /// REAL-TIME BROADCAST LISTENER FROM OTHER STATIONS
      if (data['action'] == 'session_closed') {
        debugPrint("BROADCAST RECEIVED: SESSION CLOSED REMOTELY");
        // Automatically refresh structural listings to block actions instantly
        getSessions();
      }
    };
  }

  void getSessions() {
    state = state.copyWith(loading: true);
    WebSocketService.instance.send({
      "action": "get_audit_sessions",
      "payload": {},
    });
  }

  void approveAudit(int auditId) {
    WebSocketService.instance.send({
      "action": "approve_audit",
      "payload": {"audit_id": auditId},
    });
  }

  // New native action added matching your payload structure requirement
  void closeAuditSession(int auditId) {
    WebSocketService.instance.send({
      "action": "close_audit_session",
      "payload": {"audit_id": auditId},
    });
  }
}
