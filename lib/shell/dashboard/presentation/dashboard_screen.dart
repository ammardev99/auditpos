import 'package:auditpos/shell/dashboard/presentation/dashboard_card.dart';
import 'package:auditpos/shell/audit_sessions/view/audit_sessions_screen.dart';
import 'package:auditpos/shell/auth_/login_screen.dart';
import 'package:auditpos/shell/network/websocket_service.dart';
import 'package:auditpos/shell/products/products_screen.dart';
import 'package:flutter/material.dart';

import '../../items_audit/view/audit_screen.dart';
import '../../network/app_constants.dart';
import '../../network/storage_service.dart';

// ignore: must_be_immutable
class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});
  bool connected = WebSocketService.instance.isConnectedNotifier.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audit Options"),

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
                        connected ? "WS" : "WS",

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
          crossAxisCount: 3,
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
              color: Colors.cyan,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AuditScreen()),
                );
              },
            ),

            DashboardCard(
              title: "Audit Sessions",
              icon: Icons.fact_check,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AuditSessionsScreen(),
                  ),
                );
              },
            ),

            DashboardCard(
              title: connected ? "Connected WS" : "Disconnected WS",
              icon: Icons.wifi,
              color: connected ? Colors.green : Colors.red,
              onTap: () async {
                if (connected) {
                  WebSocketService.instance.disconnect();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("WebSocket Disconnected")),
                  );
                }
                if (!connected) {
                  await WebSocketService.instance.connect();
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("WebSocket Connecting...")),
                  );
                }
              },
            ),

            // DashboardCard(
            //   title: "Connect WS",
            //   icon: Icons.wifi,
            //   color: Colors.red,
            //   onTap: () async {
            //     await WebSocketService.instance.connect();
            //     // ignore: use_build_context_synchronously
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(content: Text("WebSocket Connecting...")),
            //     );
            //   },
            // ),

            // DashboardCard(
            //   title: "Disconnect WS",
            //   icon: Icons.wifi_off,
            //   color: Colors.black,
            //   onTap: () {
            //     WebSocketService.instance.disconnect();
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(content: Text("WebSocket Disconnected")),
            //     );
            //   },
            // ),
            DashboardCard(
              title: "Logout",
              icon: Icons.logout,
              color: Colors.brown,
              onTap: () async {
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
