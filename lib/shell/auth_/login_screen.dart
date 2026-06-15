import 'package:flutter/material.dart';
import 'package:zi_core/zi_core_io.dart';
import '../network/app_constants.dart';
import '../network/server_ip_screen.dart';
import 'login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZiScaffoldB(
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40),
            Icon(
              Icons.point_of_sale_rounded,
              size: 90,
              color: ZiColors.primary,
            ),
            SizedBox(height: 20),
            Text(
              "${AppConstants.pos.name}Audit",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            LoginForm(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
