import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'scanner_state.dart';

final scannerProvider =
    StateNotifierProvider<ScannerNotifier, ScannerState>(
  (ref) => ScannerNotifier(),
);

class ScannerNotifier extends StateNotifier<ScannerState> {
  ScannerNotifier() : super(const ScannerState());

  void toggleFlash() {
    state = state.copyWith(
      isFlashOn: !state.isFlashOn,
    );
  }

  void toggleCamera() {
    state = state.copyWith(
      isFrontCamera: !state.isFrontCamera,
    );
  }

  void addCode(String code, BuildContext context) {
    if (state.scannedCodes.contains(code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Already scanned"),
        ),
      );
      return;
    }

    state = state.copyWith(
      scannedCodes: [...state.scannedCodes, code],
    );
  }

  void clear() {
    state = const ScannerState();
  }
}