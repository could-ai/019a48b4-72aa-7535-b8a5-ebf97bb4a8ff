import 'package:flutter/material.dart';

class LooplessLogo extends StatelessWidget {
  const LooplessLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.sync_disabled, // Represents breaking the subscription cycle
          color: Colors.blueAccent,
        ),
        SizedBox(width: 8),
        Text(
          'Loopless',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
