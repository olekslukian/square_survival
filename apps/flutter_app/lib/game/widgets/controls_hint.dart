import 'package:flutter/material.dart';

class ControlsHint extends StatelessWidget {
  const ControlsHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      bottom: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Controls: [W, A, S, D] or Arrow Keys to move',
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ),
    );
  }
}
