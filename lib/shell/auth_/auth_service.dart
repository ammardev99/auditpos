import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../auth_/login_screen.dart';
import '../network/websocket_service.dart';
class AuthService {
  final storage = const FlutterSecureStorage();

  Future<void> logout(BuildContext context) async {
    await storage.deleteAll();

    WebSocketService.instance.disconnect();

    Navigator.pushAndRemoveUntil(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}