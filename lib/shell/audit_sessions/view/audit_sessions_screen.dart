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
      appBar: AppBar(title: Text("Audit Sessions ${state.sessions.length}")),
      body:
          state.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: state.sessions.length,
                // Inside your AuditSessionsScreen standard ListView.builder:
                itemBuilder: (context, index) {
                  final session = state.sessions[index];

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AuditConfirmationScreen(
                                auditId: session.auditId,
                                auditNo: session.auditNo,
                              ),
                          // AuditDetailScreen(
                          //   auditId: session.auditId,
                          //   auditNo: session.auditNo,
                          // ),
                        ),
                      );
                    },
                    child: AuditSessionTile(
                      session: session,
                      onApprove: () {
                        notifier.approveAudit(session.auditId);
                      },
                    ),
                  );
                },
              ),
    );
  }
}
