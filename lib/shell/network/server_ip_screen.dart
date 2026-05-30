import 'package:auditpos/shell/auth_/login_screen.dart';
import 'package:auditpos/shell/network/app_constants.dart';
import 'package:auditpos/shell/network/server_model.dart';
import 'package:flutter/material.dart';
import 'package:zi_core/zi_core_io.dart';

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

  @override
  void initState() {
    super.initState();

    final pos = AppConstants.pos;
    isIPEmpty = pos.ip.isEmpty;

    nameController = TextEditingController(text: pos.name);

    ipController = TextEditingController(text: pos.ip);
    // Match the name used in the method below
    ipController.addListener(_onIpChanged);

    httpPortController = TextEditingController(text: pos.httpPort.toString());
    wsPortController = TextEditingController(text: pos.wsPort.toString());
    basePathController = TextEditingController(text: pos.basePath);
  }

  // Ensure this name matches the one in addListener
  void _onIpChanged() {
    final currentIsEmpty = ipController.text.trim().isEmpty;
    if (isIPEmpty != currentIsEmpty) {
      // Fixed variable name from isIpEmpty to isIPEmpty
      setState(() {
        isIPEmpty = currentIsEmpty;
      });
    }
  }

  void continueToLogin() {
    final pos = PosConfig(
      name: nameController.text.trim(),

      ip: ipController.text.trim(),

      httpPort: int.parse(httpPortController.text.trim()),

      wsPort: int.parse(wsPortController.text.trim()),

      basePath: basePathController.text.trim(),
    );

    AppConstants.setPos(pos);

    Navigator.pushReplacement(
      context,

      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    nameController.dispose();

    // Remove the listener before disposing the controller
    ipController.removeListener(_onIpChanged);
    ipController.dispose();

    httpPortController.dispose();
    wsPortController.dispose();
    basePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO add reload icon
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 420,

            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Icon(Icons.dns, size: 90),

                  const SizedBox(height: 20),

                  Text(
                    "Server Configuration",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: ZiColors.primary,
                    ),
                  ),

                  const SizedBox(height: 30),
                  // TODO later add a QR Code IP Scanner
                  if (AppConfig.environment == ZiEnvironment.development) ...[
                    TextField(
                      controller: nameController,

                      decoration: const InputDecoration(
                        labelText: "Server Name",

                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: ipController,

                      decoration: const InputDecoration(
                        labelText: "IP Address",

                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

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

                    const SizedBox(height: 15),

                    TextField(
                      controller: basePathController,

                      decoration: const InputDecoration(
                        labelText: "Base Path",

                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ZiButtonB(
                          disabled: isIPEmpty, // how i can make it real time
                          //                           Undefined name 'isIpEmpty'.
                          // Try correcting the name to one that is defined, or defining the name.
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
        ),
      ),
    );
  }
}
