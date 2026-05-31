class ScannerState {
  final List<String> scannedCodes;
  final bool isFlashOn;
  final bool isFrontCamera;
  final bool isLoading;

  const ScannerState({
    this.scannedCodes = const [],
    this.isFlashOn = false,
    this.isFrontCamera = false,
    this.isLoading = false,
  });

  ScannerState copyWith({
    List<String>? scannedCodes,
    bool? isFlashOn,
    bool? isFrontCamera,
    bool? isLoading,
  }) {
    return ScannerState(
      scannedCodes: scannedCodes ?? this.scannedCodes,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}