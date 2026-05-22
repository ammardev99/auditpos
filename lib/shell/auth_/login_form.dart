import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../network/app_constants.dart';
import '../network/dio_client.dart';
import '../network/storage_service.dart';
import '../network/websocket_service.dart';
import 'package:auditpos/shell/dashboard/presentation/dashboard_screen.dart';

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
          MaterialPageRoute(builder: (_) => DashboardScreen()),
        );
      } else {
        showMessage(data["message"] ?? "Login failed");
      }
    }
    // DIO EXCEPTIONS
    on DioException catch (e) {
      debugPrint("DIO ERROR => ${e.type}");
      debugPrint("DIO MESSAGE => ${e.message}");

      String message = "Something went wrong";

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          message =
              "Cannot connect to server.\nCheck IP address or server status.";
          break;

        case DioExceptionType.sendTimeout:
          message = "Request send timeout.";
          break;

        case DioExceptionType.receiveTimeout:
          message = "Server is taking too long to respond.";
          break;

        case DioExceptionType.badResponse:
          message = "Server error: ${e.response?.statusCode}";
          break;

        case DioExceptionType.cancel:
          message = "Request cancelled.";
          break;

        case DioExceptionType.connectionError:
          message = "No internet or server unreachable.";
          break;

        case DioExceptionType.badCertificate:
          message = "Bad SSL certificate.";
          break;

        case DioExceptionType.unknown:
          if (e.error is SocketException) {
            message = "Server not found.\nMake sure IP is correct.";
          } else {
            message = "Unexpected network error.";
          }
          break;
      }

      showMessage(message);
    }
    // OTHER ERRORS
    catch (e) {
      debugPrint("GENERAL ERROR => $e");

      showMessage("Unexpected error: $e");
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
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
