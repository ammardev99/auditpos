import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zi_core/zi_core_io.dart';

import 'shell/network/server_ip_screen.dart';

void main() {
  ziCoreInit(beta: true);
  AppConfig.environment = ZiEnvironment.production;
  ZiColors.override(ZiColorOverrides(primary: const Color(0xFFFF850C)));

  runApp(ProviderScope(child: const AuditApp()));
}

class AuditApp extends StatelessWidget {
  const AuditApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Audit App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ZiColors.primary),
        primaryColor: ZiColors.primary,
      ),
      home: const ServerIpScreen(),
      // home: const PairingScreen(),
    );
  }
}
