import 'dart:io';

import 'package:auditpos/shell/dashboard/presentation/dashboard_screen.dart';
import 'package:auditpos/shell/network/app_constants.dart';
import 'package:auditpos/shell/network/dio_client.dart';
import 'package:auditpos/shell/network/storage_service.dart';
import 'package:auditpos/shell/network/websocket_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zi_core/zi_core_io.dart';

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
      final response = await DioClient.dio.post(
        AppConstants.loginUrl,
        data: {
          "username": usernameController.text.trim(),
          "password": passwordController.text.trim(),
        },
      );

      final data = response.data;

      if (data["status"] == "success") {
        final user = data["data"];

        final token = user["token"];
        final username = user["username"];
        final userId = user["user_id"];

        // ✅ SAVE SESSION
        await StorageService.saveToken(token);

        await StorageService.saveUser(
          name: username,
          email: "", // backend not sending email
          userId: userId.toString(),
        );

        // ✅ CONNECT WEBSOCKET WITH TOKEN
        await WebSocketService.instance.connect(token: token);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        showMessage(data["message"] ?? "Login failed");
      }
    } on DioException catch (e) {
      String message = "Network error";

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          message = "Server not reachable (check IP)";
          break;
        case DioExceptionType.receiveTimeout:
          message = "Server too slow";
          break;
        case DioExceptionType.badResponse:
          message = "Server error ${e.response?.statusCode}";
          break;
        case DioExceptionType.connectionError:
          message = "No internet / server offline";
          break;
        default:
          if (e.error is SocketException) {
            message = "Invalid server IP";
          }
      }

      showMessage(message);
    } catch (e) {
      showMessage("Unexpected error: $e");
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
        Row(
          children: [
            Expanded(
              child: ZiButtonB(
                label: "LOGIN",
                loading: loading,
                action: loading ? null : login,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
