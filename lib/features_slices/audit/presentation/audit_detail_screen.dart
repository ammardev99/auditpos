import 'package:flutter/material.dart';

class AuditDetailScreen extends StatefulWidget {

  final int auditId;

  const AuditDetailScreen({
    super.key,
    required this.auditId,
  });

  @override
  State<AuditDetailScreen> createState() =>
      _AuditDetailScreenState();
}

class _AuditDetailScreenState
    extends State<AuditDetailScreen> {

  final List<Map<String, dynamic>> items =
      List.generate(
    20,
    (index) => {
      "product": "Product $index",
      "sysQty": 100.0,
      "phyQty": 100.0,
      "price": 120.0,
    },
  );

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Audit #${widget.auditId}",
        ),
      ),

      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {

          final item = items[index];

          return Card(
            margin: const EdgeInsets.all(10),

            child: Padding(
              padding: const EdgeInsets.all(12),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    item['product'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "System Qty: ${item['sysQty']}",
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    decoration: InputDecoration(
                      labelText: "Physical Qty",
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    decoration: InputDecoration(
                      labelText: "Physical Price",
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text(
                        "UPDATE ITEM",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),

        child: SizedBox(
          height: 55,

          child: ElevatedButton(
            onPressed: () {},

            child: const Text(
              "COMPLETE AUDIT",
            ),
          ),
        ),
      ),
    );
  }
}