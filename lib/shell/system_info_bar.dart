import 'package:auditpos/shell/network/app_constants.dart';
import 'package:auditpos/shell/network/storage_service.dart';
import 'package:auditpos/shell/network/websocket_service.dart';
import 'package:flutter/material.dart';
import 'package:zi_core/zi_core_io.dart';

class SystemInfoBar extends StatelessWidget {
  const SystemInfoBar({super.key});

  @override
  Widget build(BuildContext context) {
    final pos = AppConstants.pos;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "POS: ${pos.name}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              ValueListenableBuilder<bool>(
                valueListenable: WebSocketService.instance.isConnectedNotifier,
                builder: (context, connected, _) {
                  return Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: connected ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(connected ? "WS Connected" : "WS Disconnected"),
                    ],
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 6),
          if (AppConfig.environment == ZiEnvironment.development) ...[
            const Divider(),
            Text("IP: ${pos.ip}"),
            Text("Base: ${pos.baseUrl}"),
            Text("WS: ${pos.wsUrl}"),
          ],

          const Divider(),

          FutureBuilder(
            future: Future.wait([
              StorageService.getUserName(),
              StorageService.getUserEmail(),
              StorageService.getUserId(),
            ]),
            builder: (context, snapshot) {
              final name = snapshot.data?[0] ?? "N/A";
              // final email = snapshot.data?[1] ?? "N/A";

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("User: $name"),
                  // Text("Email: $email")
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
