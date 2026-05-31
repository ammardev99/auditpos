import 'package:flutter/material.dart';

class ScannerDemoWidget extends StatelessWidget {
  final dynamic result;

  const ScannerDemoWidget({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          result.toString(),
        ),
      ),
    );
  }
}