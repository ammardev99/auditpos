import 'dart:convert';

import 'package:auditpos/shell/network/app_constants.dart';
import 'package:auditpos/shell/network/qr_config/qr_config_model.dart';
import 'package:flutter/material.dart';
import 'package:auditpos/shell/network/server_model.dart';
import 'package:zi_core/zi_core_io.dart';

import '../../../bar_code_scanner/bar_code_io.dart';
import '../../auth_/login_screen.dart';

// import your model

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  PosQrConfig? _config;
  String? _error;
  bool _loading = false;

  /// =========================
  /// SCAN QR
  /// =========================
  Future<void> _scanQr() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final scannedData = await ZiToBarCodeScanner.scan(context);

      /// 👇 PRINT RAW SCANNED VALUE
      ZiLogger.log("📦 RAW QR SCANNED DATA: $scannedData");

      if (scannedData == null || scannedData.isEmpty) {
        setState(() {
          _loading = false;
          _error = "Scan cancelled or empty QR";
        });
        return;
      }

      final decoded = jsonDecode(scannedData) as Map<String, dynamic>;

      /// 👇 PRINT DECODED MAP
      ZiLogger.log("🔎 DECODED QR JSON: $decoded");

      final config = PosQrConfig.fromJson(decoded);

      /// BASIC VALIDATION (important)
      if (config.serverIp.isEmpty ||
          config.martName.isEmpty ||
          config.httpPort == 0 ||
          config.wsPort == 0) {
        setState(() {
          _loading = false;
          _error = "Invalid QR: Missing required fields";
          _config = null;
        });
        return;
      }

      setState(() {
        _config = config;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _config = null;
        _error = "Invalid QR";
      });
    }
  }

  /// =========================
  /// CONTINUE
  /// =========================
  void _continue() {
    if (_config == null) return;

    final pos = PosConfig(
      name: _config!.martName,
      ip: _config!.serverIp,
      connectionType: ConnectionType.path,
      httpPort: _config!.httpPort,
      wsPort: _config!.wsPort,
      basePath: _config!.basePath,
    );

    AppConstants.setPos(pos);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Connected to ${_config!.martName}")),
    );

    /// 👉 NAVIGATE TO LOGIN SCREEN
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  /// =========================
  /// UI ROW
  /// =========================
  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// =========================
  /// BUILD UI
  /// =========================
  @override
  Widget build(BuildContext context) {
    final isConnected = _config != null;

    return Scaffold(
      // appBar: AppBar(title: const Text("POS Pairing"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              // const SizedBox(height: 20),

              /// ICON
              if (_config == null) const Icon(Icons.qr_code_scanner, size: 80),

              const SizedBox(height: 12),

              const Text(
                "POS Pairing",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Make sure desktop POS QR is active",
                style: TextStyle(fontSize: 12),
              ),

              // const SizedBox(height: 8),

              // const Text(
              //   "Scan QR code from Desktop POS to auto configure connection",
              //   textAlign: TextAlign.center,
              // ),
              const SizedBox(height: 20),

              /// ERROR BOX
              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              if (_error != null) const SizedBox(height: 10),

              /// SCAN BUTTON
              if (!isConnected)
                ElevatedButton.icon(
                  onPressed: _loading ? null : _scanQr,
                  icon: const Icon(Icons.qr_code),
                  label: Text(_loading ? "Scanning..." : "Scan to Connect"),
                ),

              // const SizedBox(height: 20),

              /// CONFIG PREVIEW
              if (_config != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "✓ POS Found",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),

                      const SizedBox(height: 10),

                      _row("Mart", _config!.martName),
                      _row("Server IP", _config!.serverIp),
                      Text(
                        " ${_config!.httpPort}"
                        ", ${_config!.dbName}"
                        ", ${_config!.wsPort}"
                        " | ${_config!.basePath}",
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _scanQr,
                              child: const Text("Rescan"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _continue,
                              child: const Text("Continue"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
