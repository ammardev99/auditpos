import 'package:flutter/material.dart';
import 'package:zi_core/zi_core_io.dart';
import '../network/server_ip_screen.dart';
import 'login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ServerIpScreen()),
              );
            },
            icon: Icon(
              Icons.connected_tv_outlined,
              color: Colors.grey.shade300,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.point_of_sale_rounded,
                  size: 90,
                  color: ZiColors.primary,
                ),
                SizedBox(height: 20),
                Text(
                  "Mart POS",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 40),
                LoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
