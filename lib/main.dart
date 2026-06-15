import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zi_core/zi_core_io.dart';

import 'shell/network/server_ip_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  ziCoreInit(beta: true);
  AppConfig.environment = ZiEnvironment.production;
  ZiColors.override(ZiColorOverrides(primary: const Color(0xFFFF850C)));

  // Edge-to-Edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Status Bar Styling
  SystemChrome.setSystemUIOverlayStyle(
     SystemUiOverlayStyle(
      statusBarColor: ZiColors.primary,
      statusBarIconBrightness: Brightness.light, // Android
      statusBarBrightness: Brightness.light, // iOS
      systemNavigationBarColor: Colors.grey,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: AuditApp()));
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

        // Recommended for Edge-to-Edge
        scaffoldBackgroundColor: ZiColors.background,
        useMaterial3: true,
      ),
      home: const ServerIpScreen(),
    );
  }
}
