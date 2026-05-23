import 'package:auditpos/shell/dashboard/presentation/dashboard_card.dart';
import 'package:auditpos/shell/audit_sessions/view/audit_sessions_screen.dart';
import 'package:auditpos/shell/auth_/login_screen.dart';
import 'package:auditpos/shell/network/websocket_service.dart';
import 'package:auditpos/shell/products/products_screen.dart';
import 'package:flutter/material.dart';

import '../../items_audit/view/audit_screen.dart';
import '../../network/app_constants.dart';
import '../../network/storage_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key}); // Removed the static 'connected' field from here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audit Options"),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: WebSocketService.instance.isConnectedNotifier,
            builder: (context, isConnected, _) {
              return Tooltip(
                message: AppConstants.wsUrl,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 14,
                        color: isConnected ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "WS",
                        style: TextStyle(fontSize: 12),
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
            
            // Wrapped this specific card so it rebuilds whenever the connection state flips
            ValueListenableBuilder<bool>(
              valueListenable: WebSocketService.instance.isConnectedNotifier,
              builder: (context, isConnected, _) {
                return DashboardCard(
                  title: isConnected ? "Connected WS" : "Disconnected WS",
                  icon: Icons.wifi,
                  color: isConnected ? Colors.green : Colors.red,
                  onTap: () async {
                    if (isConnected) {
                      WebSocketService.instance.disconnect();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("WebSocket Disconnected")),
                      );
                    } else {
                      await WebSocketService.instance.connect();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("WebSocket Connecting...")),
                      );
                    }
                  },
                );
              },
            ),

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