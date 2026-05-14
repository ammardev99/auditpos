import 'package:flutter/material.dart';
import 'audit_detail_screen.dart';

class AuditListScreen extends StatelessWidget {
  const AuditListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audits = List.generate(
      5,
      (index) => {
        "id": index + 1,
        "auditNo": "AUD-2026-00$index",
        "status": "open",
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Audit Sessions")),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),

      body: ListView.builder(
        itemCount: audits.length,
        itemBuilder: (context, index) {
          final audit = audits[index];

          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.fact_check)),

              title: Text(audit['auditNo'].toString()),

              subtitle: Text("Status: ${audit['status']}"),

              trailing: const Icon(Icons.arrow_forward_ios),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => AuditDetailScreen(auditId: audit['id'] as int),
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
