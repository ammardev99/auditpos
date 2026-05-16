import 'package:auditpos/features_slices/dashboard/presentation/dashboard_screen.dart';
import 'package:flutter/material.dart';

import '../network/app_constants.dart';
import '../network/dio_client.dart';
import '../network/storage_service.dart';
import '../network/websocket_service.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final usernameController = TextEditingController(text: "admin");
  final passwordController = TextEditingController(text: "admin");

  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);

    try {
      debugPrint("LOGIN START");

      final response = await DioClient.dio.post(
        AppConstants.loginUrl,
        data: {
          "username": usernameController.text.trim(),
          "password": passwordController.text.trim(),
        },
      );

      debugPrint("RAW RESPONSE => ${response.data}");

      final data = response.data;

      if (data["status"] == "success") {
        final token = data["data"]["token"];

        debugPrint("LOGIN SUCCESS TOKEN => $token");

        await StorageService.saveToken(token);

        await WebSocketService.instance.connect();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        debugPrint("LOGIN FAILED => ${data["message"]}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Login failed")),
        );
      }
    } catch (e) {
      debugPrint("LOGIN ERROR => $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Server error: $e")));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: usernameController,
          decoration: const InputDecoration(
            labelText: "Username",
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Password",
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: loading ? null : login,
            child:
                loading
                    ? const CircularProgressIndicator()
                    : const Text("LOGIN"),
          ),
        ),
      ],
    );
  }
}
