import 'package:auditpos/shell/audit_sessions/view/audit_sessions_screen.dart';
import 'package:auditpos/shell/auth_/auth_service.dart';
import 'package:auditpos/shell/dashboard/presentation/dashboard_card.dart';
import 'package:auditpos/shell/network/websocket_service.dart';
import 'package:auditpos/shell/products/products_screen.dart';
import 'package:auditpos/shell/system_info_bar.dart';
import 'package:flutter/material.dart';
import 'package:zi_core/zi_core_io.dart';

import '../../audit_items/view/audit_screen.dart';
import '../../products/add_product_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
  }); // Removed the static 'connected' field from here

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ziGap(16),

              SystemInfoBar(),
              ziGap(12),
              Expanded(
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
                          MaterialPageRoute(
                            builder: (_) => const ProductsScreen(),
                          ),
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
                          MaterialPageRoute(
                            builder: (_) => const AuditScreen(),
                          ),
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
                            builder: (_) => const AuditSessionsHScreen(),
                          ),
                        );
                      },
                    ),
                    DashboardCard(
                      title: "Add Item",
                      icon: Icons.inventory,
                      color: Colors.purpleAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => const AddProductScreen(), // pass barcode
                          ),
                        );
                      },
                    ),

                    // Wrapped this specific card so it rebuilds whenever the connection state flips
                    ValueListenableBuilder<bool>(
                      valueListenable:
                          WebSocketService.instance.isConnectedNotifier,
                      builder: (context, isConnected, _) {
                        return DashboardCard(
                          title:
                              isConnected
                                  ? "Sys Connected"
                                  : "Sys Disconnected",
                          icon: Icons.wifi,
                          color: isConnected ? Colors.green : Colors.red,
                          onTap: () async {
                            if (isConnected) {
                              bool? doDisconnect =
                                  await ZiConfirmationUser.show(
                                    context: context,
                                    title: "Disconnect?",
                                    actionLabel: "Disconnected",
                                    icon: Icons.wifi,
                                  );
                              if (doDisconnect!) {
                                WebSocketService.instance.disconnect();
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("WebSocket Disconnected"),
                                  ),
                                );
                              }
                            } else {
                              await WebSocketService.instance.connect();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("WebSocket Connecting..."),
                                ),
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
                        final auth = AuthService();

                        await auth.logout(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
