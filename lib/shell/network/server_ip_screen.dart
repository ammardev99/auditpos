import 'package:auditpos/shell/auth_/login_screen.dart';
import 'package:auditpos/shell/network/app_constants.dart';
import 'package:auditpos/shell/network/qr_config/pairing_screen.dart';
import 'package:auditpos/shell/network/server_model.dart';
import 'package:flutter/material.dart';
import 'package:zi_core/zi_core_io.dart';

import '../../bar_code_scanner/bar_code_io.dart';

class ServerIpScreen extends StatefulWidget {
  const ServerIpScreen({super.key});

  @override
  State<ServerIpScreen> createState() => _ServerIpScreenState();
}

class _ServerIpScreenState extends State<ServerIpScreen> {
  late final TextEditingController nameController;
  late final TextEditingController ipController;
  late final TextEditingController httpPortController;
  late final TextEditingController wsPortController;
  late final TextEditingController basePathController;

  bool isIPEmpty = true;
  bool isMore = false;

  int selectedTab = 0;

  bool qrValidated = false;

  String? scannedQrData;

  ConnectionType connectionType = ConnectionType.port;

  @override
  void initState() {
    super.initState();

    final pos = AppConstants.pos;

    isIPEmpty = pos.ip.trim().isEmpty;

    connectionType = pos.connectionType;

    nameController = TextEditingController(text: pos.name);

    ipController = TextEditingController(text: pos.ip);

    httpPortController = TextEditingController(text: pos.httpPort.toString());

    wsPortController = TextEditingController(text: pos.wsPort.toString());

    basePathController = TextEditingController(text: pos.basePath);

    ipController.addListener(_onIpChanged);
  }

  void _onIpChanged() {
    final empty = ipController.text.trim().isEmpty;

    if (empty != isIPEmpty) {
      setState(() {
        isIPEmpty = empty;
      });
    }
  }

  void continueToLogin() {
    final pos = PosConfig(
      name: nameController.text.trim(),

      ip: ipController.text.trim(),

      connectionType: connectionType,

      httpPort: int.tryParse(httpPortController.text) ?? 80,

      wsPort: int.tryParse(wsPortController.text) ?? 8080,

      basePath: basePathController.text.trim(),
    );

    AppConstants.setPos(pos);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  bool isValidIp(String ip) {
    final regex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})$',
    );

    return regex.hasMatch(ip.trim());
  }

  @override
  void dispose() {
    ipController.removeListener(_onIpChanged);

    nameController.dispose();
    ipController.dispose();
    httpPortController.dispose();
    wsPortController.dispose();
    basePathController.dispose();

    super.dispose();
  }

  Widget buildConnectionSelector() {
    return SegmentedButton<ConnectionType>(
      segments: const [
        ButtonSegment(
          value: ConnectionType.port,

          label: Text("Port"),

          icon: Icon(Icons.router),
        ),

        ButtonSegment(
          value: ConnectionType.path,

          label: Text("Base"),

          icon: Icon(Icons.link),
        ),
      ],

      selected: {connectionType},

      onSelectionChanged: (selection) {
        setState(() {
          connectionType = selection.first;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ZiScaffoldB(
      body: Center(
        child: SizedBox(
          width: 420,

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selectedTab == 1) const Icon(Icons.dns, size: 40),
              const SizedBox(height: 10),
              Text(
                selectedTab == 1 ? "Server Configuration" : "App Configuration",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: ZiColors.primary,
                ),
              ),

              const SizedBox(height: 10),

              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text("Scan QR"),
                    icon: Icon(Icons.qr_code_scanner),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text("Manual"),
                    icon: Icon(Icons.settings),
                  ),
                ],
                selected: {selectedTab},
                onSelectionChanged: (value) {
                  setState(() {
                    selectedTab = value.first;
                  });
                },
              ),

              const SizedBox(height: 20),

              if (selectedTab == 0) Expanded(child: PairingScreen()),

              if (selectedTab == 1) buildManualTab(),

              const SizedBox(height: 10),

              if (selectedTab == 1)
                Row(
                  children: [
                    Expanded(
                      child: ZiButtonB(
                        disabled:
                            selectedTab == 0
                                ? !qrValidated
                                : !isValidIp(ipController.text),
                        label: "Continue",
                        action: continueToLogin,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQrTab() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(Icons.qr_code_2, color: Colors.grey, size: 120),
              const SizedBox(height: 10),
              Text(
                qrValidated ? "Configuration Valid" : "Scan Configuration QR",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              if (scannedQrData != null)
                // Text(scannedQrData!, textAlign: TextAlign.center),
                const SizedBox(height: 15),

              ZiButtonB(
                variant: ZiButtonVariantB.outline,
                label: "Scan QR", // scan again
                action: () async {
                  final result = await ZiToBarCodeScanner.scan(context);

                  if (result == null || result.isEmpty) {
                    return;
                  }

                  if (!isValidIp(result)) {
                    setState(() {
                      qrValidated = false;
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Invalid IP Address")),
                      );
                    }

                    return;
                  }

                  ipController.text = result;

                  setState(() {
                    scannedQrData = result;
                    qrValidated = true;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildManualTab() {
    return ListView(
      shrinkWrap: true,
      children: [
        TextField(
          controller: ipController,
          decoration: InputDecoration(
            labelText: "IP Address",
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () async {
                final scannedIp = await ZiToBarCodeScanner.scan(context);

                if (scannedIp != null && scannedIp.isNotEmpty) {
                  ipController.text = scannedIp;
                }
              },
            ),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            ZiCheckBoxD(
              value: isMore,
              label: "More Settings",
              onChanged: (value) {
                setState(() {
                  isMore = value;
                });
              },
            ),
          ],
        ),

        if (isMore) ...[
          const SizedBox(height: 10),

          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Server Name",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          buildConnectionSelector(),

          const SizedBox(height: 15),

          if (connectionType == ConnectionType.port) ...[
            TextField(
              controller: httpPortController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "HTTP Port",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: wsPortController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "WS Port",
                border: OutlineInputBorder(),
              ),
            ),
          ],

          if (connectionType == ConnectionType.path) ...[
            TextField(
              controller: basePathController,
              decoration: const InputDecoration(
                labelText: "Base Path",
                hintText: "billinga",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
