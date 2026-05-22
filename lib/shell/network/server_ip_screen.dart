import 'package:auditpos/shell/auth_/login_screen.dart';
import 'package:auditpos/shell/network/app_constants.dart';
import 'package:flutter/material.dart';

class ServerIpScreen extends StatefulWidget {
  const ServerIpScreen({super.key});

  @override
  State<ServerIpScreen> createState() => _ServerIpScreenState();
}

class _ServerIpScreenState extends State<ServerIpScreen> {
  final TextEditingController ipController = TextEditingController(
    text: "192.168.1.17",
  );

  void continueToLogin() {
    final ip = ipController.text.trim();

    if (ip.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter server IP")));
      return;
    }

    AppConstants.iP = ip;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 350,
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

                  TextField(
                    controller: ipController,
                    decoration: const InputDecoration(
                      labelText: "Server IP Address",
                      border: OutlineInputBorder(),
                      hintText: "192.168.1.18",
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: continueToLogin,
                      child: const Text("Continue"),
                    ),
                  ),
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 50,
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       Navigator.pushReplacement(
                  //         context,
                  //         MaterialPageRoute(builder: (_) => DashboardScreen()),
                  //       );
                  //     },
                  //     child: const Text("da"),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
