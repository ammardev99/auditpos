import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:zi_core/zi_core_io.dart';

import '../models/scan_type.dart';
import '../providers/scanner_provider.dart';
import 'manual_entry_dialog.dart';
import 'scanner_controls.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  final ScanType scanType;
  final bool multiScan;

  const ScannerScreen({
    super.key,
    required this.scanType,
    required this.multiScan,
  });

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _controller;
  late final AnimationController _scanLineController;
  late final Animation<double> _scanLineAnimation;

  bool _isDisposed = false;
  bool _isScanned = false;
  bool _scannerPaused = false;
  static const double _overlayOpacity = 0.80;
  static const double _cutoutH = 0.76;
  static const double _cutoutV = 0.64;
  Future<void> _pauseScanner() async {
    if (_scannerPaused || _isDisposed) return;

    _scannerPaused = true;

    _scanLineController.stop();

    await _controller.stop();

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _resumeScanner() async {
    if (!_scannerPaused || _isDisposed) return;

    await _controller.start();

    if (!mounted) return;

    _scanLineController.repeat(reverse: true);

    _scannerPaused = false;

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ZiLogger.log('📷 Scanner INIT');

    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _scanLineAnimation = CurvedAnimation(
      parent: _scanLineController,
      curve: Curves.easeInOut,
    );
  }

  void _handleScan(String code) {
    if (_isDisposed || !mounted) return;
    ZiLogger.log('📦 SCAN: $code');

    if (!widget.multiScan) {
      // ✅ Guard: only pop once
      if (_isScanned) return;
      setState(() => _isScanned = true);

      // ✅ Direct pop — no postFrameCallback race condition
      Navigator.pop(context, code);
      return;
    }

    ref.read(scannerProvider.notifier).addCode(code, context);
  }

  @override
  void dispose() {
    _isDisposed = true;
    ZiLogger.log('❌ Scanner DISPOSE');
    _scanLineController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scannerProvider);
    final primaryColor = ZiColors.primary;

    return ZiScaffoldB(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scanner'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: _CameraViewport(
              controller: _controller,
              scanLineAnimation: _scanLineAnimation,
              multiScan: widget.multiScan,
              scannedCount: state.scannedCodes.length,
              isDisposed: _isDisposed,
              isScanned: _isScanned,
              onDetect: _handleScan,
              cutoutHFraction: _cutoutH,
              cutoutVFraction: _cutoutV,
              overlayOpacity: _overlayOpacity,
              accentColor: primaryColor,
            ),
          ),

          if (widget.multiScan)
            Expanded(
              child: _ScannedList(
                codes: state.scannedCodes,
                accentColor: primaryColor,
              ),
            ),

          _ControlBar(
            flashOn: state.isFlashOn,
            accentColor: primaryColor,
            onFlash: () {
              ref.read(scannerProvider.notifier).toggleFlash();
              _controller.toggleTorch();
            },
            onSwitchCamera: () {
              ref.read(scannerProvider.notifier).toggleCamera();
              _controller.switchCamera();
            },
            onManualEntry: () async {
              await _pauseScanner();

              if (!mounted) return;

              final result = await showDialog<String>(
                // ignore: use_build_context_synchronously
                context: context,

                barrierDismissible: true,

                builder: (_) => const ManualEntryDialog(),
              );

              if (!mounted) return;

              await _resumeScanner();

              if (!mounted) return;

              if (result != null && result.trim().isNotEmpty) {
                _handleScan(result.trim());
              }
            },
          ),

          if (widget.multiScan)
            _DoneButton(
              count: state.scannedCodes.length,
              color: primaryColor,
              onTap: () => Navigator.pop(context, state.scannedCodes),
            ),
        ],
      ),
    );
  }
}

// ─── Camera Viewport ──────────────────────────────────────────────────────────

class _CameraViewport extends StatelessWidget {
  final MobileScannerController controller;
  final Animation<double> scanLineAnimation;
  final bool multiScan;
  final int scannedCount;
  final bool isDisposed;
  final bool isScanned;
  final ValueChanged<String> onDetect;
  final double cutoutHFraction;
  final double cutoutVFraction;
  final double overlayOpacity;
  final Color accentColor;

  const _CameraViewport({
    required this.controller,
    required this.scanLineAnimation,
    required this.multiScan,
    required this.scannedCount,
    required this.isDisposed,
    required this.isScanned,
    required this.onDetect,
    required this.cutoutHFraction,
    required this.cutoutVFraction,
    required this.overlayOpacity,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (capture) {
            if (isDisposed || (isScanned && !multiScan)) return;
            final code = capture.barcodes.firstOrNull?.rawValue;
            if (code != null) onDetect(code);
          },
          errorBuilder:
              (context, error) => Center(
                child: Text(
                  'Camera error: ${error.errorCode}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
        ),

        _ScanOverlay(
          cutoutHFraction: cutoutHFraction,
          cutoutVFraction: cutoutVFraction,
          overlayOpacity: overlayOpacity,
        ),

        _ScanBox(
          animation: scanLineAnimation,
          cutoutHFraction: cutoutHFraction,
          cutoutVFraction: cutoutVFraction,
          accentColor: accentColor,
        ),

        // Hint text — positioned above bottom overlay band
        Align(
          alignment: const Alignment(0, 0.82),
          child: Text(
            multiScan ? 'Keep scanning…' : 'Align within frame',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              letterSpacing: 0.4,
            ),
          ),
        ),

        if (multiScan && scannedCount > 0)
          Positioned(
            top: 12,
            right: 12,
            child: _ScanCountBadge(
              count: scannedCount,
              accentColor: accentColor,
            ),
          ),
      ],
    );
  }
}

// ─── Overlay Painter ──────────────────────────────────────────────────────────

class _ScanOverlay extends StatelessWidget {
  final double cutoutHFraction;
  final double cutoutVFraction;
  final double overlayOpacity;

  const _ScanOverlay({
    required this.cutoutHFraction,
    required this.cutoutVFraction,
    required this.overlayOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(
        cutoutHFraction: cutoutHFraction,
        cutoutVFraction: cutoutVFraction,
        overlayOpacity: overlayOpacity,
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final double cutoutHFraction;
  final double cutoutVFraction;
  final double overlayOpacity;

  const _OverlayPainter({
    required this.cutoutHFraction,
    required this.cutoutVFraction,
    required this.overlayOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cW = size.width * cutoutHFraction;
    final cH = size.height * cutoutVFraction;
    final left = (size.width - cW) / 2;
    final top = (size.height - cH) / 2;

    final paint =
        Paint()..color = Colors.black.withValues(alpha: overlayOpacity);

    // 4-quadrant mask — cutout stays transparent
    canvas
      ..drawRect(Rect.fromLTWH(0, 0, size.width, top), paint)
      ..drawRect(
        Rect.fromLTWH(0, top + cH, size.width, size.height - top - cH),
        paint,
      )
      ..drawRect(Rect.fromLTWH(0, top, left, cH), paint)
      ..drawRect(
        Rect.fromLTWH(left + cW, top, size.width - left - cW, cH),
        paint,
      );
  }

  @override
  bool shouldRepaint(_OverlayPainter old) =>
      old.cutoutHFraction != cutoutHFraction ||
      old.cutoutVFraction != cutoutVFraction;
}

// ─── Scan Box (corners + line) ────────────────────────────────────────────────

class _ScanBox extends StatelessWidget {
  final Animation<double> animation;
  final double cutoutHFraction;
  final double cutoutVFraction;
  final Color accentColor;

  const _ScanBox({
    required this.animation,
    required this.cutoutHFraction,
    required this.cutoutVFraction,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final cW = w * cutoutHFraction;
        final cH = h * cutoutVFraction;
        final left = (w - cW) / 2;
        final top = (h - cH) / 2;
        const cornerSize = 22.0;
        const thickness = 3.0;

        return Stack(
          children: [
            // Top-left corner
            Positioned(
              top: top,
              left: left,
              child: _Corner(
                size: cornerSize,
                thickness: thickness,
                color: accentColor,
                top: true,
                leftSide: true,
              ),
            ),
            // Top-right corner
            Positioned(
              top: top,
              left: left + cW - cornerSize,
              child: _Corner(
                size: cornerSize,
                thickness: thickness,
                color: accentColor,
                top: true,
                leftSide: false,
              ),
            ),
            // Bottom-left corner
            Positioned(
              top: top + cH - cornerSize,
              left: left,
              child: _Corner(
                size: cornerSize,
                thickness: thickness,
                color: accentColor,
                top: false,
                leftSide: true,
              ),
            ),
            // Bottom-right corner
            Positioned(
              top: top + cH - cornerSize,
              left: left + cW - cornerSize,
              child: _Corner(
                size: cornerSize,
                thickness: thickness,
                color: accentColor,
                top: false,
                leftSide: false,
              ),
            ),

            // Scan line
            AnimatedBuilder(
              animation: animation,
              builder: (_, __) {
                final lineY = top + 4 + (cH - 8) * animation.value;
                return Positioned(
                  top: lineY,
                  left: left + 4,
                  right: w - left - cW + 4,
                  child: _ScanLine(color: accentColor),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _Corner extends StatelessWidget {
  final double size;
  final double thickness;
  final Color color;
  final bool top;
  final bool leftSide;

  const _Corner({
    required this.size,
    required this.thickness,
    required this.color,
    required this.top,
    required this.leftSide,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          color: color,
          thickness: thickness,
          top: top,
          leftSide: leftSide,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool top;
  final bool leftSide;

  const _CornerPainter({
    required this.color,
    required this.thickness,
    required this.top,
    required this.leftSide,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.square
          ..style = PaintingStyle.stroke;

    final x = leftSide ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    final dx = leftSide ? size.width : -size.width;
    final dy = top ? size.height : -size.height;

    canvas
      ..drawLine(Offset(x, y), Offset(x + dx, y), paint)
      ..drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}

class _ScanLine extends StatelessWidget {
  final Color color;
  const _ScanLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

// ─── Scan Count Badge ─────────────────────────────────────────────────────────

class _ScanCountBadge extends StatelessWidget {
  final int count;
  final Color accentColor;

  const _ScanCountBadge({required this.count, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.18),
        border: Border.all(color: accentColor.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$count scanned',
        style: TextStyle(color: accentColor, fontSize: 11, letterSpacing: 0.3),
      ),
    );
  }
}

// ─── Scanned List ─────────────────────────────────────────────────────────────

class _ScannedList extends StatelessWidget {
  final List<String> codes;
  final Color accentColor;

  const _ScannedList({required this.codes, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D0D0D),
      child: ListView.separated(
        itemCount: codes.length,
        separatorBuilder:
            (_, __) => const Divider(
              height: 0,
              thickness: 0.5,
              color: Color(0x12FFFFFF),
            ),
        itemBuilder:
            (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    codes[i],
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}

// ─── Control Bar ─────────────────────────────────────────────────────────────

class _ControlBar extends StatelessWidget {
  final bool flashOn;
  final Color accentColor;
  final VoidCallback onFlash;
  final VoidCallback onSwitchCamera;
  final VoidCallback onManualEntry;

  const _ControlBar({
    required this.flashOn,
    required this.accentColor,
    required this.onFlash,
    required this.onSwitchCamera,
    required this.onManualEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D0D0D),
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: ScannerControls(
        flashOn: flashOn,
        accentColor: accentColor,
        onFlash: onFlash,
        onSwitchCamera: onSwitchCamera,
        onManualEntry: onManualEntry,
      ),
    );
  }
}

// ─── Done Button ─────────────────────────────────────────────────────────────

class _DoneButton extends StatelessWidget {
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _DoneButton({
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: color,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        child: Text(
          'Done — $count ${count == 1 ? 'item' : 'items'}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
