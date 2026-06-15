import 'package:flutter/material.dart';
import '../data/audit_session_history_model.dart';

class AuditSessionHTile extends StatelessWidget {
  final AuditSessionHistoryModel session;
  final VoidCallback onApprove;
  final VoidCallback onCloseSession;

  const AuditSessionHTile({
    super.key,
    required this.session,
    required this.onApprove,
    required this.onCloseSession,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (session.status) {
      case "approved":
        statusColor = Colors.green;
        break;
      case "completed":
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Header - Number & Badges
            Row(
              children: [
                Icon(Icons.inventory_2, color: statusColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  session.auditNo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),

                // Status Badge
                if (!session.isClosed) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      session.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],

                // Closed Guard Lock Badge
                if (session.isClosed) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, color: Colors.red, size: 12),
                        SizedBox(width: 3),
                        Text(
                          "CLOSED",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const Divider(height: 20),

            // Row 2: Metadata details & mismatch analytics labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Started: ${session.createdAt}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    if (session.completedAt != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        "Ended:   ${session.completedAt}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),

                // Mismatch Counter Tag Container
                if (session.mismatchCount > 0)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "${session.mismatchCount}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                            fontSize: 15,
                          ),
                        ),
                        const Text(
                          "Mismatches",
                          style: TextStyle(fontSize: 10, color: Colors.brown),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "Perfect Match",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // =========================================
            // ADDED: AUDITOR NAME ROW
            // =========================================
            Row(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Auditor: ${session.openByName}",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (session.isClosed && session.closedByName != null) ...[
                  // const SizedBox(width: 8),
                  Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.lock_person_outlined,
                        size: 14,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Closed by: ${session.closedByName}",
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            // Row 3: Context action buttons matrix
            if (!session.isClosed && session.status != 'approved') ...[
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.lock_clock, size: 16),
                    label: const Text("Close Session"),
                    onPressed: onCloseSession,
                  ),
                  // if (session.status == 'completed') ...[
                  //   const SizedBox(width: 8),
                  //   ElevatedButton.icon(
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.green,
                  //       foregroundColor: Colors.white,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //     ),
                  //     icon: const Icon(Icons.check_circle_outline, size: 16),
                  //     label: const Text("Approve All"),
                  //     onPressed: () async {
                  //       // 1. Show the confirmation dialog
                  //       bool? isConfirmed = await ZiConfirmationUser.confirm(
                  //         title:
                  //             "Confirm to approve all?", // You can customize this title
                  //         context: context,
                  //       );

                  //       // 2. Only call onApprove if the user clicks 'Yes' (returns true)
                  //       if (isConfirmed == true) {
                  //         onApprove();
                  //       }
                  //     },
                  //   ),
                  // ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
