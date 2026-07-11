import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final bool isConnected;

  const StatusIndicator({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isConnected ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
            border: Border.all(
              color: isConnected ? Colors.green : Colors.grey,
              width: 4,
            ),
          ),
          child: Icon(
            isConnected ? Icons.check : Icons.close,
            color: isConnected ? Colors.green : Colors.grey,
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          isConnected ? 'Connected' : 'Disconnected',
          style: TextStyle(
            color: isConnected ? Colors.green : Colors.grey,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}