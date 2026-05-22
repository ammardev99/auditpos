import 'package:flutter/material.dart';
import '../data/audit_session_history_model.dart';

class AuditSessionTile extends StatelessWidget {
  final AuditSessionHistoryModel session;
  final VoidCallback onApprove;
  final VoidCallback onCloseSession;

  const AuditSessionTile({
    super.key,
    required this.session,
    required this.onApprove,
    required this.onCloseSession,
  });

  @override
  Widget build(BuildContext context) {
    // Generate state color variations
    Color statusColor;
    switch (session.status) {
      case "approved":
        statusColor = Colors.green;
        break;
      case "completed":
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.blue; // "open" / dynamic status configuration
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
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

                // Closed Guard Lock Badge
                if (session.isClosed) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.withOpacity(0.5)),
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
                        "Completed: ${session.completedAt}",
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

            // Row 3: Context action buttons matrix (matching the developer's display logic)
            if (!session.isClosed && session.status != 'approved') ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Close Session button is displayed as long as it's not approved and not closed
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

                  // If it's ready and completed, provide immediate option to Approve alongside it
                  if (session.status == 'completed') ...[
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text("Approve"),
                      onPressed: onApprove,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// import '../data/audit_session_history_model.dart';

// class AuditSessionTile extends StatelessWidget {

//   final AuditSessionHistoryModel session;
//   final VoidCallback onApprove;

//   const AuditSessionTile({
//     super.key,
//     required this.session,
//     required this.onApprove,
//   });

//   @override
//   Widget build(BuildContext context) {

//     Color color;

//     switch (session.status) {

//       case "approved":
//         color = Colors.green;
//         break;

//       case "completed":
//         color = Colors.orange;
//         break;

//       default:
//         color = Colors.red;
//     }

//     return Card(
//       margin: const EdgeInsets.symmetric(
//         horizontal: 12,
//         vertical: 6,
//       ),

//       child: ListTile(

//         title: Text(session.auditNo),

//         subtitle: Column(
//           crossAxisAlignment:
//               CrossAxisAlignment.start,

//           children: [

//             Text("Status: ${session.status}"),

//             Text("Created: ${session.createdAt}"),

//             if (session.completedAt != null)
//               Text(
//                 "Completed: ${session.completedAt}",
//               ),
//           ],
//         ),

//         leading: CircleAvatar(
//           backgroundColor: color,
//           child: const Icon(Icons.assignment),
//         ),

//         trailing: session.status == "completed"
//             ? ElevatedButton(
//                 onPressed: onApprove,
//                 child: const Text("Approve"),
//               )
//             : const Icon(Icons.lock),
//       ),
//     );
//   }
// }
