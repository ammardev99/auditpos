import 'package:flutter/material.dart';
import 'package:auditpos/shell/audit_confirm/view/audit_confirmation_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zi_core/zi_core_io.dart';
import '../../network/websocket_service.dart';
import '../data/audit_sessions_provider.dart';
import 'audit_session_tile.dart';

class AuditSessionsHScreen extends ConsumerStatefulWidget {
  const AuditSessionsHScreen({super.key});

  @override
  ConsumerState<AuditSessionsHScreen> createState() =>
      _AuditSessionsHScreenState();
}

class _AuditSessionsHScreenState extends ConsumerState<AuditSessionsHScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      final connected = WebSocketService.instance.isConnectedNotifier.value;

      debugPrint("WS CONNECTED => $connected");

      // =========================================
      // CHECK WEBSOCKET BEFORE API CALL
      // =========================================
      if (!connected) {
        debugPrint("WEBSOCKET NOT CONNECTED");
        return;
      }

      ref.read(auditSessionsProvider.notifier).getSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(auditSessionsProvider);

    final notifier = ref.read(auditSessionsProvider.notifier);

    return ValueListenableBuilder<bool>(
      valueListenable: WebSocketService.instance.isConnectedNotifier,

      builder: (context, connected, _) {
        return Scaffold(
          appBar: ZiAppBarB(
            title: "Audit Sessions (${state.sessions.length})",

            actions: [
              // =========================================
              // WS STATUS
              // =========================================
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 14,
                      color: connected ? Colors.green : Colors.red,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      connected ? "WS" : "WS",

                      style: const TextStyle(fontSize: 12),
                    ),

                    const SizedBox(width: 12),

                    IconButton(
                      icon: const Icon(Icons.refresh),

                      onPressed:
                          connected ? () => notifier.getSessions() : null,
                    ),
                  ],
                ),
              ),
            ],
          ),

          body:
              !connected
                  ? const Center(child: Text("WebSocket not connected"))
                  : state.loading
                  ? const Center(child: CircularProgressIndicator())
                  : state.sessions.isEmpty
                  ? const Center(child: Text("No audit records found"))
                  : ListView.builder(
                    itemCount: state.sessions.length,

                    itemBuilder: (context, index) {
                      final session = state.sessions[index];

                      return InkWell(
                        onTap: () {
                          // =====================================
                          // OPEN BOTH OPEN/CLOSED SESSIONS
                          // CLOSED SESSION => READ ONLY MODE
                          // =====================================

                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder:
                                  (context) => AuditConfirmationScreen(
                                    auditId: session.auditId,

                                    auditNo: session.auditNo,

                                    // READ ONLY IF CLOSED
                                    readOnly: session.isClosed,
                                  ),
                            ),
                          );
                        },

                        child: AuditSessionHTile(
                          session: session,

                          onApprove: () {
                            notifier.approveAudit(session.auditId);
                          },

                          onCloseSession: () {
                            // =====================================
                            // PREVENT DOUBLE CLOSE
                            // =====================================
                            if (session.isClosed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Session already closed"),
                                ),
                              );

                              return;
                            }

                            // =====================================
                            // CONFIRMATION DIALOG
                            // =====================================
                            showDialog(
                              context: context,

                              builder:
                                  (context) => AlertDialog(
                                    title: Row(
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.red,
                                        ),

                                        const SizedBox(width: 8),

                                        Text("Close ${session.auditNo}"),
                                      ],
                                    ),

                                    content: const Text(
                                      "Are you sure you want to lock and close this session? This action stops inventory recording adjustments.",
                                    ),

                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),

                                        child: const Text("Cancel"),
                                      ),

                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),

                                        onPressed: () {
                                          notifier.closeAuditSession(
                                            session.auditId,
                                          );

                                          Navigator.pop(context);
                                        },

                                        child: Text(
                                          "Confirm & Lock",
                                          style: TextStyle(
                                            color: ZiColors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                          },
                        ),
                      );
                    },
                  ),
        );
      },
    );
  }
}
