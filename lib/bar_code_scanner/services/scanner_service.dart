import 'package:flutter/material.dart';

import '../models/scan_type.dart';
import '../widgets/scanner_dialog.dart';

class ZiToBarCodeScanner {
  static Future<dynamic> scan(
    BuildContext context, {
    ScanType scanType = ScanType.both,
    bool multiScan = false,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScannerScreen(
          scanType: scanType,
          multiScan: multiScan, // FIXED
        ),
      ),
    );

    return result;
  }
}