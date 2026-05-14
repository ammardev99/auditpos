import 'package:flutter/material.dart';
import 'login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: const [
                Icon(Icons.inventory_2, size: 90, color: Colors.blue),
                SizedBox(height: 20),
                Text(
                  "Inventory Audit System",
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