import 'package:flutter/material.dart';

import '../data/audit_session_history_model.dart';

class AuditSessionTile extends StatelessWidget {

  final AuditSessionHistoryModel session;
  final VoidCallback onApprove;

  const AuditSessionTile({
    super.key,
    required this.session,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {

    Color color;

    switch (session.status) {

      case "approved":
        color = Colors.green;
        break;

      case "completed":
        color = Colors.orange;
        break;

      default:
        color = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),

      child: ListTile(

        title: Text(session.auditNo),

        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text("Status: ${session.status}"),

            Text("Created: ${session.createdAt}"),

            if (session.completedAt != null)
              Text(
                "Completed: ${session.completedAt}",
              ),
          ],
        ),

        leading: CircleAvatar(
          backgroundColor: color,
          child: const Icon(Icons.assignment),
        ),

        trailing: session.status == "completed"
            ? ElevatedButton(
                onPressed: onApprove,
                child: const Text("Approve"),
              )
            : const Icon(Icons.lock),
      ),
    );
  }
}