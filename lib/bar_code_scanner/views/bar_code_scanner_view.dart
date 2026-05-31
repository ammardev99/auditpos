import 'package:flutter/material.dart';
import 'package:zi_core/zi_core_io.dart';

import '../bar_code_io.dart';

// <uses-permission android:name="android.permission.CAMERA" />

// <uses-permission android:name="android.permission.CAMERA" />
// <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
//

// //Yaml
// mobile_scanner: ^6.0.2

class BarCodeScannerView extends StatefulWidget {
  const BarCodeScannerView({super.key});

  @override
  State<BarCodeScannerView> createState() => _BarCodeScannerViewState();
}

class _BarCodeScannerViewState extends State<BarCodeScannerView> {
  dynamic result;
  final searchController = TextEditingController();

  Future<void> singleScan() async {
    final code = await ZiToBarCodeScanner.scan(
      context,
      scanType: ScanType.both,
    );

    setState(() {
      result = code;
    });
  }

  Future<void> multiScan() async {
    final codes = await ZiToBarCodeScanner.scan(context, multiScan: true);

    setState(() {
      result = codes;
    });
  }

  Future<void> searchScan() async {
    final code = await ZiToBarCodeScanner.scan(context);

    if (code != null) {
      searchController.text = code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZiScaffoldB(
      appBar: ZiAppBarB(title: "Barcode Scanner"),
      body: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search product...",
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: searchScan,
              ),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: singleScan,
            child: const Text("Single Scan"),
          ),

          ElevatedButton(onPressed: multiScan, child: const Text("Multi Scan")),

          const SizedBox(height: 20),

          Text("Result: ${result ?? "No scan yet"}"),
        ],
      ),
    );
  }
}
