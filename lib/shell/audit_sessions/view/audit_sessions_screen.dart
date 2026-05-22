import 'package:auditpos/shell/audit_confirm/view/audit_confirmation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/audit_sessions_provider.dart';
import 'audit_session_tile.dart';

class AuditSessionsScreen extends ConsumerStatefulWidget {
  const AuditSessionsScreen({super.key});

  @override
  ConsumerState<AuditSessionsScreen> createState() =>
      _AuditSessionsScreenState();
}

class _AuditSessionsScreenState extends ConsumerState<AuditSessionsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      ref.read(auditSessionsProvider.notifier).getSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(auditSessionsProvider);
    final notifier = ref.read(auditSessionsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text("Audit Sessions (${state.sessions.length})"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.getSessions(),
          ),
        ],
      ),
      body:
          state.loading
              ? const Center(child: CircularProgressIndicator())
              : state.sessions.isEmpty
              ? const Center(child: Text("No audit records found"))
              : ListView.builder(
                itemCount: state.sessions.length,
                itemBuilder: (context, index) {
                  final session = state.sessions[index];

                  return InkWell(
                    onTap: () {
                      // Prevent entrance navigation if session structure has been locked down
                      if (session.isClosed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "This session is closed and locked for security.",
                            ),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AuditConfirmationScreen(
                                auditId: session.auditId,
                                auditNo: session.auditNo,
                              ),
                        ),
                      );
                    },
                    child: AuditSessionTile(
                      session: session,
                      onApprove: () {
                        notifier.approveAudit(session.auditId);
                      },
                      onCloseSession: () {
                        // Standard confirmation modal dialog wrapper
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
                                    child: const Text("Confirm Lock"),
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
  }
}
