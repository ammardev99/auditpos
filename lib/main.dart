import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shell/network/server_ip_screen.dart';

void main() {
  runApp(ProviderScope(child: const AuditApp()));
}

class AuditApp extends StatelessWidget {
  const AuditApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Audit App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ServerIpScreen(),
      // home: Scaffold(
      //   body: Text("data"),
      // ),
    );
  }
}
