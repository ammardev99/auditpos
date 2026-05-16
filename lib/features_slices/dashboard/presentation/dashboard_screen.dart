import 'package:auditpos/features_slices/dashboard/presentation/dashboard_card.dart';
import 'package:auditpos/shell/auth_/login_screen.dart';
import 'package:auditpos/shell/network/websocket_service.dart';
import 'package:auditpos/shell/products/products_screen.dart';
import 'package:flutter/material.dart';

import '../../../shell/items_audit/view/audit_screen.dart';
import '../../../shell/network/app_constants.dart';
import '../../../shell/network/storage_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audit Dashboard"),

        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: WebSocketService.instance.isConnectedNotifier,

            builder: (context, connected, _) {
              return Tooltip(
                message: AppConstants.wsUrl,

                child: Padding(
                  padding: const EdgeInsets.only(right: 16),

                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 14,
                        color: connected ? Colors.green : Colors.red,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        connected ? "WS Connected" : "WS Offline",

                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),

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
                  MaterialPageRoute(builder: (_) => const AuditScreen()),
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

            DashboardCard(
              title: "Connect WS",
              icon: Icons.wifi,
              color: Colors.red,
              onTap: () async {
                await WebSocketService.instance.connect();

                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("WebSocket Connecting...")),
                );
              },
            ),

            DashboardCard(
              title: "Disconnect WS",
              icon: Icons.wifi_off,
              color: Colors.black,
              onTap: () {
                WebSocketService.instance.disconnect();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("WebSocket Disconnected")),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                WebSocketService.instance.disconnect();

                await StorageService.clear();

                if (!context.mounted) return;

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
