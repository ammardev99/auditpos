import 'package:flutter/material.dart';

class AuditSummaryScreen extends StatelessWidget {
  const AuditSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Audit Summary"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Card(
              child: ListTile(
                title: const Text("Total Items"),
                trailing: const Text("250"),
              ),
            ),

            Card(
              child: ListTile(
                title: const Text("Mismatch Items"),
                trailing: const Text("12"),
              ),
            ),

            Card(
              child: ListTile(
                title: const Text("Total Loss"),
                trailing: const Text("Rs. 12,500"),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: () {},

                child: const Text(
                  "APPROVE AUDIT",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}