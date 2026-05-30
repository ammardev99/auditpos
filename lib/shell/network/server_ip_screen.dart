import 'package:auditpos/shell/auth_/login_screen.dart';
import 'package:auditpos/shell/network/app_constants.dart';
import 'package:auditpos/shell/network/server_model.dart';
import 'package:flutter/material.dart';

class ServerIpScreen extends StatefulWidget {
  const ServerIpScreen({super.key});

  @override
  State<ServerIpScreen> createState() => _ServerIpScreenState();
}

class _ServerIpScreenState extends State<ServerIpScreen> {
  final TextEditingController nameController = TextEditingController(
    text: "php_mart",
  );

  final TextEditingController basePathController = TextEditingController(
    text: "php_mart",
  );

  final TextEditingController ipController = TextEditingController(
    text: "192.168.10.22",
  );

  void continueToLogin() {
    final name = nameController.text.trim();
    final basePath = basePathController.text.trim();
    final ip = ipController.text.trim();

    if (name.isEmpty || basePath.isEmpty || ip.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    final pos = PosConfig(name: name, ip: ip, basePath: basePath);

    AppConstants.setPos(pos);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    basePathController.dispose();
    ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 380,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.dns, size: 90, color: Colors.blue),

                  const SizedBox(height: 20),

                  const Text(
                    "Server Configuration",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 30),

                  /// POS NAME
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "POS Name",
                      border: OutlineInputBorder(),
                      hintText: "php_mart",
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// BASE PATH
                  TextField(
                    controller: basePathController,
                    decoration: const InputDecoration(
                      labelText: "Base Path",
                      border: OutlineInputBorder(),
                      hintText: "v2/php_mart",
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// SERVER IP
                  TextField(
                    controller: ipController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Server IP Address",
                      border: OutlineInputBorder(),
                      hintText: "192.168.1.16",
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// CONTINUE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: continueToLogin,
                      child: const Text("Continue"),
                    ),
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
