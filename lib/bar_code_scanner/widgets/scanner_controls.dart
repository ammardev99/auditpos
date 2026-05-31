import 'package:flutter/material.dart';

class ScannerControls extends StatelessWidget {
  final VoidCallback onFlash;
  final VoidCallback onSwitchCamera;
  final VoidCallback onManualEntry;
  final bool flashOn;
  final Color accentColor;

  const ScannerControls({
    super.key,
    required this.onFlash,
    required this.onSwitchCamera,
    required this.onManualEntry,
    required this.flashOn,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ControlButton(
          icon: flashOn ? Icons.bolt : Icons.bolt_outlined,
          label: 'Flash',
          active: flashOn,
          accentColor: accentColor,
          onTap: onFlash,
        ),
        _ControlButton(
          icon: Icons.cameraswitch_outlined,
          label: 'Flip',
          accentColor: accentColor,
          onTap: onSwitchCamera,
        ),
        _ControlButton(
          icon: Icons.keyboard_outlined,
          label: 'Manual',
          accentColor: accentColor,
          onTap: onManualEntry,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color accentColor;
  final bool active;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.accentColor,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = active ? accentColor : Colors.white;
    final bgColor =
        active
            ? accentColor.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.08);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: active ? accentColor : Colors.white38,
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
