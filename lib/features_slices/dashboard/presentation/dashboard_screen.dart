import 'package:auditpos/config/auth/presentation/screens/login_screen.dart';
import 'package:auditpos/shell/network/websocket_service.dart';
import 'package:auditpos/shell/auth_/login_screen.dart';
import 'package:auditpos/features_slices/dashboard/presentation/dashboard_card.dart';
import 'package:auditpos/shell/products/products_screen.dart';
import 'package:flutter/material.dart';
import '../../../shell/network/storage_service.dart';
import '../../audit/presentation/audit_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audit Dashboard")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            DashboardCard(
              title: "Products",
              icon: Icons.inventory,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductsScreen()),
                );
              },
            ),

            DashboardCard(
              title: "Audits",
              icon: Icons.fact_check,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AuditListScreen()),
                );
              },
            ),

            DashboardCard(
              title: "Reports",
              icon: Icons.bar_chart,
              color: Colors.orange,
              onTap: () {},
            ),

            DashboardCard(
              title: "Settings",
              icon: Icons.settings,
              color: Colors.purple,
              onTap: () {},
            ),

            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await StorageService.clear();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
